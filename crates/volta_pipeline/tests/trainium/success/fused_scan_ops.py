import nki
import nki.language as nl
import nki.isa as nisa


# scalar_tensor_tensor (s = b - 2a, both ops' operand orders exercised, with a row-sum
# reduction), tensor_scalar_cumulative (running row sums of s, then again from each row's
# sum with load_reduce), a tensor_scalar with reverse1, and dma_transposes from HBM with
# their default axes: a 2-D one, and a 3-D one whose middle dimension has extent 1.
@nki.jit
def kernel(a, b, out, sums, a_t, a_t3, carried, flipped):
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
    d = nl.ndarray((2, 4), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_scalar_cumulative(
        dst=d,
        src=s,
        op0=nl.add,
        imm0=0.0,
        op1=nl.add,
        imm1=r,
        reduce_cmd=nisa.reduce_cmd.load_reduce,
    )
    nisa.dma_copy(dst=carried, src=d)
    # A tensor_scalar with its second step reversed: 1 - 2 * s.
    u = nl.ndarray((2, 4), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_scalar(
        dst=u, data=s, op0=nl.multiply, operand0=2.0, op1=nl.subtract, operand1=1.0, reverse1=True
    )
    nisa.dma_copy(dst=flipped, src=u)

    t = nl.ndarray((4, 2), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_transpose(dst=t, src=a)
    nisa.dma_copy(dst=a_t, src=t)

    t3 = nl.ndarray((4, 1, 2), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_transpose(dst=t3, src=a.ap([[4, 2], [1, 1], [1, 4]], offset=0))
    nisa.dma_copy(dst=a_t3, src=t3)
