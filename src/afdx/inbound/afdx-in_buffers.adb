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

         Non_Blocking_Get
           (Message   => Message,
            Length    => Length,
            Freshness => Freshness);

      end Blocking_Get;


      --overriding
      procedure Non_Blocking_Get
        (Message    : in out Stream_Element_Array;
         Length     :    out Stream_Element_Count;
         Freshness  :    out Time)
      is
         First : constant Stream_Element_Offset := Message'First;
         Last  : constant Stream_Element_Offset := Message'First + Counter - 1;
      begin

         if Message'Length >= Counter then
            Message(First .. Last) := Buffer(1 .. Counter);
            Length                 := Counter;
            Freshness              := TimeStamp;
         else
            raise Program_Error with "Sampling array too small.";
         end if;

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
         Freshness  :    out Time) when Buffer.Readable_Elements >= Request_Size
      is
      begin

         if Buffer.Readable_Elements < Message'Length then
            Request_Size := Message'Length;
            requeue Blocking_Get;
         end if;

         Buffer.Read(Message, Length);
         Length := Message'Length;
         Freshness := Time_First;

         Request_Size := 0;

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
