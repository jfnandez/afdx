with Ada.Containers.Ordered_Maps;

with Network.Defs.UDP.Headers;

package body Network.Stack.Up.UDP is


   package Maps is new Ada.Containers.Ordered_Maps
     (Key_Type     => Defs.UDP.Port,
      Element_Type => Storage_Acc,
      "<"          => "<",
      "="          => "=");

   Map : Maps.Map;


   procedure Associate (Port : in Defs.UDP.Port; Buffer : in Storage_Acc) is
   begin
      Map.Insert (Key => Port, New_Item => Buffer);
   end Associate;


   function Retrieve (Port : in Defs.UDP.Port) return Storage_Acc is
      Cursor : constant Maps.Cursor := Map.Find(Port);
   begin
      if Maps.Has_Element(Cursor) then
         return Maps.Element(Cursor);
      else
         return null;
      end if;
   end Retrieve;


   function Contains (Port : in Defs.UDP.Port) return Boolean is
      Cursor : constant Maps.Cursor := Map.Find(Port);
   begin
      return  Maps.Has_Element(Cursor);
   end Contains;


   procedure Push (UDP_Stream : Stream_Element_Array) is

      First : Stream_Element_Offset;
      Last  : Stream_Element_Offset;

      Header : Defs.UDP.Headers.Header;
      Cursor     : Maps.Cursor;
   begin

      First := UDP_Stream'First;
      Last  := First + Defs.UDP.Headers.Header_Size - 1;

      Header.To_Header(Stream => UDP_Stream(First .. Last));

      First := Last + 1;
      Last  := First + Stream_Element_Count(Header.Length - Defs.UDP.Headers.Header_Size) - 1;

      Cursor := Map.Find(Header.Des_Port);

      if Maps.Has_Element(Cursor) then
         Maps.Element(Cursor).Put(UDP_Stream(First .. Last));
      end if;

   end Push;

end Network.Stack.Up.UDP;
