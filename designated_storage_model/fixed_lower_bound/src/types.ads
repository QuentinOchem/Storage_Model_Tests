package Types is

   type FLB is array (Integer range 0 .. <>) of Integer;

   type Ptr_FLB is access all FLB;

end Types;
