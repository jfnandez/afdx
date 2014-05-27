with AFDX.Virtual_Links.Pool;

with Network.Stack.Down.Eth;
with Network.Stack.Down.Eth.V_LAN;
with Network.Stack.Down.IPv4;
with Network.Stack.Down.UDP;


package body AFDX.Virtual_Links.Queues is

   ------------------- OBJETO PRINCIPAL -------------------

   protected body Object is

      procedure Initialize (ID : in Virtual_Links.ID_Range) is

      begin

         Virtual_Link := Virtual_Links.Pool.Retrieve(ID);

         -- Ethernet Header formation

         Headers.Eth.Destination := Network.Defs.Eth.Broadcast;
         Headers.Eth.Source      := Virtual_Link.Src.MAC;
         Headers.Eth.EtherType   := Network.Defs.Eth.VLAN;

         -- VLAN Header formation

         Headers.VLAN.Identifier    := 0;
         Headers.VLAN.Drop_Elegible := False;
         Headers.VLAN.EtherType     := Network.Defs.Eth.IPv4;

         case Virtual_Link.Priority is
            when Prio_HIGH => Headers.VLAN.Priority := 7;
            when Prio_LOW  => Headers.VLAN.Priority := 6;
         end case;

         -- IP Header formation

         Headers.IP.Version         := 4;
         Headers.IP.Header_Length   := 5;
         Headers.IP.Services        := 0;
         Headers.IP.Total_Length    := 0;
         Headers.IP.Identification  := 0;
         Headers.IP.Dont_Fragment   := True;
         Headers.IP.More_Fragments  := False;
         Headers.IP.Fragment_Offset := 0;
         Headers.IP.Time_To_Live    := 255;
         Headers.IP.Protocol        := Network.Defs.IPv4.UDP;
         Headers.IP.Checksum        := 0;
         Headers.IP.Source          := Virtual_Link.Source_IP;
         Headers.IP.Destination     := Virtual_Link.Destination_IP;

         Max_Packet_Size := Stream_Element_Count(Virtual_Link.Lmax) -
           (Network.Defs.Eth.Headers.Header_Size +
              Network.Defs.Eth.V_LAN.Header_Size);


         Buffer_Initialization:
         declare
            use Stream_Buffers;
            TX_Buffer_Size : Stream_Element_Count;
            TX_Size        : Sub_Virtual_Link_Size renames
              Virtual_Link.Sub_Virtual_Link.TX_Size;
         begin

            Buffer_Pointer  := Sub_Virtual_Link_Range'Last;

            for I in Sub_Virtual_Link_Range loop
               TX_Buffer_Size := Stream_Element_Count(TX_Size(I));
               if TX_Buffer_Size > 0 then
                  Buffers(I) := new Stream_Buffer(TX_Buffer_Size);
               end if;
            end loop;

         end Buffer_Initialization;

      end Initialize;


      procedure Put -- Raises AFDX.Overflow
        (Message          : in     Stream_Element_Array;
         Source_Port      : in     Network.Defs.UDP.Port;
         Destination_Port : in     Network.Defs.UDP.Port;
         Sub_Virtual_Link : in     Sub_Virtual_Link_Range;
         Identifier       : in     Unsigned_16;
         Fragmentable     : in     Boolean;
         Total_Packets    :    out Natural)
      is
         Result : Network.Stack.Down.IPv4.Error;
      begin

         Headers.IP.Identification  := Identifier;
         Headers.IP.Fragment_Offset := 0;
         Headers.IP.Dont_Fragment   := True;
         Headers.IP.More_Fragments  := False;

         Headers.UDP.Src_Port := Source_Port;
         Headers.UDP.Des_Port := Destination_Port;


         Network.Stack.Down.IPv4.Push
           (Header          => Headers.IP,
            Storage         => Buffers(Sub_Virtual_Link),
            Max_Packet_Size => Max_Packet_Size,
            Fragmentable    => Fragmentable,
            Message         => Network.Stack.Down.UDP.Push
              (Header          => Headers.UDP,
               Source          => Headers.IP.Source,
               Destination     => Headers.IP.Destination,
               Message         => Message),
            Total_Packets   => Total_Packets,
            Result          => Result);

      end Put;







      procedure Get -- Raises AFDX.Underflow
        (Datagram  : out Stream_Element_Array;
         Last      : out Stream_Element_Offset)
      is
         Buffer : access Stream_Buffers.Stream_Buffer;
      begin

         for I in Sub_Virtual_Link_Range loop
            Buffer_Pointer := Buffer_Pointer + 1;
            Buffer := Buffers(Buffer_Pointer);
            exit when (Buffer /= null) and then (not Buffer.Is_Empty);
            Buffer := null;
         end loop;

         pragma Assert (Buffer /= null);

         declare
            Eth_Frame : constant Stream_Element_Array :=
              Network.Stack.Down.Eth.Push
                (Header  => Headers.Eth,
                 Message => Network.Stack.Down.Eth.V_LAN.Push
                   (Header  => Headers.VLAN,
                    Message => Stream_Element_Array'Input(Buffer)));
         begin
            Last := Datagram'First + Eth_Frame'Length - 1;
            Datagram(Datagram'First .. Last) := Eth_Frame;
         exception
            when others =>
               Put_Line("Aqui1");
         end;

exception
         when others =>
            Put_Line("Aqui2");
            raise Program_Error with "Outbound Buffer error (Get procedure)";

      end Get;



   end Object;

end AFDX.Virtual_Links.Queues;
