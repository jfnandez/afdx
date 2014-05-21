with Ada.Streams; use Ada.Streams;
with Ada.Text_IO; use Ada.Text_IO;


with AFDX.System;



procedure Main is

   task ES_SIM_1 is
      pragma Priority(20);
      entry Release;
   end ES_SIM_1;

   task ES_SIM_2 is
      pragma Priority(20);
      entry Release;
   end ES_SIM_2;


   task body ES_SIM_1 is
      Socket : AFDX.System.Socket;
      Buffer : Stream_Element_Array(1 .. 5);
   begin

      accept Release;

      for I in Buffer'Range loop
         Buffer(I) := Stream_Element(I);
      end loop;

      Socket.Bind
        (Mode => AFDX.System.Not_Blocking,
         Port => 1);

      loop

         delay 5.0;

         Socket.Write(Buffer);

      end loop;

   end ES_SIM_1;


   task body ES_SIM_2 is
      Socket : AFDX.System.Socket;
      Buffer : Stream_Element_Array(1 .. 200);
      Last   : Stream_Element_Offset;
   begin

      accept Release;

      Socket.Bind
        (Mode => AFDX.System.Not_Blocking,
         Port => 1);

      loop

         Socket.Read
           (Item => Buffer,
            Last => Last);

         for I in Buffer'First .. Last loop
            Put(Buffer(I)'Img);
         end loop;
         Put_Line ("Total :" & Last'Img);

         delay 1.0;

      end loop;

   end ES_SIM_2;



begin

   ES_SIM_1.Release;
   ES_SIM_2.Release;

exception
   when others =>
      Put_Line("Muerto");
end Main;

