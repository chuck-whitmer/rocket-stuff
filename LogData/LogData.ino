// include the SD library:
#include <SPI.h>
#include <SD.h>

// include barometer library:
#include <Wire.h>
#include "SparkFunMPL3115A2.h"

#include <Adafruit_Sensor.h>
#include "Adafruit_BNO055.h"

MPL3115A2 barometer;

//#include <Adafruit_MPL3115A2.h>
//Adafruit_MPL3115A2 barometer = Adafruit_MPL3115A2();

/* Set the delay between fresh samples */
#define BNO055_SAMPLERATE_DELAY_MS (100)
Adafruit_BNO055 bno = Adafruit_BNO055();

const int sdChipSelect = 10;
File file;
String fileName = "Logxxx.txt";
unsigned long nextAltitude;
int altitudeDelay = 1000;
unsigned long lastTick;
const int ERRORLED = 9;

void setup() {
  Wire.begin();
  for (int ii=2; ii<=9; ii++)
    pinMode(ii,OUTPUT); // LED block on D2 to D9
  pinMode(A0,INPUT_PULLUP); // The button
  pinMode(A2,INPUT_PULLUP); // Jumper2
  pinMode(A3,INPUT_PULLUP); // Jumper3
  // Open serial communications and wait for port to open:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }

  Serial.println("\nInitializing barometer...");

//  if (!barometer.begin())
//  {
//    Serial.println("initialization failed");
//    while (1);
//  }
  
  // Configure the barometer.
  Serial.println("Initialize barometer");
  barometer.begin();
  barometer.setModeAltimeter(); // Measure altitude above sea level in meters
  //barometer.setModeBarometer(); // Measure pressure in Pascals from 20 to 110 kPa
  barometer.setOversampleRate(7); // 7 for 128.
  barometer.enableEventFlags(); // Enable all three pressure and temp event flags 

  // Configure the IMU
  Serial.println("Initialize IMU");
  if(!bno.begin(Adafruit_BNO055::OPERATION_MODE_IMUPLUS, Adafruit_BNO055::ACC_RANGE_8G))
  {
    Serial.print("No BNO055 detected");
    while(1);
  }
  bno.setExtCrystalUse(true);
  //bno.setAccRange(Adafruit_BNO055::ACC_RANGE_8G);
  
  Serial.println("Initializing SD card");
  if (!SD.begin(sdChipSelect))
  {
    Serial.println("initialization failed");
    while (1);
  }
  digitalWrite(ERRORLED,LOW);
}

// Adafruit library would hang on reading temperature if altitude was not read first. 
// Sparkfun library allows reducing the oversampling from 128x.

int lineCount = 0;

const int RUNSTATE_IDLE = 1;
const int RUNSTATE_SETUP = 2;
const int RUNSTATE_COLLECT = 3;
const int RUNSTATE_STOP = 4;
const int RUNSTATE_ERRORHOLD = 5;
const int BUTTON_UP = 1;
const int BUTTON_DOWN = 2;

int buttonState = BUTTON_UP;
unsigned int buttonDownTime;
int runState = RUNSTATE_IDLE;

void loop() 
{
  bool button = digitalRead(A0) == LOW;
  //bool jumper2 = digitalRead(A2) == LOW;
  //bool jumper3 = digitalRead(A3) == LOW;
  bool buttonPush = false;
  bool buttonLongPush = false;

  if (buttonState == BUTTON_UP)
  {
    if (button)
    {
      buttonDownTime = millis();
      buttonState = BUTTON_DOWN;
    }
  }
  else if (buttonState == BUTTON_DOWN)
  {
    if (!button)
    {
      unsigned int dt = (unsigned int)millis()-buttonDownTime;
      if (dt < 500)
        buttonPush = true;
      else
        buttonLongPush = true;
      buttonState = BUTTON_UP;
    }
  }

  if (runState == RUNSTATE_IDLE)
  {
    if (buttonLongPush)
    {
      runState = RUNSTATE_SETUP;
    }
  }
  else if (runState == RUNSTATE_ERRORHOLD)
  {
    if (buttonPush)
    {
      digitalWrite(ERRORLED,LOW);
      runState = RUNSTATE_IDLE;      
    }
  }
  else if (runState == RUNSTATE_SETUP)
  {
    file = getUniqueFile(); // Side effect: Updates fileName.
    if (!file)
    {
      Serial.println("open failed");
      digitalWrite(ERRORLED,HIGH);
      runState = RUNSTATE_ERRORHOLD;
    }
    else
    {
      file.print(format(millis(),6));
      file.println(" start new file");
      delay(1000);
      Serial.print("Collecting data to ");
      Serial.println(fileName);
      lastTick = millis();
      nextAltitude = millis() + altitudeDelay;
      runState = RUNSTATE_COLLECT;
    }
  }
  else if (runState == RUNSTATE_COLLECT)
  {
    if (buttonLongPush) runState = RUNSTATE_STOP;
    digitalWrite(2,HIGH);
    unsigned long t1,t2,t3,t4,t5;
    t1 = millis();
    float altm = 0.0;
    float tempC = 0.0;
    if (t1 >= nextAltitude)
    {
      altm = barometer.readAltitude();
      t2 = millis();
      tempC = barometer.readTemp();
      nextAltitude += altitudeDelay;
    }
    else
    {
      t2 = millis();
    }
    t3 = millis();
    imu::Vector<3> acceleration = bno.getVector(Adafruit_BNO055::VECTOR_ACCELEROMETER);
    imu::Quaternion quat = bno.getQuat();
    imu::Vector<3> linearAcceleration = bno.getVector(Adafruit_BNO055::VECTOR_LINEARACCEL);
    imu::Vector<3> gravity = bno.getVector(Adafruit_BNO055::VECTOR_GRAVITY);
    uint8_t sys, gyro, accel, mag = 0;
    bno.getCalibration(&sys, &gyro, &accel, &mag);
    t5 = millis();

    file.print(format(t1,8));
    file.print(" alt ");
    file.print(format(altm,1,7));
    file.print(format(t2,7));
    file.print(" temp ");
    file.print(format(tempC,1,7));
    file.print(format(t3,7));
    file.print(" acc ");
    file.print(format(acceleration.x(),2,7));
    file.print(format(acceleration.y(),2,7));
    file.print(format(acceleration.z(),2,7));
    file.print(" quat ");
    file.print(format(quat.w(),5,9));
    file.print(format(quat.x(),5,9));
    file.print(format(quat.y(),5,9));
    file.print(format(quat.z(),5,9));
    file.print(" linear ");
    file.print(format(linearAcceleration.x(),2,7));
    file.print(format(linearAcceleration.y(),2,7));
    file.print(format(linearAcceleration.z(),2,7));
    file.print(" grav ");
    file.print(format(gravity.x(),2,7));
    file.print(format(gravity.y(),2,7));
    file.print(format(gravity.z(),2,7));
    file.print(" cal ");
    file.print(accel);
    file.println(format(t5,8));

    digitalWrite(2,LOW);
  }
  else if (runState == RUNSTATE_STOP)
  {
    runState = RUNSTATE_IDLE;
    file.close();
    Serial.println("file closed");

    // Dump the file so we don't need to wrestle with the card.
    file = SD.open(fileName);
    while (file.available())
    {
      Serial.write(file.read());
    }
    file.close();
  }
  waitForTick(20);
}

File getUniqueFile()
{
  int jj;
  for (unsigned int ii=0; ii<1000; ii++)
  {
    pasteThreeDigitsIntoName(fileName,3,ii);
    jj = ii;
    if (!SD.exists(fileName)) break;        
  }
  // We normally get here with the name of an empty slot, corresponding to jj.
  // If there are no empty slots then we append data to the existing Log999.txt.
  // We open a slot for the next run.
  String nextFile = String(fileName);
  pasteThreeDigitsIntoName(nextFile,3,jj+1);
  SD.remove(nextFile);
//  Serial.print("open unique file: ");
//  Serial.println(fileName);
//  Serial.print("Next file: ");
//  Serial.println(nextFile);
  return SD.open(fileName,FILE_WRITE);
}

void pasteThreeDigitsIntoName(String& str, int place, unsigned int num)
{
    String numstr = String(num%1000+1000);
    str[place] = numstr[1];
    str[place+1] = numstr[2];
    str[place+2] = numstr[3];  
}

void waitForTick(int d)
{
  lastTick += d;
  unsigned long diff = lastTick - millis();
  if (diff < 1000)
    delay(diff);
}

char chars[21];

char* format(unsigned long int n, int width)
{
  return rightAlign(String(n),width);
}

//char* format(int n, int width)
//{
//  return rightAlign(String(n),width);
//}

char* format(float x, int digits, int width)
{
  return rightAlign(String(x,digits),width);
}

char* rightAlign(String str, int width)
{
  int len = str.length();
  int ii=0;
  if (len > width)
  {
    while (ii<width)
      chars[ii++] = '*';
  }
  else
  {
    while (ii<width-len)
      chars[ii++] = ' ';
    while (ii<width)
    {
      chars[ii] = str[ii+len-width];
      ii++;
    }
  }
  chars[ii] = '\0';
  return chars;
}
