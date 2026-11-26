"""FlashAttention-2 (csrc/flash_attn, the sm80 cp.async / mma.sync path) kernels checked by Volta.

`external/ptx/verify.py` runs them. Each case's kernel is one instantiation in the PTX of a
`csrc/flash_attn/src/` unit at the commit `external/ptx/sources/frameworks.txt` pins, compiled
for sm_100a by `external/ptx/extraction/survey.py`; `symbol` is substrings of its mangled name.
Every kernel takes `Flash_fwd_params` (472 bytes) or `Flash_bwd_params` (648 bytes) by value:
the launch passes it as a `struct` whose fields sit at the byte offsets of the C++ layout of
`flash.h` (Itanium ABI, natural alignment; the sizes match the PTX `.param .align 8 .b8
..._param_0[472]` / `[648]`). Every field is given, null pointers as 0, so no byte reads as
undefined. Grid, block and dynamic shared memory are those of `flash_fwd_launch_template.h` /
`flash_bwd_launch_template.h` for the kernel traits on sm_100 (`is_sm8x` false). Races only.
"""

import math
import struct
from dataclasses import dataclass, field


@dataclass(frozen=True)
class Array:
    name: str
    kind: str  # "in", "out" or "inout"
    dtype: str
    shape: tuple
    base: int | None = None


@dataclass(frozen=True)
class Ptr:
    array: str


@dataclass(frozen=True)
class Int:
    value: int
    name: str = ""


@dataclass(frozen=True)
class Float:
    value: float
    name: str = ""


@dataclass(frozen=True)
class Struct:
    """A by-value struct: `fields` are launch-file struct fields, `{"offset": N, "<type>": v}`."""

    fields: tuple
    name: str = ""


@dataclass(frozen=True)
class Case:
    """`check` is the verdict the case expects: "VERIFIED"/"REJECTED" from the graph checks."""

    name: str
    description: str
    source: str
    unit: str
    symbol: str | tuple
    args: tuple
    arrays: tuple
    grid: tuple
    block: int
    check: str
    smem: int = 0  # dynamic shared memory bytes
    spec: str | None = None
    dims: dict = field(default_factory=dict)
    cta: tuple = (0, 0, 0)


SRC = "csrc/flash_attn/src"

# Byte offsets of flash.h's Flash_fwd_params / Flash_bwd_params members, and their types.
FWD_FIELDS = {
    "q_ptr": (0, "ptr"), "k_ptr": (8, "ptr"), "v_ptr": (16, "ptr"),
    "q_batch_stride": (24, "i64"), "k_batch_stride": (32, "i64"), "v_batch_stride": (40, "i64"),
    "q_row_stride": (48, "i64"), "k_row_stride": (56, "i64"), "v_row_stride": (64, "i64"),
    "q_head_stride": (72, "i64"), "k_head_stride": (80, "i64"), "v_head_stride": (88, "i64"),
    "h": (96, "i32"), "h_k": (100, "i32"), "h_h_k_ratio": (104, "i32"),
    "o_ptr": (112, "ptr"), "oaccum_ptr": (120, "ptr"),
    "o_batch_stride": (128, "i64"), "o_row_stride": (136, "i64"), "o_head_stride": (144, "i64"),
    "p_ptr": (152, "ptr"), "softmax_lse_ptr": (160, "ptr"), "softmax_lseaccum_ptr": (168, "ptr"),
    "b": (176, "i32"), "seqlen_q": (180, "i32"), "seqlen_k": (184, "i32"), "seqlen_knew": (188, "i32"),
    "d": (192, "i32"), "seqlen_q_rounded": (196, "i32"), "seqlen_k_rounded": (200, "i32"),
    "d_rounded": (204, "i32"), "rotary_dim": (208, "i32"), "total_q": (212, "i32"),
    "scale_softmax": (216, "f32"), "scale_softmax_log2": (220, "f32"),
    "cu_seqlens_q": (224, "ptr"), "cu_seqlens_k": (232, "ptr"), "leftpad_k": (240, "ptr"),
    "seqused_k": (248, "ptr"), "blockmask": (256, "ptr"), "knew_ptr": (264, "ptr"), "vnew_ptr": (272, "ptr"),
    "knew_batch_stride": (280, "i64"), "vnew_batch_stride": (288, "i64"), "knew_row_stride": (296, "i64"),
    "vnew_row_stride": (304, "i64"), "knew_head_stride": (312, "i64"), "vnew_head_stride": (320, "i64"),
    "rotary_cos_ptr": (328, "ptr"), "rotary_sin_ptr": (336, "ptr"), "cache_batch_idx": (344, "ptr"),
    "block_table": (352, "ptr"), "block_table_batch_stride": (360, "i64"), "page_block_size": (368, "i32"),
    "p_dropout": (372, "f32"), "p_dropout_in_uint8_t": (376, "u8"), "rp_dropout": (380, "f32"),
    "scale_softmax_rp_dropout": (384, "f32"), "window_size_left": (388, "i32"),
    "window_size_right": (392, "i32"), "softcap": (396, "f32"),
    "philox_args0": (400, "u64"), "philox_args1": (408, "u64"), "philox_args2": (416, "u64"),
    "philox_args3": (424, "u64"), "rng_state": (432, "ptr"),
    "is_bf16": (440, "u8"), "is_causal": (441, "u8"), "is_seqlens_k_cumulative": (442, "u8"),
    "is_rotary_interleaved": (443, "u8"), "num_splits": (444, "i32"),
    "alibi_slopes_ptr": (448, "ptr"), "alibi_slopes_batch_stride": (456, "i64"),
    "unpadded_lse": (464, "u8"), "seqlenq_ngroups_swapped": (465, "u8"),
}
BWD_FIELDS = {
    **FWD_FIELDS,
    "do_ptr": (472, "ptr"), "dq_ptr": (480, "ptr"), "dk_ptr": (488, "ptr"), "dv_ptr": (496, "ptr"),
    "dq_accum_ptr": (504, "ptr"), "dk_accum_ptr": (512, "ptr"), "dv_accum_ptr": (520, "ptr"),
    "do_batch_stride": (528, "i64"), "do_row_stride": (536, "i64"), "do_head_stride": (544, "i64"),
    "dq_batch_stride": (552, "i64"), "dk_batch_stride": (560, "i64"), "dv_batch_stride": (568, "i64"),
    "dq_row_stride": (576, "i64"), "dk_row_stride": (584, "i64"), "dv_row_stride": (592, "i64"),
    "dq_head_stride": (600, "i64"), "dk_head_stride": (608, "i64"), "dv_head_stride": (616, "i64"),
    "dsoftmax_sum": (624, "ptr"), "deterministic": (632, "u8"), "dq_accum_split_stride": (640, "i64"),
}


def f32_bits(x: float) -> int:
    return struct.unpack("<I", struct.pack("<f", x))[0]


def params_struct(table: dict, values: dict) -> Struct:
    """Every field of `table`: a pointer field names an array (None: nullptr), others default 0."""
    fields = []
    for name, (offset, ty) in table.items():
        value = values.get(name)
        if ty == "ptr":
            fields.append({"name": name, "offset": offset, **({"ptr": value} if value else {"u64": 0})})
        elif ty == "f32":
            fields.append({"name": name, "offset": offset, "u32": f32_bits(value or 0.0)})
        else:
            fields.append({"name": name, "offset": offset, ty: int(value or 0)})
    return Struct(tuple(fields), "params")


def round_up(x, m):
    return (x + m - 1) // m * m


def fwd_values(b, h, sq, sk, d, causal=False, window=(-1, -1), num_splits=1, bf16=True):
    """`set_params_fprop` (flash_api.cpp) for contiguous (b, s, h, d) q/k/v/o, no dropout."""
    scale = 1.0 / math.sqrt(d)
    window_left, window_right = (-1, 0) if causal else window
    return {
        "q_ptr": "q", "k_ptr": "k", "v_ptr": "v", "o_ptr": "o", "softmax_lse_ptr": "lse",
        "oaccum_ptr": "oaccum" if num_splits > 1 else None,
        "softmax_lseaccum_ptr": "lseaccum" if num_splits > 1 else None,
        **{f"{t}_batch_stride": s * h * d for t, s in (("q", sq), ("k", sk), ("v", sk), ("o", sq))},
        **{f"{t}_row_stride": h * d for t in "qkvo"},
        **{f"{t}_head_stride": d for t in "qkvo"},
        "h": h, "h_k": h, "h_h_k_ratio": 1, "b": b, "seqlen_q": sq, "seqlen_k": sk, "d": d,
        "seqlen_q_rounded": round_up(sq, 128), "seqlen_k_rounded": round_up(sk, 128),
        "d_rounded": round_up(d, 32), "total_q": b * sq,
        "scale_softmax": scale, "scale_softmax_log2": scale * math.log2(math.e),
        "p_dropout": 1.0, "p_dropout_in_uint8_t": 255, "rp_dropout": 1.0,
        "scale_softmax_rp_dropout": scale,
        "window_size_left": window_left, "window_size_right": window_right,
        "is_bf16": int(bf16), "is_causal": int(causal), "is_seqlens_k_cumulative": 1,
        "num_splits": num_splits,
    }


def fwd_arrays(b, h, sq, sk, d, dtype, num_splits=1):
    arrays = [Array("q", "in", dtype, (b, sq, h, d)), Array("k", "in", dtype, (b, sk, h, d)),
              Array("v", "in", dtype, (b, sk, h, d)), Array("o", "out", dtype, (b, sq, h, d)),
              Array("lse", "out", "f32", (b, h, sq))]
    if num_splits > 1:
        arrays += [Array("oaccum", "out", "f32", (num_splits, b, h, sq, round_up(d, 32))),
                   Array("lseaccum", "out", "f32", (num_splits, b, h, sq))]
    return tuple(arrays)


def bools(*flags):
    return "".join(f"Lb{int(f)}E" for f in flags)


DTYPE_MANGLED = {"bf16": "N7cutlass10bfloat16_tE", "f16": "N7cutlass6half_tE"}


def fwd(name, d=128, block_m=128, block_n=64, sq=256, sk=256, b=1, h=1, causal=False,
        window=(-1, -1), cta=(0, 0, 0), dtype="bf16", check="VERIFIED", note=""):
    """`flash_fwd_kernel` (flash_fwd_launch_template.h:33, dispatch run_flash_fwd :55)."""
    local = window != (-1, -1) and not causal
    even_mn = sq % block_m == 0 and sk % block_n == 0 and not local
    unit = f"{SRC}/flash_fwd_hdim{d}_{dtype.replace('f16', 'fp16') if dtype == 'f16' else dtype}" \
           f"{'_causal' if causal else ''}_sm80.cu"
    flags = bools(False, causal, local, False, even_mn, True, False, False)
    smem = block_m * d * 2 + block_n * d * 2 * 2
    return Case(
        name=name,
        description=f"flash_fwd_kernel {dtype} d={d}, traits {block_m}x{block_n} 4 warps, "
                    f"b={b} h={h} sq={sq} sk={sk}{', causal' if causal else ''}"
                    f"{f', window {window}' if local else ''}, Is_even_MN={int(even_mn)}, "
                    f"cta {list(cta)}{note}",
        source=f"{SRC}/flash_fwd_kernel.h:57 (compute_attn_1rowblock), launch {SRC}/flash_fwd_launch_template.h:55",
        unit=unit,
        symbol=("16flash_fwd_kernel", f"Flash_fwd_kernel_traitsILi{d}ELi{block_m}ELi{block_n}ELi4ELb0ELb0E"
                f"{DTYPE_MANGLED[dtype]}", f"EE{flags}EEv"),
        args=(params_struct(FWD_FIELDS, fwd_values(b, h, sq, sk, d, causal, window, bf16=dtype == "bf16")),),
        arrays=fwd_arrays(b, h, sq, sk, d, dtype),
        grid=(math.ceil(sq / block_m), b, h),
        block=128,
        smem=smem,
        check=check,
        cta=cta,
    )


def splitkv(name, sq=128, sk=256, b=1, h=1, num_splits=2, cta=(0, 0, 0), check="VERIFIED", note=""):
    """`flash_fwd_splitkv_kernel` with Split (num_splits > 1: traits 128 x 64 x 128,
    run_mha_fwd_splitkv_dispatch, flash_fwd_launch_template.h:182)."""
    d, block_m, block_n = 128, 64, 128
    even_mn = sq % block_m == 0 and sk % block_n == 0
    flags = bools(False, False, False, even_mn, True, False, True, False)
    return Case(
        name=name,
        description=f"flash_fwd_splitkv_kernel bf16 d=128, traits 64x128, b={b} h={h} sq={sq} sk={sk}, "
                    f"num_splits={num_splits}, Is_even_MN={int(even_mn)}, cta {list(cta)}{note}",
        source=f"{SRC}/flash_fwd_kernel.h:508 (compute_attn_1rowblock_splitkv), launch "
               f"{SRC}/flash_fwd_launch_template.h:105",
        unit=f"{SRC}/flash_fwd_split_hdim128_bf16_sm80.cu",
        symbol=("24flash_fwd_splitkv_kernel", "Flash_fwd_kernel_traitsILi128ELi64ELi128ELi4E", f"EE{flags}EEv"),
        args=(params_struct(FWD_FIELDS, fwd_values(b, h, sq, sk, d, num_splits=num_splits)),),
        arrays=fwd_arrays(b, h, sq, sk, d, "bf16", num_splits),
        grid=(math.ceil(sq / block_m), num_splits, b * h),
        block=128,
        smem=block_m * d * 2 + block_n * d * 2 * 2,
        check=check,
        cta=cta,
    )


def combine(name, sq=128, b=1, h=1, num_splits=2, cta=(0, 0, 0), check="VERIFIED", note=""):
    """`flash_fwd_splitkv_combine_kernel` (kBlockM 4 for d=128, flash_fwd_launch_template.h:145)."""
    d, block_m = 128, 4
    log_max = max(1, math.ceil(math.log2(num_splits)))
    return Case(
        name=name,
        description=f"flash_fwd_splitkv_combine_kernel bf16 d=128, kBlockM=4, Log_max_splits={log_max}, "
                    f"b={b} h={h} sq={sq}, num_splits={num_splits}, cta {list(cta)}{note}",
        source=f"{SRC}/flash_fwd_kernel.h:1123 (combine_attn_seqk_parallel), launch "
               f"{SRC}/flash_fwd_launch_template.h:145",
        unit=f"{SRC}/flash_fwd_split_hdim128_bf16_sm80.cu",
        symbol=("32flash_fwd_splitkv_combine_kernel", f"Li4ELi{log_max}ELb1EEEv"),
        args=(params_struct(FWD_FIELDS, fwd_values(b, h, sq, sq, d, num_splits=num_splits)),),
        arrays=(Array("oaccum", "in", "f32", (num_splits, b, h, sq, d)),
                Array("lseaccum", "in", "f32", (num_splits, b, h, sq)),
                Array("o", "out", "bf16", (b, sq, h, d)), Array("lse", "out", "f32", (b, h, sq)),
                Array("q", "in", "bf16", (1,)), Array("k", "in", "bf16", (1,)), Array("v", "in", "bf16", (1,))),
        grid=(math.ceil(b * h * sq / block_m), 1, 1),
        block=128,
        check=check,
        cta=cta,
    )


BWD_TRAITS = "Flash_bwd_kernel_traitsILi128ELi64ELi128ELi8ELi2ELi4ELi2ELb0ELb0E"  # max_smem >= 144 KiB


def bwd_values(b, h, sq, sk, d):
    v = fwd_values(b, h, sq, sk, d)
    v.update({
        "do_ptr": "do", "dq_ptr": "dq", "dq_accum_ptr": "dq_accum", "dsoftmax_sum": "dsoftmax_sum",
        "do_batch_stride": sq * h * d, "do_row_stride": h * d, "do_head_stride": d,
        "dq_batch_stride": sq * h * d, "dq_row_stride": h * d, "dq_head_stride": d,
        "dk_batch_stride": sk * h * d, "dk_row_stride": h * d, "dk_head_stride": d,
        "dv_batch_stride": sk * h * d, "dv_row_stride": h * d, "dv_head_stride": d,
        "dq_accum_split_stride": 0,
    })
    return v


def bwd_arrays(b, h, sq, sk, d):
    sqr = round_up(sq, 128)
    return (Array("do", "in", "bf16", (b, sq, h, d)), Array("o", "in", "bf16", (b, sq, h, d)),
            Array("dq_accum", "inout", "f32", (b, sqr, h, d)), Array("dsoftmax_sum", "out", "f32", (b, h, sqr)),
            Array("dq", "out", "bf16", (b, sq, h, d)), Array("lse", "in", "f32", (b, h, sq)),
            Array("q", "in", "bf16", (1,)), Array("k", "in", "bf16", (1,)), Array("v", "in", "bf16", (1,)))


def dot_do_o(name, sq=256, b=1, h=1, clear_dq=True, cta=(0, 0, 0), check="VERIFIED", note=""):
    """`flash_bwd_dot_do_o_kernel` (flash_bwd_launch_template.h:53, launched :85)."""
    d = 128
    return Case(
        name=name,
        description=f"flash_bwd_dot_do_o_kernel bf16 d=128, Clear_dQaccum={int(clear_dq)}, b={b} h={h} "
                    f"sq={sq}, cta {list(cta)}{note}",
        source=f"{SRC}/flash_bwd_preprocess_kernel.h:60 (compute_dot_do_o), launch "
               f"{SRC}/flash_bwd_launch_template.h:85",
        unit=f"{SRC}/flash_bwd_hdim128_bf16_sm80.cu",
        symbol=(f"25flash_bwd_dot_do_o_kernelILb{int(clear_dq)}E", BWD_TRAITS),
        args=(params_struct(BWD_FIELDS, bwd_values(b, h, sq, sq, d)),),
        arrays=bwd_arrays(b, h, sq, sq, d),
        grid=(math.ceil(sq / 64), b, h),
        block=256,
        check=check,
        cta=cta,
    )


def convert_dq(name, sq=256, b=1, h=1, cta=(0, 0, 0), check="VERIFIED", note=""):
    """`flash_bwd_convert_dq_kernel(params, nsplits = 1)` (flash_bwd_launch_template.h:63, :124)."""
    d = 128
    return Case(
        name=name,
        description=f"flash_bwd_convert_dq_kernel bf16 d=128, nsplits=1, b={b} h={h} sq={sq}, "
                    f"cta {list(cta)}{note}",
        source=f"{SRC}/flash_bwd_preprocess_kernel.h:190 (convert_dQ), launch "
               f"{SRC}/flash_bwd_launch_template.h:124",
        unit=f"{SRC}/flash_bwd_hdim128_bf16_sm80.cu",
        symbol=("27flash_bwd_convert_dq_kernel", BWD_TRAITS),
        args=(params_struct(BWD_FIELDS, bwd_values(b, h, sq, sq, d)), Int(1, "nsplits")),
        arrays=bwd_arrays(b, h, sq, sq, d),
        grid=(math.ceil(sq / 64), b, h),
        block=256,
        smem=64 * d * 2,  # kSmemdQSize
        check=check,
        cta=cta,
    )


# Tail blocks leave sQ rows past seqlen_q and sK rows past seqlen_k unloaded ("We don't need to
# clear the sQ/sK smem tiles", flash_fwd_kernel.h:257, :276) and mask their scores: their mma.sync
# fragments are Undefined, which no stored output reaches. Volta gap BF16_SHIFT:
# `flash::convert_type` of bf16 to f32 by `shl.b32 16` / `and.b32 0xffff0000` of a packed pair.
BF16_SHIFT = " (ABORT: Volta gap, bf16 -> f32 by shl/and of a packed pair)"

CASES = [
    # Non-causal forward, d=128 bf16, traits 128 x 64 (sm_100 path, run_mha_fwd_hdim128 :264).
    fwd("fwd_d128_s256", sq=256, sk=256),
    fwd("fwd_d128_s256_cta1_h2", sq=256, sk=256, h=2, cta=(1, 0, 1)),
    fwd("fwd_d128_q200_k256_cta0", sq=200, sk=256, cta=(0, 0, 0), note=" (!Is_even_MN, all rows valid)"),
    fwd("fwd_d128_q200_k256_tail", sq=200, sk=256, cta=(1, 0, 0), check="VERIFIED"),
    fwd("fwd_d128_q256_k200", sq=256, sk=200, cta=(0, 0, 0), check="VERIFIED"),
    fwd("fwd_d128_s200_tail", sq=200, sk=200, cta=(1, 0, 0), check="VERIFIED"),
    fwd("fwd_d128_s200_cta0", sq=200, sk=200, cta=(0, 0, 0), check="VERIFIED"),
    fwd("fwd_d128_local", sq=256, sk=256, window=(64, 0), cta=(1, 0, 0), note=" (sliding window)"),
    fwd("fwd_d128_local_q200", sq=200, sk=256, window=(32, 32), cta=(1, 0, 0), check="VERIFIED",
        note=""),
    fwd("fwd_d128_local_q200_cta0", sq=200, sk=256, window=(32, 32), cta=(0, 0, 0), note=" (sliding window)"),
    # Causal forward.
    fwd("fwd_causal_d128_s256_cta1", sq=256, sk=256, causal=True, cta=(1, 0, 0)),
    fwd("fwd_causal_d128_s256_cta0", sq=256, sk=256, causal=True, cta=(0, 0, 0)),
    fwd("fwd_causal_d128_q200_k256_cta0", sq=200, sk=256, causal=True, cta=(0, 0, 0)),
    fwd("fwd_causal_d128_q200_k256_tail", sq=200, sk=256, causal=True, cta=(1, 0, 0), check="VERIFIED",
        note=""),
    fwd("fwd_causal_d128_q100_k256", sq=100, sk=256, causal=True, cta=(0, 0, 0), check="VERIFIED",
        note=""),
    fwd("fwd_causal_d128_s200_tail", sq=200, sk=200, causal=True, cta=(1, 0, 0), check="VERIFIED"),
    # d=64 fp16, traits 128 x 128 (run_mha_fwd_hdim64 :212).
    fwd("fwd_d64_f16_s256", d=64, block_m=128, block_n=128, sq=256, sk=256, dtype="f16", cta=(1, 0, 0)),
    fwd("fwd_d64_f16_q200_k256_cta0", d=64, block_m=128, block_n=128, sq=200, sk=256, dtype="f16"),
    fwd("fwd_d64_f16_s200_tail", d=64, block_m=128, block_n=128, sq=200, sk=200, dtype="f16", cta=(1, 0, 0),
        check="VERIFIED"),
    # Split-KV forward and its combine.
    splitkv("splitkv_s128_k256_split0", cta=(0, 0, 0)),
    splitkv("splitkv_s128_k256_split1", cta=(1, 1, 0)),
    splitkv("splitkv_q100_k256_cta0", sq=100, sk=256, cta=(0, 1, 0), note=" (!Is_even_MN, all rows valid)"),
    splitkv("splitkv_q100_k256_tail", sq=100, sk=256, cta=(1, 1, 0), check="VERIFIED"),
    splitkv("splitkv_s128_k512_splits3", sq=128, sk=512, num_splits=3, cta=(1, 1, 0)),
    splitkv("splitkv_s128_k512_splits3_empty", sq=128, sk=512, num_splits=3, cta=(1, 2, 0),
            note=" (split past the last block: the early-exit store)"),
    splitkv("splitkv_s100_k200_tail", sq=100, sk=200, cta=(1, 1, 0), check="VERIFIED"),
    combine("combine_splits2", num_splits=2, cta=(3, 0, 0)),
    combine("combine_splits3", num_splits=3, cta=(0, 0, 0)),
    combine("combine_splits2_bhs8", sq=8, num_splits=2, cta=(1, 0, 0), note=" (b*h*seqlen_q a multiple of 4)"),
    # REAL BUG: b*h*seqlen_q = 7 is no multiple of kBlockM = 4, and the padded-LSE store
    # (flash_fwd_kernel.h:1218, `gLSE(tidx / kRowsPerLoadTranspose) = lse_logsum`) has no bound:
    # thread 6 of block 1 writes softmax_lse[7], one past its b*h*seqlen_q floats.
    combine("combine_splits2_tail", sq=7, num_splits=2, cta=(1, 0, 0), check="ABORT",
            note=" (REAL BUG: out-of-bounds softmax_lse store)"),
    combine("combine_splits2_h14_decode", sq=1, h=14, num_splits=2, cta=(3, 0, 0), check="ABORT",
            note=" (REAL BUG: decode, 14 heads, out-of-bounds softmax_lse store)"),
    # Backward preprocessing (the main dq_dk_dv kernel does not lower: atom.add.f32).
    dot_do_o("bwd_dot_do_o_clear", cta=(1, 0, 0), check="ABORT", note=BF16_SHIFT),
    dot_do_o("bwd_dot_do_o_noclear", clear_dq=False, check="ABORT", note=BF16_SHIFT),
    dot_do_o("bwd_dot_do_o_tail", sq=200, cta=(3, 0, 0), check="ABORT", note=BF16_SHIFT),
    convert_dq("bwd_convert_dq", cta=(1, 0, 0)),
    convert_dq("bwd_convert_dq_tail", sq=200, cta=(3, 0, 0)),
]
