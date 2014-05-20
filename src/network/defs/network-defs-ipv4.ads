package Network.Defs.IPv4 is

   pragma Pure;

   Invalid : exception;

   type Protocols is (No_Def, UDP);

   Header_Size  : constant := 20;

   --Represents a IP address.
   type Address is private;
   function "=" (Left, Right : in Address) return Boolean;
   function "<" (Left, Right : in Address) return Boolean;
   function "<=" (Left, Right : in Address) return Boolean;
   function ">" (Left, Right : in Address) return Boolean;
   function ">=" (Left, Right : in Address) return Boolean;
   function Parse (Src : in String) return Address;
   function To_String(Addrs : in Address) return String;

   function Is_Multicast(This : in Address) return Boolean;

   Broadcast : constant Address;

   type Header is tagged private;
   subtype Header_Stream is Stream_Element_Array(1 .. Header_Size);

   procedure Set (This :out Header; Stream : in Header_Stream);
   procedure Set
     (This                :    out Header;
      Version             : in     Unsigned_8;
      Header_Length       : in     Unsigned_8;
      Total_Length        : in     Unsigned_16;
      Identification      : in     Unsigned_16;
      Dont_Fragment_Flag  : in     Boolean;
      More_Fragments_Flag : in     Boolean;
      Fragment_Offset     : in     Unsigned_16; -- Only 13 bits
      Time_To_Live        : in     Unsigned_8;
      Protocol            : in     Protocols;
      Header_Checksum     : in     Unsigned_16;
      Source_IP           : in     Address;
      Destination_IP      : in     Address);


   procedure Total_Length    (This : in out Header; Total_Length    : in Unsigned_16);
   procedure Identification  (This : in out Header; Identification  : in Unsigned_16);
   procedure Fragment_Offset (This : in out Header; Fragment_Offset : in Unsigned_16);

   procedure Set_DF_Flag   (This : in out Header);
   procedure Reset_DF_Flag (This : in out Header);
   procedure Set_MF_Flag   (This : in out Header);
   procedure Reset_MF_Flag (This : in out Header);

   procedure Set_Checksum (This : in out Header);


   procedure Get
     (This                : in     Header;
      Version             :    out Unsigned_8;
      Header_Length       :    out Unsigned_8;
      Total_Length        :    out Unsigned_16;
      Identification      :    out Unsigned_16;
      Dont_Fragment_Flag  :    out Boolean;
      More_Fragments_Flag :    out Boolean;
      Fragment_Offset     :    out Unsigned_16; -- Only 13 bits
      Time_To_Live        :    out Unsigned_8;
      Protocol            :    out Protocols;
      Header_Checksum     :    out Unsigned_16;
      Source_IP           :    out Address;
      Destination_IP      :    out Address);

   function Get                    (This : in Header) return Header_Stream;



private

   type Address is new Unsigned_32;

   Broadcast : constant Address := 16#FFFF_FFFF#;

   Min_Multicast : constant Address := 16#E000_0000#;
   Max_Multicast : constant Address := 16#EFFF_FFFF#;

   subtype Multicast_Address is Address range Min_Multicast .. Max_Multicast;

   type Header is tagged
      record
         Stream : Header_Stream;
      end record;

end Network.Defs.IPv4;
