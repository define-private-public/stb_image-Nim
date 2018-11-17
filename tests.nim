import unittest
import os
import stb_image/read as stbi
import stb_image/write as stbiw
import sequtils

const
  testImage1 = "testdata/image1.png"
  testImage2 = "testdata/image2.bmp"
  testImage3: seq[byte] = @[
    0x50'u8, 0x35'u8, 0x0a'u8, 0x23'u8, 0x20'u8, 0x43'u8, 0x52'u8, 0x45'u8, 0x41'u8, 0x54'u8, 0x4f'u8, 0x52'u8, 0x3a'u8, 0x20'u8, 0x47'u8, 0x49'u8,
    0x4d'u8, 0x50'u8, 0x20'u8, 0x50'u8, 0x4e'u8, 0x4d'u8, 0x20'u8, 0x46'u8, 0x69'u8, 0x6c'u8, 0x74'u8, 0x65'u8, 0x72'u8, 0x20'u8, 0x56'u8, 0x65'u8,
    0x72'u8, 0x73'u8, 0x69'u8, 0x6f'u8, 0x6e'u8, 0x20'u8, 0x31'u8, 0x2e'u8, 0x31'u8, 0x0a'u8, 0x31'u8, 0x20'u8, 0x32'u8, 0x0a'u8, 0x32'u8, 0x35'u8,
    0x35'u8, 0x0a'u8, 0x54'u8, 0xa8'u8
  ]
  testImage4 = "testdata/image4.jpeg"

  testSave1 = "testdata/save1.bmp"
  testSave2 = "testdata/save2.png"
  testSave3 = "testdata/save3.tga"
  testSave4 = "testdata/save4.tga"
  testSave5 = "testdata/save5.jpeg"
  testSave6 = "testdata/save6.jpeg"


# This is a little handy proc so I don't have to type so much
proc addRGB(pixelData: var seq[byte]; r, g, b: byte) =
  pixelData.add(r)
  pixelData.add(g)
  pixelData.add(b)


# Another handy proc for less typing
proc addRGBA(pixelData: var seq[byte]; r, g, b, a: byte) =
  pixelData.add(r)
  pixelData.add(g)
  pixelData.add(b)
  pixelData.add(a)


# Yet another handy proc for even less typing
proc addYA(pixelData: var seq[byte]; mono, alpha: byte) =
  pixelData.add(mono)
  pixelData.add(alpha)




suite "Unit Tests for stb_image wrapper":
  test "stbi.STBIException":
    # Test an STBIException being thrown
    # Data
    var
      width: int
      height: int
      channels: int
      pixels: seq[byte]

    # Load a non existant image
    try:
      pixels = stbi.load("testdata/kevin_bacon.jpeg", width, height, channels, stbi.Default)
      # This should never
      check(false)
    except STBIException:
      # This should hit
      check(true)
    except:
      # We should only get an STBIException, so check(false) here too
      check(false)


  test "stbi.load":
    # Data
    var
      width: int
      height: int
      channels: int
      pixels: seq[byte]

    # Load the image
    pixels = stbi.load(testImage1, width, height, channels, stbi.Default)

    check(width == 2)
    check(height == 2)
    check(channels == stbi.RGBA)
    check(pixels.len == (width * height * stbi.RGBA))

    # Test the pixel data
    # 1 == 25% white
    check(pixels[0 + 0] == 0xFF) # R
    check(pixels[0 + 1] == 0xFF) # G
    check(pixels[0 + 2] == 0xFF) # B
    check(pixels[0 + 3] == 0x3F) # A

    # 2 == 50% yellow
    check(pixels[4 + 0] == 0xFF) # R
    check(pixels[4 + 1] == 0xFF) # G
    check(pixels[4 + 2] == 0x00) # B
    check(pixels[4 + 3] == 0x7F) # A

    # 1 == 75% magenta
    check(pixels[8 + 0] == 0xFF) # R
    check(pixels[8 + 1] == 0x00) # G
    check(pixels[8 + 2] == 0xFF) # B
    check(pixels[8 + 3] == 0xBF) # A

    # 1 == 100% cyan
    check(pixels[12 + 0] == 0x00) # R
    check(pixels[12 + 1] == 0xFF) # G
    check(pixels[12 + 2] == 0xFF) # B
    check(pixels[12 + 3] == 0xFF) # A

  test "stbi.load [desired_channels > actual_channels]":
    # Data
    var
      width: int
      height: int
      channels: int
      pixels: seq[byte]

    pixels = stbi.load(testImage4, width, height, channels, stbi.RGBA)
    check(width == 2)
    check(height == 2)
    check(channels == stbi.RGB)
    check(pixels.len == (width * height * stbi.RGBA))

    # Test the pixel data
    check(pixels[0 + 0] == 0x11) # R
    check(pixels[0 + 1] == 0x11) # G
    check(pixels[0 + 2] == 0x11) # B
    check(pixels[0 + 3] == 0xFF) # A

    check(pixels[4 + 0] == 0x11) # R
    check(pixels[4 + 1] == 0x11) # G
    check(pixels[4 + 2] == 0x11) # B
    check(pixels[4 + 3] == 0xFF) # A

    check(pixels[8 + 0] == 0x11) # R
    check(pixels[8 + 1] == 0x11) # G
    check(pixels[8 + 2] == 0x11) # B
    check(pixels[8 + 3] == 0xFF) # A

    check(pixels[12 + 0] == 0x11) # R
    check(pixels[12 + 1] == 0x11) # G
    check(pixels[12 + 2] == 0x11) # B
    check(pixels[12 + 3] == 0xFF) # A

  test "stbi.loadFromFile":
    # Data
    var
      fileObj: File
      width: int
      height: int
      channels: int
      pixels: seq[byte]

    # Open the file object
    check(open(fileObj, testImage2))

    # Load the image
    pixels = stbi.loadFromFile(fileObj, width, height, channels, stbi.Default)

    check(width == 2)
    check(height == 1)
    check(channels == stbi.RGB)
    check(pixels.len == (width * height * stbi.RGB))

    # Test the pixel data
    # 1 == white
    check(pixels[0 + 0] == 0xFF)
    check(pixels[0 + 1] == 0xFF)
    check(pixels[0 + 2] == 0xFF)

    # 2 == Black
    check(pixels[3 + 0] == 0x00)
    check(pixels[3 + 1] == 0x00)
    check(pixels[3 + 2] == 0x00)


  test "stbi.loadFromMemory":
    # Data
    var
      width: int
      height: int
      channels: int
      pixels: seq[byte]

    # Load the image
    pixels = stbi.loadFromMemory(testImage3, width, height, channels, stbi.Grey)

    check(width == 1)
    check(height == 2)
    check(channels == stbi.Grey)
    check(pixels.len == (width * height * stbi.Grey))

    # Test the pixel data
    # 1 == darker grey
    check(pixels[0] == 84)

    # 2 == lighter grey
    check(pixels[1] == 168)


#  NOTE: not able to find a suitable 16 bit image to test against
#  test "stbi.load16":
#    check(false)
#
#
#  NOTE: not able to find a suitable 16 bit image to test against
#  test "stbi.loadFromFile16":
#    check(false)
#
#
#  NOTE: not able to find a suitable floating point image to test against
#  test "stbi.loadF":
#    check(false)
#
#
#  NOTE: not able to find a suitable floating point image to test against
#  test "stbi.loadFFromMemory":
#    check(false)
#
#
#  NOTE: not able to find a suitable floating point image to test against
#  test "stbi.loadFFromFile":
#    check(false)
#
#
#  NOTE: not able to find a suitable HDR image to test against
#  test "stbi.HDRToLDRGamma":
#    check(false)
#
#
#  NOTE: not able to find a suitable HDR image to test against
#  test "stbi.HDRToLDRScale":
#    check(false)
#
#
#  NOTE: not able to find a suitable HDR image to test against
#  test "stbi.LDRToHDRGamma":
#    check(false)
#
#
#  NOTE: not able to find a suitable HDR image to test against
#  test "stbi.LDRToHDRScale":
#    check(false)
#
#
#  NOTE: not able to find a suitable HDR image to test against
#  test "stbi.isHDRFromMemory":
#    check(false)
#
#
#  NOTE: not able to find a suitable HDR image to test against
#  test "stbi.isHDR":
#    check(false)
#
#
#  NOTE: not able to find a suitable HDR image to test against
#  test "stbi.isHDRFromFile":
#    check(false)



suite "Unit tests for stbi_image_write wrapper":
  test "stbiw.writeBMP":
    # data
    var
      width = 2
      height = 2
      channels = stbi.RGB
      pixels: seq[byte] = @[]
      filename = "save1.bmp"

    # Set the pixel data
    pixels.addRGB(0xFF, 0x00, 0x00)   # Red
    pixels.addRGB(0x00, 0xFF, 0x00)   # Green
    pixels.addRGB(0x00, 0x00, 0xFF)   # Blue
    pixels.addRGB(0x00, 0x00, 0x00)   # Black

    # Non-zero is returned on success
    check(stbiw.writeBMP(filename, width, height, channels, pixels))

    # Verify the image with the one in "testdata/"
    var
      testPixels = cast[seq[byte]](readFile(testSave1))
      ourPixels = cast[seq[byte]](readFile(filename))

    # check for equivilancy
    check(testPixels == ourPixels)

    # remove the image
    removeFile(filename)


  test "stbiw.writeBMP [memory]":
    # data
    var
      width = 2
      height = 2
      channels = stbi.RGB
      pixels: seq[byte] = @[]
      testPixels = cast[seq[byte]](readFile(testSave1))

    # Set the pixel data
    pixels.addRGB(0xFF, 0x00, 0x00)   # Red
    pixels.addRGB(0x00, 0xFF, 0x00)   # Green
    pixels.addRGB(0x00, 0x00, 0xFF)   # Blue
    pixels.addRGB(0x00, 0x00, 0x00)   # Black

    # save and load from memory
    let memoryPixels = stbiw.writeBMP(width, height, channels, pixels)

    # check for equivilancy
    check(testPixels == memoryPixels)


  test "stbiw.writePNG":
    # data
    var
      width = 3
      height = 2
      channels = stbiw.YA
      pixels: seq[byte] = @[]
      filename = "save2.png"

    # Set the pixel data
    pixels.addYA(0xFF, 0x33)    # White
    pixels.addYA(0xFF, 0x66)
    pixels.addYA(0xFF, 0x99)

    pixels.addYA(0x00, 0x99)    # Black
    pixels.addYA(0x00, 0x66)
    pixels.addYA(0x00, 0x33)

    # Non-zero is returned on success
    check(stbiw.writePNG(filename, width, height, channels, pixels))

    # Verify image is the same in testdata/
    var
      testPixels = cast[seq[byte]](readFile(testSave2))
      ourPixels = cast[seq[byte]](readFile(filename))

    # Check for sameness
    check(testPixels == ourPixels)

    # Remove the image
    removeFile(filename)


  test "stbiw.writePNG [memory]":
    # data
    var
      width = 3
      height = 2
      channels = stbiw.YA
      pixels: seq[byte] = @[]
      testPixels = cast[seq[byte]](readFile(testSave2))

    # Set the pixel data
    pixels.addYA(0xFF, 0x33)    # White
    pixels.addYA(0xFF, 0x66)
    pixels.addYA(0xFF, 0x99)

    pixels.addYA(0x00, 0x99)    # Black
    pixels.addYA(0x00, 0x66)
    pixels.addYA(0x00, 0x33)

    # save and load from memory
    let memoryPixels = stbiw.writePNG(width, height, channels, pixels)

    # check for equivilancy
    check(testPixels == memoryPixels)


  test "stbiw.writeTGA [RLE]":
    var
      width = 5
      height = 2
      channels = stbi.RGBA
      pixels: seq[byte] = @[]
      filename = "save3.tga"

    # Set the pixel data
    for i in countup(1, 5):
      pixels.addRGBA(0x00, 0x00, 0x00, 0x80)
    for i in countup(1, 5):
      pixels.addRGBA(0xFF, 0xFF, 0xFF, 0x80)

    # Non-zero is returned on success
    # Writing with RLE by default
    check(stbiw.writeTGA(filename, width, height, channels, pixels))

    # Verify image is the same in testdata/
    var
      testPixels = cast[seq[byte]](readFile(testSave3))
      ourPixels = cast[seq[byte]](readFile(filename))

    # Check for sameness
    check(testPixels == ourPixels)

    # Remove the image
    removeFile(filename)


  test "stbiw.writeTGA [memory, RLE]":
    var
      width = 5
      height = 2
      channels = stbi.RGBA
      pixels: seq[byte] = @[]
      testPixels = cast[seq[byte]](readFile(testSave3))

    # Set the pixel data
    for i in countup(1, 5):
      pixels.addRGBA(0x00, 0x00, 0x00, 0x80)
    for i in countup(1, 5):
      pixels.addRGBA(0xFF, 0xFF, 0xFF, 0x80)

    # save and load from memory
    let memoryPixels = stbiw.writeTGA(width, height, channels, pixels)

    # check for equivilancy
    check(testPixels == memoryPixels)


  test "stbiw.writeTGA [non-RLE]":
    # Data
    var
      width = 2
      height = 3
      channels = stbi.RGBA
      pixels: seq[byte] = @[]
      filename = "save4.tga"

    # Set the pixel data
    pixels.addRGBA(0xFF, 0x66, 0x00, 0x80)
    pixels.addRGBA(0xFF, 0x99, 0x00, 0xFF)

    pixels.addRGBA(0x66, 0x00, 0xFF, 0x80)
    pixels.addRGBA(0x99, 0x00, 0xFF, 0xFF)

    pixels.addRGBA(0x00, 0x66, 0xFF, 0x80)
    pixels.addRGBA(0x00, 0x99, 0xFF, 0xFF)

    # Non-zero is returned on success
    check(stbiw.writeTGA(filename, width, height, channels, pixels, false))

    # Verify image is the same in testdata/
    var
      testPixels = cast[seq[byte]](readFile(testSave4))
      ourPixels = cast[seq[byte]](readFile(filename))

    # Check for sameness
    check(testPixels == ourPixels)

    # Remove the image
    removeFile(filename)


  test "stbiw.writeTGA [memory, non-RLE]":
    # Data
    var
      width = 2
      height = 3
      channels = stbi.RGBA
      pixels: seq[byte] = @[]
      testPixels = cast[seq[byte]](readFile(testSave4))

    # Set the pixel data
    pixels.addRGBA(0xFF, 0x66, 0x00, 0x80)
    pixels.addRGBA(0xFF, 0x99, 0x00, 0xFF)

    pixels.addRGBA(0x66, 0x00, 0xFF, 0x80)
    pixels.addRGBA(0x99, 0x00, 0xFF, 0xFF)

    pixels.addRGBA(0x00, 0x66, 0xFF, 0x80)
    pixels.addRGBA(0x00, 0x99, 0xFF, 0xFF)

    # save and load from memory
    let memoryPixels = stbiw.writeTGA(width, height, channels, pixels, false)

    # check for equivilancy
    check(testPixels == memoryPixels)


  test "stbiw.writeJPG [quality=10]":
    # data
    var
      width = 2
      height = 2
      channels = stbi.RGB
      pixels: seq[byte] = @[]
      filename = "save5.jpeg"

    # Set the pixel data
    pixels.addRGB(0xFF, 0x00, 0x00)   # Red
    pixels.addRGB(0x00, 0xFF, 0x00)   # Green
    pixels.addRGB(0x00, 0x00, 0xFF)   # Blue
    pixels.addRGB(0x00, 0x00, 0x00)   # Black

    # Non-zero is returned on success
    check(stbiw.writeJPG(filename, width, height, channels, pixels, 10))

    # Verify the image with the one in "testdata/"
    var
      testPixels = cast[seq[byte]](readFile(testSave5))
      ourPixels = cast[seq[byte]](readFile(filename))

    # check for equivilancy
    check(testPixels == ourPixels)

    # remove the image
    removeFile(filename)


  test "stbiw.writeJPG [memory, quality=10]":
    # data
    var
      width = 2
      height = 2
      channels = stbi.RGB
      pixels: seq[byte] = @[]
      testPixels = cast[seq[byte]](readFile(testSave5))

    # Set the pixel data
    pixels.addRGB(0xFF, 0x00, 0x00)   # Red
    pixels.addRGB(0x00, 0xFF, 0x00)   # Green
    pixels.addRGB(0x00, 0x00, 0xFF)   # Blue
    pixels.addRGB(0x00, 0x00, 0x00)   # Black

    # save and load from memory
    let memoryPixels = stbiw.writeJPG(width, height, channels, pixels, 10)

    # check for equivilancy
    check(testPixels == memoryPixels)


  test "stbiw.writeJPG [quality=100]":
    # data
    var
      width = 2
      height = 2
      channels = stbi.RGB
      pixels: seq[byte] = @[]
      filename = "save6.jpeg"

    # Set the pixel data
    pixels.addRGB(0xFF, 0x00, 0x00)   # Red
    pixels.addRGB(0x00, 0xFF, 0x00)   # Green
    pixels.addRGB(0x00, 0x00, 0xFF)   # Blue
    pixels.addRGB(0x00, 0x00, 0x00)   # Black

    # Non-zero is returned on success
    check(stbiw.writeJPG(filename, width, height, channels, pixels, 100))

    # Verify the image with the one in "testdata/"
    var
      testPixels = cast[seq[byte]](readFile(testSave6))
      ourPixels = cast[seq[byte]](readFile(filename))

    # check for equivilancy
    check(testPixels == ourPixels)

    # remove the image
    removeFile(filename)


  test "stbiw.writeJPG [memory, quality=100]":
    # data
    var
      width = 2
      height = 2
      channels = stbi.RGB
      pixels: seq[byte] = @[]
      testPixels = cast[seq[byte]](readFile(testSave6))

    # Set the pixel data
    pixels.addRGB(0xFF, 0x00, 0x00)   # Red
    pixels.addRGB(0x00, 0xFF, 0x00)   # Green
    pixels.addRGB(0x00, 0x00, 0xFF)   # Blue
    pixels.addRGB(0x00, 0x00, 0x00)   # Black

    # save and load from memory
    let memoryPixels = stbiw.writeJPG(width, height, channels, pixels, 100)

    # check for equivilancy
    check(testPixels == memoryPixels)


#  Note, I haven't been able to find a simple HDR image to test against, so
#  that is why there isn't a test for it here.
#  test "stbiw.writeHDR":
#    check(false)



suite "info functions":
  test "stbi.infoFromMemory":
    # Data
    var
      width: int
      height: int
      channels: int

    check(stbi.infoFromMemory(testImage3, width, height, channels))
    check(width == 1)
    check(height == 2)
    check(channels == stbi.Grey)


  test "stbi.info":
    # Data
    var
      width: int
      height: int
      channels: int

    check(stbi.info(testImage1, width, height, channels))
    check(width == 2)
    check(height == 2)
    check(channels == stbi.RGBA)


  test "stbi.infoFromFile":
    # Data
    var
      width: int
      height: int
      channels: int
      fileObj: File

    # Open the file object
    check(open(fileObj, testImage2))

    check(stbi.infoFromFile(fileObj, width, height, channels))
    check(width == 2)
    check(height == 1)
    check(channels == stbi.RGB)



suite "extra functions (from stb_image.h)":
#  # NOTE: I have no idea how to test this function, but I would like to
#  test "stbi.setUnpremultiplyOnLoad":
#    check(false)

#  # NOTE: I have no idea how to test this function, but I would like to
#  test "stbi.convertIPhonePNGToRGB":
#    check(false)


  test "stbi.setFlipVerticallyOnLoad":
    # Flip upside down
    stbi.setFlipVerticallyOnLoad(true)

    # NOTE: This is all coped from the "stbi.load" test at the top

    # Data
    var
      width: int
      height: int
      channels: int
      pixels: seq[byte]

    # Load the image
    pixels = stbi.load(testImage1, width, height, channels, stbi.Default)

    check(width == 2)
    check(height == 2)
    check(channels == stbi.RGBA)
    check(pixels.len == (width * height * stbi.RGBA))

    # Test the pixel data

    # 1 == 75% magenta
    check(pixels[0 + 0] == 0xFF) # R
    check(pixels[0 + 1] == 0x00) # G
    check(pixels[0 + 2] == 0xFF) # B
    check(pixels[0 + 3] == 0xBF) # A

    # 1 == 100% cyan
    check(pixels[4 + 0] == 0x00) # R
    check(pixels[4 + 1] == 0xFF) # G
    check(pixels[4 + 2] == 0xFF) # B
    check(pixels[4 + 3] == 0xFF) # A

    # 1 == 25% white
    check(pixels[8 + 0] == 0xFF) # R
    check(pixels[8 + 1] == 0xFF) # G
    check(pixels[8 + 2] == 0xFF) # B
    check(pixels[8 + 3] == 0x3F) # A

    # 2 == 50% yellow
    check(pixels[12 + 0] == 0xFF) # R
    check(pixels[12 + 1] == 0xFF) # G
    check(pixels[12 + 2] == 0x00) # B
    check(pixels[12 + 3] == 0x7F) # A

    # Reset
    stbi.setFlipVerticallyOnLoad(false)


suite "zlib functions":
  const
    # testStringUncompressed compressed with deflate and zlib header
    testStringCompressed = [0x78'u8, 0x1, 0xc5, 0x50, 0x3b, 0x6e, 0xc4, 0x40, 0x8, 0xbd, 0xca, 0x3b, 0x80, 0xe5, 0x3b, 0xa4, 0xdf, 0x2e, 0x27, 0xc0, 0x33, 0xc8, 0x22, 0x6b, 0x6, 0x67, 0x0, 0x4b, 0x7b, 0xfb, 0xb0, 0x1b, 0x29, 0x5d, 0xd2, 0xa6, 0xa0, 0xe1, 0x7d, 0xf5, 0x6e, 0x36, 0x59, 0x21, 0xa7, 0xa7, 0xa2, 0xdb, 0x61, 0x13, 0x2e, 0x1, 0x52, 0x8e, 0x5, 0xcd, 0x86, 0x73, 0x70, 0x64, 0x3d, 0xa9, 0x17, 0xa7, 0xc9, 0xd8, 0xc1, 0x87, 0xc4, 0x5c, 0xe0, 0xdc, 0xd1, 0x85, 0x14, 0xc3, 0x46, 0xea, 0x3, 0x2c, 0x53, 0xad, 0x23, 0x58, 0xcf, 0x32, 0x91, 0x71, 0x49, 0xcf, 0x11, 0xc8, 0xc0, 0x41, 0x5b, 0x85, 0x80, 0xe3, 0x3b, 0x80, 0xa1, 0xb4, 0xf, 0x2, 0x1d, 0xf2, 0x99,
    0x8f, 0x32, 0xe0, 0x49, 0x15, 0xf6, 0xe3, 0x77, 0xd9, 0x91, 0x67, 0x24, 0xad, 0x78, 0xb, 0x5c, 0x3c, 0xd, 0x6c, 0xfe, 0x54, 0x53, 0x6b, 0xe9, 0x4f, 0x7e, 0xe0, 0x23, 0x3d, 0xc, 0x3d, 0xeb, 0x5e, 0x96, 0x2f, 0x9c, 0x9, 0x93, 0xb7, 0xd4, 0x15, 0xef, 0x55, 0x1a, 0xad, 0x7a, 0x12, 0xee, 0xe4, 0x1d, 0x7b, 0x6e, 0x3c, 0xf7, 0xc9, 0x63, 0xa9, 0xb6, 0x95, 0x44, 0x8, 0xba, 0x8b, 0x52, 0xe1, 0x4e, 0xa3, 0x45, 0x96, 0xde, 0x3, 0xb7, 0x5f, 0xb7, 0x58, 0xff, 0xc0, 0xfe, 0x7f, 0xa7, 0x2f, 0xda, 0x2, 0xa5, 0xa7,]
    # testStringUncompressed compressed with deflate but without zlib header
    testStringCompressedNoHeader = [0xc5'u8, 0x50, 0x3b, 0x6e, 0xc4, 0x40, 0x8, 0xbd, 0xca, 0x3b, 0x80, 0xe5, 0x3b, 0xa4, 0xdf, 0x2e, 0x27, 0xc0, 0x33, 0xc8, 0x22, 0x6b, 0x6, 0x67, 0x0, 0x4b, 0x7b, 0xfb, 0xb0, 0x1b, 0x29, 0x5d, 0xd2, 0xa6, 0xa0, 0xe1, 0x7d, 0xf5, 0x6e, 0x36, 0x59, 0x21, 0xa7, 0xa7, 0xa2, 0xdb, 0x61, 0x13, 0x2e, 0x1, 0x52, 0x8e, 0x5, 0xcd, 0x86, 0x73, 0x70, 0x64, 0x3d, 0xa9, 0x17, 0xa7, 0xc9, 0xd8, 0xc1, 0x87, 0xc4, 0x5c, 0xe0, 0xdc, 0xd1, 0x85, 0x14, 0xc3, 0x46, 0xea, 0x3, 0x2c, 0x53, 0xad, 0x23, 0x58, 0xcf, 0x32, 0x91, 0x71, 0x49,
    0xcf, 0x11, 0xc8, 0xc0, 0x41, 0x5b, 0x85, 0x80, 0xe3, 0x3b, 0x80, 0xa1, 0xb4, 0xf, 0x2, 0x1d, 0xf2, 0x99, 0x8f, 0x32, 0xe0, 0x49, 0x15, 0xf6, 0xe3, 0x77, 0xd9, 0x91, 0x67, 0x24, 0xad, 0x78, 0xb, 0x5c, 0x3c, 0xd, 0x6c, 0xfe, 0x54, 0x53, 0x6b, 0xe9, 0x4f, 0x7e, 0xe0, 0x23, 0x3d, 0xc, 0x3d, 0xeb, 0x5e, 0x96, 0x2f, 0x9c, 0x9, 0x93, 0xb7, 0xd4, 0x15, 0xef, 0x55, 0x1a, 0xad, 0x7a, 0x12, 0xee, 0xe4, 0x1d, 0x7b, 0x6e, 0x3c, 0xf7, 0xc9, 0x63, 0xa9, 0xb6, 0x95, 0x44, 0x8, 0xba, 0x8b, 0x52, 0xe1, 0x4e, 0xa3, 0x45, 0x96, 0xde, 0x3, 0xb7, 0x5f, 0xb7, 0x58, 0xff, 0xc0, 0xfe, 0x7f, 0xa7, 0x2f]
    testStringUncompressed = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. "

  test "stbi.zlibDecodeMalloc":
    require cast[string](stbi.zlibDecodeMalloc(testStringCompressed)) == testStringUncompressed

  test "stbi.zlibDecodeBuffer":
    var output = newSeq[byte](testStringUncompressed.len)
    require stbi.zlibDecodeBuffer(testStringCompressed, output) == testStringUncompressed.len
    require cast[string](output) == testStringUncompressed

  test "stbi.zlibDecodeBuffer [out of memory]":
    var output = newSeq[byte](testStringUncompressed.len div 2)
    expect STBIException:
      discard stbi.zlibDecodeBuffer(testStringCompressed, output)

  test "stbi.zlibDecodeMalloc [raw stream, expecting error]":
    expect STBIException:
      discard stbi.zlibDecodeMalloc(testStringCompressedNoHeader)

  test "stbi.zlibDecodeBuffer [raw stream]":
    var output = newSeq[byte](testStringUncompressed.len)
    require zlibDecodeBuffer(testStringCompressedNoHeader, output, false) == testStringUncompressed.len

