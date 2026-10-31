import nki
import nki.language as nl
import nki.isa as nisa

@nki.jit
def kernel(a, b, out):
    x = nl.ndarray((128, 128), dtype=a.dtype, buffer=nl.sbuf)
    y = nl.ndarray((128, 128), dtype=b.dtype, buffer=nl.sbuf)
    z = nl.ndarray((128, 128), dtype=a.dtype, buffer=nl.sbuf)

    nisa.dma_copy(dst=x, src=a)
    nisa.dma_copy(dst=y, src=b)

    nisa.tensor_tensor(
        dst=z,
        data1=x,
        data2=y,
        op=nl.add
    )

    nisa.dma_copy(dst=out, src=z)
