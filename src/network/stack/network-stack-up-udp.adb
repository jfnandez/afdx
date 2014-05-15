with Network.Defs.UDP;
with Network.Stack.Up.UDP_Storage;

package body Network.Stack.Up.UDP is

   procedure Put (UDP_Stream : Stream_Element_Array) is

      First : Stream_Element_Offset;
      Last  : Stream_Element_Offset;

      UDP_Hdr  : Defs.UDP.Header;
      Src_Port : Unsigned_16;
      Des_Port : Unsigned_16;
      Length   : Unsigned_16;
      Checksum : Unsigned_16;

   begin

      First := UDP_Stream'First;
      Last  := First + Defs.UDP.Header_Size - 1;

      UDP_Hdr.Set(UDP_Stream(First .. Last));

      UDP_Hdr.Get
        (Src_Port => Src_Port,
         Des_Port => Des_Port,
         Length   => Length,
         Checksum => Checksum);

      Length := Length - Defs.UDP.Header_Size;

      First := Last + 1;
      Last  := First + Stream_Element_Count(Length) - 1;

      UDP_Storage.Put
        (Stream   => UDP_Stream(First .. Last),
         Src_Port => Src_Port,
         Des_Port => Des_Port);

   end Put;

end Network.Stack.Up.UDP;
