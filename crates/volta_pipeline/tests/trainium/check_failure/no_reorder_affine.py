import nki
import nki.language as nl
import nki.isa as nisa


# affine_overwrite inside a no_reorder block: its iterations race under DataFlowOnly, and
# are ordered under DataFlowAndNoReorder, as the block orders every instruction under it,
# its loops' iterations included.
@nki.jit
def kernel(a, out):
    assert a.shape == (2, 4)
    assert out.shape == (2, 4)
    x = nl.ndarray((1, 4), dtype=a.dtype, buffer=nl.sbuf)
    with nl.no_reorder():
        for i in nl.affine_range(2):
            nisa.dma_copy(dst=x, src=a[i:i + 1, :])
            nisa.dma_copy(dst=out[i:i + 1, :], src=x)
