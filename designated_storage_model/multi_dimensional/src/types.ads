package Types is

   type Matrix2D is array (Integer range <>, Integer range <>) of Integer;

   type Ptr_Matrix2D is access all Matrix2D;

   type Matrix3D is array
     (Integer range <>,
      Integer range <>,
      Integer range <>) of Integer;

   type Ptr_Matrix3D is access all Matrix3D;

end Types;
