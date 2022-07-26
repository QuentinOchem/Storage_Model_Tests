with Ada.Text_IO; use Ada.Text_IO;

with Ada.Unchecked_Deallocation;

with Logging_Storage_Models; use Logging_Storage_Models;
with Test_Support; use Test_Support;

with Gnat.Debug_Pools;

procedure Main is
   type Device_Array_Access is access CInteger_Array
      with Designated_Storage_Model => Logging_Storage_Models.Model;

   procedure Free is new Ada.Unchecked_Deallocation
      (CInteger_Array, Device_Array_Access);

   Device_Array : Device_Array_Access;

   Pool : GNAT.Debug_Pools.Debug_Pool;
begin
   Model.Display_Log := True;

   Device_Array := new Cinteger_Array'(1 .. 3 => 999);

   Put_Line ("Host value: " & Host_Carray.all'Image);
   pragma Assert (Model.Count_Read = 0);
   Host_CArray.all := Device_Array.all;
   pragma Assert (Model.Count_Read = 1);
   Put_Line ("Host value: " & Host_Carray.all'Image);

   pragma Assert (Host_CArray (1 .. 3) = (1 .. 3 => 999));
end;
