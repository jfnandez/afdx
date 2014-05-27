with Network.Defs.Eth.V_LAN;

package Network.Stack.Down.Eth.V_LAN is

   pragma Pure;

   function Push
     (Header      : in Defs.Eth.V_LAN.Header;
      Message     : in Stream_Element_Array) return Stream_Element_Array;

end Network.Stack.Down.Eth.V_LAN;
