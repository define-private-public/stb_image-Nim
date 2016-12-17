# File:         stb_image.nim
# Author:       Benjamin N. Summerton (define-private-public)
# License:      Unlicense (Public Domain)
# Description:  A nim wrapper for stb_image.h.


import stb_image_components
export stb_image_components.Default
export stb_image_components.Grey
export stb_image_components.GreyAlpha
export stb_image_components.RGB
export stb_image_components.RGBA


# Required
{.emit: """
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
""".}


# NOTE: this function is here for completness, but it's not exposed in the
#       nim-friendly API, since seq[uint8] are GC'd
proc stbi_image_free(retval_from_stbi_load: ptr)
  {.importc: "stbi_image_free", noDecl.}


# NOTE: because of identifiers work in Nim, I need to add that extra "_internal"
#       there.
proc stbi_failure_reason_internal(): cstring
  {.importc: "stbi_failure_reason", noDecl.}


## Get an error message for why a read might have failed.  This is not a
## threadsafe function.
proc stbiFailureReason*(): string =
  return $stbi_failure_reason_internal()



# ==================
# 8 bits per channel
# ==================

proc stbi_load(
  filename: cstring;
  x, y, channels_in_file: var cint;
  desired_channels: cint
): ptr cuchar
  {.importc: "stbi_load", noDecl.}

proc stbi_load_from_memory(
  buffer: ptr cuchar;
  len: cint;
  x, y, channels_in_file: var cint;
  desired_channels: cint
): ptr cuchar
  {.importc: "stbi_load_from_memory", noDecl.}

# Right now I'm not planning on using the callback functions, but if someone
# requests it (or provides a pull request), I'll consider adding them in.
#stbi_uc *stbi_load_from_callbacks(stbi_io_callbacks const *clbk, void *user, int *x, int *y, int *channels_in_file, int desired_channels);

proc stbi_load_from_file(
  f: File;
  x, y, channels_in_file: var cint;
  desired_channels: cint
): ptr cuchar
  {.importc: "stbi_load_from_file", noDecl.}


## This takes in a filename and will return a sequence (of unsigned bytes) that
## is the pixel data. `x`, `y` are the dimensions of the image, and
## `channels_in_file` is the format (e.g. "RGBA," "GreyAlpha," etc.).
## `desired_channels` will attempt to change it to with format you would like
## though it's not guarenteed.  Set it to `0` if you don't care (a.k.a
## "Default").
proc stbiLoad*(filename: string; x, y, channels_in_file: var int; desired_channels: int): seq[uint8] =
  var
    width: cint
    height: cint
    components: cint

  # Read
  let data = stbi_load(filename.cstring, width, height, components, desired_channels.cint)

  # Set the returns
  x = width.int
  y = height.int
  channels_in_file = components.int

  # Copy pixel data
  var pixelData: seq[uint8]
  newSeq(pixelData, x * y * channels_in_file)
  copyMem(pixelData[0].addr, data, pixelData.len)

  # Free loaded image data
  stbi_image_free(data)

  return pixelData


# TODO should there be an overload that has a string instead?
## This takes in a sequences of bytes (of an image file)
## and will return a sequence (of unsigned bytes) that
## is the pixel data. `x`, `y` are the dimensions of the image, and
## `channels_in_file` is the format (e.g. "RGBA," "GreyAlpha," etc.).
## `desired_channels` will attempt to change it to with format you would like
## though it's not guarenteed.  Set it to `0` if you don't care (a.k.a
## "Default").
proc stbiLoadFromMemory*(buffer: seq[uint8]; x, y, channels_in_file: var int; desired_channels: int): seq[uint8] =
  var
    # Cast the buffer to another data type
    castedBuffer = cast[ptr cuchar](buffer[0].unsafeAddr)

    # Return values
    width: cint
    height: cint
    components: cint

  # Read
  let data = stbi_load_from_memory(castedBuffer, buffer.len.cint, width, height, components, desired_channels.cint)

  # Set the returns
  x = width.int
  y = height.int
  channels_in_file = components.int

  # Copy pixel data
  var pixelData: seq[uint8]
  newSeq(pixelData, x * y * channels_in_file)
  copyMem(pixelData[0].addr, data, pixelData.len)

  # Free loaded image data
  stbi_image_free(data)

  return pixelData


## This takes in a File and will return a sequence (of unsigned bytes) that
## is the pixel data. `x`, `y` are the dimensions of the image, and
## `channels_in_file` is the format (e.g. "RGBA," "GreyAlpha," etc.).
## `desired_channels` will attempt to change it to with format you would like
## though it's not guarenteed.  Set it to `0` if you don't care (a.k.a
## "Default").
##
## This will also close the file handle too.
proc stbiLoadFromFile*(f: File, x, y, channels_in_file: var int, desired_channels: int): seq[uint8] =
  var
    width: cint
    height: cint
    components: cint

  # Read
  let data = stbi_load_from_file(f, width, height, components, desired_channels.cint)

  # Set the returns
  x = width.int
  y = height.int
  channels_in_file = components.int

  # Copy pixel data
  var pixelData: seq[uint8]
  newSeq(pixelData, x * y * channels_in_file)
  copyMem(pixelData[0].addr, data, pixelData.len)

  # Free loaded image data
  stbi_image_free(data)

  return pixelData



# ===================
# 16 bits per channel
# ===================

proc stbi_load_16(
  filename: cstring;
  x, y, channels_in_file: var cint,
  desired_channels: cint
): ptr cushort
  {.importc: "stbi_load_16", noDecl.}

proc stbi_load_from_file_16(
  f: File;
  x, y, channels_in_file: var cint;
  desired_channels: cint
): ptr cushort
  {.importc: "stbi_load_from_file_16", noDecl.}


## This takes in a filename and will return a sequence (of unsigned shorts) that
## is the pixel data. `x`, `y` are the dimensions of the image, and
## `channels_in_file` is the format (e.g. "RGBA," "GreyAlpha," etc.).
## `desired_channels` will attempt to change it to with format you would like
## though it's not guarenteed.  Set it to `0` if you don't care (a.k.a
## "Default").
##
## This is used for files where the channels for the pixel data are encoded as
## 16 bit integers (e.g. some Photoshop files).
proc stbiLoad16*(filename: string; x, y, channels_in_file: var int; desired_channels: int): seq[uint16] =
  var
    width: cint
    height: cint
    components: cint

  # Read
  let data = stbi_load_16(filename.cstring, width, height, components, desired_channels.cint)

  # Set the returns
  x = width.int
  y = height.int
  channels_in_file = components.int

  echo x
  echo y
  echo channels_in_file
  echo stbiFailureReason()

  # Copy pixel data
  var pixelData: seq[uint16]
  newSeq(pixelData, x * y * channels_in_file)
  copyMem(pixelData[0].addr, data, pixelData.len)

  # Free loaded image data
  stbi_image_free(data)

  return pixelData


## This takes in a File and will return a sequence (of unsigned shorts) that
## is the pixel data. `x`, `y` are the dimensions of the image, and
## `channels_in_file` is the format (e.g. "RGBA," "GreyAlpha," etc.).
## `desired_channels` will attempt to change it to with format you would like
## though it's not guarenteed.  Set it to `0` if you don't care (a.k.a
## "Default").
##
## This will also close the file handle too.
##
## This is used for files where the channels for the pixel data are encoded as
## 16 bit integers (e.g. some Photoshop files).
proc stbiLoadFromFile16*(f: File; x, y, channels_in_file: var int; desired_channels: int): seq[uint16] =
  var
    width: cint
    height: cint
    components: cint

  # Read
  let data = stbi_load_from_file(f, width, height, components, desired_channels.cint)

  # Set the returns
  x = width.int
  y = height.int
  channels_in_file = components.int

  # Copy pixel data
  var pixelData: seq[uint16]
  newSeq(pixelData, x * y * channels_in_file)
  copyMem(pixelData[0].addr, data, pixelData.len)

  # Free loaded image data
  stbi_image_free(data)

  return pixelData



# =======================
# Float channel interface
# =======================

proc stbi_loadf(
  filename: cstring;
  x, y, channels_in_file: var cint;
  desired_channels: cint
): ptr cfloat
  {.importc: "stbi_loadf", noDecl.}

proc stbi_loadf_from_memory(
  buffer: ptr cuchar;
  len: cint;
  x, y, channels_in_file: var cint;
  desired_channels: cint
): ptr cfloat
  {.importc: "stbi_loadf_from_memory", noDecl.}

# The callback functions are going to be skipped (see the README.md)
#float *stbi_loadf_from_callbacks(stbi_io_callbacks const *clbk, void *user, int *x, int *y, int *channels_in_file, int desired_channels);

proc stbi_loadf_from_file(
  f: File;
  x, y, channels_in_file: var cint;
  desired_channels: cint
): ptr cfloat
  {.importc: "stbi_loadf_from_file", noDecl.}


## This takes in a filename and will return a sequence (of 32 bit floats) that
## is the pixel data. `x`, `y` are the dimensions of the image, and
## `channels_in_file` is the format (e.g. "RGBA," "GreyAlpha," etc.).
## `desired_channels` will attempt to change it to with format you would like
## though it's not guarenteed.  Set it to `0` if you don't care (a.k.a
## "Default").
proc stbiLoadF*(filename: string; x, y, channels_in_file: var int; desired_channels: int): seq[float32] =
  var
    width: cint
    height: cint
    components: cint

  # Read
  let data = stbi_loadf(filename.cstring, width, height, components, desired_channels.cint)

  # Set the returns
  x = width.int
  y = height.int
  channels_in_file = components.int

  # Copy pixel data
  var pixelData: seq[float32]
  newSeq(pixelData, x * y * channels_in_file)
  copyMem(pixelData[0].addr, data, pixelData.len)

  # Free loaded image data
  stbi_image_free(data)

  return pixelData


# TODO should there be an overload that has a string instead?
## This takes in a sequences of bytes (of an image file)
## and will return a sequence (of 32 bit floats) that
## is the pixel data. `x`, `y` are the dimensions of the image, and
## `channels_in_file` is the format (e.g. "RGBA," "GreyAlpha," etc.).
## `desired_channels` will attempt to change it to with format you would like
## though it's not guarenteed.  Set it to `0` if you don't care (a.k.a
## "Default").
proc stbiLoadFFromMemory*(buffer: seq[uint8]; x, y, channels_in_file: var int; desired_channels: int): seq[float32] =
  var
    # Cast the buffer to another data type
    castedBuffer = cast[ptr cuchar](buffer[0].unsafeAddr)

    # Return values
    width: cint
    height: cint
    components: cint

  # Read
  let data = stbi_loadf_from_memory(castedBuffer, buffer.len.cint, width, height, components, desired_channels.cint)

  # Set the returns
  x = width.int
  y = height.int
  channels_in_file = components.int

  # Copy pixel data
  var pixelData: seq[float32]
  newSeq(pixelData, x * y * channels_in_file)
  copyMem(pixelData[0].addr, data, pixelData.len)

  # Free loaded image data
  stbi_image_free(data)

  return pixelData


## This takes in a File and will return a sequence (of 32 bit floats) that
## is the pixel data. `x`, `y` are the dimensions of the image, and
## `channels_in_file` is the format (e.g. "RGBA," "GreyAlpha," etc.).
## `desired_channels` will attempt to change it to with format you would like
## though it's not guarenteed.  Set it to `0` if you don't care (a.k.a
## "Default").
##
## This will also close the file handle too.
proc stbiLoadFFromFile*(f: File, x, y, channels_in_file: var int, desired_channels: int): seq[float32] =
  var
    width: cint
    height: cint
    components: cint

  # Read
  let data = stbi_loadf_from_file(f, width, height, components, desired_channels.cint)

  # Set the returns
  x = width.int
  y = height.int
  channels_in_file = components.int

  # Copy pixel data
  var pixelData: seq[float32]
  newSeq(pixelData, x * y * channels_in_file)
  copyMem(pixelData[0].addr, data, pixelData.len)

  # Free loaded image data
  stbi_image_free(data)

  return pixelData



# =============
# HDR functions
# =============

proc stbi_hdr_to_ldr_gamma(gamma: cfloat)
  {.importc: "stbi_hdr_to_ldr_gamma", noDecl.}

proc stbi_hdr_to_ldr_scale(scale: cfloat)
  {.importc: "stbi_hdr_to_ldr_scale", noDecl.}

proc stbi_ldr_to_hdr_gamma(gamma: cfloat)
  {.importc: "stbi_ldr_to_hdr_gamma", noDecl.}

proc stbi_ldr_to_hdr_scale(scale: cfloat)
  {.importc: "stbi_ldr_to_hdr_scale", noDecl.}

# The callback functions are going to be skipped (see the README.md)
#int stbi_is_hdr_from_callbacks(stbi_io_callbacks const *clbk, void *user);

proc stbi_is_hdr_from_memory(buffer: ptr cuchar; len: cint): cint
  {.importc: "stbi_is_hdr_from_memory", noDecl.}

proc stbi_is_hdr(filename: cstring): cint
  {.importc: "stbi_is_hdr", noDecl.}

# NOTE: because of identifiers work in Nim, I need to add that extra "_internal"
#       there.
proc stbi_is_hdr_from_file_internal(f: File): cint
  {.importc: "stbi_is_hdr_from_file", noDecl.}


## Please see the "HDR image support" section in the `stb_image.h` header file
proc stbiHDRToLDRGamma*(gamma: float) =
  stbi_hdr_to_ldr_gamma(gamma.cfloat)


## Please see the "HDR image support" section in the `stb_image.h` header file
proc stbiHDRToLDRScale*(scale: float) =
  stbi_hdr_to_ldr_scale(scale.cfloat)


## Please see the "HDR image support" section in the `stb_image.h` header file
proc stbiLDRToHDRGamma*(gamma: float) =
  stbi_ldr_to_hdr_gamma(gamma.cfloat)


## Please see the "HDR image support" section in the `stb_image.h` header file
proc stbiLDRToHDRScale*(scale: float) =
  stbi_ldr_to_hdr_scale(scale.cfloat)


## Checks to see if an image is an HDR image, from memory (as a string of bytes)
proc stbiIsHDRFromMemory*(buffer: seq[uint8]): bool =
  var castedBuffer = cast[ptr cuchar](buffer[0].unsafeAddr)
  return (stbi_is_hdr_from_memory(castedBuffer, buffer.len.cint) == 1)


## Checks to see if an image, with the given filename, is an HDR image.
proc stbiIsHDR*(filename: string): bool =
  return (stbi_is_hdr(filename.cstring) == 1)
  

## Checks to see if an image is an HDR image, from a File pointer.
proc stbiIsHDRFromFile*(f: File): bool =
  return (stbi_is_hdr_from_file_internal(f) == 1)



# ==============
# Info Functions
# ==============

proc stbi_info_from_memory(
  buffer: ptr cuchar;
  len: cint;
  x, y, comp: var cint
): cint
  {.importc: "stbi_info_from_memory", noDecl.}

# NOTE: I am skipping callback functions unless there is a demand for them
#int stbi_info_from_callbacks(stbi_io_callbacks const *clbk, void *user, int *x, int *y, int *comp);

proc stbi_info(
  filename: cstring;
  x, y, comp: var cint
): cint
  {.importc: "stbi_info", noDecl.}

proc stbi_info_from_file(
  f: File;
  x, y, comp: var cint
): cint
  {.importc: "stbi_info_from_file", noDecl.}


# TODO should there be an overload that has a string instead?
## Querys a buffer to see if that data is a loadable image and get it's
## dimensions.  Returns true if stb_image can load this image, false otherwise.
proc stbiInfoFromMemory*(buffer: seq[uint8]; x, y, comp: var int): bool =
  var
    # Cast the buffer to another data type
    castedBuffer = cast[ptr cuchar](buffer[0].unsafeAddr)
    width: cint
    height: cint
    channels: cint
    r = stbi_info_from_memory(castedBuffer, buffer.len.cint, width, height, channels)

  # Set the data and return
  x = width.int
  y = height.int
  comp = channels.int
  return (r == 1)


## Querys a filename to see if that file is a loadable image and get it's
## dimensions.  Returns true if stb_image can load this image, false otherwise.
proc stbiInfo*(filename: string; x, y, comp: var int): bool =
  var
    width: cint
    height: cint
    channels: cint
    r = stbi_info(filename.cstring, width, height, channels)
  
  # Set the data & return
  x = width.int
  y = height.int
  comp = channels.int
  return (r == 1)


## Querys a File pointer to see if that file is a loadable image and get it's
## dimensions.  Returns true if stb_image can load this image, false otherwise.
##
## This will also close the file handle.
proc stbiInfoFromFile*(f: File; x, y, comp: var int): bool =
  var
    width: cint
    height: cint
    channels: cint
    r = stbi_info_from_file(f, width, height, channels)
  
  # Set the data & return
  x = width.int
  y = height.int
  comp = channels.int
  return (r == 1)



# ===============
# Extra Functions
# ===============

proc stbi_set_unpremultiply_on_load(flag_true_if_should_unpremultiply: cint)
  {.importc: "stbi_set_unpremultiply_on_load", noDecl.}

proc stbi_convert_iphone_png_to_rgb(flag_true_if_should_convert: cint)
  {.importc: "stbi_convert_iphone_png_to_rgb", noDecl.}

proc stbi_set_flip_vertically_on_load(flag_true_if_should_flip: cint)
  {.importc: "stbi_set_flip_vertically_on_load", noDecl.}


## From the header file: "For image formats that explicitly notate that they
## have premultiplied alpha, we just return the colors as stored in the file.
## set this flag to force unpremultiplication. results are undefined if the
## unpremultiply overflow.  This function acts globally, so if you use it once I
## recommend calling it again right after loading what you want.
proc stbiSetUnpremultiplyOnLoad*(unpremultiply: bool) =
  stbi_set_unpremultiply_on_load(if unpremultiply: 1 else: 0)
  

## From the header file: "indicate whether we should process iphone images back
## to canonical format."  This function acts globally, so if you use it once I
## recommend calling it again right after loading what you want.
proc stbiConvertIPhonePNGToRGB*(convert: bool) =
  stbi_convert_iphone_png_to_rgb(if convert: 1 else: 0)


## From the header file: "flip the image vertically, so the first pixels in the
## output array is the bottom left".  This function acts globally, so if you use
## it once, I recommend calling it again right after loading what you want.
proc stbiSetFlipVerticallyOnLoad*(flip: bool) =
  stbi_set_flip_vertically_on_load(if flip: 1 else: 0)



# =====================
# ZLIB Client Functions
# =====================

# The ZLIB client functions are out of the scope of this wrapper, but if someone
# wants them added in (or provides a pull request).  I'll consider adding it.

#char *stbi_zlib_decode_malloc_guesssize(const char *buffer, int len, int initial_size, int *outlen);
#char *stbi_zlib_decode_malloc_guesssize_headerflag(const char *buffer, int len, int initial_size, int *outlen, int parse_header);
#char *stbi_zlib_decode_malloc(const char *buffer, int len, int *outlen);
#int   stbi_zlib_decode_buffer(char *obuffer, int olen, const char *ibuffer, int ilen);
#char *stbi_zlib_decode_noheader_malloc(const char *buffer, int len, int *outlen);
#int   stbi_zlib_decode_noheader_buffer(char *obuffer, int olen, const char *ibuffer, int ilen);

