import nki
import nki.language as nl
import nki.isa as nisa


# back_to_back_dmas inside a no_reorder block: a write-after-write race, ordered if the
# policy keeps no_reorder blocks in program order (or orders write-after-write).
@nki.jit
def kernel(a, out):
    assert a.shape == (2, 4)
    assert out.shape == (1, 4)
    x = nl.ndarray((1, 4), dtype=a.dtype, buffer=nl.sbuf)
    with nl.no_reorder():
        nisa.dma_copy(dst=x, src=a[0:1, :])
        nisa.dma_copy(dst=x, src=a[1:2, :])
        nisa.dma_copy(dst=out, src=x)
