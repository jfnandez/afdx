package AFDX.Ports.Pool is

   Definition_Error : exception;
   Not_Found        : exception;

   procedure Add
     (Port             : in Network.Defs.UDP.Port;
      Mode             : in Port_Type;
      Virtual_Link     : in Virtual_Links.ID_Range;
      Sub_Virtual_Link : in Virtual_Links.Sub_Virtual_Link_Range);

   function Contains(Port : in Network.Defs.UDP.Port) return Boolean;
   function Retrieve(Port : in Network.Defs.UDP.Port) return Object_Acc;

   procedure Iterate          (Action : in Action_Procedure);
   procedure Iterate_QUEUEING (Action : in Action_Procedure);
   procedure Iterate_SAMPLING (Action : in Action_Procedure);

   function Items          return NATURAL;
   function Items_QUEUEING return NATURAL;
   function Items_SAMPLING return NATURAL;

end AFDX.Ports.Pool;
