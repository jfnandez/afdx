with AFDX.Ports;

with Network.Defs;
with Network.Defs.UDP;
with Network.Defs.Eth.V_LAN;

with Stream_Buffers;


package AFDX.Virtual_Links.Queues is

   type Object is limited private;
   type Object_Acc is access all Object;

   type Queued_Event is tagged limited private;
   type Queued_Event_Acc is access all Queued_Event'Class;

private


   type SVL_Array is array (Sub_Virtual_Link_Range) of access Stream_Buffers.Stream_Buffer;


   ------------
   -- Object --
   ------------

   protected type Object is

      pragma Priority(AFDX.Outbound_Buffer_Ceil_Prio);

      procedure Initialize (VL_Acc : in Virtual_Links.Object_Acc);

      procedure Put -- Raises AFDX.Overflow
        (Message          : in     Stream_Element_Array;
         Source_Port      : in     Ports.Port_Range;
         Destination_Port : in     Ports.Port_Range;
         Sub_Virtual_Link : in     Sub_Virtual_Link_Range;
         Identifier       : in     Unsigned_16;
         Frame_Payload    : in     Unsigned_16;
         Size_Required    : in     Unsigned_16;
         Inserted         :    out BOOLEAN);

      procedure Get -- Raises AFDX.Underflow
        (Frame  : out Network.Defs.Frame);

   private
      Virtual_Link : Virtual_Links.Object_Acc;
      SVL_List     : SVL_Array;
      SVL_Pointer  : Sub_Virtual_Link_Range;
      Eth_Header   : Eth.Header;
      VLAN_Header  : Eth.V_LAN.Header;
      IP_Header    : IPv4.Header;
      UDP_Header   : UDP.Header;
   end Object;


   type Queued_Event is tagged limited
      record
         At_Time   : Time;
         Period    : Time_Span;
         Buffer    : Object_Acc;
         Remaining : Natural;
         Virt_Link : Virtual_Links.Object_Acc;
      end record;

end AFDX.Virtual_Links.Queues;
