# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""Compile the TritonBench-G kernels to PTX for Blackwell (sm_100a).

    uv run external/ptx/extraction/tritonbench.py                   # the files of `SIZES` and `TEST_LAUNCHES`
    uv run external/ptx/extraction/tritonbench.py add_example.py    # some files (names or paths)
    uv run external/ptx/extraction/tritonbench.py --jobs 2 --timeout 600

Each file's own test code runs unchanged as `__main__`, and every Triton launch
it makes is compiled instead of run (`triton_capture.py`). A file of `SIZES`
records only the launches of its sizes, each called through the file's own
wrapper after its test code ran, and each becomes a Volta launch file
`<kernel>.<size>.launch.json` under `external/ptx/tritonbench/<file stem>/`
(with `LAUNCH_KEYS`' block, spec and dims); for any other file, up to three of
its test code's launches, smallest first, become `<kernel>.<i>.launch.json`.
`--summary` (by default `external/ptx/output/tritonbench_extraction.csv`) says
how each file went.
"""

from pathlib import Path

import triton_capture

EXTERNAL_ROOT = Path(__file__).resolve().parent.parent
BENCH_DIR = EXTERNAL_ROOT / "sources" / "TritonBench" / "data" / "TritonBench_G_v1"
# The files Volta checks: size label -> a call of the file's own wrapper, run in its namespace.
# A constexpr size (transpose's matrix, swiglu's n_cols) compiles each size to its own PTX.
# The sizes after the first of a file reproduce a finding (`tritonbench/README.md`).
SIZES = {
    "add_example.py": {f"n{n}": f"add_wrapper(torch.randn({n}), torch.randn({n}))" for n in (16, 64, 256)},
    "matrix_transpose.py": {f"{m}x{d}": f"wrapper({m}, {d})" for m, d in ((16, 16), (32, 32), (32, 64), (64, 64))},
    "swiglu_triton.py": {
        f"{r}x{c}": f"swiglu_backward(torch.randn({r}, {c}), torch.randn({r}, {c}), torch.randn({r}, {c}))"
        for r, c in ((32, 256),)
    },
    "relu_triton_kernel.py": {f"n{n}": f"relu(torch.randn({n}))" for n in (1024, 2048)},
    "triton_softmax.py": {f"1x{n}": f"triton_softmax(torch.randn(1, {n}))" for n in (1000, 2000)},
    "layer_norm_liger.py": {
        f"1x{n}": f"layer_norm_forward(torch.randn(1, {n}), torch.randn({n}), torch.randn({n}), 0.5)"
        for n in (128, 100)
    },
    "ksoftmax_triton.py": {
        f"qk_row{n}": "softmax(torch.empty(1, 2, 8), torch.randn(1, 2, 8), torch.randn(2, 8), mask_type='qk')"
        for n in (0, 1)
    },
    "kldiv_triton.py": {
        f"1x{n}": f"kldiv_forward_triton(torch.randn(1, {n}), torch.rand(1, {n}), False, 'sum')"
        for n in (16384, 16385)
    },
    **{
        name: {"contiguous": f"{call}(torch.randn(4, 8))", "strided": f"{call}(torch.randn(4, 16)[:, :8])"}
        for name, call in (("l2_norm_triton1.py", "_l2_norm_fwd"), ("l2_norm_triton2.py", "_l2_norm_fwd"))
    },
}
LAST_ROW = {"cta": [3, 0, 0]}
LAUNCH_KEYS = {
    "relu_triton_kernel.py": {
        f"n{n}": {"cta": [n // 1024 - 1, 0, 0], "spec": "../specs/relu.spec",
                  "dims": {"N": n, "BS": 1024, "B0": n // 1024 - 1}}
        for n in (1024, 2048)
    },
    "triton_softmax.py": {f"1x{n}": {"spec": "../specs/softmax.spec", "dims": {"R": 1, "N": n}} for n in (1000, 2000)},
    "layer_norm_liger.py": {
        f"1x{n}": {"spec": "../specs/layer_norm.spec", "dims": {"R": 1, "N": n}} for n in (128, 100)
    },
    "ksoftmax_triton.py": {
        f"qk_row{n}": {"cta": [0, n, 0], "spec": "../specs/ksoftmax_qk.spec",
                       "dims": {"B": 1, "R": 2, "K": 8, "B0": 0, "R0": n}}
        for n in (0, 1)
    },
    "l2_norm_triton1.py": {"contiguous": LAST_ROW, "strided": LAST_ROW},
    "l2_norm_triton2.py": {"contiguous": LAST_ROW, "strided": LAST_ROW},
}
# The files Volta checks at their own test code's launches: kernels with a finding, and three controls.
TEST_LAUNCHES = (
    "attention_fwd_triton1.py", "chunk_gla_fwd.py", "chunk_linear_attn.py", "fused_recurrent_hgrn.py",
    "fused_recurrent_retention.py", "nested_loops_processing.py", "parallel_attention.py",
    "log_softmax.py", "rms_norm_triton.py", "softmax_triton2.py",
)

SUITE = triton_capture.Suite(
    name="TritonBench",
    slug="tritonbench",
    script=Path(__file__),
    sources=BENCH_DIR,
    out=EXTERNAL_ROOT / "tritonbench",
    summary=EXTERNAL_ROOT / "output" / "tritonbench_extraction.csv",
    sizes=SIZES,
    triton_version="3.5.1",
    torch_version="2.9.0",
    pip_extras=("numpy",),
    run_as_main=True,
    launch_keys=LAUNCH_KEYS,
)

if __name__ == "__main__":
    triton_capture.main(SUITE, __doc__, sorted({*SIZES, *TEST_LAUNCHES}))
