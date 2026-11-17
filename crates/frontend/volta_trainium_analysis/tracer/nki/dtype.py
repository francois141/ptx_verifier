"""The stand-in `nki.dtype`: element types, the same members as `nki.language`'s."""

from ._trace import NKI_LANGUAGE, Member


def __getattr__(name):
    if name.startswith("__"):
        raise AttributeError(name)
    return Member(f"{NKI_LANGUAGE}.{name}")
