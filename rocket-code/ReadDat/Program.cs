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

        static void Main(string[] args)
        {
            if (!ReadArgs(args)) return;

            try
            {
                BinaryReader file = new BinaryReader(File.Open(filename, FileMode.Open));
                if (file.ReadByte() != '\xCC') throw new Exception("Invalid rocket data file");
                if (file.ReadByte() != '\x01') throw new Exception("Unknown rocket data format");
                long bytesLeftToRead = file.BaseStream.Length - 2;

                // Format 01 consists of repeated records.
                // time, altitude, accelerometer vector, magnetometer vector, gyroscope vector
                const long recordSize = sizeof(UInt32) + sizeof(float) + 9 * sizeof(Int16);
                while (bytesLeftToRead >= recordSize)
                {
                    UInt32 time = file.ReadUInt32();
                    double altitude = file.ReadSingle();
                    double[] acc = ReadAndScaleVector(file, 100.0);
                    double[] mag = ReadAndScaleVector(file, 16.0);
                    double[] gyro = ReadAndScaleVector(file, 16.0);
                    bytesLeftToRead -= recordSize;

                    Console.Write("{0,10}", time);
                    Console.Write(" alt {0,7:0.0}", altitude);
                    Console.Write(" acc {0,8:0.00}{1,8:0.00}{2,8:0.00}", acc[0], acc[1], acc[2]);
                    Console.Write(" mag {0,8:0.00}{1,8:0.00}{2,8:0.00}", mag[0], mag[1], mag[2]);
                    Console.Write(" gyro {0,8:0.00}{1,8:0.00}{2,8:0.00}", gyro[0], gyro[1], gyro[2]);
                    Console.WriteLine();
                }
                if (bytesLeftToRead != 0)
                {
                    Console.Error.WriteLine("Warning: {0} bytes unread at end of file", bytesLeftToRead);
                }
            }
            catch (Exception e)
            {
                Console.Error.WriteLine("Exception: {0}", e.Message);
            }
        }

        static double[] ReadAndScaleVector(BinaryReader file, double s)
        {
            Int16 i1 = file.ReadInt16();
            Int16 i2 = file.ReadInt16();
            Int16 i3 = file.ReadInt16();
            return new double[] { i1 / s, i2 / s, i3 / s };
        }

        static bool ReadArgs(string[] args)
        {
            for (int ii=0; ii<args.Length; ii++)
            {
                if (args[ii][0] == '-')
                {
                    switch (args[ii])
                    {
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

        static void ArgError(string msg)
        {
            Console.Error.WriteLine("Error: {0}", msg);
        }
    }
}
