with AFDX.End_Systems;
with AFDX.End_Systems.Pool;

package AFDX.Virtual_Links is

   type ID_Range is range 1 .. Max_Number_Of_Virtual_Links;
   type ID_Array is array(Natural range <>) of ID_Range;

   type SVL_Range is mod 4;
   type SVL_Size  is array (SVL_Range) of NATURAL;
   type SVL_List  is array (SVL_Range) of BOOLEAN;

   function Gen_ID
     (VL  : in Virtual_Links.ID_Range;
      SVL : in Virtual_Links.SVL_Range) return Unsigned_16;

   type BAG_Enum  is (BAG1, BAG2, BAG4, BAG8, BAG16, BAG32, BAG64, BAG128);
   type Prio_Enum is (Prio_LOW, Prio_HIGH);


   type Object is tagged private;
   type Object_Acc is access all Object'Class;

   function ID       (This : in Object) return ID_Range;

   function Source_IP       (This : in Object) return IPv4.Address;
   function Destination_IP  (This : in Object) return IPv4.Address;

   function Is_Source       (This : in Object) return BOOLEAN;
   function Is_Destination  (This : in Object) return BOOLEAN;

   function SVL_Defined (This : in Object; SVL : in SVL_Range) return BOOLEAN;
   function SVL_TX_Size (This : in Object; SVL : in SVL_Range) return NATURAL;
   function SVL_RX_Size (This : in Object; SVL : in SVL_Range) return NATURAL;

private

   type Object is tagged
      record
         ID       : ID_Range;
         BAG      : BAG_Enum;
         Priority : Prio_Enum;
         Lmax     : Positive;
         IP       : IPv4.Address;
         Source   : End_Systems.Object_Acc;
         Dest_Map : End_Systems.Pool.ID_Map_Acc;
         Is_Dest  : BOOLEAN;
         SVLs     : SVL_List;
         TX_Size  : SVL_Size;
         RX_Size  : SVL_Size;
      end record;

   function BAG_To_Milliseconds (BAG : in BAG_Enum) return Time_Span;



end AFDX.Virtual_Links;
