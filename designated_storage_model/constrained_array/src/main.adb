with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Deallocation;

with Logging_Storage_Models; use Logging_Storage_Models;
with Test_Support; use Test_Support;

procedure Main is
   type Device_CArray_Access is access Cinteger_Array
   with Designated_Storage_Model => Logging_Storage_Models.Model;

   procedure CFree is new Ada.Unchecked_Deallocation
     (CInteger_Array, Device_CArray_Access);

   Device_CArray : Device_Carray_Access;

   Prev_Count : Integer;
begin
   Model.Display_Log := True;

   Put_Line ("Constrained array test");

   Put_Line ("Initialize device");

   Pragma Assert (Model.Count_Allocate = 0);
   Device_Carray := new Cinteger_Array;
   Pragma Assert (Model.Count_Allocate = 1);

   Host_Carray.all := Test_Carray_Value;

   Put_Line ("Copy from host to device");

   Prev_Count := Model.Count_Write;
   Device_Carray.all := Host_Carray.all;
   pragma Assert (Model.Count_Write > Prev_Count);

   Host_Carray.all := Test_Carray_Reset;

   Put_Line ("Copy from device to host");

   Prev_Count := Model.Count_Read;
   pragma Assert (Host_Carray.all /= Test_Carray_Value);
   Host_Carray.all := Device_Carray.all;
   pragma Assert (Host_Carray.all = Test_Carray_Value);

   Put_Line ("Free device");

   pragma Assert (Model.Count_Deallocate = 0);
   CFree (Device_Carray);
   pragma Assert (Model.Count_Deallocate = 1);
end;
