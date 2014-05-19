with Interfaces; use Interfaces;

with AFDX.Table.End_Systems;

with Network.Eth;
with Net_Link;



package body AFDX.In_Buffers.Dispatcher.Executor is

   Task_Is_Released : Boolean := False;

   The_Frame   : Network.Eth.Frame;

   Eth_Header  : Network.Eth.Header;
   VLAN_Tag    : Network.Eth.VLAN_Tag;
   IP_Header   : Network.Eth.IPv4.Header;

   EtherType    : Unsigned_16;
   Is_VLAN      : Boolean;
   Frame_Offset : Stream_Element_Offset;


   Port_ID : Ports.ID_Range;



   task Executor_Task is
      --pragma Priority(AFDX.Inbound_Executor_Prio);
      entry Release;
   end Executor_Task;

   task body Executor_Task is
      use type Network.Eth.Address;
   begin

      accept Release  do
         Task_Is_Released := True;
         AFDX.Display("In_Buffer.Dispatcher.Executor Released");
      end Release;

      loop

         -- Tomo el Frame del driver;
         Net_Link.Read(The_Frame);

         -- Traduzco la cabezera Ethernet;
         Network.Eth.To_Header
           (The_Frame  => The_Frame,
            The_Header => Eth_Header,
            The_Tag    => VLAN_Tag,
            Is_VLAN    => Is_VLAN,
            EtherType  => EtherType,
            Offset     => Frame_Offset);

         -- Compruebo si soy destinatario del frame
         if (Eth_Header.Destination = End_Systems.This.MAC) or
           (Eth_Header.Destination = Network.Eth.Broadcast) then
            -- Frame unicast for me or broadcast

            if EtherType = Network.Eth.EtherType_IPv4 then
               -- Es de tipo IP

               Network.Eth.IPv4.To_Header
                 (The_Frame  => The_Frame,
                  Offset     => Frame_Offset,
                  The_Header => IP_Header);

               if Listening_To(IP_Header.Destination_IP) then

                  if (IP_Header.Protocol = Network.Eth.IPv4.UDP_Protocol)  then
                     -- Es de tipo UDP

                     Port_ID := Ports.ID_Range(IP_Header.Identification);

                     if AFDX.In_Buffers.Contains(Port_ID) then
                        -- Listening Port.

                        AFDX.In_Buffers.Retrieve(Port_ID).Put
                          (The_Frame => The_Frame,
                           Offset    => Frame_Offset,
                           IP_Header => IP_Header);

                     else
                        null;
                        -- Not Listening.
                     end if;

                  else
                     null;
                     -- It is not UDP protocol.
                     -- IGMP multicast request ...
                  end if;
               else
                  null;
                  -- IP Address not for me.
               end if;
            else
               null;
               -- Is not IP
            end if;

         else
            null;
            -- MAC Address not for me.
            null;
         end if;

      end loop;

   exception

      when others =>
         AFDX.Debug ("In_Buffer.Dispatcher.Executor is dead");
         raise Program_Error;

   end Executor_Task;

   procedure Release is
   begin
      if not Task_Is_Released then
         Executor_Task.Release;
      end if;
   end Release;


end AFDX.In_Buffers.Dispatcher.Executor;
