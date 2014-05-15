with Ada.Streams; use Ada.Streams;
with Ada.Text_IO; use Ada.Text_IO;

with AFDX.Virtual_Links.Queues.Events.Pool;
with AFDX.Virtual_Links.Queues.Scheduler.Executor;


with Network.Link.Pump;

procedure Main is

   S1 : constant Stream_Element_Array(1 .. 501) := (others => 1);

   E1 : AFDX.Virtual_Links.Queues.Events.Object_Acc;

begin

   AFDX.Virtual_Links.Queues.Scheduler.Executor.Release;

   E1 := AFDX.Virtual_Links.Queues.Events.Pool.Retrieve(1);

   for I in S1'Range loop

      E1.Put(Message             => S1(1 .. I),
             Destination_Port => 11,
             Source_Port      => 11,
             Sub_Virtual_Link => 1,
             Single_Frame => False);

      E1.Put(Message             => S1(1 .. 40),
             Destination_Port => 11,
             Source_Port      => 11,
             Sub_Virtual_Link => 3,
             Single_Frame => False);

      delay 0.5;

   end loop;



exception
      when others =>
Put_Line("Muerto");
end Main;
