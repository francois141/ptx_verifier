# /// script
# requires-python = ">=3.10"
# ///
"""Compile DeepGEMM's Blackwell (sm100) kernels to PTX the way its JIT would, without a GPU.

    uv run external/ptx/extraction/deepgemm.py                     # every job of `JOBS`
    uv run external/ptx/extraction/deepgemm.py sm100_bf16_gemm     # the jobs whose name starts so
    uv run external/ptx/extraction/deepgemm.py --list

DeepGEMM ships its kernels as header templates (`deep_gemm/include/deep_gemm/impls/*.cuh`).
At run time its host side (`csrc/jit_kernels/impls/*.hpp`) picks a config with the SM100
heuristics (`csrc/jit_kernels/heuristics/sm100.hpp`), formats a tiny `kernel.cu` that takes
the address of one template instantiation, and hands it to nvcc through DeepJIT
(`third-party/deep_jit/include/deep_jit/backend/cuda/{options,backend}.hpp`). This script
replays that for fixed problem shapes: `sm100_heuristics` below is a port of the heuristics
for normal (non-grouped) GEMMs, the generated sources follow the `std::format` templates of
the host side verbatim, and nvcc runs with DeepJIT's default flags plus DeepGEMM's
(`csrc/runtime/jit.hpp`), `--cubin` swapped for `--ptx` as `DG_JIT_DUMP_PTX` does.

The checkout is `target/ptx-sources/DeepGEMM` (`just ptx-sources`, with its submodules).
nvcc compiles for an explicit target, so no GPU is needed; without nvcc on the PATH (macOS)
the script runs itself in a CUDA container (`--backend`). Each job writes
`external/ptx/survey/DeepGEMM/<kernel>.<config>.ptx` and a `.json` beside it with the
template arguments, the launch DeepGEMM would make (grid, block, cluster, dynamic shared
memory), the kernel parameters (PTX layout and their meaning, TMA descriptors included) and
the tensor maps the host would encode.
"""

import argparse
import concurrent.futures
import json
import math
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Callable

EXTERNAL_ROOT = Path(__file__).resolve().parent.parent
REPO_ROOT = EXTERNAL_ROOT.parent.parent
DEFAULT_SOURCE = REPO_ROOT / "target" / "ptx-sources" / "DeepGEMM"
DEFAULT_OUT = EXTERNAL_ROOT / "survey" / "DeepGEMM"

# DeepJIT asserts nvcc >= 12.9 (arch-family targets); 12.9 compiles every job here.
CUDA_IMAGE = "nvidia/cuda:12.9.1-devel-ubuntu24.04"
DOCKER_IMAGE = "volta-deepgemm:cuda-12.9.1"
DOCKERFILE = f"""FROM {CUDA_IMAGE}
RUN apt-get update && apt-get install -y --no-install-recommends python3 && rm -rf /var/lib/apt/lists/*
WORKDIR /work
"""

# DeepJIT picks `sm_100f` (arch family) on a B200; Volta's corpus targets `sm_100a`, which
# enables the same tcgen05/TMA features for this one chip.
ARCH = "sm_100a"
# `CompilerOptions::default_options` + `get_flags` (deep_jit/backend/cuda/options.hpp), then
# the two flags `init_jit` appends (csrc/runtime/jit.hpp). The epilogues and MQA logits used
# here add no compiler options of their own.
NVCC_FLAGS = [
    f"--gpu-architecture={ARCH}", "-O3", "--compiler-options=-O3",
    "--ptxas-options=--register-usage-level=10",
    "-std=c++20", "--compiler-options=-fPIC", "--compiler-options=-fconcepts",
    "--expt-relaxed-constexpr", "--expt-extended-lambda",
    "--diag-suppress=39,161,174,177,186,940",
    "--compiler-options=-Wno-deprecated-declarations,-Wno-abi",
]
# The installed package's `include/` holds `deep_gemm/`, `cute/` and `cutlass/` side by side.
INCLUDE_DIRS = ["deep_gemm/include", "third-party/cutlass/include"]

NUM_SMS = 148  # B200; `runtime->get_num_sms()`
SMEM_CAPACITY = 232448  # SM100ArchSpec::smem_capacity
MK_ALIGNMENT_FOR_CONTIGUOUS_LAYOUT = 128  # HeuristicsRuntime default (only matters for k-grouped)
TC_UTIL = 100  # `Runtime::get_tc_util()` default

ELEM_SIZE = {"bf16": 2, "fp32": 4, "e4m3": 1}
DTYPE_NAME = {"bf16": "cutlass::bfloat16_t", "fp32": "float", "e4m3": "cutlass::float_e4m3_t"}
K_MAJOR = "cute::UMMA::Major::K"


# --- SM100 heuristics (csrc/jit_kernels/heuristics/sm100.hpp, common.hpp), normal GEMMs only ---

@dataclass(frozen=True)
class GemmDesc:
    m: int
    n: int
    k: int
    ab_dtype: str  # "bf16" or "e4m3"; both operands K-major
    cd_dtype: str = "bf16"
    compiled_dims: str = "nk"  # the `*_gemm_nt` default
    num_sms: int = NUM_SMS

    @property
    def is_1d1d(self) -> bool:
        return self.ab_dtype != "bf16"


def ceil_div(a: int, b: int) -> int:
    return (a + b - 1) // b


def align(a: int, b: int) -> int:
    return ceil_div(a, b) * b


def swizzle_mode(block_size: int, elem_size: int) -> int:
    return next(mode for mode in (128, 64, 32, 16) if block_size * elem_size % mode == 0)


def storage_config(d: GemmDesc, layout: dict) -> dict:
    load_block_m = layout["block_m"] // layout["cluster_n"]
    load_block_n = layout["block_n"] // layout["cluster_m"]
    store_block_m = 16 if layout["swap_ab"] else min(128, layout["block_m"])
    store_block_n = layout["block_n"]
    # K-major A and B: the swizzled inner dim is block K
    return {
        "load_block_m": load_block_m, "load_block_n": load_block_n,
        "store_block_m": store_block_m, "store_block_n": store_block_n,
        "swizzle_a_mode": swizzle_mode(layout["block_k"], ELEM_SIZE[d.ab_dtype]),
        "swizzle_b_mode": swizzle_mode(layout["block_k"], ELEM_SIZE[d.ab_dtype]),
        "swizzle_cd_mode": swizzle_mode(store_block_n, ELEM_SIZE[d.cd_dtype]),
    }


def sf_block_sizes(d: GemmDesc, block_m: int, block_n: int) -> tuple[int, int]:
    return (align(block_m, 128), align(block_n, 128)) if d.is_1d1d else (0, 0)


def layout_candidates(d: GemmDesc) -> list[dict]:
    block_k = 128 * 8 // (8 if d.is_1d1d else 16)
    candidates = []
    for swap_ab in (0, 1):
        if swap_ab:
            block_ms, block_ns = list(range(16, 257, 16)), [128]
        else:
            block_ms = [32] if d.m <= 32 else [64] if d.m <= 64 else [128]
            block_ns = [16] + list(range(32, (128 if d.k <= 256 else 256) + 1, 32))
        for cluster_m in (1, 2):
            if swap_ab and cluster_m > 1:
                continue
            for cluster_n in (1, 2):
                if cluster_m * cluster_n > 2 or (not swap_ab and cluster_n > 1) or d.num_sms % (cluster_m * cluster_n):
                    continue
                for block_m in block_ms:
                    if (block_m // cluster_n) % 8 or ceil_div(d.m, block_m) % cluster_m:
                        continue
                    for block_n in block_ns:
                        if (block_n // cluster_m) % 8 or ceil_div(d.n, block_n) % cluster_n:
                            continue
                        if swap_ab and block_n != 128:
                            continue
                        sf_m, sf_n = sf_block_sizes(d, block_m, block_n)
                        tmem_sf_cols = (sf_m * (block_k // 128) + sf_n * (block_k // 128)) // 32 if d.is_1d1d else 0
                        if (block_m if swap_ab else block_n) + tmem_sf_cols > 512:
                            continue
                        layout = {"swap_ab": swap_ab, "block_m": block_m, "block_n": block_n, "block_k": block_k,
                                  "cluster_m": cluster_m, "cluster_n": cluster_n}
                        storage = storage_config(d, layout)
                        if storage["swizzle_a_mode"] != 128 or storage["swizzle_b_mode"] != 128:
                            continue
                        candidates.append(layout)
    assert candidates
    return candidates


def better(a: dict, b: dict) -> bool:
    """`SM100ArchSpec::compare`: is layout info `a` strictly better than `b`."""
    la, lb = a["layout"], b["layout"]
    size_a, size_b = la["cluster_m"] * la["cluster_n"], lb["cluster_m"] * lb["cluster_n"]
    if (a["num_waves"] == 1 or b["num_waves"] == 1) and a["num_waves"] != b["num_waves"]:
        return a["num_waves"] < b["num_waves"]
    if size_a != size_b:
        return size_a > size_b
    if a["num_waves"] != b["num_waves"]:
        return a["num_waves"] < b["num_waves"]
    if a["last_wave_util"] != b["last_wave_util"]:
        return a["last_wave_util"] > b["last_wave_util"]
    if la["block_m"] + la["block_n"] != lb["block_m"] + lb["block_n"]:
        return la["block_m"] + la["block_n"] < lb["block_m"] + lb["block_n"]
    return la["block_m"] * la["block_n"] < lb["block_m"] * lb["block_n"]


def layout_info(d: GemmDesc, layout: dict) -> dict:
    num_blocks = ceil_div(d.m, layout["block_m"]) * ceil_div(d.n, layout["block_n"])
    last = num_blocks % d.num_sms
    return {"num_waves": ceil_div(num_blocks, d.num_sms), "last_wave_util": last or d.num_sms, "layout": layout}


def sm100_heuristics(d: GemmDesc) -> dict:
    """`get_best_config<SM100ArchSpec>`: layout, storage, pipeline and launch configs."""
    best = None
    for layout in layout_candidates(d):
        info = layout_info(d, layout)
        if best is None or better(info, best):
            best = info
    layout = best["layout"]
    storage = storage_config(d, layout)
    num_tma_store_stages = 2  # normal GEMM
    smem_cd = (storage["store_block_m"] * storage["store_block_n"] * ELEM_SIZE[d.cd_dtype] if layout["swap_ab"]
               else storage["store_block_m"] * storage["swizzle_cd_mode"]) * num_tma_store_stages
    smem_extra = smem_cd + (32 * 8 * 3 + 2 * 8 * 3 + 8) + 4
    elem = ELEM_SIZE[d.ab_dtype]
    smem_per_stage = (storage["load_block_m"] + storage["load_block_n"]) * layout["block_k"] * elem
    if d.is_1d1d:
        sf_m, sf_n = sf_block_sizes(d, layout["block_m"], layout["block_n"])
        smem_per_stage += (sf_m + sf_n) * layout["block_k"] // 32
    num_stages = min((SMEM_CAPACITY - smem_extra) // smem_per_stage, 32)
    return {
        "layout": layout,
        "storage": storage,
        "pipeline": {"smem_size": smem_extra + num_stages * smem_per_stage, "num_stages": num_stages,
                     "num_tma_store_stages": num_tma_store_stages},
        "launch": {"num_sms": d.num_sms, "cluster_size": layout["cluster_m"] * layout["cluster_n"], "num_threads": 256,
                   "num_non_epilogue_threads": 128, "num_epilogue_threads": 128},
        "layout_info": {k: v for k, v in best.items() if k != "layout"},
    }


def compiled_dim(value: int, name: str, d: GemmDesc) -> int:
    return value if name in d.compiled_dims else 0


def cpp(value: object) -> str:
    """`std::format("{}")` of the host value: bools print as true/false."""
    return ("true" if value else "false") if isinstance(value, bool) else str(value)


# --- Jobs: one generated `kernel.cu` and the launch DeepGEMM would make ---

@dataclass
class Job:
    kernel: str
    config: str
    header: str
    template: str  # the kernel template name
    template_args: list[tuple[str, object]]  # (template parameter, host value), in order
    launch: dict
    params: list[tuple[str, str]]  # (kernel parameter, meaning), in order
    tensor_maps: dict
    heuristics: dict
    preamble: str = ""

    @property
    def name(self) -> str:
        return f"{self.kernel}.{self.config}"

    def source(self) -> str:
        args = ",\n        ".join(cpp(v) for _, v in self.template_args)
        return (
            f"\n#include <deep_gemm/impls/{self.header}>\n\nusing namespace deep_gemm;\n{self.preamble}\n"
            f"static void __instantiate_kernel() {{\n    auto ptr = reinterpret_cast<void*>(&{self.template}<\n"
            f"        {args}\n    >);\n}};\n"
        )


TMA_PARAM = "CUtensorMap (128 B) passed by value as `const __grid_constant__ cute::TmaDescriptor`"


def tma_2d(gmem: tuple[int, int], box: tuple[int, int], stride_bytes: int, swizzle: int, dtype: str) -> dict:
    """`make_tma_2d_desc`: dims are inner-first; a swizzled box's inner dim is the swizzle span."""
    if swizzle:
        box = (swizzle // ELEM_SIZE.get(dtype, 4), box[1])
    return {"rank": 2, "dtype": dtype, "global_dims": list(gmem), "global_stride_bytes": [stride_bytes],
            "box_dims": list(box), "swizzle_bytes": swizzle or None, "interleave": "NONE",
            "l2_promotion": "L2_256B", "oob_fill": "NONE"}


def gemm_job(kernel: str, d: GemmDesc) -> Job:
    h = sm100_heuristics(d)
    lay, st, pipe, lau = h["layout"], h["storage"], h["pipeline"], h["launch"]
    common_head = [("kMajorA", K_MAJOR), ("kMajorB", K_MAJOR)]
    shape = [("SHAPE_M", compiled_dim(d.m, "m", d)), ("SHAPE_N", compiled_dim(d.n, "n", d)),
             ("SHAPE_K", compiled_dim(d.k, "k", d)),
             ("BLOCK_M", lay["block_m"]), ("BLOCK_N", lay["block_n"]), ("BLOCK_K", lay["block_k"]),
             ("kNumGroups", 1),
             ("kSwizzleAMode", st["swizzle_a_mode"]), ("kSwizzleBMode", st["swizzle_b_mode"]),
             ("kSwizzleCDMode", st["swizzle_cd_mode"])]
    threads = [("kNumNonEpilogueThreads", lau["num_non_epilogue_threads"]),
               ("kNumEpilogueThreads", lau["num_epilogue_threads"]),
               ("kNumMulticast", lau["cluster_size"]), ("kIsMulticastOnA", lay["cluster_n"] > 1),
               ("kNumSMs", lau["num_sms"])]
    tail = [("kSwapAB", lay["swap_ab"]), ("kEnsureZeroPadding", True),
            ("kGemmType", "GemmType::Normal"), ("kWithAccumulation", False)]
    cd = DTYPE_NAME[d.cd_dtype]
    epilogue = "epilogue::operators::Identity"
    if d.is_1d1d:
        gran_k = 128  # default recipe (1, 1, 128) for UE8M0-packed int SFs on SM100
        args = (common_head + [("kGranKA", gran_k), ("kGranKB", gran_k), ("kKAlignment", gran_k)] + shape
                + [("kNumStages", pipe["num_stages"]), ("kNumTMAStoreStages", pipe["num_tma_store_stages"])]
                + threads + tail
                + [("a_dtype_t", DTYPE_NAME[d.ab_dtype]), ("b_dtype_t", DTYPE_NAME[d.ab_dtype]),
                   ("cd_dtype_t", cd), ("epilogue_operator_t", epilogue)])
        template = "sm100_fp8_fp4_gemm_1d1d_impl"
    else:
        args = (common_head + shape + [("kNumStages_", pipe["num_stages"])] + threads
                + [("kKAlignment", MK_ALIGNMENT_FOR_CONTIGUOUS_LAYOUT)] + tail
                + [("cd_dtype_t", cd), ("epilogue_operator_t", epilogue), ("kTensorCoreUtilControl", TC_UTIL)])
        template = "sm100_bf16_gemm_impl"
    elem, cd_elem = ELEM_SIZE[d.ab_dtype], ELEM_SIZE[d.cd_dtype]
    maps = {
        "tensor_map_a": tma_2d((d.k, d.m), (lay["block_k"], st["load_block_m"]), d.k * elem, st["swizzle_a_mode"], d.ab_dtype),
        "tensor_map_b": tma_2d((d.k, d.n), (lay["block_k"], st["load_block_n"]), d.k * elem, st["swizzle_b_mode"], d.ab_dtype),
        "tensor_map_cd": tma_2d((d.n, d.m), (st["store_block_n"], st["store_block_m"]), d.n * cd_elem,
                                st["swizzle_cd_mode"], d.cd_dtype),
    }
    params = [("grouped_layout", "int* (nullptr for a normal GEMM)"),
              ("shape_m", "u32 M"), ("shape_n", "u32 N (overridden by SHAPE_N when compiled)"),
              ("shape_k", "u32 K (overridden by SHAPE_K when compiled)"),
              ("epilogue_args", "EpilogueOperatorArgs by value (48 B, align 8: sfd* @0, sfd_stride @8, shape_m @12, shape_n @16, "
                                "alpha @20 = 1.0f, clamp_value @24, clamped_count* @32, clamp_count_ready* @40); "
                                "Identity passes the default `{}`")]
    params += [("tensor_map_a", TMA_PARAM), ("tensor_map_b", TMA_PARAM)]
    if d.is_1d1d:
        # SFs: UE8M0 packed 4 per int32, MN-major, TMA-aligned (`make_tma_sf_desc`), box (sf_block_mn, 1)
        sf_m, sf_n = sf_block_sizes(d, lay["block_m"], lay["block_n"])
        sf_k = ceil_div(d.k, gran_k * 4)
        aligned = lambda mn: align(mn, 16 // 4)  # get_tma_aligned_size for 4-byte elements
        maps["tensor_map_sfa"] = tma_2d((aligned(d.m), sf_k), (sf_m, lay["block_k"] // 128), aligned(d.m) * 4, 0, "int32")
        maps["tensor_map_sfb"] = tma_2d((aligned(d.n), sf_k), (sf_n, lay["block_k"] // 128), aligned(d.n) * 4, 0, "int32")
        params += [("tensor_map_sfa", TMA_PARAM), ("tensor_map_sfb", TMA_PARAM)]
    params += [("tensor_map_cd", TMA_PARAM)]
    launch = {"grid": [lau["num_sms"], 1, 1], "block": [lau["num_threads"], 1, 1],
              "cluster": [lau["cluster_size"], 1, 1], "dynamic_smem_bytes": pipe["smem_size"],
              "persistent": "grid is the SM count; a scheduler walks the M x N blocks"}
    config = f"m{d.m}n{d.n}k{d.k}_{d.ab_dtype}_{d.cd_dtype}out"
    return Job(kernel, config, f"{kernel}.cuh", template, args, launch, params, maps,
               {"desc": d.__dict__, **h})


def mqa_logits_job(num_heads: int, head_dim: int, num_q_tokens: int, num_kv_tokens: int) -> Job:
    """`sm100_mqa_logits` (csrc/jit_kernels/impls/sm100_mqa_logits.hpp), FP8 Q/KV, no schedule metadata."""
    split_kv, num_tmem_stages, num_specialized, num_math = 384, 3, 128, (384 // 128) * 128
    block_q = 128 // num_heads
    umma_n = align(block_q * num_heads, 8)
    num_q_stages, num_kv_stages = 3, 3
    qk_bytes = head_dim
    swizzle_alignment = 8 * qk_bytes
    weights_row = align(num_heads * 2, 16) // 2
    weight_bytes = align(block_q * weights_row * 2, 128)
    smem = 0
    for size, alignment in [
        (num_q_stages * umma_n * qk_bytes, swizzle_alignment),
        (num_kv_stages * split_kv * qk_bytes, swizzle_alignment),
        (num_q_stages * align(umma_n, 128) * 4, 128),
        (num_kv_stages * align(split_kv, 128) * 4, 128),
        (num_q_stages * weight_bytes, 128),
        ((3 * (num_q_stages + num_kv_stages) + 2 * num_tmem_stages) * 8, 8),
        (4, 4),
    ]:
        smem = align(smem, alignment) + size
    smem = align(smem, swizzle_alignment)
    assert smem <= SMEM_CAPACITY
    qk = "cutlass::float_e4m3_t"
    storage_args = f"{num_heads}, {head_dim}, {block_q}, {split_kv}, {umma_n}, {num_q_stages}, {num_kv_stages}, {num_tmem_stages}, {qk}"
    preamble = (f"\nstatic_assert(sizeof(layout::MQALogitsSharedStorage<\n    {storage_args}\n>) == {smem}, "
                f"\"Incorrect MQA logits shared-memory size\");\n")
    args = [("kNumHeads", num_heads), ("kHeadDim", head_dim), ("kUseSchedule", False),
            ("BLOCK_Q", block_q), ("SPLIT_KV", split_kv), ("UMMA_N", umma_n),
            ("kNumQStages", num_q_stages), ("kNumKVStages", num_kv_stages), ("kNumTmemStages", num_tmem_stages),
            ("kNumSMs", NUM_SMS), ("kNumSpecializedThreads", num_specialized), ("kNumMathThreads", num_math),
            ("qk_dtype_t", qk)]
    kv_tma_tokens = 256 if split_kv % 256 == 0 else 128
    sf_kv_len = align(num_kv_tokens, 4)
    maps = {
        "tensor_map_q": tma_2d((head_dim, num_q_tokens * num_heads), (head_dim, block_q * num_heads), head_dim, head_dim, "e4m3"),
        "tensor_map_sf_q": tma_2d((num_heads, num_q_tokens), (num_heads, block_q), num_heads * 4, 0, "int32"),
        "tensor_map_kv": tma_2d((head_dim, num_kv_tokens), (head_dim, kv_tma_tokens), head_dim, head_dim, "e4m3"),
        "tensor_map_sf_kv": tma_2d((sf_kv_len, 1), (kv_tma_tokens, 1), 0, 0, "int32"),
        "tensor_map_weights": tma_2d((num_heads, num_q_tokens), (weights_row, block_q), num_heads * 2, 0, "bf16"),
    }
    params = [("num_q_tokens", "u32"), ("num_kv_tokens", "u32"), ("logits_stride", "u32 (elements, 1024 B aligned)"),
              ("cu_seq_len_k_start", "u32* [num_q_tokens]"), ("cu_seq_len_k_end", "u32* [num_q_tokens]"),
              ("schedule_meta", "u32* (nullptr: kUseSchedule = false)"), ("logits", "bf16* [num_q_tokens, logits_stride]")]
    params += [(name, TMA_PARAM) for name in maps]
    launch = {"grid": [NUM_SMS, 1, 1], "block": [num_specialized + num_math, 1, 1], "cluster": [1, 1, 1],
              "dynamic_smem_bytes": smem, "persistent": "grid is the SM count; a scheduler walks Q blocks x KV splits"}
    config = f"h{num_heads}d{head_dim}_e4m3"
    heur = {"num_heads": num_heads, "head_dim": head_dim, "num_q_tokens": num_q_tokens, "num_kv_tokens": num_kv_tokens,
            "block_q": block_q, "umma_n": umma_n, "split_kv": split_kv}
    return Job("sm100_mqa_logits", config, "sm100_mqa_logits.cuh", "sm100_mqa_logits", args, launch, params, maps,
               heur, preamble)


JOBS: list[Callable[[], Job]] = [
    lambda: gemm_job("sm100_bf16_gemm", GemmDesc(128, 128, 256, "bf16")),
    lambda: gemm_job("sm100_fp8_fp4_gemm_1d1d", GemmDesc(128, 128, 256, "e4m3")),
    # DeepSeek-V3.2 indexer shape: 64 heads of 128
    lambda: mqa_logits_job(num_heads=64, head_dim=128, num_q_tokens=4, num_kv_tokens=1024),
]


# --- Compilation ---

ENTRY = re.compile(r"^(?:\.visible |\.weak )?\.entry (\S+?)\(", re.MULTILINE)
PARAM = re.compile(r"\.param\s+(.*?)\s*(\S+?)(\[\d+\])?\s*,?\s*$")
DIRECTIVE = re.compile(r"^\s*\.(maxntid|reqntid|reqnctapercluster|maxnreg|minnctapersm)\s+([\d, ]+)$", re.MULTILINE)


def ptx_entries(ptx: str) -> list[dict]:
    entries = []
    for entry in ENTRY.finditer(ptx):
        close = ptx.index(")", entry.end())
        params = []
        for line in ptx[entry.end():close].splitlines():
            if m := PARAM.search(line.strip()):
                params.append({"ptx_name": m.group(2), "ptx_type": m.group(1) + (m.group(3) or "")})
        header = ptx[close: ptx.index("{", close)]
        directives = {d: [int(x) for x in v.split(",")] for d, v in DIRECTIVE.findall(header)}
        entries.append({"name": entry.group(1), "params": params, **directives})
    return entries


def nvcc_version() -> str:
    output = subprocess.run(["nvcc", "--version"], capture_output=True, text=True, check=True).stdout
    match = re.search(r"release ([\d.]+)", output)
    return match.group(1) if match else output.strip().splitlines()[-1]


def compile_job(job: Job, source_root: Path, out: Path, version: str) -> str:
    with tempfile.TemporaryDirectory() as work:  # DeepJIT compiles from an empty directory, too
        cu = Path(work) / "kernel.cu"
        cu.write_text(job.source())
        ptx_path = (out / f"{job.name}.ptx").resolve()
        cmd = ["nvcc", str(cu), "--ptx", "--output-file", str(ptx_path), *NVCC_FLAGS]
        for inc in INCLUDE_DIRS:
            cmd += ["--include-path", str(source_root / inc)]
        result = subprocess.run(cmd, cwd=work, capture_output=True, text=True)
        if result.returncode != 0:
            return f"{job.name}: COMPILE-FAILED\n{result.stdout}{result.stderr}"
    (out / f"{job.name}.cu").write_text(job.source())
    ptx = ptx_path.read_text()
    entries = ptx_entries(ptx)
    for entry in entries:
        if len(entry["params"]) == len(job.params):
            for p, (name, meaning) in zip(entry["params"], job.params):
                p.update(source_name=name, meaning=meaning)
    target = re.search(r"^\.target (\S+)", ptx, re.MULTILINE)
    summary = {
        "kernel": job.kernel,
        "config": job.config,
        "source": f"deep_gemm/include/deep_gemm/impls/{job.header}",
        "generated_source": f"{job.name}.cu",
        "nvcc": version,
        "nvcc_flags": ["--ptx", *NVCC_FLAGS],
        "target": target.group(1) if target else None,
        "template": job.template,
        "template_args": {name: value for name, value in job.template_args},
        "launch": job.launch,
        "entries": entries,
        "tensor_maps": job.tensor_maps,
        "heuristics": job.heuristics,
        "notes": [
            "DeepJIT launches with enable_pdl = false unless `deep_gemm.set_pdl(True)`, so griddepcontrol.wait is a no-op",
            "cluster = 1: mapa.shared::cluster to rank 0 and the .shared::cluster mbarrier/TMA/commit forms address this CTA",
        ],
    }
    (out / f"{job.name}.json").write_text(json.dumps(summary, indent=2) + "\n")
    return f"{job.name} -> {ptx_path}"


def selected_jobs(names: list[str]) -> list[Job]:
    jobs = [make() for make in JOBS]
    if names:
        jobs = [j for j in jobs if any(j.name.startswith(n) for n in names)]
        if not jobs:
            sys.exit(f"no job matches {names}: run with --list")
    return jobs


def compile_local(names: list[str], source_root: Path, out: Path, jobs: int) -> None:
    if shutil.which("nvcc") is None:
        sys.exit("nvcc is not on the PATH (use --backend docker)")
    version = nvcc_version()
    out.mkdir(parents=True, exist_ok=True)
    failed = False
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as pool:
        for message in pool.map(lambda j: compile_job(j, source_root, out, version), selected_jobs(names)):
            print(message, flush=True)
            failed |= "COMPILE-FAILED" in message
    if failed:
        sys.exit(1)


def docker(*args: str, stdin: str | None = None) -> None:
    if subprocess.run(["docker", *args], input=stdin, text=True).returncode != 0:
        sys.exit(f"docker {args[0]} failed")


def compile_in_docker(names: list[str], source_root: Path, out: Path, jobs: int) -> None:
    """Run this script with `--backend local` in a container, the checkout mounted read-only."""
    if subprocess.run(["docker", "info"], capture_output=True).returncode != 0:
        sys.exit("the Docker daemon is not running (start Docker Desktop, or `colima start`)")
    if subprocess.run(["docker", "image", "inspect", DOCKER_IMAGE], capture_output=True).returncode != 0:
        print(f"building {DOCKER_IMAGE} (once)", file=sys.stderr)
        docker("build", "-t", DOCKER_IMAGE, "-", stdin=DOCKERFILE)
    script = Path(__file__).resolve()
    out.mkdir(parents=True, exist_ok=True)
    docker(
        "run", "--rm",
        "-v", f"{script.parent}:/work/extraction:ro",
        "-v", f"{source_root.resolve()}:/src/DeepGEMM:ro",
        "-v", f"{out.resolve()}:/out",
        DOCKER_IMAGE,
        "python3", f"/work/extraction/{script.name}", *names, "--backend=local",
        "--source=/src/DeepGEMM", "--out=/out", f"--jobs={jobs}",
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("names", nargs="*", help="job name prefixes, e.g. sm100_bf16_gemm (default: all)")
    parser.add_argument("--list", action="store_true", help="print the jobs and their launch, then exit")
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE, help=f"DeepGEMM checkout (default {DEFAULT_SOURCE})")
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT, help=f"output dir (default {DEFAULT_OUT})")
    parser.add_argument("--jobs", type=int, default=2, help="parallel nvcc processes (default 2)")
    parser.add_argument("--backend", choices=["auto", "local", "docker"], default="auto",
                        help="where nvcc runs (default: local if it is on the PATH, else docker)")
    args = parser.parse_args()

    if args.list:
        for job in selected_jobs(args.names):
            print(job.name, json.dumps(job.launch))
        return
    if not (args.source / "third-party" / "cutlass" / "include").is_dir():
        sys.exit(f"no DeepGEMM checkout with submodules at {args.source}: run `just ptx-sources`")
    backend = args.backend
    if backend == "auto":
        backend = "local" if shutil.which("nvcc") else "docker"
    (compile_local if backend == "local" else compile_in_docker)(args.names, args.source, args.out, args.jobs)


if __name__ == "__main__":
    main()
