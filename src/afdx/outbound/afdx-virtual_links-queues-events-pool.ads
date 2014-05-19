package AFDX.Virtual_Links.Queues.Events.Pool is

   function Retrieve (ID : in ID_Range) return Object_Acc;
   function Contains (ID : in ID_Range) return Boolean;

end AFDX.Virtual_Links.Queues.Events.Pool;
