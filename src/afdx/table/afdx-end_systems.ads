package AFDX.End_Systems is

   type ID_Range is range 1 .. Max_Number_Of_End_Systems;
   type ID_Array is array (Natural range <>) of ID_Range;

   type Object is tagged limited private;
   type Object_Acc is access all Object'Class;

   function ID     (This : in Object) return ID_Range;
   function MAC    (This : in Object) return Eth.Address;
   function IP     (This : in Object) return IPv4.Address;

   function Its_Me (This : in Object) return Boolean;
   function Get_Me return Object_Acc;

   package Maps is new Ada.Containers.Ordered_Maps
     (Key_Type     => ID_Range,
      Element_Type => Object_Acc,
      "<"          => "<",
      "="          => "=");

   type Action_Procedure is access procedure (Cursor : in Maps.Cursor);

private

   type Object is tagged limited
      record
         ID   : ID_Range;
         MAC  : Eth.Address;
         IP   : IPv4.Address;
      end record;

   This_Object : Object_Acc := null;

end AFDX.End_Systems;
