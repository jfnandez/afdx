with AFDX.Ports;

package AFDX.In_Buffers.Pool is

   function Retrieve (Port : in Ports.Port_Range) return Object_Acc;
   function Contains (Port : in Ports.Port_Range) return Boolean;

end AFDX.In_Buffers.Pool;
