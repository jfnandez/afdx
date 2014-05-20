package body Stream_Buffers is

   -----------
   -- Write --
   -----------

   overriding
   procedure Write
     (This : in out Stream_Buffer;
      Item : in     Stream_Element_Array)
   is
      Item_First  : Stream_Element_Offset;
      Item_Last   : Stream_Element_Offset;
      New_Head    : Stream_Element_Offset;
      Is_Writable : constant Boolean := Item'Length <= This.Writable_Elements;
   begin

      if not Is_Writable then
         raise BUFFER_OVERFLOW;
      end if;

      New_Head := This.Head + Item'Length - 1;

      if New_Head < This.Size then
         -- La posicion de la nueva cabeza no excede el limite
         This.Data(This.Head .. New_Head) := Item;

      else
         -- La posicion de la nueva cabeza excede el limite,
         -- es necesario partir el mensaje en dos.

         -- Primer trozo que completa el final:
         Item_First := Item'First;
         Item_Last  := Item_First + This.Size - This.Head;
         This.Data(This.Head .. This.Size) := Item(Item_First .. Item_Last);

         -- Segundo trozo al comienzo:
         Item_First := Item_Last + 1;
         Item_Last  := Item'Last;
         New_Head   := Item_Last - Item_First + 1;
         This.Data(1 .. New_Head) := Item(Item_First .. Item_Last);

      end if;

      This.Head := New_Head + 1;
      This.Free := This.Free - Item'Length;

   end Write;


   ----------
   -- Read --
   ----------

   overriding
   procedure Read
     (This : in out Stream_Buffer;
      Item :    out Stream_Element_Array;
      Last :    out Stream_Element_Offset)
   is
      Item_First    : Stream_Element_Offset;
      Item_Last     : Stream_Element_Offset;
      New_Tail      : Stream_Element_Offset;
      Full_Readable : constant Boolean
        := Item'Length <= This.Readable_Elements;
   begin

      Last := Item'First - 1;

      if Full_Readable then

         New_Tail := This.Tail + Item'Length - 1;

         if New_Tail < This.Size then
            -- La posicion de la nueva cola no excede el limite
            Item := This.Data(This.Tail .. New_Tail);

         else
            -- La posicion de la nueva cola excede el limite, es necesario
            -- recoger el trozo del final y lo necesario del principio.

            -- Primer trozo hasta el final:
            Item_First := Item'First;
            Item_Last  := Item_First + This.Size - This.Tail;
            Item(Item_First .. Item_Last) := This.Data(This.Tail .. This.Size);

            -- Segundo trozo al comienzo:
            Item_First := Item_Last + 1;
            Item_Last  := Item'Last;
            New_Tail   := Item_Last - Item_First + 1;
            Item(Item_First .. Item_Last) := This.Data(1 .. New_Tail);

         end if;

         This.Tail := New_Tail + 1;
         This.Free := This.Free + Item'Length;

         Last := Item'Last;

      else

         if This.Is_Empty then
            return;
         end if;

         New_Tail := This.Tail + This.Readable_Elements - 1;

         if New_Tail < This.Size then

            -- La posicion de la nueva cola no excede el limite
            Item_First := Item'First;
            Item_Last  := Item'First + This.Readable_Elements - 1;
            Item(Item_First .. Item_Last) := This.Data(This.Tail .. New_Tail);

         else

            -- La posicion de la nueva cola excede el limite, es necesario
            -- recoger el trozo del final y lo necesario del principio.

            -- Primer trozo hasta el final:
            Item_First := Item'First;
            Item_Last  := Item_First + This.Size - This.Tail;
            Item(Item_First .. Item_Last) := This.Data(This.Tail .. This.Size);

            -- Segundo trozo al comienzo:
            New_Tail := This.Readable_Elements - (Item_Last - Item_First) - 1;
            Item_First := Item_Last + 1;
            Item_Last  := Item_Last + New_Tail;
            Item(Item_First .. Item_Last) := This.Data(1 .. New_Tail);

         end if;

         Last := Item_Last;

         This.Flush;

      end if;

   end Read;


   -----------
   -- Flush --
   -----------

   procedure Flush
     (This : in out Stream_Buffer)
   is
   begin
      This.Tail := 1;
      This.Head := 1;
      This.Free := This.Size;
   end Flush;
   pragma Inline (Flush);


   -----------------------
   -- Writable_Elements --
   -----------------------

   function Writable_Elements
     (This : in Stream_Buffer) return Stream_Element_Count
   is
   begin
      return This.Free;
   end Writable_Elements;
   pragma Inline (Writable_Elements);


   -----------------------
   -- Readable_Elements --
   -----------------------

   function Readable_Elements
     (This : in Stream_Buffer) return Stream_Element_Count
   is
   begin
      return This.Size - This.Free;
   end Readable_Elements;
   pragma Inline (Readable_Elements);


   --------------
   -- Is_Empty --
   --------------

   function Is_Empty
     (This : in Stream_Buffer) return Boolean
   is
   begin
      return This.Free = This.Size;
   end Is_Empty;
   pragma Inline (Is_Empty);


   -------------
   -- Is_Full --
   -------------

   function Is_Full
     (This : in Stream_Buffer) return Boolean
   is
   begin
      return This.Free = 0;
   end Is_Full;
   pragma Inline (Is_Full);


end Stream_Buffers;
