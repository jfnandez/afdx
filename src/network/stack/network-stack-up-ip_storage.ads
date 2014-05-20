with Network.Defs.IPv4;

package Network.Stack.Up.IP_Storage is

   type Object (Size : Stream_Element_Count) is tagged limited private;
   type Object_Acc is access all Object'Class;

   procedure Put
     (This        : in out Object;
      Stream      : in     Stream_Element_Array;
      Offset      : in     Stream_Element_Count;
      MF_Flag     : in     Boolean;
      Is_Ready    :    out Boolean);

   function Get
     (This        : in Object) return Stream_Element_Array;

   function Find
     (Source      : in IPv4.Address;
      Destination : in IPv4.Address;
      Identifier  : in Unsigned_16) return Object_Acc;

   function Acceptable_IP
     (Destination : in IPv4.Address) return Boolean;

private

   type Object (Size : Stream_Element_Count) is tagged limited
      record
         Stored   : Stream_Element_Count := 0;
         Total    : Stream_Element_Count := 0;
         Buffer   : Stream_Element_Array(1 .. Size);
      end record;

end Network.Stack.Up.IP_Storage;
