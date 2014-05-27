package body Network.Stack.Down.UDP is

   package UDPH renames Network.Defs.UDP.Headers;

   function Push
     (Header      : in Defs.UDP.Headers.Header;
      Source      : in Defs.IPv4.Address;
      Destination : in Defs.IPv4.Address;
      Message     : in Stream_Element_Array) return Stream_Element_Array
   is
      Result : Stream_Element_Array(0 .. Message'Length + UDPH.Header_Size - 1);
   begin

      Result(0 .. UDPH.Header_Size - 1) := Header.To_Stream
        (Source      => Source,
         Destination => Destination,
         Payload     => Message);

      Result(UDPH.Header_Size .. Result'Last) := Message;

      return Result;

   end Push;

end Network.Stack.Down.UDP;
