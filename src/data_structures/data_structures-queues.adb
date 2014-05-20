package body Data_Structures.Queues is


   ------------------
   -- Mod_Increase --
   ------------------

   procedure Mod_Increase
     (X      : in out Positive;
      Modulo : in     Positive)
   is
   begin
      if X < Modulo then
         X := X + 1;
      else
         X := 1;
      end if;
   end Mod_Increase;
   pragma Inline (Mod_Increase);


   ------------------
   -- Mod_Decrease --
   ------------------

   procedure Mod_Decrease
     (X      : in out Positive;
      Modulo : in     Positive)
   is
   begin
      if X /= 1 then
         X := X - 1;
      else
         X := Modulo;
      end if;
   end Mod_Decrease;
   pragma Inline (Mod_Decrease);


   ---------
   -- Put --
   ---------

   overriding procedure Put
     (This    : in out Queue;
      Element : in     Element_Type)
   is
   begin

      pragma Assert
        (not This.Is_Full,
         "DATA_STRUCTURES.QUEUES Put(): Full queue.");

      if This.Is_Full then
         raise DATA_OVERFLOW;
      end if;

      This.Data(This.Head) := Element;
      Mod_Increase
        (X      => This.Head,
         Modulo => This.Size);
      This.Free := This.Free - 1;

   end Put;


   ---------
   -- Get --
   ---------

   overriding procedure Get
     (This    : in out Queue;
      Element :    out Element_Type)
   is
   begin

      pragma Assert
        (not This.Is_Empty,
         "DATA_STRUCTURES.QUEUES Get(): Empty queue.");

      if This.Is_Empty then
         raise DATA_UNDERFLOW;
      end if;

      Element := This.Data(This.Tail);
      Mod_Increase
        (X      => This.Tail,
         Modulo => This.Size);
      This.Free := This.Free + 1;

   end Get;


   ----------
   -- Peek --
   ----------

   overriding function Peek (This : in Queue) return Element_Type is
   begin

      pragma Assert
        (not This.Is_Empty,
         "DATA_STRUCTURES.QUEUES Peek(): Empty queue.");

      if This.Is_Empty then
         raise DATA_UNDERFLOW;
      end if;

      return This.Data(This.Tail);

   end Peek;
   pragma Inline (Peek);


   -----------
   -- Clear --
   -----------

   overriding  procedure Flush (This : in out Queue) is
   begin

      This.Head := 1;
      This.Tail := 1;
      This.Free := This.Size;

   end Flush;
   pragma Inline (Flush);

end Data_Structures.Queues;
