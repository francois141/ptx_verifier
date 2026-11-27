"""Launch files for ThunderKittens' unit tests, one per kernel of their PTX.

    python3 external/ptx/extraction/thunderkittens_units.py              # the curated kernels' launch files
    python3 external/ptx/extraction/thunderkittens_units.py --all        # every kernel's (after a units build)

`thunderkittens.py --suite units` compiles `tests/` (one PTX per test file, in
`external/ptx/thunderkittens/units/`) and then runs this. Every test kernel is a
one-CTA wrapper whose template arguments name everything its launch needs: the test,
the element type, the tile sizes and each `kittens::gl` argument's type, from which
its by-value layout follows (`gl_fields`). The host code each test file runs gives
the rest (`RUNTIME_DIMS`, `block_of`): grid 1, `MAX_SHARED_MEMORY - 1024` dynamic
shared bytes. A test whose reference (`host_func`) is a formula `SPECS` can state
is checked against `units/specs/<spec>.spec`; the others are race checked only.

By default only `CURATED` kernels get launch files, PTX files none of them uses are removed
and the others keep only the entries they use (`prune`): a sample of each kind of test, correct ones and those of `thunderkittens/bugs.txt`.
`patched/` (`thunderkittens.py --suite patched`) holds the buggy ones' fixed controls.
"""

import argparse
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

UNITS = Path(__file__).resolve().parent.parent / "thunderkittens" / "units"
DYNAMIC_SHARED = 227 * 1024 - 1024  # kittens::MAX_SHARED_MEMORY - 1024 on sm_100a
ENTRY = re.compile(r"^(?:\.visible )?\.entry (\S+?)\(\n(.*?)\n\)", re.MULTILINE | re.DOTALL)
PARAM_SIZE = re.compile(r"\.param \.align \d+ \.b8 \S+\[(\d+)\]")

# C++ element type -> (launch dtype, tensor-map dtype, bytes); TK encodes 1-byte types as u8.
DTYPES = {
    "float": ("f32", "f32", 4),
    "int": ("i32", "i32", 4),
    "__nv_bfloat16": ("bf16", "bf16", 2),
    "__half": ("f16", "f16", 2),
    "__nv_fp8_e4m3": ("e4m3", "u8", 1),
    "__nv_fp8_e5m2": ("e5m2", "u8", 1),
    "signed char": ("i8", "u8", 1),
    "unsigned char": ("u8", "u8", 1),
    "bool": ("u8", "u8", 1),
    "short": ("i16", "u16", 2),
    "unsigned short": ("u16", "u16", 2),
    "unsigned int": ("u32", "u32", 4),
    "double": ("f64", "f64", 8),
    "long": ("i64", "i64", 8),
    "unsigned long": ("u64", "u64", 8),
}


def split_args(text: str) -> list[str]:
    """Top-level comma-separated template arguments."""
    args, depth, start = [], 0, 0
    for i, ch in enumerate(text):
        if ch == "<":
            depth += 1
        elif ch == ">":
            depth -= 1
        elif ch == "," and depth == 0:
            args.append(text[start:i].strip())
            start = i + 1
    args.append(text[start:].strip())
    return [a for a in args if a]


def template_of(text: str) -> tuple[str, list[str]]:
    """`name<a, b<c>>` -> (`name`, [`a`, `b<c>`])."""
    if "<" not in text:
        return text, []
    head = text.index("<")
    return text[:head], split_args(text[head + 1 : text.rindex(">")])


@dataclass(frozen=True)
class Tile:
    """A `kittens::st` (rows x cols) or `kittens::sv` (cols only) a gl makes a tensor map for."""

    dtype: str
    rows: int | None
    cols: int
    swizzle_bytes: int  # 0: unswizzled


@dataclass(frozen=True)
class Gl:
    dtype: str
    dims: tuple[int, int, int, int]  # batch, depth, rows, cols; -1 is a runtime dim
    tiles: tuple[Tile, ...]


def parse_tile(text: str) -> Tile:
    name, args = template_of(text)
    dtype = args[0]
    size = DTYPES[dtype][2]
    if name.endswith("::sv"):
        return Tile(dtype, None, int(args[1].rstrip("ul")), 0)
    rows, cols = int(args[1]), int(args[2])
    swizzle = args[3] == "true" if len(args) > 3 else True
    given = int(args[4]) if len(args) > 4 else 0
    if not swizzle:
        return Tile(dtype, rows, cols, 0)
    col_tiles = cols // (32 if size == 1 else 16)  # kittens::TILE_COL_DIM
    auto = (128 if col_tiles % 2 == 0 else 64) if size == 4 else \
        (128 if col_tiles % 4 == 0 else 64 if col_tiles % 2 == 0 else 32)
    return Tile(dtype, rows, cols, given or auto)


def parse_gl(text: str) -> Gl:
    _, args = template_of(text)
    return Gl(args[0], tuple(int(a) for a in args[1:5]), tuple(parse_tile(t) for t in args[5:]))


def gl_size(gl: Gl) -> int:
    offset = 8
    for d in gl.dims:
        offset = (offset + 7) // 8 * 8 + 8 if d == -1 else offset + 1  # runtime_dim / empty compiled_dim
    if gl.tiles:
        offset = (offset + 63) // 64 * 64 + ((128 * len(gl.tiles) + 1 + 63) // 64 * 64)
        return (offset + 63) // 64 * 64
    return (offset + 1 + 7) // 8 * 8  # the empty descriptor_dict<>


def tensor_map(tile: Tile, array: str, dims: tuple[int, int, int, int]) -> dict:
    """TK's `detail::tma::create_tensor_map` (axis 2) for a tile of a [batch, depth, rows, cols] tensor."""
    _, tma_dtype, size = DTYPES[tile.dtype]
    batch, depth, rows, cols = dims
    if tile.rows is None:  # a vector: rows of `cols`, boxes of its largest divider of at most 256
        divider = next(16 * d for d in range(16, 0, -1) if tile.cols % (16 * d) == 0 and
                       (tile.cols < 256 or 16 * d * size % 128 == 0))
        return {"array": array, "dtype": tma_dtype, "dims": [cols, rows, depth, batch],
                "strides": [cols * size, cols * rows * size, cols * rows * depth * size],
                "box": [divider, 1, 1, 1]}
    if tile.swizzle_bytes == 0:
        return {"array": array, "dtype": tma_dtype, "dims": [cols, rows, depth, batch],
                "strides": [cols * size, rows * cols * size, depth * rows * cols * size],
                "box": [tile.cols, tile.rows, 1, 1]}
    width = tile.swizzle_bytes // size
    return {"array": array, "dtype": tma_dtype,
            "dims": [width, rows, (cols + width - 1) // width, depth, batch],
            "strides": [cols * size, tile.swizzle_bytes, rows * cols * size, depth * rows * cols * size],
            "box": [width, tile.rows, tile.cols // width, 1, 1], "swizzle": f"{tile.swizzle_bytes}B"}


def gl_fields(name: str, gl: Gl, array: str, runtime: tuple[int, ...], base: int = 0) -> list[dict]:
    """The by-value `gl`'s fields: `raw_ptr`, its runtime dims (size_t) and its tensor maps."""
    fields = [{"name": f"{name}.raw_ptr", "offset": base, "ptr": array}]
    values = iter(runtime)
    dims, offset = [], 8
    for label, d in zip(("batch", "depth", "rows", "cols"), gl.dims):
        if d == -1:
            offset = (offset + 7) // 8 * 8
            dims.append(next(values))
            fields.append({"name": f"{name}.{label}", "offset": base + offset, "u64": dims[-1]})
            offset += 8
        else:
            dims.append(d)
            offset += 1
    offset = (offset + 63) // 64 * 64
    for i, tile in enumerate(gl.tiles):
        fields.append({"name": f"{name}.tma[{i}]", "offset": base + offset + 128 * i,
                       "tensor_map": tensor_map(tile, array, tuple(dims))})
    return fields


def full_dims(gl: Gl, runtime: tuple[int, ...]) -> tuple[int, int, int, int]:
    values = iter(runtime)
    return tuple(next(values) if d == -1 else d for d in gl.dims)


# The values the host passes for each wrapper's runtime dims (batch, depth, rows), by test file.
def runtime_dims(file: str, template: list[str]) -> tuple[int, ...]:
    if file == "thread_memory_tile_tma" or file == "thread_memory_vec_tma":
        return (3, 5)  # B, D
    if file == "group_memory_tile_global_to_shared":
        h, axis = int(template[2]), int(template[-1].split(",")[-1].strip(" >"))
        return (h * 16 * 3 if axis == 0 else 3, h * 16 if axis == 1 else 1, h * 16 * 4 if axis == 2 else 4)
    return ()


# The test -> spec file (units/specs/<name>.spec) and extra dims; None: race checked only.
IDENTITY = {"group_load_store", "group_shared_load_store", "group_shared_load_store_async",
            "group_shared_reg_load_store", "group_tensor_reg_load_store", "vec_load_store",
            "vec_async_load_store", "vec_copy_convert", "test_shared_copy", "vec_copy"}
REDUCTIONS = {"normalize_row", "normalize_col", "broadcast_row", "broadcast_col",
              "max_broadcast_row", "max_broadcast_col"}


def spec_of(file: str, test: str, h: int, w: int) -> tuple[str, dict] | None:
    if file == "group_memory_vec_shared_to_register" and test == "vec_load_store":
        return "add1", {}
    if test in IDENTITY or (file in ("thread_memory_tile_tma", "thread_memory_vec_tma")
                            and test in ("test_load", "test_store")):
        return "identity", {}
    if test == "test_load_oob":
        return "zero", {}
    if test == "vec_add1":
        return "add1", {}
    if test == "test_exp":
        return "exp", {}
    masks = {"test_tril": ("tril", 4 * h), "test_triu": ("triu", 4 * h),
             "test_right_fill": ("right_fill", 8 * w), "test_left_fill": ("left_fill", 8 * w),
             "test_lower_fill": ("lower_fill", 8 * h), "test_upper_fill": ("upper_fill", 8 * h)}
    if test in masks:
        spec, offset = masks[test]
        return spec, {"D": offset}
    if test.removeprefix("group_") in REDUCTIONS:
        return test.removeprefix("group_"), {}
    return None


@dataclass
class Launch:
    case: str
    kernel: str
    block: int
    arrays: list
    params: list
    spec: str | None = None
    dims: dict | None = None


def short(arg: str) -> str:
    arg = arg.replace("kittens::ducks::rt_layout::", "").replace("kittens::", "")
    if arg in DTYPES:
        return DTYPES[arg][0]
    if arg.startswith("std::integral_constant"):
        return "k" + arg.split(",")[-1].strip(" >")
    return re.sub(r"<.*", "", arg)


def array(name: str, kind: str, gl: Gl, dims) -> dict:
    batch, depth, rows, cols = dims
    return {"name": name, "kind": kind, "dtype": DTYPES[gl.dtype][0], "shape": [batch * depth * rows, cols]}


def launch_of(file: str, kernel: str, demangled: str, sizes: list[int]) -> Launch | str:
    """The kernel's launch, or why this generator does not launch it."""
    signature = demangled.removeprefix("void ")
    head = signature[: signature.index(">(") + 1]
    wrapper, template = template_of(head)
    wrapper = wrapper.split("::")[-1]
    params = split_args(signature[signature.index(">(") + 2 : signature.rindex(")")])
    if any("cgl<" in p for p in params) or "nvfp4" in wrapper or "2cta" in wrapper or "f8_k64" in wrapper:
        return "complex or block-scaled operands"
    gls = [parse_gl(p) for p in params]
    for gl, size in zip(gls, sizes):
        if gl_size(gl) != size:
            raise ValueError(f"{kernel}: computed a {gl_size(gl)}-byte gl, the PTX has {size}")
    test = short(template[0])
    tags = [test] + [short(a) for a in template[1:] if "gl<" not in a]
    case = ".".join(t for t in tags if t)

    if wrapper == "tcgen05_wrapper":
        ta, tb, acc = (template[i] == "true" for i in (2, 3, 4))
        name = f"{'mma2' if acc else 'mm'}_{'At' if ta else 'A'}{'Bt' if tb else 'B'}"
        tags = [short(template[0]), "tt" if template[1] == "true" else "st", name]
        names = ("a", "b", "c")
        dims = {"M": 128, "N": 64, "K": 32}
        return Launch(".".join(tags), kernel, 128,
                      [array(n, "out" if n == "c" else "in", g, g.dims) for n, g in zip(names, gls)],
                      [{"name": n, "struct": gl_fields(n, g, n, ())} for n, g in zip(names, gls)],
                      name, dims)
    if wrapper == "mma_global_wrapper_2d":
        variant = test.removeprefix("test_mma_").removesuffix("_fp8").removesuffix("_i8")
        a, _, c = gls
        names = ("a", "b", "c")
        k = a.dims[3] if not variant.startswith("At") else a.dims[2]
        dims = {"M": c.dims[2], "N": c.dims[3], "K": k}
        return Launch(case, kernel, 32 * int(template[4]),
                      [array(n, "out" if n == "c" else "in", g, g.dims) for n, g in zip(names, gls)],
                      [{"name": n, "struct": gl_fields(n, g, n, ())} for n, g in zip(names, gls)],
                      f"mm_{variant}", dims)

    one_d = wrapper.endswith("_1d")
    workers = int(template[3] if one_d else template[4])
    runtime = runtime_dims(file, template)
    input_gl, output_gl = gls
    dims = full_dims(input_gl, runtime)
    reduces_into_output = test.startswith("test_store_") and test.endswith("_reduce")
    arrays = [array("input", "in", input_gl, dims),
              array("output", "inout" if reduces_into_output else "out", output_gl, dims)]
    fields = [{"name": "input", "struct": gl_fields("input", input_gl, "input", runtime)},
              {"name": "output", "struct": gl_fields("output", output_gl, "output", runtime)}]
    h = 1 if one_d else int(template[2])
    w = int(template[2]) if one_d else int(template[3])
    found = spec_of(file, test, h, w)
    spec, extra = found if found else (None, {})
    spec_dims = {"R": dims[0] * dims[1] * dims[2], "C": dims[3], **extra} if spec else None
    # fp8 tiles move as packed 4-byte words, which a 1-byte element cannot be read back from:
    # a copy declares its arrays as those words (outside TMA, whose boxes may split a word).
    if spec == "identity" and DTYPES[input_gl.dtype][0] in ("e4m3", "e5m2") and not file.startswith("thread_"):
        for a in arrays:
            a["dtype"], a["shape"] = "u32", [a["shape"][0], a["shape"][1] // 4]
        spec_dims["C"] //= 4
    return Launch(case, kernel, 32 * workers, arrays, fields, spec, spec_dims)


def template_head(demangled: str) -> str:
    """`wrapper<test, dtype, sizes...>`: the demangled name without its gl arguments."""
    signature = demangled.removeprefix("void ")
    wrapper, template = template_of(signature[: signature.index(">(") + 1])
    return f"{wrapper.split('::')[-1]}<{', '.join(a for a in template if 'gl<' not in a)}>"


def demangle(names: list[str]) -> list[str]:
    out = subprocess.run(["c++filt", "-n"], input="\n".join(names), capture_output=True, text=True,
                         check=True).stdout
    return out.splitlines()


CURATED = {  # stem.case
    # correct: race free and equal to their spec
    "group_memory_tile_global_to_register.group_load_store.bf16.1.1.1.row",
    "group_memory_tile_global_to_shared.group_shared_load_store.bf16.1.1.1.k2",
    "group_memory_tile_global_to_shared.group_shared_load_store_async.bf16.1.1.1.k2",
    "group_memory_tile_shared_to_register.group_shared_reg_load_store.bf16.1.1.1.row",
    "group_memory_vec_global_to_shared.vec_load_store.bf16.1.1",
    "group_mma_warp_mma.test_mma_AB.bf16.1.1.1.k2",
    "group_mma_warp_mma.test_mma_ABt.bf16.1.1.1.k2",
    "group_mma_warp_mma.test_mma_AtB.bf16.1.1.1.k2",
    "group_mma_warp_mma.test_mma_AtBt.bf16.1.1.1.k2",
    "group_register_tile_maps.test_tril.bf16.2.2.1.row",
    "group_register_tile_reductions.broadcast_col.bf16.2.2.1.row",
    "group_register_tile_reductions.max_broadcast_row.bf16.2.2.1.row",
    "group_register_tile_reductions.normalize_row.bf16.2.2.1.row",
    # buggy (bugs.txt TK-2 to TK-5)
    "thread_memory_tile_tma.test_load.bf16.1.1.1",
    "thread_memory_tile_tma.test_store.bf16.1.1.1",
    "thread_memory_vec_tma.test_load.bf16.1.1",
    "thread_memory_vec_tma.test_store.bf16.1.1",
    "group_mma_tensor_mma.bf16.st.mm_AB",
    "group_mma_tensor_mma.bf16.st.mma2_AB",
    "group_memory_tile_tensor_to_register.group_tensor_reg_load_store.f32.8.2.4.row",
}


def render(body: dict) -> str:
    """The launch file as JSON with one array, parameter or struct field per line."""
    lines = []
    for key, value in body.items():
        if key == "arrays":
            items = [f"    {json.dumps(a)}" for a in value]
            lines.append(f'  "arrays": [\n' + ",\n".join(items) + "\n  ]")
        elif key == "params":
            params = []
            for p in value:
                fields = ",\n".join(f"      {json.dumps(f)}" for f in p["struct"])
                params.append(f'    {{"name": {json.dumps(p["name"])}, "struct": [\n{fields}\n    ]}}')
            lines.append('  "params": [\n' + ",\n".join(params) + "\n  ]")
        else:
            lines.append(f"  {json.dumps(key)}: {json.dumps(value)}")
    return "{\n" + ",\n".join(lines) + "\n}\n"


def prune(ptx: Path, keep: set[str]) -> None:
    """Drop the `.entry` blocks not in `keep`: from the header to the brace closing its body."""
    out, skipping, depth, opened = [], False, 0, False
    for line in ptx.read_text().splitlines(keepends=True):
        if m := re.match(r"(?:\.visible |\.weak )?\.entry (\S+?)\(", line):
            skipping, depth, opened = m[1] not in keep, 0, False
        if not skipping:
            out.append(line)
            continue
        code = line.split("//")[0]
        depth += code.count("{") - code.count("}")
        opened = opened or "{" in code
        if opened and depth == 0:
            skipping = False
    ptx.write_text("".join(out))


def write_launches(units: Path = UNITS, everything: bool = False) -> tuple[int, dict[str, int]]:
    """Rewrite the curated (or every) unit test's launch file; the count written and the
    skipped, by reason. Without `everything`, PTX no curated kernel uses is removed."""
    for old in units.glob("*.launch.json"):
        old.unlink()
    written, skipped = 0, {}
    for ptx in sorted(units.glob("*.ptx")):
        entries = [(m[1], [int(s) for s in PARAM_SIZE.findall(m[2])]) for m in ENTRY.finditer(ptx.read_text())]
        seen = set()
        for (kernel, sizes), demangled in zip(entries, demangle([k for k, _ in entries])):
            launch = launch_of(ptx.stem, kernel, demangled, sizes)
            if isinstance(launch, str):
                skipped[launch] = skipped.get(launch, 0) + 1
                continue
            case = launch.case
            for n in range(2, 100):
                if case not in seen:
                    break
                case = f"{launch.case}.{n}"
            seen.add(case)
            if not everything and f"{ptx.stem}.{case}" not in CURATED:
                continue
            body = {
                "description": f"ThunderKittens unit test {ptx.stem}: {template_head(demangled)}. "
                               "Generated by external/ptx/extraction/thunderkittens_units.py.",
                "kernel": kernel, "grid": 1, "block": launch.block,
                "dynamic_shared_bytes": DYNAMIC_SHARED,
                "arrays": launch.arrays, "params": launch.params,
            }
            if launch.spec:
                body["spec"] = os.path.relpath(UNITS / "specs" / f"{launch.spec}.spec", units)
                body["dims"] = launch.dims
            (units / f"{ptx.stem}.{case}.launch.json").write_text(render(body))
            written += 1
    if not everything:
        used: dict[str, set[str]] = {}
        for launch in units.glob("*.launch.json"):
            used.setdefault(launch.name.split(".")[0], set()).add(json.loads(launch.read_text())["kernel"])
        for ptx in units.glob("*.ptx"):
            if ptx.stem in used:
                prune(ptx, used[ptx.stem])
            else:
                ptx.unlink()
    return written, skipped


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--all", action="store_true", help="every kernel, not only the curated ones")
    parser.add_argument("dir", nargs="?", type=Path, default=UNITS, help=f"default {UNITS}")
    args = parser.parse_args()
    written, skipped = write_launches(args.dir, args.all)
    print(f"wrote {written} launch files to {args.dir}")
    for reason, count in sorted(skipped.items()):
        print(f"  skipped {count}: {reason}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
