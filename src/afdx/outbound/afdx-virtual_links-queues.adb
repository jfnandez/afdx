package body AFDX.Virtual_Links.Queues is

   ------------------- OBJETO PRINCIPAL -------------------

   protected body Object is

      procedure Initialize (VL_Acc : in Virtual_Links.Object_Acc) is
         Buffer_Size : Stream_Element_Count;
      begin

         Virtual_Link := VL_Acc;

         -- Ethernet Header formation

         Eth_Header.Set
           (Destination => Eth.Broadcast, --??
            Source      => End_Systems.Get_Me.MAC,
            EtherType   => Eth.VLAN);

         -- VLAN Header formation

         case Virtual_Link.Priority is

            when Prio_HIGH =>
               VLAN_Header.Set
                 (Prio          => 7,
                  Iden          => 0,
                  Drop_Elegible => False,
                  Ethertype     => Eth.IPv4);

            when Prio_LOW  =>
               VLAN_Header.Set
                 (Prio          => 6,
                  Iden          => 0,
                  Drop_Elegible => False,
                  Ethertype     => Eth.IPv4);
         end case;

         -- IP Header formation

         IP_Header.Set
           (Version             => 4,
            Header_Length       => 5,
            Total_Length        => 0,
            Identification      => 0,
            Dont_Fragment_Flag  => True,
            More_Fragments_Flag => False,
            Fragment_Offset     => 0,
            Time_To_Live        => 255,
            Protocol            => IPv4.UDP,
            Header_Checksum     => 0,
            Source_IP           => End_Systems.Get_Me.IP,
            Destination_IP      => Virtual_Link.IP);


         SVL_Pointer  := Sub_Virtual_Link_Range'Last;

         for SVL in Sub_Virtual_Link_Range loop
            Buffer_Size := Stream_Element_Count(Virtual_Link.Sub_Virtual_Link.TX_Size(SVL));
            if Buffer_Size > 0 then
               SVL_List(SVL) := new Stream_Buffers.Stream_Buffer(Buffer_Size);
            end if;
         end loop;

      end Initialize;


      procedure Put -- Raises AFDX.Overflow
        (Message          : in     Stream_Element_Array;
         Source_Port      : in     Ports.Port_Range;
         Destination_Port : in     Ports.Port_Range;
         Sub_Virtual_Link : in     Sub_Virtual_Link_Range;
         Identifier       : in     Unsigned_16;
         Frame_Payload    : in     Unsigned_16;
         Size_Required    : in     Unsigned_16;
         Inserted         :    out BOOLEAN)
      is

         Buffer      : constant access Stream_Buffers.Stream_Buffer :=
           SVL_List(Sub_Virtual_Link);

         Is_Storable : constant BOOLEAN :=
           Unsigned_16(Buffer.Writable_Elements) >= Size_Required;


         IP_Hdr_S : constant :=  IPv4.Header_Size;
         Packet_S : constant Unsigned_16 := Message'Length + UDP.Header_Size;
         Off_Incr : constant Unsigned_16 := Shift_Right(Frame_Payload, 3);

         Offset : Unsigned_16 := 0;
         Length    : Unsigned_16;

         First  : Stream_Element_Count;
         Last   : Stream_Element_Count;

         Remain : Unsigned_16 := Packet_S;

      begin

         Inserted := False;

         if Is_Storable then

            IP_Header.Identification(Identifier);
            IP_Header.Fragment_Offset(Offset);

            UDP_Header.Set
              (Src_Port => Unsigned_16(Source_Port),
               Des_Port => Unsigned_16(Destination_Port),
               Length   => Packet_S,
               Checksum => 0);


            -----------------
            -- First Frame --
            -----------------

            First := Message'First;

            if Remain > Frame_Payload then
               -- The message doesn't fit in just one frame
               Length := IP_Hdr_S + Frame_Payload;
               IP_Header.Total_Length(Length);
               IP_Header.Set_MF_Flag;

               Last   := First + Stream_Element_Count(Frame_Payload - UDP.Header_Size) - 1;
               Remain := Remain - Frame_Payload;
            else
               -- The message does fit in just one frame
               Length := IP_Hdr_S + Remain;
               IP_Header.Total_Length(Length);
               IP_Header.Reset_MF_Flag;

               Last   := Message'Last;
               Remain := 0;
            end if;

            IP_Header.Set_Checksum;
            Unsigned_16'Write(Buffer, Length);
            Buffer.Write(IP_Header.Get);
            Buffer.Write(UDP_Header.Get);
            Buffer.Write(Message (First .. Last));

            ----------------------
            -- Remaining Frames --
            ----------------------

            while Remain > 0 loop
               -- Remaing characters of the message

               First := Last + 1;
               Offset := Offset + Off_Incr;
               IP_Header.Fragment_Offset(Offset);

               if Remain > Frame_Payload then
                  -- The message doesn't fit in a frame
                  -- No cambian

                  Last   := First + Stream_Element_Count(Frame_Payload) - 1;
                  Remain := Remain - Frame_Payload;
               else
                  -- The message does fit in just one frame

                  Length := IP_Hdr_S + Remain;
                  IP_Header.Total_Length(Length);
                  IP_Header.Reset_MF_Flag;

                  Last   := Message'Last;
                  Remain := 0;
               end if;

               IP_Header.Set_Checksum;
               Unsigned_16'Write(Buffer, Length);
               Buffer.Write(IP_Header.Get);
               Buffer.Write(Message (First .. Last));

            end loop;

            Inserted := True;

         else

            --pragma Debug("Outbound package discarded due to overflow.");
            null;

         end if;

      exception

         when Stream_Buffers.BUFFER_OVERFLOW =>
            pragma Assert(False, "Not expected error DEBUG!.");
            raise AFDX.Overflow with "mal";

         when others =>
            pragma Assert(False, "Muerto");
            raise Program_Error;

      end Put;






      procedure Get (Frame  : out Network.Defs.Frame) is

         Buffer : access Stream_Buffers.Stream_Buffer;

         Length : Stream_Element_Offset;
         Last   : Stream_Element_Offset;
         First  : Stream_Element_Offset;

      begin

         for SVL in Sub_Virtual_Link_Range loop
            SVL_Pointer := SVL_Pointer + 1;
            Buffer := SVL_List(SVL_Pointer);
            exit when (Buffer /= null) and then (not Buffer.Is_Empty);
            Buffer := null;
         end loop;

         if (Buffer /= null) then

            Length := Stream_Element_Offset(Unsigned_16'Input(Buffer));

            First := 1;
            Last  := Eth.Header_Size;
            Frame.Data(First .. Last) := Eth_Header.Get;

            First := Last + 1;
            Last  := Last + Eth.V_LAN.Header_Size;
            Frame.Data(First .. Last) := VLAN_Header.Get;

            First := Last + 1;
            Last  := Last + Length;
            Frame.Length := Last;

            Buffer.Read(Frame.Data(First .. Last), Last);

         else
            raise Program_Error with "Not found any SVL ready.";
         end if;


      exception

         when Stream_Buffers.BUFFER_UNDERFLOW =>
            raise AFDX.Underflow with "Outbound Buffer underflow (Get procedure): Critical error. This should never have happened!";

         when others =>
            raise Program_Error with "Outbound Buffer error (Get procedure)";

      end Get;



   end Object;

end AFDX.Virtual_Links.Queues;
