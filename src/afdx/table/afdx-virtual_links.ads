with AFDX.End_Systems;

package AFDX.Virtual_Links is

   type ID_Range is range 1 .. Max_Number_Of_Virtual_Links;
   type ID_Array is array(Natural range <>) of ID_Range;

   type Sub_Virtual_Link_Range is mod 4;
   type Sub_Virtual_Link_List is array (Sub_Virtual_Link_Range) of Boolean;
   type Sub_Virtual_Link_Size is array (Sub_Virtual_Link_Range) of NATURAL;

   type BAG_Enum  is (BAG1, BAG2, BAG4, BAG8, BAG16, BAG32, BAG64, BAG128);
   type Prio_Enum is (Prio_LOW, Prio_HIGH);

   type Object is tagged private;
   type Object_Acc is access all Object'Class;

   type Sub_Virtual_Link_Object is tagged private;
   type Sub_Virtual_Link_Object_Acc is access all Sub_Virtual_Link_Object'Class;


   function ID               (This : in Object) return ID_Range;
   function Priority         (This : in Object) return Prio_Enum;
   function Lmax             (This : in Object) return Positive;
   function Source_IP        (This : in Object) return IPv4.Address;
   function Destination_IP   (This : in Object) return IPv4.Address;
   function Is_Source        (This : in Object) return Boolean;
   function Is_Destination   (This : in Object) return Boolean;
   function Sub_Virtual_Link (This : in Object) return Sub_Virtual_Link_Object_Acc;

   function Contains
     (This : in Sub_Virtual_Link_Object;
      ID   : in Sub_Virtual_Link_Range) return Boolean;

   function TX_Size
     (This : in Sub_Virtual_Link_Object;
      ID   : in Sub_Virtual_Link_Range) return NATURAL;

   function RX_Size
     (This : in Sub_Virtual_Link_Object;
      ID   : in Sub_Virtual_Link_Range) return NATURAL;

   package Maps is new Ada.Containers.Ordered_Maps
     (Key_Type     => ID_Range,
      Element_Type => Object_Acc,
      "<"          => "<",
      "="          => "=");

   type Action_Procedure is access procedure (Cursor : in Maps.Cursor);

private

   type Object is tagged
      record
         ID     : ID_Range;
         BAG    : BAG_Enum;
         Prio   : Prio_Enum;
         Lmax   : Positive;
         Des_IP : IPv4.Address;
         Src    : End_Systems.Object_Acc;
         Des    : End_Systems.Maps.Map;
         Is_Src : Boolean;
         Is_Des : Boolean;
         Sub_VL : Sub_Virtual_Link_Object_Acc;
      end record;

   type Sub_Virtual_Link_Object is tagged
      record
         List    : Sub_Virtual_Link_List;
         TX_Size : Sub_Virtual_Link_Size;
         RX_Size : Sub_Virtual_Link_Size;
      end record;

   function BAG_To_Milliseconds (BAG : in BAG_Enum) return Time_Span;

end AFDX.Virtual_Links;
