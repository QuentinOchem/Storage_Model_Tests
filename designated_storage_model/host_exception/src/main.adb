with Ada.Unchecked_Deallocation;

with Logging_Storage_Models; use Logging_Storage_Models;
with Test_Support; use Test_Support;

procedure Main is
   type Device_Array_Access is access Integer_Array
      with Designated_Storage_Model => Logging_Storage_Models.Model;

   Device_Array : Device_Array_Access;
   Got_Exception : Boolean := False;
begin
   Device_Array := new Integer_Array'(1 .. 20 => 999);

   begin
      -- Here host array has 10 elements, device array has 20, exception should
      -- be raised.
      Host_Array.all := Device_Array.all;
   exception
      when Constraint_Error =>
         Got_Exception := True;
   end;

   pragma Assert (Got_Exception);
end;
