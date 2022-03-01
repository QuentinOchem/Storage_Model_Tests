with Ada.Unchecked_Deallocation;

with Logging_Storage_Models; use Logging_Storage_Models;
with Test_Support; use Test_Support;

procedure Main is
   type Simple_Record is record
      A, B : Integer;
   end record;

   type Simple_Record_Host_Access is access Simple_Record
      with Designated_Storage_Model => Logging_Storage_Models.Model;

   type Simple_Record_Device_Access is access Simple_Record
      with Designated_Storage_Model => Logging_Storage_Models.Model;

   Host_Record : Simple_Record_Host_Access;
   Device_Record : Simple_Record_Device_Access;
begin
   Host_Record := new Simple_Record'(10, 20);
   Device_Record := new Simple_Record;

   pragma Assert (Model.Count_Write = 0);
   Device_Record.A := 10;
   pragma Assert (Model.Count_Write = 1);
   Device_Record.B := 20;
   pragma Assert (Model.Count_Write = 2);
   pragma Assert (Model.Count_Read = 0);
   Host_Record.all := Device_Record.all;
   pragma Assert (Model.Count_Read = 1);

   pragma Assert (Host_Record.all = (10, 20));
end Main;
