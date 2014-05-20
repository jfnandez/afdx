package body Data_Structures is


   --------------
   -- Is_Empty --
   --------------

   function Is_Empty (This : in Data_Structure) return Boolean is
   begin
      return This.Free = This.Size;
   end Is_Empty;
   pragma Inline (Is_Empty);


   -------------
   -- Is_Full --
   -------------

   function Is_Full (This : in Data_Structure) return Boolean is
   begin
      return This.Free = 0;
   end Is_Full;
   pragma Inline (Is_Full);


   ---------------------
   -- Elements_Stored --
   ---------------------

   function Elements_Stored (This : in Data_Structure) return Natural is
   begin
      return This.Size - This.Free;
   end Elements_Stored;
   pragma Inline (Elements_Stored);


   -------------------
   -- Elements_Free --
   -------------------

   function Elements_Free (This : in Data_Structure) return Natural is
   begin
      return This.Free;
   end Elements_Free;
   pragma Inline (Elements_Free);

end Data_Structures;
