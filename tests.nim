import unittest
import stb_image


const
  testImage1 = "testdata/image1.png"
  testImage2 = "testdata/image2.bmp"
  testImage3: seq[uint8] = @[
    0x50'u8, 0x35'u8, 0x0a'u8, 0x23'u8, 0x20'u8, 0x43'u8, 0x52'u8, 0x45'u8, 0x41'u8, 0x54'u8, 0x4f'u8, 0x52'u8, 0x3a'u8, 0x20'u8, 0x47'u8, 0x49'u8,
    0x4d'u8, 0x50'u8, 0x20'u8, 0x50'u8, 0x4e'u8, 0x4d'u8, 0x20'u8, 0x46'u8, 0x69'u8, 0x6c'u8, 0x74'u8, 0x65'u8, 0x72'u8, 0x20'u8, 0x56'u8, 0x65'u8,
    0x72'u8, 0x73'u8, 0x69'u8, 0x6f'u8, 0x6e'u8, 0x20'u8, 0x31'u8, 0x2e'u8, 0x31'u8, 0x0a'u8, 0x31'u8, 0x20'u8, 0x32'u8, 0x0a'u8, 0x32'u8, 0x35'u8,
    0x35'u8, 0x0a'u8, 0x54'u8, 0xa8'u8
  ]





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


#  # TODO fix this later, I can't seem to get it to work
#  #      It would be best to test the code (and bytes in C first)
#  test "stbiLoadFromMemory":
#    # Data
#    var
#      width: int
#      height: int
#      channels: int
#      pixels: seq[uint8]
#
#    # Load the image
#    pixels = stbiLoadFromMemory(testImage3, width, height, channels, Grey)
#
#    check(width == 1)
#    check(height == 2)
#    check(channels == Grey)
#    check(pixels.len == (width * height * Grey))
#
#    # Test the pixel data
#    # 1 == white
#    check(pixels[0 + 0] == 84)
#    check(pixels[0 + 1] == 0xFF)
#    check(pixels[0 + 2] == 0xFF)
#
#    # 2 == Black
#    check(pixels[3 + 0] == 168)
#    check(pixels[3 + 1] == 0x00)
#    check(pixels[3 + 2] == 0x00)


