import nki
import nki.language as nl
import nki.isa as nisa


# Doubles a 2 x 4 tensor one column pair at a time, so that each instruction's origin
# records nested loops of every kind, an inner loop entered twice and a helper call in a
# no_reorder block.
@nki.jit
def kernel(a, out):
    assert a.shape == (2, 4)
    assert out.shape == (2, 4)
    for i in nl.affine_range(2):
        for _ in nl.static_range(1):
            x = nl.ndarray((2, 2), dtype=a.dtype, buffer=nl.sbuf)
            nisa.dma_copy(dst=x, src=a[:, i * 2:(i + 1) * 2])
            with nl.no_reorder():
                y = double(x)
            nisa.dma_copy(dst=out[:, i * 2:(i + 1) * 2], src=y)


def double(x):
    y = nl.ndarray(x.shape, dtype=nl.float32, buffer=nl.sbuf)
    for _ in nl.sequential_range(1):
        nisa.tensor_scalar(dst=y, data=x, op0=nl.multiply, operand0=2.0)
    return y
