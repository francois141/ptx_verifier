"""AKLR kernels checked by Volta: what each case compiles, launches and checks.

`build.py` compiles each case and writes its assembly and launch file; `external/amd/verify.py`
runs them. Importable without AKLR, Triton, FlyDSL or a compiler.

Every kernel is AKLR's own text at `build.AKLR_COMMIT`: a kernel schema
(`aklr/.../impls/<language>/<name>/<uuid>.json`) stores its sources, and `build.py` writes them out
before compiling. A case names its schema by `<op>/<language>/<name>/<uuid>`, relative to the
`impls/` directories under `aklr/ops/` or `aklr/plugins/<engine>/...` (`Schema.path`).

- `Triton`: a `@triton.jit` function of the schema's `kernel.py`, compiled for gfx950 with the
  arguments its `run` passes at the case's shape, specialized as Triton's launcher does (an integer
  argument equal to 1 is a constexpr and passes no argument; a pointer and an integer divisible by
  16 get `tt.divisibility`; a pointer gets `tt.pointer_range=32`, as a tensor under 2 GB does on
  gfx950, so its loads are buffer instructions).
- `Hip`: `<source>.hip` beside this file, compiled by clang for gfx950. Its `// aklr: <file>
  <first>-<last>` lines are replaced by those lines of the schema's source file, so the kernel text
  is AKLR's; the rest instantiates the template the host code picks for the case's shape.
- `FlyDSL`: the schema's `kernel.py`, run in a container with `COMPILE_ONLY=1` through the Python
  `call` the case gives (the kernel's own `run` or its launcher at the case's shape).

A case whose spec depends on its launch (its rows, its block table) generates it as `spec_text`,
which `build.py` writes to `<case>.spec`.

`args` lists the kernel's explicit arguments in order, laid out from the compiled kernel's own
metadata (hidden arguments included): a `Pointer` is an array's address, a `Scalar` a 4- or 8-byte
value. `fixes` replace text, which must occur once, in the case's kernel source before it compiles.
"""

from dataclasses import dataclass, field


@dataclass(frozen=True)
class Array:
    name: str
    kind: str  # "in" or "out"
    dtype: str  # "f32", "bf16" or "i32"
    shape: tuple
    contents: tuple | None = None  # concrete i32 words of an `in` array
    base: int | None = None  # its address; by default the next 64 KiB boundary


@dataclass(frozen=True)
class Pointer:
    array: str


@dataclass(frozen=True)
class Null:
    """A null pointer argument."""


@dataclass(frozen=True)
class Scalar:
    value: int | float
    name: str = ""
    kind: str = "i32"  # "i32", "f32", "i64" or "f64"


@dataclass(frozen=True)
class Tensor:
    """A FlyDSL tensor argument: `array`'s address, then its layout (shape, then strides)."""

    array: str
    shape: tuple
    strides: tuple


@dataclass(frozen=True)
class Fix:
    """Replace `old`, which must occur once in source file `path` of the schema, with `new`."""

    old: str
    new: str
    path: str = "kernel.py"


@dataclass(frozen=True)
class Schema:
    """`<op>/<language>/<name>/<uuid>` of an AKLR kernel schema, under `root` (`aklr/ops` or a
    plugin's directory holding `<op>/impls/`)."""

    id: str
    root: str = "aklr/ops"

    def path(self) -> str:
        op, language, name, uuid = self.id.split("/")
        return f"{self.root}/{op}/impls/{language}/{name}/{uuid}.json"


@dataclass(frozen=True)
class Triton:
    """`kernel` of the schema's `kernel.py`: `args` its runtime arguments by name, as the case's
    `args` give them in order, `constexprs` the others."""

    kernel: str
    constexprs: dict
    options: dict = field(default_factory=lambda: {"num_warps": 4})


@dataclass(frozen=True)
class Hip:
    """`<source>.hip`, compiled with `flags`; `symbol` is a substring of the kernel's mangled name."""

    source: str
    symbol: str
    flags: tuple = ()


@dataclass(frozen=True)
class FlyDSL:
    """Python run after `kernel.py` is imported as `kernel`, which compiles the kernel to launch;
    `symbol` is a substring of its name."""

    call: str
    symbol: str | None = None


@dataclass(frozen=True)
class Case:
    """`check` is "ACCEPT" or "REJECT" against `spec`, or, without a spec, "VERIFIED" or
    "REJECTED" from the graph checks alone; "ABORT" requires the run to stop with an execution
    error, such as an access outside every array. `assembly` reuses another case's kernel, and
    `sample` bounds the elements checked per output array (0: all)."""

    name: str
    description: str
    schema: Schema
    build: Triton | Hip | FlyDSL
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
    spec_text: str | None = None  # written to `spec` by build.py when the case generates it

    def assembly_name(self) -> str:
        return self.assembly or self.name


CASES = []

ARRAY_BASE = 0x10000


def row_views(name, rows, cols, row_stride, dtype="bf16", base=ARRAY_BASE):
    """Output arrays `<name>0`, `<name>1`, ...: the first `cols` elements of each of `rows` rows
    `row_stride` elements apart, at the addresses a row-major `[rows, row_stride]` tensor
    starting at `base` gives them, so a workgroup writing a column tile writes exactly them.
    They must come before the arrays laid out by default; the kernel's pointer is `<name>0`'s."""
    width = {"bf16": 2, "f32": 4, "i32": 4}[dtype]
    return tuple(Array(f"{name}{r}", "out", dtype, (cols,), base=base + r * row_stride * width)
                 for r in range(rows))


# ===== RMSNorm (aklr/ops/rms_norm) =====

RMS_TRITON = Schema("rms_norm/triton/rms_norm_hidden_size6144/76e6a27406ca04fc")
ADD_RMS_TRITON = Schema("rms_norm/triton/add_rms_norm_hidden_size6144/20cb6b303f4acc8c")
EPS = 9.999999747378752e-06  # f32(1e-5), the workloads' epsilon


def rms_norm_triton(name, rows, check="ACCEPT", note=""):
    """`rms_norm(x, weight, epsilon)` on bf16 rows of 6144, one program per row (m < 1024)."""
    return Case(
        name=name,
        description=f"rms_norm (Triton _rms_kernel), bf16, {rows} rows of 6144, CHUNK 2048, "
                    f"4 warps; workgroup 0 normalizes row 0{note}",
        schema=RMS_TRITON,
        build=Triton("_rms_kernel", {"H": 6144, "CHUNK": 2048, "LOOP": 1, "NS": 1}),
        args=(Pointer("x"), Pointer("weight"), Pointer("normalized"), Scalar(rows, "M"),
              Scalar(EPS, "eps", "f32")),
        arrays=(Array("x", "in", "bf16", (rows, 6144)), Array("weight", "in", "bf16", (6144,)),
                Array("normalized", "out", "bf16", (1, 6144))),
        grid=(rows, 1, 1),
        block=256,
        check=check,
        spec="rms_norm.spec",
        dims={"R": 1, "N": 6144, "S": 6144},
    )


def add_rms_norm_triton(name, rows, check="ACCEPT"):
    """`add_rms_norm(x, residual, weight, epsilon)` on bf16 rows of 6144, one program per row."""
    return Case(
        name=name,
        description=f"add_rms_norm (Triton _rms_kernel), bf16, {rows} rows of 6144, CHUNK 2048, "
                    f"4 warps; workgroup 0 normalizes row 0",
        schema=ADD_RMS_TRITON,
        build=Triton("_rms_kernel", {"H": 6144, "CHUNK": 2048}),
        args=(Pointer("x"), Pointer("residual"), Pointer("residual_out"), Pointer("weight"),
              Pointer("normalized"), Scalar(EPS, "eps", "f32")),
        arrays=(Array("x", "in", "bf16", (rows, 6144)), Array("residual", "in", "bf16", (rows, 6144)),
                Array("weight", "in", "bf16", (6144,)),
                Array("normalized", "out", "bf16", (1, 6144)),
                Array("residual_out", "out", "bf16", (1, 6144))),
        grid=(rows, 1, 1),
        block=256,
        check=check,
        spec="add_rms_norm.spec",
        dims={"R": 1, "N": 6144},
    )


CASES += [
    rms_norm_triton("rms_norm_triton", 3),
    add_rms_norm_triton("add_rms_norm_triton", 4),
]


# ===== bf16 GEMM, out = a @ b.T (aklr/ops/gemm) =====

GEMM_N32 = Schema("gemm/triton/gemm_n32_k4096/aaa261fd9041690b")
GEMM_N6144 = Schema("gemm/triton/gemm_n6144_k2048/8307d207feb8e734")


def gemm_rows_dot(name, m, check="ACCEPT"):
    """`gemm_n32_k4096`'s `_rows_dot_kernel`: workgroup 0 computes column 0 of its BLOCK_M rows."""
    block_m = 1 if m <= 40 else 2 if m <= 128 else 4
    return Case(
        name=name,
        description=f"gemm (Triton _rows_dot_kernel), bf16, m={m}, n=32, k=4096, BLOCK_M={block_m}, "
                    f"CHUNK 2048; workgroup 0 computes out[0..{block_m}, 0]",
        schema=GEMM_N32,
        build=Triton("_rows_dot_kernel", {"N": 32, "K": 4096, "BLOCK_M": block_m, "CHUNK": 2048}),
        args=(Pointer("a"), Pointer("b"), Pointer("out0"), Scalar(m, "M"), Scalar(4096, "sam"),
              Scalar(1, "sak"), Scalar(4096, "sbn"), Scalar(1, "sbk"), Scalar(32, "scm")),
        arrays=(*row_views("out", block_m, 1, 32), Array("a", "in", "bf16", (m, 4096)),
                Array("b", "in", "bf16", (32, 4096))),
        grid=(-(-m // block_m) * 32, 1, 1),
        block=256,
        check=check,
        spec=f"gemm_rows{block_m}.spec",
        dims={"M": m, "N": 32, "K": 4096, "C": 1},
    )


def gemm_n6144_m16(name, m, check="ACCEPT"):
    """`gemm_n6144_k2048`'s `_gemm_m16_kernel` (m <= 16): workgroup 0 computes columns 0-31."""
    return Case(
        name=name,
        description=f"gemm (Triton _gemm_m16_kernel), bf16, m={m}, n=6144, k=2048, 16x32 tile, "
                    f"BLOCK_K {512 if m == 1 else 256}; workgroup 0 computes out[0..{m}, 0..32]",
        schema=GEMM_N6144,
        build=Triton("_gemm_m16_kernel",
                     {"N": 6144, "K": 2048, "BLOCK_M": 16, "BLOCK_N": 32,
                      "BLOCK_K": 512 if m == 1 else 256, "N_TILES": 192, "NXCD": 8,
                      "EVEN_M": m == 16},
                     {"num_warps": 2, "num_stages": 3, "waves_per_eu": 2}),
        args=(Pointer("a"), Pointer("b"), Pointer("out0"), Scalar(m, "M")),
        arrays=(*row_views("out", m, 32, 6144), Array("a", "in", "bf16", (m, 2048)),
                Array("b", "in", "bf16", (6144, 2048))),
        grid=(192, 1, 1),
        block=128,
        check=check,
        spec=f"gemm_rows{m}.spec",
        dims={"M": m, "N": 6144, "K": 2048, "C": 32},
    )


def gemm_n6144_xcd(name, m, check="ACCEPT", sample=0):
    """`gemm_n6144_k2048`'s `_gemm_xcd_kernel` (16 < m <= 64): workgroup 0 computes columns
    0-31 of every row, its K walk starting at its rotated phase."""
    tile = (32, 64, 4) if m <= 32 else (64, 256, 1)
    options = {"num_warps": 4, "num_stages": 3, "waves_per_eu": 2, "matrix_instr_nonkdim": 16}
    if m <= 32:
        options["schedule_hint"] = "memory-bound-attention"
    return Case(
        name=name,
        description=f"gemm (Triton _gemm_xcd_kernel), bf16, m={m}, n=6144, k=2048, "
                    f"{tile[0]}x32 tile, BLOCK_K {tile[1]}; workgroup 0 computes out[0..{m}, 0..32]",
        schema=GEMM_N6144,
        build=Triton("_gemm_xcd_kernel",
                     {"N": 6144, "K": 2048, "BLOCK_M": tile[0], "BLOCK_N": 32, "BLOCK_K": tile[1],
                      "NXCD": 8, "CHUNK": 8, "EVEN_M": m == tile[0], "UNROLL": tile[2], "KROT": 1},
                     options),
        args=(Pointer("a"), Pointer("b"), Pointer("out0"), Scalar(m, "M")),
        arrays=(*row_views("out", m, 32, 6144), Array("a", "in", "bf16", (m, 2048)),
                Array("b", "in", "bf16", (6144, 2048))),
        grid=(192, 1, 1),
        block=256,
        check=check,
        spec=f"gemm_rows{m}.spec",
        dims={"M": m, "N": 6144, "K": 2048, "C": 32},
        sample=sample,
    )


CASES += [
    gemm_rows_dot("gemm_rows_dot_m40", 40),
    gemm_rows_dot("gemm_rows_dot_m64", 64),
    gemm_n6144_m16("gemm_n6144_m2", 2),
    gemm_n6144_m16("gemm_n6144_m16", 16),
    gemm_n6144_xcd("gemm_n6144_m24", 24),
    gemm_n6144_xcd("gemm_n6144_m64", 64, sample=0),
]


ADD_RMS_HIP = Schema("rms_norm/hip/add_rms_norm_hidden_size6144/1f0b6c68db064ca4")


def add_rms_norm_hip(name, rows, check="ACCEPT"):
    """`add_rms_norm(x, residual, weight, epsilon)`'s HIP kernel, bf16 rows of 6144: one 256-thread
    block per row, three 16-byte chunks a thread."""
    return Case(
        name=name,
        description=f"add_rms_norm (HIP add_rmsnorm_bf16_kernel<3>), bf16, {rows} rows of 6144; "
                    f"workgroup 0 normalizes row 0",
        schema=ADD_RMS_HIP,
        build=Hip("add_rms_norm_hip", "add_rmsnorm_bf16_kernelILi3E"),
        args=(Pointer("x"), Pointer("residual"), Pointer("weight"), Pointer("normalized"),
              Pointer("residual_out"), Scalar(EPS, "epsilon", "f64")),
        arrays=(Array("x", "in", "bf16", (rows, 6144)), Array("residual", "in", "bf16", (rows, 6144)),
                Array("weight", "in", "bf16", (6144,)),
                Array("normalized", "out", "bf16", (1, 6144)),
                Array("residual_out", "out", "bf16", (1, 6144))),
        grid=(rows, 1, 1),
        block=256,
        check=check,
        spec="add_rms_norm.spec",
        dims={"R": 1, "N": 6144},
    )


CASES += [add_rms_norm_hip("add_rms_norm_hip", 4)]


LMHEAD = {25256: Schema("gemm/hip/gemm_n25256_k8192/a435fa6cead5c1be"),
          62080: Schema("gemm/hip/gemm_n62080_k4096/f72cfb48b99e9164")}
# pack_bf16x2 rounds to nearest even with integer operations on the float's bits, which Volta does
# not model on symbolic values; v_cvt_pk_bf16_f32 rounds the same way (NaNs aside).
HW_BF16_PACK = Fix(
    old="""    const uint32_t a = __builtin_bit_cast(uint32_t, lo);
    const uint32_t b = __builtin_bit_cast(uint32_t, hi);
    const uint32_t ra = (a + 0x7fffu + ((a >> 16) & 1u)) >> 16;
    const uint32_t rb = (b + 0x7fffu + ((b >> 16) & 1u)) >> 16;
    return ra | (rb << 16);""",
    new="""    typedef __attribute__((ext_vector_type(2))) __bf16 bf16x2;
    return __builtin_bit_cast(uint32_t, __builtin_convertvector(
        (__attribute__((ext_vector_type(2))) float){lo, hi}, bf16x2));""",
    path="gemm_stream.h",
)


# The b stage holds NTL rows, but the WN waves read WN * NSW * 16 rows of it, past NTL for 15 of
# the 21 tiles; the fix sizes the stage to the rows read (rows past nr reload row nr - 1).
LMHEAD_STAGE_FIX = Fix(
    old="    static constexpr int NTL = (NT * CH + 63) / 64 * 64 / CH;",
    new="    static constexpr int NTL = ((NT + 15) / 16 + WN_ - 1) / WN_ * WN_ * 16;",
    path="gemm_stream.h",
)


def lmhead_gemm(name, n, k, tile, m, check="ACCEPT", fixes=(HW_BF16_PACK,), note=""):
    """`gemm_stream.h`'s kernel with `tile` (MT, G, SK, SB, SA, WM, WN, WA), the one the schema's
    `run` picks for m: workgroup 0 owns tile 0, b rows 0..nr (8-row groups split evenly)."""
    mt, g, sk, sb, sa, wm, wn, wa = tile
    nr = n // 8 // g * 8
    return Case(
        name=name,
        description=f"gemm (HIP lmhead::gemm_kernel, Tile<{', '.join(map(str, tile))}>), bf16, m={m}, "
                    f"n={n}, k={k}; workgroup 0 computes out[0..{m}, 0..{nr}]{note}",
        schema=LMHEAD[n],
        build=Hip("lmhead_gemm", "gemm_kernel",
                  (f"-DLMHEAD_CFG=lmhead::Cfg<{n},{k},{','.join(map(str, tile))},8>",)),
        args=(Pointer("a"), Pointer("b"), Pointer("out0"), Null(), Null(), Scalar(m, "m")),
        arrays=(*row_views("out", m, nr, n), Array("a", "in", "bf16", (m, k)),
                Array("b", "in", "bf16", (n, k))),
        grid=(g, 1, 1),
        block=64 * wm * wn,
        check=check,
        spec=f"gemm_rows{m}.spec",
        dims={"M": m, "N": n, "K": k, "C": nr},
        fixes=fixes,
    )


CASES += [
    lmhead_gemm("lmhead_n25256_m6", 25256, 8192, (32, 243, 1, 5, 3, 1, 2, 1), 6, check="REJECT"),
    lmhead_gemm("lmhead_n25256_m6_fixed", 25256, 8192, (32, 243, 1, 5, 3, 1, 2, 1), 6,
                fixes=(HW_BF16_PACK, LMHEAD_STAGE_FIX)),
    lmhead_gemm("lmhead_n62080_m8", 62080, 4096, (16, 512, 1, 2, 3, 1, 8, 2), 8),
]


# ===== Paged decode attention (aklr/ops/attention) =====

PAGED = Schema("attention/triton/paged_attention_decode_kv_split_pages_n_heads16_n_kv_heads2_head_dim64_"
               "block_size16/6070d2d9cef49ec6")
LOG2E = 1.4426950408889634


def f32(value: float) -> float:
    import struct
    return struct.unpack("<f", struct.pack("<f", value))[0]


def paged_segment(name, context, table, check="ACCEPT", note=""):
    """`paged_attention_decode`'s `_segment` for one request (batch 1: tile 32, 2 tiles a segment,
    2 warps): workgroup (0, 0) runs the request's first segment and writes its 16 heads' fp32
    partials (acc, then m and l in the log2 domain)."""
    blocks = len(table)
    num_seg = 1 << (max(32, -(-blocks * 16 // 64)) - 1).bit_length()
    return Case(
        name=name,
        description=f"paged_attention_decode (Triton _segment), bf16, 16 query / 2 KV heads, head 64, "
                    f"block 16, batch 1, context {context}, block table {list(table)}, {num_seg} "
                    f"segments; workgroup (0, 0) writes segment 0's partials{note}",
        schema=PAGED,
        build=Triton("_segment",
                     {"N_HEADS": 16, "GROUP": 8, "HEAD": 64, "BS": 16, "TILE": 32, "SEG_TILES": 2,
                      "SHORT_TILES": 80, "SHORT_SEGS": 32, "SHORT_MIN": 4, "NUM_SEG": num_seg},
                     {"num_warps": 2, "num_stages": 1}),
        args=(Pointer("q"), Pointer("k"), Pointer("v"), Pointer("acc0"), Pointer("m0"),
              Pointer("lens"), Pointer("table"), Scalar(f32(0.125 * LOG2E), "qk_scale", "f32"),
              Scalar(0, "window"), Scalar(1024, "sq0"), Scalar(64, "sq1"), Scalar(2048, "sk0"),
              Scalar(128, "sk1"), Scalar(64, "sk2"), Scalar(2048, "sv0"), Scalar(128, "sv1"),
              Scalar(64, "sv2"), Scalar(blocks, "bt_stride")),
        arrays=(*row_views("acc", 16, 64, num_seg * 64, "f32"),
                *(Array(f"{kind}{r}", "out", "f32", (1,), base=ML_BASE + r * num_seg * 8 + 4 * i)
                  for r in range(16) for i, kind in enumerate("ml")),
                Array("q", "in", "bf16", (1, 16, 64)), Array("k", "in", "bf16", (blocks, 16, 2, 64)),
                Array("v", "in", "bf16", (blocks, 16, 2, 64)),
                Array("lens", "in", "i32", (1,), (context,)),
                Array("table", "in", "i32", (1, blocks), tuple(table))),
        grid=(1, num_seg, 1),
        block=128,
        check=check,
        spec=f"{name}.spec",
        dims={"NB": blocks, "Q": 1, "H": 16, "S": 16, "G": 2, "D": 64},
        spec_text=paged_segment_spec(context, table),
    )


ML_BASE = ARRAY_BASE + 0x100000  # the m, l partials, past acc's
LOG2E_F32 = "1.44269502162933349609375"  # f32(log2 e): Volta's exp2(x) is exp(x / f32(log2 e))


def exact(value: float) -> str:
    from decimal import Decimal
    return format(Decimal(value), "f")


def paged_segment_spec(context, table):
    """Segment 0 of one request: every token of the context (it fits one segment), each in its
    block-table block. Over the reals the kernel's online softmax is the plain one, in the log2
    domain of its logits c * (q . k), c = f32(scale * log2 e)."""
    c = exact(f32(0.125 * LOG2E))
    ranges = [(table[t // 16], 16 if (t // 16 + 1) * 16 <= context else context - t)
              for t in range(0, context, 16)]
    lines = [
        "// paged_attention_decode's segment 0 (generated by cases.py's paged_segment_spec): the",
        f"// {context}-token context, blocks {list(table)}; head h reads KV head h / 8. m<h> is the",
        "// largest logit c * (q . k), c = f32(0.125 * log2 e), l<h> the sum of exp2(logit - m), and",
        "// acc<h> the sum of exp2(logit - m) * v, exp2(x) being exp(x / f32(log2 e)) for Volta.",
        "dim NB; dim Q; dim H; dim S; dim G; dim D;",
        "array q[Q, H, D];",
        "array k[NB, S, G, D];",
        "array v[NB, S, G, D];",
    ]
    lines += [f"array acc{h}[D]; array m{h}[Q]; array l{h}[Q];" for h in range(16)]
    for h in range(16):
        g = h // 8

        def logit(block, slot):
            return f"{c} * sum(e in 0..64, q[0, {h}, e] * k[{block}, {slot}, {g}, e])"

        maxima = [f"max(s in 0..{n}, {logit(b, 's')})" for b, n in ranges]
        largest = maxima[0]
        for other in maxima[1:]:
            largest = f"max({largest}, {other})"

        def total(weight):
            return " + ".join(f"sum(s in 0..{n}, exp(({logit(b, 's')} - mx) / {LOG2E_F32}){weight(b)})"
                              for b, n in ranges)

        lines.append(f"m{h}[i] = {largest};")
        lines.append(f"l{h}[i] = let(mx, {largest}, {total(lambda b: '')});")
        lines.append(f"acc{h}[d] = let(mx, {largest}, "
                     f"{total(lambda b: f' * v[{b}, s, {g}, d]')});")
    return "\n".join(lines) + "\n"


CASES += [paged_segment("paged_segment", 40, (3, 0, 2, 1))]


# ===== FlyDSL bf16 GEMM (aklr/ops/gemm/impls/flydsl) =====

GEMM_N2304 = Schema("gemm/flydsl/gemm_n2304_k8192/a5184eccfc6977a7")


def gemm_n2304_gemv(name, m, check="ACCEPT", fixes=(), note=""):
    """`gemm_n2304_k8192`'s "gemv" kernel (m <= 16): each of 256 workgroups owns 9 rows of b over
    the full K, staged with A through a 4-deep LDS ring by DMA; 4 waves split each stage's K and
    add their sums in LDS. Workgroup 0 computes out[0..m, 0..9]."""
    return Case(
        name=name,
        description=f"gemm (FlyDSL gemm_n2304_k8192_gemv), bf16, m={m}, n=2304, k=8192, 9 rows of b "
                    f"a workgroup, 4 waves, 4-deep ring; workgroup 0 computes out[0..{m}, 0..9]{note}",
        schema=GEMM_N2304,
        build=FlyDSL(f"""
import flydsl.expr as fx
launch, _ = kernel._launcher({m})
a = torch.empty({m}, 8192, dtype=torch.bfloat16)
b = torch.empty(2304, 8192, dtype=torch.bfloat16)
out = torch.empty({m}, 2304, dtype=torch.bfloat16)
launch(a, b, out, out, stream=fx.Stream(None))
"""),
        args=(Tensor("a", (m, 8192), (8192, 1)), Tensor("b", (2304, 8192), (8192, 1)),
              Tensor("out0", (m, 2304), (2304, 1))),
        arrays=(*row_views("out", m, 9, 2304), Array("a", "in", "bf16", (m, 8192)),
                Array("b", "in", "bf16", (2304, 8192))),
        grid=(256, 1, 1),
        block=256,
        check=check,
        spec=f"gemm_rows{m}.spec",
        dims={"M": m, "N": 2304, "K": 8192, "C": 9},
        fixes=fixes,
    )


# The gemv's stage barrier waits for its DMAs only; the "big" path's also waits lgkmcnt(0).
GEMV_BARRIER_FIX = Fix(
    old='f"s_waitcnt vmcnt({vm})\\n\\ts_barrier"',
    new='f"s_waitcnt vmcnt({vm}) lgkmcnt(0)\\n\\ts_barrier"',
)

CASES += [
    gemm_n2304_gemv("gemm_n2304_gemv_m8", 8, check="REJECT"),
    gemm_n2304_gemv("gemm_n2304_gemv_m8_fixed", 8, fixes=(GEMV_BARRIER_FIX,)),
]


UNIFIED = {
    "global": Schema("attention/triton/unified_attention_max_q8_kv_split_pages_n_heads16_n_kv_heads2_"
                     "head_dim64_block_size16/6a75fb72aaa797fc"),
    "window": Schema("attention/triton/unified_attention_max_q8_window2047_0_kv_split_pages_n_heads16_"
                     "n_kv_heads2_head_dim64_block_size16/1516b0eb9622786d"),
}


def unified_segment(name, qlen, context, table, window=-1, check="VERIFIED", note=""):
    """`unified_attention`'s `_attn_segment` for one request (batch 1, so the plan's tile 64,
    chunk 64 and 128 segments, or 64 with a window): workgroup (0, 0, 0) runs KV head 0's
    first segment for the request's queries and query heads 0-7."""
    blocks = len(table)
    num_seg = 128 if window < 0 else 64
    tile, chunk = (64, 64) if window < 0 else (64, 32)
    return Case(
        name=name,
        description=f"unified_attention (Triton _attn_segment), bf16, 16 query / 2 KV heads, head 64, "
                    f"block 16, one request of {qlen} queries over {context} tokens, window "
                    f"{window}, {num_seg} segments; workgroup (0, 0, 0) runs segment 0{note}",
        schema=UNIFIED["global" if window < 0 else "window"],
        build=Triton("_attn_segment",
                     {"WINDOW": window, "BLOCK_Q": 8, "GROUP": 8, "HEAD": 64, "BS": 16, "TILE": tile,
                      "CHUNK": chunk, "NUM_SEG": num_seg, "N_HEADS": 16},
                     {"num_warps": 4, "num_stages": 1}),
        args=(Pointer("q"), Pointer("k"), Pointer("v"), Pointer("out"), Pointer("acc"),
              Pointer("ml"), Pointer("cu"), Pointer("lens"), Pointer("table"),
              Scalar(f32(0.125 * LOG2E), "qk_scale", "f32"), Scalar(1024, "sq0"), Scalar(64, "sq1"),
              Scalar(2048, "sk0"), Scalar(128, "sk1"), Scalar(64, "sk2"), Scalar(2048, "sv0"),
              Scalar(128, "sv1"), Scalar(64, "sv2"), Scalar(1024, "so0"), Scalar(64, "so1"),
              Scalar(blocks, "bt_stride")),
        arrays=(Array("acc", "out", "f32", (qlen * 16 * num_seg * 64,)),
                Array("ml", "out", "f32", (qlen * 16 * num_seg * 2,)),
                Array("out", "out", "bf16", (qlen, 16, 64)),
                Array("q", "in", "bf16", (qlen, 16, 64)), Array("k", "in", "bf16", (blocks, 16, 2, 64)),
                Array("v", "in", "bf16", (blocks, 16, 2, 64)),
                Array("cu", "in", "i32", (2,), (0, qlen)), Array("lens", "in", "i32", (1,), (context,)),
                Array("table", "in", "i32", (1, blocks), tuple(table))),
        grid=(1, 2, num_seg),
        block=256,
        check=check,
    )


# Triton's epilogue converts m_i's layout through LDS with two waves storing their copies of
# the same row maxima to the same words, unordered: a write/write race in Volta's model, which
# has no exception for equal values (README.md).
CASES += [unified_segment("unified_segment", 8, 40, (3, 0, 2, 1), check="REJECTED")]
