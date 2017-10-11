# Package
version     = "2.0"
author      = "Benjamin N. Summerton <define-private-public>"
description = "A wrapper for stb_image (including stb_image_write)."
license     = "Unlicense (Public Domain)"

# deps
requires "nim >= 0.15.0"

skipFiles = @["tests.nim"]
skipDirs = @["testdata"]

