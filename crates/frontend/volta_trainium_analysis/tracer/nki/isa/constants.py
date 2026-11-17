"""The stand-in `nki.isa.constants`: the enums `nki.isa` re-exports (`dge_mode`, `oob_mode`,
`matmul_perf_mode`, ...), so each member keeps its `nki.isa.*` path."""

from .._trace import NKI_ISA, Member


def __getattr__(name):
    if name.startswith("__"):
        raise AttributeError(name)
    return Member(f"{NKI_ISA}.{name}")
