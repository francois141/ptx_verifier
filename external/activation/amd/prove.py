"""Prove in Lean that each AMD kernel with a polynomial approximation is within its tolerance of
its spec.

    uv run --reinstall-package volta --package volta python \
        external/activation/amd/prove.py [-j JOBS] [--max-turns N] [CASE...]

The cases are OCML's tanh, erf GELU and expm1 ELU as OpenCL and Composable Kernel compile them
(`../../approximations/`), and Aiter's `gelu_fast`, whose `fast_tanh` is a Pade approximant
(`../../amd/aiter/`). Volta runs each kernel (EXEC a predicate per lane through OCML's if/else
on the argument), states every output within the case's tolerance of the spec, and a Claude
Code agent proves it into `target/lean/activation_amd/<case>/`; a later run rechecks that proof
without the agent while the challenge is unchanged. Each proved case's `challenge.lean` and
`proof.lean` are copied to `lean/<case>/` here. Lean needs `$VOLTA_LEAN_PROJECT` (or the
repository's `.env`) and Claude Code. The exit status is 1 unless every case is proved.
"""

import argparse
import json
import math
import os
import shutil
import sys
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from pathlib import Path

import volta

ROOT = Path(__file__).resolve().parent
EXTERNAL = ROOT.parents[1]
REPO_ROOT = EXTERNAL.parent
LEAN_DIR = REPO_ROOT / "target" / "lean" / "activation_amd"
ARRAY_ALIGN = 0x10000
ELEMENT_BYTES = {"f32": 4, "bf16": 2, "i32": 4}
ARRAY_KINDS = {"in": volta.ArrayKind.Input, "out": volta.ArrayKind.Output}


@dataclass(frozen=True)
class Case:
    kernel: Path
    launch: Path
    tolerance: str


def opencl(name: str) -> Case:
    return Case(EXTERNAL / f"approximations/opencl/{name}.s", ROOT / f"opencl_{name}.launch.json",
                "1/1000")


def composable_kernel(name: str) -> Case:
    folder = EXTERNAL / "approximations/composable_kernel"
    return Case(folder / f"{name}.s", folder / f"{name}.launch.json", "1/1000")


CASES = {
    "opencl_tanh": opencl("tanh"),
    "opencl_gelu": opencl("gelu"),
    "opencl_elu": opencl("elu"),
    "ck_tanh": composable_kernel("tanh"),
    "ck_gelu": composable_kernel("gelu"),
    "ck_elu": composable_kernel("elu"),
    # fast_tanh saturates at |x| = 3.8, where 1 - tanh(3.8) = 1.0004e-3, past its own 1e-3
    # target; the GELU it feeds is up to 1.62e-3 off (x = -3.24), so 1/1000 is false.
    "aiter_gelu_fast": Case(EXTERNAL / "amd/aiter/activation.s",
                            ROOT / "aiter_gelu_fast.launch.json", "1/500"),
}


def dims3(value) -> tuple[int, int, int]:
    dims = [value] if isinstance(value, int) else list(value)
    return tuple(dims + [1] * (3 - len(dims)))


def load_launch(case: Case) -> tuple[volta.Config, dict]:
    launch = json.loads(case.launch.read_text())
    config = volta.Config(block=dims3(launch["block"]), grid=dims3(launch.get("grid", 1)),
                          dynamic_shared_bytes=launch.get("dynamic_shared_bytes", 0))
    next_base = ARRAY_ALIGN
    for array in launch["arrays"]:
        width = ELEMENT_BYTES[array["dtype"]]
        length = math.prod(array["shape"])
        base = int(str(array["base"]), 0) if "base" in array else next_base
        config.add_array(volta.ArrayDef(array["name"], base, width, length,
                                        ARRAY_KINDS[array["kind"]]))
        next_base = max(next_base, -(-(base + width * length) // ARRAY_ALIGN) * ARRAY_ALIGN)
    for param in launch["params"]:
        if "int" in param:
            config.add_param(volta.Param.int(param["int"]))
        elif "float" in param:
            config.add_param(volta.Param.float(param["float"]))
        else:
            config.add_param(volta.Param.array_ptr(param["ptr"]))
    return config, launch


def prove(name: str, max_turns: int) -> tuple[str, bool, str]:
    case = CASES[name]
    config, launch = load_launch(case)
    arguments = dict(kernel=launch["kernel"],
                     spec=(case.launch.parent / launch["spec"]).read_text(),
                     dims=launch["dims"], tolerance=case.tolerance)
    directory = LEAN_DIR / name
    challenge = directory / "challenge.lean"

    if challenge.exists() and (directory / "proof.lean").exists():
        extraction = volta.extract_lean(case.kernel, config, **arguments)
        if extraction.lean == challenge.read_text():
            recheck = volta.check_lean_proof(directory)
            if recheck.proved:
                keep(name, directory)
                return name, True, f"rechecked {directory}"

    result = volta.prove_lean(case.kernel, config, output_dir=directory, equivalence=False,
                              max_turns=max_turns, **arguments)
    if result.proved:
        keep(name, directory)
    cost = f", ${result.cost_usd:.2f}" if result.cost_usd is not None else ""
    detail = (f"{result.proved_statements} of {result.statements} proved within "
              f"{case.tolerance} in {result.duration_seconds:.0f} s, {result.turns} turns{cost}")
    return name, result.proved, detail


def keep(name: str, directory: Path) -> None:
    saved = ROOT / "lean" / name
    saved.mkdir(parents=True, exist_ok=True)
    for file in ("challenge.lean", "proof.lean"):
        shutil.copyfile(directory / file, saved / file)


def load_dotenv(path: Path) -> None:
    if not path.exists():
        return
    for line in path.read_text().splitlines():
        key, separator, value = line.partition("=")
        if separator and not key.lstrip().startswith("#"):
            os.environ.setdefault(key.strip(), os.path.expanduser(value.strip()))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("cases", nargs="*", default=list(CASES))
    parser.add_argument("--max-turns", type=int, default=150)
    parser.add_argument("-j", "--jobs", type=int, default=4)
    args = parser.parse_args()
    unknown = set(args.cases) - set(CASES)
    if unknown:
        parser.error(f"unknown case(s) {sorted(unknown)}; choose from {list(CASES)}")
    load_dotenv(REPO_ROOT / ".env")

    def attempt(name: str) -> tuple[str, bool, str]:
        try:
            return prove(name, args.max_turns)
        except volta.VoltaError as error:
            return name, False, f"error: {error}"

    with ThreadPoolExecutor(args.jobs) as pool:
        results = list(pool.map(attempt, args.cases))
    for name, proved, detail in results:
        print(f"{'PROVED' if proved else 'NOT PROVED'} {name}: {detail}", flush=True)
    return 0 if all(proved for _, proved, _ in results) else 1


if __name__ == "__main__":
    sys.exit(main())
