package body Data_Structures.Heaps is


   ------------
   -- Parent --
   ------------

   function Parent (Position : in Natural) return Natural is
   begin
      return Position / 2;
   end Parent;
   pragma Inline (Parent);


   ----------------
   -- Left_Child --
   ----------------

   function Left_Child (Position : in Natural) return Natural is
   begin
      return Position + Position;
   end Left_Child;
   pragma Inline (Left_Child);


   ---------
   -- Put --
   ---------

   overriding procedure Put
     (This    : in out Heap;
      Element : in     Element_Type)
   is
      Child_Pos  : Natural;
      Parent_Pos : Natural;
   begin

      pragma Assert
        (not This.Is_Full, "Data_Structures.Heaps.Put: overflow error.");

      if This.Is_Full then
         raise OVERFLOW;
      end if;

      This.Tail := This.Tail + 1;

      Child_Pos  := This.Tail;
      Parent_Pos := Parent(Child_Pos);

      while Element > This.Data (Parent_Pos) loop
         This.Data(Child_Pos) := This.Data(Parent_Pos);
         Child_Pos  := Parent_Pos;
         Parent_Pos := Parent(Child_Pos);
      end loop;

      This.Data(Child_Pos) := Element;

      This.Free := This.Free - 1;

   end Put;


   ---------
   -- Get --
   ---------

   overriding procedure Get
     (This    : in out Heap;
      Element :    out Element_Type)
   is
      Parent_Pos :          Positive     := 1;
      Child_Pos  :          Positive     := Left_Child(Parent_Pos);
      Last_Elem  : constant Element_Type := This.Data(This.Tail);
   begin

      pragma Assert
        (not This.Is_Empty, "Data_Structures.Heaps.Get: underflow error.");

      if This.Is_Empty then
         raise UNDERFLOW;
      end if;

      if This.Tail > 1 then

         Element := This.Data(1);
         This.Tail := This.Tail - 1;

         while Child_Pos <= This.Tail loop

            if Child_Pos < This.Tail
              and then This.Data(Child_Pos + 1) > This.Data(Child_Pos) then
               Child_Pos := Child_Pos + 1;
            end if;

            exit when (Last_Elem > This.Data(Child_Pos));

            This.Data(Parent_Pos) := This.Data(Child_Pos);
            Parent_Pos := Child_Pos;
            Child_Pos  := Left_Child(Parent_Pos);

         end loop;

         This.Data(Parent_Pos) := Last_Elem;
         This.Free := This.Free + 1;

      else

         Element := This.Data(1);
         This.Flush;

      end if;

   end Get;


   ----------
   -- Peek --
   ----------

   overriding function Peek (This : in Heap) return Element_Type is
   begin

      pragma Assert
        (not This.Is_Empty, "Data_Structures.Heaps.Peek: underflow error.");

      if This.Is_Empty then
         raise UNDERFLOW;
      end if;

      return This.Data(1);

   end Peek;
   pragma Inline (Peek);


   -----------
   -- Clear --
   -----------

   overriding procedure Flush (This : in out Heap) is
   begin
      This.Free := This.Size;
      This.Tail := 0;
   end Flush;
   pragma Inline (Flush);

end Data_Structures.Heaps;
