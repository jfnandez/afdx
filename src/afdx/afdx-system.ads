with Network.Defs.UDP;

with AFDX.Definitions;
with AFDX.Ports;

with AFDX.Virtual_Links.Queues.Out_Buffers;
with AFDX.In_Buffers;

package AFDX.System is

   type Access_Mode is (Blocking, Not_Blocking);

   type Socket is new Root_Stream_Type with private;
   type Socket_Acc is access all Socket'Class;

   overriding
   procedure Write
     (This : in out Socket;
      Item : in     Stream_Element_Array);

   overriding
   procedure Read
     (This : in out Socket;
      Item :    out Stream_Element_Array;
      Last :    out Stream_Element_Offset);

   procedure Bind
     (This : in out Socket;
      Mode : in     Access_Mode;
      Port : in     Network.Defs.UDP.Port);

   function Freshness   (This : in Socket) return Time;
   function Is_Readable (This : in Socket) return Boolean;
   function Is_Writable (This : in Socket) return Boolean;
   function Port        (This : in Socket) return Ports.Object_Acc;
   function Mode        (This : in Socket) return Access_Mode;

private

   package Out_Buffers renames Virtual_Links.Queues.Out_Buffers;

   type Socket is new Root_Stream_Type with
      record
         Port       : Ports.Object_Acc;
         Mode       : Access_Mode;
         Buffer_In  : In_Buffers.Object_Acc;
         Buffer_Out : Out_Buffers.Object_Acc;
         Freshness  : Time;
         Splitable  : Boolean;
      end record;

end AFDX.System;
