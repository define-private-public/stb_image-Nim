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


# Right now I'm not planning on using the callback functions, but if someone
# requests it (or provides a pull request), I'll consider adding them in.
#stbi_uc *stbi_load_from_callbacks(stbi_io_callbacks const *clbk, void *user, int *x, int *y, int *channels_in_file, int desired_channels);



## This takes in a File and will return a sequence (of unsigned bytes) that
## is the pixel data. `x`, `y` are the dimensions of the image, and
## `channels_in_file` is the format (e.g. "RGBA," "GreyAlpha," etc.).
## `desired_channels` will attempt to change it to with format you would like
## though it's not guarenteed.  Set it to `0` if you don't care (a.k.a
## "Default").
##
## This should also close the file handle too.
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

#stbi_us *stbi_load_16(char const *filename, int *x, int *y, int *channels_in_file, int desired_channels);
#stbi_us *stbi_load_from_file_16(FILE *f, int *x, int *y, int *channels_in_file, int desired_channels);
#
## float channel interface
#float *stbi_loadf(char const *filename, int *x, int *y, int *channels_in_file, int desired_channels);
#float *stbi_loadf_from_memory(stbi_uc const *buffer, int len, int *x, int *y, int *channels_in_file, int desired_channels);

# The callback functions are going to be skipped (see the README.md)
#float *stbi_loadf_from_callbacks(stbi_io_callbacks const *clbk, void *user, int *x, int *y, int *channels_in_file, int desired_channels);


#float *stbi_loadf_from_file(FILE *f, int *x, int *y, int *channels_in_file, int desired_channels);


# The HDR functions

#void stbi_hdr_to_ldr_gamma(float gamma);
#void stbi_hdr_to_ldr_scale(float scale);

#void stbi_ldr_to_hdr_gamma(float gamma);
#void stbi_ldr_to_hdr_scale(float scale);

# The callback functions are going to be skipped (see the README.md)
#int stbi_is_hdr_from_callbacks(stbi_io_callbacks const *clbk, void *user);

#int stbi_is_hdr_from_memory(stbi_uc const *buffer, int len);
#int stbi_is_hdr(char const *filename);
#int stbi_is_hdr_from_file(FILE *f);
#

# TODO the info functions
## get image dimensions & components without fully decoding
#int stbi_info_from_memory(stbi_uc const *buffer, int len, int *x, int *y, int *comp);
#int stbi_info_from_callbacks(stbi_io_callbacks const *clbk, void *user, int *x, int *y, int *comp);
#
#int stbi_info(char const *filename, int *x, int *y, int *comp);
#int stbi_info_from_fileFILE *f, int *x, int *y, int *comp);



# TODO premultiply functions
#void stbi_set_unpremultiply_on_load(int flag_true_if_should_unpremultiply);

# TODO iphone
## indicate whether we should process iphone images back to canonical format,
#void stbi_convert_iphone_png_to_rgb(int flag_true_if_should_convert);

# TODO flip
##flip the image vertically, so the first pixel in the output array is the bottom left
#void stbi_set_flip_vertically_on_load(int flag_true_if_should_flip);


# The ZLIB client functions are out of the scope of this wrapper, but if someone
# wants them added in (or provides a pull request).  I'll consider adding it.
#
#char *stbi_zlib_decode_malloc_guesssize(const char *buffer, int len, int initial_size, int *outlen);
#char *stbi_zlib_decode_malloc_guesssize_headerflag(const char *buffer, int len, int initial_size, int *outlen, int parse_header);
#char *stbi_zlib_decode_malloc(const char *buffer, int len, int *outlen);
#int   stbi_zlib_decode_buffer(char *obuffer, int olen, const char *ibuffer, int ilen);
#char *stbi_zlib_decode_noheader_malloc(const char *buffer, int len, int *outlen);
#int   stbi_zlib_decode_noheader_buffer(char *obuffer, int olen, const char *ibuffer, int ilen);
#
