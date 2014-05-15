package body Network.Defs.UDP is

   -- Setters --

   procedure Set
     (This     :    out Header;
      Src_Port : in     Unsigned_16;
      Des_Port : in     Unsigned_16;
      Length   : in     Unsigned_16;
      Checksum : in     Unsigned_16)
   is
   begin
      This.Stream (1 .. 2) := To_Net16(Src_Port);
      This.Stream (3 .. 4) := To_Net16(Des_Port);
      This.Stream (5 .. 6) := To_Net16(Length);
      This.Stream (7 .. 8) := To_Net16(Checksum);
   end Set;

   procedure Set (This : in out Header; Stream : in Header_Stream) is
   begin
      This.Stream := Stream;
   end Set;

   procedure Set_Src_Port (This : in out Header; Src_Port : in Unsigned_16) is
   begin
      This.Stream (1 .. 2) := To_Net16(Src_Port);
   end Set_Src_Port;

   procedure Set_Des_Port (This : in out Header; Des_Port : in Unsigned_16) is
   begin
      This.Stream (3 .. 4) := To_Net16(Des_Port);
   end Set_Des_Port;

   procedure Set_Length (This : in out Header; Length : in Unsigned_16) is
   begin
      This.Stream (5 .. 6) := To_Net16(Length);
   end Set_Length;

   procedure Set_Checksum (This : in out Header; Checksum : in Unsigned_16) is
   begin
      This.Stream (7 .. 8) := To_Net16(Checksum);
   end Set_Checksum;


   -- Getters --

   procedure Get
     (This     : in     Header;
      Src_Port :    out Unsigned_16;
      Des_Port :    out Unsigned_16;
      Length   :    out Unsigned_16;
      Checksum :    out Unsigned_16) is
   begin
      Src_Port := From_Net16(This.Stream(1 .. 2));
      Des_Port := From_Net16(This.Stream(3 .. 4));
      Length   := From_Net16(This.Stream(5 .. 6));
      Checksum := From_Net16(This.Stream(7 .. 8));
   end Get;


   function Get (This : in Header) return Header_Stream is
   begin
      return This.Stream;
   end Get;

   function Get_Src_Port (This : in Header) return Unsigned_16 is
   begin
      return From_Net16(This.Stream(1 .. 2));
   end Get_Src_Port;
   pragma Inline (Get_Src_Port);

   function Get_Des_Port (This : in Header) return Unsigned_16 is
   begin
      return From_Net16(This.Stream(3 .. 4));
   end Get_Des_Port;
   pragma Inline (Get_Des_Port);

   function Get_Length (This : in Header) return Unsigned_16 is
   begin
      return From_Net16(This.Stream(5 .. 6));
   end Get_Length;
   pragma Inline (Get_Length);

   function Get_Checksum (This : in Header) return Unsigned_16 is
   begin
      return From_Net16(This.Stream(7 .. 8));
   end Get_Checksum;
   pragma Inline (Get_Checksum);


end Network.Defs.UDP;

