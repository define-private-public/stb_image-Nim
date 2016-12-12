# File:         stb_image_write.nim
# Author:       Benjamin N. Summerton (define-private-public)
# License:      Unlicense (Public Domain)
# Description:  A nim wrapper for stb_image_write.h.


import stb_image_components
export stb_image_components.Y
export stb_image_components.YA
export stb_image_components.RGB
export stb_image_components.RGBA


# Required
{.emit: """
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
""".}


# Internal functions
#int stbi_write_png(char const *filename, int w, int h, int comp, const void  *data, int stride_in_bytes);

proc stbi_write_bmp(
  filename: cstring;
  w, h, comp: cint;
  data: pointer
): cint
  {.importc: "stbi_write_bmp", noDecl.}

#int stbi_write_tga(char const *filename, int w, int h, int comp, const void  *data);
#int stbi_write_hdr(char const *filename, int w, int h, int comp, const float *data);


## TODO documenmt (read over the header file)
## TODO test
proc stbiWriteBMP*(filename: string; w, h, comp: int; data: seq[uint8]): int =
#  var pixelData = cast[ptr void](data[0].unsafeAddr)
  return stbi_write_bmp(filename.cstring, w.cint, h.cint, comp.cint, data[0].unsafeAddr).int


# For the moment being, the callback write functions are going to be skipped
# unless there is a request for them.
#typedef void stbi_write_func(void *context, void *data, int size);
#int stbi_write_png_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const void  *data, int stride_in_bytes);
#int stbi_write_bmp_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const void  *data);
#int stbi_write_tga_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const void  *data);
#int stbi_write_hdr_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const float *data);
