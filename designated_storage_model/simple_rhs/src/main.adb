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

   Put_Line ("Host value: " & Host_Record'Image);

   Put_Line ("Write to dev");
   Prev_Count := Model.Count_Write;
   Device_Record_Ptr.all.A_Integer := 3;
   pragma Assert (Model.Count_Write > Prev_Count);

   Put_Line ("Read from dev");
   Prev_Count := Model.Count_Read;
   Host_Record := Device_Record_Ptr.all;
   pragma Assert (Model.Count_Read > Prev_Count);
   pragma Assert (Host_Record.A_Integer = 3);

   Put_Line ("Host value: " & Host_Record'Image);

   Prev_Count := Model.Count_Read;
   Host_Array (Device_Record_Ptr.all.A_Integer) := 666;
   pragma Assert (Model.Count_Read > Prev_Count);
   pragma Assert (Host_Array (3) = 666);

   Put_Line ("Host array value: " & Host_Array'Image);

   Prev_Count := Model.Count_Read;
   Host_Array (0) := (Device_Record_Ptr.all.A_Integer + 555);
   pragma Assert (Model.Count_Read > Prev_Count);
   pragma Assert (Host_Array (0) = 555 + 3);

   Put_Line ("Host array value: " & Host_Array'Image);

   pragma Assert (Model.Count_Deallocate = 0);
   Free (Device_Record_Ptr);
   pragma Assert (Model.Count_Deallocate = 1);
end;
