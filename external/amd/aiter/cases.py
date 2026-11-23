"""Aiter kernels checked by Volta: what each case compiles, launches and checks.

`build.py` compiles each case and writes its assembly and launch file; `external/amd/verify.py`
runs them. Importable without Aiter, Triton or a compiler.

A case's kernel comes from Aiter's sources at `build.AITER_COMMIT`, in one of two ways:

- `Hip`: `<source>.hip` beside this file, compiled by clang for gfx950 with Aiter's JIT flags.
  Its `// aiter: <path> <first>-<last>` lines are replaced by those lines of Aiter's file, so
  the kernel text is Aiter's own; the rest of the file includes Aiter's headers and instantiates
  the template the host dispatch picks for the case's shape.
- `Triton`: a `@triton.jit` function of Aiter's Triton kernels, compiled offline in a container.

`args` lists the kernel's explicit arguments in order, laid out from the compiled kernel's own
metadata (hidden arguments included): a `Pointer` is an array's address, a `Scalar` a 4- or
8-byte value. `fixes` replace text, which must occur once, in the case's kernel source before
it compiles: a `.hip` file's text after splicing, or the Triton kernel's Python file.
"""

from dataclasses import dataclass, field


@dataclass(frozen=True)
class Array:
    name: str
    kind: str  # "in" or "out"
    dtype: str  # "f32", "bf16" or "i32"
    shape: tuple
    contents: tuple | None = None  # concrete i32 words of an `in` array


@dataclass(frozen=True)
class Pointer:
    """The address of `array`, plus `offset` bytes."""

    array: str
    offset: int = 0


@dataclass(frozen=True)
class Null:
    """A null pointer argument."""


@dataclass(frozen=True)
class Scalar:
    value: int | float
    name: str = ""
    kind: str = "i32"  # "i32", "f32", "i64", "f64" or "u8" (a bool)


@dataclass(frozen=True)
class Struct:
    """A by-value struct argument of `size` bytes: each field a `Pointer`, `Null` or `Scalar`
    at its byte offset; other bytes are zero."""

    size: int
    fields: tuple  # (offset, Pointer | Null | Scalar) pairs


@dataclass(frozen=True)
class Fix:
    """Replace `old`, which must occur once, with `new`: in the case's `.hip` text, or in the
    Aiter header `path` (relative to the checkout) that it includes."""

    old: str
    new: str
    path: str | None = None


@dataclass(frozen=True)
class Hip:
    """`<source>.hip`, compiled with Aiter's flags plus `flags` (the module's
    `flags_extra_hip` in aiter/jit/optCompilerConfig.json); `symbol` is a substring of the
    mangled name of the kernel to launch."""

    source: str
    symbol: str
    flags: tuple = ()


@dataclass(frozen=True)
class Triton:
    """`kernel` of Aiter's `module` (a path under aiter/ops/triton/_triton_kernels/), compiled
    with `signature` (types of its runtime arguments; the others are constexprs), `constexprs`
    and `options`. As Triton's launcher does, an integer argument equal to 1 is a constexpr and
    passes no argument."""

    module: str
    kernel: str
    signature: dict
    constexprs: dict
    options: dict = field(default_factory=lambda: {"num_warps": 4})
    divisible: tuple = ()  # integer arguments divisible by 16, which Triton's launcher specializes


@dataclass(frozen=True)
class Case:
    """`check` is "ACCEPT" or "REJECT" against `spec`, or, without a spec, "VERIFIED" or
    "REJECTED" from the graph checks alone; "ABORT" requires the run to stop with an execution
    error, such as an access outside every array. `assembly` reuses another case's kernel,
    and `sample` bounds the elements checked per output array (0: all)."""

    name: str
    description: str
    source: str
    build: Hip | Triton
    args: tuple
    arrays: tuple
    grid: tuple
    block: int | tuple
    check: str
    spec: str | None = None
    dims: dict = field(default_factory=dict)
    fixes: tuple = ()
    assembly: str | None = None
    sample: int = 0

    def assembly_name(self) -> str:
        return self.assembly or (self.name if self.fixes else self.build_name())

    def build_name(self) -> str:
        """The `.s` an unfixed build writes: one per `.hip` file, else one per case."""
        return self.build.source if isinstance(self.build, Hip) else self.name


def nextpow2(n: int) -> int:
    return 1 if n <= 1 else 1 << (n - 1).bit_length()


# ===== Activations (csrc/kernels/activation_kernels.cu) =====

ACTIVATION = "csrc/kernels/activation_kernels.cu"
ACTIVATION_FLAGS = ("-ffast-math", "-DCK_TILE_USE_BUFFER_ADDRESSING_BUILTIN=0")


def silu_and_mul(name, d, tokens=1, check="ACCEPT", note="", written_tokens=None):
    """`aiter.silu_and_mul(out, input)` on bf16 rows: workgroup t computes token t."""
    vec = min(max(nextpow2(d // 64), 2), 8)
    waves = min(nextpow2(d // 64 // vec), 8)
    rows = written_tokens or tokens
    return Case(
        name=name,
        description=f"silu_and_mul, bf16, {tokens} token(s) of d={d}: out = silu(x) * y, "
                    f"VEC_SIZE={vec}, {waves} wave(s){note}",
        source=f"{ACTIVATION}:33 (act_and_mul_kernel), dispatch :1150",
        build=Hip("activation", f"act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernel"
                                f"IDF16bEEfS3_EELi{vec}ELb0ELi3E", ACTIVATION_FLAGS),
        args=(Pointer("out"), Pointer("input"), Scalar(d, "d"), Scalar(0.0, "limit", "f32")),
        arrays=(Array("input", "in", "bf16", (tokens, 2, d)),
                Array("out", "out", "bf16", (rows, d))),
        grid=(tokens, 1, 1),
        block=64 * waves,
        check=check,
        spec="silu_and_mul.spec",
        dims={"T": 1, "S": 2, "D": d},
    )


# ===== RMSNorm (csrc/include/opus/rmsnorm_opus_kernel.hpp, launched by csrc/include/rmsnorm.h) =====

RMSNORM = "csrc/include/opus/rmsnorm_opus_kernel.hpp:132 (rmsnorm_opus_kernel), dispatch csrc/include/rmsnorm.h:44"
RMSNORM_FLAGS = ("-D__HIPCC_RTC__", "-DOPUS_FP32_to_BF16_DEFAULT=5")
EPS = 9.999999974752427e-07  # f32(1e-6), Aiter's default epsilon


def pick_dims(rows, vhid):
    """csrc/include/rmsnorm.h's launch geometry: (threads per row, rows per block), blocks."""
    budget = 1024 if rows < 256 else 256
    want, tpr = (vhid + 1) // 2, 64
    while tpr < want and tpr < budget and tpr < 256:
        tpr <<= 1
    rpb = max(1, min(budget // tpr, rows))
    return (tpr, rpb), -(-rows // rpb)


def rmsnorm(name, rows, hidden, add=False, in_s=None, check="ACCEPT", note="", sample=0):
    """`aiter.rms_norm_opus(out, x, weight, eps)`, or with `add`
    `aiter.rmsnorm2d_fwd_with_add_opus(out, x, residual_in, residual_out, weight, eps)`, on bf16
    rows of `in_s` elements (default `hidden`): workgroup 0 normalizes its first rows."""
    in_s = in_s or hidden
    block, blocks = pick_dims(rows, hidden // 8)
    covered = min(rows, block[1])  # rows workgroup 0 normalizes
    residual = (Pointer("residual"), Pointer("residual_out")) if add else (Null(), Null())
    arrays = [Array("x", "in", "bf16", (rows, in_s)), Array("weight", "in", "bf16", (hidden,)),
              Array("y", "out", "bf16", (covered, hidden))]
    if add:
        arrays[1:1] = [Array("residual", "in", "bf16", (rows, hidden))]
        arrays.append(Array("residual_out", "out", "bf16", (covered, hidden)))
    return Case(
        name=name,
        description=f"{'rmsnorm2d_fwd_with_add_opus' if add else 'rms_norm_opus'}, bf16, {rows} "
                    f"row(s) of {hidden}, block {block[0]}x{block[1]}{note}",
        source=RMSNORM,
        build=Hip("rmsnorm", f"rmsnorm_opus_traitsIDF16bLi8ELb0EEELb{int(add)}E", RMSNORM_FLAGS),
        args=(Pointer("y"), Pointer("x"), Pointer("weight"), *residual,
              Scalar(EPS, "epsilon", "f32"), Scalar(rows, "rows"), Scalar(hidden, "hidden"),
              Scalar(in_s, "in_s"), Scalar(0, "model_sensitive")),
        arrays=tuple(arrays),
        grid=(blocks, 1, 1),
        block=block,
        check=check,
        spec="fused_add_rmsnorm.spec" if add else "rmsnorm.spec",
        dims={"R": covered, "N": hidden, "S": in_s},
        sample=sample,
    )


# ===== MoE (csrc/kernels/topk_softmax_kernels.cu) =====

def moe_sum(name, topk, hidden, check="ACCEPT", note=""):
    """`aiter.moe_sum(input [T, topk, hidden], output [T, hidden])` on fp32: workgroup 0 sums
    token 0's expert outputs."""
    return Case(
        name=name,
        description=f"moe_sum, fp32, topk={topk}, hidden={hidden}, {min(hidden, 1024)} threads{note}",
        source="csrc/kernels/topk_softmax_kernels.cu:772 (moe_sum_kernel), dispatch :1570",
        build=Hip("moe_sum", f"moe_sum_kernelIfLi{topk}E"),
        args=(Pointer("out"), Pointer("input"), Scalar(hidden, "hidden_size")),
        arrays=(Array("input", "in", "f32", (2, topk, hidden)),
                Array("out", "out", "f32", (1, hidden))),
        grid=(2, 1, 1),
        block=min(hidden, 1024),
        check=check,
        spec="moe_sum.spec",
        dims={"T": 1, "K": topk, "H": hidden},
    )


# ===== More activations (csrc/kernels/activation_kernels.cu) =====

def silu_and_mul_bias(name, d, experts=4, expert=1, check="ACCEPT"):
    """`aiter.silu_and_mul_bias(out, input, expert_ids, bias)`: out = silu(x + bias[e, 0]) *
    (y + bias[e, 1]) with fp32 bias; workgroup 0 computes token 0, routed to `expert`."""
    vec = min(max(nextpow2(d // 64), 2), 8)
    waves = min(nextpow2(d // 64 // vec), 8)
    return Case(
        name=name,
        description=f"silu_and_mul_bias, bf16 rows with fp32 bias, d={d}, {experts} experts, "
                    f"token 0 on expert {expert}, VEC_SIZE={vec}",
        source=f"{ACTIVATION}:187 (act_and_mul_bias_kernel), dispatch :1467",
        build=Hip("activation", f"act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi{vec}E",
                  ACTIVATION_FLAGS),
        args=(Pointer("out"), Pointer("input"), Pointer("expert_ids"), Pointer("bias"),
              Scalar(d, "d"), Scalar(experts, "num_experts", "i64")),
        arrays=(Array("input", "in", "bf16", (2, 2, d)),
                Array("expert_ids", "in", "i32", (2,), (expert, 0)),
                Array("bias", "in", "f32", (experts, 2, d)),
                Array("out", "out", "bf16", (1, d))),
        grid=(2, 1, 1),
        block=64 * waves,
        check=check,
        spec="silu_and_mul_bias.spec",
        dims={"T": 1, "S": 2, "D": d, "E": experts},
    )


def gelu_fast(name, numel, check="ABORT", note=""):
    """`aiter.gelu_fast(out, input)` over `numel` bf16 elements (LAUNCH_ACTIVATION_KERNEL_VEC)."""
    vec = min(max(nextpow2(numel // 64), 1), 8)
    vecs = -(-numel // vec)
    waves = min(max(nextpow2(vecs // 64), 1), 8)
    blocks = min(-(-vecs // (64 * waves)), 2048)
    return Case(
        name=name,
        description=f"gelu_fast, bf16, {numel} elements, VEC_SIZE={vec}, {blocks} workgroup(s) "
                    f"of {64 * waves}{note}",
        source=f"{ACTIVATION}:2091 (activation_kernel_vec), dispatch :2181",
        build=Hip("activation", f"gelu_fast_kernelIDF16bEEfS3_EELi{vec}E", ACTIVATION_FLAGS),
        args=(Pointer("out"), Pointer("input"), Scalar(numel, "numel", "i64")),
        arrays=(Array("out", "out", "bf16", (numel,)), Array("input", "in", "bf16", (numel,))),
        grid=(blocks, 1, 1),
        block=64 * waves,
        check=check,
    )


# ===== HIP RMSNorm (csrc/kernels/rmsnorm_quant_kernels.cu), aiter.rms_norm's 2-D path =====

RMSNORM_HIP = "csrc/kernels/rmsnorm_quant_kernels.cu:24 (add_rmsnorm_quant_kernel), dispatch :677"


def rmsnorm_hip(name, n, add=False, check="ACCEPT", note=""):
    """`aiter.rms_norm(out, x, weight, eps)`, or with `add` `aiter.rmsnorm2d_fwd_with_add`, on
    bf16 rows: one row per workgroup, which computes row 0."""
    block, tds = (128, 8) if n <= 1024 else (256, 16)
    residual = (Pointer("residual"),) if add else (Null(),)
    arrays = [Array("x", "in", "bf16", (2, n)), Array("weight", "in", "bf16", (n,)),
              Array("y", "out", "bf16", (1, n))]
    if add:
        arrays += [Array("residual", "in", "bf16", (2, n)),
                   Array("residual_out", "out", "bf16", (1, n))]
    return Case(
        name=name,
        description=f"{'rmsnorm2d_fwd_with_add' if add else 'rms_norm'} (HIP), bf16, rows of {n}, "
                    f"{block} threads of {tds} elements{note}",
        source=RMSNORM_HIP,
        build=Hip("rmsnorm_hip", f"add_rmsnorm_quant_kernelIDF16bDF16bLi{block}ELi{tds}ELb{int(add)}E",
                  ("-ffast-math", "-DOPUS_FP32_to_BF16_DEFAULT=5")),
        args=(Pointer("y"), Pointer("residual_out") if add else Null(), Null(), Pointer("x"),
              *residual, Pointer("weight"), Scalar(EPS, "epsilon", "f64"), Scalar(0, "gemma", "u8"),
              Scalar(2, "m"), Scalar(n, "n"), Scalar(n, "input_stride"),
              Scalar(n if add else 0, "residual_in_stride"),
              Scalar(n if add else 0, "residual_out_stride"), Scalar(n, "out_stride"),
              Scalar(0, "group_size"), Scalar(0, "shuffle_scale", "u8"),
              Scalar(0, "emit_e8m0_scale", "u8")),
        arrays=tuple(arrays),
        grid=(2, 1, 1),
        block=block,
        check=check,
        spec="fused_add_rmsnorm.spec" if add else "rmsnorm.spec",
        dims={"R": 1, "N": n, "S": n},
    )


# ===== Fused Q/K RMSNorm (csrc/kernels/fused_qk_norm.cu) =====

# block_reduce's staging buffer needs a barrier between two calls (hip_reduce.h:387); the row
# loop has none, so a fast wave's next-row partial can overwrite one a slow wave has yet to read.
FUSED_QK_FIX = Fix(
    "        rcp[0] = block_reduce<float, decltype(sum_f), BlockSize, true>(square_sum, sum_f);\n",
    "        if(r > 0)\n            __syncthreads();\n"
    "        rcp[0] = block_reduce<float, decltype(sum_f), BlockSize, true>(square_sum, sum_f);\n",
)


def fused_qk_rmsnorm(name, m, n, check="ACCEPT", fixes=(), note=""):
    """`aiter.fused_qk_rmsnorm(q, q_weight, eps, k, k_weight, eps, q_out, k_out)` on bf16 heads
    of n (512 < n <= 1024): workgroup (0, 0) normalizes q's first num_row rows."""
    rows = 4 if m >= 4096 else 1
    return Case(
        name=name,
        description=f"fused_qk_rmsnorm, bf16, m={m} rows of q_n=k_n={n}, num_row={rows}{note}",
        source="csrc/kernels/fused_qk_norm.cu:26 (fused_qk_rmsnorm_kernel), dispatch :219",
        build=Hip("fused_qk_norm", f"fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi{rows}E",
                  ("-DENABLE_FP8",)),
        args=(Pointer("y"), Pointer("k_out"), Pointer("x"), Pointer("k"), Pointer("weight"),
              Pointer("k_weight"), Scalar(EPS, "q_epsilon", "f32"), Scalar(EPS, "k_epsilon", "f32"),
              Scalar(m, "m"), Scalar(n, "q_n"), Scalar(n, "k_n"), Scalar(n, "q_in_stride"),
              Scalar(n, "k_in_stride"), Scalar(n, "q_out_stride"), Scalar(n, "k_out_stride")),
        arrays=(Array("x", "in", "bf16", (rows, n)), Array("weight", "in", "bf16", (n,)),
                Array("y", "out", "bf16", (rows, n)), Array("k", "in", "bf16", (1, n)),
                Array("k_weight", "in", "bf16", (n,)), Array("k_out", "out", "bf16", (1, n))),
        grid=(-(-m // rows), 2, 1),
        block=128,
        check=check,
        spec="rmsnorm.spec",
        dims={"R": rows, "N": n, "S": n},
        fixes=fixes,
    )


# ===== GroupNorm (csrc/kernels/groupnorm.cu) =====

GROUPNORM = "csrc/kernels/groupnorm.cu:208 (groupnorm_kernel_dispatch_up), :236 (_down), dispatch :281"
GN_EPS = 2.0 ** -20


def groupnorm_grid(batch, channels, groups, per_channel):
    """launchGroupNormKernel's grid: (gridx, batch * groups), and whether it takes align4."""
    outer, inner = batch * groups, channels // groups * per_channel
    gridx = -(-inner // (8 * 1024))
    align4 = inner % 4 == 0 and gridx >= 16
    if align4:
        gridx = max(1, gridx // 4)
    return (min(-(-4096 // outer), gridx), outer, 1), align4


def groupnorm(name, kernel, batch, channels, groups, per_channel, check="ACCEPT", note=""):
    """`aiter.groupnorm_run` on fp32 [batch, channels, per_channel]: workgroup (0, 0) covers group
    0 of sample 0, channels 0 to channels / groups - 1."""
    grid, align4 = groupnorm_grid(batch, channels, groups, per_channel)
    assert grid[0] == 1, "the specs read the one partial sum of a single-block group"
    cg = channels // groups
    common = (Scalar(groups, "num_groups"), Scalar(channels, "num_channels"),
              Scalar(per_channel, "numel_per_channel", "i64"))
    x = Array("x", "in", "f32", (cg, per_channel))
    if kernel == "up":
        args = (*common, Scalar(int(align4), "align4", "u8"), Pointer("x"), Pointer("mean_acc"),
                Pointer("square_mean_acc"))
        arrays = (x, Array("mean_acc", "out", "f32", (1,)),
                  Array("square_mean_acc", "out", "f32", (1,)))
    else:
        args = (*common, Scalar(GN_EPS, "epsilon", "f32"), Scalar(int(align4), "align4", "u8"),
                Pointer("x"), Pointer("weight"), Pointer("bias"), Pointer("mean_acc"),
                Pointer("square_mean_acc"), Pointer("y"))
        arrays = (x, Array("weight", "in", "f32", (channels,)), Array("bias", "in", "f32", (channels,)),
                  Array("mean_acc", "in", "f32", (1,)), Array("square_mean_acc", "in", "f32", (1,)),
                  Array("y", "out", "f32", (cg, per_channel)))
    return Case(
        name=name,
        description=f"groupnorm {kernel} kernel, fp32 [{batch}, {channels}, {per_channel}], "
                    f"{groups} groups, {'align4' if align4 else 'scalar'} path{note}",
        source=GROUPNORM,
        build=Hip("groupnorm", f"groupnorm_kernel_dispatch_{kernel}IfLj1024E"),
        args=args,
        arrays=arrays,
        grid=grid,
        block=1024,
        check=check,
        spec=f"groupnorm_{kernel}.spec",
        dims={"CG": cg, "P": per_channel, "C": channels, "INNER": cg * per_channel, "ONE": 1},
    )


CASES = (
    silu_and_mul("silu_and_mul", 4096),
    silu_and_mul("silu_and_mul_d200", 200, note=", 50 of 64 lanes active"),
    # Odd d: the buffers round d up to whole words, so the last 2-element vector reads the next
    # row's first element and stores into token 1's out[1, 0].
    silu_and_mul("silu_and_mul_odd_d", 65, tokens=2, written_tokens=2, check="REJECT",
                 note=", d odd"),
    rmsnorm("rmsnorm", 1, 4096),
    rmsnorm("rmsnorm_rows", 4, 512, note=", four rows per workgroup"),
    rmsnorm("rmsnorm_strided", 2, 512, in_s=1024, note=", input rows 1024 apart (a split view)"),
    rmsnorm("fused_add_rmsnorm", 1, 4096, add=True),
    silu_and_mul_bias("silu_and_mul_bias", 64),
    # The second vector of each thread is predicated on its start only, so the last one reads
    # and writes past the tensor when numel is not a multiple of VEC_SIZE.
    gelu_fast("gelu_fast_ragged", 131, note=", numel not a multiple of VEC_SIZE"),
    rmsnorm_hip("rmsnorm_hip", 4096),
    rmsnorm_hip("rmsnorm_hip_1024", 1024),
    rmsnorm_hip("add_rmsnorm_hip", 4096, add=True),
    fused_qk_rmsnorm("fused_qk_rmsnorm", 8, 1024, note=" (m < 4096)"),
    fused_qk_rmsnorm("fused_qk_rmsnorm_rows", 4096, 1024, check="REJECT",
                     note=": the row loop reuses block_reduce's LDS with no barrier"),
    fused_qk_rmsnorm("fused_qk_rmsnorm_rows_fixed", 4096, 1024, fixes=(FUSED_QK_FIX,),
                     note=", a barrier before each later row's reduction"),
    groupnorm("groupnorm_up", "up", 2, 64, 32, 32),
    groupnorm("groupnorm_down", "down", 2, 64, 32, 32),
    groupnorm("groupnorm_down_align4", "down", 128, 64, 32, 61444,
              note=", channels a multiple of 4 long"),
    # align4 needs inner_size % 4 == 0 only: with 61442-element channels a 4-vector straddles
    # channels 0 and 1 and takes channel 0's weight and bias.
    groupnorm("groupnorm_down_straddle", "down", 128, 64, 32, 61442, check="REJECT",
              note=", 4-vectors straddling two channels"),
    moe_sum("moe_sum", 2, 2048, note=", two threads' worth of columns each"),
    moe_sum("moe_sum_topk4", 4, 704),
)
