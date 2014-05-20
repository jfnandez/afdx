package body AFDX.In_Buffers is


   protected body Sampling_Object is

      --overriding
      procedure Put (Stream : in Stream_Element_Array)
      is
      begin
         Counter              := Stream'Length;
         Buffer(1 .. Counter) := Stream;
         TimeStamp            := Clock;
         Is_Ready             := True;
      end Put;

      --overriding
      entry Blocking_Get
        (Message    : in out Stream_Element_Array;
         Length     :    out Stream_Element_Count;
         Freshness  :    out Time) when Is_Ready
      is
      begin
         Message   := Buffer(1 .. Counter);
         Length    := Counter;
         Freshness := TimeStamp;
      end Blocking_Get;


      --overriding
      procedure Non_Blocking_Get
        (Message    : in out Stream_Element_Array;
         Length     :    out Stream_Element_Count;
         Freshness  :    out Time)
      is
      begin
         Message   := Buffer(1 .. Counter);
         Length    := Counter;
         Freshness := TimeStamp;
      end Non_Blocking_Get;

   end Sampling_Object;


   ------------------------------------


   protected body Queueing_Object is

      --overriding
      procedure Put
        (Stream    : in     Stream_Element_Array) is
      begin
         Buffer.Write(Stream);
      end Put;

      --overriding
      entry Blocking_Get
        (Message    : in out Stream_Element_Array;
         Length     :    out Stream_Element_Count;
         Freshness  :    out Time) when not Buffer.Is_Empty
      is
      begin

         if Buffer.Readable_Elements < Message'Length then
            requeue Blocking_Get;
         end if;

         Buffer.Read(Message, Length);
         Length := Message'Length;
         Freshness := Time_First;

      end Blocking_Get;

      --overriding
      procedure Non_Blocking_Get
        (Message    : in out Stream_Element_Array;
         Length     :    out Stream_Element_Count;
         Freshness  :    out Time)
      is
         Last : Stream_Element_Offset;
      begin

         if not Buffer.Is_Empty then
            Buffer.Read(Message, Last);
            Length := Last - Message'First + 1;
         else
            Length := 0;
         end if;

         Freshness := Time_First;

      end Non_Blocking_Get;

   end Queueing_Object;


end AFDX.In_Buffers;
