using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using Microsoft.ServiceBus.Messaging;
using Newtonsoft.Json;

namespace EventHub
{
    class Program
    {
        public static void sendMessages (string connstring)

        {
                        //string eventhubname = "srrameh";
            var ehclient = EventHubClient.CreateFromConnectionString(connstring);
            Console.WriteLine("Connection is made to event hub to send the messages");
            

            while (true)
            {
                try
                {
                    //Sensor sensor = new Sensor();
                    Vehicle vehicle = new Vehicle();

                    for (int i = 1; i <= 100; i++)
                    {
                        vehicle.TelematicID = Guid.NewGuid().ToString();
                        Double addDec = new Random().NextDouble();                        
                        int randodometer = new Random().Next(25,140000);
                        int randolife = new Random().Next(5, 100);
                        int randsm = new Random().Next(0, 140);
                        int randpos = new Random().Next(0, 4);
                        int randneg = new Random().Next(-4,0);
                        vehicle.genTmStamp = DateTime.Now;
                        vehicle.OdometerReading = randodometer;
                        vehicle.Olife = randolife;
                        vehicle.SMReading = randsm + addDec;
                        vehicle.HiredInd = true;
                        if ((randolife%6 == 0) | (randsm%2 == 0))
                        {
                            vehicle.HiredInd = false;
                        }

                        vehicle.TPReadings = new Double[] { Math.Round((34 + randpos/2 + randneg/2 + addDec), 1), Math.Round((34 + randpos/2 + randneg/2 + addDec), 1), Math.Round((36 + randpos/2 + randneg/2 + addDec), 1), Math.Round((36 + randpos/2 + randneg/2 + addDec), 1) };

                        vehicle.latlong = new double[] { 99.9, 99.9 };

                        vehicle.VehicleID = i;
                        String message = JsonConvert.SerializeObject(vehicle);
                        Console.WriteLine(String.Format("Sending message : {0}", message));
                        var data = new EventData(Encoding.UTF8.GetBytes(message));
                        var group = ehclient.GetConsumerGroup("test");

                        ehclient.SendAsync(data);
                    }


                   
                }
                catch (Exception exception)
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine("Exception: {1}", DateTime.Now, exception.Message);
                    Console.ResetColor();
                }

               

                Thread.Sleep(60000);
            }

        }

        public static void RecieveMessages(string connstring)

        {
            //string eventhubname = "srrameh";
            var ehclient = EventHubClient.CreateFromConnectionString(connstring);
            Console.WriteLine("Connection is made to event hub to Recieve the messages");

            EventHubConsumerGroup group = ehclient.GetConsumerGroup("test");
            bool receive = true;
        

               // for (int i = 0; i <= 3; i++)
                //{
                    var receiver = group.CreateReceiver(ehclient.GetRuntimeInformation().PartitionIds[2]);


                    string myOffset;
                    while (receive)
                    {
                    Console.WriteLine("Reading Partition : {0} : ");
                    var message = receiver.Receive();
                    myOffset = message.Offset;
                    string body = Encoding.UTF8.GetString(message.GetBytes());
                // Console.WriteLine(String.Format("Received message offset: {0} \nbody: {1}", myOffset, body));
                //}

                using (System.IO.StreamWriter file =
    new System.IO.StreamWriter(@"C:\Users\srram\Desktop\MSFT\Demos\EHOUTPUT2.txt", true))
                {
                    file.WriteLine(myOffset);
                    file.WriteLine(body);
                }
            }
            

        }


        static void Main(string[] args)
        {

            string connstring = "Endpoint=sb://srrameventhub-ns.servicebus.windows.net/;SharedAccessKeyName=mysendpolicy;SharedAccessKey=t+9ic3EIvjc9OwfH6MoiqpoLjPuZ5q5tcj/cp+gQo6E=;EntityPath=myeventhub";
            
            sendMessages(connstring);
            //RecieveMessages(connstring);

        }
    }
}
