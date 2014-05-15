with AFDX.Virtual_Links.Pool;
with AFDX.Definitions; -- Necesario!!!
with Data_Structures.Heaps;

package body AFDX.Virtual_Links.Queues.Scheduler is


   function "<" (Left, Right : in Queued_Event_Acc) return Boolean is
   begin
      return Left.At_Time < Right.At_Time;
   end "<";
   pragma Inline ("<");


   package Event_Structures is new
     Data_Structures(Element_Type => Queued_Event_Acc);

   package Event_Prio_Qs is new Event_Structures.Heaps
     (">" => "<",
      Top_Element => new Queued_Event'(At_Time   => Time_First,
                                       Period    => Milliseconds(0),
                                       Buffer    => null,
                                       Virt_Link => null,
                                       Remaining => 0));


   -- Only used throughout the Scheduller
   Event_Queue   : Event_Prio_Qs.Heap(Virtual_Links.Pool.Number_Out + 1);
   Reset_Enabled : Boolean := False;


   protected body Scheduler is

      ------------
      -- Report --
      ------------

      procedure Report(Event  : in out Queued_Event; Amount : in Positive) is
         Now : Time;
      begin

         if Event.Remaining > 0 then
            Event.Remaining := Event.Remaining + Amount;
         else
            Event.Remaining := Amount;
            Now := Clock;

            case Event.At_Time + Event.Period < Now is
               when True  => Event.At_Time := Now;
               when False => Event.At_Time := Event.At_Time + Event.Period;
            end case;

            if (Event_Queue.Is_Empty) or else
              (Event_Queue.Peek.At_Time < Event.At_Time) then
               Reset_Enabled := True;
            end if;

            Event_Queue.Put(Event'Unchecked_Access);

         end if;

      end Report;


      ---------
      -- Get --
      ---------

      procedure Get
        (Buffer    : out Virtual_Links.Queues.Object_Acc;
         At_Time   : out Time;
         Next_Time : out Time)
      is
         Event : Queued_Event_Acc;
      begin

         Event_Queue.Get(Event);

         Buffer  := Event.Buffer;
         At_Time := Event.At_Time;

         Event.Remaining := Event.Remaining - 1;

         if Event.Remaining > 0 then
            Event.At_Time := Event.At_Time + Event.Period;
            Event_Queue.Put(Event);
         end if;

         case Event_Queue.Is_Empty is
            when True  => Next_Time := Time_Last;
            when False => Next_Time := Event_Queue.Peek.At_Time;
         end case;

      end Get;


      -----------
      -- Reset --
      -----------

      entry Reset (Next_Time : out Time) when Reset_Enabled is
      begin
         Reset_Enabled := False;
         Next_Time     := Event_Queue.Peek.At_Time;
      end Reset;

   end Scheduler;


   procedure Report (Event : in out Queued_Event; Amount : in Positive) is
   begin
      Scheduler.Report (Event => Event, Amount => Amount);
   end Report;
   pragma Inline (Report);



begin

   if Virtual_Links.Pool.Number_Out > 0 then
      --pragma Debug("Scheduler creado para" & Virtual_Links.Pool.Number_Out'Img & " eventos.");
      null;
   end if;

end AFDX.Virtual_Links.Queues.Scheduler;
