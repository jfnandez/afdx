package body Network.Defs.IPv4.Headers is

   DF_FLAG16 : constant := 2#01000000_00000000#;
   MF_FLAG16 : constant := 2#00100000_00000000#;
   FO_MASK   : constant := 2#00011111_11111111#;

   DF_FLAG8  : constant := 2#01000000#;
   MF_FLAG8  : constant := 2#00100000#;



   procedure To_Header (This : out Header; Stream : in Header_Stream) is
   begin
      This.Version         := Unsigned_4(Shift_Right(Unsigned_8(Stream(0)), 4));
      This.Header_Length   := Unsigned_4(Unsigned_8(Stream(0)) and 16#0F#);
      This.Services        := Unsigned_8(Stream(1));
      This.Total_Length    := From_Net16(Stream(2 .. 3));
      This.Identification  := From_Net16(Stream(4 .. 5));
      This.Dont_Fragment   := ((Unsigned_8(Stream(6) and DF_FLAG8)) = DF_FLAG8);
      This.More_Fragments  := ((Unsigned_8(Stream(6) and MF_FLAG8)) = MF_FLAG8);
      This.Fragment_Offset := Unsigned_13(From_Net16(Stream(6 .. 7)) and FO_MASK);
      This.Time_To_Live    := Unsigned_8(Stream(8));
      This.Protocol        := Protocol_Conv(Unsigned_8(Stream(9)));
      This.Checksum        := From_Net16(Stream(10 .. 11));
      This.Source          := Address(From_Net32(Stream(12 .. 15)));
      This.Destination     := Address(From_Net32(Stream(16 .. 19)));
   end To_Header;


   function  To_Stream (This : in Header) return Header_Stream is
      U8     : Unsigned_8;
      U16    : Unsigned_16;
      Stream : Header_Stream;
   begin

      U8 := Shift_Left(Unsigned_8(This.Version), 4) and 16#F0#;
      U8 := U8 xor (Unsigned_8(This.Header_Length)  and 16#0F#);

      Stream(0) := Stream_Element(U8);
      Stream(1) := Stream_Element(This.Services);

      Stream(2 .. 3) := To_Net16(This.Total_Length);
      Stream(4 .. 5) := To_Net16(This.Identification);

      U16 := Unsigned_16(This.Fragment_Offset) and FO_MASK;
      if This.Dont_Fragment then
         U16 := U16 xor DF_FLAG16;
      end if;
      if This.More_Fragments then
         U16 := U16 xor MF_FLAG16;
      end if;

      Stream(6 .. 7) := Network.To_Net16(U16);

      Stream(8)  := Stream_Element(This.Time_To_Live);
      Stream(9)  := Stream_Element(Protocol_Conv(This.Protocol));
      Stream(10) := 0;
      Stream(11) := 0;
      Stream(12 .. 15) := To_Net32(Unsigned_32(This.Source));
      Stream(16 .. 19) := To_Net32(Unsigned_32(This.Destination));

      Stream(10 .. 11) := U16_To_Stream(not Checksum(Stream , 0));

      return Stream;

   end To_Stream;

   function  To_Stream
     (This    : in  Header;
      Options : in  Stream_Element_Array) return Header_Stream
   is
      Stream : Header_Stream := This.To_Stream;
      Total  : Unsigned_16   := not From_Net16(Stream(10 ..11));
   begin

      Total := Checksum
        (Stream => Options,
         Carry => Total);

      Stream(10 .. 11) := U16_To_Stream(not Total);

      return Stream;

   end To_Stream;


end Network.Defs.IPv4.Headers;

