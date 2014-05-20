with Network.Defs.UDP;
with Network.Stack.Up.UDP_Storage;

package body Network.Stack.Up.UDP is

   procedure Put (UDP_Stream : Stream_Element_Array) is

      First : Stream_Element_Offset;
      Last  : Stream_Element_Offset;

      UDP_Header       : Defs.UDP.Header;
      Source_Port      : Unsigned_16;
      Destination_Port : Unsigned_16;
      Length           : Unsigned_16;
      Checksum         : Unsigned_16;

   begin

      First := UDP_Stream'First;
      Last  := First + Defs.UDP.Header_Size - 1;

      UDP_Header.Set(UDP_Stream(First .. Last));

      UDP_Header.Get
        (Src_Port => Source_Port,
         Des_Port => Destination_Port,
         Length   => Length,
         Checksum => Checksum);

      Length := Length - Defs.UDP.Header_Size;

      First := Last + 1;
      Last  := First + Stream_Element_Count(Length) - 1;

      UDP_Storage.Put
        (Stream           => UDP_Stream(First .. Last),
         Source_Port      => Source_Port,
         Destination_Port => Destination_Port);

   end Put;

end Network.Stack.Up.UDP;
