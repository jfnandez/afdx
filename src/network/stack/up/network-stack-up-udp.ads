with Network.Defs.UDP;

package Network.Stack.Up.UDP is

   type Storage is protected interface;
   type Storage_Acc is access all Storage'Class;

   procedure Put
     (This       : in out Storage;
      Stream     : in     Stream_Element_Array) is abstract;

   procedure Associate (Port : in Defs.UDP.Port; Buffer : in Storage_Acc);

   function Retrieve (Port : in Defs.UDP.Port) return Storage_Acc;
   function Contains (Port : in Defs.UDP.Port) return Boolean;

   procedure Push (UDP_Stream : Stream_Element_Array);

end Network.Stack.Up.UDP;
