with Network.Defs.Eth.Headers;

package Network.Stack.Down.Eth is

   pragma Pure;

   function Push
     (Header  : in Defs.Eth.Headers.Header;
      Message : in Stream_Element_Array) return Stream_Element_Array;

end Network.Stack.Down.Eth;
