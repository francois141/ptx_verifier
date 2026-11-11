import nki
import nki.language as nl
import nki.isa as nisa


# A tile's first pair steps over its partitions, so it must step its free size, 6.
@nki.jit
def partition_step(a):
    t = nl.ndarray((2, 6), dtype=nl.float32, buffer=nl.sbuf)
    u = nl.ndarray((2, 3), dtype=nl.float32, buffer=nl.sbuf)
    nisa.dma_copy(dst=t, src=a)
    nisa.tensor_copy(dst=u, src=t.ap([[3, 2], [1, 3]]))


# From offset 3, partition 0's four elements reach into partition 1.
@nki.jit
def crossing_partitions(a):
    t = nl.ndarray((2, 6), dtype=nl.float32, buffer=nl.sbuf)
    u = nl.ndarray((1, 4), dtype=nl.float32, buffer=nl.sbuf)
    nisa.dma_copy(dst=t, src=a)
    nisa.tensor_copy(dst=u, src=t.ap([[6, 1], [1, 4]], offset=3))


# The last element is at 6 + 6, past `a`'s twelve.
@nki.jit
def out_of_bounds(a):
    t = nl.ndarray((2, 7), dtype=nl.float32, buffer=nl.sbuf)
    nisa.dma_copy(dst=t, src=a.ap([[6, 2], [1, 7]]))


# Axis 1 of a 3-D tile is not a trailing axis.
@nki.jit
def leading_axis(a):
    t = nl.ndarray((2, 3, 2), dtype=nl.float32, buffer=nl.sbuf)
    u = nl.ndarray((2, 2), dtype=nl.float32, buffer=nl.sbuf)
    nisa.dma_copy(dst=t, src=a)
    nisa.tensor_reduce(dst=u, data=t, op=nl.add, axis=(1,))
