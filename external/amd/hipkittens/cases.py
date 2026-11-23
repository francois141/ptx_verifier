"""HipKittens kernels checked by Volta: what each case compiles, launches and checks.

`compile.py` compiles every `Kernel` from a HipKittens checkout and writes its assembly and each
case's launch file; `external/amd/verify.py` runs the cases. Importable without HipKittens.

A kernel takes one by-value globals struct, then any `args`. A case gives that struct's fields by
name: a `Gl` is a `kittens::gl` over one of the case's arrays, with its four dimensions; a
`Scalar` is a number written at the field's offset; a field the case leaves out is zero, as an
unused stream is.

Volta runs workgroup 0, so a case whose grid has more workgroups checks the first one's outputs:
its spec defines exactly the elements that workgroup writes, a prefix of each output array.
"""

from dataclasses import dataclass, field


@dataclass(frozen=True)
class Fix:
    """Replace `old`, which must occur exactly `count` times, with `new` in the kernel's source."""

    old: str
    new: str
    count: int = 1


@dataclass(frozen=True)
class Kernel:
    """`source` is a path in the HipKittens checkout, compiled as it is but for `fixes`, with
    `defines` setting the sizes a kernel leaves to `#ifndef` (`("ATTN_N", 256)`)."""

    name: str
    source: str
    fixes: tuple = ()
    defines: tuple = ()


@dataclass(frozen=True)
class Array:
    name: str
    kind: str  # "in" or "out"
    dtype: str  # "bf16" or "f32"
    shape: tuple


@dataclass(frozen=True)
class Gl:
    """A `kittens::gl` over `array`: its pointer and its batch, depth, rows and columns."""

    array: str
    dims: tuple


@dataclass(frozen=True)
class Scalar:
    value: int | float
    kind: str = "i32"  # "i32", "i64" or "f32"


@dataclass(frozen=True)
class Case:
    """`check` is "ACCEPT" or "REJECT" against `spec`, or, without a spec, "VERIFIED" or
    "REJECTED" from the graph checks alone; "ABORT" requires the run to stop with an execution
    error. `symbol` is a prefix of the kernel's mangled name, `globals` its struct's type as clang
    prints it, `args` the kernel's arguments after the struct, `shared` its dynamic LDS bytes,
    and `sample` bounds the elements checked when checking all would take too long."""

    name: str
    description: str
    kernel: str
    symbol: str
    globals: str
    grid: tuple
    block: int
    arrays: tuple
    fields: dict = field(default_factory=dict)
    spec: str | None = None
    dims: dict = field(default_factory=dict)
    check: str = "ACCEPT"
    sample: int = 0
    args: tuple = ()
    shared: int = 0


# One batch and head; 512 tokens, two workgroups of 256 query rows, eight KV tiles of 64.
ATTN_SIZES = (("ATTN_B", 1), ("ATTN_H", 1), ("ATTN_H_KV", 1), ("ATTN_N", 512))
# The dynamic LDS every HipKittens kernel with an `extern __shared__` buffer requests.
MAX_SHARED_MEMORY = 160000


def unswizzled(*descriptors: str) -> tuple:
    """Drop the row stride from `make_srsrc(ptr, range, stride)` calls, so the descriptor has
    no stride and no SWIZZLE_EN: the CDNA4 ISA (9.1.5) addresses a swizzled access through an
    element size its descriptor (table 48) has no field for, and range-checks only unswizzled
    raw buffers. The kernels compute linear byte offsets and pass HipKittens' tests on MI355X,
    so a linear raw buffer is what they rely on."""
    return tuple(Fix(f"{call})", f"{call.rsplit(', ', 1)[0]})") for call in descriptors)


def gemm_sizes(old: str, m: int, n: int, k: int) -> Fix:
    """Replace a GEMM's hard-coded `#define M ...` block `old` with these sizes."""
    lines = {name: f"#define {name} {value}" for name, value in (("M", m), ("N", n), ("K", k))}
    return Fix(old, "\n".join(lines[line.split()[1]] for line in old.splitlines()))


# The main loop's two lazy-rescale branches, one per half of its unrolled body, forced: KEEP keeps
# the running max, RESCALE rescales O to the new one.
KEEP, RESCALE = 1, 0
VOTE = "all_ok  = wave_all_ok(lane_ok);\n        if (__builtin_expect({}, 1))"


def branches(first: int, second: int) -> tuple:
    return (
        Fix("int " + VOTE.format("all_ok"), "int " + VOTE.format(first)),
        Fix("        " + VOTE.format("all_ok"), "        " + VOTE.format(second)),
    )


# bug.txt, 2's fix: the epilogue's first normaliser update guarded as the loop's are.
EPILOGUE_EXP = "    //      Finish softmax for QK2\n" \
    "    exp2(att_block[0].tiles[1][0], att_block[0].tiles[1][0]);\n"
GUARDED_EPILOGUE = Fix(
    EPILOGUE_EXP + "    mul(norm_vec, norm_vec, scale_vec);\n",
    EPILOGUE_EXP + "    if (pending_scale) {\n        mul(norm_vec, norm_vec, scale_vec);\n    }\n",
)

# bug.txt, 1's fix: the last three of the four P.V MMAs before the lazy-rescale branch, with the
# first, so the rescale scales all of P_{t-1} V_{t-1}, exponentiated against the old max.
PV_CHUNK = "        mma_AtB(o_reg, subtile_inplace<16>(v_reg, {0}), " \
    "subtile_inplace<16>(att_block_bf16_in, {0}), o_reg);\n"
LATER_CHUNKS = "".join(PV_CHUNK.format(chunk) for chunk in (1, 2, 3))
CHUNKS_BEFORE_RESCALE = (
    Fix(LATER_CHUNKS, "", 2),
    Fix(PV_CHUNK.format(0), PV_CHUNK.format(0) + LATER_CHUNKS, 2),
)

# The 16x32 kernel's waves 4-7 pass one barrier more at the start, so they trail waves 0-3 by a
# barrier: a tile loaded and waited for in phase k is read from phase k + 1 on. Its main loop reads
# Bs[1][0] in phase 4, the phase that waits for it (bug.txt, 7); the fix reads it in phase 5.
BS10_READ = """        st_subtile_b = subtile_inplace<HALF_REG_BLOCK_N, K_STEP>(Bs[1][0], {warp_col, 0});
        load(B_tile_0, st_subtile_b);
"""
PHASE5 = "        st_subtile_a = subtile_inplace<HALF_REG_BLOCK_M, K_STEP>(As[1][0], {warp_row, 0});\n"
BS10_IN_PHASE5 = (Fix(BS10_READ, ""), Fix(PHASE5, BS10_READ + PHASE5))

# A 256-row tile per workgroup over 512 rows and 256 columns: workgroup 0 computes rows 0-255,
# a prefix of C. K = 256 runs the 256x256 kernels' main loop once and its two-tile epilogue.
GEMM_M, GEMM_N, GEMM_K = 512, 256, 256
# The 192-row kernels' first tile, likewise, over two tiles of rows.
GEMM192_M = 384

KERNELS = (
    Kernel("softmax", "kernels/cdna4/softmax/kernel.cpp"),
    Kernel(
        "softmax_d32",
        "kernels/cdna4/softmax/kernel.cpp",
        (Fix("constexpr int D = 128;", "constexpr int D = 32;"),),
    ),
    Kernel("rotary", "kernels/cdna4/rotary/kernel.cpp"),
    # The forward attention kernels skip a wave's rescale when its running max grew by at most
    # RESCALE_THRESHOLD: a branch on the data, which Volta does not follow, so each path is a
    # kernel of its own. Keeping the first max is exact over the reals; rescaling scales only the
    # first of four P.V chunks (bug.txt, 1). Rescaling in the first half and keeping the max in
    # the second leaves a stale scale_vec for the epilogue (bug.txt, 2).
    *(
        Kernel(
            f"attn_gqa{suffix}_{path}",
            f"kernels/cdna4/attn/gqa/kernel{suffix}.cpp",
            (
                *unswizzled(
                    "make_srsrc(k_base, k_row_stride * ATTN_N, k_row_stride",
                    "make_srsrc(v_base, v_row_stride * ATTN_N, v_row_stride",
                ),
                *fixes,
            ),
            ATTN_SIZES,
        )
        for suffix in ("", "_d64")
        for path, fixes in (
            ("skip", branches(KEEP, KEEP)),
            ("rescale", branches(RESCALE, RESCALE)),
            ("rescale_fixed", branches(RESCALE, RESCALE) + CHUNKS_BEFORE_RESCALE),
            ("mixed", branches(RESCALE, KEEP) + CHUNKS_BEFORE_RESCALE),
            ("mixed_fixed", branches(RESCALE, KEEP) + CHUNKS_BEFORE_RESCALE + (GUARDED_EPILOGUE,)),
        )
    ),
    # The bf16 GEMMs C = A B^T. The 16x32 kernel takes M, N and K as arguments; the others
    # hard-code them.
    *(
        Kernel(
            f"gemm_256_16x32{suffix}",
            "kernels/cdna4/gemm/bf16fp32/256_256_64_32_with16x32.cpp",
            unswizzled(
                "make_srsrc(a_base, M * a_row_stride, a_row_stride",
                "make_srsrc(b_base, N * b_row_stride, b_row_stride",
            ) + fixes,
        )
        for suffix, fixes in (("", ()), ("_fixed", BS10_IN_PHASE5))
    ),
    Kernel(
        "gemm_256_32x16",
        "kernels/cdna4/gemm/bf16fp32/256_256_64_32_with32x16.cpp",
        (gemm_sizes("#define M 8192\n#define K 8192\n#define N 8192", GEMM_M, GEMM_N, GEMM_K),),
    ),
    *(
        Kernel(
            f"gemm_192{suffix}",
            f"kernels/cdna4/gemm/bf16fp32/micros/192x256/kernel{suffix}.cpp",
            (gemm_sizes("#define M 7680\n#define K 8192\n#define N 8192", GEMM192_M, GEMM_N,
                        GEMM_K),),
        )
        for suffix in ("", "v2")
    ),
)


def softmax_case(name: str, kernel: str, columns: int, rows: int, block: int) -> Case:
    """One workgroup of `block` threads, a warp per 32 rows of `columns` bf16 columns."""
    return Case(
        name,
        f"softmax over {rows} rows of {columns} bf16 columns, one workgroup of {block // 64} "
        "warps; compiled exp keeps clang's denormal guard, so the canonical solver is UNKNOWN",
        kernel,
        f"_Z10softmax_tkILi{columns}EE",
        f"softmax_globals<{columns}>",
        (1, 1, 1),
        block,
        (Array("x", "in", "bf16", (rows, columns)), Array("o", "out", "bf16", (rows, columns))),
        {"x": Gl("x", (1, 1, rows, columns)), "o": Gl("o", (1, 1, rows, columns))},
        "softmax.spec",
        {"R": rows, "C": columns},
        "UNKNOWN",
    )


def attention_case(name: str, d: int, path: str) -> Case:
    """Non-causal attention over one batch and head of 512 tokens: workgroup 0's 256 query
    rows against every key, checked on the first query row."""
    n = dict(ATTN_SIZES)["ATTN_N"]
    rescale = {
        "skip": "never rescales (keeps its first max)",
        "rescale": "always rescales",
        "rescale_fixed": "always rescales, all four P.V MMAs before the rescale (bug.txt, 1's fix)",
        "mixed": "rescales in the first half of the loop and keeps the max in the second, with "
                 "bug.txt 1's fix",
        "mixed_fixed": "rescales in the first half of the loop and keeps the max in the second, "
                       "with bug.txt 1's and 2's fixes",
    }[path]
    bnhd = (1, n, 1, d)
    return Case(
        name,
        f"non-causal attention, head dim {d}, {n} tokens, whose online softmax {rescale}; "
        "workgroup 0's 256 query rows",
        name,
        f"_Z10attend_kerILi{d}EE",
        f"attn_globals<{d}>",
        (1, n // 256, 1),
        512,
        (
            Array("Q", "in", "bf16", bnhd),
            Array("K", "in", "bf16", bnhd),
            Array("V", "in", "bf16", bnhd),
            Array("O", "out", "bf16", bnhd),
            Array("L", "out", "f32", (1, 1, 1, n)),
        ),
        {
            "Qg": Gl("Q", bnhd),
            "Kg": Gl("K", bnhd),
            "Vg": Gl("V", bnhd),
            "Og": Gl("O", bnhd),
            "L_vec": Gl("L", (1, 1, 1, n)),
        },
        f"attention_d{d}.spec",
        {"S": n, "D": d, "R": 256},
        "REJECT" if path in ("rescale", "mixed") else "ACCEPT",
        sample=d,
        shared=MAX_SHARED_MEMORY,
    )


def gemm_case(name: str, kernel: str, block_m: int, m: int, args: bool = False,
              check: str = "ACCEPT") -> Case:
    """C = A B^T over bf16 A [m, K] and B [N, K]: workgroup 0's first `block_m` rows of C."""
    n, k = GEMM_N, GEMM_K
    sizes = {"M": Scalar(m), "N": Scalar(n), "K": Scalar(k)}
    return Case(
        name,
        f"bf16 GEMM C = A B^T, M={m}, N={n}, K={k}, {block_m}x256 tiles; workgroup 0's tile, "
        f"C's first {block_m} rows",
        kernel,
        "_Z8micro_tk",
        "micro_globals",
        ((n // 256) * (m // block_m), 1, 1),
        512,
        (
            Array("a", "in", "bf16", (1, 1, m, k)),
            Array("b", "in", "bf16", (1, 1, n, k)),
            Array("c", "out", "bf16", (1, 1, m, n)),
        ),
        {
            "a": Gl("a", (1, 1, m, k)),
            "b": Gl("b", (1, 1, n, k)),
            "c": Gl("c", (1, 1, m, n)),
            **(sizes if args else {}),
        },
        "gemm_abt.spec",
        {"M": m, "N": n, "K": k, "R": block_m},
        check,
        args=tuple(sizes.values()) if args else (),
        shared=MAX_SHARED_MEMORY,
    )


CASES = (
    softmax_case("softmax", "softmax", 128, 128, 256),
    softmax_case("softmax_d32", "softmax_d32", 32, 32, 64),
    Case(
        "rotary",
        "rotary embedding of 32 rows of a 128-wide head, one warp: the halves rotated by "
        "angle i, o = x cos + rotate_half(x) sin",
        "rotary",
        "_Z15tk_fused_rotaryILi128EE",
        "rotary_globals<128>",
        (1, 1, 1),
        64,
        (
            Array("x", "in", "bf16", (1, 1, 32, 128)),
            Array("o", "out", "bf16", (1, 1, 32, 128)),
            Array("sin", "in", "bf16", (1, 1, 32, 64)),
            Array("cos", "in", "bf16", (1, 1, 32, 64)),
        ),
        {
            "x": Gl("x", (1, 1, 32, 128)),
            "o": Gl("o", (1, 1, 32, 128)),
            "sin": Gl("sin", (1, 1, 32, 64)),
            "cos": Gl("cos", (1, 1, 32, 64)),
        },
        "rotary.spec",
        {"N": 32, "TWO": 2, "HALF": 64},
    ),
    *(
        attention_case(f"attn_gqa{suffix}_{path}", d, path)
        for suffix, d in (("", 128), ("_d64", 64))
        for path in ("skip", "rescale", "rescale_fixed", "mixed", "mixed_fixed")
    ),
    # bug.txt, 7: the main loop reads Bs[1][0] before waiting for its load.
    gemm_case("gemm_256_16x32", "gemm_256_16x32", 256, GEMM_M, args=True, check="REJECT"),
    gemm_case("gemm_256_16x32_fixed", "gemm_256_16x32_fixed", 256, GEMM_M, args=True),
    gemm_case("gemm_256_32x16", "gemm_256_32x16", 256, GEMM_M),
    gemm_case("gemm_192", "gemm_192", 192, GEMM192_M),
    # bug.txt, 8: kernel.cpp's vmcnt(0) waits tightened to counts that waves 4-7, issuing one
    # load fewer per A tile, do not reach; kernel.cpp is the fixed kernel.
    gemm_case("gemm_192v2", "gemm_192v2", 192, GEMM192_M, check="REJECT"),
)
