--use Network.Defs;

package Network.Defs.Eth.V_LAN is

   pragma Pure;

   Header_Size : constant :=  4;

   type Header is tagged private;
   subtype Header_Stream is Stream_Element_Array(1 .. Header_Size);

   type Priority   is range 0 .. 7;
   type Identifier is range 0 .. 2**12 - 1;

   procedure Set (This : out Header; Stream : in Header_Stream);
   procedure Set
     (This          :    out Header;
      Prio          : in     Priority;
      Iden          : in     Identifier;
      Drop_Elegible : in     Boolean;
      Ethertype     : in     Eth.EtherTypes);

   procedure Get
     (This          : in     Header;
      Prio          :    out Priority;
      Iden          :    out Identifier;
      Drop_Elegible :    out Boolean;
      Ethertype     :    out Eth.EtherTypes);

   function Get (This : in Header) return Header_Stream;



private

   type Header is tagged
      record
         Stream : Header_Stream;
      end record;

end Network.Defs.Eth.V_LAN;
