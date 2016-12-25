import os
import nake

const
  NimCache = "nimcache/"

  Tests = "tests.nim"
  BinaryName = "tests"


# Build the unit tests
task "tests", "build unit tests for the library":
  if shell(nimExe, "c", Tests):
    echo "Tests Built."


# Delete the binaries and other files
task "clean", "Clean up compiled output":
  removeDir(NimCache)
  removeFile(BinaryName)


# Will build the tests
task defaultTask, "[tests]":
  runTask("tests")

