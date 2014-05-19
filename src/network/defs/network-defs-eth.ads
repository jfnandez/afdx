package Network.Defs.Eth is

   pragma Pure;

   --Min_Frame_Length : constant := 60;
   --Max_Frame_Length : constant := MTU;

   Header_Size : constant := 14;

   type EtherTypes is (IPv4, VLAN);

   -- Represents a MAC address.
   type Address is private;
   function "="  (Left, Right : in Address) return Boolean;
   function "<"  (Left, Right : in Address) return Boolean;
   function "<=" (Left, Right : in Address) return Boolean;
   function ">"  (Left, Right : in Address) return Boolean;
   function ">=" (Left, Right : in Address) return Boolean;

   function Parse (Src : in String) return Address;
   function To_String(Addrs : in Address) return String;

   Broadcast : constant Address;

   type Header is tagged private;
   subtype Header_Stream is Stream_Element_Array(1 .. Header_Size);

   procedure Set
     (This        :    out Header;
      Stream      : in     Header_Stream);
   procedure Set
     (This        :    out Header;
      Destination : in     Address;
      Source      : in     Address;
      Ethertype   : in     EtherTypes);

   procedure Get
     (This        : in     Header;
      Destination :    out Address;
      Source      :    out Address;
      Ethertype   :    out EtherTypes);

   function Get (This : in Header) return Header_Stream;

private


   for EtherTypes'Size use 16;
   for EtherTypes use (IPv4=> 16#0800#, VLAN => 16#8100#);

   type Address is array (1 .. 6) of Unsigned_8;
   for Address'Size use 48;
   pragma Pack (Address);

   Broadcast : constant Address := (255,255,255,255,255,255);

   type Header is tagged
      record
         Stream : Header_Stream;
      end record;

   function Ether_Conv (EtherType : in EtherTypes)  return Unsigned_16;
   function Ether_Conv (EtherType : in Unsigned_16) return EtherTypes;

end Network.Defs.Eth;
