-- File: MinimalCuda.lean
import Lean

open Lean

/-- Just check if CUDA compiler exists -/
def checkCudaEnvironment : IO Unit := do
  IO.println "Checking for CUDA compiler..."

  match ← IO.Process.output {cmd := "which", args := #["nvcc"]} with
  | ⟨exitCode, stdout, stderr⟩ =>
    if exitCode == 0 then
      IO.println s!"✓ Found nvcc at: {stdout.trim}"

      -- Try a simple compile test
      let testCode := "
#include <cuda_runtime.h>
#include <stdio.h>

int main() {
    int deviceCount = 0;
    cudaGetDeviceCount(&deviceCount);
    printf(\"CUDA devices found: %d\\n\", deviceCount);
    return 0;
}"

      let tempFile := "/tmp/lean_cuda_test.cu"
      IO.FS.writeFile tempFile testCode

      let compileCmd := s!"nvcc {tempFile} -o /tmp/lean_cuda_test 2>&1"
      let compileResult ← IO.Process.output {cmd := "sh", args := #["-c", compileCmd]}

      if compileResult.exitCode == 0 then
        IO.println "✓ CUDA compilation works!"
        let runResult ← IO.Process.output {cmd := "/tmp/lean_cuda_test"}
        IO.println s!"  {runResult.stdout.trim}"
      else
        IO.println "✗ CUDA compilation failed"
        IO.println compileResult.stderr
    else
      IO.println "✗ nvcc not found in PATH"
      IO.println "Install CUDA toolkit and ensure nvcc is in PATH"

#eval checkCudaEnvironment
