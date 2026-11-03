import nki
import nki.language as nl
import nki.isa as nisa

@nki.jit
def kernel(a, out):
    assert a.shape == (4, 8)
    assert out.shape == (4, 8)

    x = nl.ndarray((4, 8), dtype=a.dtype, buffer=nl.sbuf)
    squares = nl.ndarray((4, 8), dtype=nl.float32, buffer=nl.sbuf)
    sum_sq = nl.ndarray((4, 1), dtype=nl.float32, buffer=nl.sbuf)
    mean_sq = nl.ndarray((4, 1), dtype=nl.float32, buffer=nl.sbuf)
    rstd = nl.ndarray((4, 1), dtype=nl.float32, buffer=nl.sbuf)
    y = nl.ndarray((4, 8), dtype=a.dtype, buffer=nl.sbuf)

    nisa.dma_copy(dst=x, src=a)

    # Each partition is one row: y = x / sqrt(mean(x^2) + eps), with 0.125 = 1 / the row length.
    nisa.activation_reduce(dst=squares, op=nl.square, data=x, reduce_op=nl.add, reduce_res=sum_sq)
    nisa.tensor_scalar(dst=mean_sq, data=sum_sq, op0=nl.multiply, operand0=0.125, op1=nl.add, operand1=0.000001)
    nisa.activation(dst=rstd, op=nl.rsqrt, data=mean_sq)
    nisa.tensor_scalar(dst=y, data=x, op0=nl.multiply, operand0=rstd)

    nisa.dma_copy(dst=out, src=y)
