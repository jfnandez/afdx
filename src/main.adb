with Ada.Streams; use Ada.Streams;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Exceptions; use Ada.Exceptions;
with System;

with AFDX.System;

procedure Main is

   pragma Priority(System.Default_Priority);

   task ES_SIM_1 is
      pragma Priority(System.Default_Priority);
      entry Release;
   end ES_SIM_1;

   task ES_SIM_2 is
      pragma Priority(System.Default_Priority);
      entry Release;
   end ES_SIM_2;



   task body ES_SIM_1 is
      Socket : AFDX.System.Socket;
      Buffer : Stream_Element_Array(0 .. 255);
   begin

      accept Release;

      for I in Buffer'Range loop
         Buffer(I) := Stream_Element(I);
      end loop;

      Socket.Bind
        (Mode => AFDX.System.Not_Blocking,
         Port => 1);

      for I in 80 .. 100 loop
         Socket.Write(Buffer(0 .. Stream_Element_Offset(I)));
         delay 0.5;
      end loop;

      Put_Line("Done2");

   exception

      when others => Put_Line("ESSIM1 Muerto");

   end ES_SIM_1;



   task body ES_SIM_2 is
      Socket : AFDX.System.Socket;
      Buffer : Stream_Element_Array(1 .. 2000);
      Last   : Stream_Element_Offset;
   begin

      accept Release;

      Socket.Bind
        (Mode => AFDX.System.Blocking,
         Port => 2);

      loop

         Socket.Read(Item => Buffer, Last => Last);

         for I in Buffer'FIrst .. Last loop
            Put(Buffer(I)'Img);
         end loop;

         New_Line;

         delay 1.0;

      end loop;

   exception

      when others => Put_Line("ESSIM2 Muerto");

   end ES_SIM_2;


begin

   --delay 1.0;

  ES_SIM_1.Release;
  ES_SIM_2.Release;

   exception
when Error: others =>
    Put ("Unexpected exception: ");
    Put_Line (Exception_Information(Error));
end Main;

