with Ada.Streams;
use  Ada.Streams;

package Stream_Buffers is

   pragma Pure;

   BUFFER_OVERFLOW  : exception;
   BUFFER_UNDERFLOW : exception;

   type Stream_Buffer (Size : Stream_Element_Count)
     is new Root_Stream_Type with private;

   overriding
   procedure Write
     (This : in out Stream_Buffer;
      Item : in     Stream_Element_Array);

   overriding
   procedure Read
     (This : in out Stream_Buffer;
      Item :    out Stream_Element_Array;
      Last :    out Stream_Element_Offset);

   procedure Flush (This : in out Stream_Buffer);

   function Writable_Elements
     (This : in Stream_Buffer) return Stream_Element_Count;

   function Readable_Elements
     (This : in Stream_Buffer) return Stream_Element_Count;

   function Is_Empty (This : in Stream_Buffer) return Boolean;
   function Is_Full  (This : in Stream_Buffer) return Boolean;

private

   type Stream_Buffer (Size : Stream_Element_Count)
     is new Root_Stream_Type with
      record
         Head : Stream_Element_Offset := 1;
         Tail : Stream_Element_Offset := 1;
         Free : Stream_Element_Count := Size;
         Data : Stream_Element_Array (1 .. Size);
      end record;

end Stream_Buffers;
