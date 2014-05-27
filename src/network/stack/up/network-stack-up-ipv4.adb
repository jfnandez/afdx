with Ada.Containers.Ordered_Maps;

with Network.Defs.IPv4.Headers;
with Network.Stack.Up.UDP;

package body Network.Stack.Up.IPv4 is

   type Search_Object is
      record
         Source      : Defs.IPv4.Address;
         Destination : Defs.IPv4.Address;
         Identifier  : Unsigned_16;
      end record;

   function "<" (Left, Right : in Search_Object) return Boolean is
      use type Network.Defs.IPv4.Address;
   begin
      return
        (Left.Source      < Right.Source)      and
        (Left.Destination < Right.Destination) and
        (Left.Identifier  < Right.Identifier);
   end "<";

   ---------------------------------

   type Storage_Object (Size : Stream_Element_Count) is
      record
         Stored   : Stream_Element_Count := 0;
         Total    : Stream_Element_Count := 0;
         Buffer   : Stream_Element_Array(1 .. Size);
      end record;

   type Storage_Object_Acc is access all Storage_Object;


   procedure Store
     (This           : in     Storage_Object_Acc;
      Stream         : in     Stream_Element_Array;
      Offset         : in     Stream_Element_Offset;
      More_Fragments : in     Boolean;
      Is_Ready       :    out Boolean)
   is
      Length : constant Stream_Element_Count  := Stream'Length;
   begin

      Is_Ready := False;

      if (This.Stored /= Offset) then
         This.Total  := 0;
         This.Stored := 0;
      else

         This.Buffer(Offset + 1 .. Offset + Length) := Stream;
         This.Stored := This.Stored + Length;

         if not More_Fragments then
            Is_Ready    := True;
            This.Total  := This.Stored;
            This.Stored := 0;
         end if;

      end if;

   end Store;


   function Get (This : in Storage_Object_Acc) return Stream_Element_Array is
   begin
      return This.Buffer(1 .. This.Total);
   end Get;


   -------

   package Maps is new Ada.Containers.Ordered_Maps
     (Key_Type     => Search_Object,
      Element_Type => Storage_Object_Acc,
      "<"          => "<",
      "="          => "=");

   Map : Maps.Map;

   -------

   procedure Enable
     (Source      : in Defs.IPv4.Address;
      Destination : in Defs.IPv4.Address;
      Identifier  : in Unsigned_16;
      Buffer_Size : in Stream_Element_Count)
   is
      Key    : constant Search_Object :=
        (Source      => Source,
         Destination => Destination,
         Identifier  => Identifier);

      Cursor : constant Maps.Cursor := Map.Find(Key);
   begin

      if (not Maps.Has_Element(Cursor)) and (Buffer_Size > 0) then
         Map.Insert
           (Key      => Key,
            New_Item => new Storage_Object(Buffer_Size));
      end if;

   end Enable;

   function Find
     (Source      : in Defs.IPv4.Address;
      Destination : in Defs.IPv4.Address;
      Identifier  : in Unsigned_16) return Storage_Object_Acc
   is

      Cursor : constant Maps.Cursor := Map.Find
        (Search_Object'
           (Source      => Source,
            Destination => Destination,
            Identifier  => Identifier));

   begin

      if Maps.Has_Element(Cursor) then
         return Maps.Element(Cursor);
      else
         return null;
      end if;

   end Find;



   procedure Push (IPv4_Stream : Stream_Element_Array)
   is

      Header   : Defs.IPv4.Headers.Header;

      Deliver  : Stream_Procesing;
      First    : Stream_Element_Offset;
      Last     : Stream_Element_Offset;
      Buffer   : Storage_Object_Acc;
      Is_Ready : Boolean;

      use type Network.Unsigned_13;

   begin

      First := IPv4_Stream'First;
      Last  := First + Defs.IPv4.Headers.Header_Size - 1;

      Header.To_Header(Stream => IPv4_Stream(First .. Last));

      Buffer := Find
        (Source      => Header.Source,
         Destination => Header.Destination,
         Identifier  => Header.Identification);

      if (Buffer = null) then
         return;
      end if;

      First := IPv4_Stream'First + 4*Stream_Element_Count(Header.Header_Length);
      Last  := IPv4_Stream'First +   Stream_Element_Count(Header.Total_Length)  - 1;

      case Header.Protocol is
         when Defs.IPv4.UDP => Deliver := UDP.Push'Access;
         when others   => Deliver := Sink'Access;
      end case;


      if (Header.Fragment_Offset = 0) and (not Header.More_Fragments) then -- Single IP Frame, not fragmented

         Deliver(IPv4_Stream(First .. Last));

      else

         Store
           (This => Buffer,
            Stream         => IPv4_Stream(First .. Last),
            Offset         => 8*Stream_Element_Count(Header.Fragment_Offset),
            More_Fragments => Header.More_Fragments,
            Is_Ready       => Is_Ready);

         if Is_Ready then
            Deliver(Get(Buffer));
         end if;

      end if;

   end Push;

end Network.Stack.Up.IPv4;
