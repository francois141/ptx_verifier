#!/usr/bin/env python3
"""Compile cases.py's MIOpen OpenCL kernels for gfx950 (MI355X) and write each case's assembly and launch file.

    python3 external/amd/opencl/miopen/extract.py [--clang PATH] [CASE...]

MIOpen's kernels are `projects/miopen/src/kernels` of ROCm/rocm-libraries at `MIOPEN_TAG`, a sparse
checkout in `target/opencl/rocm-libraries`, fetched on first use. MIOpen builds an OpenCL kernel
through comgr (`src/comgr.cpp`, `BuildOcl`): the solver's `-D` build parameters, then comgr's own
options (`MIOPEN_FLAGS`), linked with ROCm's device libraries, which `../opencl_common.py` fetches
and links as comgr does. Each instruction of its inline asm (the DPP reductions) is replaced by
what LLVM's assembler prints back for it. The output is deterministic.
"""

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT.parent))
sys.path.insert(0, str(ROOT))
import opencl_common as common  # noqa: E402
import cases as registry  # noqa: E402

MIOPEN_URL = "https://github.com/ROCm/rocm-libraries.git"
MIOPEN_TAG = "rocm-7.2.4"
MIOPEN_KERNELS = "projects/miopen/src/kernels"

# comgr's AddCompilerOptions for OpenCL 2.0 (src/comgr.cpp), after the solver's options.
MIOPEN_FLAGS = (
    "-cl-std=CL2.0", "-cl-kernel-arg-info", "-D__IMAGE_SUPPORT__=1", "-D__OPENCL_VERSION__=200",
    "-mllvm", "-amdgpu-early-inline-all", "-mllvm", "-amdgpu-prelink", "-O3",
    "-mllvm", "-amdgpu-internalize-symbols",
)


def ensure_miopen() -> Path:
    checkout = common.WORK / "rocm-libraries"
    if not checkout.exists():
        common.run("git", "clone", "--quiet", "--filter=blob:none", "--no-checkout", MIOPEN_URL,
                   str(checkout))
        common.run("git", "-C", str(checkout), "sparse-checkout", "set", MIOPEN_KERNELS)
    common.run("git", "-C", str(checkout), "checkout", "--quiet", MIOPEN_TAG)
    return checkout / MIOPEN_KERNELS


def program(case, kernels: Path) -> tuple[str, list]:
    """The case's `.cl` file and its options: the solver's build parameters, then comgr's."""
    source = case.source
    options = [f"-D{name}={value}" for name, value in source.defines]
    return (kernels / source.file).read_text(), [*options, f"-I{kernels}", *MIOPEN_FLAGS]


if __name__ == "__main__":
    sys.exit(common.main(__doc__.splitlines()[0], registry.CASES, ROOT, MIOPEN_TAG, ensure_miopen,
                         program))
