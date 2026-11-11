import nki
import nki.language as nl
import nki.isa as nisa

@nki.jit
def kernel(a, b):
    # Sized from the call's shapes, as the attention kernels are.
    rows, cols = a.shape
    width = cols
    PMAX = nl.tile_size.pmax
    assert a.shape == b.shape == (rows, width)
    assert rows <= PMAX
    assert cols >= 4

    kernel_out = nl.ndarray((rows, width), dtype=a.dtype, buffer=nl.shared_hbm)

    # kernel_out = a + b, one half of the columns at a time.
    half = cols // 2
    for i in nl.affine_range(2):
        x = nl.ndarray((rows, half), dtype=a.dtype, buffer=nl.sbuf)
        y = nl.ndarray(x.shape, dtype=b.dtype, buffer=nl.sbuf)
        z = nl.ndarray(x.shape, dtype=a.dtype, buffer=nl.sbuf)
        nisa.dma_copy(dst=x, src=a[:, i * half:(i + 1) * half])
        nisa.dma_copy(dst=y, src=b[:, i * half:(i + 1) * half])
        nisa.tensor_tensor(dst=z, data1=x, data2=y, op=nl.add)
        nisa.dma_copy(dst=kernel_out[:, i * half:(i + 1) * half], src=z)

    return kernel_out
