with AFDX.Definitions;

with Network.Defs;
with Network.Defs.UDP;
with Network.Defs.UDP.Headers;
with Network.Defs.Eth.Headers;
with Network.Defs.Eth.V_LAN;
with Network.Defs.IPv4.Headers;

with Stream_Buffers;

package AFDX.Virtual_Links.Queues is

   type Object is limited private;
   type Object_Acc is access all Object;

   type Queued_Event is tagged limited private;
   type Queued_Event_Acc is access all Queued_Event'Class;

private

   type Buffer_Array is array (Sub_Virtual_Link_Range) of
     access Stream_Buffers.Stream_Buffer;

   type Header_Pack is
      record
         Eth  : Network.Defs.Eth.Headers.Header;
         VLAN : Network.Defs.Eth.V_LAN.Header;
         IP   : Network.Defs.IPv4.Headers.Header;
         UDP  : Network.Defs.UDP.Headers.Header;
      end record;

   ------------
   -- Object --
   ------------

   protected type Object is

      pragma Priority(AFDX.Outbound_Buffer_Ceil_Prio);

      procedure Initialize
        (ID : in Virtual_Links.ID_Range);

      procedure Put -- Raises AFDX.Overflow
        (Message          : in     Stream_Element_Array;
         Source_Port      : in     Network.Defs.UDP.Port;
         Destination_Port : in     Network.Defs.UDP.Port;
         Sub_Virtual_Link : in     Sub_Virtual_Link_Range;
         Identifier       : in     Unsigned_16;
         Fragmentable     : in     Boolean;
         Total_Packets    :    out Natural);

      procedure Get -- Raises AFDX.Underflow
        (Datagram  : out Stream_Element_Array;
         Last      : out Stream_Element_Offset);

   private
      Max_Packet_Size : Stream_Element_Count;
      Virtual_Link    : Virtual_Links.Object_Acc;
      Buffer_Pointer  : Sub_Virtual_Link_Range;
      Buffers         : Buffer_Array;
      Headers         : Header_Pack;
   end Object;


   type Queued_Event is tagged limited
      record
         At_Time      : Time;
         Period       : Time_Span;
         Queue        : Object_Acc;
         Remaining    : Natural;
         Virtual_Link : Virtual_Links.Object_Acc;
      end record;

end AFDX.Virtual_Links.Queues;
