with Network.Defs;
with Network.Link;
with Network.Stack.Up.Eth;

package body AFDX.In_Buffers.Executor is

   task Executor is
      pragma Priority(AFDX.Inbound_Executor_Prio);
      entry Release;
   end Executor;

   task Body Executor is
      Frame : Network.Defs.Frame;
   begin

      accept Release;

      loop
         Network.Link.Read(Frame);
         Network.Stack.Up.Eth.Push(Frame.Data(1 .. Frame.Length));
      end loop;

   exception

      when others =>
         Put_Line("Network-Link-Pump Dead.");
         raise Program_Error;

   end Executor;

   procedure Release is
   begin
      Executor.Release;
   end Release;

begin

   Put_Line("Network-Link-Pump Ready");

end AFDX.In_Buffers.Executor;
