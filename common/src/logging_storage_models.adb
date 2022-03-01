with Ada.Text_IO; use Ada.Text_IO;

with System.CRTL; use System.CRTL;

package body Logging_Storage_Models is

   procedure Log (Model : Logging_Storage_Model; Text : String) is
   begin
      if Model.Display_Log then
         Put_Line (Text);
      end if;
   end Log;

   procedure Logging_Allocate
     (Model           : in out Logging_Storage_Model;
      Storage_Address : out Logging_Address;
      Size            : Storage_Count;
      Alignment       : Storage_Count)
   is
   begin
      Model.Count_Allocate := @ + 1;
      Storage_Address := Logging_Address (Malloc (Size_T (Size)));
      Model.Ids.Insert (Storage_Address, Model.Count_Allocate);

      Log
        (Model,
         "Allocating"
         & Size'Img
         & " bytes of alignment"
         & Alignment'Img
         & "for object #"
         & Model.Count_Allocate'Img);
   end Logging_Allocate;

   procedure Logging_Deallocate
     (Model           : in out Logging_Storage_Model;
      Storage_Address : Logging_Address;
      Size            : Storage_Count;
      Alignment       : Storage_Count)
   is
   begin
      Model.Count_Deallocate := @ + 1;
      Free (System.Address (Storage_Address));

      Log
        (Model,
         "Deallocating"
         & Size'Img
         & " bytes of alignment"
         & Alignment'Img
         & "for object #"
         & Integer'Image (Model.Ids.Element (Storage_Address)));
   end Logging_Deallocate;

   procedure Logging_Copy_To
     (Model  : in out Logging_Storage_Model;
      Target : Logging_Address;
      Source : System.Address;
      Size   : Storage_Count)
   is
   begin
      Model.Count_Write := @ + 1;
      Memcpy (System.Address (Target), Source, size_T (Size));

      Log
        (Model,
         "Copying"
         & Size'Img
         & " bytes"
         & "to object #"
         & Integer'Image (Model.Ids.Element (Target)));
   end Logging_Copy_To;

   procedure Logging_Copy_From
     (Model  : in out Logging_Storage_Model;
      Target : System.Address;
      Source : Logging_Address;
      Size   : Storage_Count) is
   begin
      Model.Count_Read := @ + 1;
      Memcpy (Target, System.Address (Source), size_T (Size));

      Log
        (Model,
         "Copying"
         & Size'Img
         & " bytes"
         & "from object #"
         & Integer'Image (Model.Ids.Element (Source)));
   end Logging_copy_From;

   function Logging_Storage_Size
     (Model : Logging_Storage_Model)
      return Storage_Count
   is
   begin
      return 0;
   end Logging_Storage_Size;

end Logging_Storage_Models;
