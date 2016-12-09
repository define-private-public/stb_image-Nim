
# Required
{.emit: """
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
""".}


# ==================
# 8 bits per channel
# ==================


#stbi_uc *stbi_load(char const *filename, int *x, int *y, int *channels_in_file, int desired_channels);
proc stbi_load(filename: cstring; x, y, channels_in_file: var cint; desired_channels: cint): ptr cuchar
  {.importc: "stbi_load", noDecl.}


# TODO Document
# TODO Test
proc stbiLoad(filename: string, x, y, channels_in_file: var int, desired_channels: int): seq[uint8] =
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
  newSeq(pixelData, x * y)
  copyMem(pixelData[0].addr, data, pixelData.len)

  # Free loaded image data
  stbi_image_free(data)

  # TODO ask about memory lifetime for the returned data
  return pixelData


# TODO this needs a nim friendly version
# TODO Document
# TODO Test
#stbi_uc *stbi_load_from_memory(stbi_uc const *buffer, int len, int *x, int *y, int *channels_in_file, int desired_channels);
proc stbi_load_from_memory(buffer: ptr cuchar; len: cint; x, y, channels_in_file: var cint; desired_channels: cint): ptr cuchar
  {.importc: "stbi_load_from_memory", noDecl.}


# TODO figure out how this works, and if it's worth it to add
#stbi_uc *stbi_load_from_callbacks(stbi_io_callbacks const *clbk, void *user, int *x, int *y, int *channels_in_file, int desired_channels);


# TODO this needs a nim friendly version
# TODO Document
# TODO Test
#stbi_uc *stbi_load_from_file(FILE *f, int *x, int *y, int *channels_in_file, int desired_channels);
proc stbi_load_from_file(f: File; x, y, channels_in_file: var cint; desired_channels: cint): ptr cuchar
  {.importc: "stbi_load_from_file", noDecl.}






## 16  bits per channel
#stbi_us *stbi_load_16(char const *filename, int *x, int *y, int *channels_in_file, int desired_channels);
#stbi_us *stbi_load_from_file_16(FILE *f, int *x, int *y, int *channels_in_file, int desired_channels);
#
## float channel interface
#float *stbi_loadf(char const *filename, int *x, int *y, int *channels_in_file, int desired_channels);
#float *stbi_loadf_from_memory(stbi_uc const *buffer, int len, int *x, int *y, int *channels_in_file, int desired_channels);
#float *stbi_loadf_from_callbacks(stbi_io_callbacks const *clbk, void *user, int *x, int *y, int *channels_in_file, int desired_channels);
#
#float *stbi_loadf_from_file(FILE *f, int *x, int *y, int *channels_in_file, int desired_channels);
#
#void stbi_hdr_to_ldr_gamma(float gamma);
#void stbi_hdr_to_ldr_scale(float scale);
#
#void stbi_ldr_to_hdr_gamma(float gamma);
#void stbi_ldr_to_hdr_scale(float scale);
#
#int stbi_is_hdr_from_callbacks(stbi_io_callbacks const *clbk, void *user);
#int stbi_is_hdr_from_memory(stbi_uc const *buffer, int len);
#int stbi_is_hdr(char const *filename);
#int stbi_is_hdr_from_file(FILE *f);
#
#
## get a VERY brief reason for failure
## NOT THREADSAFE
#const char *stbi_failure_reason(void);
#


#void stbi_image_free(void *retval_from_stbi_load)
# TODO note it's here for completeness, but not necessary
proc stbi_image_free(retval_from_stbi_load: ptr) {.importc: "stbi_image_free", noDecl.}


#
## get image dimensions & components without fully decoding
#int stbi_info_from_memory(stbi_uc const *buffer, int len, int *x, int *y, int *comp);
#int stbi_info_from_callbacks(stbi_io_callbacks const *clbk, void *user, int *x, int *y, int *comp);
#
#int stbi_info(char const *filename, int *x, int *y, int *comp);
#int stbi_info_from_fileFILE *f, int *x, int *y, int *comp);
#
#
#
#void stbi_set_unpremultiply_on_load(int flag_true_if_should_unpremultiply);
#
## indicate whether we should process iphone images back to canonical format,
#void stbi_convert_iphone_png_to_rgb(int flag_true_if_should_convert);
#
##flip the image vertically, so the first pixel in the output array is the bottom left
#void stbi_set_flip_vertically_on_load(int flag_true_if_should_flip);
#
## ZLIB client - used by PNG, available for other purposes
#char *stbi_zlib_decode_malloc_guesssize(const char *buffer, int len, int initial_size, int *outlen);
#char *stbi_zlib_decode_malloc_guesssize_headerflag(const char *buffer, int len, int initial_size, int *outlen, int parse_header);
#char *stbi_zlib_decode_malloc(const char *buffer, int len, int *outlen);
#int   stbi_zlib_decode_buffer(char *obuffer, int olen, const char *ibuffer, int ilen);
#
#char *stbi_zlib_decode_noheader_malloc(const char *buffer, int len, int *outlen);
#int   stbi_zlib_decode_noheader_buffer(char *obuffer, int olen, const char *ibuffer, int ilen);
#
