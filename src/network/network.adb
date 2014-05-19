with System;

package body Network is


   -----------------------
   -- Parsing Functions --
   -----------------------

   -------------
   -- BASE 16 --
   -------------

   function Parse_B16(C : in Character) return Unsigned_8 is
   begin
      case C is
         when '0' .. '9' =>
            return Unsigned_8(Character'Pos(C) - Character'Pos('0'));
         when 'a' .. 'f' =>
            return Unsigned_8(Character'Pos(C) - Character'Pos('a') + 10);
         when 'A' .. 'F' =>
            return Unsigned_8(Character'Pos(C) - Character'Pos('A') + 10);
         when others     =>
            raise Parsing_Error with "Not valid hexadecimal character " & C & '.';
      end case;
   end Parse_B16;


   -------------
   -- BASE 10 --
   -------------

   function Parse_B10(C : in Character) return Unsigned_8 is
   begin
      case C is
         when '0' .. '9' =>
            return Unsigned_8(Character'Pos(C) - Character'Pos('0'));
         when others     =>
            raise Parsing_Error with "Not valid decimal character " & C & '.';
      end case;
   end Parse_B10;


   ------------
   -- To_Hex --
   ------------

   function To_Hex (N : in Unsigned_8) return STRING is
      Result : STRING(1 .. 2) := "00";
      N1 : constant Unsigned_8 := Shift_Right(N, 4);
      N2 : constant Unsigned_8 := N and 16#0F#;
   begin

      case N1 is
         when 0 .. 9 =>
            Result(1) := Character'Val(Character'Pos('0') + N1);
         when 10 .. 15 =>
            Result(1) := Character'Val(Character'Pos('A') + N1 - 10);
         when others =>
            raise Program_Error with "Never happends.";
      end case;

      case N2 is
         when 0 .. 9 =>
            Result(2) := Character'Val(Character'Pos('0') + N2);
         when 10 .. 15 =>
            Result(2) := Character'Val(Character'Pos('A') + N2 - 10);
         when others =>
            raise Program_Error with "Never happends.";
      end case;

      return Result;

   end To_Hex;


   --     -------------------------
   --     -- Endianness Reversal --
   --     -------------------------
   --
   --     pragma Warnings(OFF);
   --
   --     function Reverse_Endianness (X : in Unsigned_16) return Unsigned_16 is
   --        S : constant U16_Stream := U16_To_Stream(X);
   --     begin
   --        return Stream_To_U16(U16_Stream'(S(2), S(1)));
   --     end Reverse_Endianness;
   --     pragma Inline (Reverse_Endianness);
   --
   --
   --     function Reverse_Endianness (X : in Unsigned_32) return Unsigned_32 is
   --        S : constant U32_Stream := U32_To_Stream(X);
   --     begin
   --        return Stream_To_U32(U32_Stream'(S(4), S(3), S(2), S(1)));
   --     end Reverse_Endianness;
   --     pragma Inline (Reverse_Endianness);
   --
   --     pragma Warnings(ON);


   --------------------------
   -- To Network Endianess --
   --------------------------

   function To_Net16(X: in Unsigned_16) return U16_Stream is
      S: constant U16_Stream := U16_To_Stream(X);
   begin

      case System.Default_Bit_Order is
         when System.High_Order_First =>
            -- Big Endian
            return S;
         when System.Low_Order_First =>
            -- Little Endian
            return U16_Stream'(S(2), S(1));
      end case;

   end To_Net16;
   pragma Inline (To_Net16);


   function To_Net32(X : in Unsigned_32) return U32_Stream is
      S: constant U32_Stream := U32_To_Stream(X);
   begin

      case System.Default_Bit_Order is
         when System.High_Order_First =>
            -- Big Endian
            return S;
         when System.Low_Order_First =>
            -- Little Endian
            return U32_Stream'(S(4), S(3), S(2), S(1));
      end case;

   end To_Net32;
   pragma Inline (To_Net32);


   function From_Net16(Stream : in U16_Stream) return Unsigned_16 is
   begin

      case System.Default_Bit_Order is
         when System.High_Order_First =>
            -- Big Endian
            return Stream_To_U16
              (Stream);
         when System.Low_Order_First =>
            -- Little Endian
            return Stream_To_U16
              (U16_Stream'(Stream(2), Stream(1)));
      end case;

   end From_Net16;
   pragma Inline (From_Net16);


   function From_Net32(Stream : in U32_Stream) return Unsigned_32 is
   begin

      case System.Default_Bit_Order is
         when System.High_Order_First =>
            -- Big Endian
            return Stream_To_U32
              (Stream);
         when System.Low_Order_First =>
            -- Little Endian
            return Stream_To_U32
              (U32_Stream'(Stream(4), Stream(3), Stream(2), Stream(1)));
      end case;

   end From_Net32;
   pragma Inline (From_Net32);


   -------------------------------
   -- One's Complement Checksum --
   -------------------------------

   function Checksum
     (Stream : in Stream_Element_Array) return Unsigned_16
   is
      Position : Stream_Element_Offset := Stream'First + 1;
      Total    : Unsigned_32 := 0;
      Partial  : Unsigned_16;
   begin

      Total := Unsigned_32(Stream(Stream'First));
      Total := Shift_Left(Total, 8);

      while Position < Stream'Last loop
         Partial  := Stream_To_U16(Stream(Position .. Position + 1));
         Total    := Total + Unsigned_32(Partial);
         Position := Position + 2;
      end loop;

      if Position = Stream'Last then
         Total := Total + Unsigned_32(Stream(Stream'Last));
      end if;

      Total := (Total and 16#FFFF#) + Shift_Right(Total, 16);
      Total := (Total and 16#FFFF#) + Shift_Right(Total, 16);

      Partial := Unsigned_16(Total);

      case System.Default_Bit_Order is
         when System.High_Order_First =>
            -- Big Endian
            null;
         when System.Low_Order_First =>
            -- Little Endian
            Partial := Shift_Left(Partial, 4) xor Shift_Right(Partial, 4);
      end case;

      return Partial;

   end Checksum;


end Network;
