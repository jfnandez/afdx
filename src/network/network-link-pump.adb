with Ada.Text_IO;
use Ada.Text_IO;

with Network.Stack.Up.Eth;
with AFDX;

package body Network.Link.Pump is

   task Executor is
      pragma Priority(AFDX.Inbound_Executor_Prio);
      entry Release;
   end Executor;

   task Body Executor is
      Frame : Defs.Frame;
   begin

      accept Release;

      loop
         Network.Link.Read(Frame);
         Network.Stack.Up.Eth.Put(Frame.Data(1 .. Frame.Length));
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

end Network.Link.Pump;
