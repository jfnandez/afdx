with POSIX_IO;
with POSIX;
with Ethernet_Driver;
with MaRTE.Integer_Types;

with Ada.Text_IO;

--------------------------------------------------------------------------------
-- Performs operations to manipulate the interface within Ethernet.
-- This is the implementation.
--------------------------------------------------------------------------------
package body Network.Link is

   Device_MAC_Address : Network.Defs.Eth.Address;

   File_Descriptor    : POSIX_IO.File_Descriptor;

   -----------------------------------------------------------------------------
   -- Creates a reception filter.
   -----------------------------------------------------------------------------
   procedure Ioctl_Protocol is new POSIX_IO.Generic_Ioctl
     (Ioctl_Options_Type => Ethernet_Driver.Ioctl_Cmd_Protocol,
      Ioctl_Data_Type    => Ethernet_Driver.Eth_Proto_Arg);

   -----------------------------------------------------------------------------
   -- Creates a scheme to block/unblock calls.
   -----------------------------------------------------------------------------
   procedure Ioctl_Block is new POSIX_IO.Generic_Ioctl
     (Ioctl_Options_Type => Ethernet_Driver.Ioctl_Cmd_No_Args,
      Ioctl_Data_Type    => Ethernet_Driver.Eth_Proto_Arg);

   -----------------------------------------------------------------------------
   -- Inquiries the current MAC.
   -----------------------------------------------------------------------------
   procedure Ioctl_Net is new POSIX_IO.Generic_Ioctl
     (Ioctl_Options_Type => Ethernet_Driver.Ioctl_Cmd_Addr,
      Ioctl_Data_Type    => Ethernet_Driver.Eth_Addr_Ioctl_Arg);


   function Non_Blocking_Open
     (Device_Name : in String;
      Mode        : in POSIX_IO.File_Mode)
     return POSIX_IO.File_Descriptor
   is
      Network_Fd         : POSIX_IO.File_Descriptor;
      Ioctl_Net_Protocol : MaRTE.Integer_Types.Unsigned_16 := 0;
      Unused_Parameter   : MaRTE.Integer_Types.Unsigned_16 := 0;
   begin

      -- Opens the interface.
      Network_Fd := POSIX_IO.Open
        (Name => POSIX.To_POSIX_String (Device_Name),
         Mode => Mode);

      -- Sets a filter to receive only the specified protocol.
      Ioctl_Protocol
        (File    => Network_Fd,
         Request => Ethernet_Driver.Set_Protocol_Filter,
         Data    => Ioctl_Net_Protocol);

      -- Sets the option that makes the calls to not block.
      Ioctl_Block
        (File    => Network_Fd,
         Request => Ethernet_Driver.Eth_Non_Blocking_Read,
         Data    => Unused_Parameter);

      return Network_Fd;

   end Non_Blocking_Open;


   function Blocking_Open
     (Device_Name : in String;
      Mode        : in POSIX_IO.File_Mode)
     return POSIX_IO.File_Descriptor
   is
      Network_Fd         : POSIX_IO.File_Descriptor;
      Ioctl_Net_Protocol : MaRTE.Integer_Types.Unsigned_16 := 0;
      Unused_Parameter   : MaRTE.Integer_Types.Unsigned_16 := 0;
   begin
      -- Opens the interface.
      Network_Fd := POSIX_IO.Open
        (Name => POSIX.To_POSIX_String (Device_Name),
         Mode => Mode);

      -- Sets a filter to receive only the specified protocol.
      Ioctl_Protocol
        (File    => Network_Fd,
         Request => Ethernet_Driver.Set_Protocol_Filter,
         Data    => Ioctl_Net_Protocol);

      -- Sets the option that makes the calls to block.
      Ioctl_Block
        (File    => Network_Fd,
         Request => Ethernet_Driver.Eth_Blocking_Read,
         Data    => Unused_Parameter);

      return Network_Fd;

   end Blocking_Open;

   procedure Write (The_Frame : in  Network.Defs.Frame) is
   Last : Stream_Element_Offset;
   begin

      POSIX_IO.Write
        (File           => File_Descriptor,
         Buffer         => The_Frame.Data (1 .. The_Frame.Length),
         Last           => Last,
         Masked_Signals => POSIX.RTS_Signals);

   end Write;

   procedure Read  (The_Frame : out  Network.Defs.Frame) is
   begin

      POSIX_IO.Read
        (File            => File_Descriptor,
         Buffer          => The_Frame.Data,
         Last            => The_Frame.Length,
         Masked_Signals  => POSIX.RTS_Signals);

   end Read;

   function Address return Network.Defs.Eth.Address is
   begin
      return Device_MAC_Address;
   end Address;
   pragma Inline (Address);

   procedure Get_Device_MAC_Address
     (File_Descriptor : in POSIX_IO.File_Descriptor)
   is

      Raw_Address : Ethernet_Driver.Eth_Addr_Ioctl_Arg;

      -- Conversion Function
      function To_Address is new Ada.Unchecked_Conversion
        (Source => Ethernet_Driver.Eth_Addr_Ioctl_Arg,
         Target => Network.Defs.Eth.Address);

   begin

      -- Get the MAC
      Ioctl_Net
        (File   => File_Descriptor,
         Request => Ethernet_Driver.Eth_Hardware_Address,
         Data    => Raw_Address);

      Device_MAC_Address := To_Address(Raw_Address);

   end Get_Device_MAC_Address;

begin

   File_Descriptor := Blocking_Open
     (Device_Name => "/dev/eth0",
      Mode        => POSIX_IO.Read_Write);

   Get_Device_MAC_Address
     (File_Descriptor => File_Descriptor);

  Ada.Text_IO.Put_Line("Netlink Ready with MAC: " & Network.Defs.Eth.To_String(Device_MAC_Address));

end Network.Link;
