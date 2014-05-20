with AFDX.Ports;

with Network.Defs;
with Network.Defs.UDP;
with Network.Defs.Eth.V_LAN;

with Stream_Buffers;

with AFDX.Definitions;

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
         Eth  : Network.Defs.Eth.Header;
         VLAN : Network.Defs.Eth.V_LAN.Header;
         IP   : Network.Defs.IPv4.Header;
         UDP  : Network.Defs.UDP.Header;
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
         Source_Port      : in     Ports.Port_Range;
         Destination_Port : in     Ports.Port_Range;
         Sub_Virtual_Link : in     Sub_Virtual_Link_Range;
         Identifier       : in     Unsigned_16;
         Frame_Payload    : in     Unsigned_16;
         Size_Required    : in     Unsigned_16;
         Inserted         :    out Boolean);

      procedure Get -- Raises AFDX.Underflow
        (Frame  : out Network.Defs.Frame);

   private
      Virtual_Link   : Virtual_Links.Object_Acc;
      Buffer_Pointer : Sub_Virtual_Link_Range;
      Buffers        : Buffer_Array;
      Headers        : Header_Pack;
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
