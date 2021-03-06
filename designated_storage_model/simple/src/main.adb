with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Deallocation;

with Logging_Storage_Models; use Logging_Storage_Models;
with Test_Support; use Test_Support;

procedure Main is
   type Device_Array_Access is access Integer_Array
     with Designated_Storage_Model => Logging_Storage_Models.Model;

   procedure Free is new Ada.Unchecked_Deallocation
     (Integer_Array, Device_Array_Access);

   Device_Array : Device_Array_Access;
   Prev_Count : Integer;
begin
   Model.Display_Log := True;

   Put_Line ("Initialize device");

   pragma Assert (Model.Count_Allocate = 0);
   Device_Array := new Integer_Array (1 .. 10);
   pragma Assert (Model.Count_Allocate > 0);

   Host_Array.all := Test_Array_Value;

   Put_Line ("Copy from host to device");

   Prev_Count := Model.Count_Write;
   Device_Array.all := Host_Array.all;
   pragma Assert (Model.Count_Write > Prev_Count);

   Host_Array.all := Test_Array_Reset;

   Put_Line ("Copy from device to host");

   Prev_Count := Model.Count_Read;
   pragma Assert (Host_Array.all /= Test_Array_Value);
   Host_Array.all := Device_Array.all;
   pragma Assert (Model.Count_Read > Prev_Count);

   pragma Assert (Host_Array.all = Test_Array_Value);

   Free (Host_Array);

   Put_Line ("Free device");

   pragma Assert (Model.Count_Deallocate = 0);
   Free (Device_Array);
   pragma Assert (Model.Count_Deallocate = 1);
end;
