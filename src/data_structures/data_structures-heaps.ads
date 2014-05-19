generic

   with function ">" (Left, Right : Element_Type) return Boolean is <>;
   Top_Element : in Element_Type;

package Data_Structures.Heaps is

   pragma Pure;

   type Heap (Size : Positive) is new Data_Structure with private;
   type Heap_Acc is access all Heap'Class;

   overriding procedure Put
     (This    : in out Heap;
      Element : in     Element_Type);

   overriding procedure Get
     (This    : in out Heap;
      Element :    out Element_Type);

   overriding function Peek (This : in Heap) return Element_Type;

   overriding procedure Flush (This : in out Heap);

private

   type Heap (Size : Positive)
     is new Data_Structure(Size) with
      record
         Data : Element_Type_Array (0 .. Size) := (others => Top_Element);
         Tail : Natural := 0;
      end record;

end Data_Structures.Heaps;
