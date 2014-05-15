package body AFDX.Virtual_Links is


   --------
   -- ID --
   --------

   function ID (This : in Object) return ID_Range is
   begin
      return This.ID;
   end ID;
   pragma Inline (ID);


   ---------------
   -- Source_IP --
   ---------------

   function Source_IP  (This : in Object) return IPv4.Address is
   begin
      return This.Source.IP;
   end Source_IP;
   pragma Inline (Source_IP);


   --------------------
   -- Destination_IP --
   --------------------

   function Destination_IP  (This : in Object) return IPv4.Address is
   begin
      return This.IP;
   end Destination_IP;
   pragma Inline (Destination_IP);


   ---------------
   -- Is_Source --
   ---------------

   function Is_Source (This : in Object) return BOOLEAN is
   begin
      return This.Source.Its_Me;
   end Is_Source;
   pragma Inline (Is_Source);


   --------------------
   -- Is_Destination --
   --------------------

   function Is_Destination (This : in Object) return BOOLEAN is
   begin
      return This.Is_Dest;
   end Is_Destination;
   pragma Inline (Is_Destination);


   -----------------
   -- SVL_Defined --
   -----------------

   function SVL_Defined(This : in Object; SVL : in SVL_Range) return BOOLEAN is
   begin
      return This.SVLs(SVL);
   end SVL_Defined;
   pragma Inline (SVL_Defined);


   -----------------
   -- SVL_TX_Size --
   -----------------

   function SVL_TX_Size(This : in Object; SVL : in SVL_Range) return NATURAL is
   begin
      return This.TX_Size(SVL);
   end SVL_TX_Size;
   pragma Inline (SVL_TX_Size);

   -----------------
   -- SVL_RX_Size --
   -----------------

   function SVL_RX_Size(This : in Object; SVL : in SVL_Range) return NATURAL is
   begin
      return This.RX_Size(SVL);
   end SVL_RX_Size;
   pragma Inline (SVL_RX_Size);


   -------------------------
   -- BAG_To_Milliseconds --
   -------------------------

   function BAG_To_Milliseconds (BAG : in BAG_Enum) return Time_Span is
   begin
      case BAG is
         when BAG1   => return Milliseconds(1);
         when BAG2   => return Milliseconds(2);
         when BAG4   => return Milliseconds(4);
         when BAG8   => return Milliseconds(8);
         when BAG16  => return Milliseconds(16);
         when BAG32  => return Milliseconds(32);
         when BAG64  => return Milliseconds(64);
         when BAG128 => return Milliseconds(128);
      end case;
   end BAG_To_Milliseconds;


   ------------
   -- Gen_ID --
   ------------

   function Gen_ID
     (VL  : in Virtual_Links.ID_Range;
      SVL : in Virtual_Links.SVL_Range) return Unsigned_16
   is
      VL16  : constant Unsigned_16 := Unsigned_16(VL);
      SVL16 : constant Unsigned_16 := Unsigned_16(SVL);
   begin
      return Shift_Left(VL16, 2) xor (SVL16 and 16#0003#);
   end Gen_ID;
   pragma Inline (Gen_ID);

end AFDX.Virtual_Links;
