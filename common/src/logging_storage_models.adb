with System; use System;
with Ada.Unchecked_Conversion;
with Ada.Text_IO; use Ada.Text_IO;

with System.CRTL; use System.CRTL;

package body Logging_Storage_Models is

   function Convert1 is new Ada.Unchecked_Conversion (System.Address, Long_Integer);
   function Convert2 is new Ada.Unchecked_Conversion (Long_Integer, Logging_Address);

   function Convert3 is new Ada.Unchecked_Conversion (Logging_Address, Long_Integer);
   function Convert4 is new Ada.Unchecked_Conversion (Long_Integer, System.Address);

   procedure Log (Model : Logging_Storage_Model; Text : String) is
   begin
      if Model.Display_Log then
         Put_Line (Text);
      end if;
   end Log;

   function Get_Id (Model :  Logging_Storage_Model; Addr : Logging_Address) return Integer is
      Address : Integer with Address => Addr'Address;
   begin
      for R of Model.Ids loop
         if Address >= R.Addr and then Address < R.Addr + Integer (R.Size) then
            return R.Id;
         end if;
      end loop;

      return -1;
   end Get_Id;

   function Host_To_Device (Addr: System.Address) return Logging_Address
   is
      Int_Address : Long_Integer;
   begin
      Int_Address := Convert1 (Addr);
      Int_Address := Int_Address + 2**62;

      return Convert2 (Int_Address);
   end Host_To_Device;

   function Device_To_Host (Addr: Logging_Address) return System.Address
   is
      Int_Address : Long_Integer;
   begin
      Int_Address := Convert3 (Addr);
      Int_Address := Int_Address - 2**62;

      return Convert4 (Int_Address);
   end Device_To_Host;

   procedure Logging_Allocate
     (Model           : in out Logging_Storage_Model;
      Storage_Address : out Logging_Address;
      Size            : Storage_Count;
      Alignment       : Storage_Count)
   is
      New_Region : Region;
      Address : Integer with Address => Storage_Address'Address;
   begin
      Model.Count_Allocate := @ + 1;

      Storage_Address := Host_To_Device (Malloc (Size_T (Size)));

      New_Region.Addr := Address;
      New_Region.Size := Size;
      New_Region.Id := Model.Count_Allocate;

      Model.Ids.Append (New_Region);

      Log
        (Model,
         To_String (Model.Name) & " Allocating"
         & Size'Img
         & " bytes of alignment"
         & Alignment'Img
         & " for object #"
         & Model.Count_Allocate'Img
         & " at virt: "
         & Storage_Address'Img
         & " / real: "
         & Device_To_Host (Storage_Address)'Img);

   end Logging_Allocate;

   procedure Logging_Deallocate
     (Model           : in out Logging_Storage_Model;
      Storage_Address : Logging_Address;
      Size            : Storage_Count;
      Alignment       : Storage_Count)
   is
   begin
      Model.Count_Deallocate := @ + 1;
      Free (System.Address (Device_To_Host (Storage_Address)));

      Log
        (Model,
         To_String (Model.Name) & " Deallocating"
         & Size'Img
         & " bytes of alignment"
         & Alignment'Img
         & " for object #"
         & Integer'Image (Get_Id (Model, Storage_Address)));
   end Logging_Deallocate;

   procedure Logging_Copy_To
     (Model  : in out Logging_Storage_Model;
      Target : Logging_Address;
      Source : System.Address;
      Size   : Storage_Count)
   is
   begin
      Model.Count_Write := @ + 1;
      Memcpy (Device_To_Host (Target), Source, size_T (Size));

      Log
        (Model,
         To_String (Model.Name) & " Copying"
         & Size'Img
         & " bytes to object #"
         & Integer'Image (Get_Id (Model, Target)));
   end Logging_Copy_To;

   procedure Logging_Copy_From
     (Model  : in out Logging_Storage_Model;
      Target : System.Address;
      Source : Logging_Address;
      Size   : Storage_Count) is
   begin
      Model.Count_Read := @ + 1;
      Memcpy (Target, Device_To_Host (Source), size_T (Size));

      Log
        (Model,
         To_String (Model.Name) & " Copying"
         & Size'Img
         & " bytes from object #"
         & Integer'Image (Get_Id (Model, Source)));
   end Logging_copy_From;

   function Logging_Storage_Size
     (Model : Logging_Storage_Model)
      return Storage_Count
   is
   begin
      return 0;
   end Logging_Storage_Size;

end Logging_Storage_Models;
