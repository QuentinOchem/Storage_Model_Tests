with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Deallocation;

with Logging_Storage_Models; use Logging_Storage_Models;
with Test_Support; use Test_Support;

procedure Main is
   type Some_Rec is record
      A_Integer : Integer;
   end record;

   type Some_Rec_Access_Dev is access Some_Rec
     with Designated_Storage_Model => Logging_Storage_Models.Model;

   procedure Free is new Ada.Unchecked_Deallocation
     (Some_Rec, Some_Rec_Access_Dev);

   Device_Record_Ptr : Some_Rec_Access_Dev;

   Host_Record : Some_Rec := (others => 999);

   type Some_Array is array (Integer range 0 .. 10) of Integer;

   Host_Array : Some_Array := (others => 999);

   Prev_Count : Integer;
begin
   Model.Display_Log := True;

   Pragma Assert (Model.Count_Allocate = 0);
   Device_Record_Ptr := new Some_Rec;
   Pragma Assert (Model.Count_Allocate = 1);

   --  Write the full aggregate
   Prev_Count := Model.Count_Write;
   Device_Record_Ptr.all := (others => 3);
   pragma Assert (Model.Count_Write > Prev_Count);

   --  Read one field
   Put_Line ("Host value: " & Host_Record'Image);
   Prev_Count := Model.Count_Read;
   Host_Record.A_Integer := Device_Record_Ptr.all.A_Integer;
   pragma Assert (Model.Count_Read > Prev_Count);
   Put_Line ("Host value: " & Host_Record'Image);

   --  Write one field
   Host_Record := (others => 0);
   Put_Line ("Host value: " & Host_Record'Image);
   Prev_Count := Model.Count_Write;
   Device_Record_Ptr.all.A_Integer := 888;
   pragma Assert (Model.Count_Write > Prev_Count);
   Host_Record := Device_Record_Ptr.all;
   pragma Assert (Host_Record.A_Integer = 888);
   Put_Line ("Host value: " & Host_Record'Image);

   pragma Assert (Model.Count_Deallocate = 0);
   Free (Device_Record_Ptr);
   pragma Assert (Model.Count_Deallocate = 1);
end;
