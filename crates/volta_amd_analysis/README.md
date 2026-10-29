# volta_amd_analysis

Experimental AMD kernel analysis for Volta.

`frontend::parse::parse_kernel(source, name)` parses Clang assembly;
`lower_kernel(&kernel)` validates the supported gfx950 instruction forms and
produces an AMD `LoweredKernel`. The lowering API and IR types are exported
from the crate root.

The IR represents AMD instructions for symbolic execution. It preserves
physical register identities, explicit waits, and launch metadata.

Supported operand forms follow the [CDNA4 ISA](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/instruction-set-architectures/amd-instinct-cdna4-instruction-set-architecture.pdf)
(§6.2, §12.6, §12.7) and LLVM 21.1.8's
[operand validation](https://github.com/llvm/llvm-project/blob/llvmorg-21.1.8/llvm/lib/Target/AMDGPU/AsmParser/AMDGPUAsmParser.cpp)
and [counter widths](https://github.com/llvm/llvm-project/blob/llvmorg-21.1.8/llvm/lib/Target/AMDGPU/Utils/AMDGPUBaseInfo.cpp).

## Tests

Run the unit tests:

```sh
cargo test -p volta_amd_analysis --lib
```

### Regenerating the copy fixture

`tests/fixtures/copy.cl` is `out[i] = in[i]`, one element per workitem, and
`copy.s` is the assembly Homebrew clang 21.1.8 produced for it for gfx950
(MI355X). Apple's clang lacks the AMDGPU target; use LLVM's clang (Homebrew
`llvm@21` on macOS). Regenerate it from `tests/fixtures/` with:

```sh
clang -x cl -cl-std=CL1.2 --target=amdgcn-amd-amdhsa -mcpu=gfx950 -nogpulib \
  -O2 -g0 -fno-verbose-asm -Xclang -target-feature -Xclang -xnack \
  -S copy.cl -o copy.s
```
