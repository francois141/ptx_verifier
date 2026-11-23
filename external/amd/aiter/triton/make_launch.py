"""Build a Volta launch file for a kernel compiled by compile_case.py.

launch(case, values, arrays, grid, spec=None, dims=None, out=None, description="")
  case:   the compile tag (reads out/<case>.json and out/<case>.s)
  values: runtime arg name -> array name (pointer), None (null pointer), int or float; every
          non-constexpr argument of the compiled signature, in any order
  arrays: Volta arrays [{name, kind: in|out, dtype: f32|bf16|i32, shape, contents?}]
The kernarg buffer follows the .s metadata: Triton's runtime args, then its global_scratch and
profile_scratch pointers (null), then the hidden args (block counts = grid, group sizes = block,
grid dims), every byte covered by 4-byte words."""
import json
import re
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "out"


def metadata_args(asm):
    section = asm.split(".args:", 1)[1].split(".group_segment_fixed_size", 1)[0]
    entries = []
    for chunk in section.split("      - ")[1:]:
        fields = dict(re.findall(r"\.(\w+):\s+(\S+)", chunk))
        entries.append(dict(offset=int(fields["offset"]), size=int(fields["size"]),
                            kind=fields["value_kind"]))
    size = int(re.search(r"\.kernarg_segment_size:\s+(\d+)", asm).group(1))
    return entries, size


def launch(case, values, arrays, grid, spec=None, dims=None, out=None, description="",
           dynamic_lds=None):
    meta = json.loads((OUT / f"{case}.json").read_text())
    asm = (OUT / f"{case}.s").read_text()
    entries, size = metadata_args(asm)
    grid = list(grid) + [1] * (3 - len(grid))
    block = [64 * meta["options"].get("num_warps", 4), 1, 1]
    runtime = [(name, ty) for name, ty in meta["signature"].items() if ty != "constexpr"]
    runtime += [("global_scratch", "*i8"), ("profile_scratch", "*i8")]
    explicit = [e for e in entries if not e["kind"].startswith("hidden_")]
    if len(explicit) != len(runtime):
        raise RuntimeError(f"{case}: {len(explicit)} metadata args, {len(runtime)} runtime args")
    data = bytearray(size)
    pointers = {}
    for entry, (name, ty) in zip(explicit, runtime):
        o, n = entry["offset"], entry["size"]
        if ty.startswith("*"):
            value = values.get(name) if name in values else None
            if name not in values and name not in ("global_scratch", "profile_scratch"):
                raise RuntimeError(f"{case}: no value for pointer {name}")
            if value is not None:
                pointers[o] = (name, value)
            continue
        value = values[name]
        if ty == "fp32":
            data[o:o + 4] = struct.pack("<f", value)
        elif ty == "i32":
            data[o:o + 4] = struct.pack("<i", value)
        elif ty == "i64":
            data[o:o + 8] = struct.pack("<q", value)
        else:
            raise RuntimeError(f"{case}: arg {name} of type {ty}")
    dims_used = 3 if grid[2] > 1 else 2 if grid[1] > 1 else 1
    hidden = dict(hidden_block_count_x=grid[0], hidden_block_count_y=grid[1],
                  hidden_block_count_z=grid[2], hidden_group_size_x=block[0],
                  hidden_group_size_y=block[1], hidden_group_size_z=block[2],
                  hidden_grid_dims=dims_used)
    for entry in entries:
        if entry["kind"].startswith("hidden_"):
            value = hidden.get(entry["kind"], 0)
            o, n = entry["offset"], entry["size"]
            data[o:o + n] = value.to_bytes(n, "little")
    params, o = [], 0
    while o < size:
        if o in pointers:
            name, array = pointers[o]
            params.append(dict(name=name, ptr=array))
            o += 8
            continue
        word = int.from_bytes(data[o:o + 4], "little", signed=True)
        params.append(dict(name=f"bytes {o}..{o + 3}", int=word))
        o += 4
    doc = dict(description=description or meta["note"] or case, kernel=meta["symbol"],
               grid=grid, block=block, dynamic_shared_bytes=meta["shared"] if dynamic_lds is None
               else dynamic_lds, arrays=arrays, params=params)
    if spec:
        doc["spec"] = spec
        doc["dims"] = dims or {}
    path = Path(out) if out else OUT / f"{case}.launch.json"
    path.write_text(json.dumps(doc, indent=1) + "\n")
    return path
