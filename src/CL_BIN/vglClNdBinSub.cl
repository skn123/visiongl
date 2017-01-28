/** Subtraction or difference between two binary images.

    Subtraction or difference between two binary images. Finds img_input1 minus img_input2 and
    saves in img_output.
  */

__kernel void vglClNdBinSub(__global char* img_input1,
                            __global char* img_input2,
                            __global char* img_output)
{
#if __OPENCL_VERSION__ < 200
  int coord = (  (get_global_id(2) - get_global_offset(2)) * get_global_size(1) * get_global_size(0)) +
              (  (get_global_id(1) - get_global_offset(1)) * get_global_size (0)  ) +
                 (get_global_id(0) - get_global_offset(0));
#else
  int coord = get_global_linear_id();
#endif

  unsigned char p1 =  img_input1[coord];
  unsigned char p2 =  img_input2[coord];
  unsigned char result = p1 & ~p2;
  img_output[coord] = result;
}