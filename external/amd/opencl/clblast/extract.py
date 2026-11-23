#!/usr/bin/env python3
"""Compile cases.py's CLBlast OpenCL kernels for gfx950 (MI355X) and write each case's assembly and launch file.

    python3 external/amd/opencl/clblast/extract.py [--clang PATH] [CASE...]

CLBlast is checked out at `CLBLAST_TAG` in `target/opencl/CLBlast`, fetched on first use. A case's
program is the text CLBlast hands the OpenCL runtime (`clblast_program`), compiled with the options
of ROCm's OpenCL runtime (`CLBLAST_FLAGS`) and linked with ROCm's device libraries, which
`../opencl_common.py` fetches and links as the runtime's comgr does. The output is deterministic.
"""

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT.parent))
sys.path.insert(0, str(ROOT))
import opencl_common as common  # noqa: E402
import cases as registry  # noqa: E402

CLBLAST_URL = "https://github.com/CNugteren/CLBlast.git"
CLBLAST_TAG = "1.6.3"

# clBuildProgram with no options under ROCm's OpenCL runtime (CLR rocclr/device/devprogram.cpp,
# compileImplLC, ProcessOptions and linkImplLC): OpenCL C 1.2 at -O3, whole-program mode.
CLBLAST_FLAGS = ("-cl-std=CL1.2", "-cl-kernel-arg-info", "-O3", "-D__OPENCL_VERSION__=210",
                 "-D__IMAGE_SUPPORT__=1", "-mllvm", "-amdgpu-prelink", "-mllvm",
                 "-amdgpu-internalize-symbols",
                 # The one change: CLR leaves XgemmDirect a function its four entry points call,
                 # which Volta does not follow; inlining it changes no value.
                 "-mllvm", "-inline-threshold=100000")


def ensure_clblast() -> Path:
    checkout = common.WORK / "CLBlast"
    if not checkout.exists():
        common.run("git", "clone", "--quiet", "--depth", "1", "--branch", CLBLAST_TAG,
                   CLBLAST_URL, str(checkout))
    return checkout


def clblast_program(source, clblast: Path) -> str:
    """The program text CLBlast builds for single precision on an AMD GPU: the header of
    `CompileFromSource` (src/utilities/compile.cpp) with `common.opencl`, then the routine's
    tuning parameters and kernel strings (src/routine.cpp), each kernel file without the
    `R"(` ... `)"` raw-string wrapper of its `.opencl` file."""
    def kernel_text(part: str) -> str:
        body = (clblast / "src" / "kernels" / part).read_text()
        start, end = body.index('R"('), body.rindex(')"')
        return body[start + 3:end] + "\n"

    text = (f"#define PRECISION 32\n#define ROUTINE_{source.routine}\n"
            "#define USE_CL_MAD 1\n#define USE_STAGGERED_INDICES 1\n")
    text += kernel_text("common.opencl")
    text += "".join(f"#define {name} {value}\n" for name, value in source.defines)
    return text + "".join(kernel_text(part) for part in source.files)


def program(case, clblast: Path) -> tuple[str, list]:
    return clblast_program(case.source, clblast), list(CLBLAST_FLAGS)


if __name__ == "__main__":
    sys.exit(common.main(__doc__.splitlines()[0], registry.CASES, ROOT, CLBLAST_TAG,
                         ensure_clblast, program))
