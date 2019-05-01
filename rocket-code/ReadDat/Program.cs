using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RocketCode
{
    class Program
    {
        static string filename = null;
        static bool doDump = false;
        static bool doStats = false;

        static void Main(string[] args)
        {
            if (!ReadArgs(args)) return;

            try
            {
                LogFile data = new LogFile(filename);

                if (doDump)
                {
                    int n = data.rawTimes.Length;
                    for (int i = 0; i < n; i++)
                    {
                        UInt32 time = data.rawTimes[i];
                        double altitude = data.rawAltitude[i];
                        float[] acc = data.rawAccelerometer[i];
                        float[] mag = data.rawMagnetometer[i];
                        float[] gyro = data.rawGyroscope[i];

                        Console.Write("{0,10}", time);
                        Console.Write(" alt {0,7:0.0}", altitude);
                        Console.Write(" acc {0,8:0.00}{1,8:0.00}{2,8:0.00}", acc[0], acc[1], acc[2]);
                        Console.Write(" mag {0,8:0.00}{1,8:0.00}{2,8:0.00}", mag[0], mag[1], mag[2]);
                        Console.Write(" gyro {0,8:0.00}{1,8:0.00}{2,8:0.00}", gyro[0], gyro[1], gyro[2]);
                        Console.WriteLine();
                    }
                }

                if (doStats)
                {
                    int nReadings = data.rawTimes.Length;
                    Console.WriteLine("{0} readings", nReadings);
                    double startTime = data.rawTimes[0] / 1000.0;
                    double endTime = data.rawTimes[nReadings-1] / 1000.0;
                    double totalTime = endTime - startTime;

                    Console.WriteLine("Start, end, total time = {0:0.000} {1:0.000} {2:0.000}",
                        startTime, endTime, totalTime);

                    int nAccChanges = LogFile.CountChanges(data.accChanged);
                    int nMagChanges = LogFile.CountChanges(data.magChanged);
                    int nGyroChanges = LogFile.CountChanges(data.gyroChanged);

                    Console.WriteLine("Acc: {0} changes, avg time {1:0.000} msec", nAccChanges, totalTime / nAccChanges * 1000.0);
                    Console.WriteLine("Mag: {0} changes, avg time {1:0.000} msec", nMagChanges, totalTime / nMagChanges * 1000.0);
                    Console.WriteLine("Gyro: {0} changes, avg time {1:0.000} msec", nGyroChanges, totalTime / nGyroChanges * 1000.0);

                }


            }
            catch (Exception e)
            {
                Console.Error.WriteLine("Exception: {0}", e.Message);
            }
        }

        static bool ReadArgs(string[] args)
        {
            for (int ii=0; ii<args.Length; ii++)
            {
                if (args[ii][0] == '-')
                {
                    switch (args[ii])
                    {
                        case "-dump":
                            doDump = true;
                            break;
                        case "-stats":
                            doStats = true;
                            break;
                        case "-?":
                            ShowUsage();
                            return false;
                        default:
                            ArgError(String.Format("Unknown switch {0}", args[ii]));
                            return false;
                    }
                }
                else if (filename == null)
                {
                    filename = args[ii];
                }
                else
                {
                    ArgError(String.Format("Unrecongnized parameter {0}", args[ii]));
                    return false;
                }
            }
            if (filename == null)
            {
                ArgError("A filename is required");
                return false;
            }
            return true;
        }

        static void ShowUsage()
        {
            Console.WriteLine(@"
ReadDat <options> <filename>
  Reads a binary data log file.
  Options:
    -dump              Creates a text file containing the data.
    -stats             Reports stats about the data.
");
            
        }

        static void ArgError(string msg)
        {
            Console.Error.WriteLine("Error: {0}", msg);
        }
    }
}
