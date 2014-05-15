package Network.Stack.Up.IP_Buffers is

   type Object(Size : Stream_Element_Count) is tagged limited private;
   type Object_Acc is access all Object;


   procedure Put
     (This     : in out Object;
      Stream   : in     Stream_Element_Array;
      Offset   : in     Stream_Element_Count;
      MF_Flag  : in     BOOLEAN;
      Is_Ready :    out BOOLEAN);

   function Get (This : in Object) return Stream_Element_Array;


   procedure Free (This : in out Object_Acc);

private

   type Object (Size : Stream_Element_Count) is tagged limited
      record
         Stored   : Stream_Element_Count := 0;
         Total    : Stream_Element_Count := 0;
         Buffer   : Stream_Element_Array(1 .. Size);
      end record;

end Network.Stack.Up.IP_Buffers;
