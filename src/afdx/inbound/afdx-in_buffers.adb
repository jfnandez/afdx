package body AFDX.In_Buffers is


   protected body Sampling_Object is


      overriding procedure Put (Stream : in Stream_Element_Array)
      is
      begin
         Counter := Stream'Length;
         Buffer(1 .. Counter) := Stream;
         Rcv_At   := Clock;
         Is_Ready := True;
      end Put;


      entry Blocking_Get
        (Message    : in out Stream_Element_Array;
         Length     :    out Stream_Element_Count;
         Freshness  :    out Time) when Is_Ready
      is
      begin
         Message   := Buffer(1 .. Counter);
         Length    := Counter;
         Freshness := Rcv_At;
      end Blocking_Get;


      overriding procedure Non_Blocking_Get
        (Message    : in out Stream_Element_Array;
         Length     :    out Stream_Element_Count;
         Freshness  :    out Time)
      is
      begin
         Message   := Buffer(1 .. Counter);
         Length    := Counter;
         Freshness := Rcv_At;
      end Non_Blocking_Get;

   end Sampling_Object;


   ------------------------------------


   protected body Queueing_Object is



      overriding procedure Put
        (Stream    : in     Stream_Element_Array) is
      begin
         Stream_Element_Array'Output(Buffer, Stream);
      end Put;


      entry Blocking_Get
        (Message    : in out Stream_Element_Array;
         Length     :    out Stream_Element_Count;
         Freshness  :    out Time) when not Buffer.Is_Empty
      is
         Output_Stream : constant Stream_Element_Array := Stream_Element_Array'Input(Buffer);
      begin
         Length := Output_Stream'Length;
         Message(Message'First .. Message'First + Length) := Output_Stream;
         Freshness := Time_First;
      end Blocking_Get;


      overriding procedure Non_Blocking_Get
        (Message    : in out Stream_Element_Array;
         Length     :    out Stream_Element_Count;
         Freshness  :    out Time)
      is

      begin
         Freshness := Time_First;
         if not Buffer.Is_Empty then
            declare
               Output_Stream : constant Stream_Element_Array := Stream_Element_Array'Input(Buffer);
            begin
               Length := Output_Stream'Length;
               Message(Message'First .. Message'First + Length) := Output_Stream;
            end;
         else
            Length := 0;
         end if;
      end Non_Blocking_Get;

   end Queueing_Object;






end AFDX.In_Buffers;
