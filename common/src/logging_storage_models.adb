with Ada.Text_IO; use Ada.Text_IO;

with System.CRTL; use System.CRTL;

package body Logging_Storage_Models is

   procedure Allocate
     (Model           : in out Logging_Storage_Model;
      Storage_Address : out Logging_Address;
      Size            : Storage_Count;
      Alignment       : Storage_Count)
   is
   begin
      Model.Count_Allocate := @ + 1;
      Storage_Address.Address := Malloc (Size_T (Size));
      Storage_Address.Object_Index := Model.Count_Allocate;

      Put_Line
        ("Allocating"
         & Size'Img
         & " bytes of alignment"
         & Alignment'Img
         & "for object #"
         & Storage_Address.Object_Index'Img);
   end Allocate;

   procedure Deallocate
     (Model           : in out Logging_Storage_Model;
      Storage_Address : Logging_Address;
      Size            : Storage_Count;
      Alignment       : Storage_Count)
   is
   begin
      Model.Count_Deallocate := @ + 1;
      Free (Storage_Address.Address);

      Put_Line
        ("Deallocating"
         & Size'Img
         & " bytes of alignment"
         & Alignment'Img
         & "for object #"
         & Storage_Address.Object_Index'Img);
   end Deallocate;

   procedure Logging_Copy_To
     (Model  : in out Logging_Storage_Model;
      Target : Logging_Address;
      Source : System.Address;
      Size   : Storage_Count)
   is
   begin
      Model.Count_Write := @ + 1;
      Memcpy (Target.Address, Source, size_T (Size));

      Put_Line
        ("Copying"
         & Size'Img
         & " bytes"
         & "to object #"
         & Target.Object_Index'Img);
   end Logging_Copy_To;

   procedure Logging_Copy_From
     (Model  : in out Logging_Storage_Model;
      Target : System.Address;
      Source : Logging_Address;
      Size   : Storage_Count) is
   begin
      Model.Count_Write := @ + 1;
      Memcpy (Target, Source.Address, size_T (Size));

      Put_Line
        ("Copying"
         & Size'Img
         & " bytes"
         & "from object #"
         & Source.Object_Index'Img);
   end Logging_copy_From;

   function Storage_Size
     (Model : Logging_Storage_Model)
      return Storage_Count
   is
   begin
      return 0;
   end Storage_Size;

   function Add_Offset
     (Model : in out Logging_Storage_Model;
      Left  : Logging_Address;
      Right : Storage_Count) return Logging_Address
   is
      Result : Logging_Address;
   begin
      Result.Object_Index := Left.Object_Index;
      Result.Address := Left.Address + Right;

      return Result;
   end Add_Offset;

end Logging_Storage_Models;
