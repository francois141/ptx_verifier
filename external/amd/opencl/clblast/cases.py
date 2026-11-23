"""CLBlast's OpenCL kernels for gfx950 (MI355X) checked by Volta: what each case compiles, launches
and checks.

`extract.py` compiles each case and writes its assembly and launch file; `external/amd/verify.py`
runs them. Importable without CLBlast or a compiler.

A case's kernel is one of CLBlast's kernel strings (tag 1.6.3), in the program CLBlast builds for
one routine: its header, the routine's tuning parameters (the database's AMD GPU defaults, as no
gfx950 entry exists) and kernel files. The case dataclasses are `../opencl_common.py`'s.
"""

import sys
from dataclasses import dataclass
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from opencl_common import Array, Case, Pointer, Scalar  # noqa: E402


@dataclass(frozen=True)
class ClBlast:
    """`kernel` of CLBlast's kernel strings `files` (paths under src/kernels/), in the order its
    routine `routine` (`Xgemm`, `Xdot`, ...) concatenates them, after its tuning parameters
    `defines`."""

    files: tuple
    kernel: str
    defines: tuple
    routine: str
    library: str = "CLBlast"

    def origin(self) -> str:
        return f"src/kernels/{self.files[-1]} ({self.kernel}), {self.routine}"


# The AMD GPU defaults of CLBlast's database (src/database/kernels/*/*_32.hpp, vendor "AMD",
# architecture "default", kDeviceNameDefault), which an MI355X, absent from it, is given.
XGEMM_DIRECT_AMD = (("KWID", 2), ("MDIMAD", 8), ("MDIMCD", 8), ("NDIMBD", 8), ("NDIMCD", 8),
                    ("PADA", 1), ("PADB", 1), ("VWMD", 2), ("VWND", 2), ("WGD", 16))
XDOT_AMD = (("WGS1", 256), ("WGS2", 64))
XGEMM_DIRECT_FILES = ("level3/level3.opencl", "level3/xgemm_direct_part1.opencl",
                      "level3/xgemm_direct_part2.opencl", "level3/xgemm_direct_part3.opencl")


# Compiles packed f32 FMAs as two scalar ones, as LLVM's fix for gfx950 (README.md, Bugs) does
# where their op_sel is invalid.
NO_PACKED_FP32 = ("-Xclang", "-target-feature", "-Xclang", "-packed-fp32-ops")


def gemm_direct(name, m, n, k, check="ACCEPT", flags=(), note=""):
    """`clblast::Gemm` column-major, no transposes, alpha 1, beta 0, below the indirect
    kernel's minimum size: `XgemmDirectNT`, as `ProcessArguments` gives a column-major B the
    kernel's transposed reading (it wants B rotated), a WGD x WGD tile of C per workgroup of
    MDIMCD x NDIMCD. K not a multiple of WGD leaves a remainder loop over global memory."""
    wgd = 16
    grid = (-(-m // wgd), -(-n // wgd))
    return Case(
        name=name,
        description=f"GEMM direct (NT kernel), fp32 column-major C[{m}, {n}] = A[{m}, {k}] "
                    f"B[{k}, {n}], 16x16 tiles, workgroups of 8x8{note}",
        source=ClBlast(XGEMM_DIRECT_FILES, "XgemmDirectNT", XGEMM_DIRECT_AMD, "Xgemm"),
        args=(Scalar(m, "kSizeM"), Scalar(n, "kSizeN"), Scalar(k, "kSizeK"),
              Scalar(1.0, "alpha", "f32"), Scalar(0.0, "beta", "f32"), Pointer("a"),
              Scalar(0, "a_offset"), Scalar(m, "a_ld"), Pointer("b"), Scalar(0, "b_offset"),
              Scalar(k, "b_ld"), Pointer("c"), Scalar(0, "c_offset"), Scalar(m, "c_ld"),
              Scalar(0, "c_transpose"), Scalar(0, "a_conjugate"), Scalar(0, "b_conjugate")),
        arrays=(Array("a", "in", "f32", (k, m)), Array("b", "in", "f32", (n, k)),
                Array("c", "out", "f32", (n, m))),
        grid=grid,
        block=(8, 8),
        check=check,
        spec="gemm_colmajor.spec",
        dims={"M": m, "N": n, "K": k},
        flags=flags,
    )


def dot_stage(name, kernel, n=0, check="ACCEPT"):
    """`clblast::Dot` / `Nrm2` / `Asum` on fp32 vectors with unit increments: `Xdot` / `Xnrm2` /
    `Xasum` (2 * WGS2 workgroups of WGS1, each striding over the vectors by WGS1 times their count
    and reducing in LDS to one partial) or the dot product's one-workgroup epilogue, which folds
    the 2 * WGS2 partials. `Xnrm2Epilogue` is not here: its square root's denormal scaling is a
    scalar select on a lane's comparison (`s_cselect` on SCC), which Volta keeps concrete."""
    routine = next(r for r in ("Xnrm2", "Xasum", "Xdot") if kernel.startswith(r))
    files = (f"level1/{routine.lower()}.opencl",)
    groups = 2 * 64
    if kernel in ("Xnrm2", "Xasum"):
        return Case(
            name=name,
            description=f"{'sum of squares (nrm2)' if kernel == 'Xnrm2' else 'absolute sum (asum)'} "
                        f"stage 1, fp32 n={n}, {groups} workgroups of 256",
            source=ClBlast(files, kernel, XDOT_AMD, routine),
            args=(Scalar(n, "n"), Pointer("x"), Scalar(0, "x_offset"), Scalar(1, "x_inc"),
                  Pointer("partial")),
            arrays=(Array("x", "in", "f32", (n,)), Array("partial", "out", "f32", (1,))),
            grid=groups,
            block=256,
            check=check,
            spec=f"{kernel.lower()}_partial.spec",
            dims={"N": n, "B": 256, "S": 256 * groups, "R": 1},
        )
    if kernel == "Xdot":
        return Case(
            name=name,
            description=f"dot product stage 1, fp32 n={n}, {groups} workgroups of 256",
            source=ClBlast(files, kernel, XDOT_AMD, routine),
            args=(Scalar(n, "n"), Pointer("x"), Scalar(0, "x_offset"), Scalar(1, "x_inc"),
                  Pointer("y"), Scalar(0, "y_offset"), Scalar(1, "y_inc"), Pointer("partial"),
                  Scalar(0, "do_conjugate")),
            arrays=(Array("x", "in", "f32", (n,)), Array("y", "in", "f32", (n,)),
                    Array("partial", "out", "f32", (1,))),
            grid=groups,
            block=256,
            check=check,
            spec="dot_partial.spec",
            dims={"N": n, "B": 256, "S": 256 * groups, "R": 1},
        )
    return Case(
        name=name,
        description=f"dot product epilogue, fp32, {groups} partials, one workgroup of 64",
        source=ClBlast(files, kernel, XDOT_AMD, routine),
        args=(Pointer("partial"), Pointer("result"), Scalar(0, "offset")),
        arrays=(Array("partial", "in", "f32", (groups,)), Array("result", "out", "f32", (1,))),
        grid=1,
        block=64,
        check=check,
        spec="dot_epilogue.spec",
        dims={"P": groups, "R": 1},
    )


CASES = (
    gemm_direct("gemm_direct", 16, 16, 40, check="ABORT"),
    gemm_direct("gemm_direct_fixed", 16, 16, 40, flags=NO_PACKED_FP32,
                note=", packed f32 FMAs split"),
    dot_stage("dot", "Xdot", n=40000),
    dot_stage("dot_epilogue", "XdotEpilogue"),
    dot_stage("nrm2", "Xnrm2", n=40000),
    dot_stage("asum", "Xasum", n=40000),
)
