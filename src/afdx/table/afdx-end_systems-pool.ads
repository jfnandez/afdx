package AFDX.End_Systems.Pool is

   package ID_Maps is new Ada.Containers.Ordered_Maps
     (Key_Type     => ID_Range,
      Element_Type => Object_Acc,
      "<"          => "<",
      "="          => "=");

   type ID_Map is new ID_Maps.Map with null record;
   type ID_Map_Acc is access all ID_Map'Class;


   Definition_Error : exception;
   Not_Found        : exception;

   procedure Add (ID : in ID_Range; MAC : in STRING; IP : in STRING);

   function Contains(ID : in ID_Range) return BOOLEAN;
   function Retrieve(ID : in ID_Range) return Object_Acc;


   type Action_Procedure is access procedure (Cursor : in ID_Maps.Cursor);

   procedure Iterate (Action : in Action_Procedure);


   function Number return Natural;
   function This return Object_Acc;

end AFDX.End_Systems.Pool;
