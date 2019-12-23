# File:         stb_image/write.nim
# Author:       Benjamin N. Summerton (define-private-public)
# License:      Unlicense (Public Domain)
# Description:  A nim wrapper for stb_image_write.h.


import streams
import sequtils

import components
export components.Y
export components.YA
export components.RGB
export components.RGBA

when defined(windows) and defined(vcc):
  {.pragma: stbcall, stdcall.}
else:
  {.pragma: stbcall, cdecl.}

# Include the header
{.compile: "stb_image/write.c".}

when defined(Posix) and not defined(haiku):
  {.passl: "-lm".}


# Used for set if the TGA function should use run length encoding
var stbi_write_tga_with_rle {.importc: "stbi_write_tga_with_rle".}: cint


# Internal functions
proc stbi_write_png(
  filename: cstring;
  w, h, comp: cint;
  data: pointer,
  stride_in_bytes: int
): cint
  {.importc: "stbi_write_png", stbcall.}

proc stbi_write_bmp(
  filename: cstring;
  w, h, comp: cint;
  data: pointer
): cint
  {.importc: "stbi_write_bmp", stbcall.}

proc stbi_write_tga(
  filename: cstring;
  w, h, comp: cint;
  data: pointer
): cint
  {.importc: "stbi_write_tga", stbcall.}

proc stbi_write_hdr(
  filename: cstring;
  w, h, comp: cint;
  data: ptr cfloat
): cint
  {.importc: "stbi_write_hdr", stbcall.}

proc stbi_write_jpg(
  filename: cstring;
  w, h, comp: cint;
  data: pointer;
  quality: cint;
): cint
  {.importc: "stbi_write_jpg", stbcall.}


## This proc will let you write out data to a PNG file.  `w` and `h` are the
## size of the image you want.  `comp` is how many components make up a single
## pixel (.e.g "RGBA," "RGB", "YA").  The entries in `data` should match be the
## same as `w * h * comp`.  This returns a true upon success.
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
##
## By default the stride is set to zero.
proc writePNG*(filename: string; w, h, comp: int; data: openarray[byte]; stride_in_bytes: int = 0): bool {.discardable.} =
  return (stbi_write_png(filename.cstring, w.cint, h.cint, comp.cint, data[0].unsafeAddr, stride_in_bytes) == 1)


## This proc will let you write out data to a BMP file.  `w` and `h` are the
## size of the image you want.  `comp` is how many components make up a single
## pixel (.e.g "RGB", "YA").  The entries in `data` should match be the
## same as `w * h * comp`.  This returns a true upon success.
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
proc writeBMP*(filename: string; w, h, comp: int; data: openarray[byte]): bool {.discardable.} =
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
proc writeTGA*(filename: string; w, h, comp: int; data: openarray[byte]; useRLE: bool = true): bool {.discardable.} =
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
proc writeHDR*(filename: string; w, h, comp: int; data: openarray[float32]): bool {.discardable.} =
  return (stbi_write_hdr(filename.cstring, w.cint, h.cint, comp.cint, data[0].unsafeAddr) == 1)


## This proc will let you write out data to a JPEG file.  `w` and `h` are the
## size of the image you want.  `comp` is how many components make up a single
## pixel (.e.g "RGB", "YA").  `quality` is how well the quality of the saved 
## JPEG image should be.  It should be a value between [1, 100].  1 for the
## lowest quality and 100 for the highest.  Higher quality will result in larger
## file sizes.  The entries in `data` should match be the same as `w * h * comp`
## .  This returns a true upon success.
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
proc writeJPG*(filename: string; w, h, comp: int; data: openarray[byte]; quality: int): bool {.discardable.} =
  return (stbi_write_jpg(filename.cstring, w.cint, h.cint, comp.cint, data[0].unsafeAddr, quality.cint) == 1)



# Callback prototype for the `*_func` writing functions
type writeCallback* = proc (context, data: pointer, size: cint) {.cdecl.}


proc stbi_write_png_to_func(
  fn: writeCallback,
  context: pointer,
  w, h, comp: cint,
  data: pointer,
  stride_in_bytes: cint
): cint
  {.importc: "stbi_write_png_to_func", stbcall.}

proc stbi_write_bmp_to_func(
  fn: writeCallback,
  context: pointer,
  w, h, comp: cint,
  data: pointer
): cint
  {.importc: "stbi_write_bmp_to_func", stbcall.}

proc stbi_write_tga_to_func(
  fn: writeCallback,
  context: pointer,
  w, h, comp: cint,
  data: pointer
): cint
  {.importc: "stbi_write_tga_to_func", stbcall.}

proc stbi_write_hdr_to_func(
  fn: writeCallback,
  context: pointer,
  w, h, comp: cint,
  data: pointer
): cint
  {.importc: "stbi_write_hdr_to_func", stbcall.}

proc stbi_write_jpg_to_func(
  fn: writeCallback,
  context: pointer,
  w, h, comp: cint,
  data: pointer,
  quality: cint
): cint
  {.importc: "stbi_write_jpg_to_func", stbcall.}


proc streamWriteData(context, data: pointer, size: cint) {.cdecl.} =
  if size > 0:
    let stream = cast[ptr StringStream](context)
    stream[].writeData(data, size)


## This proc will let you write out PNG data to memory.  `w` and `h` are the
## size of the image you want.  `comp` is how many components make up a single
## pixel (.e.g "RGBA," "RGB", "YA").  The entries in `data` should match be the
## same as `w * h * comp`.  This raises an IOError exception on failure.
## Returns a binary sequence contaning the PNG data.
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
##
## By default the stride is set to zero.
proc writePNG*(w, h, comp: int; data: openarray[byte]; stride_in_bytes: int = 0): seq[byte] =
  var buffer = newStringStream()

  if stbi_write_png_to_func(streamWriteData, buffer.addr, w.cint, h.cint, comp.cint, data[0].unsafeAddr, stride_in_bytes.cint) != 1:
    raise newException(IOError, "Failed to write PNG to memory")

  return cast[seq[byte]](buffer.data)


## This proc will let you write out BMP data to memory.  `w` and `h` are the
## size of the image you want.  `comp` is how many components make up a single
## pixel (.e.g "RGB", "YA").  The entries in `data` should match be the
## same as `w * h * comp`.  This raises an IOError exception on failure.
##
## Returns a binary sequence contaning the BMP data.
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
proc writeBMP*(w, h, comp: int; data: openarray[byte]): seq[byte] =
  var buffer = newStringStream()

  if stbi_write_bmp_to_func(streamWriteData, buffer.addr, w.cint, h.cint, comp.cint, data[0].unsafeAddr) != 1:
    raise newException(IOError, "Failed to write BMP to memory")

  return cast[seq[byte]](buffer.data)

## This proc will let you write out TGA data to memory.  `w` and `h` are the
## size of the image you want.  `comp` is how many components make up a single
## pixel (.e.g "RGBA," "RGBA", "YA").  The entries in `data` should match be the
## same as `w * h * comp`.  This raises an IOError exception on failure.
##
## Returns a binary sequence contaning the TGA data.
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
##
## By default this function will save the TGA with run-length encoding, but this
## can be turned off by setting `useRLE` to `false`.
proc writeTGA*(w, h, comp: int; data: openarray[byte]; useRLE: bool = true): seq[byte] =
  # Set RLE option
  stbi_write_tga_with_rle = if useRLE: 1 else: 0
  var buffer = newStringStream()

  if stbi_write_tga_to_func(streamWriteData, buffer.addr, w.cint, h.cint, comp.cint, data[0].unsafeAddr) != 1:
    raise newException(IOError, "Failed to write TGA to memory")

  return cast[seq[byte]](buffer.data)


## This proc will let you write out HDR data to memory.  `w` and `h` are the
## size of the image you want.  `comp` is how many components make up a single
## pixel (.e.g "RGB", "YA").  The entries in `data` should match be the
## same as `w * h * comp`.  This raises an IOError exception on failure.
##
## Returns a binary sequence contaning the HDR data.
##
## From the header file:
## ----
## HDR expects linear float data. Since the format is always 32-bit rgb(e)
## data, alpha (if provided) is discarded, and for monochrome data it is
## replicated across all three channels.
## --
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
proc writeHDR*(w, h, comp: int; data: openarray[byte]): seq[byte] =
  var buffer = newStringStream()

  if stbi_write_hdr_to_func(streamWriteData, buffer.addr, w.cint, h.cint, comp.cint, data[0].unsafeAddr) != 1:
    raise newException(IOError, "Failed to write HDR to memory")

  return cast[seq[byte]](buffer.data)


## This proc will let you write out JPG data to memory.  `w` and `h` are the
## size of the image you want.  `comp` is how many components make up a single
## pixel (.e.g "RGB", "YA").  `quality` is how well the quality of the saved 
## JPEG image should be.  It should be a value between [1, 100].  1 for the
## lowest quality and 100 for the highest.  Higher quality will result in larger
## file sizes.  The entries in `data` should match be the same as `w * h * comp`
## .  This raises an IOError exception on failure.
##
## Returns a binary sequence contaning the JPG data.
##
## Please see the documentation in the `stbi_image_write.h` file for more info.
proc writeJPG*(w, h, comp: int; data: openarray[byte]; quality: int): seq[byte] =
  var buffer = newStringStream()

  if stbi_write_jpg_to_func(streamWriteData, buffer.addr, w.cint, h.cint, comp.cint, data[0].unsafeAddr, quality.cint) != 1:
    raise newException(IOError, "Failed to write JPG to memory")

  return cast[seq[byte]](buffer.data)

