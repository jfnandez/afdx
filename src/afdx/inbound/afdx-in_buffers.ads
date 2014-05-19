with Stream_Buffers;

package AFDX.In_Buffers is


   type Object is protected interface;
   type Object_Acc is access all Object'Class;


   procedure Put
     (This       : in out Object;
      Stream     : in     Stream_Element_Array) is abstract;


   procedure Blocking_Get
     (This       : in out Object;
      Message    : in out Stream_Element_Array;
      Length     :    out Stream_Element_Count;
      Freshness  :    out Time) is abstract;


   procedure Non_Blocking_Get
     (This       : in out Object;
      Message    : in out Stream_Element_Array;
      Length     :    out Stream_Element_Count;
      Freshness  :    out Time)  is abstract;



   protected type Sampling_Object (Size : Stream_Element_Count) is new Object with

      pragma Priority(AFDX.Inbound_Buffer_Ceil_Prio);


      overriding procedure Put
        (Stream    : in     Stream_Element_Array);


      overriding entry Blocking_Get
        (Message    : in out Stream_Element_Array;
         Length     :    out Stream_Element_Count;
         Freshness  :    out Time);


      overriding procedure Non_Blocking_Get
        (Message    : in out Stream_Element_Array;
         Length     :    out Stream_Element_Count;
         Freshness  :    out Time);

   private
      Is_Ready : Boolean              := False;
      Counter  : Stream_Element_Count := 0;
      Rcv_At   : Time                 := Time_Last;
      Buffer   : Stream_Element_Array(1 .. Size);
   end Sampling_Object;




   protected type Queueing_Object (Size : Stream_Element_Count) is new Object with

      pragma Priority(AFDX.Inbound_Buffer_Ceil_Prio);


      overriding procedure Put
        (Stream    : in     Stream_Element_Array);


      overriding entry Blocking_Get
        (Message    : in out Stream_Element_Array;
         Length     :    out Stream_Element_Count;
         Freshness  :    out Time);


      overriding procedure Non_Blocking_Get
        (Message    : in out Stream_Element_Array;
         Length     :    out Stream_Element_Count;
         Freshness  :    out Time);

   private
      Buffer : aliased Stream_Buffers.Object(Size);
   end Queueing_Object;

end AFDX.In_Buffers;
