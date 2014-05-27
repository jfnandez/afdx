package body Network.Stack.Down.Eth.V_LAN is

   package V_LANH renames Network.Defs.Eth.V_LAN;

   function Push
     (Header      : in Defs.Eth.V_LAN.Header;
      Message     : in Stream_Element_Array) return Stream_Element_Array
   is
      Result : Stream_Element_Array(0 .. Message'Length + V_LANH.Header_Size - 1);
   begin

      Result(0 .. V_LANH.Header_Size - 1) := Header.To_Stream;
      Result(V_LANH.Header_Size .. Result'Last) := Message;

      return Result;

   end Push;

end Network.Stack.Down.Eth.V_LAN;
