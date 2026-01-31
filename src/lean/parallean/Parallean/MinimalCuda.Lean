-- File: MinimalCuda.lean
import Lean

open Lean


def writeToFile (path : String) (content : String) : IO Unit := do
  -- Extract parent directory
  let pathParts := path.splitOn "/"
  let parentDir := String.intercalate "/" (pathParts.dropLast)
  if parentDir != "" then
    IO.FS.createDirAll parentDir
  IO.FS.writeFile path content

def testCode : String := "
#include <cuda_runtime.h>
#include <stdio.h>

int main() {
  int deviceCount = 0;
  cudaGetDeviceCount(&deviceCount);
  printf(\"CUDA devices found: %d\\n\", deviceCount);
  return 0;
}"

#eval writeToFile "/tmp/parallean/test" testCode
