package body Network.Defs.IPv4 is

   function Parse (Src : in String) return Address
   is
      IP     : Unsigned_32 := 0;
      Total  : Unsigned_32;
      Offset : Integer := Src'First;
   begin

      for I in 1 ..3 loop
         Total  := 0;

         while Src(Offset) /= '.' loop

            Total  := Total*10 + Unsigned_32(Network.Parse_B10(Src(Offset)));
            Offset := Offset + 1;

            if Total > 255 then
               raise Invalid;
            end if;

         end loop;

         Offset := Offset + 1;

         IP := Shift_Left(IP, 8) or Total;

      end loop;

      Total  := 0;

      for I in Offset .. Src'Last loop

         Total  := Total*10 + Unsigned_32(Network.Parse_B10(Src(I)));

         if Total > 255 then
            raise Invalid;
         end if;

      end loop;

      IP := Shift_Left(IP, 8) or Total;

      return Address(IP);


   exception

      when Network.Parsing_Error =>
         raise Invalid;

   end Parse;


   function "=" (Left, Right : in Address) return Boolean is
   begin
      return Unsigned_32(Left) = Unsigned_32(Right);
   end "=";


   function "<" (Left, Right : in Address) return Boolean is
   begin
      return Unsigned_32(Left) < Unsigned_32(Right);
   end "<";

      function "<=" (Left, Right : in Address) return Boolean is
   begin
      return Unsigned_32(Left) <= Unsigned_32(Right);
   end "<=";

      function ">" (Left, Right : in Address) return Boolean is
   begin
      return Unsigned_32(Left) > Unsigned_32(Right);
   end ">";

      function ">=" (Left, Right : in Address) return Boolean is
   begin
      return Unsigned_32(Left) >= Unsigned_32(Right);
   end ">=";


   function To_String(Addrs : in Address) return String is
      T : constant Unsigned_32 := Unsigned_32(Addrs);
      B1: constant Unsigned_32 := Shift_Right(T, 24) and 16#000000FF#;
      B2: constant Unsigned_32 := Shift_Right(T, 16) and 16#000000FF#;
      B3: constant Unsigned_32 := Shift_Right(T,  8) and 16#000000FF#;
      B4: constant Unsigned_32 := T and 16#000000FF#;
   begin

      declare
         ST : STRING := B1'Img & B2'Img & B3'Img & B4'Img;
      begin
         for I in ST'RANGE loop
            if ST(I) = ' ' then
               ST(I) := '.';
            end if;
         end loop;

         return ST(ST'First + 1 .. ST'Last);
      end;



   end To_String;



   -- Setters --

   DF_FLAG16 : constant := 2#01000000_00000000#;
   MF_FLAG16 : constant := 2#00100000_00000000#;

   DF_FLAG8  : constant := 2#01000000#;
   MF_FLAG8  : constant := 2#00100000#;

   FO_MASK : constant := 2#00011111_11111111#;

   UDP_Protocol : constant Unsigned_8 := 17;

   function Protocol_Conv (Protocol : in Protocols) return Unsigned_8 is
   begin
      case Protocol is
         when UDP   => return UDP_Protocol;
         when others => raise Program_Error;
      end case;
   end Protocol_Conv;

   function Protocol_Conv (Protocol : in Unsigned_8) return Protocols is
   begin
      case Protocol is
         when UDP_Protocol => return UDP;
         when others      => return No_Def;
      end case;
   end Protocol_Conv;


   procedure Set
     (This                :    out Header;
      Version             : in     Unsigned_8;
      Header_Length       : in     Unsigned_8;
      Total_Length        : in     Unsigned_16;
      Identification      : in     Unsigned_16;
      Dont_Fragment_Flag  : in     Boolean;
      More_Fragments_Flag : in     Boolean;
      Fragment_Offset     : in     Unsigned_16; -- Only 13 bits
      Time_To_Live        : in     Unsigned_8;
      Protocol            : in     Protocols;
      Header_Checksum     : in     Unsigned_16;
      Source_IP           : in     Address;
      Destination_IP      : in     Address)
   is
      U8  : Unsigned_8;
      U16 : Unsigned_16;
   begin

      U8 := Shift_Left(Version, 4);
      U8 := U8 xor (Header_Length and 16#0F#);

      This.Stream(1) := Stream_Element(U8);

      -- Service type DSCP_ECN
      This.Stream(2) := Stream_Element(2#00000000#);

      This.Stream(3 ..  4) := Network.To_Net16(Total_Length);
      This.Stream(5 ..  6) := Network.To_Net16(Identification);

      U16 := Fragment_Offset and FO_MASK;

      if Dont_Fragment_Flag then
         U16 := U16 xor DF_FLAG16;
      end if;

      if More_Fragments_Flag then
         U16 := U16 xor MF_FLAG16;
      end if;

      This.Stream(7 ..  8) := Network.To_Net16(U16);

      This.Stream( 9)  := Stream_Element(Time_To_Live);
      This.Stream(10)  := Stream_Element(Protocol_Conv(Protocol));

      This.Stream(11 .. 12) := Network.To_Net16(Header_Checksum);
      This.Stream(13 .. 16) := Network.To_Net32(Unsigned_32(Source_IP));
      This.Stream(17 .. 20) := Network.To_Net32(Unsigned_32(Destination_IP));

   end Set;








   procedure Total_Length (This : in out Header; Total_Length : in Unsigned_16) is
   begin
      This.Stream(3 ..  4) := Network.To_Net16(Total_Length);
   end Total_Length;

   procedure Identification (This : in out Header; Identification : in Unsigned_16) is
   begin
      This.Stream(5 ..  6) := Network.To_Net16(Identification);
   end
     Identification;

   procedure Set_DF_Flag (This : in out Header) is
      U8 : constant Unsigned_8 := Unsigned_8(This.Stream(7));
   begin
      This.Stream(7) := Stream_Element(U8 or DF_FLAG8);
   end Set_DF_Flag;

   procedure Set_MF_Flag (This : in out Header) is
      U8 : constant Unsigned_8 := Unsigned_8(This.Stream(7));
   begin
      This.Stream(7) := Stream_Element(U8 or MF_FLAG8);
   end Set_MF_Flag;

   procedure Reset_DF_Flag (This : in out Header) is
      U8 : constant Unsigned_8 := Unsigned_8(This.Stream(7));
   begin
      This.Stream(7) := Stream_Element(U8 and (not DF_FLAG8));
   end Reset_DF_Flag;

   procedure Reset_MF_Flag (This : in out Header) is
      U8 : constant Unsigned_8 := Unsigned_8(This.Stream(7));
   begin
      This.Stream(7) := Stream_Element(U8 and (not MF_FLAG8));
   end Reset_MF_Flag;


   procedure Fragment_Offset (This : in out Header; Fragment_Offset : in Unsigned_16) is
      U16 : Unsigned_16 := Network.From_Net16(This.Stream(7 .. 8)) and (not FO_MASK);
   begin
      U16 := U16 xor (Fragment_Offset and FO_MASK);
      This.Stream(7 .. 8) := Network.To_Net16(U16);
   end Fragment_Offset;



   procedure Set_Checksum (This : in out Header) is
      Header_Checksum : Unsigned_16;
   begin

      This.Stream(11 .. 12) := (0, 0);
      Header_Checksum := not Checksum(This.Stream);
      This.Stream(11 .. 12) := U16_To_Stream(Header_Checksum);
   end Set_Checksum;






   procedure Get
     (This                : in     Header;
      Version             :    out Unsigned_8;
      Header_Length       :    out Unsigned_8;
      Total_Length        :    out Unsigned_16;
      Identification      :    out Unsigned_16;
      Dont_Fragment_Flag  :    out Boolean;
      More_Fragments_Flag :    out Boolean;
      Fragment_Offset     :    out Unsigned_16; -- Only 13 bits
      Time_To_Live        :    out Unsigned_8;
      Protocol            :    out Protocols;
      Header_Checksum     :    out Unsigned_16;
      Source_IP           :    out Address;
      Destination_IP      :    out Address)
   is
   begin

      Version        := Shift_Right(Unsigned_8(This.Stream(1)), 4);
      Header_Length  := Unsigned_8(This.Stream(1)) and 16#0F#;

      Total_Length   := Network.From_Net16(This.Stream(3 .. 4));
      Identification := Network.From_Net16(This.Stream(5 .. 6));

      Dont_Fragment_Flag  := ((Unsigned_8(This.Stream(7) and DF_FLAG8)) = DF_FLAG8);
      More_Fragments_Flag := ((Unsigned_8(This.Stream(7) and MF_FLAG8)) = MF_FLAG8);

      Fragment_Offset := (Network.From_Net16(This.Stream(7 .. 8)) and FO_MASK);

      Time_To_Live      := Unsigned_8(This.Stream( 9));
      Protocol          := Protocol_Conv(Unsigned_8(This.Stream(10)));

      Header_Checksum   := Network.From_Net16(This.Stream(11 .. 12));
      Source_IP         := Address(Network.From_Net32(This.Stream(13 .. 16)));
      Destination_IP    := Address(Network.From_Net32(This.Stream(17 .. 20)));

   end Get;


   function Get (This : in Header) return Header_Stream is
   begin
      return This.Stream;
   end Get;


   procedure Set (This :out Header; Stream : in Header_Stream) is
   begin
      This.Stream := Stream;
   end Set;





   function Is_Multicast(This : in Address) return Boolean is
   begin
      return (This in Multicast_Address);
   end Is_Multicast;





   end Network.Defs.IPv4;

