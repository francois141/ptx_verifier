"""What `miopen/` and `clblast/` share: the case description, ROCm's device libraries, the
compilation for gfx950, and the launch files.

Importable without the sources or a compiler: `miopen/cases.py` and `clblast/cases.py` take their
dataclasses from here, and each folder's `extract.py` its compiler driver (`main`).

A case's `args` lists its kernel's explicit arguments in order: a `Pointer` is an array's address,
a `Scalar` a 4- or 8-byte value, a `Local` a `__local` buffer of dynamic LDS. `grid` counts
workgroups (OpenCL's global size divided by the local size) and `block` is the local size.
`fixes` replace text, which must occur once, in the kernel's source before it compiles.
"""

import argparse
import json
import re
import struct
import subprocess
import sys
import tarfile
import urllib.request
from dataclasses import dataclass, field
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
WORK = REPO / "target" / "opencl"
DEVICE_LIBS_DEB = ("https://repo.radeon.com/rocm/apt/7.2.1/pool/main/r/rocm-device-libs/"
                   "rocm-device-libs_1.0.0.70201-81~24.04_amd64.deb")
DEVICE_LIBS_BITCODE = "opt/rocm-7.2.1/lib/llvm/lib/clang/22/lib/amdgcn/bitcode"
DEFAULT_CLANG = "/opt/homebrew/opt/llvm@21/bin/clang"
TARGET = ("-target", "amdgcn-amd-amdhsa", "-mcpu=gfx950:xnack-")


# ===== Cases =====

@dataclass(frozen=True)
class Array:
    name: str
    kind: str  # "in" or "out"
    dtype: str  # "f32" or "i32"
    shape: tuple
    contents: tuple | None = None  # concrete i32 words of an `in` array


@dataclass(frozen=True)
class Pointer:
    array: str


@dataclass(frozen=True)
class Null:
    """A null pointer argument."""


@dataclass(frozen=True)
class Scalar:
    value: int | float
    name: str = ""
    kind: str = "i32"  # "i32", "u32", "f32", "f64", "i64" or "u64"


@dataclass(frozen=True)
class Local:
    """A `__local` pointer argument to `bytes` of dynamic LDS."""

    bytes: int


@dataclass(frozen=True)
class Fix:
    """Replace `old`, which must occur once, with `new` in the kernel's source."""

    old: str
    new: str


@dataclass(frozen=True)
class Case:
    """`source` is the library's description of the kernel (its `library`, `kernel` and
    `origin()`). `check` is "ACCEPT" or "REJECT" against `spec`, or, without a spec, "VERIFIED"
    or "REJECTED" from the graph checks alone; "ABORT" requires the run to stop with an error,
    such as an access outside every array or an instruction encoding gfx950 does not execute.
    `assembly` reuses another case's kernel, and `sample` bounds the elements checked per output
    array (0: all)."""

    name: str
    description: str
    source: object
    args: tuple
    arrays: tuple
    grid: int | tuple
    block: int | tuple
    check: str
    spec: str | None = None
    dims: dict = field(default_factory=dict)
    fixes: tuple = ()
    assembly: str | None = None
    sample: int = 0
    flags: tuple = ()  # extra compiler options, after the library's own

    def assembly_name(self) -> str:
        return self.assembly or self.name


# ===== Device libraries =====

def run(*command, **kwargs):
    print("+", " ".join(str(c) for c in command), flush=True)
    subprocess.run(command, check=True, **kwargs)


def ensure_device_libs() -> Path:
    """ROCm's device-library bitcode (`opencl.bc`, `ocml.bc`, `ockl.bc`, the `oclc_*` controls),
    extracted from its Ubuntu package (an `ar` archive) into `target/opencl/devlibs`."""
    root = WORK / "devlibs"
    bitcode = root / DEVICE_LIBS_BITCODE
    if (bitcode / "opencl.bc").exists():
        return bitcode
    root.mkdir(parents=True, exist_ok=True)
    deb = root / Path(DEVICE_LIBS_DEB).name
    if not deb.exists():
        print(f"+ fetch {DEVICE_LIBS_DEB}", flush=True)
        urllib.request.urlretrieve(DEVICE_LIBS_DEB, deb)
    data = ar_member(deb.read_bytes(), "data.tar")
    (root / "data.tar.gz").write_bytes(data)
    with tarfile.open(root / "data.tar.gz") as archive:
        archive.extractall(root, filter="data")
    return bitcode


def ar_member(archive: bytes, prefix: str) -> bytes:
    if not archive.startswith(b"!<arch>\n"):
        sys.exit("the device-library package is not an ar archive")
    offset = 8
    while offset < len(archive):
        header = archive[offset:offset + 60]
        name, size = header[:16].decode().strip(), int(header[48:58].decode().strip())
        if name.startswith(prefix):
            return archive[offset + 60:offset + 60 + size]
        offset += 60 + size + size % 2
    sys.exit(f"the device-library package has no {prefix} member")


# ===== Compilation =====

def apply_fixes(case, text: str) -> str:
    for fix in case.fixes:
        if text.count(fix.old) != 1:
            sys.exit(f"{case.name}: the fix's text occurs {text.count(fix.old)} times")
        text = text.replace(fix.old, fix.new)
    return text


def canonical_inline_asm(assembly: str, clang: str) -> str:
    """The assembly with each instruction of its inline-asm blocks (between clang's `;;#ASMSTART`
    and `;;#ASMEND`) as LLVM's assembler prints it back: MIOpen's DPP sweeps are written
    without commas or the `_dpp` suffix, and with `bound_ctrl:0`, which LLVM encodes as
    `bound_ctrl:1`."""
    lines = assembly.split("\n")
    positions, inside = [], False
    for number, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith(";;#ASMSTART"):
            inside = True
        elif stripped.startswith(";;#ASMEND"):
            inside = False
        elif inside and stripped and not stripped.startswith(";"):
            positions.append(number)
    if not positions:
        return assembly
    source = "\n".join(lines[number].strip() for number in positions) + "\n"
    llvm_mc = str(Path(clang).with_name("llvm-mc"))
    result = subprocess.run([llvm_mc, "-triple=amdgcn-amd-amdhsa", "-mcpu=gfx950"],
                            input=source, capture_output=True, text=True)
    if result.returncode:
        sys.exit(f"llvm-mc rejected the inline assembly:\n{result.stderr}")
    printed = [line.split(";")[0].rstrip() for line in result.stdout.split("\n")
               if line.strip() and not line.strip().startswith(".amdgcn_target")]
    if len(printed) != len(positions):
        sys.exit("llvm-mc printed a different number of inline-asm instructions")
    for number, line in zip(positions, printed):
        lines[number] = line
    return "\n".join(lines)


def compile_case(case, text: str, options: list, clang: str, bitcode: Path, build: Path) -> str:
    """The gfx950 assembly of `text` (the case's fixes applied) compiled with `options`, linked
    with ROCm's device libraries."""
    out = build / f"{case.assembly_name()}.cl"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(apply_fixes(case, text))
    assembly = out.with_suffix(".s")
    command = [clang, "-x", "cl", *TARGET, f"--rocm-device-lib-path={bitcode}", "-w", "-g0",
               "-fno-verbose-asm", *options, *case.flags, "-S", str(out), "-o", str(assembly)]
    print(f"+ clang {case.assembly_name()}", flush=True)
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode:
        sys.exit(f"{case.name}: clang failed:\n{' '.join(command)}\n{result.stderr}")
    text = assembly.read_text()
    if "s_swappc_b64" in text:
        sys.exit(f"{case.name}: the kernel calls a function")
    return canonical_inline_asm(text, clang)


# ===== Launch files =====

def kernel_metadata(assembly: str, name: str) -> dict:
    """The `amdhsa.kernels` entry named `name`: its kernarg size, group segment size and
    arguments (offset, size, value kind, name) in order."""
    metadata = assembly[assembly.index("amdhsa.kernels:"):]
    for block in re.split(r"\n  - ", metadata)[1:]:
        if "\n    .args:" not in block:
            continue
        if re.search(r"\n    \.name:\s+(\S+)", "\n    " + block).group(1) != name:
            continue
        args = []
        args_text = block.split(".args:", 1)[1].split("\n    .", 1)[0]
        for item in re.split(r"\n      - ", args_text)[1:]:
            fields = dict(re.findall(r"\.(\w+):\s+(\S+)", item))
            # YAML writes an argument named like a boolean (`y`) as `!str y`.
            arg_name = re.search(r"\.name:\s+(?:!str\s+)?(\S+)", item)
            args.append((int(fields["offset"]), int(fields["size"]), fields["value_kind"],
                         arg_name.group(1) if arg_name else ""))
        size = int(re.search(r"\.kernarg_segment_size:\s+(\d+)", block).group(1))
        lds = int(re.search(r"\.group_segment_fixed_size:\s+(\d+)", block).group(1))
        return {"name": name, "args": args, "kernarg_size": size, "static_lds": lds}
    sys.exit(f"no kernel named {name}")


def dims3(value) -> tuple:
    dims = [value] if isinstance(value, int) else list(value)
    return tuple(dims + [1] * (3 - len(dims)))


def kernarg_params(case, kernel: dict) -> tuple[list[dict], int]:
    """Launch-file parameters covering every kernel-argument byte the metadata describes, and
    the dynamic LDS bytes the case's `__local` pointer arguments take."""
    size = kernel["kernarg_size"]
    data = bytearray(size + (-size) % 64)
    labels = ["padding"] * (len(data) // 4)
    pointers, local_bytes = {}, 0

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
    args = list(case.args)
    for offset, width, kind, name in kernel["args"]:
        if kind.startswith("hidden_"):
            put(offset, hidden.get(kind, 0).to_bytes(width, "little"), kind)
            continue
        if not args:
            sys.exit(f"{case.name}: the kernel takes more arguments than the case gives")
        arg = args.pop(0)
        label = name or getattr(arg, "name", "") or "argument"
        if isinstance(arg, Local):
            # The runtime places dynamic LDS after the kernel's static LDS; its pointer argument
            # holds that LDS address (a 4-byte local pointer).
            if kind != "dynamic_shared_pointer":
                sys.exit(f"{case.name}: a local buffer meets a {kind} argument")
            address = kernel["static_lds"] + local_bytes
            put(offset, address.to_bytes(width, "little"), label)
            local_bytes += arg.bytes
        elif isinstance(arg, Null):
            if kind != "global_buffer" or width != 8:
                sys.exit(f"{case.name}: a null pointer meets a {width}-byte {kind} argument")
            put(offset, bytes(8), label)
        elif isinstance(arg, Pointer):
            if kind != "global_buffer" or width != 8 or offset % 8:
                sys.exit(f"{case.name}: {arg} meets a {width}-byte {kind} argument")
            pointers[offset] = arg.array
            labels[offset // 4] = labels[offset // 4 + 1] = label
        else:
            formats = {"i32": "<i", "u32": "<I", "f32": "<f", "f64": "<d", "i64": "<q",
                       "u64": "<Q"}
            raw = struct.pack(formats[arg.kind], arg.value)
            if kind != "by_value" or width != len(raw):
                sys.exit(f"{case.name}: {arg} meets a {width}-byte {kind} argument ({label})")
            put(offset, raw, label)
    if args:
        sys.exit(f"{case.name}: the kernel takes fewer arguments than the case gives")
    return words(data, labels, pointers), local_bytes


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


def launch_file(case, kernel: dict, tool: str) -> dict:
    launch = {
        "description": f"{case.source.library} {case.source.origin()}: {case.description}. "
                       f"Generated by {tool}.",
        "kernel": kernel["name"],
        "grid": list(dims3(case.grid)),
        "block": list(dims3(case.block)),
    }
    params, shared = kernarg_params(case, kernel)
    if shared:
        launch["dynamic_shared_bytes"] = shared
    launch["arrays"] = []
    for array in case.arrays:
        entry = {"name": array.name, "kind": array.kind, "dtype": array.dtype,
                 "shape": list(array.shape)}
        if array.contents is not None:
            entry["contents"] = list(array.contents)
        launch["arrays"].append(entry)
    launch["params"] = params
    if case.spec:
        launch["spec"] = case.spec
        launch["dims"] = case.dims
    return launch


# ===== Driver =====

def main(description: str, cases, root: Path, tag: str, prepare, program) -> int:
    """Compile the selected `cases` into `root`'s `<case>.s` and write each `<case>.launch.json`:
    `prepare()` fetches the library's sources, `program(case, sources)` gives a case's program
    text and the library's compiler options; `tag` is the library's pinned version."""
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument("--clang", default=DEFAULT_CLANG)
    parser.add_argument("cases", nargs="*", help="cases to build (default: all)")
    args = parser.parse_args()

    selected = [c for c in cases if not args.cases or c.name in args.cases]
    if args.cases and len(selected) != len(args.cases):
        sys.exit(f"unknown cases: {set(args.cases) - {c.name for c in selected}}")
    tool = f"{root.relative_to(REPO)}/extract.py"
    bitcode = ensure_device_libs()
    sources = prepare()

    built = set()
    for case in selected:
        name = case.assembly_name()
        if name in built or case.assembly:
            continue
        built.add(name)
        text, options = program(case, sources)
        assembly = compile_case(case, text, options, args.clang, bitcode, WORK / "build" / root.name)
        header = (f"; {case.source.library} {tag} {case.source.origin()}, compiled for gfx950\n"
                  f"; by {tool} (case {case.name}).\n")
        (root / f"{name}.s").write_text(header + assembly)
        print(f"wrote {name}.s")
    for case in selected:
        assembly = (root / f"{case.assembly_name()}.s").read_text()
        kernel = kernel_metadata(assembly, case.source.kernel)
        path = root / f"{case.name}.launch.json"
        path.write_text(json.dumps(launch_file(case, kernel, tool), indent=2) + "\n")
        print(f"wrote {path.name}")
    return 0
