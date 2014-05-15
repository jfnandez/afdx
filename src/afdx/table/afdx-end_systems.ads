package AFDX.End_Systems is

   type ID_Range is range 1 .. Max_Number_Of_End_Systems;
   type ID_Array is array (Natural range <>) of ID_Range;

   type Object is tagged limited private;
   type Object_Acc is access all Object'Class;

   function ID     (This : in Object) return ID_Range;
   function MAC    (This : in Object) return Eth.Address;
   function IP     (This : in Object) return IPv4.Address;
   function Its_Me (This : in Object) return Boolean;




private

   type Object is tagged limited
      record
         ID   : ID_Range;
         MAC  : Eth.Address;
         IP   : IPv4.Address;
      end record;

end AFDX.End_Systems;
