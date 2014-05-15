package body AFDX.Ports is

   function Port (This : in Object) return Port_Range is
   begin
      return This.Port;
   end Port;

   function Mode (This : in Object) return Port_Type is
   begin
      return This.Mode;
   end Mode;

   function Virtual_Link (This : in Object) return Virtual_Links.Object_Acc is
   begin
      return This.VL;
   end Virtual_Link;

   function Sub_Virtual_Link (This : in Object) return Virtual_Links.SVL_Range is
   begin
      return This.SVL;
   end Sub_Virtual_Link;


end AFDX.Ports;
