with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Deallocation;

with Logging_Storage_Models; use Logging_Storage_Models;
with Test_Support; use Test_Support;
with Types; use Types;

procedure Main is
   type Ptr_Matrix2D_Device is access Matrix2D
     with Designated_Storage_Model => Logging_Storage_Models.Model;

   type Ptr_Matrix3D_Device is access Matrix3D
     with Designated_Storage_Model => Logging_Storage_Models.Model;

   procedure Free is new Ada.Unchecked_Deallocation
     (Matrix2D, Ptr_Matrix2D);

   procedure Free is new Ada.Unchecked_Deallocation
     (Matrix3D, Ptr_Matrix3D);

   Host_2D : Ptr_Matrix2D;
   Device_2D : Ptr_Matrix2D_Device;

   Host_3D : Ptr_Matrix3D;
   Device_3D : Ptr_Matrix3D_Device;
begin
   Device_2D := new Matrix2D (1 .. 10, 10 .. 20);
   Device_3D := new Matrix3D (1 .. 10, 10 .. 20, 20 .. 30);

   Device_2D.all := (others => (others => 0));
   Device_3D.all := (others => (others => (others => 0)));

   Device_2D (2, 15) := 888;
   Device_3D (3, 16, 28) := 999;

   pragma Assert (Device_2D (1, 10) = 0);
   pragma Assert (Device_2D (2, 15) = 888);
   pragma Assert (Device_3D (1, 10, 20) = 0);
   pragma Assert (Device_3D (3, 16, 28) = 999);
   pragma Assert (Model.Count_Write > 0);
   pragma Assert (Model.Count_Read > 0);

end;

