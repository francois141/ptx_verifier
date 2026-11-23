#!/usr/bin/env python3
"""Compile the HipKittens kernels cases.py lists for gfx950 and write each case's launch file.

    HK_ROOT=<HazyResearch/HipKittens checkout, 8cde3dd> \\
    HIP_ROOT=<HIP 7.0.2 headers: include/ and share/hip/version> \\
    python3 compile.py [--clang PATH] [KERNEL...]

Each kernel's source is its copy in `kernels/` (HipKittens 8cde3dd, MIT; `kernels/LICENSE`),
compiled against the checkout's headers as it is but for its case's fixes, as
kernels/common.mk builds it for CDNA4 (`-DKITTENS_CDNA4 -O3 -std=c++20`) with the kernels'
Makefile flags (`-ffast-math -DHIP_ENABLE_WARP_SYNC_BUILTINS`), f32 denormals kept as hipcc keeps
them, so every exp carries clang's denormal guard. `stubs/` stands in for the pybind11 bindings,
and `device_libs.hpp` for the ROCm device library `-nogpulib` omits. The compiler is LLVM's
clang 21 (Apple's lacks the AMDGPU target).

A launch file's kernel arguments cover every byte the kernel's metadata declares: the globals
struct, laid out field by field from clang's record layout of it, the case's arguments after it,
then the hidden arguments.
"""
import argparse
import json
import os
import re
import struct
import subprocess
import sys
import tempfile
from pathlib import Path

import cases

ROOT = Path(__file__).resolve().parent
DEFAULT_CLANG = "/opt/homebrew/opt/llvm@21/bin/clang++"
ELEMENT_BYTES = {"bf16": 2, "f32": 4}
# A `kittens::gl`'s pointer and four dimensions, by offset within it.
GL_FIELDS = (("raw_ptr", 0), ("batch_internal", 8), ("depth_internal", 16),
             ("rows_internal", 24), ("cols_internal", 32))


def clang_command(clang: str, source: Path, hk_root: Path, hip_root: Path) -> list[str]:
    return [
        clang, "-x", "hip", "-std=c++20", "-w", "--offload-arch=gfx950:xnack-",
        "--offload-device-only", "-nogpulib", f"--hip-path={hip_root}", "-DKITTENS_CDNA4",
        "-DHIP_ENABLE_WARP_SYNC_BUILTINS", "-O3", "-ffast-math", "-g0", "-fno-verbose-asm",
        f"-I{ROOT / 'stubs'}", f"-I{hk_root / 'include'}", "-include",
        str(ROOT / "device_libs.hpp"), str(source),
    ]


def patched_source(kernel: cases.Kernel, scratch: Path) -> Path:
    """The kernel's source with its fixes applied, beside a copy of nothing else: relative
    includes resolve through `-iquote` to the source's own directory."""
    original = ROOT / kernel.source
    text = original.read_text(encoding="utf-8")
    for fix in kernel.fixes:
        if text.count(fix.old) != fix.count:
            sys.exit(f"{kernel.name}: {fix.old!r} occurs {text.count(fix.old)} times, not {fix.count}")
        text = text.replace(fix.old, fix.new)
    patched = scratch / f"{kernel.name}.cpp"
    patched.write_text(text, encoding="utf-8")
    return patched


def compile_kernel(clang: str, kernel: cases.Kernel, hk_root: Path, hip_root: Path) -> str:
    """Write `<kernel>.s`; return clang's record layouts of the source's types."""
    with tempfile.TemporaryDirectory() as scratch:
        source = patched_source(kernel, Path(scratch))
        include = ["-iquote", str((ROOT / kernel.source).parent)]
        defines = [f"-D{name}={value}" for name, value in kernel.defines]
        command = clang_command(clang, source, hk_root, hip_root) + include + defines
        assembly = ROOT / f"{kernel.name}.s"
        result = subprocess.run(command + ["-S", "-o", str(assembly)], capture_output=True, text=True)
        if result.returncode:
            sys.exit(f"{kernel.name}: clang failed:\n{result.stderr}")
        if "s_swappc_b64" in assembly.read_text(encoding="utf-8"):
            sys.exit(f"{kernel.name}: the kernel calls a function -nogpulib does not provide")
        layouts = subprocess.run(
            command + ["-fsyntax-only", "-Xclang", "-fdump-record-layouts"],
            capture_output=True, text=True,
        )
        if layouts.returncode:
            sys.exit(f"{kernel.name}: clang's record layout dump failed:\n{layouts.stderr}")
        return layouts.stdout


def struct_fields(layouts: str, type_name: str) -> dict[str, int]:
    """The offset of each top-level field of `type_name`, by name, from clang's dump."""
    lines = layouts.splitlines()
    header = re.compile(rf"^\s*0 \| struct {re.escape(type_name)}$")
    start = next((i for i, line in enumerate(lines) if header.match(line)), None)
    if start is None:
        sys.exit(f"no record layout of {type_name}")
    fields = {}
    for line in lines[start + 1:]:
        match = re.match(r"^\s*(\d+) \|   (\S.*\S)$", line)
        if line.startswith("***") or not line.strip():
            break
        if match and not match.group(2).startswith(" "):
            offset, declaration = int(match.group(1)), match.group(2)
            fields[declaration.split()[-1]] = offset
    return fields


def kernel_metadata(assembly: str, symbol: str) -> dict:
    """The arguments (offset, size, kind) and kernarg size of the kernel `symbol` starts."""
    metadata = assembly.split(".amdgpu_metadata", 1)[1]
    kernels = []
    for block in re.split(r"\n  - \.", metadata)[1:]:
        name = re.search(r"\.name:\s+(\S+)", block)
        size = re.search(r"\.kernarg_segment_size:\s+(\d+)", block)
        args = re.findall(
            r"\.offset:\s+(\d+)\s+\.size:\s+(\d+)\s+\.value_kind:\s+(\w+)", block
        )
        if name and size:
            kernels.append({
                "name": name.group(1),
                "size": int(size.group(1)),
                "args": [(int(o), int(s), k) for o, s, k in args],
            })
    chosen = [k for k in kernels if k["name"].startswith(symbol)]
    if len(chosen) != 1:
        sys.exit(f"expected one kernel named {symbol}*, found {[k['name'] for k in kernels]}")
    return chosen[0]


def kernarg_params(case: cases.Case, metadata: dict, fields: dict[str, int]) -> list[dict]:
    size = metadata["size"]
    data = bytearray(size + (-size) % 4)
    labels = ["padding"] * (len(data) // 4)
    pointers = {}

    def put(offset: int, raw: bytes, label: str) -> None:
        data[offset:offset + len(raw)] = raw
        for word in range(offset // 4, (offset + len(raw) + 3) // 4):
            labels[word] = label

    unknown = set(case.fields) - set(fields)
    if unknown:
        sys.exit(f"{case.name}: {case.globals} has no fields {sorted(unknown)}")
    packings = {"i32": "<i", "i64": "<q", "f32": "<f"}
    (struct_offset, _, kind), *rest = metadata["args"]
    if kind != "by_value" or struct_offset != 0:
        sys.exit(f"{case.name}: the kernel's first argument is not its globals struct")
    for name, value in case.fields.items():
        offset = fields[name]
        if isinstance(value, cases.Gl):
            pointers[offset] = value.array
            labels[offset // 4] = labels[offset // 4 + 1] = f"{name}.raw_ptr"
            for (part, at), dim in zip(GL_FIELDS[1:], value.dims):
                put(offset + at, struct.pack("<q", dim), f"{name}.{part.split('_')[0]}")
        else:
            put(offset, struct.pack(packings[value.kind], value.value), name)

    explicit = [arg for arg in rest if not arg[2].startswith("hidden_")]
    if len(explicit) != len(case.args) or any(kind != "by_value" for _, _, kind in explicit):
        sys.exit(f"{case.name}: the kernel takes {explicit} after its globals struct, "
                 f"the case gives {len(case.args)} arguments")
    for index, ((offset, width, _), value) in enumerate(zip(explicit, case.args)):
        raw = struct.pack(packings[value.kind], value.value)
        if len(raw) != width:
            sys.exit(f"{case.name}: argument {index + 1} is {width} bytes, not {value.kind}")
        put(offset, raw, f"argument {index + 1}")

    hidden = {
        "hidden_block_count_x": case.grid[0], "hidden_block_count_y": case.grid[1],
        "hidden_block_count_z": case.grid[2], "hidden_group_size_x": case.block,
        "hidden_group_size_y": 1, "hidden_group_size_z": 1, "hidden_grid_dims": 3,
        "hidden_dynamic_lds_size": case.shared,
    }
    for offset, width, kind in rest:
        if kind.startswith("hidden_"):
            put(offset, hidden.get(kind, 0).to_bytes(width, "little"), kind)

    params, word = [], 0
    while word < len(labels):
        if word * 4 in pointers:
            params.append({"name": labels[word], "ptr": pointers[word * 4]})
            word += 2
            continue
        params.append({"name": labels[word], "int": struct.unpack_from("<i", data, word * 4)[0]})
        word += 1
    return params


def launch_file(case: cases.Case, kernel: cases.Kernel, metadata: dict, fields: dict) -> dict:
    launch = {
        "description": f"HipKittens {kernel.source}: {case.description}. Generated by "
                       "external/amd/hipkittens/compile.py.",
        "kernel": metadata["name"],
        "grid": list(case.grid),
        "block": case.block,
        "arrays": [
            {"name": a.name, "kind": a.kind, "dtype": a.dtype, "shape": list(a.shape)}
            for a in case.arrays
        ],
        "params": kernarg_params(case, metadata, fields),
    }
    if case.shared:
        launch["dynamic_shared_bytes"] = case.shared
    if case.spec:
        launch["spec"] = case.spec
        launch["dims"] = case.dims
    return launch


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--clang", default=DEFAULT_CLANG)
    parser.add_argument("kernels", nargs="*", help="kernel names (default: all)")
    args = parser.parse_args()
    try:
        hk_root, hip_root = Path(os.environ["HK_ROOT"]), Path(os.environ["HIP_ROOT"])
    except KeyError as missing:
        sys.exit(f"error: set {missing.args[0]} (see the module docstring)")
    chosen = [k for k in cases.KERNELS if not args.kernels or k.name in args.kernels]
    for kernel in chosen:
        layouts = compile_kernel(args.clang, kernel, hk_root, hip_root)
        assembly = (ROOT / f"{kernel.name}.s").read_text(encoding="utf-8")
        print(f"wrote {kernel.name}.s")
        for case in (c for c in cases.CASES if c.kernel == kernel.name):
            metadata = kernel_metadata(assembly, case.symbol)
            fields = struct_fields(layouts, case.globals)
            launch = launch_file(case, kernel, metadata, fields)
            path = ROOT / f"{case.name}.launch.json"
            path.write_text(json.dumps(launch, indent=2) + "\n", encoding="utf-8")
            print(f"wrote {path.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
