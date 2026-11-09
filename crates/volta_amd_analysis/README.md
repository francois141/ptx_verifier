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
The maximum LGKM field, `lgkmcnt(15)`, does not wait or complete any operation, even
when the logical issue history exceeds 15 instructions. It leaves DS and scalar-load
destinations pending and creates no graph completion evidence. Other fields of a
combined wait still take effect. Counter fields and their maximum-value defaults
follow [LLVM's gfx9 wait encoding](https://releases.llvm.org/21.1.0/docs/AMDGPU/gfx9_waitcnt.html).
The maximal VM field, `vmcnt(63)`, likewise leaves every vector-load destination
pending. The interpreter does not infer completion from hardware queue capacity
or backpressure; an explicit zero or supported partial wait must establish it.
Launch initialization supports full waves in 1D, 2D, and 3D workgroups, matching
[AMD's X/Y/Z launch interface](https://releases.llvm.org/21.1.0/docs/AMDGPUUsage.html#initial-kernel-execution-state),
with an optional kernarg pointer and enabled workgroup IDs. `WorkgroupLaunch` selects a
concrete X/Y/Z workgroup ID within nonzero grid dimensions; `analyze` executes only that
workgroup. `analyze_grid` runs every workgroup along one shared control flow, keeping each
workgroup's concrete words and real expressions in its registers and LDS. Instructions that
read differing values run once per workgroup, using the same evaluators as `analyze`.
Different branch outcomes or LDS access addresses abort the run with `DependsOnWorkgroup`.
The shared event graph records the LDS accesses and synchronization common to every workgroup;
written output values are exported separately for each workgroup. Duplicate output stores
across workgroups are reported separately from the LDS graph checks.
Disabled ID axes consume no SGPR. Work-items are ordered
with X advancing first, then Y, then Z, following
[AMD's execution model](https://rocm.docs.amd.com/projects/HIP/en/latest/understand/programming_model.html#hierarchical-thread-model).
Unsupported instructions and launch layouts return `EvalError`.

All lanes of a wave stay active; instructions that change EXEC are rejected.
Integer and bitwise operations require concrete words: symbolic values are floats and
represent the math, not bit patterns. This rejects integer arithmetic on symbolic values and
sign-mask tricks for negation and absolute value; floating-point arithmetic and transfers,
including lane exchanges, remain supported. A select between two different constant words
under a symbolic condition is rejected, since the words could encode floats or integers.
Negated select sources use floating-point semantics, so they are not ambiguous.
F32 e64 comparisons, e64 selects, f32 FMA and three-source f32 operations accept absolute-value
and negation input modifiers on any source; these operate on mathematical expressions.
E64 comparisons write VCC or an SGPR pair.
Scalar and vector NOT require concrete words. Accumulator writes accept VGPRs, SGPRs and inline constants.
Packed f32 add, multiply and FMA share component selection and negation handling;
each register holds one real expression, and either selector reads the same inline constant.
An f64 register pair holds one real expression or two concrete words that encode one. Reading
a half as a word, or a pair whose halves no longer match, is rejected; conversions keep the
exact real. F64 arithmetic, comparisons and conversions share one source reader and modifiers.
Packed moves select one word from each source and reuse the 64-bit move execution,
preserving concrete words and symbolic expressions unchanged. An inline constant must use the
low-word selector, because the high word of its 64-bit source is not established.
Comparison masks in VCC or SGPR pairs retain per-lane predicates for selects;
scalar instructions reject symbolic masks.
Negated f32 comparisons use the opposite ordered comparison because NaN is excluded.

`ArrayDef` marks each global-memory array `Input` or `Output(OutputType)`. Output
stores decode `F32` constants into mathematical reals and preserve existing real
expressions; `U32` outputs require concrete 32-bit words. Invalid values abort at
the store. Outputs cannot be loaded. On completion, `AnalysisResult.symbolic_outputs`
holds the interpreted values that execution wrote; an aborted run has none.

Supported operand forms follow the [CDNA4 ISA](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/instruction-set-architectures/amd-instinct-cdna4-instruction-set-architecture.pdf)
(§6.2, §12.6, §12.7, §12.10, §12.11, §12.12); scalar addressing and completion follow §8.2–8.3. Operand checks
also follow LLVM 21.1.8's
[operand validation](https://github.com/llvm/llvm-project/blob/llvmorg-21.1.8/llvm/lib/Target/AMDGPU/AsmParser/AMDGPUAsmParser.cpp)
and [counter widths](https://github.com/llvm/llvm-project/blob/llvmorg-21.1.8/llvm/lib/Target/AMDGPU/Utils/AMDGPUBaseInfo.cpp).
Packed f32 low-word selectors also follow LLVM's later
[gfx950 validation fix](https://github.com/llvm/llvm-project/commit/cac3cc2836765f5b039bcb213cda99db2818c11e).
Inline constants follow its [packed-to-scalar regression](https://github.com/llvm/llvm-project/blob/1b2bf711eb920b78c24e31a6c958751d0bdd0007/llvm/test/CodeGen/AMDGPU/unpack-non-coissue-insts-post-ra-scheduler.mir).

The `.amdgcn_target` directive requires exactly one quoted string. Unquoted,
unbalanced and extra-quoted arguments are rejected.

## Tests

Kernel tests in `tests/kernels.rs` parse, lower, and execute compiled assembly
fixtures, then compare their symbolic outputs with the corresponding `.out` files.
The `scalar_ops` fixture checks signed arithmetic, 64-bit comparisons and uniform loop branches.
The `vector_int_ops` fixture checks multiplication, bit counts, 64-bit and packed moves,
and signed 64-bit comparisons against a literal bound. `compare64_ops` checks every 64-bit integer comparison
in both encodings, and `scalar_alu_ops` the scalar ALU, comparison and branch families.
The `packed_float_ops` fixture checks paired arithmetic, selectors, negation and destination
overlap against independently derived expressions.
The `f64_ops` fixture checks f64 arithmetic, modifiers, constants, conversions, comparisons and
moves.
`accvgpr` checks each source form; the bitwise fixtures check NOT results and scalar SCC.
`lds_sync` includes a pending-read race and its waited control. `workgroup_ids` checks all
three launch coordinates, including a disabled Y axis, and rejects invalid grid coordinates;
a grid run over all its workgroups must match a run of each workgroup alone and report
duplicate stores. It also checks integer data through LDS and lane exchange, uniform branch
outcomes with different VCC masks, and rejection of varying LDS addresses and NaN operands.
Rejection fixtures instead require a specific lowering or execution error.
`tests/lgkm_wait.rs` checks maximal-field DS and scalar waits across the counter's
field limit, actual zero and partial waits, combined VM/LGKM waits, and END completion.
Its VM controls use distinct load destinations across the 63-field boundary and
check read/overwrite refusal, actual zero/partial completion and independent LGKM waits.
Specification comparisons live in `volta_pipeline/tests/amd_equivalence_tests.rs`.
`volta_pipeline/tests/amd_grid_tests.rs` compares CK grid outputs with independent workgroup
runs, checks that their stores do not overlap, and rejects differing control flow.
Run the kernel and equivalence suites, then the graph and grid suites, from the repository root:

```sh
just amd
cargo test -p volta_pipeline --test amd_graph_tests --test amd_grid_tests
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

### Compiling the CK GEMM fixture

`ck_gemm.hip` contains the same GEMM instance with and without its K-block main loop.
The main-loop tests use M=N=40, K=192 to exercise three K tiles, padding and data exchanged
between both waves.
Use [CK rocm-7.0.0](https://github.com/ROCm/composable_kernel/tree/rocm-7.0.0)
headers, including `ck/config.h` configured for gfx950, and the HIP headers described below:

```sh
clang++ -x hip -std=c++20 -fbracket-depth=1024 \
  --offload-arch=gfx950:xnack- --offload-device-only -nogpulib \
  --hip-path="$HIP_ROOT" -DNDEBUG -Wno-unknown-warning-option \
  -O3 -g0 -fno-verbose-asm -fgpu-flush-denormals-to-zero \
  -fno-hip-fp32-correctly-rounded-divide-sqrt -I "$CK_ROOT/include" \
  -S crates/volta_amd_analysis/tests/fixtures/ck_gemm.hip \
  -o crates/volta_amd_analysis/tests/fixtures/ck_gemm.s
```

### Compiling the CK attention fixture

`tests/fixtures/ck_fmha.hip` instantiates CK Tile's fp32 forward-attention device entry at
revision [`fc2862d712`](https://github.com/ROCm/composable_kernel/blob/fc2862d712/example/ck_tile/01_fmha/codegen/ops/fmha_fwd.py):
a 64 x 64 query/key tile, head dimension 64, row-major V and 256 work-items,
without masking, padding, bias, dropout or auxiliary outputs.
Sequence lengths and the attention scale are kernel arguments.

Use Clang 21.1.8, that CK checkout (`CK_ROOT`), and the [HIP 7.0.2 headers](https://repo.radeon.com/rocm/apt/7.0.2/pool/main/h/hip-dev/hip-dev_7.0.51831.70002-56~24.04_amd64.deb) (`HIP_ROOT`,
containing `include/` and `share/hip/version`). On macOS, change the host-only
`std::min(rotating_count, max_rotating_count)` in CK's `host/rotating_buffers.hpp`
to `std::min<uint64_t>(rotating_count, max_rotating_count)` to reconcile Darwin's integer types.
Compile from the repository root:

```sh
clang++ -x hip -std=c++20 -fbracket-depth=1024 \
  --offload-arch=gfx950:xnack- --offload-device-only -nogpulib \
  --hip-path="$HIP_ROOT" -DNDEBUG -Wno-unknown-warning-option \
  -O3 -g0 -fno-verbose-asm -fgpu-flush-denormals-to-zero \
  -fno-hip-fp32-correctly-rounded-divide-sqrt \
  -I "$CK_ROOT/include" -I "$CK_ROOT/example/ck_tile/01_fmha" \
  -S crates/volta_amd_analysis/tests/fixtures/ck_fmha.hip \
  -o crates/volta_amd_analysis/tests/fixtures/ck_fmha.s
```

The source supplies OCKL helpers as in `ck_gemm.hip`; `NDEBUG` matches CK's Release build.
Fast exp2 and the denormal flag follow CK's [forward-attention build](https://github.com/ROCm/composable_kernel/blob/fc2862d712/example/ck_tile/01_fmha/CMakeLists.txt);
the division flag permits reciprocal-based normalization.
