"""Helpers for helper_call.py, a module it imports from."""
import nki.language as nl
import nki.isa as nisa


class Unused(nl.NKIObject):
    def method(self):
        return -1 if self else {"never": "parsed"}


def row_sums(data, axes=(1,)):
    """Each partition of `data` summed into a [partitions, 1] tile."""
    shape = list(data.shape)
    for axis in axes:
        shape[axis] = 1
    shape = tuple(shape)
    sums = nl.ndarray(shape, dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_reduce(dst=sums, data=data, op=nl.add, axis=axes)
    return sums


def unused(x):
    if x % 2 == 0:
        return f"{x} is even"
