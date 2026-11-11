import nki
import nki.language as nl
import nki.isa as nisa


@nki.jit
def kernel(a, b, mx, rs, tr):
    """The nki.language functions that return a new tile, as attn_fwd_v1 calls them."""
    x = nl.load(a)
    y = nl.load(b)

    # mx[i] = max_j (a.T @ b)[i, j]
    p = nl.matmul(x, y, transpose_x=True)
    s = nl.ndarray(p.shape, dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_copy(dst=s, src=p)
    m = nl.max(s, axis=1, keepdims=True)
    nl.store(dst=mx, value=m)

    # rs[i] = 1 / sum_j exp(a[i, j])
    e = nl.exp(x)
    u = nl.sum(e, axis=1, keepdims=True)
    r = nl.reciprocal(u)
    nl.store(dst=rs, value=r)

    # tr = a.T, through PSUM
    t = nl.transpose(x)
    w = nl.ndarray(t.shape, dtype=a.dtype, buffer=nl.sbuf)
    nisa.tensor_copy(dst=w, src=t)
    nl.store(dst=tr, value=w)
