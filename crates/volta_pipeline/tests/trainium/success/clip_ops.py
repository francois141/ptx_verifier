import nki
import nki.language as nl
import nki.isa as nisa


# nl.minimum, as nkilib's rmsnorm_quant clips to float8's range: `a` clipped to [-1, 1] by a
# tensor_scalar, copied into a tile with an extent-1 free dimension (nkilib's output
# projection's view) and folded back with `a` by a tensor_tensor minimum across the two shapes.
@nki.jit
def kernel(a, out):
    assert a.shape == (2, 4)
    assert out.shape == (2, 4)
    x = nl.ndarray((2, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a)
    clipped = nl.ndarray((2, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.tensor_scalar(
        dst=clipped, data=x, op0=nl.minimum, operand0=1.0, op1=nl.maximum, operand1=-1.0
    )
    column = nl.ndarray((2, 1, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.tensor_copy(dst=column, src=clipped)
    y = nl.ndarray((2, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.tensor_tensor(dst=y, data1=column, data2=x, op=nl.minimum)
    nisa.dma_copy(dst=out, src=y)
