with Ada.Streams; use Ada.Streams;
with Interfaces;  use Interfaces;

with Ada.Unchecked_Conversion;

package Network is

   pragma Pure;

private

   Parsing_Error : exception;

   function Parse_B16(C : in Character) return Unsigned_8;
   function Parse_B10(C : in Character) return Unsigned_8;

   function To_Hex (N : in Unsigned_8) return STRING;

   subtype U16_Stream is Stream_Element_Array(1 .. 2);
   subtype U32_Stream is Stream_Element_Array(1 .. 4);

   function To_Net16(X : in Unsigned_16) return U16_Stream;
   function To_Net32(X : in Unsigned_32) return U32_Stream;

   function From_Net16(Stream : in U16_Stream) return Unsigned_16;
   function From_Net32(Stream : in U32_Stream) return Unsigned_32;

   function U16_To_Stream is new Ada.Unchecked_Conversion
     (Source => Unsigned_16,
      Target => U16_Stream);

   function  U32_To_Stream is new Ada.Unchecked_Conversion
     (Source => Unsigned_32,
      Target => U32_Stream);

   function Stream_To_U16 is new Ada.Unchecked_Conversion
     (Source => U16_Stream,
      Target => Unsigned_16);

   function Stream_To_U32 is new Ada.Unchecked_Conversion
     (Source => U32_Stream,
      Target => Unsigned_32);

   function Checksum (Stream : in Stream_Element_Array) return Unsigned_16;

end Network;
