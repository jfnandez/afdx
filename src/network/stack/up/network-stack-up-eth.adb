with Network.Stack.Up.IPv4;
with Network.Defs.Eth;
with Network.Defs.Eth.Headers;
with Network.Defs.Eth.V_LAN;

with Network.Link;

package body Network.Stack.Up.Eth is

   Device_MAC : constant Defs.Eth.Address := Link.Address;

   procedure Push (Eth_Stream : in Stream_Element_Array) is

      First : Stream_Element_Offset;
      Last  : Stream_Element_Offset;

      Eth_Hdr  : Defs.Eth.Headers.Header;
      VLAN_Hdr : Defs.Eth.V_LAN.Header;

      use type Defs.Eth.Address;
      use type Defs.Eth.EtherTypes;

      Deliver : Stream_Procesing;

   begin

      First := Eth_Stream'First;
      Last  := First + Defs.Eth.Headers.Header_Size - 1;

      Eth_Hdr.To_Header(Stream => Eth_Stream(First .. Last));

      if (Eth_Hdr.Destination = Device_MAC) or (Eth_Hdr.Destination = Defs.Eth.Broadcast) then

         VLAN_Hdr.EtherType := Eth_Hdr.EtherType;

         while (VLAN_Hdr.EtherType = Defs.Eth.VLAN) loop

            First := Last + 1;
            Last  := First + Defs.Eth.V_LAN.Header_Size - 1;

            VLAN_Hdr.To_Header(Stream => Eth_Stream(First .. Last));

         end loop;

         First := Last + 1;
         Last  := Eth_Stream'Last;

         case VLAN_Hdr.EtherType is
            when Defs.Eth.IPv4 => Deliver := IPv4.Push'Access;
            when others        => Deliver := Sink'Access; -- Not Implemented.
         end case;

         Deliver(Eth_Stream(First .. Last));

      else
         null; -- Ignore. Not for me.
      end if;

   end Push;

end Network.Stack.Up.Eth;
