package Network.Defs.IPv4.Headers is

   pragma Pure;

   Header_Size  : constant := 20;

   type Header is tagged
      record
         Version         : Unsigned_4;
         Header_Length   : Unsigned_4;
         Services        : Unsigned_8;
         Total_Length    : Unsigned_16;
         Identification  : Unsigned_16;
         Dont_Fragment   : Boolean;
         More_Fragments  : Boolean;
         Fragment_Offset : Unsigned_13;
         Time_To_Live    : Unsigned_8;
         Protocol        : Protocols;
         Checksum        : Unsigned_16;
         Source          : Address;
         Destination     : Address;
      end record;

   subtype Header_Stream is Stream_Element_Array(0 .. Header_Size - 1);

   procedure To_Header
     (This    : out Header;
      Stream  : in  Header_Stream);

   function  To_Stream
     (This    : in  Header) return Header_Stream;

   function  To_Stream
     (This    : in  Header;
      Options : in  Stream_Element_Array) return Header_Stream;

end Network.Defs.IPv4.Headers;
