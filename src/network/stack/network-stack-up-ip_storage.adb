with Ada.Containers.Ordered_Maps;
with Ada.Containers.Ordered_Sets;
use  Ada.Containers;

with AFDX.Ports;
with AFDX.Ports.Pool;
with AFDX.Virtual_Links;
use  AFDX;

package body Network.Stack.Up.IP_Storage is

   use type Network.Defs.IPv4.Address;

   type Search_Object is
      record
         Source      : IPv4.Address;
         Destination : IPv4.Address;
         Identifier  : Unsigned_16;
      end record;

   function Search_Object_Comparator
     (Left, Right : in Search_Object) return Boolean
   is
   begin
      if (Left.Identifier < Right.Identifier) then
         return True;
      elsif (Left.Identifier > Right.Identifier) then
         return False;
      else
         if (Left.Source < Right.Source) then
            return True;
         elsif (Left.Source > Right.Source) then
            return False;
         else
            if (Left.Destination < Right.Destination) then
               return True;
            elsif (Left.Destination > Right.Destination) then
               return False;
            else
               return False;
            end if;
         end if;
      end if;
   end Search_Object_Comparator;

   package Buffer_Maps is new Ordered_Maps
     (Key_Type     => Search_Object,
      Element_Type => Object_Acc,
      "<"          => Search_Object_Comparator,
      "="          => "=");

   package IP_Sets is new Ordered_Sets
     (Element_Type => IPv4.Address,
      "<" => "<",
      "=" => "=");

   Buffer_Map : Buffer_Maps.Map;
   IP_Set     : IP_Sets.Set; -- Valid Destination IP Addresses.

   -------------------
   -- Acceptable_IP --
   -------------------

   function Acceptable_IP
     (Destination : in IPv4.Address) return Boolean
   is
   begin
      return IP_Set.Contains(Destination);
   end Acceptable_IP;


   ----------
   -- Find --
   ----------

   function Find
     (Source      : in IPv4.Address;
      Destination : in IPv4.Address;
      Identifier  : in  Unsigned_16) return Object_Acc
   is

      Cursor : constant Buffer_Maps.Cursor := Buffer_Map.Find
        (Search_Object'
           (Source      => Source,
            Destination => Destination,
            Identifier  => Identifier));

   begin

      if Buffer_Maps.Has_Element(Cursor) then
         return Buffer_Maps.Element(Cursor);
      else
         return null;
      end if;

   end Find;







   procedure Put
     (This     : in out Object;
      Stream   : in     Stream_Element_Array;
      Offset   : in     Stream_Element_Count;
      MF_Flag  : in     Boolean;
      Is_Ready :    out Boolean)
   is
      Length : constant Stream_Element_Count := Stream'Length;
   begin

      Is_Ready := False;

      if (This.Stored /= Offset) then

         This.Total  := 0;
         This.Stored := 0;
         --pragma Debug("Fragment not received in sequence");

      else

         This.Buffer(Offset+1 .. Offset+Length) := Stream;

         This.Stored := This.Stored + Length;

         if not MF_Flag then
            Is_Ready    := True;
            This.Total  := This.Stored;
            This.Stored := 0;
         end if;

      end if;

   end Put;


   function Get (This : in Object) return Stream_Element_Array is
   begin
      return This.Buffer(1 .. This.Total);
   end Get;


   ------------
   -- Create --
   ------------

   procedure Create (Cursor : in Ports.Maps.Cursor) is

      Port             : constant Ports.Object_Acc :=
        Ports.Maps.Element(Cursor);

      Virtual_Link     : constant Virtual_Links.Object_Acc :=
        Port.Virtual_Link;

      Sub_Virtual_Link : constant Virtual_Links.Sub_Virtual_Link_Object_Acc :=
        Virtual_Link.Sub_Virtual_Link;

      Buffer_Size      : constant Stream_Element_Count :=
        Stream_Element_Count(Sub_Virtual_Link.RX_Size(Port.Sub_Virtual_Link));

   begin

      if not Virtual_Link.Is_Destination then
         return;
      end if;

      IP_Set.Include(Virtual_Link.Destination_IP);

      --pragma Debug("Buffer llegada IP para VL:" & VL.ID'Img & '.');

         if Buffer_Size > 0 then

            --pragma Debug(" SVL:" & SVL'Img);

            Buffer_Map.Insert
              (Key      => Search_Object'
                 (Source      => Virtual_Link.Source_IP,
                  Destination => Virtual_Link.Destination_IP,
                  Identifier  => Unsigned_16(Port.Port)),
               New_Item => new Object(Buffer_Size));

         end if;

   end Create;


begin

   Ports.Pool.Iterate(Create'Access);

end Network.Stack.Up.IP_Storage;
