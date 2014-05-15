with AFDX.End_Systems.Pool;

package body AFDX.Virtual_Links.Pool is

   Object_Pool_In  : ID_Map; -- Inbound VL
   Object_Pool_Out : ID_Map; -- Outbound VL
   Object_Pool_All : ID_Map; -- All VL


   ---------
   -- Add --
   ---------

   procedure Add
     (ID       : in ID_Range;
      BAG      : in BAG_Enum;
      Priority : in Prio_Enum;
      Lmax     : in Positive;
      IP       : in STRING;
      Src      : in End_Systems.ID_Range;
      Des      : in End_Systems.ID_Array;
      TX_Sizes : in SVL_Size;
      RX_Sizes : in SVL_Size)
   is
      VL_Candidate : Object_Acc;
      Final_IP     : IPv4.Address;
      Des_ES      : End_Systems.Object_Acc;

   begin

      if not Contains(ID) then

         if (IP = "") and (Des'Length = 2) then
            Des_ES  := End_Systems.Pool.Retrieve(Des(Des'First+1));
            Final_IP := Des_ES.IP;

         elsif (Des'Length > 2) then
            Final_IP := Ipv4.Parse(IP);
         else
            raise Definition_Error with "Invalid Virtual Link IP";
         end if;

         VL_Candidate := new Object'
           (ID       => ID,
            BAG      => BAG,
            Priority => Priority,
            Lmax     => Lmax,
            IP       => Final_IP,
            Source   => End_Systems.Pool.Retrieve(Src),
            Dest_Map => null,
            Is_Dest  => False,
            SVLs     => (others => False),
            TX_Size => TX_Sizes,
            RX_Size => RX_Sizes);


         Sub_Virtual_Links:
         for SVL in SVL_Range loop

            if (TX_Sizes(SVL) > 0) and (RX_Sizes(SVL) > 0) then
               VL_Candidate.SVLs(SVL) := True;
            elsif (TX_Sizes(SVL) > 0) xor (RX_Sizes(SVL) > 0) then
               raise Definition_Error with "Invalid SVL buffer sizes.";
            end if;

         end loop Sub_Virtual_Links;


         VL_Candidate.Dest_Map := new End_Systems.Pool.ID_Map;

         for I in (Des'First+1) .. Des'Last loop

            Des_ES := End_Systems.Pool.Retrieve(Des(I));

            if Des_Es.Its_Me then
               VL_Candidate.Is_Dest := True;
            end if;

            if not VL_Candidate.Dest_Map.Contains(Des_Es.ID) then
               VL_Candidate.Dest_Map.Insert
                 (Key      => Des_ES.ID,
                  New_Item => Des_ES);
            end if;

         end loop;

         Object_Pool_All.Insert
           (Key      => VL_Candidate.ID,
            New_Item => VL_Candidate);

         if VL_Candidate.Source.Its_Me then
            Object_Pool_Out.Insert
              (Key      => VL_Candidate.ID,
               New_Item => VL_Candidate);
         end if;

         if VL_Candidate.Is_Dest then
            Object_Pool_In.Insert
              (Key      => VL_Candidate.ID,
               New_Item => VL_Candidate);
         end if;

      else
         raise Definition_Error with "VL ID already defined.";
      end if;

   exception
      when End_Systems.Pool.Not_Found =>
         raise Definition_Error with "Associated ES not defined.";
   end Add;


   --------------
   -- Retrieve --
   --------------

  function Retrieve (ID : in ID_Range) return Object_Acc is
      Cursor : constant ID_Maps.Cursor := Object_Pool_All.Find(ID);
   begin
      if ID_Maps.Has_Element(Cursor) then
         return ID_Maps.Element(Cursor);
      else
         raise Not_Found;
      end if;
   end Retrieve;


   --------------
   -- Contains --
   --------------

   function Contains(ID : in ID_Range) return BOOLEAN is
   begin
      return Object_Pool_All.Contains(ID);
   end Contains;


   ----------------
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


   -----------------
   -- Iterate_All --
   -----------------

   procedure Iterate_All (Action : in Action_Procedure) is
   begin
      Object_Pool_All.Iterate(Action);
   end Iterate_All;


   ---------------
   -- Number_In --
   ---------------

   function Number_In  return Natural is
   begin
      return Natural(Object_Pool_In.Length);
   end Number_In;


   ----------------
   -- Number_Out --
   ----------------
   function Number_Out return Natural is
   begin
      return Natural(Object_Pool_Out.Length);
   end Number_Out;


   ----------------
   -- Number_All --
   ----------------
   function Number_All return Natural is
   begin
      return Natural(Object_Pool_All.Length);
   end Number_All;

end AFDX.Virtual_Links.Pool;
