with System; use System;
with System.Storage_Elements; use System.Storage_Elements;

package Logging_Storage_Models is

   type Logging_Storage_Model is record
      Count_Write      : Integer := 0;
      Count_Read       : Integer := 0;
      Count_Allocate   : Integer := 0;
      Count_Deallocate : Integer := 0;
      Display_Log      : Boolean := False;
   end record
     with Storage_Model_Type =>
       (Address_Type          => Logging_Address,
        Allocate              => Logging_Allocate,
        Deallocate            => Logging_Deallocate,
        Copy_To               => Logging_Copy_To,
        Copy_From             => Logging_Copy_From,
        Storage_Size          => Logging_Storage_Size,
        Add_Offset            => Logging_Add_Offset,
        Null_Address          => Logging_Null_Address);

   type Logging_Address is record
      Address      : System.Address;
      Object_Index : Integer;
   end record;

   Logging_Null_Address : constant Logging_Address := (System.Null_Address, 0);

   procedure Allocate
     (Model           : in out Logging_Storage_Model;
      Storage_Address : out Logging_Address;
      Size            : Storage_Count;
      Alignment       : Storage_Count);

   procedure Deallocate
     (Model           : in out Logging_Storage_Model;
      Storage_Address : Logging_Address;
      Size            : Storage_Count;
      Alignment       : Storage_Count);

   procedure Logging_Copy_To
     (Model  : in out Logging_Storage_Model;
      Target : Logging_Address;
      Source : System.Address;
      Size   : Storage_Count);

   procedure Logging_Copy_From
     (Model  : in out Logging_Storage_Model;
      Target : System.Address;
      Source : Logging_Address;
      Size   : Storage_Count);

   function Storage_Size
     (Model : Logging_Storage_Model)
   return Storage_Count;

   function Add_Offset
     (Model : in out Logging_Storage_Model;
      Left  : Logging_Address;
      Right : Storage_Count) return Logging_Address;

   Model : Logging_Storage_Model;

end Logging_Storage_Models;
