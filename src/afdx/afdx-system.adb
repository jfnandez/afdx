with AFDX.Ports.Pool;
with AFDX.Virtual_Links.Queues.Scheduler.Executor;
with Network.Link.Pump;
with AFDX.Virtual_Links.Queues.Out_Buffers.Pool;
with AFDX.In_Buffers.Pool;

package body AFDX.System is


   overriding
   procedure Write
     (This : in out Socket;
      Item : in     Stream_Element_Array)
   is
   begin

      if This.Is_Writable then

         This.Buffer_Out.Put
           (Message          => Item,
            Destination_Port => This.Port.Port,
            Source_Port      => This.Port.Port,
            Sub_Virtual_Link => This.Port.Sub_Virtual_Link,
            Single_Frame     => not This.Splitable);

      else

         raise Program_Error with "This socket is not writable";

      end if;

   end Write;


   overriding
   procedure Read
     (This : in out Socket;
      Item :    out Stream_Element_Array;
      Last :    out Stream_Element_Offset)
   is
      Length : Stream_Element_Count;
   begin

      if This.Is_Readable then

         case This.Mode is

            when Blocking =>

               This.Buffer_In.Blocking_Get
                 (Message   => Item,
                  Length    =>  Length,
                  Freshness => This.Freshness);

            when Not_Blocking =>

               This.Buffer_In.Non_Blocking_Get
                 (Message   => Item,
                  Length    => Length,
                  Freshness => This.Freshness);

         end case;

         Last := Item'First + Length - 1;

      else

         raise Program_Error with "This socket is not writable";

      end if;

   end Read;


   procedure Bind
     (This : in out Socket;
      Mode : in     Access_Mode;
      Port : in     Ports.Port_Range)
   is
   begin

      This.Mode := Mode;
      This.Port := Ports.Pool.Retrieve(Port);
      This.Freshness := Time_Last;

      case (This.Port.Mode) is
         when Ports.QUEUEING =>
            This.Splitable := True;
         when Ports.SAMPLING =>
            This.Splitable := False;
      end case;


      if This.Is_Readable then
         This.Buffer_In :=
           In_Buffers.Pool.Retrieve (This.Port.Port);
      end if;


      if This.Is_Writable then
         This.Buffer_Out :=
           Out_Buffers.Pool.Retrieve (This.Port.Virtual_Link.ID);
      end if;

   end Bind;


   function Freshness   (This : in Socket) return Time is
   begin
      return This.Freshness;
   end Freshness;

   function Is_Readable (This : in Socket) return Boolean is
   begin
      return This.Port.Virtual_Link.Is_Destination;
   end Is_Readable;

   function Is_Writable (This : in Socket) return Boolean is
   begin
      return This.Port.Virtual_Link.Is_Source;
   end Is_Writable;

   function Port (This : in Socket) return Ports.Object_Acc is
   begin
      return This.Port;
   end Port;

   function Mode (This : in Socket) return Access_Mode is
   begin
      return This.Mode;
   end Mode;

begin

   Network.Link.Pump.Release;
   Virtual_Links.Queues.Scheduler.Executor.Release;

end AFDX.System;
