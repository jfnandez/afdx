generic

package Data_Structures.Queues is

   pragma Pure;

   type Queue (Size : Positive) is new Data_Structure with private;
   type Queue_Acc is access all Queue'Class;

   overriding procedure Put
     (This    : in out Queue;
      Element : in     Element_Type);

   overriding procedure Get
     (This    : in out Queue;
      Element :    out Element_Type);


   overriding function Peek (This : in Queue) return Element_Type;

   overriding procedure Flush (This : in out Queue);

private

   type Queue (Size : Positive) is new Data_Structure(Size) with
      record
         Head : Positive := 1;
         Tail : Positive := 1;
         Data : Element_Type_Array (1 .. Size);
      end record;

   procedure Mod_Increase (X : in out Positive; Modulo : in Positive);
   procedure Mod_Decrease (X : in out Positive; Modulo : in Positive);

end Data_Structures.Queues;
