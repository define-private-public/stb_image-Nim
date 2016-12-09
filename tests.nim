import unittest

suite "Unit Tests for stb_image wrapper.":
  test "Hi":
    echo "sup"
    require(true)

  test "Fail":
    check(1 != 1)
    echo "1"
    require(false)
    echo "2"

