package AFDX.End_Systems.Pool is

   Definition_Error : exception;
   Not_Found        : exception;

   procedure Add
     (ID  : in ID_Range;
      MAC : in STRING;
      IP  : in STRING);

   function Contains (ID : in ID_Range) return BOOLEAN;

   function Retrieve (ID : in ID_Range) return Object_Acc;

   procedure Iterate (Action : in Action_Procedure);

   function Items return NATURAL;

end AFDX.End_Systems.Pool;
