import nki
import nki.language as nl
import nki.isa as nisa


@nki.jit
def kernel(a_t, b):
    """out = (a_t.T @ b).T, every tile placed by `address=` as attn_fwd_v10 places its own."""
    contraction, rows = a_t.shape
    columns = b.shape[1]
    chunk = contraction // 2
    out = nl.ndarray((columns, rows), dtype=nl.float32, buffer=nl.shared_hbm)

    x = nl.ndarray((contraction, rows), dtype=nl.float32, buffer=nl.sbuf, address=(0, 0))
    y = nl.ndarray((contraction, columns), dtype=nl.float32, buffer=nl.sbuf, address=(0, 32))
    product = nl.ndarray((rows, columns), dtype=nl.float32, buffer=nl.sbuf, address=(0, 64))
    product_t = nl.ndarray((columns, rows), dtype=nl.float32, buffer=nl.sbuf, address=(0, 96))
    result = nl.ndarray((columns, rows), dtype=nl.float32, buffer=nl.sbuf, address=(0, 128))
    # `staged` takes `acc`'s PSUM bytes once `acc` is read for the last time.
    acc = nl.ndarray((rows, columns), dtype=nl.float32, buffer=nl.psum, address=(0, 0))
    staged = nl.ndarray((columns, rows), dtype=nl.float32, buffer=nl.psum, address=(0, 0))

    nisa.dma_copy(dst=x, src=a_t)
    nisa.dma_copy(dst=y, src=b)
    # The second pass's `accumulate=False` overwrites the first pass's sum.
    for _ in range(2):
        for i in range(2):
            nisa.nc_matmul(dst=acc, stationary=x[i * chunk:(i + 1) * chunk, :],
                           moving=y[i * chunk:(i + 1) * chunk, :], accumulate=(i != 0))
    nisa.tensor_copy(dst=product, src=acc, engine=nisa.vector_engine)
    nisa.dma_transpose(dst=product_t, src=product, axes=(1, 0))
    nisa.tensor_copy(dst=staged, src=product_t)
    nisa.tensor_copy(dst=result, src=staged, engine=nisa.scalar_engine)
    nisa.dma_copy(dst=out, src=result)
    return out
