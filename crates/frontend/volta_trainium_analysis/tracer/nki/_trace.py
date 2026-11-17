"""The trace one kernel call records: its tensors, its statements in program order, and
the loop iterations and `no_reorder` block each instruction is emitted in.

Every statement is a JSON-ready dict in the wire form `frontend::trace` reads. A tracer
process traces exactly one call, so the trace is this module's state."""

import ast
import math
import sys
from dataclasses import dataclass, field
from pathlib import Path

STAND_IN = Path(__file__).resolve().parent
NKI_LANGUAGE = "nki.language"
NKI_ISA = "nki.isa"
PARTITIONS_MAX = 128
PSUM_PARTITION_BYTES = 16 * 1024
ELEMENT_BYTES = {"float32": 4, "bfloat16": 2, "float16": 2}


class Unsupported(Exception):
    """Kernel code used a part of NKI the stand-in does not model."""


class KernelError(Exception):
    """Kernel code used NKI in a way NKI rejects, e.g. a slice outside its tensor."""


@dataclass
class TileSizes:
    pmax: int = PARTITIONS_MAX
    gemm_stationary_fmax: int = 128
    gemm_moving_fmax: int = 512
    sbuf_fmax_bytes: int = 192 * 1024


@dataclass
class Trace:
    tile_sizes: TileSizes = field(default_factory=TileSizes)
    names: set = field(default_factory=set)
    body: list = field(default_factory=list)
    loops: list = field(default_factory=list)
    next_loop: int = 0
    no_reorder: list = field(default_factory=list)
    next_block: int = 0
    helper_calls: dict = field(default_factory=dict)
    helper_counts: dict = field(default_factory=dict)
    kernel_code: object = None

    def origin(self):
        return {
            "loops": [dict(loop) for loop in self.loops],
            "no_reorder": self.no_reorder[0] if self.no_reorder else None,
        }

    def unique(self, base):
        name, version = base, 0
        while name in self.names:
            version += 1
            name = f"{base}~{version}"
        self.names.add(name)
        return name

    def instruction(self, opcode, operands):
        self.body.append(
            {
                "instruction": {
                    "opcode": opcode,
                    "operands": operands,
                    "origin": self.origin(),
                }
            }
        )


TRACE = Trace()


def reset(tile_sizes):
    global TRACE
    TRACE = Trace(tile_sizes=tile_sizes)
    return TRACE


# =============================================================================
# Values
# =============================================================================


class Member:
    """A member of `nki.language` or `nki.isa` the stand-in gives no meaning of its own,
    e.g. `nl.add` or `nisa.engine.vector`, passed to an instruction by its dotted path."""

    def __init__(self, path):
        self._path = path

    def __getattr__(self, name):
        if name.startswith("__"):
            raise AttributeError(name)
        return Member(f"{self._path}.{name}")

    def __call__(self, *args, **kwargs):
        raise Unsupported(f"`{self._path}` is not supported")

    def __eq__(self, other):
        if isinstance(other, DtypeOf):
            return other == self
        return isinstance(other, Member) and other._path == self._path

    def __hash__(self):
        return hash(self._path)

    def __repr__(self):
        return self._path

    def member_of(self, module):
        prefix = module + "."
        return self._path[len(prefix) :] if self._path.startswith(prefix) else None


class DtypeOf:
    """`t.dtype` of a tensor whose dtype the call may not give."""

    def __init__(self, tensor):
        self.tensor = tensor

    def name(self):
        return self.tensor.dtype_name

    def __eq__(self, other):
        if isinstance(other, DtypeOf) and other.tensor is self.tensor:
            return True
        mine = self.name()
        theirs = dtype_name(other)
        if mine is None or theirs is None:
            raise Unsupported(
                f"comparing `{self.tensor.name}.dtype` needs the call to give its dtype"
            )
        return mine == theirs

    def __hash__(self):
        return hash(self.tensor.name)

    def __repr__(self):
        return f"{self.tensor.name}.dtype"


def dtype_name(value):
    if isinstance(value, DtypeOf):
        return value.name()
    if isinstance(value, Member):
        return value.member_of(NKI_LANGUAGE)
    return None


def wire_dtype(value):
    if isinstance(value, DtypeOf):
        return {"of": value.tensor.name}
    if isinstance(value, Member) and value.member_of(NKI_LANGUAGE) is not None:
        return {"named": value.member_of(NKI_LANGUAGE)}
    raise KernelError(
        f"a dtype must be a tensor's `dtype` or an `nl` type, not `{value!r}`"
    )


class Tensor:
    """A tensor: a kernel argument or an HBM tensor (`place` "hbm"), or an on-chip tile
    ("sbuf", "psum"). Its shape is concrete, as `@nki.jit` specializes it per call."""

    def __init__(self, name, shape, place, dtype, known_dtype=None):
        self.name = name
        self.shape = tuple(shape)
        self.place = place
        self.dtype_name = known_dtype if known_dtype is not None else dtype_name(dtype)

    @property
    def dtype(self):
        return DtypeOf(self)

    @property
    def ndim(self):
        return len(self.shape)

    def __getitem__(self, key):
        return Region(self, subscript(key)).checked()

    def ap(self, pattern, offset=0, **unsupported):
        if unsupported:
            raise Unsupported(
                f"`{self.name}.ap`'s {', '.join(unsupported)} is not supported"
            )
        pairs = []
        for pair in pattern:
            step, count = pair
            pairs.append([non_negative(step, "a step"), non_negative(count, "a count")])
        return Pattern(self, pairs, non_negative(offset or 0, "an offset"))

    def indirect(self, index, num_elem=None):
        if not isinstance(index, Tensor):
            raise KernelError(f"`{self.name}.indirect` takes an index tile")
        count = None if num_elem is None else non_negative(num_elem, "num_elem")
        return Indirect(self, index, count)

    def __bool__(self):
        raise Unsupported(f"the truth of tensor `{self.name}` is not defined")

    def __iter__(self):
        raise Unsupported(f"iterating over tensor `{self.name}` is not supported")

    def __repr__(self):
        return self.name

    def wire(self):
        return {"tensor": self.name}


def subscript(key):
    keys = key if isinstance(key, tuple) else (key,)
    dims = []
    for item in keys:
        if isinstance(item, slice):
            if item.step is not None:
                raise Unsupported("a tensor slice with a step is not supported")
            bounds = [
                None if bound is None else non_negative(bound, "a slice bound")
                for bound in (item.start, item.stop)
            ]
            dims.append({"slice": bounds})
        elif is_int(item):
            dims.append({"index": non_negative(item, "an index")})
        else:
            raise Unsupported(
                f"a tensor index must be an integer or a slice, not `{item!r}`"
            )
    return dims


def resolve(dims, extents):
    """`dims` against `extents`, numpy's rule: trailing dimensions omitted are whole."""
    if len(dims) > len(extents):
        raise KernelError(
            f"{len(dims)} indices into a tensor of {len(extents)} dimensions"
        )
    dims = dims + [{"slice": [None, None]}] * (len(extents) - len(dims))
    selected = []
    for dimension, (dim, extent) in enumerate(zip(dims, extents)):
        if "index" in dim:
            if dim["index"] >= extent:
                raise KernelError(
                    f"index {dim['index']} of dimension {dimension} is outside {extent}"
                )
            selected.append(("index", dim["index"]))
        else:
            start, stop = dim["slice"]
            start = 0 if start is None else start
            stop = extent if stop is None else stop
            if not start < stop <= extent:
                raise KernelError(
                    f"slice {start}:{stop} of dimension {dimension} is empty or outside {extent}"
                )
            selected.append(("slice", start, stop - start))
    return selected


class Region:
    """A rectangular region of a tensor, its subscript as written."""

    def __init__(self, tensor, dims):
        self.tensor = tensor
        self.dims = dims

    def checked(self):
        self.selected = resolve(self.dims, self.tensor.shape)
        return self

    @property
    def shape(self):
        return tuple(sel[2] for sel in self.selected if sel[0] == "slice")

    @property
    def dtype(self):
        return self.tensor.dtype

    def __getitem__(self, key):
        """A region of this region: the two compose to one rectangle of the tensor."""
        kept = [i for i, sel in enumerate(self.selected) if sel[0] == "slice"]
        inner = resolve(subscript(key), [self.selected[i][2] for i in kept])
        dims = []
        for sel in self.selected:
            dims.append({"index": sel[1]} if sel[0] == "index" else None)
        for position, sel in zip(kept, inner):
            start = self.selected[position][1]
            if sel[0] == "index":
                dims[position] = {"index": start + sel[1]}
            else:
                dims[position] = {"slice": [start + sel[1], start + sel[1] + sel[2]]}
        return Region(self.tensor, dims).checked()

    def __bool__(self):
        raise Unsupported(
            f"the truth of a region of `{self.tensor.name}` is not defined"
        )

    def wire(self):
        return {"region": {"tensor": self.tensor.name, "dims": self.dims}}


class Pattern:
    def __init__(self, tensor, pattern, offset):
        self.tensor = tensor
        self.pattern = pattern
        self.offset = offset

    @property
    def shape(self):
        return tuple(count for _, count in self.pattern)

    @property
    def dtype(self):
        return self.tensor.dtype

    def wire(self):
        return {
            "pattern": {
                "tensor": self.tensor.name,
                "pattern": self.pattern,
                "offset": self.offset,
            }
        }


class Indirect:
    def __init__(self, tensor, index, count):
        self.tensor = tensor
        self.index = index
        self.count = count

    def wire(self):
        return {
            "indirect": {
                "tensor": self.tensor.name,
                "index": self.index.name,
                "count": self.count,
            }
        }


class Broadcast:
    def __init__(self, tensor, shape):
        self.tensor = tensor
        self.shape = shape

    def wire(self):
        return {"broadcast": {"tensor": self.tensor.name, "shape": list(self.shape)}}


def is_int(value):
    if isinstance(value, bool):
        return False
    if isinstance(value, int):
        return True
    return (
        type(value).__module__ == "numpy"
        and hasattr(value, "dtype")
        and value.dtype.kind in "iu"
    )


def non_negative(value, what):
    if not is_int(value):
        raise KernelError(f"{what} must be an integer, not `{value!r}`")
    value = int(value)
    if value < 0:
        raise Unsupported(f"{what} must not be negative, not {value}")
    return value


def operand(keyword, value):
    """The wire form of instruction operand `keyword`."""
    if isinstance(value, (Tensor, Region, Pattern, Indirect, Broadcast)):
        return value.wire()
    if isinstance(value, Member):
        return {"member": value._path}
    if isinstance(value, DtypeOf):
        name = value.name()
        if name is None:
            raise Unsupported(f"operand `{keyword}` needs the call to give `{value!r}`")
        return {"member": f"{NKI_LANGUAGE}.{name}"}
    if value is None:
        return {"none": None}
    if isinstance(value, bool):
        return {"bool": value}
    if is_int(value):
        return {"int": non_negative(value, f"integer operand `{keyword}`")}
    if isinstance(value, float) or (
        type(value).__module__ == "numpy" and hasattr(value, "dtype")
    ):
        value = float(value)
        if not math.isfinite(value):
            raise Unsupported(f"operand `{keyword}` is not finite: {value}")
        return {"scalar": value}
    if isinstance(value, (tuple, list)):
        return {
            "ints": [
                non_negative(item, f"an item of operand `{keyword}`") for item in value
            ]
        }
    raise Unsupported(
        f"operand `{keyword}` of type `{type(value).__name__}` is not supported"
    )


# =============================================================================
# Naming
# =============================================================================

_MODULE_TREES = {}


def _tree(filename):
    if filename not in _MODULE_TREES:
        try:
            _MODULE_TREES[filename] = ast.parse(Path(filename).read_text())
        except (OSError, SyntaxError):
            _MODULE_TREES[filename] = None
    return _MODULE_TREES[filename]


def _target(frame):
    """The name the statement running in `frame` binds its current call's value to: `x`
    for `x = call(...)` and `obj.x = call(...)`."""
    positions = list(frame.f_code.co_positions())
    index = frame.f_lasti // 2
    if index >= len(positions):
        return None
    lineno, end_lineno, col, end_col = positions[index]
    tree = _tree(frame.f_code.co_filename)
    if tree is None or lineno is None:
        return None
    for node in ast.walk(tree):
        if isinstance(node, (ast.Assign, ast.AnnAssign)) and node.value is not None:
            value = node.value
            span = (
                value.lineno,
                value.end_lineno,
                value.col_offset,
                value.end_col_offset,
            )
            if span == (lineno, end_lineno, col, end_col):
                target = (
                    node.targets[0] if isinstance(node, ast.Assign) else node.target
                )
                if isinstance(target, ast.Name):
                    return target.id
                if isinstance(target, ast.Attribute):
                    return target.attr
    return None


def caller_frame():
    frame = sys._getframe(1)
    while frame is not None and Path(frame.f_code.co_filename).resolve().is_relative_to(
        STAND_IN
    ):
        frame = frame.f_back
    return frame


def tensor_name(name=None):
    """A unique name for the tensor the kernel is declaring: `name=` if given, else its
    assignment target; prefixed by each helper call it is declared in, outermost first, and
    suffixed by each enclosing NKI loop's index."""
    frame = caller_frame()
    base = name or (_target(frame) if frame is not None else None) or "t"
    prefixes = []
    while frame is not None and frame.f_code is not TRACE.kernel_code:
        code = frame.f_code
        if frame not in TRACE.helper_calls:
            count = TRACE.helper_counts.get(code.co_qualname, 0)
            TRACE.helper_counts[code.co_qualname] = count + 1
            TRACE.helper_calls[frame] = count
        prefixes.append(f"{code.co_qualname}[{TRACE.helper_calls[frame]}].")
        frame = frame.f_back
    suffix = "".join(f".{loop['index']}" for loop in TRACE.loops)
    return TRACE.unique("".join(reversed(prefixes)) + base + suffix)


# =============================================================================
# Declarations
# =============================================================================


def extents(shape, what):
    if not isinstance(shape, (tuple, list)) or not shape:
        raise KernelError(f"{what}'s shape must be a non-empty tuple, not `{shape!r}`")
    result = []
    for extent in shape:
        extent = non_negative(extent, f"an extent of {what}")
        if extent == 0:
            raise KernelError(f"{what}'s extents must be positive")
        result.append(extent)
    return result


def declare_hbm(shape, dtype, name=None):
    shape = extents(shape, "an HBM tensor")
    tensor = Tensor(tensor_name(name), shape, "hbm", dtype)
    TRACE.body.append(
        {
            "declare_hbm": {
                "name": tensor.name,
                "shape": shape,
                "dtype": wire_dtype(dtype),
            }
        }
    )
    return tensor


def declare_tile(shape, dtype, buffer, address=None, name=None):
    shape = extents(shape, "a tile")
    if len(shape) < 2:
        raise KernelError("a tile's shape must be `(partitions, free, ...)`")
    if not 1 <= shape[0] <= PARTITIONS_MAX:
        raise KernelError(
            f"a tile spans 1 to {PARTITIONS_MAX} partitions, not {shape[0]}"
        )
    placed = None if address is None else place(address, shape, dtype, buffer)
    tensor = Tensor(tensor_name(name), shape, buffer, dtype)
    TRACE.body.append(
        {
            "declare": {
                "name": tensor.name,
                "shape": shape,
                "dtype": wire_dtype(dtype),
                "buffer": buffer,
                "address": placed,
            }
        }
    )
    return tensor


def place(address, shape, dtype, buffer):
    if not isinstance(address, tuple) or len(address) != 2:
        raise KernelError(
            f"`address=` must be a `(partition, offset)` tuple, not `{address!r}`"
        )
    partition = non_negative(address[0], "a partition offset")
    offset = non_negative(address[1], "a byte offset")
    name = dtype_name(dtype)
    if name is None:
        raise Unsupported(
            f"a tile placed by `address=` needs the call to give `{dtype!r}`"
        )
    if name not in ELEMENT_BYTES:
        raise Unsupported(
            f"a tile placed by `address=` of dtype `{name}` is not supported"
        )
    element_bytes = ELEMENT_BYTES[name]
    free = math.prod(shape[1:])
    capacity = (
        TRACE.tile_sizes.sbuf_fmax_bytes if buffer == "sbuf" else PSUM_PARTITION_BYTES
    )
    if (
        partition + shape[0] > PARTITIONS_MAX
        or offset + free * element_bytes > capacity
    ):
        raise KernelError(
            f"a tile of {shape[0]} partitions of {free} {element_bytes}-byte elements at "
            f"({partition}, {offset}) does not fit in `nl.{buffer}`"
        )
    return {"partition": partition, "offset": offset, "element_bytes": element_bytes}
