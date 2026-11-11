import nki
import nki.language as nl
import nki.isa as nisa

@nki.jit
def kernel(a, b, out):
    assert a.shape == (16, 16)
    assert b.shape == (16, 16)
    assert out.shape == (16, 16)

    x = nl.ndarray((16, 16), dtype=a.dtype, buffer=nl.sbuf)
    y = nl.ndarray((16, 16), dtype=b.dtype, buffer=nl.sbuf)
    z = nl.ndarray((16, 16), dtype=a.dtype, buffer=nl.sbuf)

    nisa.dma_copy(dst=x, src=a)
    nisa.dma_copy(dst=y, src=b)

    nisa.tensor_tensor(
        dst=z,
        data1=x,
        data2=y,
        op=nl.add
    )

    nisa.dma_copy(dst=out, src=z)
