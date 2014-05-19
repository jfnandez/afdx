package body AFDX.End_Systems.Pool is


   Object_Pool : Maps.Map;

   --------------
   -- Contains --
   --------------

   function Contains(ID : in ID_Range) return BOOLEAN is
   begin
      return Object_Pool.Contains(ID);
   end Contains;


   --------------
   -- Retrieve --
   --------------

   function Retrieve (ID : in ID_Range) return Object_Acc is
      Cursor : constant Maps.Cursor := Object_Pool.Find(ID);
   begin
      if Maps.Has_Element(Cursor) then
         return Maps.Element(Cursor);
      else
         raise Not_Found;
      end if;
   end Retrieve;


   ---------
   -- Add --
   ---------

   procedure Add
     (ID  : in ID_Range;
      MAC : in STRING;
      IP : in STRING)
   is

      ES_Candidate : Object_Acc;
      use type Eth.Address;

      procedure Validation (Position : Maps.Cursor) is
         ES_Inserted : constant Object_Acc := Maps.Element(Position);
         use type IPv4.Address;
      begin
         if    (ES_Inserted.ID = ES_Candidate.ID) then
            raise Definition_Error with "Duplicated ES ID.";
         elsif (ES_Inserted.MAC = ES_Candidate.MAC) then
            raise Definition_Error with "Duplicated ES MAC.";
         elsif (ES_Inserted.IP = ES_Candidate.IP) then
            raise Definition_Error with "Duplicated ES IP.";
         end if;
      end Validation;

   begin

      ES_Candidate := new Object'
        (ID  => ID,
         MAC => Eth.Parse(MAC),
         IP  => IPv4.Parse(IP));

      Object_Pool.Iterate(Validation'Access);

      Object_Pool.Insert
        (Key      => ES_Candidate.ID,
         New_Item => ES_Candidate);

      if ES_Candidate.MAC = Network.Link.Address then
         This_Object := ES_Candidate;
      end if;

   end Add;


   -------------
   -- Iterate --
   -------------

   procedure Iterate (Action : in Action_Procedure) is
   begin
      Object_Pool.Iterate(Action);
   end Iterate;


   -----------
   -- Items --
   -----------

   function Items return NATURAL is
   begin
      return Natural(Object_Pool.Length);
   end Items;
   pragma Inline(Items);

end AFDX.End_Systems.Pool;
