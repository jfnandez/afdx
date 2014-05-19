pragma Warnings(Off);

with Ada.Streams;    use Ada.Streams;
with Ada.Assertions; use Ada.Assertions;
with Ada.Text_IO;    use Ada.Text_IO;
with Interfaces;     use Interfaces;
with Ada.Real_Time;  use Ada.Real_Time;
with Network.Link;
with System;

with Ada.Containers.Ordered_Maps;

pragma Warnings(On);


with Network.Defs.Eth;
with Network.Defs.IPv4;


use Network.Defs;

package AFDX is

   Overflow  : exception;
   Underflow : exception;

   Max_Number_Of_End_Systems     : constant := 5;
   Max_Number_Of_Virtual_Links   : constant := 10; -- < 2**(16 - 2)
   Max_Number_Of_Ports           : constant := 255;

   ---------------------------------------------------------------------
   Base_Prio  : constant System.Priority := System.Default_Priority;
   ---------------------------------------------------------------------

   Outbound_Buffer_Ceil_Prio    : constant System.Priority := Base_Prio + 0;
   Outbound_Scheduler_Ceil_Prio : constant System.Priority := Base_Prio + 1;
   Outbound_Executor_Prio       : constant System.Priority := Base_Prio + 1;

   ---------------------------------------------------------------------

   Inbound_Executor_Prio        : constant System.Priority := Base_Prio - 1;
   Inbound_Buffer_Ceil_Prio     : constant System.Priority := Base_Prio - 1;

   ---------------------------------------------------------------------

private

   --Device_MAC : constant Eth.Address  := Network.Link.Address;
   --Device_IP  :          IPv4.Address;

   Switch_MAC : constant Eth.Address  := Eth.Parse("AA:BB:CC:DD:EE:FF");
   Switch_IP  : constant IPv4.Address := IPv4.Parse("192.168.1.1");

end AFDX;
