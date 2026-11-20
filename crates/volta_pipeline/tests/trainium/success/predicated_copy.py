import numpy as np

import nki
import nki.language as nl
import nki.isa as nisa


# nkilib attention_tkg's masked score eviction: a tile set to -inf, then a
# tensor_copy_predicated of `a` where the (symbolic) mask is nonzero, and its row maxima;
# and the reverse_pred copy into a zeroed tile.
@nki.jit
def kernel(a, mask, out, row_max, kept):
    assert a.shape == (2, 4)
    assert mask.shape == (2, 4)
    assert out.shape == (2, 4)
    assert row_max.shape == (2, 1)
    assert kept.shape == (2, 4)
    x = nl.ndarray((2, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a)
    m = nl.ndarray((2, 4), dtype=mask.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=m, src=mask)

    scores = nl.ndarray((2, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.memset(dst=scores, value=-np.inf)
    nisa.tensor_copy_predicated(dst=scores, src=x, predicate=m)
    nisa.dma_copy(dst=out, src=scores)
    r = nl.ndarray((2, 1), dtype=a.dtype, buffer=nl.sbuf)
    nisa.tensor_reduce(dst=r, op=nl.maximum, data=scores, axis=1)
    nisa.dma_copy(dst=row_max, src=r)

    z = nl.ndarray((2, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.memset(dst=z, value=0.0)
    nisa.tensor_copy_predicated(dst=z, src=x, predicate=m, reverse_pred=True)
    nisa.dma_copy(dst=kept, src=z)
