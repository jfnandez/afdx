with AFDX.Definitions;
with AFDX.Virtual_Links.Pool;

package body AFDX.Virtual_Links.Queues.Out_Buffers.Pool is


   package Maps is new Ada.Containers.Ordered_Maps
     (Key_Type     => ID_Range,
      Element_Type => Object_Acc,
      "<"          => "<",
      "="          => "=");


   Object_Pool : Maps.Map;


   --------------
   -- Contains --
   --------------

   function Contains (ID : in ID_Range) return Boolean is
   begin
      return Object_Pool.Contains(ID);
   end Contains;
   pragma Inline (Contains);


   --------------
   -- Retrieve --
   --------------

   function  Retrieve (ID : ID_Range) return Object_Acc is
   begin
      return Object_Pool.Element(ID);
   end Retrieve;


   ------------
   -- Create --
   -------------


   procedure Create (Cursor : in Virtual_Links.Maps.Cursor) is
      Event : constant Object_Acc := new Object;
   begin

      --pragma Debug("Creando evento de salida para el Virtual Link" & Virt_Link.ID'Img);

      Event.At_Time      := Time_First;
      Event.Remaining    := 0;
      Event.Virtual_Link := Virtual_Links.Maps.Element(Cursor);
      Event.Period       := BAG_To_Milliseconds(Event.Virtual_Link.BAG);
      Event.Queue        := new Virtual_Links.Queues.Object;

      Event.Queue.Initialize(Event.Virtual_Link.ID);

      Object_Pool.Insert
        (Key      => Event.Virtual_Link.ID,
         New_Item => Event);

   end Create;

begin

   Virtual_Links.Pool.Iterate_Out(Create'Access);
   Put_Line("AFDX-OUT_Buffer-Pool Ready");

end AFDX.Virtual_Links.Queues.Out_Buffers.Pool;
