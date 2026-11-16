"""out = a_t.T @ b over f32 matrices, a_t K x 256 (A transposed, as nc_matmul contracts over
partitions) and b K x 64: the 256 x 64 tile one PTX or AMD block computes, staged as CTA 0 stages
it. Each step copies 16 rows of a_t and b to SBUF (its As and Bs) and accumulates their product in
PSUM, one nc_matmul per 128-row half of the tile, the most its stationary operand holds.
Volta takes NKI shapes from literal asserts: one kernel per K."""
import nki
import nki.language as nl
import nki.isa as nisa


def matmul_tile(a_t, b, out):
    k = a_t.shape[0]
    acc = nl.ndarray((128, 2, 64), dtype=nl.float32, buffer=nl.psum)
    for c in nl.affine_range(k // 16):
        x = nl.ndarray((16, 256), dtype=a_t.dtype, buffer=nl.sbuf)
        y = nl.ndarray((16, 64), dtype=b.dtype, buffer=nl.sbuf)
        nisa.dma_copy(dst=x, src=a_t[c * 16:(c + 1) * 16, 0:256])
        nisa.dma_copy(dst=y, src=b[c * 16:(c + 1) * 16, 0:64])
        for m in nl.affine_range(2):
            nisa.nc_matmul(dst=acc[:, m, :], stationary=x[:, m * 128:(m + 1) * 128], moving=y)
    for m in nl.affine_range(2):
        z = nl.ndarray((128, 64), dtype=nl.float32, buffer=nl.sbuf)
        nisa.tensor_copy(dst=z, src=acc[:, m, :])
        nisa.dma_copy(dst=out[m * 128:(m + 1) * 128, 0:64], src=z)


@nki.jit
def matmul_128(a_t, b, out):
    assert a_t.shape == (128, 256)
    assert b.shape == (128, 64)
    assert out.shape == (256, 64)
    matmul_tile(a_t, b, out)


@nki.jit
def matmul_256(a_t, b, out):
    assert a_t.shape == (256, 256)
    assert b.shape == (256, 64)
    assert out.shape == (256, 64)
    matmul_tile(a_t, b, out)


@nki.jit
def matmul_512(a_t, b, out):
    assert a_t.shape == (512, 256)
    assert b.shape == (512, 64)
    assert out.shape == (256, 64)
    matmul_tile(a_t, b, out)


@nki.jit
def matmul_1024(a_t, b, out):
    assert a_t.shape == (1024, 256)
    assert b.shape == (1024, 64)
    assert out.shape == (256, 64)
    matmul_tile(a_t, b, out)


@nki.jit
def matmul_2048(a_t, b, out):
    assert a_t.shape == (2048, 256)
    assert b.shape == (2048, 64)
    assert out.shape == (256, 64)
    matmul_tile(a_t, b, out)


@nki.jit
def matmul_4096(a_t, b, out):
    assert a_t.shape == (4096, 256)
    assert b.shape == (4096, 64)
    assert out.shape == (256, 64)
    matmul_tile(a_t, b, out)


@nki.jit
def matmul_8192(a_t, b, out):
    assert a_t.shape == (8192, 256)
    assert b.shape == (8192, 64)
    assert out.shape == (256, 64)
    matmul_tile(a_t, b, out)
