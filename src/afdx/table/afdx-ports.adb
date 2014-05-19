package body AFDX.Ports is

   function Port (This : in Object) return Port_Range is
   begin
      return This.Port;
   end Port;
   pragma Inline (Port);

   function Mode (This : in Object) return Port_Type is
   begin
      return This.Mode;
   end Mode;
   pragma Inline (Mode);

   function Virtual_Link (This : in Object) return Virtual_Links.Object_Acc is
   begin
      return This.VL;
   end Virtual_Link;
   pragma Inline (Virtual_Link);

   function Sub_Virtual_Link_ID (This : in Object) return Virtual_Links.Sub_Virtual_Link_Range is
   begin
      return This.SVL_ID;
   end Sub_Virtual_Link_ID;
   pragma Inline (Sub_Virtual_Link_ID);


end AFDX.Ports;
