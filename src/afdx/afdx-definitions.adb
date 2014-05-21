with AFDX.End_Systems;
with AFDX.End_Systems.Pool;

with AFDX.Virtual_Links;
with AFDX.Virtual_Links.Pool;

with AFDX.Ports;
with AFDX.Ports.Pool;

package body AFDX.Definitions is

begin

   End_Systems.Pool.Add
     (ID  => 1,
      MAC => "00:30:64:07:A2:66",
      IP  => "192.168.85.1");

   End_Systems.Pool.Add
     (ID  => 2,
      MAC => "00:30:64:07:A2:64",
      IP  => "192.168.85.2");

   pragma Debug(Put_Line("ES definidos correctamente."));

   Virtual_Links.Pool.Add
     (ID          => 1,
      BAG         => Virtual_Links.BAG64,
      Priority    => Virtual_Links.Prio_HIGH,
      Lmax        => 200,
      IP          => "",
      Source      => 1,
      Destination => (1 => 1),
      TX_Size     => (0 => 3500, 1 => 3500, 2 => 3500, 3 => 3500),
      RX_Size     => (0 => 3500, 1 => 3500, 2 => 3500, 3 => 3500));

   Virtual_Links.Pool.Add
     (ID          => 2,
      BAG         => Virtual_Links.BAG128,
      Priority    => Virtual_Links.Prio_LOW,
      Lmax        => 200,
      IP          => "",
      Source      => 1,
      Destination => (1 => 1),
      TX_Size     => (0 => 3500, 1 => 0, 2 => 0, 3 => 0),
      RX_Size     => (0 => 3500, 1 => 0, 2 => 0, 3 => 0));


   pragma Debug(Put_Line("VL definidos correctamente."));

   Ports.Pool.Add
     (Port             => 1,
      Mode             => Ports.SAMPLING,
      Virtual_Link     => 1,
      Sub_Virtual_Link => 0);

   Ports.Pool.Add
     (Port             => 2,
      Mode             => Ports.SAMPLING,
      Virtual_Link     => 1,
      Sub_Virtual_Link => 1);

   pragma Debug(Put_Line("Puertos definidos correctamente."));

   Put_Line("AFDX-Definitions Ready");

end AFDX.Definitions;
