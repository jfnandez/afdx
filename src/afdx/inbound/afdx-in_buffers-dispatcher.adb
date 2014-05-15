with AFDX.Table.End_Systems;
with AFDX.Table.Virtual_Links;
with Ada.Containers.Ordered_Sets;

package body AFDX.In_Buffers.Dispatcher is

   package Object_Set is new Ada.Containers.Ordered_Sets
     (Element_Type => Network.Eth.IPv4.Address,
      "<" => Network.Eth.IPv4."<",
      "=" => Network.Eth.IPv4."=");

   Set : Object_Set.Set;

   ------------------
   -- Listening_To --
   ------------------

   function Listening_To (ID : in Network.Eth.IPv4.Address) return Boolean is
   begin

      if Network.Eth.IPv4."="(ID, End_Systems.This.IP) or
         Network.Eth.IPv4."="(ID, Network.Eth.IPv4.Broadcast) then
         return True;
      end if;

      if Network.Eth.IPv4.Is_Multicast(ID) then
         return Set.Contains(ID);
      else
         return False;
      end if;

   end Listening_To;
   pragma Inline (Listening_To);



   procedure Create (ID : in Virtual_Links.ID_Range) is
      VL   : constant Virtual_Links.Object_Acc := Virtual_Links.Retrieve(ID);
   begin
      if Network.Eth.IPv4.Is_Multicast(VL.IP) then
         Set.Insert(New_Item => VL.IP);
      end if;
   end Create;


begin

   Virtual_Links.Do_For_Receivers(Create'Access);

end AFDX.In_Buffers.Dispatcher;
