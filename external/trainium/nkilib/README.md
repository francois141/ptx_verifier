# Bugs in nkilib's experimental kernels

Volta found four bugs in AWS's [nki-library](https://github.com/aws-neuron/nki-library)
(commit `ad2f1b9`). Each one silently gives wrong outputs, with no error. This folder holds
each bug's kernel at the call that shows it, together with a proposed fix.

`crates/volta_pipeline/tests/trainium/nkilib_tests.rs` runs them all through `just trainium`.
Each buggy call must fail, either with an execution error or with a refutation against the
kernel's spec. The same call with the fix applied must be proved equal to the spec and race
free.

| ID | Kernel | Call | What Volta reports | Proposed fix |
|---|---|---|---|---|
| F7 | `max_pooling_3d` | `[1, 2, 5, 6, 7]`, kernel 2, stride 1, padding 1 | a tile is read after another tile overwrote its bytes (`ClobberedRead`); reading the shared bytes, 40 of 672 outputs are refuted | one reduce section per axis |
| F9 | `conv3d` (fallback path, `C_in > 64`) | `[1, 130, 1, 3, 4]`, 1 x 1 x 1 filter, W padding `(0, 2)`, and with D and H padding | unwritten PSUM reaches `conv_out` (`UninitializedRead`) | mark each tap's written rectangle, not the flattened span |
| F11 | `conv3d_bwd` `dx` (col2im path, `C_out > 64`) | `[1, 2, 1, 4, 4]`, 3 x 3 x 3 filter, padding 1; `[1, 2, 2, 4, 4]`, 2 x 2 x 2 filter | all 32 elements refuted; with two frames, `dx`'s plane 1 is never written | take the 3-D branch whenever depth matters |
| F12 | `conv3d_temporal_unroll` | `[1, 65, 6, 1, 513]`, 2 x 1 x 1 filter, depth dilation 2 | all 2,052 outputs refuted | stop multiplying `d_in` by the dilation |

## Layout

- **`src/`**: the nkilib modules these four kernels import, vendored unmodified at `ad2f1b9`
  under nkilib's Apache-2.0 license (`src/LICENSE`, `src/NOTICE`).
- **`<kernel>.py`**: the wrapper Volta traces. It calls the kernel as released and fixes its
  outputs' names.
- **`<kernel>_fixed.py`**: the same wrapper, but it first imports the kernel's module through
  `fixes.apply`. That applies `fixes.py`'s text edits to the vendored source as the module is
  imported, so `src/` stays exactly as released.
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
