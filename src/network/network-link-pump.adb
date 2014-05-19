with Network.Stack.Up.Eth;
with AFDX;
package body Network.Link.Pump is

   task Executor is
      pragma Priority(AFDX.Inbound_Executor_Prio);
      --entry Release;
   end Executor;

   task Body Executor is

      Frame : Defs.Frame;

   begin

      loop

         Network.Link.Read(Frame);
         Network.Stack.Up.Eth.Put(Frame.Data(1 .. Frame.Length));

      end loop;

   exception

      when others =>
         null;

   end Executor;

end Network.Link.Pump;
