import nki
import nki.language as nl
import nki.isa as nisa


# scalar_tensor_tensor (s = b - 2a, both ops' operand orders exercised, with a row-sum
# reduction), tensor_scalar_cumulative (running row sums of s), and dma_transposes from HBM
# with their default axes: a 2-D one, and a 3-D one whose middle dimension has extent 1.
@nki.jit
def kernel(a, b, out, sums, a_t, a_t3):
    assert a.shape == (2, 4)
    assert b.shape == (2, 4)
    x = nl.ndarray((2, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a)
    y = nl.ndarray((2, 4), dtype=b.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=y, src=b)

    s = nl.ndarray((2, 4), dtype=nl.float32, buffer=nl.sbuf)
    r = nl.ndarray((2, 1), dtype=nl.float32, buffer=nl.sbuf)
    nisa.scalar_tensor_tensor(
        dst=s,
        data=x,
        op0=nl.multiply,
        operand0=2.0,
        op1=nl.subtract,
        operand1=y,
        reverse1=True,
        reduce_op=nl.add,
        reduce_res=r,
    )
    c = nl.ndarray((2, 4), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_scalar_cumulative(dst=c, src=s, op0=nl.multiply, imm0=1.0, op1=nl.add)
    nisa.dma_copy(dst=out, src=c)
    nisa.dma_copy(dst=sums, src=r)

    t = nl.ndarray((4, 2), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_transpose(dst=t, src=a)
    nisa.dma_copy(dst=a_t, src=t)

    t3 = nl.ndarray((4, 1, 2), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_transpose(dst=t3, src=a.ap([[4, 2], [1, 1], [1, 4]], offset=0))
    nisa.dma_copy(dst=a_t3, src=t3)
