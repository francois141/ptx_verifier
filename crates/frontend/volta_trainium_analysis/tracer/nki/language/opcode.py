"""The stand-in `nki.language.opcode`: the ALU operations, the same members as
`nki.language`'s (`opcode.maximum` is `nl.maximum`)."""

from .._trace import NKI_LANGUAGE, Member


def __getattr__(name):
    if name.startswith("__"):
        raise AttributeError(name)
    return Member(f"{NKI_LANGUAGE}.{name}")
