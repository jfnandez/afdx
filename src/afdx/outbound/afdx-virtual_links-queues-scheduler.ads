package AFDX.Virtual_Links.Queues.Scheduler is

   procedure Report
        (Event  : in out Queued_Event;
         Amount : in     Positive);

private

   protected Scheduler is

      pragma Priority (AFDX.Outbound_Scheduler_Ceil_Prio);

      procedure Report
        (Event     : in out Queued_Event;
         Amount    : in     Positive);

      procedure Get
        (Buffer    :    out Queues.Object_Acc;
         At_Time   :    out Time;
         Next_Time :    out Time);

      entry Reset (Next_Time : out Time);

   end Scheduler;

end AFDX.Virtual_Links.Queues.Scheduler;
