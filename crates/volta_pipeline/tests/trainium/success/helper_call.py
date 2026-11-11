"""Calls a helper of another module twice; each call declares tiles of its own."""
import nki
import nki.language as nl
import nki.isa as nisa
from helpers import row_sums


@nki.jit
def kernel(a, b):
    """kernel_out[i] = sum_j a[i, j] + sum_j b[i, j]."""
    rows, cols = a.shape
    kernel_out = nl.ndarray((rows, 1), dtype=a.dtype, buffer=nl.shared_hbm)
    x = nl.ndarray(a.shape, dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a)
    y = nl.ndarray(b.shape, dtype=b.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=y, src=b)

    a_sums = row_sums(x)
    b_sums = row_sums(y, axes=(1,))
    total = nl.ndarray((rows, 1), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_tensor(dst=total, data1=a_sums, data2=b_sums, op=nl.add)
    nisa.dma_copy(dst=kernel_out, src=total)
    return kernel_out


def unused_in_this_module():
    return not True
