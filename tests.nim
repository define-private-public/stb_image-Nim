import unittest
import os
import stb_image
import stb_image_write


const
  testImage1 = "testdata/image1.png"
  testImage2 = "testdata/image2.bmp"
  testImage3: seq[uint8] = @[
    0x50'u8, 0x35'u8, 0x0a'u8, 0x23'u8, 0x20'u8, 0x43'u8, 0x52'u8, 0x45'u8, 0x41'u8, 0x54'u8, 0x4f'u8, 0x52'u8, 0x3a'u8, 0x20'u8, 0x47'u8, 0x49'u8,
    0x4d'u8, 0x50'u8, 0x20'u8, 0x50'u8, 0x4e'u8, 0x4d'u8, 0x20'u8, 0x46'u8, 0x69'u8, 0x6c'u8, 0x74'u8, 0x65'u8, 0x72'u8, 0x20'u8, 0x56'u8, 0x65'u8,
    0x72'u8, 0x73'u8, 0x69'u8, 0x6f'u8, 0x6e'u8, 0x20'u8, 0x31'u8, 0x2e'u8, 0x31'u8, 0x0a'u8, 0x31'u8, 0x20'u8, 0x32'u8, 0x0a'u8, 0x32'u8, 0x35'u8,
    0x35'u8, 0x0a'u8, 0x54'u8, 0xa8'u8
  ]

  testSave1 = "testdata/save1.bmp"
  testSave2 = "testdata/save2.png"
  testSave3 = "testdata/save3.tga"
  testSave4 = "testdata/save4.tga"


# This is a little handy proc so I don't have to type so much
proc addRGB(pixelData: var seq[uint8]; r, g, b: uint8) =
  pixelData.add(r)
  pixelData.add(g)
  pixelData.add(b)


# Another handy proc for less typing
proc addRGBA(pixelData: var seq[uint8]; r, g, b, a: uint8) =
  pixelData.add(r)
  pixelData.add(g)
  pixelData.add(b)
  pixelData.add(a)


# Yet another handy proc for even less typing
proc addYA(pixelData: var seq[uint8]; mono, alpha: uint8) =
  pixelData.add(mono)
  pixelData.add(alpha)




suite "Unit Tests for stb_image wrapper.":
  test "stbiLoad":
    # Data
    var
      width: int
      height: int
      channels: int
      pixels: seq[uint8]

    # Load the image
    pixels = stbiLoad(testImage1, width, height, channels, Default)

    check(width == 2)
    check(height == 2)
    check(channels == RGBA)
    check(pixels.len == (width * height * RGBA))

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


  test "stbiLoadFromFile":
    # Data
    var
      fileObj: File
      width: int
      height: int
      channels: int
      pixels: seq[uint8]

    # Open the file object
    check(open(fileObj, testImage2))

    # Load the image
    pixels = stbiLoadFromFile(fileObj, width, height, channels, Default)

    check(width == 2)
    check(height == 1)
    check(channels == RGB)
    check(pixels.len == (width * height * RGB))

    # Test the pixel data
    # 1 == white
    check(pixels[0 + 0] == 0xFF)
    check(pixels[0 + 1] == 0xFF)
    check(pixels[0 + 2] == 0xFF)

    # 2 == Black
    check(pixels[3 + 0] == 0x00)
    check(pixels[3 + 1] == 0x00)
    check(pixels[3 + 2] == 0x00)


  test "stbiLoadFromMemory":
    # Data
    var
      width: int
      height: int
      channels: int
      pixels: seq[uint8]

    # Load the image
    pixels = stbiLoadFromMemory(testImage3, width, height, channels, Grey)

    check(width == 1)
    check(height == 2)
    check(channels == Grey)
    check(pixels.len == (width * height * Grey))

    # Test the pixel data
    # 1 == darker grey
    check(pixels[0] == 84)

    # 2 == lighter grey
    check(pixels[1] == 168)


suite "Unit tests for stbi_image_write wrapper":
  test "stbiWriteBMP":
    # data
    var
      width = 2
      height = 2
      channels = RGB
      pixels: seq[uint8] = @[]
      filename = "save1.bmp"

    # Set the pixel data
    pixels.addRGB(0xFF, 0x00, 0x00)   # Red
    pixels.addRGB(0x00, 0xFF, 0x00)   # Green
    pixels.addRGB(0x00, 0x00, 0xFF)   # Blue
    pixels.addRGB(0x00, 0x00, 0x00)   # Black

    # Non-zero is returned on success
    check(stbiWriteBMP(filename, width, height, channels, pixels) != 0)

    # Verify the image with the one in "testdata/"
    var
      testPixels = readFile(testSave1)
      ourPixels = readFile(filename)

    # check for equivilancy
    check(testPixels == ourPixels)

    # remove the image
    removeFile(filename)

  test "stbiWritePNG":
    # data
    var
      width = 3
      height = 2
      channels = YA
      pixels: seq[uint8] = @[]
      filename = "save2.png"

    # Set the pixel data
    pixels.addYA(0xFF, 0x33)    # White
    pixels.addYA(0xFF, 0x66)
    pixels.addYA(0xFF, 0x99)

    pixels.addYA(0x00, 0x99)    # Black
    pixels.addYA(0x00, 0x66)
    pixels.addYA(0x00, 0x33)

    # Non-zero is returned on success
    check(stbiWritePNG(filename, width, height, channels, pixels) != 0)

    # Verify image is the same in testdata/
    var
      testPixels = readFile(testSave2)
      ourPixels = readFile(filename)

    # Check for sameness
    check(testPixels == ourPixels)

    # Remove the image
    removeFile(filename)


  test "stbiWriteTGA [RLE]":
    var
      width = 5
      height = 2
      channels = RGBA
      pixels: seq[uint8] = @[]
      filename = "save3.tga"

    # Set the pixel data
    for i in countup(1, 5):
      pixels.addRGBA(0x00, 0x00, 0x00, 0x80)
    for i in countup(1, 5):
      pixels.addRGBA(0xFF, 0xFF, 0xFF, 0x80)

    # Non-zero is returned on success
    # Writing with RLE by default
    check(stbiWriteTGA(filename, width, height, channels, pixels) != 0)

    # Verify image is the same in testdata/
    var
      testPixels = readFile(testSave3)
      ourPixels = readFile(filename)

    # Check for sameness
    check(testPixels == ourPixels)

    # Remove the image
    removeFile(filename)


  test "stbiWriteTGA [non-RLE]":
    # Data
    var
      width = 2
      height = 3
      channels = RGBA
      pixels: seq[uint8] = @[]
      filename = "save4.tga"

    # Set the pixel data
    pixels.addRGBA(0xFF, 0x66, 0x00, 0x80)
    pixels.addRGBA(0xFF, 0x99, 0x00, 0xFF)

    pixels.addRGBA(0x66, 0x00, 0xFF, 0x80)
    pixels.addRGBA(0x99, 0x00, 0xFF, 0xFF)

    pixels.addRGBA(0x00, 0x66, 0xFF, 0x80)
    pixels.addRGBA(0x00, 0x99, 0xFF, 0xFF)

    # Non-zero is returned on success
    check(stbiWriteTGA(filename, width, height, channels, pixels, false) != 0)

    # Verify image is the same in testdata/
    var
      testPixels = readFile(testSave4)
      ourPixels = readFile(filename)

    # Check for sameness
    check(testPixels == ourPixels)

    # Remove the image
    removeFile(filename)

