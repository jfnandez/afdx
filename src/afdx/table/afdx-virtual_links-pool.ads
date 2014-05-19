package AFDX.Virtual_Links.Pool is

   Definition_Error : exception;
   Not_Found        : exception;

   procedure Add
     (ID          : in ID_Range;
      BAG         : in BAG_Enum;
      Priority    : in Prio_Enum;
      Lmax        : in Positive;
      IP          : in STRING;
      Source      : in End_Systems.ID_Range;
      Destination : in End_Systems.ID_Array;
      TX_Size     : in Sub_Virtual_Link_Size;
      RX_Size     : in Sub_Virtual_Link_Size);

   function Contains(ID : in ID_Range) return BOOLEAN;
   function Retrieve(ID : in ID_Range) return Object_Acc;

   procedure Iterate     (Action : in Action_Procedure);
   procedure Iterate_In  (Action : in Action_Procedure);
   procedure Iterate_Out (Action : in Action_Procedure);

   function Items     return NATURAL;
   function Items_In  return NATURAL;
   function Items_Out return NATURAL;

end AFDX.Virtual_Links.Pool;

