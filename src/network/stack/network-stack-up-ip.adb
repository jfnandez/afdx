with Network.Stack.Up.IP_Buffers;
with Network.Stack.Up.IP_Storage;
with Network.Stack.Up.UDP;
with Network.Defs.IPv4;

package body Network.Stack.Up.IP is

   procedure Put(IP_Stream : Stream_Element_Array)
   is

      IP_Hdr         : IPv4.Header;
      Version        : Unsigned_8;
      Header_Length  : Unsigned_8;
      Total_Length   : Unsigned_16;
      Identification : Unsigned_16;
      DF_Flag        : Boolean;
      MF_Flag        : Boolean;
      Offset         : Unsigned_16;
      TTL            : Unsigned_8;
      Protocol       : IPv4.Protocols;
      Hdr_Checksum   : Unsigned_16;
      Source_IP      : IPv4.Address;
      Destination_IP : IPv4.Address;

      Deliver  : Stream_Procesing;
      First    : Stream_Element_Offset;
      Last     : Stream_Element_Offset;
      Buffer   : IP_Buffers.Object_Acc;
      Ready    : BOOLEAN;

   begin

      First := IP_Stream'First;
      Last  := First + IPv4.Header_Size - 1;

      IP_Hdr.Set(IP_Stream(First .. Last));

      IP_Hdr.Get
        (Version             => Version,
         Header_Length       => Header_Length,
         Total_Length        => Total_Length,
         Identification      => Identification,
         Dont_Fragment_Flag  => DF_Flag,
         More_Fragments_Flag => MF_Flag,
         Fragment_Offset     => Offset,
         Time_To_Live        => TTL,
         Protocol            => Protocol,
         Header_Checksum     => Hdr_Checksum,
         Source_IP           => Source_IP,
         Destination_IP      => Destination_IP);

      -- From 4 byte blocks to bytes
      Header_Length := Shift_Left(Header_Length, 2);

      Last  := First + Stream_Element_Count(Total_Length) - 1;
      First := First + Stream_Element_Count(Header_Length);

      case Protocol is
         when IPv4.UDP => Deliver := UDP.Put'Access;
         when others   => Deliver := Sink'Access;
      end case;

      if (Offset = 0) and (not MF_Flag) then

         if IP_Storage.Acceptable_IP (Destination_IP) then
            Deliver(IP_Stream(First .. Last));
         end if;

      else

         Buffer := IP_Storage.Find
           (IP => Destination_IP,
            ID => Identification);

         if IP_Buffers."/="(Buffer, null) then

            -- From 8 byte blocks to bytes
            Offset := Shift_Left(Offset, 3);

            Buffer.Put
              (Stream   => IP_Stream(First .. Last),
               MF_Flag  => MF_Flag,
               Offset   => Stream_Element_Count(Offset),
               Is_Ready => Ready);

            if Ready then
               Deliver(Buffer.Get);
            end if;

         else

            --pragma Debug
            --  ("IP Source: " & Defs.IPv4.To_String(Source_IP) &
            --     " Dest : "  & Defs.IPv4.To_String(Destination_IP) &
            --     " rejected");

            null;

         end if;

      end if;

   end Put;


end Network.Stack.Up.IP;