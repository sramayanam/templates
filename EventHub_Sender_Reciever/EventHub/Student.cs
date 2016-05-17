using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EventHub
{
    class Sensor
    {

        public String ReadingID;
        //public String[] CoursesAttended;
        //public Random Grade;
        public Double[] SensorReadings;
        public int HomeID;
        public DateTime genTmStamp;
     }

    class Vehicle
    {
        public String TelematicID;
        public Boolean HiredInd;
        public int OdometerReading;   
        public Double[] TPReadings;
        public Double SMReading;
        public Double[] latlong;
        public int Olife;
        public int VehicleID;
        public DateTime genTmStamp;
    }
}
