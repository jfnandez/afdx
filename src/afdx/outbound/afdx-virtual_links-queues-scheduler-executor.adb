with Network.Link;

package body AFDX.Virtual_Links.Queues.Scheduler.Executor is

   Executor_Released : Boolean := False;

   task Executor is
      pragma Priority(AFDX.Outbound_Executor_Prio);
      entry Release;
   end Executor;


   task body Executor is
      Frame     : Network.Defs.Frame;
      Buffer    : Virtual_Links.Queues.Object_Acc;
      At_Time   : Time;
      Next_Time : Time := Time_Last;
   begin

      accept Release;


      Put_Line("Out_Buffer.Dispatcher.Executor Released");

      loop
         select
            Scheduler.Reset(Next_Time);
         or
            delay until Next_Time;
            Scheduler.Get(Buffer, At_Time, Next_Time);
            Buffer.Get(Frame.Data, Frame.Length);
            Network.Link.Write(Frame);
         end select;
      end loop;

   exception

      when others =>
         Put_Line("Outb Executor Died");
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
