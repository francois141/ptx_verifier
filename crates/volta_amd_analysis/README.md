# volta_amd_analysis

Experimental AMD kernel analysis for Volta.

`frontend::parse::parse_kernel(source, name)` parses Clang assembly;
`lower_kernel(&kernel)` validates the supported gfx950 instruction forms and
produces an AMD `LoweredKernel`. The lowering API and IR types are exported
from the crate root.

The IR represents AMD instructions for symbolic execution. It preserves
physical register identities, explicit waits, and launch metadata. The evaluator
initializes registers from the descriptor and launch inputs, tracks symbolic
register values, and executes scalar instructions once per wave and vector instructions
for individual lanes. Scalar loads read the concrete kernel argument buffer or symbolic
global inputs and keep their destinations unavailable until `s_waitcnt lgkmcnt(0)`.
Scalar execution requires XNACK to be disabled; partial LGKM waits with pending scalar
loads are rejected. `ds_bpermute_b32` exchanges register values across a wave without
accessing LDS memory; its results remain pending until an LGKM wait completes them.
Launch initialization supports full waves in 1D, 2D, and 3D workgroups, matching
[AMD's X/Y/Z launch interface](https://releases.llvm.org/21.1.0/docs/AMDGPUUsage.html#initial-kernel-execution-state),
with an optional kernarg pointer and enabled workgroup IDs. Work-items are ordered
with X advancing first, then Y, then Z, following
[AMD's execution model](https://rocm.docs.amd.com/projects/HIP/en/latest/understand/programming_model.html#hierarchical-thread-model).
Unsupported instructions and launch layouts return `EvalError`.

All lanes of a wave stay active; instructions that change EXEC are rejected.
Bitwise operations require concrete words: symbolic values represent the math, not
bit patterns. This also rejects sign-mask tricks for negation and absolute value;
symbolic arithmetic and transfers, including lane exchanges, remain supported.

`ArrayDef` marks each global-memory array `Input` or `Output`. Global stores write
output elements, which the kernel cannot load. On completion,
`AnalysisResult.symbolic_outputs` holds the output elements that execution wrote; an
aborted run has none.

Supported operand forms follow the [CDNA4 ISA](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/instruction-set-architectures/amd-instinct-cdna4-instruction-set-architecture.pdf)
(§6.2, §12.6, §12.7, §12.11, §12.12); scalar addressing and completion follow §8.2–8.3. Operand checks
also follow LLVM 21.1.8's
[operand validation](https://github.com/llvm/llvm-project/blob/llvmorg-21.1.8/llvm/lib/Target/AMDGPU/AsmParser/AMDGPUAsmParser.cpp)
and [counter widths](https://github.com/llvm/llvm-project/blob/llvmorg-21.1.8/llvm/lib/Target/AMDGPU/Utils/AMDGPUBaseInfo.cpp).

The `.amdgcn_target` directive requires exactly one quoted string. Unquoted,
unbalanced and extra-quoted arguments are rejected.

## Tests

Kernel tests in `tests/kernels.rs` parse, lower, and execute compiled assembly
fixtures, then compare their symbolic outputs with the corresponding `.out` files.
Rejection fixtures instead require a specific lowering or execution error.
Specification comparisons live in `volta_pipeline/tests/amd_equivalence_tests.rs`.
Run both suites from the repository root:

```sh
just amd
```

`tests/lean_tests.rs` states the sigmoid fixture's outputs against
`tests/fixtures/sigmoid.spec` (`1 / (1 + exp(-a[i]))`) as a Lean challenge and writes it to
`target/lean/sigmoid.lean` (`just extract-lean`). Each element is claimed within
`1/1000`, not equal: above `a > 87.34` the kernel rescales by the f32 constant nearest
`e^-64`, so over the reals the exact equality is false there.

The cooperative `softmax` fixture uses lane exchanges for row maxima and sums,
as in CK's [FMHA reductions](https://github.com/ROCm/composable_kernel/blob/d80f11f70b1ab154a56b4bb7b4e28062007ccc65/include/ck_tile/ops/fmha/pipeline/block_fmha_pipeline_qr_ks_vs.hpp).
Its XOR reduction follows CK's [block reduction](https://github.com/ROCm/composable_kernel/blob/d80f11f70b1ab154a56b4bb7b4e28062007ccc65/include/ck_tile/ops/reduce/block/block_reduce.hpp),
using the same `ds_bpermute` [shuffle builtin](https://github.com/ROCm/composable_kernel/blob/d80f11f70b1ab154a56b4bb7b4e28062007ccc65/include/ck_tile/core/arch/utility.hpp).

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
