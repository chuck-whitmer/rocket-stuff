using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RocketCode
{
    class LogFile
    {
        public UInt32[] rawTimes;
        public float[] rawAltitude;
        public float[][] rawAccelerometer;
        public float[][] rawMagnetometer;
        public float[][] rawGyroscope;

        public bool[] accChanged;
        public bool[] magChanged;
        public bool[] gyroChanged;

        public LogFile(string filename, long iStart=0, long iLength = long.MaxValue)
        {
            List<UInt32> timeList = new List<UInt32>();
            List<float> altList = new List<float>();
            List<float[]> accList = new List<float[]>();
            List<float[]> magList = new List<float[]>();
            List<float[]> gyroList = new List<float[]>();

            string ext = Path.GetExtension(filename).ToLower();
            if (ext == ".dat")
            {
                // Read binary file.
                BinaryReader file = new BinaryReader(File.Open(filename, FileMode.Open));
                if (file.ReadByte() != '\xCC') throw new Exception("Invalid rocket data file");
                if (file.ReadByte() != '\x01') throw new Exception("Unknown rocket data format");
                long bytesLeftToRead = file.BaseStream.Length - 2;

                // Format 01 consists of repeated records.
                // time, altitude, accelerometer vector, magnetometer vector, gyroscope vector
                const long recordSize = sizeof(UInt32) + sizeof(float) + 9 * sizeof(Int16);

                long recordsLeftToRead = bytesLeftToRead / recordSize;

                if (iStart != 0)
                {
                    recordsLeftToRead -= iStart;
                    file.BaseStream.Seek(iStart * recordSize, SeekOrigin.Current);
                }
                if (recordsLeftToRead > iLength)
                    recordsLeftToRead = iLength;

                while (bytesLeftToRead >= recordSize)
                {
                    UInt32 time = file.ReadUInt32();
                    float altitude = file.ReadSingle();
                    float[] acc = ReadAndScaleVector(file, 100.0f);
                    float[] mag = ReadAndScaleVector(file, 16.0f);
                    float[] gyro = ReadAndScaleVector(file, 16.0f);
                    bytesLeftToRead -= recordSize;
                    timeList.Add(time);
                    altList.Add(altitude);
                    accList.Add(acc);
                    magList.Add(mag);
                    gyroList.Add(gyro);
                }
                if (bytesLeftToRead != 0)
                {
                    Console.Error.WriteLine("Warning: {0} bytes unread at end of file", bytesLeftToRead);
                }
                rawTimes = timeList.ToArray();
                rawAltitude = altList.ToArray();
                rawAccelerometer = accList.ToArray();
                rawMagnetometer = magList.ToArray();
                rawGyroscope = gyroList.ToArray();
            }
            else if (ext == ".txt")
            {
                // Read ascii version.
                throw new NotImplementedException("Text data file");
            }

            accChanged = LocateChanges(rawAccelerometer);
            magChanged = LocateChanges(rawMagnetometer);
            gyroChanged = LocateChanges(rawGyroscope);
        }

        public static int CountChanges(bool[] b)
        {
            int n = 0;
            for (int i = 0; i < b.Length; i++)
                if (b[i]) n++;
            return n;
        }

        bool[] LocateChanges(float[][] data)
        {
            bool[] b = new bool[data.Length - 1];
            for (int i = 0; i < b.Length; i++)
            {
                for (int j = 0; j < 3; j++)
                {
                    if (data[i][j] != data[i + 1][j]) b[i] = true;
                }
            }
            return b;
        }

        static float[] ReadAndScaleVector(BinaryReader file, float s)
        {
            Int16 i1 = file.ReadInt16();
            Int16 i2 = file.ReadInt16();
            Int16 i3 = file.ReadInt16();
            return new float[] { i1 / s, i2 / s, i3 / s };
        }


    }
}
