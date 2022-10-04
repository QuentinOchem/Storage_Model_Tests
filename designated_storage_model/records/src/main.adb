with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Deallocation;

with Logging_Storage_Models; use Logging_Storage_Models;
with Test_Support; use Test_Support;

procedure Main is
   type Simple_Array is array (Integer range 1..2) of Integer;
   type Simple_Record is record
      A, B : Integer;
      C : Float;
      D : Simple_Array;
      E : String(1..3);
   end record;

   type Simple_Record_Host_Access is access Simple_Record;

   type Simple_Record_Device_Access is access Simple_Record
      with Designated_Storage_Model => Logging_Storage_Models.Model;

   Host_Record : Simple_Record_Host_Access;
   Device_Record : Simple_Record_Device_Access;
   Prev_Count : Integer;
begin
   Model.Display_Log := True;

   Put_Line ("Initialize device");

   Host_Record := new Simple_Record;
   Device_Record := new Simple_Record'(11, 21, 3.1, (41,51), "111");

   Put_Line ("Writing aggregate to device");
   Device_Record.all := (10, 20, 3.0, (4,5), "six");

   Put_Line ("Retrieve device values");


   Prev_Count := Model.Count_Read;
   Host_Record.all := (0, 0, 0.0, (0,0), "zer");
   Host_Record.all := Device_Record.all;
   pragma Assert (Model.Count_Read > Prev_Count);

   pragma Assert (Host_Record.all = (10, 20, 3.0, (4, 5), "six"));

   Put_Line ("Write two integer to device");

   Prev_Count := Model.Count_Write;
   Device_Record.A := 30;
   pragma Assert (Model.Count_Write > Prev_Count);

   Prev_Count := Model.Count_Write;
   Device_Record.B := 40;
   pragma Assert (Model.Count_Write > Prev_Count);

   Prev_Count := Model.Count_Write;
   Device_Record.C := 5.0;
   pragma Assert (Model.Count_Write > Prev_Count);

   Prev_Count := Model.Count_Write;
   Device_Record.D := (6, 7);
   pragma Assert (Model.Count_Write > Prev_Count);

   Prev_Count := Model.Count_Write;
   Device_Record.E := "eig";
   pragma Assert (Model.Count_Write > Prev_Count);

   Put_Line ("Retrieve device values");

   Prev_Count := Model.Count_Read;
   Host_Record.all := (0, 0, 0.0, (0, 0), "zer");
   Host_Record.all := Device_Record.all;
   pragma Assert (Model.Count_Read > Prev_Count);

   pragma Assert (Host_Record.all = (30, 40, 5.0, (6, 7), "eig"));
end Main;
