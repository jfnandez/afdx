with AFDX.Ports.Pool;

with Network.Stack.Up.IPv4;

with AFDX.Definitions;

package body AFDX.In_Buffers.Pool is

   function Retrieve (Port : in Network.Defs.UDP.Port) return Object_Acc is
   begin
      return Object_Acc(Network.Stack.Up.UDP.Retrieve(Port));
   end Retrieve;

   function Contains (Port : in Network.Defs.UDP.Port) return Boolean is
   begin
      return Network.Stack.Up.UDP.Contains(Port);
   end Contains;


   procedure Create (Cursor : Ports.Maps.Cursor) is
      Port        : Ports.Object_Acc;
      Buffer      : Object_Acc;
      Buffer_Size : Stream_Element_Count;
   begin

      Port := Ports.Maps.Element(Cursor);

      if  Port.Virtual_Link.Is_Destination then

         case (Port.Mode) is

         when Ports.QUEUEING =>

            Buffer_Size := Stream_Element_Count
              (Port.Virtual_Link.Sub_Virtual_Link.RX_Size
                (Port.Sub_Virtual_Link));

            Buffer := new In_Buffers.Queueing_Object(Buffer_Size);

         when Ports.SAMPLING =>

            Buffer_Size := Stream_Element_Count
              (Port.Virtual_Link.Lmax);

            Buffer := new In_Buffers.Sampling_Object(Buffer_Size);

         end case;

         Network.Stack.Up.IPv4.Enable
           (Source      => Port.Virtual_Link.Source_IP,
            Destination => Port.Virtual_Link.Destination_IP,
            Identifier  => Port.Port,
            Buffer_Size => Buffer_Size);

         Network.Stack.Up.UDP.Associate
           (Port   => Port.Port,
            Buffer => Network.Stack.Up.UDP.Storage_Acc(Buffer));

      end if;

   end Create;

begin

   Ports.Pool.Iterate(Create'Access);
   Put_Line("AFDX-IN_Buffer-Pool Ready");

end AFDX.In_Buffers.Pool;
