package body AFDX.Virtual_Links.Queues.Scheduler.Executor is

   Executor_Released : BOOLEAN := False;

   task Executor is
      pragma Priority(AFDX.Outbound_Executor_Prio);
      entry Release;
   end Executor;


   task body Executor is
      My_Frame  : Network.Defs.Frame;
      Buffer    : Virtual_Links.Queues.Object_Acc;
      At_Time   : Time;
      Next_Time : Time := Time_Last;
   begin

      accept Release;

      --pragma Debug("Out_Buffer.Dispatcher.Executor Released");

      loop
         select
            Scheduler.Reset(Next_Time);
         or
            delay until Next_Time;
            Scheduler.Get(Buffer, At_Time, Next_Time);
            Buffer.Get(My_Frame);
            Network.Link.Write(My_Frame);
         end select;
      end loop;

   exception

      when others =>
         --pragma Debug("Out_Buffer.Dispatcher.Executor.Execute is dead.");
         raise Program_Error;

   end Executor;


   procedure Release is
   begin
      if not Executor_Released then
         Executor_Released := True;
         Executor.Release;
      end if;
   end Release;

end AFDX.Virtual_Links.Queues.Scheduler.Executor;
