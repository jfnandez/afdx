package AFDX.Virtual_Links.Pool is

   package ID_Maps is new Ada.Containers.Ordered_Maps
     (Key_Type     => ID_Range,
      Element_Type => Object_Acc,
      "<"          => "<",
      "="          => "=");

   type ID_Map is new ID_Maps.Map with null record;
   type ID_Map_Acc is access all ID_Map'Class;

   Definition_Error : exception;
   Not_Found        : exception;

   procedure Add
     (ID       : in ID_Range;
      BAG      : in BAG_Enum;
      Priority : in Prio_Enum;
      Lmax     : in Positive;
      IP       : in STRING;
      Src      : in End_Systems.ID_Range;
      Des      : in End_Systems.ID_Array;
      TX_Sizes : in SVL_Size;
      RX_Sizes : in SVL_Size);

   function Contains(ID : in ID_Range) return BOOLEAN;
   function Retrieve(ID : in ID_Range) return Object_Acc;

   type Action_Procedure is access procedure (Cursor : in ID_Maps.Cursor);

   procedure Iterate_In  (Action : in Action_Procedure);
   procedure Iterate_Out (Action : in Action_Procedure);
   procedure Iterate_All (Action : in Action_Procedure);

   function Number_In  return Natural;
   function Number_Out return Natural;
   function Number_All return Natural;

end AFDX.Virtual_Links.Pool;

