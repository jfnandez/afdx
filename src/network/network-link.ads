with Network.Defs.Eth;
with Network.Defs;

package Network.Link is

   procedure Write (The_Frame : in       Defs.Frame);
   procedure Read  (The_Frame :     out  Defs.Frame);

   function Address return Defs.Eth.Address;

end Network.Link;
