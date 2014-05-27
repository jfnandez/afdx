with Network.Defs.IPv4.Headers;
with Stream_Buffers;

package Network.Stack.Down.IPv4 is

   pragma Pure;

   type Error is (Success, Fragmentation, Size, Unknown);

   procedure Push
     (Header          : in     Defs.IPv4.Headers.Header;
      Storage         : access Stream_Buffers.Stream_Buffer;
      Max_Packet_Size : in     Stream_Element_Count;
      Fragmentable    : in     Boolean;
      Message         : in     Stream_Element_Array;
      Total_Packets   :    out Natural;
      Result          :    out Error);

end Network.Stack.Down.IPv4;
