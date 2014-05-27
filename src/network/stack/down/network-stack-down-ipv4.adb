package body Network.Stack.Down.IPv4 is

   package IPv4H renames Network.Defs.IPv4.Headers;

   function Ceil (Left, Right : in Positive) return Natural is
   begin
      return 1 + ((Left - 1) / Right); -- Left /= 0
      --return (Left + Right - 1) / Right; --Posible Overflow;
   end Ceil;
   pragma Inline (Ceil);


   procedure Push
     (Header          : in     Defs.IPv4.Headers.Header;
      Storage         : access Stream_Buffers.Stream_Buffer;
      Max_Packet_Size : in     Stream_Element_Count;
      Fragmentable    : in     Boolean;
      Message         : in     Stream_Element_Array;
      Total_Packets   :    out Natural;
      Result          :    out Error)
   is
      Max_Payload_Size : Stream_Element_Count;
      Size_Required    : Stream_Element_Count;
      Offset_Increase  : Unsigned_13;
      Header_Copy      : IPv4H.Header := Header;

      Sto_First  : Stream_Element_Offset;
      Sto_Last   : Stream_Element_Offset;
      Msg_First  : Stream_Element_Offset;
      Msg_Last   : Stream_Element_Offset;
      Msg_Remain : Stream_Element_Count;

      Stream : Stream_Element_Array(0 .. Max_Packet_Size - 1); -- De sobra.
   begin

      Offset_Increase  := Unsigned_13((Max_Packet_Size - IPv4H.Header_Size) / 8);
      Max_Payload_Size := 8 * Stream_Element_Count(Offset_Increase);
      Total_Packets    := Ceil(Natural(Message'Length), Positive(Max_Payload_Size));
      Size_Required    := Stream_Element_Count(Total_Packets) * (IPv4H.Header_Size + 8) + Message'Length;


      Result := Unknown;

      if (Total_Packets > 2 ) and (not Fragmentable) then --Fragmentation compulsory.
         Total_Packets := 0;
         Result := Fragmentation;
         return;
      elsif Storage.Writable_Elements < Size_Required then -- Not enough buffer size.
         Result := Size;
         Total_Packets := 0;
         return;
      end if;

      Msg_Remain := Message'Length;

      -- First Packet;

      Header_Copy.Fragment_Offset := 0;
      Header_Copy.Dont_Fragment   := True;
      Header_Copy.More_Fragments  := False;

      Msg_First  := Message'First;

      if Msg_Remain > Max_Payload_Size then -- The message doesn't fit in just one frame;
         Header_Copy.Total_Length   := IPv4H.Header_Size + Unsigned_16(Max_Payload_Size);
         Header_Copy.More_Fragments := True;
         Msg_Remain := Msg_Remain - Max_Payload_Size;
         Msg_Last   := Msg_First + Max_Payload_Size - 1;
      else
         Header_Copy.Total_Length   := IPv4H.Header_Size + Unsigned_16(Msg_Remain);
         Msg_Remain := 0;
         Msg_Last   := Message'Last;
      end if;

      Sto_First := 0;
      Sto_Last  := IPv4H.Header_Size - 1;
      Stream(Sto_First .. Sto_Last) := Header_Copy.To_Stream;

      Sto_First := Sto_Last + 1;
      Sto_Last  := Stream_Element_Offset(Header_Copy.Total_Length) - 1;
      Stream(Sto_First .. Sto_Last) := Message(Msg_First .. Msg_Last);

      Stream_Element_Array'Output(Storage, Stream(0 .. Sto_Last));

      -- Rem_Packets;


      while Msg_Remain > 0 loop
         -- Remaing characters of the message

         Msg_First := Msg_Last + 1;
         Header_Copy.Fragment_Offset := Header_Copy.Fragment_Offset + Offset_Increase;

         if Msg_Remain > Max_Payload_Size then -- The message doesn't fit in a frame
            Msg_Remain := Msg_Remain - Max_Payload_Size;
            Msg_Last   := Msg_First + Max_Payload_Size - 1;
         else -- The message does fit in just one frame
            Header_Copy.Total_Length   := IPv4H.Header_Size + Unsigned_16(Msg_Remain);
            Header_Copy.More_Fragments := False;
            Msg_Remain := 0;
            Msg_Last   := Message'Last;
         end if;

         Sto_First := 0;
         Sto_Last  := IPv4H.Header_Size - 1;
         Stream(Sto_First .. Sto_Last) := Header_Copy.To_Stream;

         Sto_First := Sto_Last + 1;
         Sto_Last  := Stream_Element_Offset(Header_Copy.Total_Length) - 1;
         Stream(Sto_First .. Sto_Last) := Message(Msg_First .. Msg_Last);

         Stream_Element_Array'Output(Storage, Stream(0 .. Sto_Last));

      end loop;

       Result := Success;

   end Push;

end Network.Stack.Down.IPv4;
