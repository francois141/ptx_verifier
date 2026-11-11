import nki
import nki.language as nl
import nki.isa as nisa


# Each row of `a` holds a 2 x 3 matrix; `t` is it transposed, through a strided HBM view.
# `out`'s first three columns sum each row of `t`, the second three are `t`'s second
# column, read through an offset view of the tile.
@nki.jit
def kernel(a):
    out = nl.ndarray((2, 6), dtype=nl.float32, buffer=nl.shared_hbm)
    t = nl.ndarray((2, 3, 2), dtype=nl.float32, buffer=nl.sbuf)
    nisa.dma_copy(dst=t, src=a.ap([[6, 2], [1, 3], [3, 2]]))
    sums = nl.ndarray((2, 3), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_reduce(dst=sums, data=t, op=nl.add, axis=(2,))
    nisa.dma_copy(dst=out[:, 0:3], src=sums)
    nisa.dma_copy(dst=out[:, 3:6], src=t.ap(pattern=[[6, 2], [2, 3]], offset=1))
    return out
