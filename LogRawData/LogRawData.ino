// include the SD library:
#include <SPI.h>
#include <SD.h>

// include barometer library:
#include <Wire.h>
#include <SparkFunMPL3115A2.h> // The Adafruit driver is too slow for retrieving data.

#include <Adafruit_Sensor.h>
#include <cw_Adafruit_BNO055.h>

MPL3115A2 barometer;

Adafruit_BNO055 bno = Adafruit_BNO055();

const int sdChipSelect = 10;
File file;
char *fileName = "Logxxx.dat";
unsigned long nextAltitude;
int altitudeDelay = 1000;
unsigned long lastTick;
const int ERRORLED = 9;

const byte FILETYPE = 0xCC;
const byte VERSION = 0x01;

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

  // Configure the barometer.
  Serial.println("Initialize barometer");
  barometer.begin();
  barometer.setModeAltimeter(); // Measure altitude above sea level in meters
  barometer.setOversampleRate(7); // 7 for 128.
  barometer.enableEventFlags(); // Enable all three pressure and temp event flags 

  // Configure the IMU
  Serial.println("Initialize IMU");
  if(!bno.begin(Adafruit_BNO055::OPERATION_MODE_AMG, Adafruit_BNO055::ACC_RANGE_8G))
  {
    Serial.print("No BNO055 detected");
    while(1);
  }
  bno.setExtCrystalUse(true);
  bno.setAccBandWidth(Adafruit_BNO055::ACC_BANDWIDTH_31Hz);
  
  Serial.println("Initializing SD card");
  if (!SD.begin(sdChipSelect))
  {
    Serial.println("initialization failed");
    while (1);
  }
  digitalWrite(ERRORLED,LOW);
}

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
const int NDATA = (Adafruit_BNO055::BNO055_GYRO_DATA_Z_MSB_ADDR + 1 - Adafruit_BNO055::BNO055_ACCEL_DATA_X_LSB_ADDR);

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
      digitalWrite(2,HIGH);
    }
  }
  else if (buttonState == BUTTON_DOWN)
  {
    unsigned int dt = (unsigned int)millis()-buttonDownTime;
    if (dt >= 500)
      digitalWrite(3,HIGH);
    
    if (!button)
    {
      if (dt < 500)
        buttonPush = true;
      else
        buttonLongPush = true;
      buttonState = BUTTON_UP;
      digitalWrite(3,LOW);
      digitalWrite(2,LOW);
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
      file.write(FILETYPE);
      file.write(VERSION);
      delay(500);  
      Serial.print("Collecting data to ");
      Serial.println(fileName);
      lastTick = millis();
      nextAltitude = millis() + altitudeDelay;
      runState = RUNSTATE_COLLECT;
      digitalWrite(2,HIGH);
    }
  }
  else if (runState == RUNSTATE_COLLECT)
  {
    if (buttonLongPush) runState = RUNSTATE_STOP;
    unsigned long t1;
    t1 = millis();
    float altm = 0.0;
    //float tempC = 0.0;
    if (t1 >= nextAltitude)
    {
      altm = barometer.readAltitude();
      //tempC = barometer.readTemp();
      nextAltitude += altitudeDelay;
    }
    // Read IMU data.
    // 6 bytes for each of ACC, MAG, GYRO.
    byte buf[NDATA];
    bno.readLen(Adafruit_BNO055::BNO055_ACCEL_DATA_X_LSB_ADDR, buf, NDATA);
    
    // Write it to the file.
    file.write((byte *)&t1, sizeof(t1));
    file.write((byte *)&altm, sizeof(altm));
    //file.write((byte *)&tempC, sizeof(tempC));
    file.write(buf,NDATA);
  }
  else if (runState == RUNSTATE_STOP)
  {
    digitalWrite(2,LOW);
    runState = RUNSTATE_IDLE;
    file.close();
    Serial.println("file closed");

    // Dump the file so we don't need to wrestle with the card for debugging.
    dumpFileToSerial(fileName);
  }
  waitForTick(4);
}

void dumpFileToSerial(char *filename)
{
    byte buf[NDATA];
    unsigned long t1;
    float ee;
    
    file = SD.open(filename);
    Serial.println(filename);
    if (file.available())
    {
      Serial.print(formatHex((uint8_t)file.read()));
      Serial.println(formatHex((uint8_t)file.read()));
    }
    while (file.available())
    {
      file.read((byte *)&t1, sizeof(t1));
      Serial.print(format(t1,10));
      file.read((byte *)&ee, sizeof(ee)); // alt
      Serial.print(format(ee,2,9));
      //file.read((byte *)&ee, sizeof(ee)); // temp
      //Serial.print(format(ee,2,9));
      file.read(buf, NDATA);
      uint16_t *p = (uint16_t *) buf;
      for (int i=0; i<3; i++)
      {
        Serial.print(' ');
        for (int j=0; j<3; j++)
        {
          Serial.print(' ');
          Serial.print(formatHex(*p++));
        }
      }
      Serial.println();
    }
    file.close();
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
  pasteThreeDigitsIntoName(fileName,3,jj+1);
  SD.remove(fileName);
  pasteThreeDigitsIntoName(fileName,3,jj);
  return SD.open(fileName,FILE_WRITE);
}

void waitForTick(int d)
{
  lastTick += d;
  unsigned long diff = lastTick - millis();
  if (diff - 1ul < 1000ul)  // Don't wait with 0, or more than 1 second.
    delay(diff);
}

void printVector(char *label, imu::Vector<3> vec)
{
    file.print(label);
    file.print(format(vec.x(),2,8));
    file.print(format(vec.y(),2,8));
    file.print(format(vec.z(),2,8));
}

char chars[21];
char digits[] = "0123456789ABCDEF";

char* formatHex(uint16_t n)
{
  chars[4] = '\0';
  chars[3] = digits[n & 15];
  n >>= 4;
  chars[2] = digits[n & 15];
  n >>= 4;
  chars[1] = digits[n & 15];
  chars[0] = digits[(n>>4) & 15];
  return chars;
}

char* formatHex(uint8_t n)
{
  chars[2] = '\0';
  chars[1] = digits[n & 15];
  chars[0] = digits[(n>>4) & 15];
  return chars;
}

void pasteThreeDigitsIntoName(char *str, int place, unsigned int num)
{
  str[place+2] = digits[num % 10];
  num /= 10;
  str[place+1] = digits[num % 10];
  num /= 10;
  str[place] = digits[num % 10];
}

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
