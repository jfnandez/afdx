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
   begin

      pragma Assert
        (This_Object /= null,
         "AFDX.End_Systems.Its_Me error : Device with current MAC not found.");

      return This_Object.ID = This.ID;

   end Its_Me;
   pragma Inline (Its_Me);


   ------------
   -- Get_Me --
   ------------

   function Get_Me return Object_Acc is
   begin

      pragma Assert
        (This_Object /= null,
         "AFDX.End_Systems.Get_Me error : Device with current MAC not found.");

      return This_Object;

   end Get_Me;
   pragma Inline (Get_Me);

end AFDX.End_Systems;
