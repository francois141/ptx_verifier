# /// script
# requires-python = ">=3.10"
# ///
"""Compile the CUTLASS units to PTX and write their Volta launch files.

    uv run external/ptx/extraction/cutlass.py                  # every unit
    uv run external/ptx/extraction/cutlass.py gemm_bf16_tn     # the units whose name contains it
    uv run external/ptx/extraction/cutlass.py --jobs 2

Each `external/ptx/cutlass/units/<unit>.cu` instantiates one CUTLASS kernel configuration and,
as a host program, builds its `Params` with CUTLASS's own `to_underlying_arguments` (or a
2.x adapter's `initialize`) over fake device pointers, writing one launch file per problem
it names (`harness/volta_launch.h`: the TMA encoders are stand-ins that record their
arguments, so no GPU or driver is needed). The unit compiles with nvcc 12.9 for sm_100a
in the ThunderKittens image (`extraction/thunderkittens.py` builds it), from CUTLASS at the
commit `sources/frameworks.txt` pins (`fetch_sources.py cutlass`). Its PTX lands in
`external/ptx/cutlass/<unit>.ptx` and each launch file beside it as
`<unit>.<case>.launch.json`, the kernel named by the PTX's one entry; `races.py --framework
cutlass` checks them. `--patched` builds the units against CUTLASS with `FIXES` applied (a
copy of CUTLASS's include tree with the fixes, compiled in its place) into
`external/ptx/cutlass/patched/`: the
controls of `cutlass/bugs.txt`, which `eval_table.py` does not count.
"""

import argparse
import json
import re
import shutil
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

EXTERNAL_ROOT = Path(__file__).resolve().parent.parent
REPO_ROOT = EXTERNAL_ROOT.parent.parent
CUTLASS = REPO_ROOT / "target" / "ptx-sources" / "cutlass"
HERE = EXTERNAL_ROOT / "cutlass"
BUILD = REPO_ROOT / "target" / "cutlass-build"
DOCKER_IMAGE = "volta-thunderkittens:cuda-12.9.1"
ENTRY = re.compile(r"^\.(?:visible |weak )?entry (\S+?)\(", re.MULTILINE)
PATCHED_INCLUDE = BUILD / "patched-include"
# cutlass/bugs.txt's fixes, as (header under include/, text, replacement, count).
TMA_STORE_ONE_LANE = ("    bool issue_tma_store = warp_idx == 0;\n",
                      "    bool issue_tma_store = (warp_idx == 0) && cute::elect_one_sync();\n")
FIXES = [("cutlass/epilogue/collective/sm100_epilogue_tma_warpspecialized.hpp", *TMA_STORE_ONE_LANE, 2)]

NVCC = ("nvcc -std=c++17 -arch=sm_100a -O3 -DNDEBUG --expt-relaxed-constexpr -w "
        "-DCUTLASS_ENABLE_DIRECT_CUDA_DRIVER_CALL -DCUTLASS_ENABLE_GDC_FOR_SM100=1 "
        "-I{include} -I{c}/tools/util/include -I{c}/examples/common -I{c}/examples/77_blackwell_fmha "
        "-Iexternal/ptx/cutlass/harness "
        "--keep --keep-dir {b} -o {b}/gen external/ptx/cutlass/units/{u}.cu")


def write_patched_include() -> None:
    """CUTLASS's include tree with `FIXES` applied, under `PATCHED_INCLUDE` (quoted includes
    resolve beside the including header, so a fixed header must replace the original)."""
    shutil.rmtree(PATCHED_INCLUDE, ignore_errors=True)
    shutil.copytree(CUTLASS / "include", PATCHED_INCLUDE)
    for header, old, new, count in FIXES:
        text = (CUTLASS / "include" / header).read_text()
        if text.count(old) != count:
            sys.exit(f"{header}: expected {count} occurrence(s) of {old.strip()!r}")
        target = PATCHED_INCLUDE / header
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text.replace(old, new))


def build(unit: str, patched: bool = False) -> str:
    """Compile `unit` and run it in the container; the error, if any."""
    dest = HERE / "patched" if patched else HERE
    out = BUILD / ("patched" if patched else "") / unit
    shutil.rmtree(out, ignore_errors=True)
    (out / "launch").mkdir(parents=True)
    rel = lambda p: p.relative_to(REPO_ROOT).as_posix()  # noqa: E731
    include = rel(PATCHED_INCLUDE) if patched else f"{rel(CUTLASS)}/include"
    script = (NVCC.format(c=rel(CUTLASS), include=include, b=rel(out), u=unit)
              + f" && {rel(out)}/gen {rel(out)}/launch")
    run = subprocess.run(["docker", "run", "--rm", "-v", f"{REPO_ROOT}:/volta", "-w", "/volta",
                          DOCKER_IMAGE, "bash", "-c", script], capture_output=True, text=True)
    if run.returncode != 0:
        errors = [line for line in (run.stdout + run.stderr).splitlines()
                  if "error" in line or "volta_launch" in line]
        return "\n".join(errors[:6]) or run.stderr[-800:]
    ptx_files = sorted(out.glob("*.compute_100a.ptx"))
    if not ptx_files:
        return "no compute_100a PTX"
    ptx = ptx_files[0].read_text()
    entries = ENTRY.findall(ptx)
    if len(entries) != 1:
        return f"{len(entries)} entries in the PTX"
    dest.mkdir(exist_ok=True)
    (dest / f"{unit}.ptx").write_text(ptx)
    for old in dest.glob(f"{unit}.*.launch.json"):
        old.unlink()
    for case in sorted((out / "launch").glob("*.launch.json")):
        launch = json.loads(case.read_text())
        launch["kernel"] = entries[0]
        if patched and "spec" in launch:
            launch["spec"] = "../" + launch["spec"]
        if patched:
            launch["description"] += ", with the cutlass/bugs.txt fix"
        (dest / f"{unit}.{case.name}").write_text(json.dumps(launch, indent=2) + "\n")
    return ""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("names", nargs="*", help="substrings of the units to build (default: all)")
    parser.add_argument("--jobs", type=int, default=3, help="units compiled at once (nvcc is memory hungry)")
    parser.add_argument("--patched", action="store_true", help="build against CUTLASS with FIXES applied")
    args = parser.parse_args()
    if not CUTLASS.exists():
        sys.exit("no CUTLASS checkout: uv run external/ptx/extraction/fetch_sources.py cutlass")
    units = sorted(p.stem for p in (HERE / "units").glob("*.cu"))
    units = [u for u in units if not args.names or any(n in u for n in args.names)]
    if args.patched:
        write_patched_include()
    failed = 0
    with ThreadPoolExecutor(args.jobs) as pool:
        for unit, error in zip(units, pool.map(lambda u: build(u, args.patched), units)):
            print(f"{'FAILED' if error else 'ok':6} {unit}" + (f"\n{error}" if error else ""), flush=True)
            failed += bool(error)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
