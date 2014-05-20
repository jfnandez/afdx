package AFDX.Virtual_Links.Queues.Out_Buffers is

   type Object is tagged limited private;
   type Object_Acc is access all Object;

   procedure Put
     (This             : in out Object;
      Message          : in     Stream_Element_Array;
      Destination_Port : in     Ports.Port_Range;
      Source_Port      : in     Ports.Port_Range;
      Sub_Virtual_Link : in     Virtual_Links.Sub_Virtual_Link_Range;
      Single_Frame     : in     Boolean := False);

private

   type Object is new Queued_Event with null record;

end AFDX.Virtual_Links.Queues.Out_Buffers;
