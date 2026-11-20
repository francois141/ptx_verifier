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
    nc_version: int = 3
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


def reset(tile_sizes, nc_version):
    global TRACE
    TRACE = Trace(tile_sizes=tile_sizes, nc_version=nc_version)
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

    def __str__(self):
        """A `nki.language` member's bare name, as kernels compare dtypes by `str`."""
        name = self.member_of(NKI_LANGUAGE)
        return self._path if name is None else name

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
        if other is None:
            return False
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

    def __str__(self):
        if self.name() is None:
            raise Unsupported(f"`str({self!r})` needs the call to give its dtype")
        return self.name()


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


def _strides(shape):
    strides, step = [], 1
    for extent in reversed(shape):
        strides.append(step)
        step *= extent
    return list(reversed(strides))


class Views:
    """NKI's view methods (`nki.language.NkiTensor`): each returns a `Pattern` sharing the
    tensor's storage, an element offset and `[step, count]` pairs over its row-major
    layout, as the docs define them. On-chip, dimension 0 is the partitions and stays put."""

    def pattern_view(self):
        raise NotImplementedError

    def _on_chip(self):
        return self.pattern_view().tensor.place != "hbm"

    def _with(self, pairs, offset):
        view = self.pattern_view()
        return Pattern(view.tensor, [list(pair) for pair in pairs], offset)

    def _dim(self, dim, what):
        rank = len(self.pattern_view().pattern)
        dim = non_negative(dim, f"{what}'s dimension")
        if dim >= rank:
            raise KernelError(f"{what}'s dimension {dim} is outside a view of {rank}")
        if dim == 0 and self._on_chip():
            raise KernelError(
                f"{what} may not change an on-chip tile's partition dimension"
            )
        return dim

    def get_pattern(self):
        return [list(pair) for pair in self.pattern_view().pattern]

    @property
    def strides(self):
        return tuple(step for step, _ in self.pattern_view().pattern)

    @property
    def offset(self):
        return self.pattern_view().offset

    @property
    def size(self):
        return math.prod(count for _, count in self.pattern_view().pattern)

    @property
    def ndim(self):
        return len(self.pattern_view().pattern)

    @property
    def buffer(self):
        return Member(f"{NKI_LANGUAGE}.{self.pattern_view().tensor.place}")

    def is_contiguous(self):
        pairs = self.pattern_view().pattern
        free = pairs[1:] if self._on_chip() else pairs
        expected = 1
        for step, count in reversed(free):
            if count != 1 and step != expected:
                return False
            expected *= count
        return True

    def slice(self, dim, start, end, step=1):
        view = self.pattern_view()
        rank = len(view.pattern)
        dim = non_negative(dim, "`slice`'s dimension")
        if dim >= rank:
            raise KernelError(f"`slice`'s dimension {dim} is outside a view of {rank}")
        stride, count = view.pattern[dim]
        start, end = (
            non_negative(start, "`slice`'s start"),
            non_negative(end, "`slice`'s end"),
        )
        step = non_negative(step, "`slice`'s step")
        if not (start < end <= count and step >= 1):
            raise KernelError(
                f"`slice({dim}, {start}, {end}, {step})` of extent {count}"
            )
        pairs = view.pattern[:]
        pairs[dim] = [stride * step, -(-(end - start) // step)]
        return self._with(pairs, view.offset + start * stride)

    def select(self, dim, index):
        view = self.pattern_view()
        if not is_int(index):
            raise Unsupported("`select` of a runtime index is not supported")
        dim = self._dim(dim, "`select`")
        stride, count = view.pattern[dim]
        index = non_negative(index, "`select`'s index")
        if index >= count:
            raise KernelError(f"`select({dim}, {index})` of extent {count}")
        pairs = view.pattern[:dim] + view.pattern[dim + 1 :]
        return self._with(pairs, view.offset + index * stride)

    def reshape_dim(self, dim, shape):
        view = self.pattern_view()
        dim = non_negative(dim, "`reshape_dim`'s dimension")
        stride, count = view.pattern[dim]
        shape = _infer(list(shape), count, "`reshape_dim`")
        if dim == 0 and self._on_chip() and len(shape) != 1:
            raise KernelError(
                "`reshape_dim` may not split an on-chip tile's partitions"
            )
        inner = _strides(shape)
        split = [[stride * step, extent] for step, extent in zip(inner, shape)]
        return self._with(
            view.pattern[:dim] + split + view.pattern[dim + 1 :], view.offset
        )

    def reshape(self, *shape, **keyword):
        view = self.pattern_view()
        if "shape" in keyword:
            shape = (keyword.pop("shape"),)
        if keyword:
            raise KernelError(f"`reshape` takes no {', '.join(keyword)}")
        shape = (
            list(shape[0])
            if len(shape) == 1 and isinstance(shape[0], (tuple, list))
            else list(shape)
        )
        shape = _infer(shape, self.size, "`reshape`")
        if not self.is_contiguous():
            raise Unsupported("`reshape` of a non-contiguous view is not supported")
        if self._on_chip():
            partition_step, partitions = view.pattern[0]
            if shape[0] != partitions:
                raise KernelError(
                    "`reshape` of an on-chip tile must keep its partitions"
                )
            pairs = [[partition_step, partitions]]
            pairs += [
                [step, extent] for step, extent in zip(_strides(shape[1:]), shape[1:])
            ]
        else:
            pairs = [[step, extent] for step, extent in zip(_strides(shape), shape)]
        return self._with(pairs, view.offset)

    def permute(self, *dims, **keyword):
        view = self.pattern_view()
        if "dims" in keyword:
            dims = (keyword.pop("dims"),)
        if keyword:
            raise KernelError(f"`permute` takes no {', '.join(keyword)}")
        dims = (
            list(dims[0])
            if len(dims) == 1 and isinstance(dims[0], (tuple, list))
            else list(dims)
        )
        if sorted(dims) != list(range(len(view.pattern))):
            raise KernelError(
                f"`permute({dims})` is not a permutation of a view of {len(view.pattern)}"
            )
        if self._on_chip() and dims[0] != 0:
            raise KernelError("`permute` must keep an on-chip tile's partitions first")
        return self._with([view.pattern[d] for d in dims], view.offset)

    def flatten_dims(self, start_dim, end_dim):
        view = self.pattern_view()
        if start_dim == 0 and self._on_chip():
            raise KernelError(
                "`flatten_dims` may not merge an on-chip tile's partitions"
            )
        merged = view.pattern[start_dim : end_dim + 1]
        # A dimension of count 1 is contiguous with any other, whatever its step.
        merged = [pair for pair in merged if pair[1] != 1] or merged[-1:]
        for (step, _), (inner_step, inner_count) in zip(merged, merged[1:]):
            if step != inner_step * inner_count:
                raise KernelError(
                    "`flatten_dims` merges only dimensions contiguous in memory"
                )
        pair = [merged[-1][0], math.prod(count for _, count in merged)]
        return self._with(
            view.pattern[:start_dim] + [pair] + view.pattern[end_dim + 1 :], view.offset
        )

    def squeeze_dim(self, dim):
        view = self.pattern_view()
        dim = self._dim(dim, "`squeeze_dim`")
        if view.pattern[dim][1] != 1:
            raise KernelError(f"`squeeze_dim({dim})` of extent {view.pattern[dim][1]}")
        return self._with(view.pattern[:dim] + view.pattern[dim + 1 :], view.offset)

    def expand_dim(self, dim):
        view = self.pattern_view()
        dim = non_negative(dim, "`expand_dim`'s dimension")
        if dim == 0 and self._on_chip():
            raise KernelError(
                "`expand_dim` may not insert before an on-chip tile's partitions"
            )
        return self._with(
            view.pattern[:dim] + [[1, 1]] + view.pattern[dim:], view.offset
        )

    def broadcast(self, dim, size):
        view = self.pattern_view()
        dim = self._dim(dim, "`broadcast`")
        if view.pattern[dim][1] != 1:
            raise KernelError(
                f"`broadcast({dim}, {size})` of extent {view.pattern[dim][1]}"
            )
        pairs = view.pattern[:]
        pairs[dim] = [0, non_negative(size, "`broadcast`'s size")]
        return self._with(pairs, view.offset)

    def view(self, dtype):
        raise Unsupported(
            "reinterpreting a tensor's bits as another dtype is not modelled"
        )

    reinterpret_cast = view

    def rearrange(self, *args, **kwargs):
        raise Unsupported("`rearrange` is not supported")

    def vector_select(self, *args, **kwargs):
        raise Unsupported(
            "`vector_select` (runtime per-partition offsets) is not supported"
        )


def _infer(shape, total, what):
    if shape.count(-1) > 1:
        raise KernelError(f"{what} infers at most one extent")
    known = math.prod(extent for extent in shape if extent != -1)
    if -1 in shape:
        if known == 0 or total % known:
            raise KernelError(f"{what} cannot infer an extent of {shape} from {total}")
        shape[shape.index(-1)] = total // known
    shape = [non_negative(extent, f"an extent of {what}") for extent in shape]
    if math.prod(shape) != total:
        raise KernelError(f"{what} to {shape} changes the element count {total}")
    return shape


class Tensor(Views):
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

    def pattern_view(self):
        return Pattern(
            self,
            [[step, extent] for step, extent in zip(_strides(self.shape), self.shape)],
            0,
        )

    def __getitem__(self, key):
        keys = expand(key, len(self.shape))
        if _stepped(keys):
            return self.pattern_view()[keys]
        return Region(self, subscript(keys)).checked()

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


def expand(key, rank):
    """`key` as a tuple with its one `...` replaced by whole slices of the dimensions it spans."""
    keys = key if isinstance(key, tuple) else (key,)
    if keys.count(Ellipsis) > 1:
        raise KernelError("a subscript may hold at most one `...`")
    if Ellipsis in keys:
        at = keys.index(Ellipsis)
        whole = (slice(None),) * (rank - len(keys) + 1)
        keys = keys[:at] + whole + keys[at + 1 :]
    return keys


def _stepped(keys):
    """Whether a subscript has a slice with a step, which only a view can take."""
    return any(isinstance(item, slice) and item.step not in (None, 1) for item in keys)


def subscript(key):
    keys = key if isinstance(key, tuple) else (key,)
    dims = []
    for item in keys:
        if isinstance(item, slice):
            if item.step not in (None, 1):
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


class Region(Views):
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
        if _stepped(expand(key, len(kept))):
            return self.pattern_view()[key]
        inner = resolve(
            subscript(expand(key, len(kept))), [self.selected[i][2] for i in kept]
        )
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

    def pattern_view(self):
        steps = _strides(self.tensor.shape)
        offset = sum(step * sel[1] for step, sel in zip(steps, self.selected))
        pairs = [
            [step, sel[2]]
            for step, sel in zip(steps, self.selected)
            if sel[0] == "slice"
        ]
        return Pattern(self.tensor, pairs, offset)

    def ap(self, pattern, offset=None, **unsupported):
        return self.pattern_view().ap(pattern, offset, **unsupported)

    def __bool__(self):
        raise Unsupported(
            f"the truth of a region of `{self.tensor.name}` is not defined"
        )

    def wire(self):
        return {"region": {"tensor": self.tensor.name, "dims": self.dims}}


class Pattern(Views):
    """A view of `tensor`: element `local` at `offset + sum(step * local)` of its row-major
    layout, one `[step, count]` pair per dimension."""

    def __init__(self, tensor, pattern, offset):
        self.tensor = tensor
        self.pattern = pattern
        self._offset = offset

    def pattern_view(self):
        return self

    @property
    def offset(self):
        return self._offset

    def ap(self, pattern, offset=None, **unsupported):
        if offset is not None and self._offset != 0:
            raise Unsupported(
                "`.ap` with an offset of a view that has one is ambiguous in the docs"
            )
        base = self._offset if offset is None else offset
        return self.tensor.ap(pattern, base, **unsupported)

    def __getitem__(self, key):
        view = self
        dim = 0
        for item in expand(key, len(self.pattern)):
            if isinstance(item, slice):
                count = view.pattern[dim][1]
                start, stop, step = item.indices(count)
                if (
                    item.start is not None
                    and item.start < 0
                    or item.stop is not None
                    and item.stop < 0
                ):
                    raise Unsupported("a negative slice bound is not supported")
                view = view.slice(dim, start, stop, step)
                dim += 1
            elif is_int(item):
                view = view._select_any(dim, item)
            else:
                raise Unsupported(
                    f"a view index must be an integer or a slice, not `{item!r}`"
                )
        return view

    def _select_any(self, dim, index):
        stride, count = self.pattern[dim]
        index = non_negative(index, "an index")
        if index >= count:
            raise KernelError(f"index {index} of dimension {dim} is outside {count}")
        return Pattern(
            self.tensor,
            self.pattern[:dim] + self.pattern[dim + 1 :],
            self._offset + index * stride,
        )

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
                "offset": self._offset,
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
