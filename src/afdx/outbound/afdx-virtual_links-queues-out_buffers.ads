
package AFDX.Virtual_Links.Queues.Out_Buffers is

   type Object is tagged limited private;
   type Object_Acc is access all Object;

   procedure Put
     (This             : in out Object;
      Message          : in     Stream_Element_Array;
      Destination_Port : in     Network.Defs.UDP.Port;
      Source_Port      : in     Network.Defs.UDP.Port;
      Identifier       : in     Unsigned_16;
      Sub_Virtual_Link : in     Virtual_Links.Sub_Virtual_Link_Range;
      Fragmentable     : in     Boolean := False);

private

   type Object is new Queued_Event with null record;

end AFDX.Virtual_Links.Queues.Out_Buffers;
