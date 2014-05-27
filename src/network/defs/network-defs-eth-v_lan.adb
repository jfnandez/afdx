package body Network.Defs.Eth.V_LAN is

   IDEN_MASK : constant := 2#00001111_11111111#;
   DROP_MASK : constant := 2#00010000_00000000#;
   PRIO_MASK : constant := 2#11100000_00000000#;

   procedure To_Header (This : out Header; Stream : in Header_Stream) is
      U16 : constant Unsigned_16 := From_Net16(Stream(0 .. 1));
   begin
      This.Priority      := Priorities(Shift_Right(U16, 13));
      This.Identifier    := Identifiers(U16 and IDEN_MASK);
      This.Drop_Elegible := (U16 and DROP_MASK) = DROP_MASK;
      This.Ethertype     := Eth.Ether_Conv(From_Net16(Stream(2 .. 3)));
   end To_Header;


   function To_Stream (This : in Header) return Header_Stream is
      U_IDEN : Unsigned_16;
      U_DROP : Unsigned_16;
      U_PRIO : Unsigned_16;
      Stream : Header_Stream;
   begin

      U_IDEN := Unsigned_16(This.Identifier) and IDEN_MASK;
      U_PRIO := Shift_Left(Unsigned_16(This.Priority), 13) and PRIO_MASK;

      case This.Drop_Elegible is
         when True  => U_DROP := DROP_MASK;
         when False => U_DROP := 0;
      end case;

      Stream(0 .. 1) := To_Net16(U_IDEN xor U_DROP xor U_PRIO);
      Stream(2 .. 3) := To_Net16(Eth.Ether_Conv(This.EtherType));

      return Stream;

   end To_Stream;

end Network.Defs.Eth.V_LAN;

