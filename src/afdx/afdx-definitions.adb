with AFDX.End_Systems;
with AFDX.End_Systems.Pool;

with AFDX.Virtual_Links;
with AFDX.Virtual_Links.Pool;

with AFDX.Ports;
with AFDX.Ports.Pool;

package body AFDX.Definitions is

begin

   End_Systems.Pool.Add (ID => 1, MAC => "00:30:64:07:A2:66", IP => "192.168.85.1");
   End_Systems.Pool.Add (ID => 2, MAC => "00:30:64:07:A2:64", IP => "192.168.85.2");
   --pragma Debug("ES definidos correctamente.");

   Virtual_Links.Pool.Add
     (ID       => 1,
      BAG      => Virtual_Links.BAG64,
      Priority => Virtual_Links.Prio_HIGH,
      Lmax     => 200,
      IP       => "",
      Src      => 1,
      Des      => (1, 1),
      TX_Sizes => (3500, 3500, 3500, 3500),
      RX_Sizes => (3500, 3500, 3500, 3500));

   Virtual_Links.Pool.Add
     (ID       => 2,
      BAG      => Virtual_Links.BAG128,
      Priority => Virtual_Links.Prio_LOW,
      Lmax     => 200,
      IP       => "",
      Src      => 2,
      Des      => (1, 2),
      TX_Sizes => (3500, 0, 0, 0),
      RX_Sizes => (3500, 0, 0, 0));


   --pragma Debug("VL definidos correctamente.");

   Ports.Pool.Add
     (Port             => 1,
      Mode             => Ports.QUEUEING,
      Virtual_Link     => 1,
      Sub_Virtual_Link => 1);

   --pragma Debug("Puertos definidos correctamente.");

end AFDX.Definitions;
