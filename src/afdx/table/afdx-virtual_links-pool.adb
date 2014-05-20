with AFDX.End_Systems.Pool;

package body AFDX.Virtual_Links.Pool is

   Object_Pool     : Maps.Map; -- All VL
   Object_Pool_In  : Maps.Map; -- Inbound VL
   Object_Pool_Out : Maps.Map; -- Outbound VL

   ---------
   -- Add --
   ---------

   procedure Add
     (ID          : in ID_Range;
      BAG         : in BAG_Enum;
      Priority    : in Prio_Enum;
      Lmax        : in Positive;
      IP          : in STRING;
      Source      : in End_Systems.ID_Range;
      Destination : in End_Systems.ID_Array;
      TX_Size     : in Sub_Virtual_Link_Size;
      RX_Size     : in Sub_Virtual_Link_Size)
   is
      VL_Candidate   : Object_Acc;
      Destination_ES : End_Systems.Object_Acc;
      Destination_ID : End_Systems.ID_Range;

   begin


      if ((Destination'Length /= 1) or (IP /= "")) then
         raise Program_Error with "Multicast not implemented.";
      end if;


      if Contains(ID) then
         raise Definition_Error with "VL ID already defined.";
      end if;

      VL_Candidate        := new Object;
      VL_Candidate.ID     := ID;
      VL_Candidate.BAG    := BAG;
      VL_Candidate.Prio   := Priority;
      VL_Candidate.Lmax   := Lmax;

      VL_Candidate.Src    := End_Systems.Pool.Retrieve(Source);
      VL_Candidate.Is_Src := VL_Candidate.Src.Its_Me;

      VL_Candidate.Is_Des := False;

      for I in Destination'Range loop

         Destination_ID := Destination(I);
         Destination_ES := End_Systems.Pool.Retrieve(Destination_ID);

         VL_Candidate.Is_Des := VL_Candidate.Is_Des or Destination_ES.Its_Me;

         if not VL_Candidate.Des.Contains(Destination_ID) then
            VL_Candidate.Des.Insert
              (Key      => Destination_ID,
               New_Item => Destination_ES);
         else
            raise Definition_Error with "Duplicated Destination End System ID";
         end if;

      end loop;


      case (Destination'Length) is
         when 1 =>
            VL_Candidate.IP := VL_Candidate.Src.IP;
         when 2 .. AFDX.Max_Number_Of_Virtual_Links =>
            VL_Candidate.IP := Network.Defs.IPv4.Parse(IP);
         when others => raise Program_Error;
      end case;


      VL_Candidate.Sub_VL := new Sub_Virtual_Link_Object;

      for I in Sub_Virtual_Link_Range loop

         VL_Candidate.Sub_VL.List(I) := ((TX_Size(I) > 0) and (RX_Size(I) > 0));
         VL_Candidate.Sub_VL.TX_Size(I) := TX_Size(I);
         VL_Candidate.Sub_VL.RX_Size(I) := RX_Size(I);

         if ((TX_Size(I) = 0) xor (RX_Size(I) = 0)) then
            raise Definition_Error with "Sub Virtual Links buffer size error.";
         end if;

      end loop;

      Object_Pool.Insert
        (Key      => VL_Candidate.ID,
         New_Item => VL_Candidate);

      if VL_Candidate.Is_Src then
         Object_Pool_Out.Insert
           (Key      => VL_Candidate.ID,
            New_Item => VL_Candidate);
      end if;

      if VL_Candidate.Is_Des then
         Object_Pool_In.Insert
           (Key      => VL_Candidate.ID,
            New_Item => VL_Candidate);
      end if;


   exception
      when End_Systems.Pool.Not_Found =>
         raise Definition_Error with "Virtual Link uses a non defined ES.";
   end Add;


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


   --------------
   -- Contains --
   --------------

   function Contains(ID : in ID_Range) return Boolean is
   begin
      return Object_Pool.Contains(ID);
   end Contains;


   -------------
   -- Iterate --
   -------------

   procedure Iterate (Action : in Action_Procedure) is
   begin
      Object_Pool.Iterate(Action);
   end Iterate;


   ---------------
   -- Iterate_In --
   ----------------

   procedure Iterate_In (Action : in Action_Procedure) is
   begin
      Object_Pool_In.Iterate(Action);
   end Iterate_In;


   -----------------
   -- Iterate_Out --
   -----------------

   procedure Iterate_Out (Action : in Action_Procedure) is
   begin
      Object_Pool_Out.Iterate(Action);
   end Iterate_Out;

   -----------
   -- Items --
   --------------

   function Items  return Natural is
   begin
      return Natural(Object_Pool.Length);
   end Items;

   --------------
   -- Items_In --
   --------------

   function Items_In  return Natural is
   begin
      return Natural(Object_Pool_In.Length);
   end Items_In;


   ---------------
   -- Items_Out --
   ---------------
   function Items_Out return Natural is
   begin
      return Natural(Object_Pool_Out.Length);
   end Items_Out;

begin

      Put_Line("AFDX-VL-Pool Ready");

end AFDX.Virtual_Links.Pool;
