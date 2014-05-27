with Ada.Text_IO;
use Ada.Text_IO;


package body Network.Link is

   MAC_Address : constant Network.Defs.Eth.Address :=
     Network.Defs.Eth.Parse("00:30:64:07:A2:66");

   task Dispatcher is
       pragma Priority(15);
      entry Write (The_Frame : in      Network.Defs.Frame);
      entry Read  (The_Frame :     out Network.Defs.Frame);
   end Dispatcher;

   task body Dispatcher is
      Stored_Frame : Network.Defs.Frame;
   begin

      loop

         accept Write (The_Frame : in Network.Defs.Frame) do
            Stored_Frame := The_Frame;
         end Write;

         accept Read (The_Frame : out Network.Defs.Frame) do
            The_Frame := Stored_Frame;
         end Read;

      end loop;

   exception

      when others =>
         Put_Line("El simulador de la red cayo.");
         raise Program_Error;

   end Dispatcher;




   procedure Write (The_Frame : in  Network.Defs.Frame) is
   begin
      Dispatcher.Write(The_Frame);
   end Write;

   procedure Read  (The_Frame : out  Network.Defs.Frame) is
   begin
      Dispatcher.Read(The_Frame);
   end Read;


   function Address return Network.Defs.Eth.Address is
   begin
      return MAC_Address;
   end Address;

begin

   Put_Line("Network-Link Ready with MAC " & Defs.Eth.To_String(MAC_Address));

end Network.Link;
