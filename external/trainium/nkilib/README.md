# Bugs in nkilib's experimental kernels

Volta found four bugs in AWS's [nki-library](https://github.com/aws-neuron/nki-library)
(commit `ad2f1b9`). Each one silently gives wrong outputs, with no error. This folder holds
each bug's kernel at the call that shows it, together with a proposed fix.

`crates/volta_pipeline/tests/trainium/nkilib_tests.rs` runs them all through `just trainium`.
Each buggy call must fail, either with an execution error or with a refutation against the
kernel's spec. The same call with the fix applied must be proved equal to the spec and race
free.

| ID | Kernel | Call | What Volta reports | Proposed fix | Upstream |
|---|---|---|---|---|---|
| F7 | `max_pooling_3d` | `[1, 2, 5, 6, 7]`, kernel 2, stride 1, padding 1 | a tile is read after another tile overwrote its bytes (`ClobberedRead`); reading the shared bytes, 40 of 672 outputs are refuted | one reduce section per axis | not yet filed |
| F9 | `conv3d` (fallback path, `C_in > 64`) | `[1, 130, 1, 3, 4]`, 1 x 1 x 1 filter, W padding `(0, 2)`, and with D and H padding | unwritten PSUM reaches `conv_out` (`UninitializedRead`) | mark each tap's written rectangle, not the flattened span | not yet filed |
| F11 | `conv3d_bwd` `dx` (col2im path, `C_out > 64`) | `[1, 2, 1, 4, 4]`, 3 x 3 x 3 filter, padding 1; `[1, 2, 2, 4, 4]`, 2 x 2 x 2 filter | all 32 elements refuted; with two frames, `dx`'s plane 1 is never written | take the 3-D branch whenever depth matters | [aws-neuron/nki-library#28](https://github.com/aws-neuron/nki-library/issues/28), fix in [#29](https://github.com/aws-neuron/nki-library/pull/29) |
| F12 | `conv3d_temporal_unroll` | `[1, 65, 6, 1, 513]`, 2 x 1 x 1 filter, depth dilation 2 | all 2,052 outputs refuted | stop multiplying `d_in` by the dilation | [aws-neuron/nki-library#26](https://github.com/aws-neuron/nki-library/issues/26), fix in [#27](https://github.com/aws-neuron/nki-library/pull/27) |

Volta also proved other nkilib kernels correct; they are listed in
[Checked and found correct](#checked-and-found-correct) below.

## Layout

- **`nki-library.commit`**: the nki-library commit the kernels are traced from (`ad2f1b9`).
  `just nkilib` fetches it into `target/nkilib`, and `just trainium` runs that first. No
  nkilib source is kept in this repository.
- **`<kernel>.py`**: the wrapper Volta traces. It calls the kernel as released and fixes its
  outputs' names.
- **`<kernel>_fixed.py`**: the same wrapper, but it first imports the kernel's module through
  `fixes.apply`. That applies `fixes.py`'s text edits to the fetched source as the module is
  imported, so `target/nkilib` stays exactly as released.
- **`*.spec`**: each operation as nkilib's own PyTorch reference (`*_torch.py`) defines it.
  - `max_pooling_3d.spec` follows `F.max_pool3d`.
  - `conv3d.spec` follows `nn.Conv3d` after `F.pad`. It gives both `conv_out` (`conv3d`) and
    `y_out` (`conv3d_temporal_unroll`).
  - `conv3d_bwd.spec` gives that convolution's gradients.
  - Evaluated in float64, each spec agrees with the torch reference at the calls above
    (largest relative error 4e-14).

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

Volta also proved these kernels equal to a spec written from nkilib's own PyTorch reference
(`*_torch.py`) at every call below, and race free under `OrderingPolicy::BASELINE` unless the
row says otherwise. These results say where not to look. They were checked with standalone
probes, outside this repository; turning them into cases of `nkilib_tests.rs` is left to a
later change.

| Kernel (nkilib, `ad2f1b9`) | Calls | Result |
|---|---|---|
| `core/subkernels/rmsnorm_tkg` (one core) | `[1, 4, 256]`, `[1, 1, 128]`, `[3, 5, 384]`, `[2, 80, 256]`, `[1, 3, 256]`; default layout, `hidden_dim_tp=True`, `hidden_actual=200` | equal; race free |
| `core/subkernels/layernorm_tkg` (one core, with `beta`) | `[1, 4, 256]`, `[3, 5, 256]` | equal; race free |
| `core/cumsum/cumsum` | float and int32 paths; `[10, 21]`, `[3, 2, 17]`, `[8, 16]`, `[1, 1]` at small tile sizes, `[4, 8]` and `[2, 3, 600]` at hardware ones | equal; race free |
| `experimental/foreach/foreach_elementwise`: `add_scalar`, `add_tensor`, `sub_tensor`, `mul_tensor`, `div_tensor`, `addcdiv`, `addcmul`, `lerp` | `numel` 43, 16, 4 and 3, with 16-element tiles | equal |
| `experimental/foreach/foreach_norm`: `l2_norm`, `l1_norm`, `linf_norm` | `numel` 43, 16 and 3, with 16-element tiles | equal; race free, except `linf_norm`'s maximum accumulated across `affine_range` iterations, which commutes in practice |
| `experimental/pooling/avg_pooling_3d` | kernel/stride/padding 2/2/0, 2/1/1, 3/2/1; NCDHW and NDHWC; `[1, 2, 5, 6, 7]`, `[2, 130, 5, 6, 7]`; 60 fuzzed calls | equal; race free once write after write is ordered (a `memset` then a DMA into padded tiles) |
| `experimental/pooling/avg_pooling_3d_backward` | seven kernel/stride/padding settings on `[1, 2, 5, 6, 7]` and `[1, 2, 4, 6, 6]`; 50 fuzzed calls | equal; race free |
| `experimental/pooling/max_pooling_3d` | 2/2/0, 3/2/1, 3/1/1 on `[1, 2, 5, 6, 7]`; 52 of 60 fuzzed calls | equal; race free. The other 8 are F7 |
| `experimental/conv/conv1d` (no activation) | strides, dilation, asymmetric padding, with and without bias, over 128 channels, two length tiles; 50 fuzzed calls | equal; race free once write after write is ordered |
| `experimental/conv/depthwise_conv1d` (`depthwise_conv1d_implicit_gemm`) | 36 calls: 1 to 200 taps, strides 1 to 4, asymmetric padding, 2 to 258 channels | equal; race free |
| `experimental/conv/conv3d` (no batch norm, no activation) | strides 1 and 2, dilation 2, symmetric and asymmetric padding, two batches; 110 fuzzed calls | equal; race free once write after write is ordered, except F9 and F10 (a division by zero when every tap is in the padding) |
| `experimental/conv/conv3d_bwd` (`dx`, `dw`, `db`) | 60 fuzzed calls: strides 1 and 2, dilations 1 and 2, asymmetric padding, 1 to 130 channels, two batches | equal; race free, except F11 in `dx` |
| `experimental/conv/conv3d_temporal_unroll` | `[2, 1, 520]` and `[3, 1, 522]` outputs, 1 x 1 x 1 and 3 x 3 x 3 filters, strides 1 and 2, padding | equal; race free without depth dilation, F12 with it |
| `experimental/conv/conv3d_transpose` | 39 fuzzed calls: up to 130 channels, filters 1 to 3, strides 1 to 3, dilations 1 and 2, padding 0 to 2 | 37 equal (equivalence only); one too large for the checker; one crash (F10) |
| `experimental/pad/pad` (constant 0, replicate, reflect, circular) | 150 fuzzed calls, up to 130 channels, 1 to 3 padded dimensions | 143 equal and race free; 7 rejected by an over-strict `reflect requires size >= 2` (line 80), not wrong outputs |
| `experimental/scan/linear_scan` | `[2, 10]`, `[130, 7]`, `[3, 2, 8]` with `initial` | equal to itself untiled with a 3-element tile, so carries cross tiles; race free |
| `experimental/scan/selective_scan` (no `D` skip) | `[1, 2, 7]` and `[2, 130, 5]`, states 3 and 2, with `initial_state` | equal, also with a 3-element tile; race free |
| `experimental/scan/ssd` (Mamba-2, no `D` skip) | head-outer and chunk-outer, 1 and 2 batches, 2 and 3 chunks, `headdim` up to 515 | equal; race free |
| `experimental/optimizer/fused_adam` (`adam_kernel`, `adamw_kernel`, no AMSGrad) | 1 to 1,000 elements, also with a 3-element tile | equal; race free |
| `experimental/batch_norm/batch_norm_bwd` (no ReLU, no residual, one batch) | `[1, 4, 2, 8, 8]`, `[1, 130, 1, 4, 4]`, `[1, 2, 3, 5, 7]` | equal; race free |
