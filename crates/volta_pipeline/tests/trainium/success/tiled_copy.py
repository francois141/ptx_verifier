import nki
import nki.language as nl
import nki.isa as nisa

@nki.jit
def kernel(a, out):
    assert a.shape == (8, 4)
    assert out.shape == (8, 4)

    # out = a, moved through SBUF one (4, 4) tile of rows at a time.
    for i in nl.affine_range(2):
        x = nl.ndarray((4, 4), dtype=a.dtype, buffer=nl.sbuf)
        nisa.dma_copy(dst=x, src=a[i * 4:(i + 1) * 4, :])
        nisa.dma_copy(dst=out[i * 4:(i + 1) * 4, :], src=x)
