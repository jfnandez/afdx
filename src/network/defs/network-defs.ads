package Network.Defs is

   pragma Pure;

   MTU : constant := 1500;
   
   type Frame is record
   Data   : Stream_Element_Array(1 .. MTU);
   Length : Stream_Element_Count;
   end record;

end Network.Defs;
