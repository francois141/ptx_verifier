"""The stand-in `nki.collectives`: cross-core collectives, which Volta does not model, so
using any of its members (beyond importing them) is `Unsupported`."""

from ._trace import Member


def __getattr__(name):
    if name.startswith("__"):
        raise AttributeError(name)
    return Member(f"nki.collectives.{name}")
