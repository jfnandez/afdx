with AFDX.Ports;
with AFDX.In_Buffers;
with AFDX.In_Buffers.Pool;

use AFDX;

package body Network.Stack.Up.UDP_Storage is

   pragma Warnings(OFF);

   procedure Put
     (Stream           : in Stream_Element_Array;
      Source_Port      : in Unsigned_16;
      Destination_Port : in Unsigned_16)
   is

      use AFDX.In_Buffers;

      Buffer : constant In_Buffers.Object_Acc :=
        In_Buffers.Pool.Retrieve(Ports.Port_Range(Destination_Port));

   begin

      if Buffer /= null then
         Buffer.Put(Stream);
      else
         raise Program_Error with "Not defined port or not listening.";
      end if;

   end Put;

   pragma Warnings(ON);

end Network.Stack.Up.UDP_Storage;
