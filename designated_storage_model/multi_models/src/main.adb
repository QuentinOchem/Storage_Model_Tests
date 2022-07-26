with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Logging_Storage_Models; use Logging_Storage_Models;
with Test_Support; use Test_Support;

procedure Main is
   Model_1 : Logging_Storage_Model;
   Model_2 : Logging_Storage_Model;

   type Device_Array_Access_1 is access Integer_Array
     with Designated_Storage_Model => Model_1;

   type Device_Array_Access_2 is access Integer_Array
      with Designated_Storage_Model => Model_2;

   procedure Free is new Ada.Unchecked_Deallocation
     (Integer_Array, Device_Array_Access_1);
   procedure Free is new Ada.Unchecked_Deallocation
      (Integer_Array, Device_Array_Access_2);

   Device_Array_1 : Device_Array_Access_1;
   Device_Array_2 : Device_Array_Access_2;

   Prev_Count_1 : Integer;
   Prev_Count_2 : Integer;
begin
   Model.Display_Log := True;

   Model_1.Display_Log := True;
   Model_2.Display_Log := True;

   Model_1.Name := To_Unbounded_String ("Model 1");
   Model_2.Name := To_Unbounded_String ("Model 2");

   Put_Line ("Initialize Device 1");

   Prev_Count_1 := Model_1.Count_Allocate;
   Device_Array_1 := new Integer_Array (1 .. 10);
   pragma Assert (Model_1.Count_Allocate > Prev_Count_1);

   Put_Line ("Initialize Device 2");

   Prev_Count_2 := Model_2.Count_Allocate;
   Device_Array_2 := new Integer_Array (1 .. 10);
   pragma Assert (Model_2.Count_Allocate > Prev_Count_2);

   Host_Array.all := Test_Array_Value;

   Put_Line ("Copy host to device 1");

   Prev_Count_1 := Model_1.Count_Write;
   Device_Array_1.all := Host_Array.all;
   pragma Assert (Model_1.Count_Write > Prev_Count_1);

   Put_Line ("Copy device 1 to device 2");

   Prev_Count_1 := Model_1.Count_Read;
   Prev_Count_2 := Model_2.Count_Write;
   Device_Array_2.all := Device_Array_1.all;
   pragma Assert (Model_1.Count_Read > Prev_Count_1);
   pragma Assert (Model_2.Count_Write > Prev_Count_2);

   Host_Array.all := Test_Array_Reset;

   Put_Line ("Copy device 2 to host");

   Prev_Count_2 := Model_2.Count_Read;
   Host_Array.all := Device_Array_2.all;
   pragma Assert (Model_2.Count_Read > Prev_Count_2);

   pragma Assert (Host_Array.all = Test_Array_Value);

   Free (Host_Array);

   Put_Line ("Free device 1");

   Prev_Count_1 := Model_1.Count_Deallocate;
   Free (Device_Array_1);
   pragma Assert (Model_1.Count_Deallocate > Prev_Count_1);

   Put_Line ("Free device 2");

   Prev_Count_2 := Model_2.Count_Deallocate;
   Free (Device_Array_2);
   pragma Assert (Model_2.Count_Deallocate > Prev_Count_2);
end;
