"""The stand-in `nki.language`: tensor declarations, loop iterators, `no_reorder`, and
the tile-returning functions, each rewritten into a declaration and the one `nki.isa`
instruction it lowers to. Any other member is a `Member` passed by its dotted path."""

from .. import _trace
from .._trace import (
    NKI_LANGUAGE,
    Broadcast,
    KernelError,
    Member,
    Pattern,
    Region,
    Tensor,
    Unsupported,
    declare_hbm,
    declare_tile,
    is_int,
    non_negative,
    operand,
    resolve,
)

sbuf = Member(f"{NKI_LANGUAGE}.sbuf")
psum = Member(f"{NKI_LANGUAGE}.psum")
shared_hbm = Member(f"{NKI_LANGUAGE}.shared_hbm")
# HBM private to one core: with one program traced (`SingleNkiInstance`), as `shared_hbm`.
private_hbm = Member(f"{NKI_LANGUAGE}.private_hbm")
HBM = (shared_hbm, private_hbm)
ON_CHIP = {sbuf: "sbuf", psum: "psum"}


def __getattr__(name):
    if name.startswith("__"):
        raise AttributeError(name)
    return Member(f"{NKI_LANGUAGE}.{name}")


class NKIObject:
    """The base of a kernel's own classes; a plain Python object when traced."""


class _Function(Member):
    """A `nki.language` function: callable, and also a member an instruction may take as
    an operand, as `activation(op=nl.exp)` does."""

    def __init__(self, function):
        super().__init__(f"{NKI_LANGUAGE}.{function.__name__}")
        self._function = function

    def __call__(self, *args, **kwargs):
        return self._function(*args, **kwargs)


def _member(function):
    return _Function(function)


class _TileSize:
    # A partition's SBUF the allocator may use; Volta takes it to be the whole partition.
    ALIASES = {"total_available_sbuf_size": "sbuf_fmax_bytes"}

    # A PSUM bank's free size in fp32 elements: one of Volta's eight 2 KiB banks.
    psum_fmax = 2048 // 4
    psum_bank_fmax = 2048 // 4

    def __init__(self):
        # Constants the docs name without a value (`sbuf_min_align`, ...): a wrapper that
        # needs one sets it here, stating its assumption in the open.
        self.__dict__["assumed"] = {}

    def __getattr__(self, name):
        if name in self.assumed:
            return self.assumed[name]
        name = self.ALIASES.get(name, name)
        if name.startswith("__") or not hasattr(_trace.TRACE.tile_sizes, name):
            raise Unsupported(f"`nl.tile_size.{name}` is not supported")
        return getattr(_trace.TRACE.tile_sizes, name)


tile_size = _TileSize()


# =============================================================================
# Declarations
# =============================================================================


def ndarray(shape, dtype, buffer=sbuf, name=None, address=None):
    if buffer in HBM:
        if address is not None:
            raise KernelError("`address=` places on-chip tiles only, not an HBM tensor")
        return declare_hbm(shape, dtype, name or None)
    return declare_tile(shape, dtype, _buffer(buffer), address, name or None)


def zeros(shape, dtype, buffer=sbuf, name=None):
    if buffer in HBM:
        raise KernelError(
            "`nl.zeros` allocates an on-chip tile only: `nl.sbuf` or `nl.psum`"
        )
    tile = declare_tile(shape, dtype, _buffer(buffer), None, name or None)
    _trace.TRACE.instruction("memset", {"dst": tile.wire(), "value": {"scalar": 0.0}})
    return tile


def shared_identity_matrix(n, dtype=None, dst=None, **kwargs):
    """The `n` x `n` identity: written into `dst`, else into a new SBUF tile, where every
    kernel calling it without `dst` uses it (as a matmul or transpose operand)."""
    if kwargs:
        raise Unsupported(
            f"`nl.shared_identity_matrix`'s `{next(iter(kwargs))}` is not supported"
        )
    n = non_negative(n, "`nl.shared_identity_matrix`'s size")
    tile = declare_tile((n, n), dtype, "sbuf") if dst is None else dst
    _trace.TRACE.instruction("shared_identity_matrix", {"dst": operand("dst", tile)})
    return tile


def _buffer(buffer):
    if buffer not in ON_CHIP:
        raise Unsupported(
            f"a tensor's buffer must be `nl.sbuf`, `nl.psum`, `nl.shared_hbm` or `nl.private_hbm`, not `{buffer!r}`"
        )
    return ON_CHIP[buffer]


def ds(start, size):
    start = non_negative(start, "`nl.ds`'s start")
    size = non_negative(size, "`nl.ds`'s size")
    if size == 0:
        raise KernelError("`nl.ds` needs a positive size")
    return slice(start, start + size)


# =============================================================================
# Loops and scheduling blocks
# =============================================================================


def _loop(kind, args):
    if not 1 <= len(args) <= 3 or not all(is_int(arg) for arg in args):
        raise KernelError(
            f"a loop over `{kind}_range` needs integer bounds, not {args!r}"
        )
    trace = _trace.TRACE
    loop = {"loop_id": trace.next_loop, "kind": kind, "index": 0}
    trace.next_loop += 1
    trace.loops.append(loop)
    try:
        for index, value in enumerate(range(*(int(arg) for arg in args))):
            loop["index"] = index
            yield value
    finally:
        trace.loops.remove(loop)


def affine_range(*args):
    return _loop("affine", args)


def sequential_range(*args):
    return _loop("sequential", args)


def static_range(*args):
    return _loop("static", args)


class no_reorder:
    """Forbids the scheduler to reorder the instructions its block emits; only the
    outermost block numbers a scheduling block."""

    def __enter__(self):
        trace = _trace.TRACE
        trace.no_reorder.append(
            trace.next_block if not trace.no_reorder else trace.no_reorder[0]
        )
        if len(trace.no_reorder) == 1:
            trace.next_block += 1
        return self

    def __exit__(self, *_):
        _trace.TRACE.no_reorder.pop()
        return False


# =============================================================================
# Tile-returning functions
# =============================================================================


def _extents(value, callee):
    """The tensor `value` reads and its shape: a tensor's, or a region's or view's."""
    if isinstance(value, Tensor):
        return value, list(value.shape)
    if isinstance(value, (Region, Pattern)):
        return value.tensor, list(value.shape)
    raise KernelError(f"`{callee}` reads a tensor, a region or a view, not `{value!r}`")


def _in_hbm(tensor, keyword, callee):
    if tensor.place != "hbm":
        raise KernelError(
            f"`{keyword}` of `{callee}` must be in HBM, not the tile `{tensor.name}`"
        )


def _tile(value, keyword, callee):
    if not isinstance(value, Tensor):
        raise KernelError(f"`{keyword}` of `{callee}` must be a tile, not `{value!r}`")
    return value


def _matrix(tile, callee):
    if len(tile.shape) != 2:
        raise KernelError(f"`{callee}` takes a two-dimensional tile, not `{tile.name}`")
    return tile.shape


def _emit(shape, buffer, dtype, opcode, operands):
    tile = declare_tile(shape, dtype, buffer)
    operands = dict(operands, dst=tile.wire())
    _trace.TRACE.instruction(opcode, operands)
    return tile


@_member
def load(src, **unsupported):
    _reject(unsupported, "nl.load")
    tensor, shape = _extents(src, "nl.load")
    _in_hbm(tensor, "src", "nl.load")
    return _emit(shape, "sbuf", tensor.dtype, "dma_copy", {"src": operand("src", src)})


@_member
def store(dst, value, **unsupported):
    _reject(unsupported, "nl.store")
    tensor, _ = _extents(dst, "nl.store")
    _in_hbm(tensor, "dst", "nl.store")
    _trace.TRACE.instruction(
        "dma_copy", {"dst": operand("dst", dst), "src": operand("src", value)}
    )


@_member
def matmul(x, y, transpose_x=False, **unsupported):
    _reject(unsupported, "nl.matmul")
    if transpose_x is not True:
        raise Unsupported(
            "`nl.matmul` is supported with `transpose_x=True` only, which computes `x.T @ y` "
            "as `nc_matmul` does"
        )
    x, y = _tile(x, "x", "nl.matmul"), _tile(y, "y", "nl.matmul")
    (_, rows), (_, columns) = _matrix(x, "nl.matmul"), _matrix(y, "nl.matmul")
    operands = {"stationary": x.wire(), "moving": y.wire()}
    return _emit(
        [rows, columns],
        "psum",
        Member(f"{NKI_LANGUAGE}.float32"),
        "nc_matmul",
        operands,
    )


def _reduce(x, axis, keepdims, op, callee):
    tensor, shape = _extents(x, callee)
    axes = (
        [non_negative(axis, "an axis")]
        if is_int(axis)
        else [non_negative(a, "an axis") for a in axis]
    )
    rank = len(shape)
    first = rank - len(axes)
    if first <= 0 or axes != list(range(first, rank)):
        raise KernelError(
            f"`{callee}` reduces a tile's trailing free axes, not {axes} of its {rank}"
        )
    if not isinstance(keepdims, bool):
        raise KernelError(
            f"`keepdims` of `{callee}` must be a bool, not `{keepdims!r}`"
        )
    reduced = shape[:first] + ([1] * len(axes) if keepdims else [])
    operands = {
        "data": operand("x", x),
        "op": {"member": f"{NKI_LANGUAGE}.{op}"},
        "axis": operand("axis", axis) if is_int(axis) else {"ints": axes},
    }
    return _emit(reduced, "sbuf", tensor.dtype, "tensor_reduce", operands)


@_member
def max(x, axis, keepdims=False, **unsupported):
    _reject(unsupported, "nl.max")
    return _reduce(x, axis, keepdims, "maximum", "nl.max")


@_member
def sum(x, axis, keepdims=False, **unsupported):
    _reject(unsupported, "nl.sum")
    return _reduce(x, axis, keepdims, "add", "nl.sum")


@_member
def exp(x, **unsupported):
    _reject(unsupported, "nl.exp")
    x = _tile(x, "x", "nl.exp")
    operands = {"data": x.wire(), "op": {"member": f"{NKI_LANGUAGE}.exp"}}
    return _emit(list(_matrix(x, "nl.exp")), "sbuf", x.dtype, "activation", operands)


@_member
def reciprocal(x, **unsupported):
    _reject(unsupported, "nl.reciprocal")
    x = _tile(x, "x", "nl.reciprocal")
    return _emit(
        list(_matrix(x, "nl.reciprocal")),
        "sbuf",
        x.dtype,
        "reciprocal",
        {"data": x.wire()},
    )


@_member
def transpose(x, **unsupported):
    _reject(unsupported, "nl.transpose")
    x = _tile(x, "x", "nl.transpose")
    partitions, free = _matrix(x, "nl.transpose")
    return _emit(
        [free, partitions], "psum", x.dtype, "nc_transpose", {"data": x.wire()}
    )


@_member
def broadcast_to(x, shape, dtype=None):
    if dtype is not None:
        raise Unsupported("`nl.broadcast_to`'s `dtype` is not supported")
    x = _tile(x, "x", "nl.broadcast_to")
    shape = [non_negative(extent, "an extent") for extent in shape]
    if len(shape) != len(x.shape) or any(
        a != b and a != 1 for a, b in zip(x.shape, shape)
    ):
        raise KernelError(
            f"`nl.broadcast_to` cannot broadcast `{x.name}` of shape {list(x.shape)} to {shape}: "
            "each dimension must match or be 1"
        )
    resolve([], shape)
    return _emit(
        shape, "sbuf", x.dtype, "tensor_copy", {"src": Broadcast(x, shape).wire()}
    )


def _reject(unsupported, callee):
    if unsupported:
        raise Unsupported(
            f"`{callee}`'s {', '.join(sorted(unsupported))} is not supported"
        )


# =============================================================================
# The launch grid
# =============================================================================
# A traced call is one program launched without a grid (Volta's `SingleNkiInstance`).


def program_ndim():
    return 0


def num_programs(axes=None):
    return 1


def program_id(axis=0):
    return 0
