# File:         stb_image_write.nim
# Author:       Benjamin N. Summerton (define-private-public)
# License:      Unlicense (Public Domain)
# Description:  A nim wrapper for stb_image_write.h.


import stb_image_components
export stb_image_components.Y
export stb_image_components.YA
export stb_image_components.RGB
export stb_image_components.RGBA
import stb_image_write_header

# Used for set if the TGA function should use run length encoding
var stbi_write_tga_with_rle {.importc: "stbi_write_tga_with_rle".}: cint


# Internal functions
proc stbi_write_png(
  filename: cstring;
  w, h, comp: cint;
  data: pointer,
  stride_in_bytes: int
): cint
  {.importc: "stbi_write_png", noDecl.}

proc stbi_write_bmp(
  filename: cstring;
  w, h, comp: cint;
  data: pointer
): cint
  {.importc: "stbi_write_bmp", noDecl.}

proc stbi_write_tga(
  filename: cstring;
  w, h, comp: cint;
  data: pointer
): cint
  {.importc: "stbi_write_tga", noDecl.}

proc stbi_write_hdr(
  filename: cstring;
  w, h, comp: cint;
  data: ptr cfloat
): cint
  {.importc: "stbi_write_hdr", noDecl.}


## This proc will let you write out data to a PNG file.  `w` and `h` are the
## size of the image you want.  `comp` is how many components make up a single
## pixel (.e.g "RGBA," "RGB", "YA").  The entries in `data` should match be the
## same as `w * h * comp`.  This returns a non-zero value upon success.
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
##
## By default the stride is set to zero.
proc stbiWritePNG*(filename: string; w, h, comp: int; data: seq[uint8]; stride_in_bytes: int = 0): int =
  return stbi_write_png(filename.cstring, w.cint, h.cint, comp.cint, data[0].unsafeAddr, stride_in_bytes).int


## This proc will let you write out data to a BMP file.  `w` and `h` are the
## size of the image you want.  `comp` is how many components make up a single
## pixel (.e.g "RGB", "YA").  The entries in `data` should match be the
## same as `w * h * comp`.  This returns a non-zero value upon success.
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
proc stbiWriteBMP*(filename: string; w, h, comp: int; data: seq[uint8]): int =
  return stbi_write_bmp(filename.cstring, w.cint, h.cint, comp.cint, data[0].unsafeAddr).int


## This proc will let you write out data to a TGA file.  `w` and `h` are the
## size of the image you want.  `comp` is how many components make up a single
## pixel (.e.g "RGBA," "RGBA", "YA").  The entries in `data` should match be the
## same as `w * h * comp`.  This returns a non-zero value upon success.
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
##
## By default this function will save the TGA with run-length encoding, but this
## can be turned off by setting `useRLE` to `false`.
proc stbiWriteTGA*(filename: string; w, h, comp: int; data: seq[uint8]; useRLE: bool = true): int =
  # Set RLE option
  stbi_write_tga_with_rle = if useRLE: 1 else: 0
  return stbi_write_tga(filename.cstring, w.cint, h.cint, comp.cint, data[0].unsafeAddr).int


## This proc will let you write out data to a BMP file.  `w` and `h` are the
## size of the image you want.  `comp` is how many components make up a single
## pixel (.e.g "RGB", "YA").  The entries in `data` should match be the
## same as `w * h * comp`.  This returns a non-zero value upon success.
##
## From the header file:
## ----
## HDR expects linear float data. Since the format is always 32-bit rgb(e)
## data, alpha (if provided) is discarded, and for monochrome data it is
## replicated across all three channels.
## --
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
proc stbiWriteHDR*(filename: string; w, h, comp: int; data: seq[float32]): int =
  return stbi_write_hdr(filename.cstring, w.cint, h.cint, comp.cint, data[0].unsafeAddr).int


# For the moment being, the callback write functions are going to be skipped
# unless there is a request for them.
#
#typedef void stbi_write_func(void *context, void *data, int size);
#int stbi_write_png_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const void  *data, int stride_in_bytes);
#int stbi_write_bmp_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const void  *data);
#int stbi_write_tga_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const void  *data);
#int stbi_write_hdr_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const float *data);

