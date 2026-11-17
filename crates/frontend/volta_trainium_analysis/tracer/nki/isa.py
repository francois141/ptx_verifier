"""The stand-in `nki.isa`: calling any `nisa.<opcode>` records that instruction with its
operands by keyword, for lowering to accept or reject; its other members (`engine`,
`reduce_cmd`, ...) are `Member`s passed by their dotted paths."""

from . import _trace
from ._trace import NKI_ISA, KernelError, Member, Unsupported, operand

# The leading parameters an instruction may take by position, in its docs' order; every
# other operand must be given by keyword, so each operand's role is explicit.
POSITIONAL = {
    "dma_copy": ("dst", "src"),
    "tensor_copy": ("dst", "src"),
    "nc_matmul": ("dst", "stationary", "moving"),
    "nc_transpose": ("dst", "data"),
}

# Members that are queries of the hardware rather than instructions.
QUERIES = {"get_nc_version", "get_nc_sub_version"}


class _Opcode(Member):
    def __call__(self, *args, **kwargs):
        opcode = self.member_of(NKI_ISA)
        if opcode in QUERIES:
            raise Unsupported(
                f"`nisa.{opcode}()`: which NeuronCore Volta models is not decided"
            )
        if "." in opcode:
            raise Unsupported(f"`{self._path}` is not supported")
        params = POSITIONAL.get(opcode, ())
        if len(args) > len(params):
            raise Unsupported(
                f"`nisa.{opcode}` takes at most {len(params)} operands by position, the rest by keyword"
            )
        operands = {}
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
