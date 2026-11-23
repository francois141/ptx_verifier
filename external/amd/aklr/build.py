#!/usr/bin/env python3
"""Compile cases.py's AKLR kernels for gfx950 and write each case's assembly and launch file.

    python3 external/amd/aklr/build.py [--clang PATH] [CASE...]

AKLR is checked out at `AKLR_COMMIT` in `target/aklr/AKLR`. Each case's kernel schema stores its
sources; they are written to `target/aklr/build/<case>/` with the case's fixes applied.

- Triton kernels compile in a container (`TRITON_IMAGE`, Triton 3.9 with torch, the one
  `external/gluon` builds; AKLR's kernels require Triton >= 3.8): the script re-executes itself
  there with `--inside`.
- FlyDSL kernels compile in `FLYDSL_IMAGE` (`external/amd/flydsl/extract.py` builds it) with
  `COMPILE_ONLY=1`, the final ISA dumped by `FLYDSL_DEBUG_DUMP_ASM=1`.
- HIP kernels compile with LLVM's clang (`--clang`, by default Homebrew's llvm@21), device only,
  for `gfx950:xnack-` at -O3, against the HIP headers `external/amd/aiter/build.py` assembles in
  `target/aiter/hip`, with `-nogpulib`: a `.hip` file includes Aiter's `prelude.h` for the
  device-library functions its kernel calls (ockl's work-item ids).

Every case's launch file lays out the kernel-argument bytes its compiled metadata describes: each
argument `cases.py` gives, then the hidden arguments (the grid's block counts, the group sizes, the
grid's dimension count; the rest zero). The output is deterministic.
"""

import argparse
import importlib.util
import json
import re
import shutil
import struct
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[2]
WORK = REPO / "target" / "aklr"
AKLR_URL = "https://github.com/AMD-AGI/AKLR.git"
AKLR_COMMIT = "766a200e367fac608a91db74b22e67fbf140397e"
TRITON_IMAGE = "volta-gluon:triton-3.9.0-torch-2.15.0"
FLYDSL_IMAGE = "volta-flydsl:0.5.1"
DEFAULT_CLANG = "/opt/homebrew/opt/llvm@21/bin/clang++"
HIP_FLAGS = ("-O3", "-std=c++20", "-D__HIP_PLATFORM_AMD__=1", "-fgpu-flush-denormals-to-zero")

_spec = importlib.util.spec_from_file_location("aklr_cases", ROOT / "cases.py")
registry = importlib.util.module_from_spec(_spec)
sys.modules["aklr_cases"] = registry
_spec.loader.exec_module(registry)
from aklr_cases import FlyDSL, Hip, Null, Pointer, Scalar, Tensor, Triton  # noqa: E402


def run(*command, **kwargs):
    print("+", " ".join(str(c) for c in command), flush=True)
    subprocess.run(command, check=True, **kwargs)


# ===== Sources =====

def ensure_aklr() -> Path:
    checkout = WORK / "AKLR"
    if not checkout.exists():
        run("git", "clone", "--quiet", AKLR_URL, str(checkout))
    run("git", "-C", str(checkout), "checkout", "--quiet", AKLR_COMMIT)
    return checkout


def write_sources(case, aklr: Path) -> Path:
    """The schema's sources, fixes applied, in `target/aklr/build/<case>/`."""
    schema = json.loads((aklr / case.schema.path()).read_text())
    sources = {s["path"]: s["content"] for s in schema["kernel"]["sources"]}
    for fix in case.fixes:
        text = sources[fix.path]
        if text.count(fix.old) != 1:
            sys.exit(f"{case.name}: the fix's text occurs {text.count(fix.old)} times in {fix.path}")
        sources[fix.path] = text.replace(fix.old, fix.new)
    out = WORK / "build" / case.name
    shutil.rmtree(out, ignore_errors=True)
    for path, text in sources.items():
        (out / path).parent.mkdir(parents=True, exist_ok=True)
        (out / path).write_text(text)
    return out


# ===== Triton, inside the container =====

TRITON_COMPILE = """
import importlib.util, json, sys
from pathlib import Path
import triton
from triton.backends.compiler import GPUTarget
request = json.loads(sys.argv[1])
spec = importlib.util.spec_from_file_location("kernel", request["source"])
module = importlib.util.module_from_spec(spec)
sys.path.insert(0, str(Path(request["source"]).parent))
spec.loader.exec_module(module)
kernel = getattr(module, request["kernel"])
while not isinstance(kernel, triton.runtime.jit.JITFunction):
    kernel = kernel.fn
runtime = [a for i, a in enumerate(kernel.arg_names) if not kernel.params[i].is_constexpr]
if len(runtime) != len(request["args"]):
    sys.exit(f"the kernel's runtime arguments are {runtime}, the case gives {len(request['args'])}")
signature, constexprs, attrs = {}, dict(request["constexprs"]), {}
for index, name in enumerate(kernel.arg_names):
    if kernel.params[index].is_constexpr:
        signature[name] = "constexpr"
        if name not in constexprs and kernel.params[index].has_default:
            constexprs[name] = kernel.params[index].default
        continue
    kind, value = request["args"][runtime.index(name)]
    if kind == "ptr":
        signature[name] = "*" + value
        attrs[(index,)] = [["tt.divisibility", 16], ["tt.pointer_range", 32]]
    elif kind == "i32" and value == 1:
        signature[name] = "constexpr"
        constexprs[name] = 1
    else:
        signature[name] = {"i32": "i32", "i64": "i64", "f32": "fp32"}[kind]
        if kind in ("i32", "i64") and value % 16 == 0:
            attrs[(index,)] = [["tt.divisibility", 16]]
source = triton.compiler.ASTSource(fn=kernel, signature=signature, constexprs=constexprs, attrs=attrs)
compiled = triton.compile(source, target=GPUTarget("hip", "gfx950", 64), options=request["options"])
asm = compiled.asm["amdgcn"].replace("amdgpu9.50-amd-amdhsa-unknown-gfx950", "amdgcn-amd-amdhsa--gfx950")
Path(request["out"]).write_text(asm)
Path(request["out"]).with_suffix(".json").write_text(json.dumps({"shared": compiled.metadata.shared}))
"""

TRITON_DTYPES = {"bf16": "bf16", "f32": "fp32", "i32": "i32"}


def triton_args(case) -> list:
    dtypes = {array.name: array.dtype for array in case.arrays}
    args = []
    for arg in case.args:
        if isinstance(arg, Pointer):
            args.append(("ptr", TRITON_DTYPES[dtypes[arg.array]]))
        elif isinstance(arg, Null):
            args.append(("ptr", "fp32"))
        else:
            args.append((arg.kind, arg.value))
    return args


def inside(names: list[str]) -> None:
    by_name = {case.name: case for case in registry.CASES}
    for name in names:
        case = by_name[name]
        request = json.dumps({"source": f"/work/build/{name}/kernel.py", "kernel": case.build.kernel,
                              "args": triton_args(case), "constexprs": case.build.constexprs,
                              "options": case.build.options, "out": f"/work/out/{name}.s"})
        subprocess.run([sys.executable, "-c", TRITON_COMPILE, request], check=True, cwd="/tmp")
        print(f"compiled {name}", flush=True)


def docker(image: str, *command: str) -> None:
    arch = subprocess.run(["docker", "image", "inspect", image, "--format", "{{.Architecture}}"],
                          capture_output=True, text=True)
    if arch.returncode:
        sys.exit(f"no Docker image {image}: see this script's docstring")
    run("docker", "run", "--rm", "--platform", f"linux/{arch.stdout.strip()}", "-v", f"{WORK}:/work",
        "-v", f"{ROOT}:/volta/external/amd/aklr:ro", image, *command)


def compile_triton(names: list[str]) -> dict:
    (WORK / "out").mkdir(parents=True, exist_ok=True)
    docker(TRITON_IMAGE, "python", "/volta/external/amd/aklr/build.py", "--inside", *names)
    out = WORK / "out"
    return {name: ((out / f"{name}.s").read_text(),
                   json.loads((out / f"{name}.json").read_text())["shared"]) for name in names}


# ===== FlyDSL, inside its container =====

FLYDSL_COMPILE = """
import importlib.util, sys
sys.path.insert(0, {source!r})
spec = importlib.util.spec_from_file_location("kernel", {source!r} + "/kernel.py")
kernel = importlib.util.module_from_spec(spec)
sys.modules["kernel"] = kernel
spec.loader.exec_module(kernel)
import torch
{call}
"""


def inside_flydsl(names: list[str]) -> None:
    import os
    by_name = {case.name: case for case in registry.CASES}
    for name in names:
        case = by_name[name]
        dump = Path(f"/tmp/dump/{name}")
        shutil.rmtree(dump, ignore_errors=True)
        env = dict(os.environ, FLYDSL_GPU_ARCH="gfx950", COMPILE_ONLY="1", FLYDSL_DEBUG_DUMP_ASM="1",
                   FLYDSL_DUMP_DIR=str(dump), FLYDSL_RUNTIME_ENABLE_CACHE="0")
        script = FLYDSL_COMPILE.format(source=f"/work/build/{name}", call=case.build.call)
        subprocess.run([sys.executable, "-c", script], check=True, env=env, cwd="/tmp")
        isas = sorted(dump.glob("*/*_final_isa.s"))
        symbol = case.build.symbol
        chosen = [i for i in isas if symbol is None or symbol in i.name]
        if len(chosen) != 1:
            sys.exit(f"{name}: expected one compiled kernel matching {symbol!r}, found {[i.name for i in isas]}")
        shutil.copy(chosen[0], f"/work/out/{name}.s")
        print(f"compiled {name}", flush=True)


def compile_flydsl(names: list[str]) -> dict:
    (WORK / "out").mkdir(parents=True, exist_ok=True)
    docker(FLYDSL_IMAGE, "python", "/volta/external/amd/aklr/build.py", "--inside-flydsl", *names)
    return {name: ((WORK / "out" / f"{name}.s").read_text(), 0) for name in names}


# ===== HIP =====

SPLICE = re.compile(r"^// aklr: (\S+) (\d+)-(\d+)$", re.MULTILINE)


def compile_hip(case, sources: Path, clang: str) -> str:
    path = ROOT / f"{case.build.source}.hip"
    text = path.read_text()

    def splice(match):
        file, first, last = match.group(1), int(match.group(2)), int(match.group(3))
        lines = (sources / file).read_text().splitlines()[first - 1:last]
        resume = text.count("\n", 0, match.end()) + 2
        return f'#line {first} "{file}"\n' + "\n".join(lines) + f'\n#line {resume} "{path.name}"'

    source = sources / f"{case.name}.hip"
    source.write_text(SPLICE.sub(splice, text))
    out = source.with_suffix(".s")
    hip = WORK.parent / "aiter" / "hip"
    if not (hip / "include" / "hip").exists():
        sys.exit(f"no HIP headers in {hip}: run external/amd/aiter/build.py once to assemble them")
    command = [clang, "-x", "hip", "-w", "--offload-arch=gfx950:xnack-", "--offload-device-only",
               "-nogpulib", f"--hip-path={hip}", "-DNDEBUG", "-g0", "-fno-verbose-asm", *HIP_FLAGS,
               *case.build.flags, f"-I{sources}", f"-I{ROOT.parent / 'aiter'}", "-S", str(source),
               "-o", str(out)]
    print("+ clang", source.name, flush=True)
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode:
        sys.exit(f"{case.name}: clang failed:\n{result.stderr}")
    assembly = out.read_text()
    if "s_swappc_b64" in assembly:
        sys.exit(f"{case.name}: the kernel calls a function -nogpulib does not provide")
    return assembly


# ===== Launch files =====

def kernel_metadata(assembly: str, symbol: str | None) -> dict:
    """The `amdhsa.kernels` entry whose name contains `symbol`, or of the only kernel: its name,
    kernarg size and arguments (offset, size, value kind) in order."""
    metadata = assembly[assembly.index("amdhsa.kernels:"):]
    kernels = []
    for block in re.split(r"\n  - ", metadata)[1:]:
        if "\n    .args:" not in block:
            continue
        name = re.search(r"\n    \.name:\s+(\S+)", "\n    " + block).group(1)
        args = []
        args_text = block.split(".args:", 1)[1].split("\n    .", 1)[0]
        for item in re.split(r"\n      - ", args_text)[1:]:
            fields = dict(re.findall(r"\.(\w+):\s+(\S+)", item))
            args.append((int(fields["offset"]), int(fields["size"]), fields["value_kind"]))
        size = int(re.search(r"\.kernarg_segment_size:\s+(\d+)", block).group(1))
        kernels.append({"name": name, "args": args, "kernarg_size": size})
    chosen = [k for k in kernels if symbol is None or symbol in k["name"]]
    if len(chosen) != 1:
        sys.exit(f"expected one kernel matching {symbol!r}, found {[k['name'] for k in kernels]}")
    return chosen[0]


def dims3(value) -> tuple:
    dims = [value] if isinstance(value, int) else list(value)
    return tuple(dims + [1] * (3 - len(dims)))


def launched_args(case) -> list:
    """The arguments the kernel receives: a Triton integer equal to 1 is a constexpr."""
    if isinstance(case.build, Triton):
        return [a for a in case.args if not (isinstance(a, Scalar) and a.kind == "i32" and a.value == 1)]
    return list(case.args)


def kernarg_params(case, kernel: dict) -> list[dict]:
    """Launch-file parameters covering every kernel-argument byte the metadata describes."""
    # Past the segment's end, zero bytes cover the compiler's scalar loads that over-read it.
    size = kernel["kernarg_size"]
    data = bytearray(size + (-size) % 64)
    labels = ["padding"] * (len(data) // 4)
    pointers = {}

    def put(offset, raw, label):
        data[offset:offset + len(raw)] = raw
        for word in range(offset // 4, (offset + len(raw) + 3) // 4):
            labels[word] = label

    grid, block = dims3(case.grid), dims3(case.block)
    hidden = {
        "hidden_block_count_x": grid[0], "hidden_block_count_y": grid[1],
        "hidden_block_count_z": grid[2], "hidden_group_size_x": block[0],
        "hidden_group_size_y": block[1], "hidden_group_size_z": block[2],
        "hidden_grid_dims": sum(1 for extent in grid if extent > 1) or 1,
    }
    args = launched_args(case)
    metadata = list(kernel["args"])
    while metadata:
        offset, width, kind = metadata.pop(0)
        if kind.startswith("hidden_"):
            put(offset, hidden.get(kind, 0).to_bytes(width, "little"), kind)
            continue
        if not args:
            # Triton's trailing scratch pointers, which these kernels never use.
            if isinstance(case.build, Triton) and kind == "global_buffer":
                put(offset, bytes(width), "scratch pointer")
                continue
            sys.exit(f"{case.name}: the kernel takes more arguments than the case gives")
        arg = args.pop(0)
        if isinstance(arg, Null):
            put(offset, bytes(8), "null pointer")
        elif isinstance(arg, (Pointer, Tensor)):
            if kind != "global_buffer" or width != 8 or offset % 8:
                sys.exit(f"{case.name}: {arg} meets a {width}-byte {kind} argument")
            pointers[offset] = arg.array
            labels[offset // 4] = labels[offset // 4 + 1] = f"{arg.array} pointer"
            if isinstance(arg, Tensor) and metadata and metadata[0][2] == "by_value" \
                    and metadata[0][0] == offset + 8:
                layout_offset, layout_size, _ = metadata.pop(0)
                words = flydsl_layout(arg, layout_size)
                put(layout_offset, struct.pack(f"<{len(words)}I", *words), f"{arg.array} layout")
        else:
            formats = {"i32": "<i", "f32": "<f", "i64": "<q", "f64": "<d"}
            raw = struct.pack(formats[arg.kind], arg.value)
            if kind != "by_value" or width != len(raw):
                sys.exit(f"{case.name}: {arg} meets a {width}-byte {kind} argument")
            put(offset, raw, arg.name or "scalar")
    if args:
        sys.exit(f"{case.name}: the kernel takes fewer arguments than the case gives")

    params, word = [], 0
    while word < len(labels):
        if word * 4 in pointers:
            params.append({"name": labels[word], "ptr": pointers[word * 4]})
            word += 2
            continue
        params.append({"name": labels[word], "int": struct.unpack_from("<i", data, word * 4)[0]})
        word += 1
    return params


def flydsl_layout(tensor: Tensor, size: int) -> list[int]:
    """The tensor's dynamic layout as `flydsl.compiler.jit_argument` packs it in `size` bytes:
    its shapes as i32s, then its strides but the unit one, as i64s or i32s."""
    shapes = list(tensor.shape)
    strides = [s for s in tensor.strides if s != 1]
    candidates = {
        4 * len(shapes) + 8 * len(strides): shapes + [w for s in strides for w in (s & 0xFFFFFFFF, s >> 32)],
        4 * len(shapes) + 4 * len(strides): shapes + strides,
        4 * len(shapes): shapes,
    }
    if size not in candidates:
        sys.exit(f"no layout of {tensor} takes {size} bytes")
    return candidates[size]


def launch_file(case, kernel: dict, shared: int) -> dict:
    launch = {
        "description": f"AKLR {case.schema.id}: {case.description}. Generated by "
                       f"external/amd/aklr/build.py.",
        "kernel": kernel["name"],
        "grid": list(dims3(case.grid)),
        "block": list(dims3(case.block)),
    }
    if shared:
        launch["dynamic_shared_bytes"] = shared
    launch["arrays"] = []
    for array in case.arrays:
        entry = {"name": array.name, "kind": array.kind, "dtype": array.dtype,
                 "shape": list(array.shape)}
        if array.base is not None:
            entry["base"] = hex(array.base)
        if array.contents is not None:
            entry["contents"] = list(array.contents)
        launch["arrays"].append(entry)
    launch["params"] = kernarg_params(case, kernel)
    if case.spec:
        launch["spec"] = case.spec
        launch["dims"] = case.dims
    return launch


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--inside", action="store_true", help=argparse.SUPPRESS)
    parser.add_argument("--inside-flydsl", action="store_true", help=argparse.SUPPRESS)
    parser.add_argument("--clang", default=DEFAULT_CLANG)
    parser.add_argument("cases", nargs="*", help="cases to build (default: all)")
    args = parser.parse_args()
    if args.inside:
        inside(args.cases)
        return 0
    if args.inside_flydsl:
        inside_flydsl(args.cases)
        return 0

    selected = [c for c in registry.CASES if not args.cases or c.name in args.cases]
    if args.cases and len(selected) != len(args.cases):
        sys.exit(f"unknown cases: {set(args.cases) - {c.name for c in selected}}")
    aklr = ensure_aklr()
    to_build = [c for c in selected if not c.assembly]
    sources = {case.name: write_sources(case, aklr) for case in to_build}
    builds = {}  # case name -> (assembly text, dynamic LDS bytes)
    for case in to_build:
        if isinstance(case.build, Hip):
            builds[case.name] = (compile_hip(case, sources[case.name], args.clang), 0)
    triton = [c.name for c in to_build if isinstance(c.build, Triton)]
    if triton:
        builds.update(compile_triton(triton))
    flydsl = [c.name for c in to_build if isinstance(c.build, FlyDSL)]
    if flydsl:
        builds.update(compile_flydsl(flydsl))

    for name, (assembly, shared) in builds.items():
        case = next(c for c in registry.CASES if c.name == name)
        header = (f"; AKLR {AKLR_COMMIT[:12]} {case.schema.path()}, compiled for gfx950 by\n"
                  f"; external/amd/aklr/build.py (case {case.name}).\n")
        if shared:
            header += f"; dynamic LDS: {shared} bytes\n"
        (ROOT / f"{name}.s").write_text(header + assembly)
        print(f"wrote {name}.s")
    for case in selected:
        if case.spec_text is not None:
            (ROOT / case.spec).write_text(case.spec_text)
        assembly = (ROOT / f"{case.assembly_name()}.s").read_text()
        kernel = kernel_metadata(assembly, getattr(case.build, "symbol", None))
        shared = re.search(r"^; dynamic LDS: (\d+) bytes$", assembly, re.MULTILINE)
        shared = int(shared.group(1)) if shared else 0
        path = ROOT / f"{case.name}.launch.json"
        path.write_text(json.dumps(launch_file(case, kernel, shared), indent=2) + "\n")
        print(f"wrote {path.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
