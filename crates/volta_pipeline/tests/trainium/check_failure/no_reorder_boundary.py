import nki
import nki.language as nl
import nki.isa as nisa


# A tile written before a no_reorder block and rewritten inside it: the block orders only
# its own instructions, so the write before it races the rewrite and the read unless the
# policy orders write-after-write.
@nki.jit
def kernel(a, out):
    assert a.shape == (2, 4)
    assert out.shape == (1, 4)
    x = nl.ndarray((1, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a[0:1, :])
    with nl.no_reorder():
        nisa.dma_copy(dst=x, src=a[1:2, :])
        nisa.dma_copy(dst=out, src=x)
