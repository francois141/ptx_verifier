# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""Compile the TritonBench-G kernels to PTX for Blackwell (sm_100a).

    uv run external/extraction/tritonbench.py                   # the files of `SIZES`
    uv run external/extraction/tritonbench.py add_example.py    # some files (names or paths)
    uv run external/extraction/tritonbench.py --jobs 2 --timeout 600

Each file's own test code runs unchanged as `__main__`, and every Triton launch
it makes is compiled instead of run (`triton_capture.py`). A file of `SIZES`
records only the launches of its sizes, each called through the file's own
wrapper after its test code ran, and each becomes a Volta launch file
`<kernel>.<size>.launch.json` under `external/tritonbench/<file stem>/`; for
any other file, up to three of its test code's launches, smallest first,
become `<kernel>.<i>.launch.json`. `--summary` (by default
`external/output/tritonbench_extraction.csv`) says how each file went.
"""

from pathlib import Path

import triton_capture

EXTERNAL_ROOT = Path(__file__).resolve().parent.parent
BENCH_DIR = EXTERNAL_ROOT / "sources" / "TritonBench" / "data" / "TritonBench_G_v1"
# The files Volta checks: size label -> a call of the file's own wrapper, run in its namespace.
# A constexpr size (transpose's matrix, swiglu's n_cols) compiles each size to its own PTX.
SIZES = {
    "add_example.py": {f"n{n}": f"add_wrapper(torch.randn({n}), torch.randn({n}))" for n in (16, 64, 256)},
    "matrix_transpose.py": {f"{m}x{d}": f"wrapper({m}, {d})" for m, d in ((16, 16), (32, 32), (32, 64), (64, 64))},
    "swiglu_triton.py": {
        f"{r}x{c}": f"swiglu_backward(torch.randn({r}, {c}), torch.randn({r}, {c}), torch.randn({r}, {c}))"
        for r, c in ((32, 256),)
    },
}

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
)

if __name__ == "__main__":
    triton_capture.main(SUITE, __doc__, sorted(SIZES))
