import unittest
import stb_image


const
  testImage1 = "testdata/image1.png"


suite "Unit Tests for stb_image wrapper.":
  test "stbiLoad":
    # Data
    var
      width: int
      height: int
      channels: int
      pixels: seq[uint8]

    # Load the image
    pixels = stbiLoad(testImage1, width, height, channels, 0)

    check(width == 2)
    check(height == 2)
    check(channels == 4)
    check(pixels.len == (2 * 2 * 4))

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


