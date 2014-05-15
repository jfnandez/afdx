package AFDX.Ports.Pool is

   package Port_Maps is new Ada.Containers.Ordered_Maps
     (Key_Type     => Port_Range,
      Element_Type => Object_Acc,
      "<"          => "<",
      "="          => "=");

   type Port_Map is new Port_Maps.Map with null record;
   type Port_Map_Acc is access all Port_Map'Class;

   Definition_Error : exception;
   Not_Found        : exception;

   procedure Add
     (Port             : in Port_Range;
      Mode             : in Port_Type;
      Virtual_Link     : in Virtual_Links.ID_Range;
      Sub_Virtual_Link : in Virtual_Links.SVL_Range);


   function Contains(Port : in Port_Range) return BOOLEAN;
   function Retrieve(Port : in Port_Range) return Object_Acc;

end AFDX.Ports.Pool;
