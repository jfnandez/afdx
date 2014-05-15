package body AFDX.End_Systems.Pool is


   Object_Pool : ID_Map;

   Device_ES   : Object_Acc := null;


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
      Cursor : constant ID_Maps.Cursor := Object_Pool.Find(ID);
   begin
      if ID_Maps.Has_Element(Cursor) then
         return ID_Maps.Element(Cursor);
      else
         raise Not_Found;
      end if;
   end Retrieve;


   ---------
   -- Add --
   ---------

   procedure Add (ID : in ID_Range; MAC : in STRING; IP : in STRING) is

      ES_Candidate : Object_Acc;

      procedure Validation (Position : ID_Maps.Cursor) is
         ES_Inserted : constant Object_Acc := ID_Maps.Element(Position);
         use type Eth.Address;
         use type IPv4.Address;
      begin
         if    (ES_Inserted.ID = ES_Candidate.ID) then
            raise Definition_Error with "ES ID already used.";
         elsif (ES_Inserted.MAC = ES_Candidate.MAC) then
            raise Definition_Error with "ES MAC already used.";
         elsif (ES_Inserted.IP = ES_Candidate.IP) then
            raise Definition_Error with "ES IP already used.";
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

      if ES_Candidate.Its_Me then
         Device_IP := ES_Candidate.IP;
         Device_ES := ES_Candidate;
      end if;

   end Add;


   -------------
   -- Iterate --
   -------------

   procedure Iterate (Action : in Action_Procedure) is
   begin
      Object_Pool.Iterate(Action);
   end Iterate;


   ------------
   -- Number --
   ------------

   function Number return Natural is
   begin
      return Natural(Object_Pool.Length);
   end Number;
   pragma Inline(Number);


   ----------
   -- This --
   ----------

   function This return Object_Acc  is
   begin
      return Device_ES;
   end This;
   pragma Inline(This);


end AFDX.End_Systems.Pool;
