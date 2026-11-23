from dataclasses import dataclass


@dataclass(frozen=True)
class T:
    """A tensor argument of this dtype (16-byte aligned, < 2 GB, as a real launch)."""
    dtype: str
