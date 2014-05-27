package Network.Defs.IPv4 is

   pragma Pure;

   type Protocols is (No_Def, UDP);

   type Address is private;

   function "="  (Left, Right : in Address) return Boolean;
   function "<"  (Left, Right : in Address) return Boolean;
   function "<=" (Left, Right : in Address) return Boolean;
   function ">"  (Left, Right : in Address) return Boolean;
   function ">=" (Left, Right : in Address) return Boolean;

   function Parse     (IP : in String)  return Address;
   function To_String (IP : in Address) return String;

   subtype Address_Stream is Stream_Element_Array(0 .. 3);
   function To_Stream (IP : in Address) return Address_Stream;
   function To_Address(IP : in Address_Stream) return Address;

   function Is_Multicast(IP : in Address) return Boolean;

   Broadcast : constant Address;


private

   type Address is new Unsigned_32;

   Broadcast     : constant Address := 16#FFFF_FFFF#;
   Min_Multicast : constant Address := 16#E000_0000#;
   Max_Multicast : constant Address := 16#EFFF_FFFF#;

   subtype Multicast_Address is Address range Min_Multicast .. Max_Multicast;

   function Protocol_Conv (Protocol : in Protocols) return Unsigned_8;
   function Protocol_Conv (Protocol : in Unsigned_8) return Protocols;

end Network.Defs.IPv4;
