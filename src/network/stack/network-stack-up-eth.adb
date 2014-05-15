with Network.Stack.Up.IP;
with Network.Defs.Eth;
with Network.Defs.Eth.V_LAN;

with Network.Link;

package body Network.Stack.Up.Eth is

   Device_MAC : constant Defs.Eth.Address := Network.Link.Address;

   procedure Put (Eth_Stream : in Stream_Element_Array) is

      First : Stream_Element_Offset;
      Last  : Stream_Element_Offset;

      Ethe_Hdr  : Defs.Eth.Header;
      Src_Add   : Defs.Eth.Address;
      Dest_Add  : Defs.Eth.Address;
      Eth_Type  : Defs.Eth.EtherTypes;

      VLAN_Hdr      : Defs.Eth.V_LAN.Header;
      Prio          : Defs.Eth.V_LAN.Priority;
      Iden          : Defs.Eth.V_LAN.Identifier;
      Drop_Elegible : BOOLEAN;

      use type Defs.Eth.Address;
      use type Defs.Eth.EtherTypes;

      Deliver : Stream_Procesing;

   begin

      First := Eth_Stream'First;
      Last  := First + Defs.Eth.Header_Size - 1;

      Ethe_Hdr.Set(Eth_Stream(First .. Last));

      Ethe_Hdr.Get
        (Destination => Dest_Add,
         Source      => Src_Add,
         Ethertype   => Eth_Type);


      if (Dest_Add = Device_MAC) or (Dest_Add = Defs.Eth.Broadcast) then

         while (Eth_Type = Defs.Eth.VLAN) loop

            First := Last + 1;
            Last  := First + Defs.Eth.V_LAN.Header_Size - 1;

            VLAN_Hdr.Set(Eth_Stream(First .. Last));

            VLAN_Hdr.Get
              (Prio          => Prio,
               Iden          => Iden,
               Drop_Elegible => Drop_Elegible,
               Ethertype     => Eth_Type);

         end loop;

         First := Last + 1;
         Last  := Eth_Stream'Last;

         case Eth_Type is
            when Defs.Eth.IPv4 => Deliver := IP.Put'Access;
            when others        => Deliver := Sink'Access; -- Not Implemented.
         end case;

         Deliver(Eth_Stream(First .. Last));

      else
         null; -- Ignore. Not for me.
      end if;

   end Put;

end Network.Stack.Up.Eth;
