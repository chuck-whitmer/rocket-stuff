:: It is assumed that you have cloned projects into an ArduinoLibraries folder at the
:: same level as rocket-stuff.
::
:: cd \git
:: md ArduinoLibraries
:: cd ArduinoLibraries
:: git clone https://github.com/chuck-whitmer/cw_Adafruit_BNO055.git
:: git clone https://github.com/adafruit/Adafruit_BNO055.git
:: git clone https://github.com/sparkfun/MPL3115A2_Breakout.git
:: git clone https://github.com/adafruit/Adafruit_Sensor.git
::
:: The following commands need to be run as administrator from the rocket-stuff folder.
::
cd libraries
mklink /d cw_Adafruit_BNO055 ..\..\ArduinoLibraries\cw_Adafruit_BNO055\
mklink /d Adafruit_BNO055 ..\..\ArduinoLibraries\Adafruit_BNO055\
mklink /d Adafruit_Sensor ..\..\ArduinoLibraries\Adafruit_Sensor\
mklink /d SparkFunMPL3115A2 ..\..\ArduinoLibraries\MPL3115A2_Breakout\Libraries\Arduino\src\




