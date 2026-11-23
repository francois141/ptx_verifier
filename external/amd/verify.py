"""Check the Composable Kernel examples, PyTorch's piecewise activations and FlyDSL's attention.

    uv run --reinstall-package volta --package volta python external/amd/verify.py \
        [--verbose] [PREFIX]

A PREFIX runs only the cases whose launch file starts with it (`activations`), and `--checker`
only those the canonical solver (`solver`) or Lean (`lean`) decides. Each case is a
kernel `composable_kernel/<kernel>.s` (compiled from the `.hip` beside it) and a launch file
`composable_kernel/<case>.launch.json` naming its spec, CK's activations under
`composable_kernel/activations*/`; PyTorch's continuous piecewise activations are likewise in
`external/activation/`, the cases named `activation/<case>`, compiled for AMD and, as
`activation/<case>_ptx`, from CUDA to PTX. Triton's tutorial kernels, compiled for gfx950, are in
`triton/`, the cases named `triton/<case>`.
FlyDSL's gfx950 flash attention is in `flydsl/` (cases `flydsl/<case>`, compiled by
`flydsl/extract.py`), with bf16 arrays, Aiter's kernels in `aiter/` (cases `aiter/<case>`,
compiled by `aiter/build.py`) and HipKittens' kernels in `hipkittens/` (cases
`hipkittens/<case>`, compiled by `hipkittens/compile.py`). MIOpen's and CLBlast's OpenCL
kernels are in `opencl/miopen/` and `opencl/clblast/` (cases `opencl/<library>/<case>`,
compiled by each folder's `extract.py`). Each case prints one
line when it finishes: PASS if its kernel verified (ACCEPT, or every output proved in Lean),
else FAIL, noting when a verdict other than ACCEPT is the case's expected one, such as a known
bug's REJECT. `--verbose` also prints Volta's log of each case as it runs, then a summary.

Some cases are verified in Lean instead, with no canonical solver. CK's fused GEMM-sigmoid is not
exactly its formula over the reals (its exp rescales by f32(e^-64) past the underflow bound), so
it is proved within a tolerance. The activations that compile to a select the canonical solver
cannot match with their spec's `min` and `max` are proved equal. Claude Code writes each proof
into `target/lean/<case>/`, which later runs recheck without the agent while the challenge is
unchanged. These cases need Claude Code and `$VOLTA_LEAN_PROJECT`, a Lake project with Mathlib
built, which the environment or the repository's untracked `.env` (a `VOLTA_LEAN_PROJECT=<path>`
line) gives. The exit status is 1 if any case's verdict is not its
expected one.
"""

import argparse
import importlib.util
import json
import logging
import math
import os
import sys
import time
from dataclasses import dataclass
from pathlib import Path

import volta

sys.path.insert(0, str(Path(__file__).resolve().parent / "flydsl"))
import cases as flydsl_cases  # noqa: E402

# Aiter's and HipKittens' registries are also named `cases`, so each is loaded under a module
# name of its own.
_aiter_spec = importlib.util.spec_from_file_location(
    "aiter_cases", Path(__file__).resolve().parent / "aiter" / "cases.py"
)
aiter_cases = importlib.util.module_from_spec(_aiter_spec)
_aiter_spec.loader.exec_module(aiter_cases)
_hipkittens_spec = importlib.util.spec_from_file_location(
    "hipkittens_cases", Path(__file__).resolve().parent / "hipkittens" / "cases.py"
)
hipkittens_cases = importlib.util.module_from_spec(_hipkittens_spec)
_hipkittens_spec.loader.exec_module(hipkittens_cases)
OPENCL_CASES = {}
for _library in ("miopen", "clblast"):
    _spec = importlib.util.spec_from_file_location(
        f"opencl_{_library}_cases", Path(__file__).resolve().parent / "opencl" / _library / "cases.py"
    )
    OPENCL_CASES[_library] = importlib.util.module_from_spec(_spec)
    _spec.loader.exec_module(OPENCL_CASES[_library])

AMD_ROOT = Path(__file__).resolve().parent
CK_ROOT = AMD_ROOT / "composable_kernel"
ACTIVATION_ROOT = AMD_ROOT.parent / "activation"
TRITON_ROOT = AMD_ROOT / "triton"
FLYDSL_ROOT = AMD_ROOT / "flydsl"
AITER_ROOT = AMD_ROOT / "aiter"
HIPKITTENS_ROOT = AMD_ROOT / "hipkittens"
OPENCL_ROOT = AMD_ROOT / "opencl"
REPO_ROOT = AMD_ROOT.parents[1]
LEAN_DIR = REPO_ROOT / "target" / "lean"
LOG = logging.getLogger("verify")

# The launch-file subset these cases use, laid out as `volta_ptx_analysis::LaunchFile` lays
# out arrays without a `base`: in order from 0x10000, each on the first 64 KiB boundary past
# the arrays before it.
ARRAY_ALIGN = 0x10000
ELEMENT_BYTES = {"f32": 4, "bf16": 2, "i32": 4}
ARRAY_KINDS = {"in": volta.ArrayKind.Input, "out": volta.ArrayKind.Output}


@dataclass(frozen=True)
class Solve:
    """The canonical solver's verdict against the spec must be `expected`."""

    expected: str


@dataclass(frozen=True)
class Race:
    """With no spec, the graph checks alone must conclude `expected` ("VERIFIED" or "REJECTED")."""

    expected: str


@dataclass(frozen=True)
class Abort:
    """The run must stop with an execution error, such as an access outside every array."""


@dataclass(frozen=True)
class Prove:
    """Every output must be proved in Lean equal to the spec, or within `tolerance` of it."""

    tolerance: str | None = None

    def claim(self) -> str:
        return "exactly" if self.tolerance is None else f"within {self.tolerance}"


@dataclass(frozen=True)
class Case:
    """`launch` and `kernel` are paths without extension, from `root`; `extension` is the
    kernel's, which chooses its ISA."""

    launch: str
    kernel: str
    check: Solve | Race | Abort | Prove
    root: Path = CK_ROOT
    extension: str = ".s"
    sample: int = 0

    def name(self) -> str:
        if self.root == CK_ROOT:
            return self.launch
        folder = self.root.relative_to(AMD_ROOT) if self.root.is_relative_to(AMD_ROOT) else self.root.name
        return f"{folder}/{self.launch}"

    def checker(self) -> str:
        return "lean" if isinstance(self.check, Prove) else "solver"

    def describe(self) -> str:
        if isinstance(self.check, Solve):
            return f"canonical solver, expecting {self.check.expected}"
        if isinstance(self.check, Race):
            return f"graph checks, expecting {self.check.expected}"
        if isinstance(self.check, Abort):
            return "execution, expecting an execution error"
        return f"Lean proof {self.check.claim()}"


@dataclass(frozen=True)
class Outcome:
    """Whether the kernel verified, and whether that verdict is the case's expected one."""

    verified: bool
    expected: bool
    detail: str


def flydsl_check(expected: str, spec: str | None) -> "Solve | Race | Abort":
    if expected == "ABORT":
        return Abort()
    return Solve(expected) if spec else Race(expected)


# Hardswish is compiled three ways: plain and -funsafe-math-optimizations keep the selects,
# -ffast-math gives native max and min instructions.
PIECEWISE = (
    "hardtanh",
    "leaky_relu",
    "hardsigmoid",
    "hardswish",
    "hardswish_fast",
    "hardswish_nans",
    "softshrink",
    "elu",
    "celu",
    "selu",
)

# Triton's tutorial kernels.
TRITON = ("vector_add", "softmax", "matmul", "matmul_leaky_relu", "layer_norm")

CASES = (
    Case("ck_gemm", "ck_gemm", Solve("ACCEPT")),
    # Case("ck_fmha", "ck_fmha", Solve("ACCEPT")),
    # Case("ck_fmha_swapped_qk", "ck_fmha", Solve("REJECT")),
    Case("ck_rmsnorm2d", "ck_rmsnorm2d", Solve("ACCEPT")),
    Case("ck_avgpool2d", "ck_avgpool2d", Solve("ACCEPT")),
    # CK's output buffer bound drops four of the nine outputs' stores.
    Case("ck_avgpool2d_larger_output", "ck_avgpool2d", Solve("REJECT")),
    Case("activations/ck_relu", "activations/ck_relu", Solve("ACCEPT")),
    Case("activations/ck_clipped_relu", "activations/ck_clipped_relu", Solve("ACCEPT")),
    Case("activations/ck_sigmoid", "activations/ck_sigmoid", Solve("ACCEPT")),
    Case("activations/ck_logistic", "activations/ck_logistic", Solve("ACCEPT")),
    Case("activations/ck_silu", "activations/ck_silu", Solve("ACCEPT")),
    Case("activations/ck_swish", "activations/ck_swish", Solve("ACCEPT")),
    Case("activations/ck_fast_gelu", "activations/ck_fast_gelu", Solve("ACCEPT")),
    # ROCm/composable_kernel#3763: FastGeluAsm's scratch register shares an input's at -O3.
    Case(
        "activations/ck_fast_gelu_asm", "activations/ck_fast_gelu_asm", Solve("REJECT")
    ),
    Case(
        "activations/ck_fast_gelu_asm_fixed",
        "activations/ck_fast_gelu_asm",
        Solve("ACCEPT"),
    ),
    Case("activations/ck_unary_abs", "activations/ck_unary_abs", Solve("ACCEPT")),
    Case("activations/ck_neg", "activations/ck_neg", Solve("ACCEPT")),
    Case("activations/ck_clamp", "activations/ck_clamp", Solve("REJECT")),
    Case("activations/ck_clamp_fixed", "activations/ck_clamp", Solve("ACCEPT")),
    # AddHardswish's select, which the canonical solver cannot match with the spec's min and max.
    Case("activations/ck_hardswish", "activations/ck_hardswish", Prove()),
    # The same ops without -ffast-math, whose exp keeps its range reduction.
    Case(
        "activations_no_fast_math/ck_relu",
        "activations_no_fast_math/ck_relu",
        Solve("ACCEPT"),
    ),
    Case(
        "activations_no_fast_math/ck_clipped_relu",
        "activations_no_fast_math/ck_clipped_relu",
        Solve("ACCEPT"),
    ),
    Case(
        "activations_no_fast_math/ck_fast_gelu_asm",
        "activations_no_fast_math/ck_fast_gelu_asm",
        Solve("REJECT"),
    ),
    Case(
        "activations_no_fast_math/ck_fast_gelu_asm_fixed",
        "activations_no_fast_math/ck_fast_gelu_asm",
        Solve("ACCEPT"),
    ),
    # Clamp<int, int> clamps through an int8_t reference, so 300 becomes 44.
    Case(
        "activations_no_fast_math/ck_clamp",
        "activations_no_fast_math/ck_clamp",
        Solve("REJECT"),
    ),
    Case(
        "activations_no_fast_math/ck_clamp_fixed",
        "activations_no_fast_math/ck_clamp",
        Solve("ACCEPT"),
    ),
    # LeakyRelu's select between x and alpha x, likewise.
    Case(
        "activations_no_fast_math/ck_leaky_relu",
        "activations_no_fast_math/ck_leaky_relu",
        Prove(),
    ),
    # i4_to_f8x4 converts its high nibbles unshifted, as zeros.
    Case("ck_i4_to_f8x4", "ck_i4_to_f8x4", Solve("REJECT")),
    Case("ck_i4_to_f8x4_fixed", "ck_i4_to_f8x4", Solve("ACCEPT")),
    # cast_tile<bf8_t> encodes with the fp8 (E4M3) instruction.
    Case("ck_cast_tile_bf8", "ck_cast_tile_bf8", Solve("REJECT")),
    Case("ck_cast_tile_bf8_fixed", "ck_cast_tile_bf8", Solve("ACCEPT")),
    # BlockReduce2dCrossWarpSync keeps only lane 0's partial, so every row gets row 0's.
    Case("ck_reduce2d_cross_warp", "ck_reduce2d_cross_warp", Solve("REJECT")),
    # Generic2dBlockShape gives 16-thread rows 4 waves, so workgroup 0 writes rows 0-6, not 0-3.
    Case("ck_rmsnorm2d_rows", "ck_rmsnorm2d_rows", Solve("REJECT")),
    # ImageToColumn copies vectors of 4 channels when a pixel has 3, so they straddle pixels.
    Case("ck_img2col", "ck_img2col", Solve("REJECT")),
    # A model of PermuteWarpGemmCToA's loop, which runs four times past its buffers.
    Case("ck_permute_c_to_a", "ck_permute_c_to_a", Solve("REJECT")),
    Case("ck_permute_c_to_a_fixed", "ck_permute_c_to_a", Solve("ACCEPT")),
    Case("ck_gemm_sigmoid", "ck_gemm_sigmoid", Prove("1/1000")),
    # Legacy CK's cos<double> calls itself, so its kernel compiles to a bare s_endpgm and
    # writes none of its outputs.
    Case(
        "math_double/ck_math_cos_double", "math_double/ck_math_double", Solve("REJECT")
    ),
    # CK Tile's ck_tile::exp<double> does the same.
    Case(
        "math_double/ck_tile_exp_double",
        "math_double/ck_tile_math_double",
        Solve("REJECT"),
    ),
    # FlyDSL's kernels, as flydsl/cases.py lists them.
    *(
        Case(c.name, c.assembly_name(), flydsl_check(c.check, c.spec), FLYDSL_ROOT, sample=c.sample)
        for c in flydsl_cases.CASES
    ),
    # Aiter's kernels, as aiter/cases.py lists them.
    *(
        Case(c.name, c.assembly_name(), flydsl_check(c.check, c.spec), AITER_ROOT, sample=c.sample)
        for c in aiter_cases.CASES
    ),
    # HipKittens' kernels, as hipkittens/cases.py lists them.
    *(
        Case(c.name, c.kernel, flydsl_check(c.check, c.spec), HIPKITTENS_ROOT, sample=c.sample)
        for c in hipkittens_cases.CASES
    ),
    # MIOpen's and CLBlast's OpenCL kernels, as opencl/miopen/cases.py and opencl/clblast/cases.py
    # list them.
    *(
        Case(c.name, c.assembly_name(), flydsl_check(c.check, c.spec), OPENCL_ROOT / library,
             sample=c.sample)
        for library, registry in OPENCL_CASES.items()
        for c in registry.CASES
    ),
    # PyTorch's continuous piecewise activations, each compiled for AMD and, as `<op>_ptx`, to
    # PTX.
    *(Case(op, op, Solve("ACCEPT"), ACTIVATION_ROOT) for op in PIECEWISE),
    *(Case(f"{op}_ptx", op, Solve("ACCEPT"), ACTIVATION_ROOT, ".ptx") for op in PIECEWISE),
    *(Case(kernel, kernel, Solve("ACCEPT"), TRITON_ROOT) for kernel in TRITON),
)


@dataclass(frozen=True)
class Launch:
    kernel: str | None
    config: volta.Config
    spec: str | None
    dims: dict[str, int]


def load_launch(path: Path) -> Launch:
    launch = json.loads(path.read_text(encoding="utf-8"))
    config = volta.Config(
        block=dims3(launch["block"]),
        grid=dims3(launch.get("grid", 1)),
        dynamic_shared_bytes=launch.get("dynamic_shared_bytes", 0),
    )

    next_base = ARRAY_ALIGN
    for array in launch["arrays"]:
        width = ELEMENT_BYTES[array["dtype"]]
        length = math.prod(array["shape"])
        kind = ARRAY_KINDS[array["kind"]]
        config.add_array(volta.ArrayDef(array["name"], next_base, width, length, kind))
        if "contents" in array:
            config.set_contents(array["name"], array["contents"])
        next_base = -(-(next_base + width * length) // ARRAY_ALIGN) * ARRAY_ALIGN

    for param in launch["params"]:
        if "int" in param:
            config.add_param(volta.Param.int(param["int"]))
        elif "float" in param:
            config.add_param(volta.Param.float(param["float"]))
        else:
            config.add_param(volta.Param.array_ptr(param["ptr"]))

    if "spec" not in launch:
        return Launch(launch.get("kernel"), config, None, {})
    spec = (path.parent / launch["spec"]).read_text(encoding="utf-8")
    return Launch(launch.get("kernel"), config, spec, launch["dims"])


def dims3(value: int | list[int]) -> tuple[int, int, int]:
    dims = [value] if isinstance(value, int) else value
    return tuple(dims + [1] * (3 - len(dims)))


def solve(kernel: Path, launch: Launch, check: Solve, sample: int = 0) -> Outcome:
    result = volta.solve(
        kernel, launch.config, kernel=launch.kernel, spec=launch.spec, dims=launch.dims,
        sample=sample,
    )
    verified = result.verdict == "ACCEPT"
    expected = result.verdict == check.expected
    if not expected:
        note = f" (expected {check.expected})"
    elif not verified:
        note = " (expected)"
    else:
        note = ""
    outputs = sum(len(indices) for _, indices in result.output_indices)
    detail = f"{result.verdict}{note} by the canonical solver, {outputs} outputs"
    if not verified and result.evidence:
        detail += f"; {result.evidence[0]}"
    return Outcome(verified, expected, detail)


def race(kernel: Path, launch: Launch, check: Race) -> Outcome:
    result = volta.solve(kernel, launch.config, kernel=launch.kernel)
    verdict = {True: "VERIFIED", False: "REJECTED", None: "NOT RECORDED"}[result.race_verified]
    verified = verdict == "VERIFIED"
    expected = verdict == check.expected
    note = "" if verified else (" (expected)" if expected else f" (expected {check.expected})")
    return Outcome(verified, expected, f"{verdict}{note} by the graph checks")


def abort(kernel: Path, launch: Launch) -> Outcome:
    try:
        result = volta.solve(kernel, launch.config, kernel=launch.kernel)
    except volta.VoltaError as error:
        return Outcome(False, True, f"execution error (expected): {error}")
    return Outcome(result.race_verified is True, False, "ran to completion (expected an execution error)")


def prove(case: Case, kernel: Path, launch: Launch, check: Prove) -> Outcome:
    directory = LEAN_DIR / case.name()
    arguments = {
        "kernel": launch.kernel,
        "spec": launch.spec,
        "dims": launch.dims,
        "tolerance": check.tolerance,
    }
    challenge = directory / "challenge.lean"
    if challenge.exists() and (directory / "proof.lean").exists():
        extraction = volta.extract_lean(kernel, launch.config, **arguments)
        if extraction.lean == challenge.read_text(encoding="utf-8"):
            LOG.info(
                "[lean] challenge unchanged: rechecking the proof in %s", directory
            )
            recheck = volta.check_lean_proof(directory)
            if recheck.proved:
                detail = f"{recheck.proved_statements} of {recheck.statements} proved in Lean"
                detail += f" {check.claim()} (rechecked {directory})"
                return Outcome(True, True, detail)

    LOG.info("[lean] proving with Claude Code into %s", directory)
    result = volta.prove_lean(
        kernel, launch.config, output_dir=directory, equivalence=False, **arguments
    )
    detail = f"{result.proved_statements} of {result.statements} proved in Lean"
    detail += f" {check.claim()} (proof {result.proof})"
    return Outcome(result.proved, result.proved, detail)


def load_dotenv(path: Path) -> None:
    """Set each `NAME=value` line of `path` that the environment does not already set."""
    if not path.exists():
        return
    for line in path.read_text(encoding="utf-8").splitlines():
        name, separator, value = line.partition("=")
        if separator and not name.lstrip().startswith("#"):
            os.environ.setdefault(name.strip(), os.path.expanduser(value.strip()))


def status(passed: bool) -> str:
    """PASS in green or FAIL in red, uncolored unless stdout is a terminal."""
    word, color = ("PASS", 32) if passed else ("FAIL", 31)
    if not sys.stdout.isatty() or "NO_COLOR" in os.environ:
        return word
    return f"\033[{color}m{word}\033[0m"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "prefix",
        nargs="?",
        default="",
        help="run only the cases whose launch file starts with it",
    )
    parser.add_argument(
        "--checker",
        choices=("solver", "lean"),
        help="run only the cases the canonical solver or Lean decides",
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="print Volta's log of each case"
    )
    args = parser.parse_args()
    prefix = args.prefix

    # Volta's Rust logs reach Python's `logging` at info level.
    logging.basicConfig(
        level=logging.INFO if args.verbose else logging.WARNING,
        format="%(asctime)s  %(message)s",
        datefmt="%H:%M:%S",
        stream=sys.stdout,
    )
    load_dotenv(REPO_ROOT / ".env")

    results = []
    for case in CASES:
        if not case.name().startswith(prefix):
            continue
        if args.checker and case.checker() != args.checker:
            continue
        if args.verbose:
            print(f"\n== {case.name()}: {case.describe()}", flush=True)
        kernel = case.root / f"{case.kernel}{case.extension}"
        launch = load_launch(case.root / f"{case.launch}.launch.json")
        start = time.monotonic()
        try:
            if isinstance(case.check, Solve):
                outcome = solve(kernel, launch, case.check, case.sample)
            elif isinstance(case.check, Race):
                outcome = race(kernel, launch, case.check)
            elif isinstance(case.check, Abort):
                outcome = abort(kernel, launch)
            else:
                outcome = prove(case, kernel, launch, case.check)
        except volta.VoltaError as error:
            outcome = Outcome(False, False, f"{type(error).__name__}: {error}")

        seconds = time.monotonic() - start
        line = f"{status(outcome.verified)} {case.name()}: {outcome.detail} ({seconds:.1f}s)"
        print(line, flush=True)
        results.append((outcome.expected, line))

    if not results:
        print(f"no case's launch file starts with {prefix!r}", flush=True)
        return 1
    if args.verbose:
        print("\n== summary", flush=True)
        for _, line in results:
            print(line, flush=True)
    return 0 if all(expected for expected, _ in results) else 1


if __name__ == "__main__":
    sys.exit(main())
