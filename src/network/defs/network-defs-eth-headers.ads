package Network.Defs.Eth.Headers is

   pragma Pure;

   Header_Size : constant := 14;

   type Header is tagged
      record
         Destination : Address;
         Source      : Address;
         EtherType   : EtherTypes;
      end record;

   subtype Header_Stream is Stream_Element_Array(0 .. Header_Size - 1);

   procedure To_Header (This : out Header; Stream : in Header_Stream);
   function  To_Stream (This : in Header) return Header_Stream;

end Network.Defs.Eth.Headers;
