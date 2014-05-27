with System;

package body Network is


   -----------------------
   -- Parsing Functions --
   -----------------------

   -------------
   -- BASE 16 --
   -------------

   function Parse_B16 (C : in Character) return Unsigned_8 is
   begin
      case C is
         when '0' .. '9' =>
            return Unsigned_8(Character'Pos(C) - Character'Pos('0'));
         when 'a' .. 'f' =>
            return Unsigned_8(Character'Pos(C) - Character'Pos('a') + 10);
         when 'A' .. 'F' =>
            return Unsigned_8(Character'Pos(C) - Character'Pos('A') + 10);
         when others     =>
            raise Program_Error with
              "Not valid hexadecimal character " & C & '.';
      end case;
   end Parse_B16;


   -------------
   -- BASE 10 --
   -------------

   function Parse_B10 (C : in Character) return Unsigned_8  is
   begin
      case C is
         when '0' .. '9' =>
            return Unsigned_8(Character'Pos(C) - Character'Pos('0'));
         when others     =>
            raise Program_Error with
              "Not valid decimal character " & C & '.';
      end case;
   end Parse_B10;


   ------------
   -- To_Hex --
   ------------

   function To_Hex (X : in Unsigned_8) return String is
      R  : String(1 .. 2) := "00";
      X1 : constant Unsigned_8 := Shift_Right(X, 4);
      X2 : constant Unsigned_8 := X and 16#0F#;
   begin

      case X1 is
         when 0 .. 9 =>
            R(1) := Character'Val(Character'Pos('0') + X1);
         when 10 .. 15 =>
            R(1) := Character'Val(Character'Pos('A') + X1 - 10);
         when others =>
            raise Program_Error;
      end case;

      case X2 is
         when 0 .. 9 =>
            R(2) := Character'Val(Character'Pos('0') + X2);
         when 10 .. 15 =>
            R(2) := Character'Val(Character'Pos('A') + X2 - 10);
         when others =>
            raise Program_Error;
      end case;

      return R;

   end To_Hex;


   --------------------------
   -- To Network Endianess --
   --------------------------

   function To_Net16 (X: in Unsigned_16) return U16_Stream  is
      S: constant U16_Stream := U16_To_Stream(X);
   begin

      case System.Default_Bit_Order is
         when System.High_Order_First =>
            -- Big Endian
            return S;
         when System.Low_Order_First =>
            -- Little Endian
            return U16_Stream'(S(1), S(0));
      end case;

   end To_Net16;
   pragma Inline (To_Net16);


   function To_Net32 (X : in Unsigned_32) return U32_Stream is
      S: constant U32_Stream := U32_To_Stream(X);
   begin

      case System.Default_Bit_Order is
         when System.High_Order_First =>
            -- Big Endian
            return S;
         when System.Low_Order_First =>
            -- Little Endian
            return U32_Stream'(S(3), S(2), S(1), S(0));
      end case;

   end To_Net32;
   pragma Inline (To_Net32);


   function From_Net16 (Stream : in U16_Stream) return Unsigned_16 is
   begin

      case System.Default_Bit_Order is
         when System.High_Order_First =>
            -- Big Endian
            return Stream_To_U16
              (Stream);
         when System.Low_Order_First =>
            -- Little Endian
            return Stream_To_U16
              (U16_Stream'(Stream(1), Stream(0)));
      end case;

   end From_Net16;
   pragma Inline (From_Net16);


   function From_Net32 (Stream : in U32_Stream) return Unsigned_32 is
   begin

      case System.Default_Bit_Order is
         when System.High_Order_First =>
            -- Big Endian
            return Stream_To_U32
              (Stream);
         when System.Low_Order_First =>
            -- Little Endian
            return Stream_To_U32
              (U32_Stream'(Stream(3), Stream(2), Stream(1), Stream(0)));
      end case;

   end From_Net32;
   pragma Inline (From_Net32);


   -------------------------------
   -- One's Complement Checksum --
   -------------------------------

   function Checksum
     (Stream : in Stream_Element_Array;
      Carry  : in Unsigned_16 := 0) return Unsigned_16
   is
      Pos : Stream_Element_Offset := Stream'First;
      Sum : Unsigned_32 := Unsigned_32(Carry);
      Res : Unsigned_16;
   begin

      while Pos < (Stream'Last - 14) loop
         Res := Stream_To_U16(Stream(Pos + 0  .. Pos + 1 ));
         Sum := Sum + Unsigned_32(Res);
         Res := Stream_To_U16(Stream(Pos + 2  .. Pos + 3 ));
         Sum := Sum + Unsigned_32(Res);
         Res := Stream_To_U16(Stream(Pos + 4  .. Pos + 5 ));
         Sum := Sum + Unsigned_32(Res);
         Res := Stream_To_U16(Stream(Pos + 6  .. Pos + 7 ));
         Sum := Sum + Unsigned_32(Res);
         Res := Stream_To_U16(Stream(Pos + 8  .. Pos + 9 ));
         Sum := Sum + Unsigned_32(Res);
         Res := Stream_To_U16(Stream(Pos + 10 .. Pos + 11));
         Sum := Sum + Unsigned_32(Res);
         Res := Stream_To_U16(Stream(Pos + 12 .. Pos + 13));
         Sum := Sum + Unsigned_32(Res);
         Res := Stream_To_U16(Stream(Pos + 14 .. Pos + 15));
         Sum := Sum + Unsigned_32(Res);
         Pos := Pos + 16;
      end loop;

      while Pos < Stream'Last loop
         Res := Stream_To_U16(Stream(Pos + 0 .. Pos + 1));
         Sum := Sum + Unsigned_32(Res);
         Pos := Pos + 2;
      end loop;

      if Pos = Stream'Last then
        Sum := Sum + Unsigned_32(Stream(Stream'Last));
      end if;

      Sum := (Sum and 16#FFFF#) + Shift_Right(Sum, 16);
      Sum := (Sum and 16#FFFF#) + Shift_Right(Sum, 16);

      return Unsigned_16(Sum);

   end Checksum;


end Network;
