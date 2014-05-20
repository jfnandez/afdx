package body Network.Defs.Eth.V_LAN is

   IDEN_MASK : constant := 2#00001111_11111111#;
   DROP_MASK : constant := 2#00010000_00000000#;
   PRIO_MASK : constant := 2#11100000_00000000#;

   procedure Set
     (This          :    out Header;
      Prio          : in     Priority;
      Iden          : in     Identifier;
      Drop_Elegible : in     Boolean;
      Ethertype     : in     Eth.EtherTypes)
   is
      U16 : Unsigned_16;
   begin

      U16 := Unsigned_16(Iden) and IDEN_MASK;
      U16 := U16 xor (Shift_Left(Unsigned_16(Prio), 13) and PRIO_MASK);

      if Drop_Elegible then
         U16 := U16 xor DROP_MASK;
      end if;

      This.Stream(1..2) := To_Net16(U16);
      This.Stream(3..4) := To_Net16(Eth.Ether_Conv(Ethertype));

   end Set;


   procedure Set (This : out Header; Stream : in Header_Stream) is
   begin
      This.Stream := Stream;
   end Set;


   procedure Get
     (This          : in     Header;
      Prio          :    out Priority;
      Iden          :    out Identifier;
      Drop_Elegible :    out Boolean;
      Ethertype     :    out Eth.EtherTypes)
   is
      U16 : constant Unsigned_16 := From_Net16(This.Stream(1 .. 2));
   begin
      Prio          := Priority(Shift_Right(U16, 13));
      Iden          := Identifier(U16 and IDEN_MASK);
      Drop_Elegible := (U16 and DROP_MASK) = DROP_MASK;
      Ethertype     := Eth.Ether_Conv(From_Net16(This.Stream(3 .. 4)));
   end Get;


   function Get (This : in Header) return Header_Stream is
   begin
      return This.Stream;
   end Get;


end Network.Defs.Eth.V_LAN;

