"""The stand-in `nki.isa`: calling any `nisa.<opcode>` records that instruction with its
operands by keyword, for lowering to accept or reject; its other members (`engine`,
`reduce_cmd`, ...) are `Member`s passed by their dotted paths."""

import functools

from .. import _trace
from .._trace import NKI_ISA, KernelError, Member, Unsupported, operand

# Each instruction's parameters in the order AWS's `nki.isa` reference declares them, so a
# positional operand gets its documented keyword; an instruction not listed takes keywords only.
POSITIONAL = {
    "memset": ("dst", "value", "engine"),
    "tensor_tensor": ("dst", "data1", "data2", "op", "engine"),
    "tensor_scalar": (
        "dst",
        "data",
        "op0",
        "operand0",
        "reverse0",
        "op1",
        "operand1",
        "reverse1",
        "engine",
    ),
    "activation": (
        "dst",
        "op",
        "data",
        "bias",
        "scale",
        "reduce_op",
        "reduce_res",
        "reduce_cmd",
        "engine",
    ),
    "activation_reduce": (
        "dst",
        "op",
        "data",
        "reduce_op",
        "reduce_res",
        "bias",
        "scale",
    ),
    "tensor_reduce": ("dst", "op", "data", "axis", "negate", "keepdims"),
    "tensor_copy": ("dst", "src", "engine"),
    "dma_copy": ("dst", "src", "priority", "oob_mode", "dge_mode", "engine"),
    "dma_transpose": ("dst", "src", "axes", "priority", "dge_mode", "oob_mode"),
    "nc_matmul": (
        "dst",
        "stationary",
        "moving",
        "is_stationary_onezero",
        "is_moving_onezero",
        "is_transpose",
        "accumulate",
        "tile_position",
        "tile_size",
        "perf_mode",
    ),
    "nc_transpose": ("dst", "data", "engine"),
    "iota": ("dst", "pattern", "offset", "channel_multiplier"),
    "range_select": (
        "dst",
        "on_true_tile",
        "comp_op0",
        "comp_op1",
        "bound0",
        "bound1",
        "reduce_cmd",
        "reduce_res",
        "reduce_op",
        "range_start",
        "on_false_value",
    ),
    "affine_select": (
        "dst",
        "pattern",
        "offset",
        "channel_multiplier",
        "on_true_tile",
        "on_false_value",
        "cmp_op",
    ),
    "tensor_tensor_scan": (
        "dst",
        "data0",
        "data1",
        "initial",
        "op0",
        "op1",
        "reverse0",
        "reverse1",
    ),
    "tensor_scalar_cumulative": (
        "dst",
        "src",
        "op0",
        "op1",
        "imm0",
        "imm1",
        "reduce_cmd",
    ),
    "scalar_tensor_tensor": (
        "dst",
        "data",
        "op0",
        "operand0",
        "op1",
        "operand1",
        "reverse0",
        "reverse1",
        "reduce_cmd",
        "reduce_op",
        "reduce_res",
    ),
    "reciprocal": ("dst", "data"),
    "tensor_copy_predicated": ("dst", "src", "predicate", "reverse_pred"),
    "select_reduce": (
        "dst",
        "predicate",
        "on_true",
        "on_false",
        "reduce_res",
        "reduce_cmd",
        "reduce_op",
        "reverse_pred",
    ),
    "nc_n_gather": ("dst", "data", "indices"),
    "tensor_partition_reduce": ("dst", "op", "data"),
    "max8": ("dst", "src"),
}

# Members that are queries of the hardware rather than instructions.
QUERIES = {"get_nc_sub_version"}


@functools.total_ordering
class NcVersion(Member):
    """`nisa.nc_version.gen<n>`, ordered by generation (kernels compare with `>=`, and with
    plain integers); gen3 is Trn2's NeuronCore and gen4 Trn3's."""

    def __init__(self, generation):
        super().__init__(f"{NKI_ISA}.nc_version.gen{generation}")
        self.generation = generation

    def _key(self, other):
        if isinstance(other, NcVersion):
            return other.generation
        if isinstance(other, int) and not isinstance(other, bool):
            return other
        return NotImplemented

    def __eq__(self, other):
        key = self._key(other)
        return key if key is NotImplemented else self.generation == key

    def __lt__(self, other):
        key = self._key(other)
        return key if key is NotImplemented else self.generation < key

    def __hash__(self):
        return hash(self._path)

    def __int__(self):
        return self.generation


class _NcVersions:
    def __getattr__(self, name):
        if not (name.startswith("gen") and name[3:].isdigit()):
            raise AttributeError(name)
        return NcVersion(int(name[3:]))


nc_version = _NcVersions()


def get_nc_version():
    """The NeuronCore the call is traced for, `TRACE.nc_version`."""
    return NcVersion(_trace.TRACE.nc_version)


class _Opcode(Member):
    def __call__(self, *args, **kwargs):
        opcode = self.member_of(NKI_ISA)
        if opcode in QUERIES:
            raise Unsupported(f"`nisa.{opcode}()` is not supported")
        if "." in opcode:
            raise Unsupported(f"`{self._path}` is not supported")
        params = POSITIONAL.get(opcode, ())
        if len(args) > len(params):
            raise Unsupported(
                f"`nisa.{opcode}` takes at most {len(params)} operands by position, the rest by keyword"
            )
        operands = {}
        kwargs.pop("name", None)
        for keyword, value in [*zip(params, args), *kwargs.items()]:
            if keyword in operands:
                raise KernelError(
                    f"operand `{keyword}` of `nisa.{opcode}` is given twice"
                )
            operands[keyword] = operand(keyword, value)
        _trace.TRACE.instruction(opcode, operands)


def __getattr__(name):
    if name.startswith("__"):
        raise AttributeError(name)
    return _Opcode(f"{NKI_ISA}.{name}")
