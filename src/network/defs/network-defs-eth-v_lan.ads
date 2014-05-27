package Network.Defs.Eth.V_LAN is

   pragma Pure;

   type Priorities  is mod 2**3;
   type Identifiers is mod 2**12;

   Header_Size : constant :=  4;

   type Header is tagged
      record
         Priority      : Priorities;
         Identifier    : Identifiers;
         Drop_Elegible : Boolean;
         EtherType     : Eth.EtherTypes;
      end record;

   subtype Header_Stream is
     Stream_Element_Array(0 .. Header_Size - 1);

   procedure To_Header (This : out Header; Stream : in Header_Stream);
   function  To_Stream (This : in Header) return Header_Stream;

end Network.Defs.Eth.V_LAN;
