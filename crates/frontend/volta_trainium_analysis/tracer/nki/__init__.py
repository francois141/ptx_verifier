"""A stand-in for AWS's `nki` package that records the instructions a kernel call emits
instead of compiling them, for Volta to verify. `trace.py` runs a kernel under it."""

from . import isa as isa, language as language, typing as typing
from ._trace import Member


def jit(function=None, **options):
    """`@nki.jit` and `@nki.jit(mode=...)`: the function itself, traced when Volta calls it."""
    if function is None:
        return lambda function: function
    return function


def __getattr__(name):
    if name.startswith("__"):
        raise AttributeError(name)
    return Member(f"nki.{name}")
