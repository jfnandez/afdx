with AFDX.Virtual_Links.Pool;

package body AFDX.Ports.Pool is


   Object_Pool : Port_Map;


   ---------
   -- Add --
   ---------

   procedure Add
     (Port             : in Port_Range;
      Mode             : in Port_Type;
      Virtual_Link     : in Virtual_Links.ID_Range;
      Sub_Virtual_Link : in Virtual_Links.SVL_Range)
   is
      Port_Candidate : Object_Acc;
   begin

      if not Object_Pool.Contains(Port) then

         Port_Candidate := new Object'
           (Port => Port,
            Mode => Mode,
            VL   => Virtual_Links.Pool.Retrieve(Virtual_Link),
            SVL  => Sub_Virtual_Link);

         if not Port_Candidate.VL.SVL_Defined(Sub_Virtual_Link) then
            raise Definition_Error with "Invalid Sub Virtual Link.";
         end if;


         Object_Pool.Insert
           (Key      => Port_Candidate.Port,
            New_Item => Port_Candidate);
      else
         raise Definition_Error with "Port already defined.";
      end if;

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
      Cursor : constant Port_Maps.Cursor := Object_Pool.Find(Port);
   begin
      if Port_Maps.Has_Element(Cursor) then
         return Port_Maps.Element(Cursor);
      else
         raise Not_Found;
      end if;
   end Retrieve;


end AFDX.Ports.Pool;
