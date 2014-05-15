with AFDX.Virtual_Links;

package AFDX.Ports is

   type Port_Range is range 0 .. Max_Number_Of_Ports;
   for Port_Range'Size use 16;

   type Port_Type  is (QUEUEING, SAMPLING);

   type Object is tagged limited private;
   type Object_Acc is access all Object;

   function Port (This : in Object) return Port_Range;
   function Mode (This : in Object) return Port_Type;
   function Virtual_Link     (This : in Object) return Virtual_Links.Object_Acc;
   function Sub_Virtual_Link (This : in Object) return Virtual_Links.SVL_Range;

private

   type Object is tagged limited
      record
         Port : Port_Range;
         Mode : Port_Type;
         VL   : Virtual_Links.Object_Acc;
         SVL  : Virtual_Links.SVL_Range;
      end record;

end AFDX.Ports;
