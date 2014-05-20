package Network.Defs.UDP is

   pragma Pure;

   Header_Size : constant := 8;

   type    Header is tagged private;
   subtype Header_Stream is Stream_Element_Array(1 .. Header_Size);


   procedure Set
     (This     :    out Header;
      Src_Port : in     Unsigned_16;
      Des_Port : in     Unsigned_16;
      Length   : in     Unsigned_16;
      Checksum : in     Unsigned_16);

   procedure Set (This : in out Header; Stream : in Header_Stream);
   procedure Set_Src_Port (This : in out Header; Src_Port : in Unsigned_16);
   procedure Set_Des_Port (This : in out Header; Des_Port : in Unsigned_16);
   procedure Set_Length   (This : in out Header; Length   : in Unsigned_16);
   procedure Set_Checksum (This : in out Header; Checksum : in Unsigned_16);


   procedure Get
     (This     : in     Header;
      Src_Port :    out Unsigned_16;
      Des_Port :    out Unsigned_16;
      Length   :    out Unsigned_16;
      Checksum :    out Unsigned_16);

   function Get (This : in Header) return Header_Stream;
   function Get_Src_Port (This : in Header) return Unsigned_16;
   function Get_Des_Port (This : in Header) return Unsigned_16;
   function Get_Length   (This : in Header) return Unsigned_16;
   function Get_Checksum (This : in Header) return Unsigned_16;

private

   type Header is tagged
      record
         Stream : Header_Stream;
      end record;

end Network.Defs.UDP;
