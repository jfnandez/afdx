pragma Warnings(off);
with Network.Defs;
use Network.Defs;
pragma Warnings(on);

package Network.Stack is

   pragma Pure;

   type Stream_Procesing is access procedure (Stream : in Stream_Element_Array);

   procedure Sink (Stream : in Stream_Element_Array) is null;

end Network.Stack;
