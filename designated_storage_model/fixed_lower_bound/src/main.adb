with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Deallocation;

with Logging_Storage_Models; use Logging_Storage_Models;
with Test_Support; use Test_Support;
with Types; use Types;

procedure Main is
   type Ptr_FLB_Device is access FLB
     with Designated_Storage_Model => Logging_Storage_Models.Model;

   Device_FLB : Ptr_FLB_Device;
begin
   Model.Display_Log := True;

   Put_Line ("Allocating on device");

   Device_FLB := new FLB (0 .. 255);

   Put_Line ("Initialize data on device");

   Device_FLB.all := (others => 99);

   Put_Line ("Write single data on device");
   Device_FLB (8) := 888;

   Put_Line ("Checking results");
   pragma Assert (Device_FLB (1) = 99);
   pragma Assert (Device_FLB (8) = 888);
   pragma Assert (Model.Count_Write > 0);
   pragma Assert (Model.Count_Read > 0);

end;

