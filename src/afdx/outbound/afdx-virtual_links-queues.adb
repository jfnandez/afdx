with AFDX.Virtual_Links.Pool;

package body AFDX.Virtual_Links.Queues is

   ------------------- OBJETO PRINCIPAL -------------------

   protected body Object is

      procedure Initialize (ID : in Virtual_Links.ID_Range) is

      begin

         Virtual_Link := Virtual_Links.Pool.Retrieve(ID);

         -- Ethernet Header formation

         Headers.Eth.Set
           (Destination => Eth.Broadcast, --??
            Source      => End_Systems.Get_Me.MAC,
            EtherType   => Eth.VLAN);

         -- VLAN Header formation

         case Virtual_Link.Priority is

            when Prio_HIGH =>
               Headers.VLAN.Set
                 (Prio          => 7,
                  Iden          => 0,
                  Drop_Elegible => False,
                  Ethertype     => Eth.IPv4);

            when Prio_LOW  =>
               Headers.VLAN.Set
                 (Prio          => 6,
                  Iden          => 0,
                  Drop_Elegible => False,
                  Ethertype     => Eth.IPv4);
         end case;

         -- IP Header formation

         Headers.IP.Set
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
            Source_IP           => Virtual_Link.Source_IP,
            Destination_IP      => Virtual_Link.Destination_IP);


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
         Source_Port      : in     Ports.Port_Range;
         Destination_Port : in     Ports.Port_Range;
         Sub_Virtual_Link : in     Sub_Virtual_Link_Range;
         Identifier       : in     Unsigned_16;
         Frame_Payload    : in     Unsigned_16;
         Size_Required    : in     Unsigned_16;
         Inserted         :    out Boolean)
      is

         Buffer          : constant access Stream_Buffers.Stream_Buffer :=
           Buffers(Sub_Virtual_Link);

         Is_Storable     : constant Boolean :=
           Unsigned_16(Buffer.Writable_Elements) >= Size_Required;

         IP_Header_Size  : constant :=
           IPv4.Header_Size;

         Packet_Size     : constant Unsigned_16 :=
           Message'Length + UDP.Header_Size;

         Offset_Increase : constant Unsigned_16 :=
           Shift_Right(Frame_Payload, 3);

         Offset : Unsigned_16 := 0;
         Length : Unsigned_16;

         First  : Stream_Element_Count;
         Last   : Stream_Element_Count;

         Remain : Unsigned_16 := Packet_Size;

      begin

         Inserted := False;

         if Is_Storable then

            Headers.IP.Identification(Identifier);
            Headers.IP.Fragment_Offset(Offset);

            Headers.UDP.Set
              (Src_Port => Unsigned_16(Source_Port),
               Des_Port => Unsigned_16(Destination_Port),
               Length   => Packet_Size,
               Checksum => 0);


            -----------------
            -- First Frame --
            -----------------

            First := Message'First;

            if Remain > Frame_Payload then
               -- The message doesn't fit in just one frame
               Length := IP_Header_Size + Frame_Payload;
               Headers.IP.Total_Length(Length);
               Headers.IP.Set_MF_Flag;

               Last   := First + Stream_Element_Count(Frame_Payload - UDP.Header_Size) - 1;
               Remain := Remain - Frame_Payload;
            else
               -- The message does fit in just one frame
               Length := IP_Header_Size + Remain;
               Headers.IP.Total_Length(Length);
               Headers.IP.Reset_MF_Flag;

               Last   := Message'Last;
               Remain := 0;
            end if;

            Headers.IP.Set_Checksum;
            Unsigned_16'Write(Buffer, Length);
            Buffer.Write(Headers.IP.Get);
            Buffer.Write(Headers.UDP.Get);
            Buffer.Write(Message (First .. Last));

            ----------------------
            -- Remaining Frames --
            ----------------------

            while Remain > 0 loop
               -- Remaing characters of the message

               First := Last + 1;
               Offset := Offset + Offset_Increase;
               Headers.IP.Fragment_Offset(Offset);

               if Remain > Frame_Payload then
                  -- The message doesn't fit in a frame
                  -- No cambian

                  Last   := First + Stream_Element_Count(Frame_Payload) - 1;
                  Remain := Remain - Frame_Payload;
               else
                  -- The message does fit in just one frame

                  Length := IP_Header_Size + Remain;
                  Headers.IP.Total_Length(Length);
                  Headers.IP.Reset_MF_Flag;

                  Last   := Message'Last;
                  Remain := 0;
               end if;

               Headers.IP.Set_Checksum;
               Unsigned_16'Write(Buffer, Length);
               Buffer.Write(Headers.IP.Get);
               Buffer.Write(Message (First .. Last));

            end loop;

            Inserted := True;

         else

            Last := Message'Last;
            pragma Debug(Put_Line("Outbound package discarded due to overflow."));
            Put_Line("Outbound package discarded due to overflow." & Last'Img);
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

         Length    : Stream_Element_Offset;
         First     : Stream_Element_Offset;
         Last      : Stream_Element_Offset;
         Last_Read : Stream_Element_Offset;

      begin

         Sub_Virtual_Link_Round_Robin:
         for I in Sub_Virtual_Link_Range loop
            Buffer_Pointer := Buffer_Pointer + 1;
            Buffer := Buffers(Buffer_Pointer);
            exit when (Buffer /= null) and then (not Buffer.Is_Empty);
            Buffer := null;
         end loop Sub_Virtual_Link_Round_Robin;

         if (Buffer /= null) then

            Length := Stream_Element_Offset(Unsigned_16'Input(Buffer));

            First := 1;
            Last  := Eth.Header_Size;
            Frame.Data(First .. Last) := Headers.Eth.Get;

            First := Last + 1;
            Last  := Last + Eth.V_LAN.Header_Size;
            Frame.Data(First .. Last) := Headers.VLAN.Get;

            First := Last + 1;
            Last  := Last + Length;
            Frame.Length := Last;

            Buffer.Read(Frame.Data(First .. Last), Last_Read);

            if Last /= Last_Read then
               raise Program_Error with "Buffer underflow error.";
            end if;

         else
            raise Program_Error with "Not found any SVL ready.";
         end if;


      exception

         when others =>
            raise Program_Error with "Outbound Buffer error (Get procedure)";

      end Get;



   end Object;

end AFDX.Virtual_Links.Queues;
