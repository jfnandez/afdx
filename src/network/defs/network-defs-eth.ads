package Network.Defs.Eth is

   pragma Pure;

   --Min_Frame_Length : constant := 60;
   --Max_Frame_Length : constant := MTU;

   type EtherTypes is (IPv4, VLAN);

   type Address is private;

   Broadcast : constant Address;

   function "="  (Left, Right : in Address) return Boolean;
   function "<"  (Left, Right : in Address) return Boolean;
   function "<=" (Left, Right : in Address) return Boolean;
   function ">"  (Left, Right : in Address) return Boolean;
   function ">=" (Left, Right : in Address) return Boolean;

   function Parse    (MAC : in String)  return Address;
   function To_String(MAC : in Address) return String;

   subtype Address_Stream is Stream_Element_Array(0 .. 5);

   function To_Stream (MAC : in Address) return Address_Stream;
   function To_Address(MAC : in Address_Stream) return Address;

private

   for EtherTypes'Size use 16;
   for EtherTypes use (IPv4=> 16#0800#, VLAN => 16#8100#);

   type Address is array (0 .. 5) of Unsigned_8;
   for Address'Size use 48;
   pragma Pack (Address);

   Broadcast : constant Address := (255,255,255,255,255,255);

   function Ether_Conv (EtherType : in EtherTypes)  return Unsigned_16;
   function Ether_Conv (EtherType : in Unsigned_16) return EtherTypes;

end Network.Defs.Eth;
