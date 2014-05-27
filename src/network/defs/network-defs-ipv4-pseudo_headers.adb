package body Network.Defs.IPv4.Pseudo_Headers is

   procedure To_Header (This : out Header; Stream : in Header_Stream) is
   begin

      This.Source      := Address(From_Net32(Stream(0 .. 3)));
      This.Destination := Address(From_Net32(Stream(4 .. 7)));
      This.Protocol    := Protocol_Conv(Unsigned_8(Stream(9)));
      This.Length      := From_Net16(Stream(10 .. 11));

   end To_Header;


   function  To_Stream (This : in Header) return Header_Stream is
      Stream : Header_Stream;
   begin

      Stream(0 .. 3) := To_Net32(Unsigned_32(This.Source));
      Stream(4 .. 7) := To_Net32(Unsigned_32(This.Destination));
      Stream(8) := 0;
      Stream(9) := Stream_Element(Protocol_Conv(This.Protocol));
      Stream(10 .. 11) := Network.To_Net16(This.Length);

      return Stream;

   end To_Stream;

end Network.Defs.IPv4.Pseudo_Headers;

