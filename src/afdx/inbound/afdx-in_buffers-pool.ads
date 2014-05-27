with Network.Defs.UDP;

package AFDX.In_Buffers.Pool is

   function Retrieve (Port : in Network.Defs.UDP.Port) return Object_Acc;
   function Contains (Port : in Network.Defs.UDP.Port) return Boolean;

end AFDX.In_Buffers.Pool;
