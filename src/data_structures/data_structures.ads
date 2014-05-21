generic

   type Element_Type is private;

package Data_Structures is

   pragma Pure;

   OVERFLOW  : exception;
   UNDERFLOW : exception;

   type Data_Structure (Size : Positive) is
     abstract tagged limited private;

   type Data_Structure_Acc is
     access all Data_Structure'Class;

   procedure Put
     (This    : in out Data_Structure;
      Element : in     Element_Type) is abstract;

   procedure Get
     (This    : in out Data_Structure;
      Element :    out Element_Type) is abstract;

   function Peek
     (This : in Data_Structure) return Element_Type is abstract;

   procedure Flush
     (This : in out Data_Structure) is abstract;

   function Is_Empty
     (This : in Data_Structure) return Boolean;

   function Is_Full
     (This : in Data_Structure) return Boolean;

   function Elements_Stored
     (This : in Data_Structure) return Natural;

   function Elements_Free
     (This : in Data_Structure) return Natural;

private

   type Element_Type_Array is array (Natural range <>) of Element_Type;

   type Data_Structure (Size : Positive) is abstract tagged limited
      record
         Free : Natural := Size;
      end record;

end Data_Structures;
