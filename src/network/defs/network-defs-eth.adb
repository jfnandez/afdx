with Ada.Unchecked_Conversion;

package body Network.Defs.Eth is

   function Parse (Src : in String) return Address
   is
      MAC    :          Address;
      Offset : constant Integer := Src'First;
   begin

      for I in 0..4 loop
         MAC(I+1) := Shift_Left(Parse_B16(Src(3*I + 0 + Offset)), 4);
         MAC(I+1) := MAC(I+1) + Parse_B16(Src(3*I + 1 + Offset));
         if Src(3*I + 2 + Offset) /= ':' then
            raise Parsing_Error;
         end if;
      end loop;

      MAC(6) := Shift_Left(Parse_B16(Src(15 + Offset)), 4);
      MAC(6) := MAC(6) + Parse_B16(Src(16 + Offset));

      return MAC;

   exception

      when Parsing_Error =>
         raise Program_Error with "Invalid MAC: " & Src;

   end Parse;

   pragma Warnings(OFF);

   function "=" (Left, Right : in Address) return Boolean is
      Flag : Boolean;
   begin

      Flag :=          (Left(1) = Right(1));
      Flag := Flag and (Left(2) = Right(2));
      Flag := Flag and (Left(3) = Right(3));
      Flag := Flag and (Left(4) = Right(4));
      Flag := Flag and (Left(5) = Right(5));
      Flag := Flag and (Left(6) = Right(6));

      return Flag;

   end "=";

   function "<" (Left, Right : in Address) return Boolean is
   begin
      for I in Address'Range loop
         if Left(I) < Right(I) then
            return True;
         elsif  Left(I) > Right(I) then
            return False;
         end if;
      end loop;
      return False;
   end "<";

   function "<=" (Left, Right : in Address) return Boolean is
   begin
      for I in Address'Range loop
         if Left(I) < Right(I) then
            return True;
         elsif  Left(I) > Right(I) then
            return False;
         end if;
      end loop;
      return True;
   end "<=";

   function ">" (Left, Right : in Address) return Boolean is
   begin
      for I in Address'Range loop
         if Left(I) > Right(I) then
            return True;
         elsif  Left(I) < Right(I) then
            return False;
         end if;
      end loop;
      return False;
   end ">";

   function ">=" (Left, Right : in Address) return Boolean is
   begin
      for I in Address'Range loop
         if Left(I) > Right(I) then
            return True;
         elsif  Left(I) < Right(I) then
            return False;
         end if;
      end loop;
      return True;
   end ">=";

   pragma Warnings(ON);


   function To_String (Addrs : in Address) return String is
      Result : STRING(1 .. 17) := "00:00:00:00:00:00";
   begin
      Result( 1.. 2) := To_Hex(Addrs(1));
      Result( 4.. 5) := To_Hex(Addrs(2));
      Result( 7.. 8) := To_Hex(Addrs(3));
      Result(10..11) := To_Hex(Addrs(4));
      Result(13..14) := To_Hex(Addrs(5));
      Result(16..17) := To_Hex(Addrs(6));
      return Result;
   end To_String;



   ----------------------
   subtype Stream_Address is Stream_Element_Array(1..6);

   function Address_To_Stream is new Ada.Unchecked_Conversion
     (Source => Address,
      Target => Stream_Address);

   function Stream_To_Address is new Ada.Unchecked_Conversion
     (Source => Stream_Address,
      Target => Address);


   EtherType_VLAN : constant Unsigned_16 := 16#8100#;
   EtherType_IPv4 : constant Unsigned_16 := 16#0800#;

   function Ether_Conv (EtherType : in EtherTypes) return Unsigned_16 is
   begin
      case EtherType is
         when IPv4   => return EtherType_IPv4;
         when VLAN   => return EtherType_VLAN;
      end case;
     end Ether_Conv;

   function Ether_Conv (EtherType : in Unsigned_16) return EtherTypes is
   begin
      case EtherType is
         when EtherType_IPv4 => return IPv4;
         when EtherType_VLAN => return VLAN;
         when others         =>
            raise Program_Error
              with "EtherType " & EtherType'Img & " not valid.";
      end case;
     end Ether_Conv;


   procedure Set
     (This        :    out Header;
      Destination : in     Address;
      Source      : in     Address;
      EtherType   : in     EtherTypes)
   is
   begin
      This.Stream( 1 ..  6) := Address_To_Stream(Destination);
      This.Stream( 7 .. 12) := Address_To_Stream(Source);
      This.Stream(13 .. 14) := To_Net16(Ether_Conv(EtherType));
   end Set;


   procedure Set (This : out Header; Stream : in Header_Stream) is
   begin
      This.Stream := Stream;
   end Set;




   procedure Get
     (This        : in     Header;
      Destination :    out Address;
      Source      :    out Address;
      Ethertype   :    out EtherTypes)
   is
   begin
      Destination := Stream_To_Address(This.Stream(1 ..  6));
      Source      := Stream_To_Address(This.Stream(7 .. 12));
      Ethertype   := Ether_Conv(From_Net16(This.Stream(13..14)));
   end Get;


   function Get (This : in Header) return Header_Stream is
   begin
      return This.Stream;
   end Get;


end Network.Defs.Eth;

