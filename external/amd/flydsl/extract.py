#!/usr/bin/env python3
"""Compile cases.py's FlyDSL kernels for gfx950 and write each case's assembly and launch file.

    python3 external/amd/flydsl/extract.py [--rebuild-image] [CASE...]

FlyDSL ships only Linux x86-64 wheels, so the compiler runs in a `linux/amd64` Docker container
(`python:3.12-slim` with `flydsl==0.5.1` and CPU-only torch, built once as `volta-flydsl:0.5.1`),
from a checkout of FlyDSL at `FLYDSL_COMMIT` in `target/flydsl/FlyDSL`. FlyDSL compiles without a
GPU (`COMPILE_ONLY=1`, `FLYDSL_GPU_ARCH=gfx950`) and dumps the final ISA
(`FLYDSL_DEBUG_DUMP_ASM=1`). Each case compiles in a process of its own, against a copy of
FlyDSL's `kernels` with the case's fixes applied when it has any. The output is deterministic.

For each case it writes, beside this script, `<case>.s` (unless the case reuses another's
assembly) and `<case>.launch.json`, whose parameters lay out the kernel-argument bytes the
compiled kernel's metadata describes: each tensor's address and dynamic layout (its shapes as
i32s, then its strides but the unit one as i64s, as `flydsl.compiler.jit_argument` packs them),
each scalar, and the hidden arguments (the grid's block counts and the group sizes).

The script re-executes itself inside the container with `--inside`; Docker must be running
(Colima shares only the home directory, where the repository is).
"""

import argparse
import json
import os
import re
import shutil
import struct
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[2]
WORK = REPO / "target" / "flydsl"
FLYDSL_URL = "https://github.com/ROCm/FlyDSL.git"
FLYDSL_COMMIT = "304d441202a30e524971a0de49233121e5d17a51"
IMAGE = "volta-flydsl:0.5.1"
DOCKERFILE = """\
FROM python:3.12-slim
RUN pip install --no-cache-dir flydsl==0.5.1 numpy \\
 && pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu
"""

sys.path.insert(0, str(ROOT))
import cases as registry  # noqa: E402
from cases import Pointer, Scalar, Tensor  # noqa: E402


def run(*command, **kwargs):
    print("+", " ".join(str(c) for c in command), flush=True)
    subprocess.run(command, check=True, **kwargs)


# ===== Inside the container =====

COMPILE = """
import os, sys
sys.path.insert(0, {root!r})
import torch
import flydsl.expr as fx
exec(compile({build!r}, {name!r}, "exec"))
"""


def inside(out: Path, names: list[str]) -> None:
    """Compile each case in a fresh process and copy its final ISA to `out`."""
    by_name = {case.name: case for case in registry.CASES}
    for name in names:
        case = by_name[name]
        root = Path("/flydsl")
        if case.fixes:
            root = Path(f"/tmp/fixed/{name}")
            shutil.rmtree(root, ignore_errors=True)
            shutil.copytree("/flydsl/kernels", root / "kernels")
            for fix in case.fixes:
                path = root / fix.path
                text = path.read_text()
                if text.count(fix.old) != 1:
                    sys.exit(f"{name}: the fix's text occurs {text.count(fix.old)} times in {fix.path}")
                path.write_text(text.replace(fix.old, fix.new))
        dump = Path(f"/tmp/dump/{name}")
        shutil.rmtree(dump, ignore_errors=True)
        env = dict(os.environ, FLYDSL_GPU_ARCH="gfx950", COMPILE_ONLY="1", FLYDSL_DEBUG_DUMP_ASM="1",
                   FLYDSL_DUMP_DIR=str(dump), FLYDSL_RUNTIME_ENABLE_CACHE="0")
        script = COMPILE.format(root=str(root), build=case.build, name=name)
        subprocess.run([sys.executable, "-c", script], check=True, env=env, cwd="/tmp")
        isas = sorted(dump.glob("*/*_final_isa.s"))
        if len(isas) != 1:
            sys.exit(f"{name}: expected one compiled kernel, found {[str(i) for i in isas]}")
        shutil.copy(isas[0], out / f"{name}.s")
        print(f"compiled {name}", flush=True)


# ===== Outside: the container, then the launch files =====

def ensure_image(rebuild: bool) -> None:
    present = subprocess.run(["docker", "image", "inspect", IMAGE], capture_output=True)
    if present.returncode == 0 and not rebuild:
        return
    run("docker", "build", "--platform", "linux/amd64", "-t", IMAGE, "-", input=DOCKERFILE.encode())


def ensure_checkout() -> Path:
    checkout = WORK / "FlyDSL"
    if not checkout.exists():
        run("git", "clone", "--quiet", FLYDSL_URL, str(checkout))
    run("git", "-C", str(checkout), "checkout", "--quiet", FLYDSL_COMMIT)
    return checkout


def compile_in_docker(checkout: Path, names: list[str]) -> Path:
    out = WORK / "out"
    out.mkdir(parents=True, exist_ok=True)
    run(
        "docker", "run", "--rm", "--platform", "linux/amd64",
        "-v", f"{checkout}:/flydsl:ro",
        "-v", f"{out}:/out",
        "-v", f"{ROOT}:/volta/external/amd/flydsl:ro",
        IMAGE, "python", "/volta/external/amd/flydsl/extract.py", "--inside", *names,
    )
    return out


def kernel_metadata(assembly: str, symbol: str | None) -> dict:
    """The `amdhsa.kernels` entry of `symbol`, or of the only kernel: its name, kernarg size
    and arguments (offset, size, value kind) in order."""
    metadata = assembly[assembly.index("amdhsa.kernels:"):]
    kernels = []
    for block in re.split(r"\n  - ", metadata)[1:]:
        if "\n    .args:" not in block:
            continue
        name = re.search(r"\n    \.name:\s+(\S+)", "\n    " + block)
        args = []
        args_text = block.split(".args:", 1)[1].split("\n    .", 1)[0]
        for item in re.split(r"\n      - ", args_text)[1:]:
            fields = dict(re.findall(r"\.(\w+):\s+(\S+)", item))
            args.append((int(fields["offset"]), int(fields["size"]), fields["value_kind"]))
        size = int(re.search(r"\.kernarg_segment_size:\s+(\d+)", block).group(1))
        kernels.append({"name": name.group(1), "args": args, "kernarg_size": size})
    chosen = [k for k in kernels if symbol is None or k["name"].startswith(symbol)]
    if len(chosen) != 1:
        sys.exit(f"expected one kernel named {symbol!r}, found {[k['name'] for k in kernels]}")
    return chosen[0]


def layout_words(tensor: Tensor, size: int) -> list[int]:
    """The tensor's layout as FlyDSL packs it, in the `size` bytes the kernel declares."""
    shapes = list(tensor.shape)
    strides = [s for s, axis in zip(tensor.layout_strides(), range(len(shapes))) if s != 1]
    candidates = {
        4 * len(shapes) + 8 * len(strides): shapes + [w for s in strides for w in (s & 0xFFFFFFFF, s >> 32)],
        4 * len(shapes) + 4 * len(strides): shapes + strides,
        4 * len(shapes): shapes,
        0: [],
    }
    if size not in candidates:
        sys.exit(f"no layout of {tensor} takes {size} bytes")
    return candidates[size]


def kernarg_params(case, kernel: dict) -> list[dict]:
    """Launch-file parameters covering every kernel-argument byte the metadata describes."""
    size = kernel["kernarg_size"]
    data = bytearray(size + (-size) % 4)
    labels = ["padding"] * (len(data) // 4)
    pointers = {}

    def put(offset, raw, label):
        data[offset:offset + len(raw)] = raw
        for word in range(offset // 4, (offset + len(raw) + 3) // 4):
            labels[word] = label

    args = list(case.args)
    metadata = list(kernel["args"])
    hidden = {
        "hidden_block_count_x": case.grid[0], "hidden_block_count_y": case.grid[1],
        "hidden_block_count_z": case.grid[2], "hidden_group_size_x": case.block,
        "hidden_group_size_y": 1, "hidden_group_size_z": 1, "hidden_grid_dims": 3,
    }
    while metadata:
        offset, width, kind = metadata.pop(0)
        if kind.startswith("hidden_"):
            put(offset, hidden.get(kind, 0).to_bytes(width, "little"), kind)
            continue
        if not args:
            sys.exit(f"{case.name}: the kernel takes more arguments than the case gives")
        arg = args.pop(0)
        if isinstance(arg, (Tensor, Pointer)):
            if kind != "global_buffer" or width != 8:
                sys.exit(f"{case.name}: {arg} meets a {width}-byte {kind} argument")
            pointers[offset] = arg.array
            labels[offset // 4] = labels[offset // 4 + 1] = f"{arg.array} pointer"
            if isinstance(arg, Tensor):
                layout_size = 0
                if metadata and metadata[0][2] == "by_value" and metadata[0][0] == offset + 8:
                    layout_size = metadata[0][1]
                words = layout_words(arg, layout_size)
                if layout_size:
                    layout_offset, _, _ = metadata.pop(0)
                    put(layout_offset, struct.pack(f"<{len(words)}I", *words), f"{arg.array} layout")
        else:
            if kind != "by_value" or width != 4:
                sys.exit(f"{case.name}: {arg} meets a {width}-byte {kind} argument")
            raw = struct.pack("<f" if arg.kind == "f32" else "<i", arg.value)
            put(offset, raw, arg.name or "scalar")
    if args:
        sys.exit(f"{case.name}: the kernel takes fewer arguments than the case gives")

    params, word = [], 0
    while word < len(labels):
        if word * 4 in pointers:
            params.append({"name": labels[word], "ptr": pointers[word * 4]})
            word += 2
            continue
        value = struct.unpack_from("<i", data, word * 4)[0]
        params.append({"name": labels[word], "int": value})
        word += 1
    return params


def launch_file(case, kernel: dict) -> dict:
    launch = {
        "description": f"FlyDSL {case.source}: {case.description}. Generated by "
                       f"external/amd/flydsl/extract.py.",
        "kernel": kernel["name"],
        "grid": list(case.grid),
        "block": case.block,
        "arrays": [],
        "params": kernarg_params(case, kernel),
    }
    for array in case.arrays:
        entry = {"name": array.name, "kind": array.kind, "dtype": array.dtype, "shape": list(array.shape)}
        if array.contents is not None:
            entry["contents"] = list(array.contents)
        launch["arrays"].append(entry)
    if case.spec:
        launch["spec"] = case.spec
        launch["dims"] = case.dims
    return launch


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--inside", action="store_true", help=argparse.SUPPRESS)
    parser.add_argument("--rebuild-image", action="store_true", help="rebuild the Docker image")
    parser.add_argument("cases", nargs="*", help="cases to extract (default: all)")
    args = parser.parse_args()
    if args.inside:
        inside(Path("/out"), args.cases)
        return 0

    selected = [c for c in registry.CASES if not args.cases or c.name in args.cases]
    if args.cases and len(selected) != len(args.cases):
        sys.exit(f"unknown cases: {set(args.cases) - {c.name for c in selected}}")
    to_compile = [c.name for c in selected if not c.assembly]
    for name in {c.assembly for c in selected if c.assembly} - set(to_compile):
        if not (ROOT / f"{name}.s").exists():
            to_compile.append(name)

    if to_compile:
        ensure_image(args.rebuild_image)
        checkout = ensure_checkout()
        out = compile_in_docker(checkout, to_compile)
        for name in to_compile:
            header = (f"; FlyDSL {FLYDSL_COMMIT[:12]} {registry_case(name).source}, compiled for gfx950 by\n"
                      f"; external/amd/flydsl/extract.py (case {name}).\n")
            (ROOT / f"{name}.s").write_text(header + (out / f"{name}.s").read_text())
            print(f"wrote {name}.s")
    for case in selected:
        kernel = kernel_metadata((ROOT / f"{case.assembly_name()}.s").read_text(), case.symbol)
        path = ROOT / f"{case.name}.launch.json"
        path.write_text(json.dumps(launch_file(case, kernel), indent=2) + "\n")
        print(f"wrote {path.name}")
    return 0


def registry_case(name):
    return next(c for c in registry.CASES if c.name == name)


if __name__ == "__main__":
    sys.exit(main())
