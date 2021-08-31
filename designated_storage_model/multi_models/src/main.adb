with Ada.Unchecked_Deallocation;

with Logging_Storage_Models; use Logging_Storage_Models;
with Test_Support; use Test_Support;

procedure Main is
   Model_1 : Logging_Storage_Model;
   Model_2 : Logging_Storage_Model;

   type Device_Array_Access_1 is access all Integer_Array
     with Designated_Storage_Model => Model_1;

   type Device_Array_Access_2 is access all Integer_Array
      with Designated_Storage_Model => Model_2;

   procedure Free is new Ada.Unchecked_Deallocation
     (Integer_Array, Device_Array_Access_1);
   procedure Free is new Ada.Unchecked_Deallocation
      (Integer_Array, Device_Array_Access_2);

   Device_Array_1 : Device_Array_Access_1;
   Device_Array_2 : Device_Array_Access_2;
begin
   Model.Display_Log := True;
   Model_2.Display_Log := True;

   pragma Assert (Model_1.Count_Allocate = 0);
   Device_Array_1 := new Integer_Array (1 .. 10);
   pragma Assert (Model_1.Count_Allocate = 1);

   pragma Assert (Model_2.Count_Allocate = 0);
   Device_Array_2 := new Integer_Array (1 .. 10);
   pragma Assert (Model_2.Count_Allocate = 1);

   Host_Array.all := Test_Array_Value;

   pragma Assert (Model_1.Count_Write = 0);
   Device_Array_1.all := Host_Array.all;
   pragma Assert (Model_1.Count_Write = 1);

   pragma Assert (Model_1.Count_Read = 0);
   pragma Assert (Model_2.Count_Write = 0);
   Device_Array_2.all := Device_Array_1.all;
   pragma Assert (Model_1.Count_Read = 1);
   pragma Assert (Model_2.Count_Write = 1);

   Host_Array.all := Test_Array_Reset;

   pragma Assert (Model_2.Count_Read = 0);
   Host_Array.all := Device_Array_2.all;
   pragma Assert (Model_2.Count_Read = 1);

   pragma Assert (Host_Array.all = Test_Array_Value);

   Free (Host_Array);

   pragma Assert (Model_1.Count_Deallocate = 0);
   Free (Device_Array_1);
   pragma Assert (Model_1.Count_Deallocate = 1);

   pragma Assert (Model_2.Count_Deallocate = 0);
   Free (Device_Array_2);
   pragma Assert (Model_2.Count_Deallocate = 1);
end;
