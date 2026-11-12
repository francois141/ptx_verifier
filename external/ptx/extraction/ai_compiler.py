# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""Extract the AI compiler's PTX kernels and write their Volta launch files.

    uv run external/ptx/extraction/ai_compiler.py                  # every kernel
    uv run external/ptx/extraction/ai_compiler.py Softmax sm_89    # those whose path contains every word

The AI compiler (`sources/triton_ai_compiler`, a submodule) writes PTX for a
Triton kernel of PTX Gym (its `ptx_gym` submodule) in place of Triton's. Each
of its results, `compiler_results/<target>/<operator>/<stem>.ptx` beside a
`<stem>.result.json`, is copied to `external/ptx/ai_compiler/<target>/<operator>/`
with a launch file `<stem>.<size>.launch.json`: PTX Gym's problem for the
operator (`OPERATORS`, from its `get_random_input` and `forward_triton`), the
grid of the tuning configuration the PTX was measured with, the result's
block, and the target's opt-in maximum of dynamic shared memory (PTX Gym's
own launch size is not recorded). The tensors are whole: Volta runs CTA 0, so
an access outside them is out of bounds. Each PTX parameter binds by name to
an array or a scalar; Triton's two trailing scratch pointers are zero. An
operator of `NO_LAUNCH_FILE` gets its PTX only. The output directory is
replaced.
"""

import argparse
import json
import re
import shutil
import sys
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path

EXTERNAL_ROOT = Path(__file__).resolve().parent.parent
RESULTS = EXTERNAL_ROOT / "sources" / "triton_ai_compiler" / "compiler_results"
OUT = EXTERNAL_ROOT / "ai_compiler"
MAX_DYNAMIC_SHARED = {"sm_89": 99 * 1024, "sm_90a": 227 * 1024, "sm_100a": 227 * 1024}
SCRATCH_PARAMS = ("dummy_ptr1", "dummy_ptr2")
ENTRY = re.compile(r"\.entry\s+(\w+)\s*\(([^)]*)\)", re.DOTALL)
TARGET = re.compile(r"^\s*\.target\s+(\w+)", re.MULTILINE)


@dataclass(frozen=True)
class Array:
    kind: str  # `in`, `out` or `inout`, as in a launch file
    dtype: str
    shape: tuple[int, ...]


def inp(dtype: str, *shape: int) -> Array:
    return Array("in", dtype, shape)


def out(dtype: str, *shape: int) -> Array:
    return Array("out", dtype, shape)


def inout(dtype: str, *shape: int) -> Array:
    return Array("inout", dtype, shape)


@dataclass(frozen=True)
class Problem:
    """One launch of an operator: its arrays, what each PTX parameter binds to, and the grid."""

    size: str
    arrays: dict[str, Array]
    # PTX parameter -> array name or integer value.
    params: dict[str, str | int]
    grid: tuple[int, ...]


def cdiv(a: int, b: int) -> int:
    return -(-a // b)


def pointers(arrays: dict[str, Array], **aliases: str) -> dict[str, str]:
    """`<name>_ptr` -> `<name>` for every array, and each alias parameter -> its array."""
    return {f"{name}_ptr": name for name in arrays} | aliases


def tuned(config: dict, key: str, default: int) -> int:
    """The tuning configuration's `key`, else PTX Gym's default for the operator."""
    return int(config.get(key, default))


def input_dtype(operator: str) -> str:
    return "e4m3" if "Float8" in operator else "f16"


# PTX Gym's elementwise problems: (256, 4096) tensors, one BLOCK_SIZE slice per CTA.
ROWS, COLS = 256, 4096


def elementwise(inputs: tuple[str, ...], block_size: int) -> Callable[[str, dict], Problem]:
    def problem(operator: str, config: dict) -> Problem:
        arrays = {name: inp(input_dtype(operator), ROWS, COLS) for name in inputs}
        arrays["output"] = out("f16", ROWS, COLS)
        grid = (cdiv(ROWS * COLS, tuned(config, "block_size", block_size)),)
        return Problem(f"{ROWS}x{COLS}", arrays, pointers(arrays), grid)

    return problem


def reduction_sum(operator: str, config: dict) -> Problem:
    arrays = {"x": inp(input_dtype(operator), ROWS, COLS), "output": inout("f32", ROWS)}
    grid = (cdiv(COLS, tuned(config, "block_size", 1024)), ROWS)
    return Problem(f"{ROWS}x{COLS}", arrays, pointers(arrays), grid)


def rms_norm(operator: str, config: dict) -> Problem:
    dtype = input_dtype(operator)
    arrays = {"x": inp(dtype, ROWS, COLS), "weight": inp(dtype, ROWS, COLS), "output": out("f16", ROWS, COLS)}
    return Problem(f"{ROWS}x{COLS}", arrays, pointers(arrays), (ROWS,))


def rope(operator: str, config: dict) -> Problem:
    batch, heads, seq, dim = 256, 64, 256, 128
    dtype = input_dtype(operator)
    arrays = {
        "input": inp(dtype, batch, heads, seq, dim),
        "cos": inp(dtype, seq, dim),
        "sin": inp(dtype, seq, dim),
        "output": out("f16", batch, heads, seq, dim),
    }
    return Problem(f"{batch}x{heads}x{seq}x{dim}", arrays, pointers(arrays), (batch * heads * seq,))


def softmax(operator: str, config: dict) -> Problem:
    rows, cols = 4096, 256
    arrays = {"output": out("f16", rows, cols), "input": inp(input_dtype(operator), rows, cols)}
    scalars = {"input_row_stride": cols, "output_row_stride": cols, "n_rows": rows, "n_cols": cols}
    return Problem(f"{rows}x{cols}", arrays, pointers(arrays) | scalars, (rows,))


def matvec(operator: str, config: dict) -> Problem:
    n = 4096
    dtype = input_dtype(operator)
    arrays = {"a": inp(dtype, n, n), "x": inp(dtype, n), "y": out("f16", n)}
    return Problem(f"{n}x{n}", arrays, pointers(arrays), (cdiv(n, tuned(config, "block_m", 16)),))


def gemm(fused_add: bool) -> Callable[[str, dict], Problem]:
    """C = A B (+ D, through the fused epilogue), all (4096, 4096) and row-major."""

    def problem(operator: str, config: dict) -> Problem:
        n = 4096
        dtype = input_dtype(operator)
        arrays = {"a": inp(dtype, n, n), "b": inp(dtype, n, n)}
        if fused_add:
            arrays["d"] = inp(dtype, n, n)
        arrays["c"] = out("f16", n, n)
        grid = (cdiv(n, tuned(config, "block_m", 128)), cdiv(n, tuned(config, "block_n", 128)))
        return Problem(f"{n}x{n}x{n}", arrays, pointers(arrays), grid)

    return problem


def conv2d(operator: str, config: dict) -> Problem:
    batch, c_in, c_out, h_in, taps = 32, 64, 128, 56, 3
    h_out = h_in - taps + 1
    dtype = input_dtype(operator)
    arrays = {
        "x": inp(dtype, batch, c_in, h_in, h_in),
        "weight": inp(dtype, c_out, c_in, taps, taps),
        "output": out("f16", batch, c_out, h_out, h_out),
    }
    grid = (cdiv(batch * h_out * h_out, tuned(config, "block_m", 128)), cdiv(c_out, tuned(config, "block_n", 128)))
    return Problem(f"{batch}x{c_in}x{h_in}x{h_in}", arrays, pointers(arrays), grid)


def bitdelta(batch: int | None) -> Callable[[str, dict], Problem]:
    """f16 A times sign bits packed 32 K values per i32, (K / 32, N); `batch` such products."""

    def problem(operator: str, config: dict) -> Problem:
        n = 4096
        lead = () if batch is None else (batch,)
        arrays = {"a": inp("f16", *lead, n, n), "b": inp("i32", *lead, n // 32, n), "c": out("f16", *lead, n, n)}
        tiles = cdiv(n, tuned(config, "block_size_m", 64)) * cdiv(n, tuned(config, "block_size_n", 64))
        size = "x".join(map(str, (*lead, n, n, n)))
        return Problem(size, arrays, pointers(arrays), (tiles, *lead))

    return problem


def lion(operator: str, config: dict) -> Problem:
    n = 1 << 20
    arrays = {"p": inout("f32", n), "grad": inp("f32", n), "exp_avg": inout("f32", n)}
    return Problem(f"n{n}", arrays, pointers(arrays), (cdiv(n, tuned(config, "block_size", 1024)),))


def flash_attention(operator: str, config: dict) -> Problem:
    batch, heads, seq, dim = 64, 64, 128, 64
    block_m = tuned(config, "block_m", 32)
    arrays = {
        "Q": inp("f16", batch, heads, seq, dim),
        "K": inp("f16", batch, heads, seq, dim),
        "V": inp("f16", batch, heads, seq, dim),
        "Bias": inp("f16", 1),
        "Out": out("f16", batch, heads, seq, dim),
        "Lse": out("f32", batch, heads, seq),
        "TMP": out("f32", batch * heads * cdiv(seq, block_m) * block_m),
    }
    grid = (cdiv(seq, block_m), batch * heads)
    return Problem(f"{batch}x{heads}x{seq}x{dim}", arrays, pointers(arrays), grid)


def forgetting_attention(operator: str, config: dict) -> Problem:
    batch, heads, seq, dim = 16, 16, 1024, 64
    arrays = {
        "q": inp("f16", batch, heads, seq, dim),
        "k": inp("f16", batch, heads, seq, dim),
        "v": inp("f16", batch, heads, seq, dim),
        "log_lambda": inp("f32", batch, heads, seq),
        "l": out("f32", batch, heads, seq),
        "o": out("f16", batch, heads, seq, dim),
    }
    grid = (cdiv(seq, tuned(config, "block_m", 32)), heads, batch)
    return Problem(f"{batch}x{heads}x{seq}x{dim}", arrays, pointers(arrays), grid)


def sage_attention(operator: str, config: dict) -> Problem:
    batch, q_heads, kv_heads, q_len, kv_len, dim = 16, 16, 2, 1024, 128, 64
    block_m, block_n = tuned(config, "block_m", 128), tuned(config, "block_n", 64)
    arrays = {
        "Q": inp("i8", batch, q_heads, q_len, dim),
        "K": inp("i8", batch, kv_heads, kv_len, dim),
        "V": inp("f16", batch, kv_heads, kv_len, dim),
        "Q_scale": inp("f32", batch, q_heads, cdiv(q_len, block_m)),
        "K_scale": inp("f32", batch, kv_heads, cdiv(kv_len, block_n)),
        "Out": out("f16", batch, q_heads, q_len, dim),
        "mask": inp("i8", 1),
        "Lse": out("f32", 1),
    }
    grid = (q_len // block_m, q_heads, batch)
    return Problem(f"{batch}x{q_heads}x{q_len}x{dim}", arrays, pointers(arrays), grid)


def mamba2_chunk_state(operator: str, config: dict) -> Problem:
    batch, seq, heads, groups, dim, state, chunk = 64, 2048, 8, 4, 64, 128, 256
    chunks = cdiv(seq, chunk)
    arrays = {
        "x": inp("f16", batch, seq, heads, dim),
        "b": inp("f16", batch, seq, groups, state),
        "states": out("f32", batch, chunks, heads, dim, state),
        "dt": inp("f32", batch, heads, chunks, chunk),
        "dA_cumsum": inp("f32", batch, heads, chunks, chunk),
        "seq_idx": inp("i32", batch, seq),
    }
    tiles = cdiv(dim, tuned(config, "block_size_m", 32)) * cdiv(state, tuned(config, "block_size_n", 32))
    return Problem(f"{batch}x{seq}x{heads}x{dim}", arrays, pointers(arrays), (tiles, batch * chunks, heads))


def mamba2_chunk_scan(operator: str, config: dict) -> Problem:
    batch, seq, heads, groups, dim, state, chunk = 4, 2048, 8, 2, 128, 32, 128
    chunks = cdiv(seq, chunk)
    arrays = {
        "cb": inp("f32", batch, chunks, groups, chunk, chunk),
        "x": inp("f16", batch, seq, heads, dim),
        "z": inp("f16", batch, seq, heads, dim),
        "out": out("f16", batch, seq, heads, dim),
        "out_x": out("f16", batch, seq, heads, dim),
        "dt": inp("f32", batch, heads, chunks, chunk),
        "dA_cumsum": inp("f32", batch, heads, chunks, chunk),
        "seq_idx": inp("i32", batch, seq),
        "C": inp("f16", batch, seq, groups, state),
        "prev_states": inp("f32", batch, chunks, heads, dim, state),
        "D": inp("f32", heads, dim),
    }
    tiles = cdiv(chunk, tuned(config, "block_size_m", 64)) * cdiv(dim, tuned(config, "block_size_n", 64))
    return Problem(f"{batch}x{seq}x{heads}x{dim}", arrays, pointers(arrays), (tiles, batch * chunks, heads))


def flash_sinkhorn(operator: str, config: dict) -> Problem:
    n, m, dim = 1024, 1024, 64
    arrays = {
        "x": inp("f16", n, dim),
        "y": inp("f16", m, dim),
        "f_hat": inp("f32", n),
        "g_hat": inp("f32", m),
        "log_a": inp("f32", n),
        "log_b": inp("f32", m),
        "f_out": out("f32", n),
        "g_out": out("f32", m),
        "labels": inp("i32", 1),
        "W": inp("f32", 1),
    }
    params = pointers(arrays, label_x_ptr="labels", label_y_ptr="labels")
    grid = (cdiv(n, tuned(config, "block_m", 64)) + cdiv(m, tuned(config, "block_n", 64)),)
    return Problem(f"{n}x{m}x{dim}", arrays, params, grid)


def mamba_iclr2026(operator: str, config: dict) -> Problem:
    batch, heads, seq, k, v, chunk = 8, 16, 2048, 64, 64, 128
    chunks = cdiv(seq, chunk)
    arrays = {
        "Q": inp("f16", batch, heads, seq, k),
        "K": inp("f16", batch, heads, seq, k),
        "V": inp("f16", batch, heads, seq, v),
        "ADT": inp("f32", batch, heads, seq),
        "DT": inp("f32", batch, heads, seq + 1),
        "Trap": inp("f32", batch, heads, seq + 1),
        "Q_bias": inp("f16", heads, k),
        "K_bias": inp("f16", heads, k),
        "Angles": inp("f32", batch, heads, seq, k // 2),
        "D_input": inp("f32", heads),
        "Z": inp("f16", batch, heads, seq, v),
        "Initial_SSM_State": inp("f32", batch, heads, v, k),
        "Initial_K_State": inp("f32", batch, heads, k),
        "Initial_V_State": inp("f32", batch, heads, v),
        "Cu_Seqlens": inp("i32", batch + 1),
        "Out": out("f16", batch, heads, seq, v),
        "Out_v": out("f16", batch, heads, seq, v),
        "SSM_States": out("f16", batch, heads, v, chunks * k),
        "DA_CS_Store": out("f32", batch, heads, seq),
        "DA_CS_SUM_Store": out("f32", batch, heads, chunks),
        "Q_store": out("f16", batch, heads, seq, k),
        "K_store": out("f16", batch, heads, seq, k),
        "QK_store": out("f32", batch, heads, seq),
        "Scale_store": out("f32", batch, heads, seq),
        "Gamma_store": out("f32", batch, heads, seq),
        "Final_SSM_State": out("f32", batch, heads, v, k),
        "Final_K_State": out("f16", batch, heads, chunk, k),
    }
    return Problem(f"{batch}x{heads}x{seq}x{k}", arrays, pointers(arrays), (heads, batch))


# PTX Gym operator -> its problem, given the tuning configuration the PTX was measured with.
OPERATORS: dict[str, Callable[[str, dict], Problem]] = {
    "ReLUFloat16Kernel": elementwise(("x",), 1024),
    "ReLUFloat8Kernel": elementwise(("x",), 1024),
    "GELUFloat16Kernel": elementwise(("x",), 1024),
    "GELUFloat8Kernel": elementwise(("x",), 1024),
    "SigmoidFloat16Kernel": elementwise(("x",), 4096),
    "SigmoidFloat8Kernel": elementwise(("x",), 4096),
    "SiLUFloat16Kernel": elementwise(("x",), 4096),
    "SiLUFloat8Kernel": elementwise(("x",), 4096),
    "SwiGLUFloat16Kernel": elementwise(("gate", "value"), 4096),
    "SwiGLUFloat8Kernel": elementwise(("gate", "value"), 4096),
    "ReductionSumFloat16Kernel": reduction_sum,
    "ReductionSumFloat8Kernel": reduction_sum,
    "RMSNormFloat16Kernel": rms_norm,
    "RMSNormFloat8Kernel": rms_norm,
    "RoPEFloat16Kernel": rope,
    "RoPEFloat8Kernel": rope,
    "SoftmaxFloat16Kernel": softmax,
    "SoftmaxFloat8Kernel": softmax,
    "MatrixVectorMultiplicationFloat16Kernel": matvec,
    "MatrixVectorMultiplicationFloat8Kernel": matvec,
    "MatrixMultiplicationFloat16": gemm(fused_add=False),
    "MatrixMultiplicationFloat8": gemm(fused_add=False),
    "FusedGEMMAddGELUFloat16Kernel": gemm(fused_add=True),
    "FusedGEMMAddGELUFloat8Kernel": gemm(fused_add=True),
    "FusedGEMMAddSiLUFloat16Kernel": gemm(fused_add=True),
    "FusedGEMMAddSiLUFloat8Kernel": gemm(fused_add=True),
    "Convolution2DFloat16Kernel": conv2d,
    "Convolution2DFloat8Kernel": conv2d,
    "BitDeltaNeurIPS2024Matmul": bitdelta(batch=None),
    "BitDeltaNeurIPS2024BatchedMatmul": bitdelta(batch=8),
    "LionNeurIPS2023Optimizer": lion,
    "FlashAttentionNeurIPS2022Forward": flash_attention,
    "ForgettingAttentionICLR2025Forward": forgetting_attention,
    "SageAttentionICLR2025": sage_attention,
    "Mamba2ChunkStateForward": mamba2_chunk_state,
    "Mamba2ChunkScanForward": mamba2_chunk_scan,
    "FlashSinkhornFusedSchurMatvec": flash_sinkhorn,
    "MambaICLR2026Forward": mamba_iclr2026,
}
# Operators whose PTX is copied without a launch file, and why no launch file expresses their problem.
NO_LAUNCH_FILE = {
    "Dion2TritonPostOrthogonalize": "its index map holds positions in U's 32 selected columns, but a "
    "launch file's index array holds i at i, so CTA 0's columns 32-63 would gather unstaged shared memory",
}


@dataclass(frozen=True)
class Result:
    """One `<stem>.result.json`, whichever of the AI compiler's layouts it has."""

    block: tuple[int, int, int]
    config: dict
    speedup: float | None

    @staticmethod
    def load(path: Path) -> "Result":
        result = json.loads(path.read_text())
        candidate = result.get("candidate", result)
        metrics = result.get("autotune_metrics", {})
        config = metrics.get("selected_config") or metrics.get("tuning_result", {}).get("parameters", {})
        verdict = result.get("evaluation") or result.get("answer") or {}
        speedup = result.get("speedup", result.get("speedup_vs_triton", verdict.get("speedup_vs_triton")))
        block = tuple(candidate[f"num_threads_{axis}"] for axis in "xyz")
        return Result(block, config, speedup)


def kernel_params(ptx: str) -> tuple[str, list[str]]:
    (entry,) = ENTRY.findall(ptx)
    name, params = entry
    return name, [param.split()[-1] for param in params.split(",") if param.strip()]


def launch_file(ptx_path: Path, operator: str, target: str, result: Result) -> tuple[str, dict]:
    """`ptx_path`'s case label and launch file."""
    ptx = ptx_path.read_text()
    kernel, names = kernel_params(ptx)
    declared = TARGET.search(ptx)
    if declared is None or declared[1] != target:
        raise ValueError(f"{ptx_path}: .target is not {target}")
    problem = OPERATORS[operator](operator, result.config)
    params = []
    for name in names:
        if name in SCRATCH_PARAMS:
            params.append({"name": "Triton scratch pointer", "int": 0})
        elif isinstance(bound := problem.params.get(name), str):
            params.append({"name": name, "ptr": bound})
        elif isinstance(bound, int):
            params.append({"name": name, "int": bound})
        else:
            raise ValueError(f"{ptx_path}: parameter {name} is not in {operator}'s problem")
    unbound = set(problem.arrays) - {p["ptr"] for p in params if "ptr" in p}
    if unbound:
        raise ValueError(f"{ptx_path}: no parameter takes {', '.join(sorted(unbound))}")
    tensors = ", ".join(f"{name} {a.dtype}{list(a.shape)}" for name, a in problem.arrays.items())
    speedup = "" if result.speedup is None else f", {result.speedup:.4f}x Triton"
    launch = {
        "description": f"AI compiler {target}/{operator}/{ptx_path.stem}{speedup}: PTX Gym's problem, {tensors}",
        "kernel": kernel,
        "block": list(result.block),
        "grid": list(problem.grid) + [1] * (3 - len(problem.grid)),
        "dynamic_shared_bytes": MAX_DYNAMIC_SHARED[target],
        "arrays": [
            {"name": name, "kind": a.kind, "dtype": a.dtype, "shape": list(a.shape)}
            for name, a in problem.arrays.items()
        ],
        "params": params,
    }
    return problem.size, launch


def render(launch: dict) -> str:
    """The launch file with one line per array and per parameter, as the other suites write it."""
    lines = []
    for key, value in launch.items():
        if isinstance(value, list) and value and isinstance(value[0], dict):
            rows = ",\n".join(f"    {json.dumps(row)}" for row in value)
            lines.append(f'  "{key}": [\n{rows}\n  ]')
        else:
            lines.append(f'  "{key}": {json.dumps(value)}')
    return "{\n" + ",\n".join(lines) + "\n}\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("words", nargs="*", help="extract only the results whose path contains every word")
    args = parser.parse_args()
    if not RESULTS.is_dir():
        sys.exit(f"no {RESULTS}: run `git submodule update --init external/ptx/sources/triton_ai_compiler`")

    ptxs = [
        p for p in sorted(RESULTS.glob("*/*/*.ptx"))
        if all(word in str(p.relative_to(RESULTS)) for word in args.words)
    ]
    unknown = sorted({p.parent.name for p in ptxs} - set(OPERATORS) - set(NO_LAUNCH_FILE))
    if unknown:
        sys.exit(f"no problem for {', '.join(unknown)}: add it to OPERATORS")
    if not args.words:
        shutil.rmtree(OUT, ignore_errors=True)
    for ptx in ptxs:
        operator, target = ptx.parent.name, ptx.parent.parent.name
        dest = OUT / target / operator
        for stale in dest.glob(f"{ptx.stem}.*"):
            stale.unlink()
        dest.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ptx, dest / ptx.name)
        if operator in NO_LAUNCH_FILE:
            print(f"{ptx.relative_to(RESULTS)}: no launch file, since {NO_LAUNCH_FILE[operator]}")
            continue
        size, launch = launch_file(ptx, operator, target, Result.load(ptx.with_suffix(".result.json")))
        (dest / f"{ptx.stem}.{size}.launch.json").write_text(render(launch))
        print(f"{ptx.relative_to(RESULTS)} -> {(dest / ptx.stem).relative_to(EXTERNAL_ROOT)}.{size}.launch.json")
    print(f"extracted {len(ptxs)} kernels to {OUT.relative_to(EXTERNAL_ROOT.parent.parent)}/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
