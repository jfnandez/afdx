with Ada.Containers.Ordered_Maps;
use  Ada.Containers;

with AFDX;
with AFDX.Virtual_Links;
with AFDX.Virtual_Links.Pool;
with AFDX.Definitions;

use AFDX;

package body Network.Stack.Up.IP_Storage is

   package ID_Maps is new Ordered_Maps
     (Key_Type     => Unsigned_16,
      Element_Type => IP_Buffers.Object_Acc,
      "<"          => "<",
      "="          => IP_Buffers."=");

   type ID_Map is new ID_Maps.Map with null record;
   type ID_Map_Acc is access all ID_Map;


   package IP_Maps is new Ordered_Maps
     (Key_Type     => IPv4.Address,
      Element_Type => ID_Map_Acc,
      "<"          => IPv4."<",
      "="          => "=");


   Accepting_IP_Map : IP_Maps.Map;

   -------------------
   -- Acceptable_IP --
   -------------------

   function Acceptable_IP (IP : in IPv4.Address) return BOOLEAN is
   begin
      return Accepting_IP_Map.Contains(IP);
   end Acceptable_IP;


   ----------
   -- Find --
   ----------

   function Find
     (IP : in IPv4.Address; ID : in  Unsigned_16) return IP_Buffers.Object_Acc
   is
      Cursor_IP    : IP_Maps.Cursor;
      Cursor_ID    : ID_Maps.Cursor;
      Assoc_ID_Map : ID_Map_Acc;
      Found_Buffer : IP_Buffers.Object_Acc := null;

   begin

      Cursor_IP := Accepting_IP_Map.Find(IP);

      if IP_Maps.Has_Element(Cursor_IP) then

         Assoc_ID_Map := IP_Maps.Element(Cursor_IP);

         Cursor_ID := Assoc_ID_Map.Find(ID);

         if ID_Maps.Has_Element(Cursor_ID) then
            Found_Buffer := ID_Maps.Element(Cursor_ID);
         end if;

      end if;

      return Found_Buffer;

   end Find;


   ------------
   -- Create --
   ------------

   procedure Create (Cursor : in Virtual_Links.Maps.Cursor) is

      VL : constant Virtual_Links.Object_Acc :=
        Virtual_Links.Maps.Element(Cursor);

      IP : constant Defs.IPv4.Address := VL.Destination_IP;

      Cursor_IP : constant IP_Maps.Cursor := Accepting_IP_Map.Find(IP);

      Assoc_Maps_Id : ID_Map_Acc;
      Identifier    : Unsigned_16;
      Buffer_Size   : Stream_Element_Count;

   begin

      if not IP_Maps.Has_Element(Cursor_IP) then

         --pragma Debug("Accepting IP: " & Defs.IPv4.To_String(IP));

         Assoc_Maps_Id := new ID_Map;

         Accepting_IP_Map.Insert
           (Key      => IP,
            New_Item => Assoc_Maps_Id);

      else
         Assoc_Maps_Id := IP_Maps.Element(Cursor_IP);
      end if;


      --pragma Debug("Buffer llegada IP para VL:" & VL.ID'Img & '.');

      for SVL in Virtual_Links.Sub_Virtual_Link_Range loop

         if VL.Sub_Virtual_Link.Contains(SVL) then

            --pragma Debug(" SVL:" & SVL'Img);

            Buffer_Size := Stream_Element_Count( VL.Sub_Virtual_Link.RX_Size(SVL));

            Identifier  := Virtual_Links.Gen_ID
              (VL  => VL.ID,
               SVL => SVL);

            Assoc_Maps_Id.Insert
              (Key      => Identifier,
               New_Item => new Up.IP_Buffers.Object(Buffer_Size));

         end if;

      end loop;

   end Create;


begin

   Virtual_Links.Pool.Iterate_In(Create'Access);

end Network.Stack.Up.IP_Storage;
