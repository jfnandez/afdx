with Ada.Containers.Ordered_Maps;

with Network.Defs.UDP;

with AFDX.Virtual_Links;

package AFDX.Ports is

   type Port_Type  is (QUEUEING, SAMPLING);

   type Object is tagged limited private;
   type Object_Acc is access all Object;

   function Port
     (This : in Object) return Network.Defs.UDP.Port;

   function Mode
     (This : in Object) return Port_Type;

   function Virtual_Link
     (This : in Object) return Virtual_Links.Object_Acc;

   function Sub_Virtual_Link
     (This : in Object) return Virtual_Links.Sub_Virtual_Link_Range;

   package Maps is new Ada.Containers.Ordered_Maps
     (Key_Type     => Network.Defs.UDP.Port,
      Element_Type => Object_Acc,
      "<"          => "<",
      "="          => "=");

   type Action_Procedure is access procedure (Cursor : in Maps.Cursor);

private

   type Object is tagged limited
      record
         Port             : Network.Defs.UDP.Port;
         Mode             : Port_Type;
         Virtual_Link     : Virtual_Links.Object_Acc;
         Sub_Virtual_Link : Virtual_Links.Sub_Virtual_Link_Range;
      end record;

end AFDX.Ports;
