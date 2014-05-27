package body Network.Defs.IPv4 is

   function Parse (IP : in String) return Address
   is
      IP_R   : Unsigned_32 := 0;
      Total  : Unsigned_32;
      Offset : Integer := IP'First;
   begin

      for I in 1 ..3 loop
         Total  := 0;

         while IP(Offset) /= '.' loop

            Total  := Total*10 + Unsigned_32(Parse_B10(IP(Offset)));
            Offset := Offset + 1;

            if Total > 255 then
               raise Program_Error;
            end if;

         end loop;

         Offset := Offset + 1;

         IP_R := Shift_Left(IP_R, 8) or Total;

      end loop;

      Total  := 0;

      for I in Offset .. IP'Last loop

         Total  := Total*10 + Unsigned_32(Network.Parse_B10(IP(I)));

         if Total > 255 then
            raise Program_Error;
         end if;

      end loop;

      IP_R := Shift_Left(IP_R, 8) or Total;

      return Address(IP_R);

   end Parse;


   function "=" (Left, Right : in Address) return Boolean is
   begin
      return Unsigned_32(Left) = Unsigned_32(Right);
   end "=";


   function "<" (Left, Right : in Address) return Boolean is
   begin
      return Unsigned_32(Left) < Unsigned_32(Right);
   end "<";

      function "<=" (Left, Right : in Address) return Boolean is
   begin
      return Unsigned_32(Left) <= Unsigned_32(Right);
   end "<=";

      function ">" (Left, Right : in Address) return Boolean is
   begin
      return Unsigned_32(Left) > Unsigned_32(Right);
   end ">";

      function ">=" (Left, Right : in Address) return Boolean is
   begin
      return Unsigned_32(Left) >= Unsigned_32(Right);
   end ">=";


   function To_String(IP : in Address) return String is

      T : constant Unsigned_32 := Unsigned_32(IP);
      B1: constant Unsigned_32 := Shift_Right(T, 24) and 16#000000FF#;
      B2: constant Unsigned_32 := Shift_Right(T, 16) and 16#000000FF#;
      B3: constant Unsigned_32 := Shift_Right(T,  8) and 16#000000FF#;
      B4: constant Unsigned_32 := T and 16#000000FF#;

      ST : STRING := B1'Img & B2'Img & B3'Img & B4'Img;
   begin

         for I in ST'RANGE loop
            if ST(I) = ' ' then
               ST(I) := '.';
            end if;
         end loop;

         return ST(ST'First + 1 .. ST'Last);

   end To_String;

   function To_Stream (IP : in Address) return Address_Stream is
   begin
      return To_Net32(Unsigned_32(IP));
   end To_Stream;


   function To_Address (IP : in Address_Stream) return Address is
   begin
      return Address(From_Net32(IP));
   end To_Address;



   function Is_Multicast(IP : in Address) return Boolean is
   begin
      return (IP in Multicast_Address);
   end Is_Multicast;


   UDP_Protocol : constant Unsigned_8 := 17;

   function Protocol_Conv (Protocol : in Protocols) return Unsigned_8 is
   begin
      case Protocol is
         when UDP   => return UDP_Protocol;
         when others => raise Program_Error;
      end case;
   end Protocol_Conv;

   function Protocol_Conv (Protocol : in Unsigned_8) return Protocols is
   begin
      case Protocol is
         when UDP_Protocol => return UDP;
         when others       => return No_Def;
      end case;
   end Protocol_Conv;




   end Network.Defs.IPv4;

