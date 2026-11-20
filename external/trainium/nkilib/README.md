# nkilib's kernels

Volta checks kernels of AWS's [nki-library](https://github.com/aws-neuron/nki-library)
(commit `ad2f1b9`) against specs written from nkilib's own PyTorch references:
- **[the bugs](#the-bugs) it found**, four of which silently give wrong outputs, with no
  error. Each is kept at the call that shows it, together with a proposed fix;
- **[the kernels it found correct](#checked-and-found-correct)**, each at the calls it was
  proved on.

`crates/volta_pipeline/tests/trainium/nkilib_tests/` runs them all through `just trainium`:
- **`bugs.rs`:** each buggy call must fail, either with an execution error or with a
  refutation against the kernel's spec. The same call with the fix applied must be proved
  equal to the spec and race free.
- **`layers.rs`, `norms.rs`, `elementwise.rs`, `pooling.rs`, `conv.rs`:** each call of a correct kernel
  must be proved equal to its spec on every element and race free.

| ID | Kernel | Call | What Volta reports | Proposed fix | Upstream |
|---|---|---|---|---|---|
| F7 | `max_pooling_3d` | `[1, 2, 5, 6, 7]`, kernel 2, stride 1, padding 1 | a tile is read after another tile overwrote its bytes (`ClobberedRead`); reading the shared bytes, 40 of 672 outputs are refuted | one reduce section per axis | not yet filed |
| F9 | `conv3d` (fallback path, `C_in > 64`) | `[1, 130, 1, 3, 4]`, 1 x 1 x 1 filter, W padding `(0, 2)`, and with D and H padding | unwritten PSUM reaches `conv_out` (`UninitializedRead`) | mark each tap's written rectangle, not the flattened span | not yet filed |
| F11 | `conv3d_bwd` `dx` (col2im path, `C_out > 64`) | `[1, 2, 1, 4, 4]`, 3 x 3 x 3 filter, padding 1; `[1, 2, 2, 4, 4]`, 2 x 2 x 2 filter | all 32 elements refuted; with two frames, `dx`'s plane 1 is never written | take the 3-D branch whenever depth matters | [aws-neuron/nki-library#28](https://github.com/aws-neuron/nki-library/issues/28), fix in [#29](https://github.com/aws-neuron/nki-library/pull/29) |
| F12 | `conv3d_temporal_unroll` | `[1, 65, 6, 1, 513]`, 2 x 1 x 1 filter, depth dilation 2 | all 2,052 outputs refuted | stop multiplying `d_in` by the dilation | [aws-neuron/nki-library#26](https://github.com/aws-neuron/nki-library/issues/26), fix in [#27](https://github.com/aws-neuron/nki-library/pull/27) |

## Layout

- **`nki-library.commit`**: the nki-library commit the kernels are traced from (`ad2f1b9`).
  `just nkilib` fetches it into `target/nkilib`, and `just trainium` runs that first. No
  nkilib source is kept in this repository.
- **`<kernel>.py`**: the wrapper Volta traces. It calls the kernel as released and fixes its
  outputs' names. Where one wrapper covers several variants (an op, a layout, which output
  to return, a smaller tile size), a constant of the call picks it.
- **`<kernel>_fixed.py`**: the same wrapper, but it first imports the kernel's module through
  `fixes.apply`. That applies `fixes.py`'s text edits to the fetched source as the module is
  imported, so `target/nkilib` stays exactly as released.
- **`*.spec`**: each operation as nkilib's own PyTorch reference (`*_torch.py`) defines it.
  Where the kernel multiplies by a rounded constant (`1/384`, `1/27`), so does the spec.
  - `max_pooling_3d.spec` follows `F.max_pool3d`.
  - `conv3d.spec` follows `nn.Conv3d` after `F.pad`. It gives both `conv_out` (`conv3d`) and
    `y_out` (`conv3d_temporal_unroll`).
  - `conv3d_bwd.spec` gives that convolution's gradients.
  - Evaluated in float64, each bug's spec agrees with the torch reference at its failing
    call (largest relative error 4e-14).

## The bugs

Line numbers are those of `ad2f1b9`.

### F7: `max_pooling_3d` overwrites a tile it still reads

**Where:** `experimental/pooling/max_pooling_3d.py`, `_reduce_all_axes`. It reduces one axis
at a time inside a scope with two ping-pong sections. Axis 2's output therefore goes back to
axis 0's address.

**Why that fails:** reusing axis 0's address is safe only if no tile grows. With stride 1 and
`2 * padding > kernel - 1` (kernel 2 with padding 1, both valid in PyTorch), each axis's
output is larger than its input. Axis 2's tile then overruns axis 1's tile while axis 1's is
still being read.

**Why the tests miss it:** no tested configuration grows an axis.

**The fix:** `fixes.py` opens the scope with one section per axis, so no tile is reused. That
uses more SBUF than the two sections the kernel's tiling budgets for, so a fix upstream
should also budget for it. Two alternatives: size each section for the largest tile it will
hold, or keep two sections only when no axis grows.

### F9: `conv3d` sends stale PSUM to its output

**Where:**
- the helper `_compute_unwritten_free_ranges` in `experimental/conv/conv3d_helpers.py`
  (line 2060);
- its use in `_conv3d_fallback_compute`, the path taken when `C_in > 64`.

**Why that fails:**
- The helper treats a tap's whole flattened span, from its first valid row to its last, as
  written by the matmul.
- The matmul writes only the rectangle of valid rows and columns. The padding-only columns
  between rows are never filled.
- `psum + bias` then evicts whatever PSUM held there.

**When it happens:** whenever W padding exceeds the dilated filter's reach, for example any W
padding with a 1 x 1 x 1 filter.

**Why the tests miss it:** no test pads W that far.

**The fix:** `fixes.py` marks each row of the rectangle. On this path each K-outer tile holds
one tap (`K_REP` is 1 when `C_in > 64`), so the rectangle is exactly what it writes.

### F11: `conv3d_bwd`'s `dx` ignores depth when the output has one depth plane

**Where:** `experimental/conv/conv3d_bwd_kernels.py`, `_conv3d_dx_col2im`. It chooses its 2-D
branch by `D_out > 1` (line 4148). The 2-D branch:
- loops over `(kh, kw)` taps only, so it reads the `kd = 0` filter taps;
- writes only `dx`'s plane 0.

**When it happens:** when depth matters but the output has a single depth plane:
- one frame with a padded 3 x 3 x 3 filter: every gradient is wrong;
- an input with several frames: planes after the first are never written.

**Why the tests miss it:** every tested call with `D_out = 1` has `D = 1` and `K_d = 1`, a
genuinely 2-D case. The sibling GEMM2D path checks this condition (`_dx_gemm2d_supported`,
`conv3d_bwd.py` line 847); col2im does not.

**The fix:** `fixes.py` takes the 3-D branch whenever `D > 1` or `K_d > 1`.

### F12: `conv3d_temporal_unroll` maps depth taps wrongly under dilation

**Where:** `experimental/conv/conv3d_temporal_unroll.py`, line 200. It computes an input
plane's depth tap as `(d_in * dilation_d + pad - d_out * stride) / dilation_d`. The
convolution's tap is `(d_in + pad - d_out * stride) / dilation_d`.

**When it happens:** whenever depth dilation is above 1. Each output plane then reads the
wrong input planes, or none, keeping only the bias. With dilation 1 the two formulas agree.

**Why the tests miss it:** every test uses dilation 1, and no assertion rejects dilation
above 1.

**The fix:** drop the multiplication.

## How they were found

Volta's own checks reported each bug before anyone read the code:
- **F7:** the overlap check on live tiles, plus equivalence against the spec;
- **F9:** an uninitialized read reaching an output;
- **F11 and F12:** equivalence against the spec.

The calls came from fuzzing each kernel over valid configurations. The root causes were then
found by reading the code at the instructions Volta named.

None of these verdicts depends on how the compiler orders instructions: the kernels are wrong
in program order. They have not yet been reproduced on Trainium hardware or NKI's simulator.

## Checked and found correct

Volta proved each kernel below equal to its spec on every element at every call listed, and
race free under `OrderingPolicy::BASELINE`, or under `WAW` (`BASELINE` with write after write
ordered) where the row says so. These results say where not to look. A `WAW` kernel writes a
tile and overwrites it with no read in between, typically a `memset` followed by a DMA; that
is a race only if the compiler does not order two writes to the same bytes.

The calls are the representative ones of the original checks, not their fuzzing campaigns
(e.g. `conv3d`'s 110 random calls). All of them run in about 30 s in release.

| Kernel (nkilib `ad2f1b9`) | Test module | Calls | Result |
|---|---|---|---|
| `core/embeddings/rope` (`RoPE`, contiguous layout, one core) | `layers` | `d_head` 128 with 2 heads and 4 tokens; `d_head` 64 with 2 batches and 3 tokens | equal; race free. The interleaved layout's spec is refuted (128 of 128) |
| `core/embeddings/rope_hf` (from `cos` and `sin`) | `layers` | 2 query heads and 1 key head, 128 tokens, `head_dim` 64; `q_out` and `k_out` | equal; race free |
| `core/output_projection` cte (one core, unquantized) | `layers` | 2 heads of 128, 128 tokens, hidden 128 | equal; race free |
| `core/output_projection` tkg (one core, unquantized) | `layers` | 2 heads of 128, 4 tokens, hidden 512 | equal; race free |
| `core/qkv` tkg (one core, unfused, unquantized, BSD) | `layers` | 4 tokens, hidden 512, 2 query, 1 key and 1 value heads of 128 | equal; race free |
| `core/qkv` cte (one core, unfused, unquantized, BSD) | `layers` | 128 tokens, hidden 128, 2 query, 1 key and 1 value heads of 128 | equal; race free |
| `core/rmsnorm/rmsnorm_quant` (static quantization) | `norms` | `[1, 4, 256]`, `[2, 3, 128]` | equal, over the reals (the fp8 cast is not modelled); race free. Token `t` is divided by row `t` of the `[128, 1]` scale, which the reference takes to be one value broadcast |
| `core/subkernels/rmsnorm_tkg` (one core) | `norms` | default layout at `[1, 4, 256]`, `[1, 1, 128]`, `[2, 80, 256]`, `[3, 5, 384]`; `hidden_dim_tp=True` at `[1, 4, 256]`, `[3, 5, 384]`; `hidden_actual=200` at `[1, 3, 256]` | equal; race free. The other layout's spec is refuted (1,016 of 1,024) |
| `core/subkernels/layernorm_tkg` (one core, with `beta`) | `norms` | `[1, 4, 256]`, `[3, 2, 128]` | equal; race free |
| `core/cumsum/cumsum` | `norms` | float32 and int32 at `[10, 21]` with 4 x 8 tiles; `[3, 2, 17]`, `[8, 16]`, `[1, 1]`; `[4, 8]` and `[2, 3, 600]` at hardware tiles | equal; race free. An exclusive scan is refuted |
| `experimental/scan/linear_scan` | `norms` | `[2, 10]`, `[130, 7]`, `[3, 2, 8]` with `initial`; `result` and `final_state` | equal to itself untiled with a 3-element tile, so carries cross tiles; race free |
| `experimental/scan/selective_scan` (no `D` skip) | `norms` | `[1, 2, 7]` with 3 states, `[2, 130, 5]` with 2, `initial_state`, 3-element tiles; `y` and `final_state` | equal; race free under `WAW` |
| `experimental/scan/ssd` (Mamba-2, no `D` skip) | `norms` | head-outer and chunk-outer, 1 and 2 batches, 2 and 3 chunks, `headdim` 515 (past 512); `y` and `final_state` | equal; race free |
| `experimental/foreach/foreach_elementwise`: `add_scalar`, `add_tensor`, `sub_tensor`, `mul_tensor`, `div_tensor`, `addcdiv`, `addcmul`, `lerp` | `elementwise` | `numel` 43, 16, 4 and 3, with 16-element tiles (full tiles, a partial tile and a tail) | equal; race free |
| `experimental/foreach/foreach_norm`: `l2_norm`, `l1_norm`, `linf_norm` | `elementwise` | `numel` 43, 16 and 3, with 16-element tiles | equal; race free, except `linf_norm` across tiles: its maximum accumulated across `affine_range` iterations is a `MemoryConflict`, since only additions commute there; likely benign |
| `experimental/optimizer/fused_adam` (`adam_kernel`, `adamw_kernel`, no AMSGrad) | `elementwise` | all three outputs at 1 and 300 elements, and at 1,000 with a 3-element tile | equal; race free |
| `experimental/batch_norm/batch_norm_bwd` (no ReLU, no residual, one batch) | `elementwise` | `dx`, `dgamma`, `dbeta` at `[1, 4, 2, 8, 8]`, `[1, 130, 1, 4, 4]`, `[1, 2, 3, 5, 7]` | equal; race free, under `WAW` at `[1, 130, 1, 4, 4]`, whose two channel tiles both write the unread `dbeta_discard_tile` |
| `experimental/pooling/avg_pooling_3d` | `pooling` | kernel/stride/padding 2/2/0, 2/1/1, 3/2/1 in NCDHW on `[1, 2, 5, 6, 7]`; 2/2/0 and 2/1/1 in NDHWC and NCDHW to NDHWC; 2/2/0 and 3/2/1 on `[2, 130, 5, 6, 7]` | equal; race free under `WAW` (a `memset`, then a DMA into padded tiles) |
| `experimental/pooling/avg_pooling_3d_backward` | `pooling` | seven kernel/stride/padding settings on `[1, 2, 5, 6, 7]`, 3/2/1 on `[1, 2, 4, 6, 6]` | equal; race free |
| `experimental/pooling/max_pooling_3d` | `pooling` | 2/2/0, 3/2/1, 3/1/1 on `[1, 2, 5, 6, 7]`, where no axis grows | equal; race free. Growing axes are F7 |
| `experimental/pad/pad` (constant 0, replicate, reflect, circular) | `pooling` | two calls per mode, 1 to 3 padded dimensions, one with 130 channels | equal; race free. Its `reflect requires size >= 2` (line 80) also rejects zero padding on a size-1 axis, which PyTorch accepts: over-strict, not wrong |
| `experimental/conv/conv1d` (no activation) | `conv` | `[2, 64, 40]` to 128 channels with stride 2, dilation 2, padding `(2, 1)` and bias; `[1, 130, 21]` to 130, dilation 3, no bias; `[1, 2, 515]` (two length tiles) | equal; race free under `WAW` |
| `experimental/conv/depthwise_conv1d` (`depthwise_conv1d_implicit_gemm`) | `conv` | 130 channels (two tiles) with stride 2; 200 taps (two tap tiles) with padding `(2, 5)`; stride 4 | equal; race free under `WAW` |
| `experimental/conv/conv3d` (no batch norm, no activation; `C_in` at most 64) | `conv` | two batches; stride 2 with padding 1; dilation 2 with asymmetric padding; a 2 x 3 x 2 filter with mixed strides | equal; race free under `WAW`. `C_in > 64` with wide W padding is F9 |
| `experimental/conv/conv3d_bwd` (`dx`, `dw`, `db`) | `conv` | each gradient on two batches with asymmetric padding; stride 2 with dilation `(1, 2, 1)`; `C_out` 65 (col2im) with three output depth planes | equal; race free under `WAW`. One output depth plane on col2im is F11 |
| `experimental/conv/conv3d_temporal_unroll` (`C_in` 65) | `conv` | `[2, 1, 520]` outputs with a 1 x 1 x 1 filter; `[3, 1, 522]` with 3 x 3 x 3, stride `(2, 1, 1)`, padding | equal; race free under `WAW`. Depth dilation is F12 |
| `experimental/conv/conv3d_transpose` | `conv` | 2 to 65 input channels, filters 2 and 3, strides 1 to 3, dilation 2, padding 0 and 1 | equal; race free under `WAW` |

## Core kernels in progress

`triage.txt` records how far each core kernel call not yet checked gets through Volta at one
small call: traced, lowered and run, then its graph's verdict under `BASELINE` and `WAW`. A
stage that fails names the kernel's first blocker. `nkilib_tests/triage.rs` regenerates the
table and fails when it changes (`VOLTA_BLESS=1` rewrites it), so a change that unblocks a
kernel shows up there.

| Kernel (nkilib `core/`) | Reaches | First blocker |
|---|---|---|
| `rmsnorm/rmsnorm_quant` row | tracing | it stores fp32 scales as fp8 bytes, which is out of model |
| `mlp` cte | lowering | a tile with two free dimensions as an operand |
| `mlp` tkg | tracing | `flatten_dims` of a view whose dimensions are not contiguous |
| `attention/attention_cte` | tracing | `nisa.iota` with a nested `pattern` |
| `attention/attention_tkg` | tracing | a `memset` to `-inf` |

`mlp` sizes its own SBUF heap at 200 KiB a partition, past the 192 KiB Volta assumes for
Trn2, so its calls run with a 224 KiB partition, the bound its context encoding path uses.
`attention_tkg` without fused RoPE needs `q` and `k` in SBUF, so its wrapper copies them
there.
