with Network.Defs.IPv4;

package Network.Defs.UDP.Headers is

   pragma Pure;

   Header_Size : constant := 8;

   subtype Header_Stream is Stream_Element_Array(0 .. Header_Size - 1);


   type Header is tagged
      record
         Src_Port : Port;
         Des_Port : Port;
         Length   : Unsigned_16;
         Checksum : Unsigned_16;
      end record;

   procedure To_Header
     (This          : out Header;
      Stream        : in  Header_Stream);

   function  To_Stream
     (This          : in  Header;
      Source        : in  Defs.IPv4.Address;
      Destination   : in  Defs.IPv4.Address;
      Payload       : in  Stream_Element_Array) return Header_Stream;

end Network.Defs.UDP.Headers;
