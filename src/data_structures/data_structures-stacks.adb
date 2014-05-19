package body Data_Structures.Stacks is


   ---------
   -- Put --
   ---------

   overriding procedure Put
     (This    : in out Stack;
      Element : in     Element_Type)
   is
   begin

      pragma Assert
        (not This.Is_Full,
         "DATA_STRUCTURES.STACKS Put(): Full stack.");

      if This.Is_Full then
         raise DATA_OVERFLOW;
      end if;

      This.Head := This.Head + 1;
      This.Data(This.Head) := Element;
      This.Free := This.Free - 1;

   end Put;


   ---------
   -- Get --
   ---------

   overriding procedure Get
     (This    : in out Stack;
      Element : out Element_Type)
   is
   begin

      pragma Assert
        (not This.Is_Empty,
         "DATA_STRUCTURES.STACKS Get(): Empty stack.");

      if This.Is_Empty then
         raise DATA_UNDERFLOW;
      end if;

      Element := This.Data(This.Head);
      This.Head := This.Head - 1;
      This.Free := This.Free + 1;

   end Get;


   ----------
   -- Peek --
   ----------

   overriding function Peek (This : in Stack) return Element_Type is
   begin

      pragma Assert
        (not This.Is_Empty,
         "DATA_STRUCTURES.STACKS Peek(): Empty stack.");

      return This.Data(This.Head);

   end Peek;
   pragma Inline (Peek);


   -----------
   -- Clear --
   -----------

   overriding procedure Flush (This : in out Stack) is
   begin

      This.Head := 0;
      This.Free := This.Size;

   end Flush;
   pragma Inline (Flush);

end Data_Structures.Stacks;
