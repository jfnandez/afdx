with AFDX.Virtual_Links.Queues.Scheduler;

package body AFDX.Virtual_Links.Queues.Events is


   ----------
   -- Ceil --
   ----------

   function Ceil (Left : in Natural; Right : in Positive) return Natural is
      Result : Natural := Left / Right;
   begin
      if (Result * Right) /= Left then
         Result := Result + 1;
      end if;
      return Result;
   end Ceil;
   pragma Inline (Ceil);


   ---------
   -- Put --
   ---------

   procedure Put -- Raises AFDX.Overflow
     (This             : in out Object;
      Message          : in     Stream_Element_Array;
      Destination_Port : in     AFDX.Ports.Port_Range;
      Source_Port      : in     AFDX.Ports.Port_Range;
      Sub_Virtual_Link : in     Virtual_Links.Sub_Virtual_Link_Range;
      Single_Frame     : in     Boolean := False)
   is

      U16_Size : constant := Unsigned_16'Stream_Size/Stream_Element'Size;

      UDP_Pkt_Size  : Unsigned_16;
      Frame_Payload : Unsigned_16;
      Size_Required : Unsigned_16;
      Identifier    : Unsigned_16;
      Total_Frames  : Positive;
      Inserted      : BOOLEAN;

   begin

      UDP_Pkt_Size := Message'Length + UDP.Header_Size;

      Frame_Payload := Unsigned_16
        (This.Virt_Link.Lmax
         - Eth.Header_Size
         - Eth.V_LAN.Header_Size
         - IPv4.Header_Size) and (not 16#0003#);


      Total_Frames  := Ceil
        (Left  => Natural(UDP_Pkt_Size),
         Right => Positive(Frame_Payload));

      if (not Single_Frame) or (Total_Frames = 1) then

         Size_Required  := UDP_Pkt_Size +
           Unsigned_16(Total_Frames * (U16_Size + IPv4.Header_Size));

         Identifier := Gen_ID
           (VL  => This.Virt_Link.ID,
            SVL => Sub_Virtual_Link);

         -- The Message is stored in a buffer
         This.Buffer.Put -- Raises AFDX.Overflow
           (Message          => Message,
            Source_Port      => Source_Port,
            Destination_Port => Destination_Port,
            Sub_Virtual_Link => Sub_Virtual_Link,
            Identifier       => Identifier,
            Frame_Payload    => Frame_Payload,
            Size_Required    => Size_Required,
            Inserted         => Inserted);

         -- If the Message is stored, the scheduler is reported
         -- the number of frames stored.

         if Inserted then
            Queues.Scheduler.Report
              (Event  => Queued_Event(This),
               Amount => Total_Frames);
         end if;

      else
         --pragma Debug("Outbound package discarded due to fragmentation.");
         null;
      end if;


   end Put;


end AFDX.Virtual_Links.Queues.Events;
