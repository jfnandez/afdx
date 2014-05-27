with AFDX.Virtual_Links.Queues.Scheduler;


package body AFDX.Virtual_Links.Queues.Out_Buffers is


   ---------
   -- Put --
   ---------

   procedure Put -- Raises AFDX.Overflow
     (This             : in out Object;
      Message          : in     Stream_Element_Array;
      Destination_Port : in     Network.Defs.UDP.Port;
      Source_Port      : in     Network.Defs.UDP.Port;
      Identifier       : in     Unsigned_16;
      Sub_Virtual_Link : in     Virtual_Links.Sub_Virtual_Link_Range;
      Fragmentable     : in     Boolean := False)
   is
      Total_Packets : Natural;
   begin

         -- The Message is stored in a buffer
         This.Queue.Put -- Raises AFDX.Overflow
           (Message          => Message,
            Source_Port      => Source_Port,
            Destination_Port => Destination_Port,
            Sub_Virtual_Link => Sub_Virtual_Link,
            Identifier       => Identifier,
            Fragmentable     => Fragmentable,
            Total_Packets    => Total_Packets);

         -- If the Message is stored, the scheduler is reported
         -- the number of frames stored.

         if Total_Packets > 0 then
            Queues.Scheduler.Report
              (Event  => Queued_Event(This),
               Amount => Total_Packets);
         end if;

   end Put;


end AFDX.Virtual_Links.Queues.Out_Buffers;
