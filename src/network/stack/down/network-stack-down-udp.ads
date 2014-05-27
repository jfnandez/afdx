with Network.Defs.UDP.Headers;
with Network.Defs.IPv4;

package Network.Stack.Down.UDP is

   pragma Pure;

   function Push
     (Header      : in Defs.UDP.Headers.Header;
      Source      : in Defs.IPv4.Address;
      Destination : in Defs.IPv4.Address;
      Message     : in Stream_Element_Array) return Stream_Element_Array;

end Network.Stack.Down.UDP;
