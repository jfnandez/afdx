with AFDX.Virtual_Links.Pool;

package body AFDX.Ports.Pool is


   Object_Pool          : Maps.Map;
   Object_Pool_QUEUEING : Maps.Map;
   Object_Pool_SAMPLING : Maps.Map;


   ---------
   -- Add --
   ---------

   procedure Add
     (Port                   : in Port_Range;
      Mode                   : in Port_Type;
      Virtual_Link           : in Virtual_Links.ID_Range;
      Sub_Virtual_Link_ID : in Virtual_Links.Sub_Virtual_Link_Range)
   is
      Port_Candidate : Object_Acc;
   begin

      if Object_Pool.Contains(Port) then
         raise Definition_Error with "Port already defined.";
      end if;

      Port_Candidate := new Object'
        (Port   => Port,
         Mode   => Mode,
         VL     => Virtual_Links.Pool.Retrieve(Virtual_Link),
         SVL_ID => Sub_Virtual_Link_ID);

      if not Port_Candidate.VL.Sub_Virtual_Link.Contains(Sub_Virtual_Link_ID) then
         raise Definition_Error with "Invalid Sub Virtual Link.";
      end if;


      Object_Pool.Insert
        (Key      => Port_Candidate.Port,
         New_Item => Port_Candidate);

      case Mode is
         when QUEUEING =>
            Object_Pool_QUEUEING.Insert
              (Key      => Port_Candidate.Port,
               New_Item => Port_Candidate);
         when SAMPLING =>
            Object_Pool_SAMPLING.Insert
              (Key      => Port_Candidate.Port,
               New_Item => Port_Candidate);
      end case;

   exception
      when Virtual_Links.Pool.Not_Found =>
         raise Definition_Error with "Associated Virtual Link not defined.";
   end Add;


   --------------
   -- Contains --
   --------------

   function Contains (Port : in Port_Range) return BOOLEAN is
   begin
      return Object_Pool.Contains(Port);
   end Contains;


   --------------
   -- Retrieve --
   --------------

   function Retrieve (Port : in Port_Range) return Object_Acc is
      Cursor : constant Maps.Cursor := Object_Pool.Find(Port);
   begin
      if Maps.Has_Element(Cursor) then
         return Maps.Element(Cursor);
      else
         raise Not_Found;
      end if;
   end Retrieve;


   -------------
   -- Iterate --
   -------------

   procedure Iterate (Action : in Action_Procedure) is
   begin
      Object_Pool.Iterate(Action);
   end Iterate;


   ---------------
   -- Iterate_QUEUEING --
   ----------------

   procedure Iterate_QUEUEING (Action : in Action_Procedure) is
   begin
      Object_Pool_QUEUEING.Iterate(Action);
   end Iterate_QUEUEING;


   -----------------
   -- Iterate_SAMPLING --
   -----------------

   procedure Iterate_SAMPLING (Action : in Action_Procedure) is
   begin
      Object_Pool_SAMPLING.Iterate(Action);
   end Iterate_SAMPLING;

   -----------
   -- Items --
   --------------

   function Items  return Natural is
   begin
      return Natural(Object_Pool.Length);
   end Items;

   --------------
   -- Items_QUEUEING --
   --------------

   function Items_QUEUEING  return Natural is
   begin
      return Natural(Object_Pool_QUEUEING.Length);
   end Items_QUEUEING;


   ---------------
   -- Items_SAMPLING --
   ---------------
   function Items_SAMPLING return Natural is
   begin
      return Natural(Object_Pool_SAMPLING.Length);
   end Items_SAMPLING;


end AFDX.Ports.Pool;
