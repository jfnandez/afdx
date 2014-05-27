package body Network.Stack.Down.Eth is

   package EthH renames Network.Defs.Eth.Headers;

   function Push
     (Header  : in Defs.Eth.Headers.Header;
      Message : in Stream_Element_Array) return Stream_Element_Array
   is
      Result : Stream_Element_Array(0 .. Message'Length + EthH.Header_Size - 1);
   begin

      Result(0 .. EthH.Header_Size - 1)       := Header.To_Stream;
      Result(EthH.Header_Size .. Result'Last) := Message;

      return Result;

   end Push;

end Network.Stack.Down.Eth;
