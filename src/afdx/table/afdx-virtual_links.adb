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
      return This.Src.IP;
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

   --------------
   -- Priority --
   --------------

   function Priority (This : in Object) return Prio_Enum is
   begin
      return This.Prio;
   end Priority;
   pragma Inline (Priority);


   ---------------
   -- Is_Source --
   ---------------

   function Is_Source (This : in Object) return BOOLEAN is
   begin
      return This.Is_Src;
   end Is_Source;
   pragma Inline (Is_Source);


   --------------------
   -- Is_Destination --
   --------------------

   function Is_Destination (This : in Object) return BOOLEAN is
   begin
      return This.Is_Des;
   end Is_Destination;
   pragma Inline (Is_Destination);



   function Sub_Virtual_Link (This : in Object) return Sub_Virtual_Link_Object_Acc is
   begin
      return This.Sub_VL;
   end Sub_Virtual_Link;
   pragma Inline (Sub_Virtual_Link);

   function Contains
     (This : in Sub_Virtual_Link_Object;
      ID   : in Sub_Virtual_Link_Range) return BOOLEAN
   is
   begin
      return This.List(ID);
   end Contains;
   pragma Inline (Contains);

   function TX_Size
     (This : in Sub_Virtual_Link_Object;
      ID   : in Sub_Virtual_Link_Range) return NATURAL
   is
   begin
      return This.TX_Size(ID);
   end TX_Size;
   pragma Inline (TX_Size);


   function RX_Size
     (This : in Sub_Virtual_Link_Object;
      ID   : in Sub_Virtual_Link_Range) return NATURAL
   is
   begin
      return This.RX_Size(ID);
   end RX_Size;
   pragma Inline (RX_Size);




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
      SVL : in Virtual_Links.Sub_Virtual_Link_Range) return Unsigned_16
   is
      VL16  : constant Unsigned_16 := Unsigned_16(VL);
      SVL16 : constant Unsigned_16 := Unsigned_16(SVL);
   begin
      return Shift_Left(VL16, 2) xor (SVL16 and 16#0003#);
   end Gen_ID;
   pragma Inline (Gen_ID);

end AFDX.Virtual_Links;
