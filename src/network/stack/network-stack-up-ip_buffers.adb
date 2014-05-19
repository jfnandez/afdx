with Ada.Unchecked_Deallocation;

package body Network.Stack.Up.IP_Buffers is


   procedure Free_P is new Ada.Unchecked_Deallocation
     (Object => Object,
      Name   => Object_Acc);


   procedure Put
     (This     : in out Object;
      Stream   : in     Stream_Element_Array;
      Offset   : in     Stream_Element_Count;
      MF_Flag  : in     BOOLEAN;
      Is_Ready :    out BOOLEAN)
   is
      Length : constant Stream_Element_Count := Stream'Length;
   begin

      Is_Ready := False;

      if (This.Stored /= Offset) then

         This.Total  := 0;
         This.Stored := 0;
         --pragma Debug("Fragment not received in sequence");

      else

         This.Buffer(Offset+1 .. Offset+Length) := Stream;

         This.Stored := This.Stored + Length;

         if not MF_Flag then
            Is_Ready    := True;
            This.Total  := This.Stored;
            This.Stored := 0;
         end if;

      end if;

   end Put;


   function Get (This : in Object) return Stream_Element_Array is
   begin
      return This.Buffer(1 .. This.Total);
   end Get;


   procedure Free (This : in out Object_Acc) is
   begin
      Free_P(This);
   end Free;


end Network.Stack.Up.IP_Buffers;
