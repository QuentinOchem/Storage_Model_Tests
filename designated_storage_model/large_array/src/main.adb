with Ada.Unchecked_Deallocation;

with Logging_Storage_Models; use Logging_Storage_Models;
with Test_Support; use Test_Support;

procedure Main is
   type Device_Array_Access is access all Integer_Array
      with Designated_Storage_Model => Logging_Storage_Models.Model;

   procedure Free is new Ada.Unchecked_Deallocation
      (Integer_Array, Device_Array_Access);

   N : Integer := 16 * 1024 * 1024;

   Large_Host_Array : Host_Array_Access;
   Large_Device_Array : Device_Array_Access;
begin
   Large_Host_Array := new Integer_Array (1 .. N);
   Large_Device_Array := new Integer_Array (1 .. N);

   Large_Host_Array.all := (others => 999);

   pragma Assert (Model.Count_Write = 0);
   Large_Device_Array.all := Large_Host_Array.all;

   --  Note - we want some liberty has to how such large amount of data is
   --  copied. However, this is a typicall cases where we can't do component by
   --  component copy as this would be too slow. This assumes that we copy at
   --  least 1 Ko of memory at a time.
   pragma Assert (Model.Count_Write <= 16 * 1024);

   Large_Host_Array.all := (others => 0);

   --  Verify an arbitrary position
   pragma Assert (Large_Host_Array (1024 * 1024 * 2 + 4) = 0);

   pragma Assert (Model.Count_Read = 0);
   Large_Host_Array.all := Large_Device_Array.all;
   pragma Assert (Model.Count_Read <= 16 * 1024);

   --  Verify an arbitrary position
   pragma Assert (Large_Host_Array (1024 * 1024 * 2 + 4) = 999);
end Main;
