with Network.Defs.IPv4;

package Network.Stack.Up.IPv4 is

   procedure Enable
     (Source      : in Defs.IPv4.Address;
      Destination : in Defs.IPv4.Address;
      Identifier  : in Unsigned_16;
      Buffer_Size : in Stream_Element_Count);

   procedure Push (IPv4_Stream : Stream_Element_Array);

end Network.Stack.Up.IPv4;
