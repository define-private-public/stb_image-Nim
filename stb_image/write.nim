# File:         stb_image/write.nim
# Author:       Benjamin N. Summerton (define-private-public)
# License:      Unlicense (Public Domain)
# Description:  A nim wrapper for stb_image_write.h.


import components
export components.Y
export components.YA
export components.RGB
export components.RGBA
include write_header


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
## same as `w * h * comp`.  This returns a true upon success.
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
##
## By default the stride is set to zero.
proc writePNG*(filename: string; w, h, comp: int; data: seq[uint8]; stride_in_bytes: int = 0): bool {.discardable.} =
  return (stbi_write_png(filename.cstring, w.cint, h.cint, comp.cint, data[0].unsafeAddr, stride_in_bytes) == 1)


## This proc will let you write out data to a BMP file.  `w` and `h` are the
## size of the image you want.  `comp` is how many components make up a single
## pixel (.e.g "RGB", "YA").  The entries in `data` should match be the
## same as `w * h * comp`.  This returns a true upon success.
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
proc writeBMP*(filename: string; w, h, comp: int; data: seq[uint8]): bool {.discardable.} =
  return (stbi_write_bmp(filename.cstring, w.cint, h.cint, comp.cint, data[0].unsafeAddr) == 1)


## This proc will let you write out data to a TGA file.  `w` and `h` are the
## size of the image you want.  `comp` is how many components make up a single
## pixel (.e.g "RGBA," "RGBA", "YA").  The entries in `data` should match be the
## same as `w * h * comp`.  This returns a true upon success.
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
##
## By default this function will save the TGA with run-length encoding, but this
## can be turned off by setting `useRLE` to `false`.
proc writeTGA*(filename: string; w, h, comp: int; data: seq[uint8]; useRLE: bool = true): bool {.discardable.} =
  # Set RLE option
  stbi_write_tga_with_rle = if useRLE: 1 else: 0
  return (stbi_write_tga(filename.cstring, w.cint, h.cint, comp.cint, data[0].unsafeAddr) == 1)


## This proc will let you write out data to a BMP file.  `w` and `h` are the
## size of the image you want.  `comp` is how many components make up a single
## pixel (.e.g "RGB", "YA").  The entries in `data` should match be the
## same as `w * h * comp`.  This returns a true upon success.
##
## From the header file:
## ----
## HDR expects linear float data. Since the format is always 32-bit rgb(e)
## data, alpha (if provided) is discarded, and for monochrome data it is
## replicated across all three channels.
## --
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
proc writeHDR*(filename: string; w, h, comp: int; data: seq[float32]): bool {.discardable.} =
  return (stbi_write_hdr(filename.cstring, w.cint, h.cint, comp.cint, data[0].unsafeAddr) == 1)


# For the moment being, the callback write functions are going to be skipped
# unless there is a request for them.
#
#typedef void stbi_write_func(void *context, void *data, int size);
#int stbi_write_png_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const void  *data, int stride_in_bytes);
#int stbi_write_bmp_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const void  *data);
#int stbi_write_tga_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const void  *data);
#int stbi_write_hdr_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const float *data);

