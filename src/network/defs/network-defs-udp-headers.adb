with Network.Defs.IPv4.Pseudo_Headers;

package body Network.Defs.UDP.Headers is

   procedure To_Header (This : out Header; Stream : in Header_Stream) is
   begin
      This.Src_Port := From_Net16(Stream(0 .. 1));
      This.Des_Port := From_Net16(Stream(2 .. 3));
      This.Length   := From_Net16(Stream(4 .. 5));
      This.Checksum := From_Net16(Stream(6 .. 7));
   end To_Header;


   function To_Stream
     (This          : in  Header;
      Source        : in  Defs.IPv4.Address;
      Destination   : in  Defs.IPv4.Address;
      Payload       : in  Stream_Element_Array) return Header_Stream
   is

      Real_Length   : constant Unsigned_16 :=
        Payload'Length + Header_Size;

      Pseudo_Header : Defs.IPv4.Pseudo_Headers.Header;
      Total         : Unsigned_16;
      Stream        : Header_Stream;
   begin

      Total := Checksum(Payload, 0);

      Pseudo_Header.Source      := Source;
      Pseudo_Header.Destination := Destination;
      Pseudo_Header.Protocol    := IPv4.UDP;
      Pseudo_Header.Length      := Real_Length;

      Total := Checksum
        (Stream => IPv4.Pseudo_Headers.To_Stream(Pseudo_Header),
         Carry  => Total);

      Stream (0 .. 1) := To_Net16(This.Src_Port);
      Stream (2 .. 3) := To_Net16(This.Des_Port);
      Stream (4 .. 5) := To_Net16(Real_Length);
      Stream (6 .. 7) := (0, 0);

      Total := Checksum
        (Stream => Stream,
         Carry  => Total);

      Stream(6 ..  7) := U16_To_Stream(not Total);

      return Stream;

   end To_Stream;








end Network.Defs.UDP.Headers;

