# /// script
# requires-python = ">=3.10"
# ///
"""Compile ThunderKittens' educational GEMM tutorial to PTX for Blackwell (sm_100a).

    uv run external/extraction/thunderkittens.py                 # every level, 01-09
    uv run external/extraction/thunderkittens.py 6 7             # levels 06 and 07
    uv run external/extraction/thunderkittens.py --tutorial educational_h100

Each level is built with the tutorial's own Makefile (`make ptx`, so the
flags and the architecture are those of `kernels/common.mk`), which needs
`nvcc` from CUDA 12.8 or later. nvcc compiles for an explicit target, so no
GPU is needed; without one on the PATH (macOS) the script builds an image
with the CUDA toolkit once, runs itself in a container and copies the PTX
out (`--backend`). The PTX lands in `<out>/<tutorial>/level_NN.ptx` (by
default `external/thunderkittens/`), beside a `.json` summary of what the PTX
itself states about its kernels' launch; the launch files there are kept.
"""

import argparse
import json
import re
import shutil
import subprocess
import sys
import tempfile
import uuid
from pathlib import Path

EXTERNAL_ROOT = Path(__file__).resolve().parent.parent
TK_ROOT = EXTERNAL_ROOT / "sources" / "ThunderKittens"
GEMM_DIR = TK_ROOT / "kernels" / "gemm"
TUTORIALS = ["educational_b200", "educational_h100"]
DEFAULT_OUT = EXTERNAL_ROOT / "thunderkittens"
CUDA_IMAGE = "nvidia/cuda:12.9.1-devel-ubuntu24.04"
DOCKER_IMAGE = "volta-thunderkittens:cuda-12.9.1"
DOCKERFILE = f"""FROM {CUDA_IMAGE}
RUN apt-get update && apt-get install -y --no-install-recommends python3 make && rm -rf /var/lib/apt/lists/*
WORKDIR /work
"""
# What the container needs of the submodule: the headers and the kernels tree (`common.mk`, `gemm/common.cuh`).
TK_PARTS = ["include", "prototype", "kernels"]

ENTRY = re.compile(r"^\.visible \.entry (\S+?)\(", re.MULTILINE)
DIRECTIVE = re.compile(r"^\s*\.(maxntid|reqntid|reqnctapercluster|maxnreg|minnctapersm)\s+([\d, ]+)$", re.MULTILINE)


def levels_of(tutorial: str) -> list[str]:
    return sorted(p.stem.removeprefix("level_") for p in (GEMM_DIR / tutorial).glob("level_*.cu"))


def parse_level(text: str, available: list[str]) -> str:
    level = f"{int(text):02d}" if text.isdigit() else text
    if level not in available:
        sys.exit(f"no level {text!r}: pick among {', '.join(available)}")
    return level


def launch_summary(ptx: str) -> list[dict[str, object]]:
    """Each kernel's name and its launch directives, in source order."""
    kernels = []
    for entry in ENTRY.finditer(ptx):
        header = ptx[entry.start() : ptx.index("{", entry.end())]
        directives = {d: [int(x) for x in v.split(",")] for d, v in DIRECTIVE.findall(header)}
        kernels.append({"kernel": entry.group(1), **directives})
    return kernels


def nvcc_version() -> str:
    output = subprocess.run(["nvcc", "--version"], capture_output=True, text=True, check=True).stdout
    match = re.search(r"release ([\d.]+)", output)
    return match.group(1) if match else output.strip().splitlines()[-1]


def compile_local(tutorial: str, levels: list[str], out: Path) -> None:
    if shutil.which("nvcc") is None:
        sys.exit("nvcc is not on the PATH (use --backend docker)")
    version = nvcc_version()
    out_dir = out / tutorial
    out_dir.mkdir(parents=True, exist_ok=True)
    for level in levels:
        stem = out_dir.resolve() / f"level_{level}"
        build = subprocess.run(
            ["make", "-C", str(GEMM_DIR / tutorial), "ptx", f"LEVEL={level}", f"OUT={stem}"],
            capture_output=True,
            text=True,
        )
        if build.returncode != 0:
            sys.exit(f"level {level} failed to compile:\n{build.stdout}{build.stderr}")
        ptx_path = stem.with_name(f"{stem.name}.ptx")
        ptx = ptx_path.read_text()
        target = re.search(r"^\.target (\S+)", ptx, re.MULTILINE)
        summary = {
            "source": f"kernels/gemm/{tutorial}/level_{level}.cu",
            "nvcc": version,
            "target": target.group(1) if target else None,
            "kernels": launch_summary(ptx),
        }
        ptx_path.with_suffix(".json").write_text(json.dumps(summary, indent=2) + "\n")
        print(f"{tutorial} level {level} -> {ptx_path}")


def docker(*args: str, stdin: str | None = None, quiet: bool = False) -> None:
    result = subprocess.run(["docker", *args], input=stdin, text=True, capture_output=quiet)
    if result.returncode != 0:
        sys.exit(f"docker {args[0]} failed{': ' + result.stderr.strip() if quiet else ''}")


def compile_in_docker(tutorial: str, levels: list[str], out: Path) -> None:
    """Run this script with `--backend local` in a container, then copy its output dir out."""
    if subprocess.run(["docker", "info"], capture_output=True).returncode != 0:
        sys.exit("the Docker daemon is not running (start Docker Desktop, or `colima start`)")
    if subprocess.run(["docker", "image", "inspect", DOCKER_IMAGE], capture_output=True).returncode != 0:
        print(f"building {DOCKER_IMAGE} (once)", file=sys.stderr)
        docker("build", "-t", DOCKER_IMAGE, "-", stdin=DOCKERFILE)
    container = f"volta-thunderkittens-{uuid.uuid4().hex[:12]}"
    script = Path(__file__).resolve()
    command = [
        "python3", f"/work/{script.parent.name}/{script.name}", *levels,
        f"--tutorial={tutorial}", "--backend=local", "--out=/work/out",
    ]
    docker("create", "--name", container, DOCKER_IMAGE, *command, quiet=True)
    try:
        with tempfile.TemporaryDirectory() as staging:
            # `docker cp` creates no parent directories, so `/work` mirrors `external/` whole.
            staged = Path(staging)
            (staged / script.parent.name).mkdir()
            shutil.copy(script, staged / script.parent.name)
            for part in TK_PARTS:
                shutil.copytree(TK_ROOT / part, staged / TK_ROOT.relative_to(EXTERNAL_ROOT) / part)
            docker("cp", f"{staging}/.", f"{container}:/work/", quiet=True)
        docker("start", "--attach", container)
        out.mkdir(parents=True, exist_ok=True)
        docker("cp", f"{container}:/work/out/{tutorial}", str(out), quiet=True)
    finally:
        subprocess.run(["docker", "rm", "--force", container], capture_output=True)
    print(f"copied {tutorial}/ to {out}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("levels", nargs="*", help="levels to compile, e.g. 3 or 03 (default: all)")
    parser.add_argument("--tutorial", choices=TUTORIALS, default=TUTORIALS[0], help=f"default {TUTORIALS[0]}")
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT, help=f"output root (default {DEFAULT_OUT})")
    parser.add_argument(
        "--backend",
        choices=["auto", "local", "docker"],
        default="auto",
        help="where nvcc runs (default: local if it is on the PATH, else docker)",
    )
    args = parser.parse_args()

    if not (GEMM_DIR / args.tutorial).is_dir():
        sys.exit(f"no {GEMM_DIR / args.tutorial}: run `git submodule update --init external/sources/ThunderKittens`")
    available = levels_of(args.tutorial)
    levels = [parse_level(level, available) for level in args.levels] or available
    backend = args.backend
    if backend == "auto":
        backend = "local" if shutil.which("nvcc") else "docker"
    (compile_local if backend == "local" else compile_in_docker)(args.tutorial, levels, args.out)


if __name__ == "__main__":
    main()
