with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Deallocation;

with Logging_Storage_Models; use Logging_Storage_Models;
with Test_Support; use Test_Support;

procedure Main is
   type R (D : Integer) is record
      S : String (1 .. D);
   end record;

   type Host_Record_Access is access R;
   type Device_Record_Access is access R
     with Designated_Storage_Model => Model;

   procedure Free is new Ada.Unchecked_Deallocation (R, Host_Record_Access);
   procedure Free is new Ada.Unchecked_Deallocation (R, Device_Record_Access);

   Host_Record : Host_Record_Access;
   Device_Record : Device_Record_Access;
   Prev_Count : Integer;
begin
   Model.Display_Log := True;

   Host_Record := new R'(D => 4, S => "1234");

   Put_Line ("Initialize device");

   pragma Assert (Model.Count_Allocate = 0);
   Device_Record := new R (4);
   pragma Assert (Model.Count_Allocate > 0);

   Put_Line ("Copy from host to device");

   Prev_Count := Model.Count_Write;
   Device_Record.all := Host_Record.all;
   pragma Assert (Model.Count_Write > Prev_Count);

   Put_Line ("Copy from device to host");

   Prev_Count := Model.Count_Read;
   Host_Record.all := Device_Record.all;
   pragma Assert (Model.Count_Read > Prev_Count);

   pragma Assert (Host_Record.S = "1234");

   Free (Host_Record);

   Put_Line ("Free device");

   pragma Assert (Model.Count_Deallocate = 0);
   Free (Device_Record);
   pragma Assert (Model.Count_Deallocate = 1);
end;
