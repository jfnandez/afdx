with Ada.Unchecked_Conversion;

package body Network.Defs.Eth is

   function Parse (MAC : in String) return Address
   is
      R_MAC  :          Address;
      Offset : constant Integer := MAC'First;
   begin

      for I in 0..4 loop
         R_MAC(I) := Shift_Left(Parse_B16(MAC(3*I + 0 + Offset)), 4);
         R_MAC(I) := R_MAC(I) + Parse_B16(MAC(3*I + 1 + Offset));
         if MAC(3*I + 2 + Offset) /= ':' then
            raise Program_Error with
              "Invalid MAC format.";
         end if;
      end loop;

      R_MAC(5) := Shift_Left(Parse_B16(MAC(15 + Offset)), 4);
      R_MAC(5) := R_MAC(5) + Parse_B16(MAC(16 + Offset));

      return R_MAC;

   end Parse;

   pragma Warnings(OFF);


   function "=" (Left, Right : in Address) return Boolean is
      Flag : Boolean := True;
   begin

      Flag := Flag and (Left(0) = Right(0));
      Flag := Flag and (Left(1) = Right(1));
      Flag := Flag and (Left(2) = Right(2));
      Flag := Flag and (Left(3) = Right(3));
      Flag := Flag and (Left(4) = Right(4));
      Flag := Flag and (Left(5) = Right(5));

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


   function To_String (MAC : in Address) return String is
      Result : String (1 .. 17) := "00:00:00:00:00:00";
   begin
      Result( 1.. 2) := To_Hex(MAC(0));
      Result( 4.. 5) := To_Hex(MAC(1));
      Result( 7.. 8) := To_Hex(MAC(2));
      Result(10..11) := To_Hex(MAC(3));
      Result(13..14) := To_Hex(MAC(4));
      Result(16..17) := To_Hex(MAC(5));
      return Result;
   end To_String;


   function Address_To_Stream is new
     Ada.Unchecked_Conversion
     (Source => Address,
      Target => Address_Stream);

   function Stream_To_Address is new
     Ada.Unchecked_Conversion
     (Source => Address_Stream,
      Target => Address);

   function To_Stream (MAC  : in Address) return Address_Stream is
   begin
      return Address_To_Stream(MAC);
   end To_Stream;


   function To_Address (MAC : in Address_Stream) return Address is
   begin
      return Stream_To_Address(MAC);
   end To_Address;



   EtherType_VLAN : constant Unsigned_16 := 16#8100#;
   EtherType_IPv4 : constant Unsigned_16 := 16#0800#;

   function Ether_Conv (EtherType : in EtherTypes) return Unsigned_16 is
   begin
      case EtherType is
         when IPv4 => return EtherType_IPv4;
         when VLAN => return EtherType_VLAN;
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

end Network.Defs.Eth;

