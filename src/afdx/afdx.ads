---------------------
pragma Warnings(Off);
---------------------
with Ada.Text_IO;    use Ada.Text_IO;

with Interfaces;     use Interfaces;
with Ada.Real_Time;  use Ada.Real_Time;
with Ada.Streams;    use Ada.Streams;
with System;
---------------------
pragma Warnings(On);
---------------------

with Network.Defs.Eth;
with Network.Defs.IPv4;

package AFDX is

   Max_Number_Of_End_Systems     : constant := 5;
   Max_Number_Of_Virtual_Links   : constant := 10;
   Max_Number_Of_Ports           : constant := 255;

   ---------------------------------------------------------------------
   Base_Prio  : constant System.Priority := System.Default_Priority;
   ---------------------------------------------------------------------

   Inbound_Buffer_Ceil_Prio     : constant System.Priority := Base_Prio + 1;
   Outbound_Buffer_Ceil_Prio    : constant System.Priority := Base_Prio + 1;
   Outbound_Scheduler_Ceil_Prio : constant System.Priority := Base_Prio + 1;

   ---------------------------------------------------------------------

   Inbound_Executor_Prio        : constant System.Priority := Base_Prio + 0;
   Outbound_Executor_Prio       : constant System.Priority := Base_Prio + 0;

   ---------------------------------------------------------------------

private

   Switch_MAC : constant Network.Defs.Eth.Address  :=
     Network.Defs.Eth.Parse("AA:BB:CC:DD:EE:FF");

   Switch_IP  : constant Network.Defs.IPv4.Address :=
     Network.Defs.IPv4.Parse("192.168.1.1");

end AFDX;
