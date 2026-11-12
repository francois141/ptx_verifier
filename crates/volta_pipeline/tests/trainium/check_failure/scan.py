import nki
import nki.language as nl
import nki.isa as nisa


# Each row of `a` scanned with `b`'s one row broadcast to every partition: `out[:, 0:3]`
# from `c`'s element (`acc = a * acc + b`), `out[:, 3:6]` from 1.0 with both ops
# reversed (`acc = b - (acc - a)`); `out[:, 6:9]` is `exp(a * c)`, `c` the scale.
@nki.jit
def kernel(a, b, c):
    out = nl.ndarray((2, 9), dtype=nl.float32, buffer=nl.shared_hbm)
    rows = a[0:2, 0:3]
    x = nl.ndarray(rows.shape, dtype=rows.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=rows)
    row = nl.ndarray((1, 3), dtype=nl.float32, buffer=nl.sbuf)
    nisa.dma_copy(dst=row, src=b)
    scale = nl.zeros((2, 1), dtype=nl.float32)
    nisa.dma_copy(dst=scale, src=c)
    rows_b = nl.broadcast_to(row, (2, 3))

    forward = nl.ndarray((2, 3), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_tensor_scan(dst=forward, data0=x, data1=rows_b, initial=scale,
                            op0=nl.multiply, op1=nl.add)
    reversed = nl.ndarray((2, 3), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_tensor_scan(dst=reversed, data0=x, data1=rows_b, initial=1.0,
                            op0=nl.subtract, op1=nl.subtract, reverse0=True, reverse1=True)
    scaled = nl.ndarray((2, 3), dtype=nl.float32, buffer=nl.sbuf)
    nisa.activation(dst=scaled, op=nl.exp, data=x, scale=scale)

    nisa.dma_copy(dst=out[:, 0:3], src=forward)
    nisa.dma_copy(dst=out[:, 3:6], src=reversed)
    nisa.dma_copy(dst=out[:, 6:9], src=scaled)
    return out
