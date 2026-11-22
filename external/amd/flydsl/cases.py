"""FlyDSL kernels checked by Volta: what each case compiles, launches and checks.

`extract.py` compiles every case's `build` in the FlyDSL container and writes its assembly
and launch file; `external/amd/verify.py` runs them. Importable without FlyDSL or torch.

A case's `build` is Python run inside the container, in a process of its own, with `torch` and
`fx` (`flydsl.expr`) in scope and the case's `fixes` applied to its copy of FlyDSL's `kernels`;
it must compile exactly one launch of the kernel. `args` lists the kernel's
explicit arguments in order: a `Tensor` is a pointer and its dynamic layout, a `Pointer` an
address alone, a `Scalar` a 32-bit value. The kernel-argument bytes are laid out from the
compiled kernel's own metadata, hidden arguments included.
"""

from dataclasses import dataclass, field, replace


@dataclass(frozen=True)
class Array:
    name: str
    kind: str  # "in" or "out"
    dtype: str  # "f32", "bf16" or "i32"
    shape: tuple
    contents: tuple | None = None  # concrete i32 words of an `in` array


@dataclass(frozen=True)
class Tensor:
    """An `fx.Tensor` argument: the address of `array` plus `offset` elements, and the layout
    of a `shape` view with element `strides` (row-major when omitted)."""

    array: str
    shape: tuple
    strides: tuple | None = None
    offset: int = 0

    def layout_strides(self) -> tuple:
        if self.strides is not None:
            return self.strides
        strides, step = [], 1
        for extent in reversed(self.shape):
            strides.append(step)
            step *= extent
        return tuple(reversed(strides))

@dataclass(frozen=True)
class Pointer:
    """An `fx.Pointer` argument: an address alone."""

    array: str
    offset: int = 0


@dataclass(frozen=True)
class Scalar:
    value: int | float
    name: str = ""
    kind: str = "i32"  # "i32" or "f32"


@dataclass(frozen=True)
class Fix:
    """Replace `old`, which must occur once, with `new` in FlyDSL's `path`."""

    path: str
    old: str
    new: str


@dataclass(frozen=True)
class Case:
    """`check` is "ACCEPT" or "REJECT" against `spec`, or, without a spec, "VERIFIED" or
    "REJECTED" from the graph checks alone; "ABORT" requires the run to stop with an execution
    error, such as an access outside every array. `assembly` reuses another case's kernel (its
    `build` is then empty); `symbol` picks the kernel when the assembly defines several, and
    `sample` bounds the elements checked when proving all of them would take too long."""

    name: str
    description: str
    source: str
    args: tuple
    arrays: tuple
    grid: tuple
    block: int
    check: str
    build: str = ""
    spec: str | None = None
    dims: dict = field(default_factory=dict)
    fixes: tuple = ()
    assembly: str | None = None
    symbol: str | None = None
    sample: int = 0  # check only each output array's first `sample` elements (0: all)

    def assembly_name(self) -> str:
        return self.assembly or self.name


# ===== Flash attention (kernels/attention/flash_attn_gfx950.py) =====

FA_SOURCE = "kernels/attention/flash_attn_gfx950.py"
FA_TENSORS = ("Q", "K", "V", "O", "LSE", "DebugCounts", "CuSeqQ", "CuSeqKv", "BlockTable",
              "Bias", "AlibiSlopes", "Sink")

def flash_attention(name, causal, seq, arrays_qk=("Q", "K"), assembly=None, check="ACCEPT"):
    shape = (1, seq, 1, 64)
    q, k = arrays_qk
    tensors = []
    for tensor in FA_TENSORS:
        array = {"Q": q, "K": k, "V": "V"}.get(tensor, "O")
        tensors.append(Tensor(array, shape))
    scalars = (Scalar(seq, "seq_len"), Scalar(seq, "seq_len_kv"), Scalar(64, "stride_q_n"),
               Scalar(64, "stride_kv_n"), Scalar(64, "head_dim_runtime"),
               Scalar(0, "block_table_stride"), Scalar(0, "bias_stride0"),
               Scalar(0, "alibi_stride_b"))
    kind = "causal" if causal else "non-causal"
    swapped = " with Q and K swapped" if arrays_qk != ("Q", "K") else ""
    return Case(
        name=name,
        description=f"dual-wave flash attention, {kind}, bf16, S={seq}, D=64, eager "
                    f"rescaling{swapped}; workgroup 0's 256 query rows",
        source=FA_SOURCE,
        build="" if assembly else f"""
from kernels.attention.flash_attn_gfx950 import build_flash_attn_dualwave_swp_module
launch = build_flash_attn_dualwave_swp_module(num_heads=1, head_dim=64, causal={causal},
    dtype_str="bf16", dualwave_swp_lazy_rescale=False)
q = torch.empty(1, {seq}, 1, 64, dtype=torch.bfloat16)
launch.compile(q, torch.empty_like(q), torch.empty_like(q), torch.empty_like(q), 1, {seq})
""",
        args=(*tensors, *scalars),
        arrays=tuple(Array(n, "in", "bf16", shape) for n in "QKV") + (Array("O", "out", "bf16", shape),),
        grid=(1, -(-seq // 256), 1),
        block=512,
        check=check,
        spec="flash_attention_causal.spec" if causal else "flash_attention.spec",
        dims={"S": seq, "D": 64, "R": min(256, seq)},
        assembly=assembly,
    )

# ===== GEMM (kernels/gemm/gemm_a16w16_gfx950.py) =====

GEMM_SOURCE = "kernels/gemm/gemm_a16w16_gfx950.py"
GEMM_FIX_SWIZZLE = Fix(
    "kernels/gemm/gemm_a16w16_gfx950_utils.py",
    "    swizzle = fx.static(fx.SwizzleType.get(3, 3, 3))\n",
    "    swizzle = fx.static(fx.SwizzleType.get(min(3, block_k.bit_length() - 4), 3, 3))\n",
)
GEMM_FIX_HTI = (
    Fix(GEMM_SOURCE,
        "    a1 = load_a_fragment(1, 1)\n    rocdl.s_barrier()\n",
        "    a1 = load_a_fragment(1, 1)\n    rocdl.s_waitcnt(lgkmcnt=0)\n    rocdl.s_barrier()\n"),
    Fix(GEMM_SOURCE,
        """    else:
        wait_vmcnt_and_barrier(0)
        store_half_tile_to_global(0, 0)
        store_half_tile_to_global(0, 1)
        wait_vmcnt_and_barrier(0)
        store_half_tile_to_lds(1, 0, c10)
        store_half_tile_to_lds(1, 1, c11)
        wait_vmcnt_and_barrier(0)
        store_half_tile_to_global(1, 0)
""",
        """    else:
        if wid // n_waves == 0:
            rocdl.s_barrier()
        rocdl.s_waitcnt(vmcnt=0)
        rocdl.s_waitcnt(lgkmcnt=0)
        rocdl.s_barrier()
        store_half_tile_to_global(0, 0)
        store_half_tile_to_global(0, 1)
        rocdl.s_waitcnt(vmcnt=0)
        rocdl.s_waitcnt(lgkmcnt=0)
        rocdl.s_barrier()
        store_half_tile_to_lds(1, 0, c10)
        store_half_tile_to_lds(1, 1, c11)
        rocdl.s_waitcnt(vmcnt=0)
        rocdl.s_waitcnt(lgkmcnt=0)
        rocdl.s_barrier()
        store_half_tile_to_global(1, 0)
"""),
)

def gemm(name, layout, out="f32", m=64, n=64, k=256, check="ACCEPT", fixes=(), bias=False,
         note="", **params):
    kwargs = dict(block_m=64, block_n=64, block_k=64, stages=2, m_waves=2, n_waves=2,
                  k_waves=1, group_m=0, use_half_tile_interleaved=False)
    kwargs.update(params)
    threads = 64 * kwargs["m_waves"] * kwargs["n_waves"] * kwargs["k_waves"]
    a_shape = (m, k) if layout[0] == "n" else (k, m)
    b_shape = (k, n) if layout[1] == "n" else (n, k)
    out_dtype = {"f32": "torch.float32", "bf16": "torch.bfloat16"}[out]
    tiles = (-(-m // kwargs["block_m"])) * (-(-n // kwargs["block_n"]))
    return Case(
        name=name,
        description=f"bf16 GEMM, layout {layout}, {out} output, M={m} N={n} K={k}, "
                    f"{kwargs['block_m']}x{kwargs['block_n']}x{kwargs['block_k']} tiles, "
                    f"{kwargs['m_waves']}x{kwargs['n_waves']} waves"
                    f"{', half-tile interleaved' if kwargs['use_half_tile_interleaved'] else ''}"
                    f"{', bias' if bias else ''}{note}",
        source=GEMM_SOURCE,
        build=f"""
from kernels.gemm.gemm_a16w16_gfx950 import gemm_a16w16
a = torch.empty({m}, {k}, dtype=torch.bfloat16) if "{layout[0]}" == "n" else torch.empty({k}, {m}, dtype=torch.bfloat16).t()
b = torch.empty({k}, {n}, dtype=torch.bfloat16) if "{layout[1]}" == "n" else torch.empty({n}, {k}, dtype=torch.bfloat16).t()
bias = torch.empty({n}, dtype=torch.bfloat16) if {bias} else None
gemm_a16w16(a, b, bias=bias, user_kwargs={kwargs!r}, stream=fx.Stream(None), layout="{layout}", out_dtype={out_dtype})
""",
        args=(Tensor("out", (m, n)), Tensor("a", a_shape), Tensor("b", b_shape),
              Tensor("bias" if bias else "a", (n,) if bias else a_shape),
              Tensor("semaphore", (64,)), Tensor("signal", (64,)),
              Scalar(m, "m"), Scalar(n, "n"), Scalar(k, "k"), Scalar(1, "split_k"),
              Scalar(k, "working_k"), Scalar(a_shape[1], "a_leading_stride"),
              Scalar(b_shape[1], "b_leading_stride")),
        arrays=(Array("out", "out", out, (m, n)), Array("a", "in", "bf16", a_shape),
                Array("b", "in", "bf16", b_shape))
               + ((Array("bias", "in", "bf16", (n,)),) if bias else ())
               + (Array("semaphore", "in", "i32", (64,), (0,) * 64),
                  Array("signal", "in", "i32", (64,), (0,) * 64)),
        grid=(tiles, 1, 1),
        block=threads,
        check=check,
        spec=f"gemm_{layout}{'_bias' if bias else ''}.spec",
        dims={"M": m, "N": n, "K": k},
        fixes=fixes,
    )


# ===== Row-wise normalizations (kernels/norm/), one row (M = 1) in f32 =====

def row_case(name, source, build, args, arrays, spec, n, description, block=256, symbol=None,
             check="ACCEPT", dims=None):
    return Case(name=name, description=description, source=source, build=build, args=args,
                arrays=arrays, grid=(1, 1, 1), block=block, check=check, spec=spec,
                dims=dims or {"R": 1, "N": n}, symbol=symbol)

def softmax(name, n):
    path = "fast path (128-bit vectors)" if n % 1024 == 0 else "generic path (masked scalar tail)"
    return row_case(
        name, "kernels/norm/softmax_kernel.py",
        f"""
from kernels.norm.softmax_kernel import build_softmax_module
x = torch.empty(1, {n}, dtype=torch.float32)
build_softmax_module(1, {n}, "f32")(x, torch.empty_like(x), 1)
""",
        (Tensor("x", (1, n)), Tensor("y", (1, n)), Tensor("y", (1, n)), Tensor("y", (1, n)),
         Scalar(1, "MIn")),
        (Array("x", "in", "f32", (1, n)), Array("y", "out", "f32", (1, n))),
        "softmax.spec", n, f"softmax of one {n}-column f32 row, {path}")

def softmax_bwd(name, n):
    return row_case(
        name, "kernels/norm/softmax_bwd_kernel.py",
        f"""
from kernels.norm.softmax_bwd_kernel import build_softmax_bwd_module
dy = torch.empty(1, {n}, dtype=torch.float32)
build_softmax_bwd_module({n}, "f32")(dy, torch.empty_like(dy), torch.empty_like(dy), 1)
""",
        (Tensor("dy", (1, n)), Tensor("y", (1, n)), Tensor("dx", (1, n))),
        (Array("dy", "in", "f32", (1, n)), Array("y", "in", "f32", (1, n)),
         Array("dx", "out", "f32", (1, n))),
        "softmax_bwd.spec", n, f"softmax backward of one {n}-column f32 row")

def rmsnorm(name, n):
    return row_case(
        name, "kernels/norm/rmsnorm_kernel.py",
        f"""
from kernels.norm.rmsnorm_kernel import build_rmsnorm_module
x = torch.empty(1, {n}, dtype=torch.float32)
build_rmsnorm_module({n}, "f32")(x, torch.empty({n}, dtype=torch.float32), torch.empty_like(x), 1)
""",
        (Tensor("x", (1, n)), Tensor("gamma", (n,)), Tensor("gamma", (n,)), Tensor("y", (1, n))),
        (Array("x", "in", "f32", (1, n)), Array("gamma", "in", "f32", (n,)),
         Array("y", "out", "f32", (1, n))),
        "rmsnorm.spec", n, f"RMSNorm of one {n}-column f32 row, eps 1e-5", symbol="rmsnorm_kernel")

def fused_add_rmsnorm(name, n):
    return row_case(
        name, "kernels/norm/rmsnorm_kernel.py",
        f"""
from kernels.norm.rmsnorm_kernel import build_fused_add_rmsnorm_module
x = torch.empty(1, {n}, dtype=torch.float32)
build_fused_add_rmsnorm_module({n}, "f32")(x, torch.empty_like(x), torch.empty({n}, dtype=torch.float32),
                                          torch.empty_like(x), torch.empty_like(x), 1)
""",
        (Tensor("x", (1, n)), Tensor("residual", (1, n)), Tensor("gamma", (n,)), Tensor("y", (1, n)),
         Tensor("residual_out", (1, n)), Tensor("gamma", (n,))),
        (Array("x", "in", "f32", (1, n)), Array("residual", "in", "f32", (1, n)),
         Array("gamma", "in", "f32", (n,)), Array("y", "out", "f32", (1, n)),
         Array("residual_out", "out", "f32", (1, n))),
        "fused_add_rmsnorm.spec", n, f"residual add then RMSNorm of one {n}-column f32 row")

def layernorm(name, n):
    return row_case(
        name, "kernels/norm/layernorm_kernel.py",
        f"""
import flydsl.compiler as flyc
from kernels.norm.layernorm_kernel import build_layernorm_module
x = torch.empty(1, {n}, dtype=torch.float32)
g = torch.empty({n}, dtype=torch.float32)
ptr = lambda t: flyc.from_c_void_p(fx.Float32, t.data_ptr())
build_layernorm_module({n}, "f32")(ptr(x), ptr(g), ptr(torch.empty_like(g)), ptr(torch.empty_like(x)), 1,
                                   fx.Stream(None))
""",
        (Pointer("x"), Pointer("gamma"), Pointer("beta"), Pointer("y"), Pointer("gamma"),
         Pointer("gamma")),
        (Array("x", "in", "f32", (1, n)), Array("gamma", "in", "f32", (n,)),
         Array("beta", "in", "f32", (n,)), Array("y", "out", "f32", (1, n))),
        "layernorm.spec", n, f"LayerNorm of one {n}-column f32 row, eps 1e-5")

# ===== Fused RoPE + KV cache (kernels/attention/fused_rope_cache_kernel.py) =====

ROPE_SOURCE = "kernels/attention/fused_rope_cache_kernel.py"
ROPE_FIX_PAIR = Fix(ROPE_SOURCE, "            pair_lane = tid ^ vecs_per_half\n",
                    "            pair_lane = (tid + vecs_per_half) % vecs_per_head\n")


def rope(name, d, check="ACCEPT", fixes=(), note=""):
    t, h, block, max_pos = 1, 1, 16, 4
    qkv, cache, table = (t, h, d), (1, block, h, d), (max_pos, d // 2)
    return Case(
        name=name,
        description=f"NeoX RoPE of Q and K at position 2, bf16, head_dim={d}, one token and head; "
                    f"slot -1 skips the KV-cache write{note}",
        source=ROPE_SOURCE,
        build=f"""
from kernels.attention.fused_rope_cache_kernel import build_fused_rope_cache_module
launch = build_fused_rope_cache_module(head_dim={d}, num_q_heads={h}, num_kv_heads={h},
                                       block_size={block}, dtype_str="bf16")
bf = lambda *s: torch.empty(*s, dtype=torch.bfloat16)
i32 = lambda *s: torch.empty(*s, dtype=torch.int32)
f32 = lambda *s: torch.empty(*s, dtype=torch.float32)
launch(bf(*{qkv}), bf(*{qkv}), bf(*{qkv}), i32({t}), bf(*{table}), bf(*{table}), i32({t}),
       bf(*{cache}), bf(*{cache}), bf(*{qkv}), bf(*{qkv}), {t}, f32(1), f32(1))
""",
        args=(Tensor("q", qkv), Tensor("k", qkv), Tensor("v", qkv), Tensor("positions", (t,)),
              Tensor("cos", table), Tensor("sin", table), Tensor("slots", (t,)),
              Tensor("key_cache", cache), Tensor("value_cache", cache), Tensor("q_out", qkv),
              Tensor("k_out", qkv), Tensor("kscale", (1,)), Tensor("vscale", (1,))),
        arrays=(Array("q", "in", "bf16", qkv), Array("k", "in", "bf16", qkv),
                Array("v", "in", "bf16", qkv), Array("positions", "in", "i32", (t,), (2,)),
                Array("cos", "in", "bf16", table), Array("sin", "in", "bf16", table),
                Array("slots", "in", "i32", (t,), (-1,)),
                Array("key_cache", "out", "bf16", cache), Array("value_cache", "out", "bf16", cache),
                Array("q_out", "out", "bf16", qkv), Array("k_out", "out", "bf16", qkv),
                Array("kscale", "in", "f32", (1,)), Array("vscale", "in", "f32", (1,))),
        grid=(h, t, 1),
        block=64,
        check=check,
        spec="rope.spec",
        dims={"T": t, "H": h, "S": 2, "F": d // 2, "P": max_pos},
        fixes=fixes,
    )


# ===== MoE sorting, multiphase P23 (kernels/moe/moe_sorting_kernel.py) =====

MOE_SOURCE = "kernels/moe/moe_sorting_kernel.py"
MOE_FIX_BARRIER = Fix(
    MOE_SOURCE,
    "            # Store local_idx to LDS cumsum[tid], barrier, read cumsum[my_expert]\n"
    "            _lds_store_raw(cumsum_mr, local_idx_p23, tid)\n",
    "            # Store local_idx to LDS cumsum[tid], barrier, read cumsum[my_expert]\n"
    "            gpu.barrier()\n"
    "            _lds_store_raw(cumsum_mr, local_idx_p23, tid)\n",
)


def moe_workspace(experts, topk, tokens, unit):
    """The workspace P0 leaves for token t routed to experts t % E, (t + 1) % E, ...: a byte
    `slot + 1` per (expert, token) in rows of `mesh_stride` bytes, then each expert's count."""
    mesh_stride = -(-tokens // unit) * unit
    mesh = bytearray(experts * mesh_stride)
    counts = [0] * experts
    for t in range(tokens):
        for slot in range(topk):
            e = (t + slot) % experts
            mesh[e * mesh_stride + t] = slot + 1
            counts[e] += 1
    words = [int.from_bytes(mesh[i:i + 4], "little") for i in range(0, len(mesh), 4)]
    return mesh_stride, len(words), tuple(words + counts + [0])


def moe_sorting(name, masked, check, fixes=(), note=""):
    experts, topk, tokens, unit, moe_buf = 8, 2, 64, 32, 1024
    mesh_stride, mesh_words, workspace = moe_workspace(experts, topk, tokens, unit)
    sorted_len = tokens * topk + experts * unit
    i32 = lambda name, n, contents=None: Array(name, "in" if contents else "out", "i32", (n,), contents)
    return Case(
        name=name,
        description=f"multiphase P23 kernel (prefix sum, scatter, sentinel fill), E={experts}, "
                    f"topk={topk}, M={tokens}, {'with' if masked else 'without'} an expert mask; "
                    f"workgroup 0 sorts expert 0{note}",
        source=MOE_SOURCE,
        build=f"""
from kernels.moe.moe_sorting_kernel import _compile_moe_sorting_multiphase
launch_p23 = _compile_moe_sorting_multiphase(num_experts={experts}, topk={topk}, unit_size={unit},
                                             has_mask={masked})[3]
i32 = lambda n: torch.empty(n, dtype=torch.int32)
launch_p23(i32({len(workspace)}), torch.empty({tokens}, {topk}, dtype=torch.float32), i32({sorted_len}),
           torch.empty({sorted_len}, dtype=torch.float32), i32({sorted_len // unit}), i32(2), i32({moe_buf}),
           i32({experts}), {tokens}, {mesh_stride}, {mesh_words}, {moe_buf}, {experts + 1})
""",
        args=(Tensor("workspace", (len(workspace),)), Tensor("weights", (tokens, topk)),
              Tensor("sorted_ids", (sorted_len,)), Tensor("sorted_weights", (sorted_len,)),
              Tensor("sorted_experts", (sorted_len // unit,)), Tensor("num_valid", (2,)),
              Tensor("moe_buf", (moe_buf,)), Tensor("mask", (experts,)),
              Scalar(tokens, "i32_tokens"), Scalar(mesh_stride, "i32_mesh_stride"),
              Scalar(mesh_words, "i32_mesh_size"), Scalar(moe_buf, "i32_moe_buf_elems")),
        arrays=(i32("workspace", len(workspace), workspace),
                Array("weights", "in", "f32", (tokens, topk)),
                i32("sorted_ids", sorted_len), Array("sorted_weights", "out", "f32", (sorted_len,)),
                i32("sorted_experts", sorted_len // unit), i32("num_valid", 2),
                i32("moe_buf", moe_buf), i32("mask", experts, (1,) * experts)),
        grid=(experts + 1, 1, 1),
        block=256,
        check=check,
        fixes=fixes,
    )


# ===== Generic flash attention (kernels/attention/flash_attn_generic.py) =====

GENERIC_SOURCE = "kernels/attention/flash_attn_generic.py"
GENERIC_FIX_PAD = Fix(
    GENERIC_SOURCE,
    """            S_int = _extract_seq_len(args, kwargs)
            if S_int is not None and S_int % 64 == 0:
""",
    """            S_int = _extract_seq_len(args, kwargs)
            S_kv = kwargs.get("seq_len_kv", S_int)
            if S_int is not None and S_int % 64 == 0 and isinstance(S_kv, int) and S_kv % 64 == 0:
""",
)


def generic_attention(name, causal, seq, seq_kv=None, check="ACCEPT", fixes=(), note=""):
    seq_kv = seq_kv or seq
    q_shape, kv_shape = (1, seq, 1, 64), (1, seq_kv, 1, 64)
    kind = "causal" if causal else "non-causal"
    lengths = f"S={seq}" if seq == seq_kv else f"S_q={seq}, S_kv={seq_kv}"
    return Case(
        name=name,
        description=f"generic flash attention, {kind}, bf16, {lengths}, D=64, the 64x128 N32 tile "
                    f"FlyDSL picks for small grids, through its padding-mask dispatch{note}",
        source=GENERIC_SOURCE,
        build=f"""
from kernels.attention.flash_attn_generic import build_flash_attn_func_module
launch = build_flash_attn_func_module(num_heads=1, head_dim=64, causal={causal}, dtype_str="bf16",
    block_m=64, flat_work_group_size=128, path_tag="N32", cross_seqlen={seq != seq_kv})
q = torch.empty(*{q_shape}, dtype=torch.bfloat16)
kv = torch.empty(*{kv_shape}, dtype=torch.bfloat16)
launch(q, kv, kv.clone(), torch.empty_like(q), 1, {seq}, seq_len_kv={seq_kv}, stream=fx.Stream(None))
""",
        args=(Tensor("Q", q_shape), Tensor("K", kv_shape), Tensor("V", kv_shape), Tensor("O", q_shape),
              Tensor("O", q_shape), Scalar(seq, "seq_len"), Scalar(seq_kv, "seq_len_kv"),
              Tensor("O", q_shape), Tensor("O", q_shape), Tensor("O", q_shape),
              Scalar(0, "block_table_stride")),
        arrays=(Array("Q", "in", "bf16", q_shape), Array("K", "in", "bf16", kv_shape),
                Array("V", "in", "bf16", kv_shape), Array("O", "out", "bf16", q_shape)),
        grid=(-(-seq // 64), 1, 1),
        block=128,
        check=check,
        spec="flash_attention_causal.spec" if causal else "cross_attention.spec",
        dims={"S": seq, "D": 64, "R": seq} if causal else {"S": seq, "SKV": seq_kv, "D": 64},
        fixes=fixes,
    )


RMSNORM_SOURCE = "kernels/norm/rmsnorm_kernel.py"
RMSNORM_FIX_TAIL = (
    Fix(RMSNORM_SOURCE,
        """            if const_expr(TAIL_ELEMS > 0):
                if tid < TAIL_ELEMS:
                    tail_idx = tid + VEC_ELEMS
                    x_tail_e = row_in[tail_idx]
                    x_tail = x_tail_e.to(fx.Float32)
                    thread_sumsq = thread_sumsq + x_tail * x_tail
""",
        """            if const_expr(TAIL_ELEMS > 0):
                for tail_base in range_constexpr(0, TAIL_ELEMS, BLOCK_THREADS):
                    if tid + tail_base < TAIL_ELEMS:
                        tail_idx = tid + tail_base + VEC_ELEMS
                        x_tail_e = row_in[tail_idx]
                        x_tail = x_tail_e.to(fx.Float32)
                        thread_sumsq = thread_sumsq + x_tail * x_tail
"""),
    Fix(RMSNORM_SOURCE,
        """            if const_expr(TAIL_ELEMS > 0):
                if tid < TAIL_ELEMS:
                    tail_idx = tid + VEC_ELEMS
                    x_tail_e = row_in[tail_idx]
                    g_tail_e = Gamma_buf[tail_idx]
                    x_tail = x_tail_e.to(fx.Float32)
                    g_tail = g_tail_e if weight_dtype_str == "f32" else g_tail_e.to(fx.Float32)
                    y_tail = (x_tail * rrms) * g_tail
                    y_tail_e = _to_elem_scalar(dtype_str, elem_dtype, y_tail)
                    row_out[tail_idx] = y_tail_e
""",
        """            if const_expr(TAIL_ELEMS > 0):
                for tail_base in range_constexpr(0, TAIL_ELEMS, BLOCK_THREADS):
                    if tid + tail_base < TAIL_ELEMS:
                        tail_idx = tid + tail_base + VEC_ELEMS
                        x_tail_e = row_in[tail_idx]
                        g_tail_e = Gamma_buf[tail_idx]
                        x_tail = x_tail_e.to(fx.Float32)
                        g_tail = g_tail_e if weight_dtype_str == "f32" else g_tail_e.to(fx.Float32)
                        y_tail = (x_tail * rrms) * g_tail
                        y_tail_e = _to_elem_scalar(dtype_str, elem_dtype, y_tail)
                        row_out[tail_idx] = y_tail_e
"""),
)


def rmsnorm_small_block(name, n, threads, check="ACCEPT", fixes=(), note=""):
    return Case(
        name=name,
        description=f"RMSNorm of one {n}-column bf16 row, eps 1e-5, BLOCK_THREADS={threads}{note}",
        source=RMSNORM_SOURCE,
        build=f"""
from kernels.norm.rmsnorm_kernel import build_rmsnorm_module
x = torch.empty(1, {n}, dtype=torch.bfloat16)
build_rmsnorm_module({n}, "bf16", BLOCK_THREADS={threads})(x, torch.empty({n}, dtype=torch.bfloat16),
                                                         torch.empty_like(x), 1)
""",
        args=(Tensor("x", (1, n)), Tensor("gamma", (n,)), Tensor("gamma", (n,)), Tensor("y", (1, n))),
        arrays=(Array("x", "in", "bf16", (1, n)), Array("gamma", "in", "bf16", (n,)),
                Array("y", "out", "bf16", (1, n))),
        grid=(1, 1, 1), block=threads, check=check, spec="rmsnorm.spec", dims={"R": 1, "N": n},
        fixes=fixes, symbol="rmsnorm_kernel",
    )


# ===== examples/01-vectorAdd.py =====

VECTOR_ADD_SOURCE = "examples/01-vectorAdd.py"


def vector_add(name, m, n, check="ACCEPT"):
    return Case(
        name=name,
        description=f"the vectorized, predicated C = A + B example, f32, M={m} N={n}, one 8x64 "
                    f"tile of 128 threads, each copying float4s",
        source=VECTOR_ADD_SOURCE,
        build=f"""
source = open("/flydsl/{VECTOR_ADD_SOURCE}").read().split("M, N = 100, 1000")[0]
exec(compile(source, "{VECTOR_ADD_SOURCE}", "exec"))
a = torch.empty({m}, {n}, dtype=torch.float32)
vector_add(a, torch.empty_like(a), torch.empty_like(a))
""",
        args=(Tensor("A", (m, n)), Tensor("B", (m, n)), Tensor("C", (m, n))),
        arrays=(Array("A", "in", "f32", (m, n)), Array("B", "in", "f32", (m, n)),
                Array("C", "out", "f32", (m, n))),
        grid=(-(-m // 8), -(-n // 64), 1),
        block=128,
        check=check,
        spec="vector_add.spec",
        dims={"M": m, "N": n},
    )

HTI = dict(block_m=256, block_n=256, block_k=64, stages=2, m_waves=2, n_waves=4,
           use_half_tile_interleaved=True)
CASES = (
    flash_attention("flash_attn_gfx950", causal=False, seq=384),
    # A REJECT needs only some refuted outputs; refuting all 16384 takes over ten minutes.
    replace(flash_attention("flash_attn_gfx950_swapped_qk", causal=False, seq=384,
                            arrays_qk=("K", "Q"), assembly="flash_attn_gfx950", check="REJECT"),
            sample=64),
    # Not the causal dual-wave kernel: it masks with the finite score -3e38, so over the reals each
    # masked key keeps weight exp(-3e38 - m) > 0 and the output is not exactly causal attention.
    gemm("gemm_nt", "nt"),
    gemm("gemm_nn", "nn"),
    gemm("gemm_tn", "tn"),
    gemm("gemm_tt", "tt"),
    gemm("gemm_nt_bf16", "nt", out="bf16"),
    gemm("gemm_nt_bias", "nt", bias=True),
    # Swizzle<3,3,3> over a 32-element row reaches the row's bit 0 (gemm_a16w16_gfx950_utils.py).
    gemm("gemm_nt_block_k32", "nt", block_k=32, check="REJECT"),
    gemm("gemm_tn_block_k32", "tn", block_k=32),
    gemm("gemm_nt_block_k32_fixed", "nt", block_k=32, fixes=(GEMM_FIX_SWIZZLE,),
         note=", the swizzle sized to block_k"),
    # The default configuration: the two wave groups' barriers do not order their LDS accesses.
    gemm("gemm_hti", "nt", out="bf16", m=256, n=256, k=128, check="REJECT", **HTI),
    gemm("gemm_hti_fixed", "nt", out="bf16", m=256, n=256, k=128, fixes=GEMM_FIX_HTI,
         note=", LDS waits at the epilogue barriers and the wave groups re-aligned", **HTI),
    softmax("softmax", 1024),
    softmax("softmax_tail", 300),
    softmax_bwd("softmax_bwd", 1024),
    softmax_bwd("softmax_bwd_tail", 300),
    rmsnorm("rmsnorm", 1024),
    rmsnorm("rmsnorm_tail", 300),
    fused_add_rmsnorm("fused_add_rmsnorm", 1024),
    layernorm("layernorm", 128),
    generic_attention("flash_attn_generic", False, 64),
    generic_attention("flash_attn_generic_causal", True, 64),
    # The padding-mask dispatch looks at seq_len only, so 65 keys run unmasked: the 63 padded
    # columns repeat key 64.
    replace(generic_attention("flash_attn_generic_cross", False, 64, 65, check="REJECT"),
            sample=64),
    generic_attention("flash_attn_generic_cross_fixed", False, 64, 65, fixes=(GENERIC_FIX_PAD,),
                      note=", the dispatch checking seq_len_kv too"),
    rmsnorm_small_block("rmsnorm_block4", 8, 4),
    # With 4 threads, `if tid < TAIL_ELEMS` stores 4 of the 6 tail elements.
    rmsnorm_small_block("rmsnorm_block4_tail", 14, 4, check="REJECT"),
    rmsnorm_small_block("rmsnorm_block4_tail_fixed", 14, 4, fixes=RMSNORM_FIX_TAIL,
                        note=", the tail strided over the block"),
    vector_add("vector_add", 8, 64),
    # The predicate checks each float4's first column only, so the last one of a 62-column row
    # moves two elements past the row, and past both arrays' ends on the last row.
    vector_add("vector_add_ragged", 8, 62, check="ABORT"),
    rope("rope_d128", 128),
    # pair_lane = tid ^ vecs_per_half is tid +- 24 only when 24 is a power of two.
    rope("rope_d96", 96, check="REJECT"),
    rope("rope_d96_fixed", 96, fixes=(ROPE_FIX_PAIR,), note=", the pair lane tid +- 24"),
    moe_sorting("moe_sorting_p23_masked", True, "VERIFIED"),
    # No barrier between the cumsum[bid], cumsum[bid + 1] reads and cumsum[tid] = local_idx.
    moe_sorting("moe_sorting_p23", False, "REJECTED"),
    moe_sorting("moe_sorting_p23_fixed", False, "VERIFIED", fixes=(MOE_FIX_BARRIER,),
                note=", a barrier before cumsum is overwritten"),
)
