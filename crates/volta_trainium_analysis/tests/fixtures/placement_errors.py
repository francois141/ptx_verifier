import nki
import nki.language as nl
import nki.isa as nisa


# `half` covers bytes 4 to 8 of each partition, `acc`'s second column only.
@nki.jit
def clobbered_read(a):
    out = nl.ndarray((2, 1), dtype=nl.float32, buffer=nl.shared_hbm)
    acc = nl.ndarray((2, 3), dtype=nl.float32, buffer=nl.psum, address=(0, 0))
    half = nl.ndarray((2, 2), dtype=nl.bfloat16, buffer=nl.psum, address=(0, 4))
    column = nl.ndarray((2, 1), dtype=nl.float32, buffer=nl.sbuf, address=(0, 0))
    nisa.memset(dst=acc, value=1.0)
    nisa.memset(dst=half, value=2.0)
    nisa.tensor_copy(dst=column, src=acc[:, 0:1])
    nisa.tensor_copy(dst=column, src=acc[:, 2:3])
    nisa.tensor_copy(dst=column, src=acc[:, 1:2])
    nisa.dma_copy(dst=out, src=column)
    return out


@nki.jit
def accumulate_uninitialized(a_t, b):
    x = nl.ndarray((4, 2), dtype=nl.float32, buffer=nl.sbuf, address=(0, 0))
    y = nl.ndarray((4, 3), dtype=nl.float32, buffer=nl.sbuf, address=(0, 32))
    acc = nl.ndarray((2, 3), dtype=nl.float32, buffer=nl.psum, address=(0, 0))
    nisa.dma_copy(dst=x, src=a_t)
    nisa.dma_copy(dst=y, src=b)
    nisa.nc_matmul(dst=acc, stationary=x, moving=y, accumulate=True)


@nki.jit
def mixed_allocation(a):
    x = nl.ndarray((2, 4), dtype=nl.float32, buffer=nl.sbuf, address=(0, 0))
    y = nl.ndarray((2, 4), dtype=nl.float32, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a)
    nisa.tensor_copy(dst=y, src=x)


@nki.jit
def overflowing_psum(a):
    acc = nl.ndarray((2, 4096), dtype=nl.float32, buffer=nl.psum, address=(0, 4))
