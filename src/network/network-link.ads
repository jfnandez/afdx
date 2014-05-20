with Network.Defs.Eth;
with Network.Defs;

use Network.Defs;

package Network.Link is

   procedure Write (The_Frame : in       Frame);
   procedure Read  (The_Frame :     out  Frame);

   function Address return Eth.Address;

end Network.Link;
