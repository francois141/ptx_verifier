#!/usr/bin/env python3
"""Compile cases.py's Aiter kernels for gfx950 and write each case's assembly and launch file.

    python3 external/amd/aiter/build.py [--clang PATH] [CASE...]

Aiter is checked out at `AITER_COMMIT` (with its Composable Kernel submodule) in
`target/aiter/aiter`, and the HIP and rocPRIM headers of `ROCM_TAG` are assembled in
`target/aiter/hip`, both on first use.

A `Hip` case compiles `<source>.hip` with LLVM's clang (`--clang`, by default Homebrew's
llvm@21: Apple's clang lacks the AMDGPU target), device only, with the flags Aiter's JIT
(aiter/jit/core.py) passes for gfx950 under HIP 7.0 plus the module's own, except that
`-nogpulib` replaces ROCm's device library with `prelude.h` and `NDEBUG` compiles out device
asserts (whose printf the device library would provide). Each `// aiter: <path> <first>-<last>`
line of the `.hip` file is replaced by those lines of Aiter's file, so the kernel text is
Aiter's. A `.hip` file compiles to `<source>.s`; a case with fixes compiles its own `<case>.s`,
a fix of an included header through a fixed copy that shadows the checkout's.

A `Triton` case compiles one of Aiter's Triton kernels in a `linux/amd64` container
(`TRITON_IMAGE`, built once): the script re-executes itself there with `--inside`, imports the
kernel's module without running aiter/__init__.py, and compiles it for `hip`/`gfx950`/wave64.

Every case's launch file lays out the kernel-argument bytes its compiled metadata describes:
each argument `cases.py` gives, then the hidden arguments (the grid's block counts, the group
sizes, the grid's dimension count; the rest zero). The output is deterministic.
"""

import argparse
import json
import re
import shutil
import struct
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[2]
WORK = REPO / "target" / "aiter"
AITER_URL = "https://github.com/ROCm/aiter.git"
AITER_COMMIT = "183a6ce66ebb975223534f3bdeaca4132d2f4530"
ROCM_TAG = "rocm-7.0.2"
HIP_VERSION = (7, 0, 51831)  # ROCm 7.0.2's HIP/VERSION
ROCPRIM_VERSION = (4, 0, 1)  # its rocPRIM CMakeLists.txt VERSION_STRING
DEFAULT_CLANG = "/opt/homebrew/opt/llvm@21/bin/clang++"
TRITON_IMAGE = "volta-aiter-triton:3.5.1"
TRITON_DOCKERFILE = """\
FROM python:3.12-slim
RUN pip install --no-cache-dir triton==3.5.1 numpy
"""

# aiter/jit/core.py's flags_cc and flags_hip for gfx950 under HIP 7.0 (kernarg preload on).
AITER_FLAGS = (
    "-O3", "-std=c++20", "-DLEGACY_HIPBLAS_DIRECT", "-DUSE_PROF_API=1",
    "-D__HIP_PLATFORM_HCC__=1", "-D__HIP_PLATFORM_AMD__=1", "-U__HIP_NO_HALF_CONVERSIONS__",
    "-U__HIP_NO_HALF_OPERATORS__", "-fgpu-flush-denormals-to-zero",
    "-mllvm", "--amdgpu-kernarg-preload-count=32", "-mllvm", "--lsr-drop-solution=1",
    "-fno-offload-uniform-block", "-mllvm", "-enable-post-misched=0",
    "-mllvm", "-amdgpu-early-inline-all=true", "-mllvm", "-amdgpu-function-calls=false",
    "-D__Float4_e2m1fn_x2", "-DENABLE_CK=1", "-DENABLE_ROPE_POSITIONS_INT32=0",
)

sys.path.insert(0, str(ROOT))
import cases as registry  # noqa: E402
from cases import Hip, Null, Pointer, Scalar, Struct, Triton  # noqa: E402


def run(*command, **kwargs):
    print("+", " ".join(str(c) for c in command), flush=True)
    subprocess.run(command, check=True, **kwargs)


# ===== Sources =====

def ensure_aiter() -> Path:
    checkout = WORK / "aiter"
    if not checkout.exists():
        run("git", "clone", "--quiet", "--filter=blob:none", AITER_URL, str(checkout))
    run("git", "-C", str(checkout), "checkout", "--quiet", AITER_COMMIT)
    run("git", "-C", str(checkout), "submodule", "update", "--quiet", "--init", "--depth", "1",
        "3rdparty/composable_kernel")
    return checkout


def ensure_hip() -> Path:
    """HIP's headers with CLR's AMD implementation and rocPRIM's, plus the version files
    their CMake builds would generate."""
    hip = WORK / "hip"
    if (hip / "share" / "hip" / "version").exists():
        return hip
    deps = WORK / "deps"
    for repo in ("HIP", "clr", "rocPRIM"):
        if not (deps / repo).exists():
            run("git", "clone", "--quiet", "--depth", "1", "--branch", ROCM_TAG,
                f"https://github.com/ROCm/{repo}.git", str(deps / repo))
    shutil.rmtree(hip, ignore_errors=True)
    include = hip / "include"
    shutil.copytree(deps / "HIP" / "include" / "hip", include / "hip")
    shutil.copytree(deps / "clr" / "hipamd" / "include" / "hip" / "amd_detail",
                    include / "hip" / "amd_detail")
    shutil.copytree(deps / "rocPRIM" / "rocprim" / "include" / "rocprim", include / "rocprim")
    major, minor, patch = HIP_VERSION
    (include / "hip" / "hip_version.h").write_text(
        "#pragma once\n"
        f"#define HIP_VERSION_MAJOR {major}\n#define HIP_VERSION_MINOR {minor}\n"
        f"#define HIP_VERSION_PATCH {patch}\n#define HIP_VERSION_GITHASH \"\"\n"
        "#define HIP_VERSION_BUILD_ID 0\n#define HIP_VERSION_BUILD_NAME \"\"\n"
        "#define HIP_VERSION (HIP_VERSION_MAJOR * 10000000 + HIP_VERSION_MINOR * 100000"
        " + HIP_VERSION_PATCH)\n#define __HIP_HAS_GET_PCH 0\n")
    version = include / "rocprim" / "rocprim_version.hpp"
    major, minor, patch = ROCPRIM_VERSION
    text = (version.parent / "rocprim_version.hpp.in").read_text()
    for name, value in (("NUMBER", major * 100000 + minor * 100 + patch), ("MAJOR", major),
                        ("MINOR", minor), ("PATCH", patch)):
        text = text.replace(f"@rocprim_VERSION_{name}@", str(value))
    version.write_text(text)
    (version.parent / "rocprim_version.hpp.in").unlink()
    (hip / "share" / "hip").mkdir(parents=True)
    (hip / "share" / "hip" / "version").write_text(
        f"HIP_VERSION_MAJOR={HIP_VERSION[0]}\nHIP_VERSION_MINOR={HIP_VERSION[1]}\n"
        f"HIP_VERSION_PATCH={HIP_VERSION[2]}\n")
    return hip


SPLICE = re.compile(r"^// aiter: (\S+) (\d+)-(\d+)$", re.MULTILINE)


def hip_text(case, aiter: Path) -> str:
    """The case's `.hip` file with Aiter's lines spliced in and its fixes applied."""
    path = ROOT / f"{case.build.source}.hip"
    source = path.read_text()

    def splice(match):
        file, first, last = match.group(1), int(match.group(2)), int(match.group(3))
        lines = (aiter / file).read_text().splitlines()[first - 1:last]
        resume = source.count("\n", 0, match.end()) + 2
        return (f'#line {first} "{file}"\n' + "\n".join(lines)
                + f'\n#line {resume} "{path.name}"')

    text = SPLICE.sub(splice, source)
    return apply_fixes(case, text, [fix for fix in case.fixes if fix.path is None])


def apply_fixes(case, text: str, fixes) -> str:
    for fix in fixes:
        if text.count(fix.old) != 1:
            sys.exit(f"{case.name}: the fix's text occurs {text.count(fix.old)} times")
        text = text.replace(fix.old, fix.new)
    return text


def header_overlay(case, aiter: Path, out: Path) -> list[str]:
    """Include flags putting fixed copies of Aiter's headers before the checkout's own."""
    overlay = out.with_suffix("")
    shutil.rmtree(overlay, ignore_errors=True)
    for path in sorted({fix.path for fix in case.fixes if fix.path}):
        fixed = overlay / path
        fixed.parent.mkdir(parents=True, exist_ok=True)
        fixes = [fix for fix in case.fixes if fix.path == path]
        fixed.write_text(apply_fixes(case, (aiter / path).read_text(), fixes))
    if not overlay.exists():
        return []
    return [f"-I{overlay / 'csrc' / 'include'}", f"-I{overlay / 'csrc' / 'kernels'}"]


def compile_hip(case, clang: str, aiter: Path, hip: Path) -> str:
    out = WORK / "build" / f"{case.assembly_name()}.s"
    source = out.with_suffix(".hip")
    out.parent.mkdir(parents=True, exist_ok=True)
    source.write_text(hip_text(case, aiter))
    command = [
        clang, "-x", "hip", "-w", "--offload-arch=gfx950:xnack-", "--offload-device-only",
        "-nogpulib", f"--hip-path={hip}", "-DNDEBUG", "-g0", "-fno-verbose-asm", *AITER_FLAGS,
        *case.build.flags, f"-I{ROOT}", *header_overlay(case, aiter, out),
        f"-I{aiter / 'csrc' / 'include'}", f"-I{aiter / 'csrc' / 'kernels'}",
        f"-I{aiter / '3rdparty' / 'composable_kernel' / 'include'}", "-S", str(source),
        "-o", str(out),
    ]
    print("+ clang", case.build.source, flush=True)
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode:
        sys.exit(f"{case.name}: clang failed:\n{result.stderr}")
    assembly = out.read_text()
    if "s_swappc_b64" in assembly:
        sys.exit(f"{case.name}: the kernel calls a function -nogpulib does not provide")
    return assembly


# ===== Triton, inside the container =====

TRITON_COMPILE = """
import importlib.util, json, sys, types
from pathlib import Path
import triton
from triton.backends.compiler import GPUTarget
aiter = Path("/aiter/aiter")
for name, path in (("aiter", aiter), ("aiter.ops", aiter / "ops"),
                   ("aiter.ops.triton", aiter / "ops" / "triton")):
    package = types.ModuleType(name)
    package.__path__ = [str(path)]
    sys.modules[name] = package
case = json.loads(sys.argv[1])
module = case["module"].replace("/", ".").removesuffix(".py")
kernel = getattr(importlib.import_module("aiter.ops.triton._triton_kernels." + module), case["kernel"])
kernel = getattr(kernel, "fn", kernel)
signature = {arg: "constexpr" for arg in kernel.arg_names}
signature.update(case["signature"])
# As Triton's launcher specializes them: every pointer, and each integer argument the case names,
# divisible by 16.
divisible = [i for i, arg in enumerate(kernel.arg_names)
             if signature[arg].startswith("*") or arg in case["divisible"]]
attrs = {(i,): [["tt.divisibility", 16]] for i in divisible}
source = triton.compiler.ASTSource(fn=kernel, signature=signature, constexprs=case["constexprs"],
                                   attrs=attrs)
compiled = triton.compile(source, target=GPUTarget("hip", "gfx950", 64), options=case["options"])
Path(sys.argv[2]).write_text(compiled.asm["amdgcn"])
Path(sys.argv[2]).with_suffix(".json").write_text(json.dumps({"shared": compiled.metadata.shared}))
"""


def inside(names: list[str]) -> None:
    by_name = {case.name: case for case in registry.CASES}
    for name in names:
        build = by_name[name].build
        request = json.dumps({"module": build.module, "kernel": build.kernel,
                              "signature": build.signature, "constexprs": build.constexprs,
                              "options": build.options, "divisible": list(build.divisible)})
        subprocess.run([sys.executable, "-c", TRITON_COMPILE, request, f"/out/{name}.s"],
                       check=True, cwd="/tmp")
        print(f"compiled {name}", flush=True)


def compile_triton(names: list[str], aiter: Path) -> dict:
    present = subprocess.run(["docker", "image", "inspect", TRITON_IMAGE], capture_output=True)
    if present.returncode:
        run("docker", "build", "--platform", "linux/amd64", "-t", TRITON_IMAGE, "-",
            input=TRITON_DOCKERFILE.encode())
    out = WORK / "build" / "triton"
    out.mkdir(parents=True, exist_ok=True)
    run("docker", "run", "--rm", "--platform", "linux/amd64", "-v", f"{aiter}:/aiter:ro",
        "-v", f"{out}:/out", "-v", f"{ROOT}:/volta/external/amd/aiter:ro", TRITON_IMAGE,
        "python", "/volta/external/amd/aiter/build.py", "--inside", *names)
    return {name: ((out / f"{name}.s").read_text(),
                   json.loads((out / f"{name}.json").read_text())["shared"]) for name in names}


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
        sys.exit(f"expected one kernel matching {symbol!r}, found {[k['name'] for k in chosen]}")
    return chosen[0]


def dims3(value) -> tuple:
    dims = [value] if isinstance(value, int) else list(value)
    return tuple(dims + [1] * (3 - len(dims)))


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

    def place(offset, arg, kind=None, width=None):
        place_argument(put, pointers, labels, case, offset, arg, kind, width)

    grid, block = dims3(case.grid), dims3(case.block)
    hidden = {
        "hidden_block_count_x": grid[0], "hidden_block_count_y": grid[1],
        "hidden_block_count_z": grid[2], "hidden_group_size_x": block[0],
        "hidden_group_size_y": block[1], "hidden_group_size_z": block[2],
        "hidden_grid_dims": sum(1 for extent in grid if extent > 1) or 1,
    }
    args = list(case.args)
    for offset, width, kind in kernel["args"]:
        if kind.startswith("hidden_"):
            put(offset, hidden.get(kind, 0).to_bytes(width, "little"), kind)
            continue
        if not args:
            sys.exit(f"{case.name}: the kernel takes more arguments than the case gives")
        arg = args.pop(0)
        if isinstance(arg, Struct):
            if kind != "by_value" or width != arg.size:
                sys.exit(f"{case.name}: a {arg.size}-byte struct meets a {width}-byte {kind} argument")
            for field_offset, field in arg.fields:
                place(offset + field_offset, field)
            continue
        place(offset, arg, kind, width)
    if args:
        sys.exit(f"{case.name}: the kernel takes fewer arguments than the case gives")
    return words(data, labels, pointers)


def place_argument(put, pointers, labels, case, offset, arg, kind=None, width=None):
    """Write one pointer, null pointer or scalar at `offset`; `kind` and `width` are the
    metadata's for a whole argument, `None` for a struct field."""
    if isinstance(arg, Null):
        if kind not in (None, "global_buffer") or width not in (None, 8) or offset % 8:
            sys.exit(f"{case.name}: a null pointer meets a {width}-byte {kind} argument")
        put(offset, bytes(8), "null pointer")
        return
    if isinstance(arg, Pointer):
        if kind not in (None, "global_buffer") or width not in (None, 8) or offset % 8 or arg.offset:
            sys.exit(f"{case.name}: {arg} meets a {width}-byte {kind} argument")
        pointers[offset] = arg.array
        labels[offset // 4] = labels[offset // 4 + 1] = f"{arg.array} pointer"
        return
    formats = {"i32": "<i", "f32": "<f", "i64": "<q", "f64": "<d", "u8": "<B"}
    raw = struct.pack(formats[arg.kind], arg.value)
    if kind not in (None, "by_value") or width not in (None, len(raw)) or offset % len(raw):
        sys.exit(f"{case.name}: {arg} meets a {width}-byte {kind} argument")
    put(offset, raw, arg.name or "scalar")


def words(data, labels, pointers) -> list[dict]:
    """The argument bytes as launch-file parameters: a pointer per 8-byte array address, else
    one 32-bit integer per word."""
    params, word = [], 0
    while word < len(labels):
        if word * 4 in pointers:
            params.append({"name": labels[word], "ptr": pointers[word * 4]})
            word += 2
            continue
        params.append({"name": labels[word], "int": struct.unpack_from("<i", data, word * 4)[0]})
        word += 1
    return params


def launch_file(case, kernel: dict, shared: int) -> dict:
    launch = {
        "description": f"Aiter {case.source}: {case.description}. Generated by "
                       f"external/amd/aiter/build.py.",
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
    parser.add_argument("--clang", default=DEFAULT_CLANG)
    parser.add_argument("cases", nargs="*", help="cases to build (default: all)")
    args = parser.parse_args()
    if args.inside:
        inside(args.cases)
        return 0

    selected = [c for c in registry.CASES if not args.cases or c.name in args.cases]
    if args.cases and len(selected) != len(args.cases):
        sys.exit(f"unknown cases: {set(args.cases) - {c.name for c in selected}}")
    aiter = ensure_aiter()
    builds = {}  # assembly name -> (assembly text, dynamic LDS bytes)
    hip_cases = [c for c in selected if isinstance(c.build, Hip) and not c.assembly]
    if hip_cases:
        hip = ensure_hip()
        for case in hip_cases:
            name = case.assembly_name()
            if name not in builds:
                builds[name] = (compile_hip(case, args.clang, aiter, hip), 0)
    triton = [c.name for c in selected if isinstance(c.build, Triton) and not c.assembly]
    if triton:
        builds.update(compile_triton(triton, aiter))

    for name, (assembly, shared) in builds.items():
        case = next(c for c in registry.CASES if c.assembly_name() == name)
        header = (f"; Aiter {AITER_COMMIT[:12]} {case.source}, compiled for gfx950 by\n"
                  f"; external/amd/aiter/build.py (case {case.name}).\n")
        if shared:
            header += f"; dynamic LDS: {shared} bytes\n"
        (ROOT / f"{name}.s").write_text(header + assembly)
        print(f"wrote {name}.s")
    for case in selected:
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
