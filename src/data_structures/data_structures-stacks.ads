generic

package Data_Structures.Stacks is

   pragma Pure;

   type Stack (Size : Positive) is new Data_Structure with private;
   type Stack_Acc is access all Stack'Class;

   overriding procedure Put
     (This    : in out Stack;
      Element : in     Element_Type);

   overriding procedure Get
     (This    : in out Stack;
      Element :    out Element_Type);

   overriding function Peek (This : in Stack) return Element_Type;

   overriding procedure Flush (This : in out Stack);

private

   type Stack (Size : Positive) is new Data_Structure(Size) with
      record
         Head : Natural := 0;
         Data : Element_Type_Array (1 .. Size);
      end record;

end Data_Structures.Stacks;
