package body Stream_Buffers is

   -----------
   -- Write --
   -----------

   overriding
   procedure Write
     (This : in out Stream_Buffer;
      Item : in     Stream_Element_Array)
   is
      Item_F   : Stream_Element_Offset;
      Item_L   : Stream_Element_Offset;
      New_Head : Stream_Element_Offset;
      Data     : Stream_Element_Array renames This.Data;
   begin

      pragma Assert
        (Item'Length <= This.Writable_Elements,
         "Stream_Buffers.Write: Buffer overflow.");

      if Item'Length > This.Writable_Elements then
         raise BUFFER_OVERFLOW;
      end if;

      New_Head := This.Head + Item'Length - 1;

      if New_Head < This.Size then
         -- La posicion de la nueva cabeza no excede el limite
         Data(This.Head .. New_Head) := Item;

      else
         -- La posicion de la nueva cabeza excede el limite,
         -- es necesario partir el mensaje en dos.

         -- Primer trozo que completa el final:
         Item_F := Item'First;
         Item_L := Item'First + This.Size - This.Head;
         Data(This.Head .. This.Size) := Item(Item_F .. Item_L);

         -- Segundo trozo al comienzo:
         Item_F := Item_L + 1;
         Item_L := Item'Last;
         New_Head   := Item_L - Item_F + 1;
         Data(1 .. New_Head) := Item(Item_F .. Item_L);

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
      Item_F   : Stream_Element_Offset;
      Item_L   : Stream_Element_Offset;
      New_Tail : Stream_Element_Offset;
      Reading  : Stream_Element_Count;
      Data     : Stream_Element_Array renames This.Data;
   begin

      Reading :=  Item'Length;

      if This.Readable_Elements < Reading then
         Reading := This.Readable_Elements;
      end if;

      New_Tail := This.Tail + Reading - 1;

      if New_Tail < This.Size then

         -- La posicion de la nueva cola no excede el limite
         Item_F := Item'First;
         Item_L  := Item'First + Reading - 1;
         Item(Item_F .. Item_L) := Data(This.Tail .. New_Tail);

      else

         -- La posicion de la nueva cola excede el limite, es necesario
         -- recoger el trozo del final y lo necesario del principio.

         -- Primer trozo hasta el final:
         Item_F := Item'First;
         Item_L := Item'First + This.Size - This.Tail;
         Item(Item_F .. Item_L) := Data(This.Tail .. This.Size);

         -- Segundo trozo al comienzo:
         New_Tail := Reading - (Item_L - Item_F) - 1;
         Item_F := Item_L + 1;
         Item_L := Item_L + New_Tail;
         Item(Item_F .. Item_L) := Data(1 .. New_Tail);

      end if;

      This.Tail := New_Tail + 1;
      This.Free := This.Free + Reading;

      Last := Item_L;

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
