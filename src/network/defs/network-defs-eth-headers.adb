package body Network.Defs.Eth.Headers is

   procedure To_Header (This : out Header; Stream : in Header_Stream) is
   begin
      This.Destination := To_Address    (Stream( 0 ..  5));
      This.Source      := To_Address    (Stream( 6 .. 11));
      This.Ethertype   := Ether_Conv(From_Net16(Stream(12 .. 13)));
   end To_Header;

   function To_Stream (This : in Header) return Header_Stream is
      Stream : Header_Stream;
   begin
      Stream( 0 ..  5) := To_Stream  (This.Destination);
      Stream( 6 .. 11) := To_Stream  (This.Source     );
      Stream(12 .. 13) := To_Net16(Ether_Conv(This.EtherType ));
      return Stream;
   end To_Stream;

end Network.Defs.Eth.Headers;

