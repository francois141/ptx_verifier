import nki
import nki.language as nl
import nki.isa as nisa

@nki.jit
def kernel(a, b):
    assert a.shape == (2, 4)
    assert b.shape == (2, 4)

    # The output is allocated in device memory and returned, as in NKI's attention samples,
    # rather than passed in as an argument.
    kernel_out = nl.ndarray((2, 4), dtype=a.dtype, buffer=nl.shared_hbm)

    x = nl.ndarray((2, 4), dtype=a.dtype, buffer=nl.sbuf)
    y = nl.ndarray((2, 4), dtype=b.dtype, buffer=nl.sbuf)
    z = nl.ndarray((2, 4), dtype=a.dtype, buffer=nl.sbuf)

    nisa.dma_copy(dst=x, src=a)
    nisa.dma_copy(dst=y, src=b)
    nisa.tensor_tensor(dst=z, data1=x, data2=y, op=nl.multiply)
    nisa.dma_copy(dst=kernel_out, src=z)
    return kernel_out
