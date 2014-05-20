with Ada.Containers.Ordered_Maps;
with AFDX.Ports.Pool;

package body AFDX.In_Buffers.Pool is


   package Maps is new Ada.Containers.Ordered_Maps
     (Key_Type     => Ports.Port_Range,
      "<"          => Ports."<",
      Element_Type => Object_Acc,
      "="          => "=");

   Map : Maps.Map;

   function Retrieve
     (Port : in Ports.Port_Range) return Object_Acc
   is
      Cursor : constant Maps.Cursor := Map.Find(Port);
   begin
      if Maps.Has_Element(Cursor) then
         return Maps.Element(Cursor);
      else
         return null;
      end if;
   end Retrieve;

   function Contains
     (Port : in Ports.Port_Range) return Boolean
   is
   begin
      return Map.Contains(Port);
   end Contains;




   procedure Create
     (Cursor : Ports.Maps.Cursor)
   is
      Port        : Ports.Object_Acc;
      Buffer      : Object_Acc;
      Buffer_Size : Stream_Element_Count;
   begin

      Port := Ports.Maps.Element(Cursor);

      if  Port.Virtual_Link.Is_Destination then

         case (Port.Mode) is

         when Ports.QUEUEING =>

            Buffer_Size := Stream_Element_Count
              (Port.Virtual_Link.Sub_Virtual_Link.RX_Size
                (Port.Sub_Virtual_Link));

            Buffer := new In_Buffers.Queueing_Object(Buffer_Size);

         when Ports.SAMPLING =>

            Buffer_Size := Stream_Element_Count
              (Port.Virtual_Link.Lmax);

            Buffer := new In_Buffers.Sampling_Object(Buffer_Size);

         end case;

         Map.Insert
           (Key      => Port.Port,
            New_Item => Buffer);

      end if;

   end Create;


begin

   Ports.Pool.Iterate(Create'Access);
   Put_Line("AFDX-IN_Buffer-Pool Ready");

end AFDX.In_Buffers.Pool;
