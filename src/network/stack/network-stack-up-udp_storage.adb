with Ada.Text_IO;
use  Ada.Text_IO;

package body Network.Stack.Up.UDP_Storage is
pragma Warnings(off);
   procedure Put
     (Stream   : Stream_Element_Array;
      Src_Port : Unsigned_16;
      Des_Port : Unsigned_16) is
   begin

      --for I in Stream'Range loop
      --   Put(Stream(I)'Img);
      --end loop;
      Put_Line(" Total size: " & Stream'Length'Img);

      null;
   end Put;
pragma Warnings(on);

end Network.Stack.Up.UDP_Storage;
