with System; use System;
with System.Storage_Elements; use System.Storage_Elements;

with Ada.Containers.Ordered_Maps;

package Logging_Storage_Models is

   type Logging_Address is new System.Address;

   package Object_Ids is new Ada.Containers.Ordered_Maps
     (Logging_Address, Integer);

   type Logging_Storage_Model is limited record
      Count_Write      : Integer := 0;
      Count_Read       : Integer := 0;
      Count_Allocate   : Integer := 0;
      Count_Deallocate : Integer := 0;
      Display_Log      : Boolean := False;
      Ids              : Object_Ids.Map;
   end record
     with Storage_Model_Type =>
       (Address_Type          => Logging_Address,
        Allocate              => Logging_Allocate,
        Deallocate            => Logging_Deallocate,
        Copy_To               => Logging_Copy_To,
        Copy_From             => Logging_Copy_From,
        Storage_Size          => Logging_Storage_Size,
        Null_Address          => Logging_Null_Address);

   Logging_Null_Address : constant Logging_Address :=
     Logging_Address (System.Null_Address);

   procedure Logging_Allocate
     (Model           : in out Logging_Storage_Model;
      Storage_Address : out Logging_Address;
      Size            : Storage_Count;
      Alignment       : Storage_Count);

   procedure Logging_Deallocate
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

   function Logging_Storage_Size
     (Model : Logging_Storage_Model)
   return Storage_Count;

   Model : Logging_Storage_Model;

end Logging_Storage_Models;
