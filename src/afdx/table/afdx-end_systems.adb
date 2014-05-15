package body AFDX.End_Systems is


   --------
   -- ID --
   --------

   function ID (This : in Object) return ID_Range is
   begin
      return This.ID;
   end ID;
   pragma Inline (ID);


   ---------
   -- MAC --
   ---------

   function MAC (This : in Object) return Eth.Address is
   begin
      return This.MAC;
   end MAC;
   pragma Inline (MAC);


   --------
   -- IP --
   --------

   function IP (This : in Object) return IPv4.Address is
   begin
      return This.IP;
   end IP;
   pragma Inline (IP);


   ------------
   -- Its_Me --
   ------------

   function Its_Me (This : in Object) return Boolean is
      use type Eth.Address;
   begin
      return This.MAC = Device_MAC;
   end Its_Me;
   pragma Inline (Its_Me);

end AFDX.End_Systems;
