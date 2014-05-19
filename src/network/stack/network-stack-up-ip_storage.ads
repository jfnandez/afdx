with Network.Defs.IPv4;
with Network.Stack.Up.IP_Buffers;

package Network.Stack.Up.IP_Storage is

   function Find
     (IP : in IPv4.Address;
      ID : in  Unsigned_16) return IP_Buffers.Object_Acc;

   function Acceptable_IP (IP : in IPv4.Address) return BOOLEAN;

end Network.Stack.Up.IP_Storage;
