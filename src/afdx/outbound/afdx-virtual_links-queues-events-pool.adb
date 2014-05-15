with AFDX.Definitions;
with AFDX.Virtual_Links.Pool;

package body AFDX.Virtual_Links.Queues.Events.Pool is

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

   procedure Create (Cursor : in Virtual_Links.Pool.ID_Maps.Cursor) is

      Virt_Link : constant Virtual_Links.Object_Acc :=
        Virtual_Links.Pool.ID_Maps.Element(Cursor);

      New_Event : constant Object_Acc := new Object;
   begin

      --pragma Debug("Creando evento de salida para el Virtual Link" & Virt_Link.ID'Img);

      New_Event.At_Time   := Time_First;
      New_Event.Period    := BAG_To_Milliseconds(Virt_Link.BAG);
      New_Event.Remaining := 0;
      New_Event.Virt_Link := Virt_Link;
      New_Event.Buffer    := new Virtual_Links.Queues.Object;

      New_Event.Buffer.Initialize(Virt_Link);

      Object_Pool.Insert
        (Key      => Virt_Link.ID,
         New_Item => New_Event);

   end Create;


begin

   Virtual_Links.Pool.Iterate_Out(Create'Access);

end AFDX.Virtual_Links.Queues.Events.Pool;
