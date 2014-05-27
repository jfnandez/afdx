package Network.Defs.IPv4.Pseudo_Headers is

   pragma Pure;

   Header_Size : constant := 12;

   type Header is tagged
      record
         Source      : Address;
         Destination : Address;
         Protocol    : Protocols;
         Length      : Unsigned_16;
      end record;

   subtype Header_Stream is Stream_Element_Array (0 .. Header_Size - 1);

   procedure To_Header (This : out Header; Stream : in Header_Stream);
   function  To_Stream (This : in Header) return Header_Stream;

end Network.Defs.IPv4.Pseudo_Headers;
