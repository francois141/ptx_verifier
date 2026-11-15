"""out = a_t.T @ b over f32 n x n matrices (a_t is A transposed, as nc_matmul contracts over
partitions); each kernel computes the first 64 x 64 tile of out, accumulating 128-row chunks of
the contraction in PSUM. Volta takes NKI shapes from literal asserts: one kernel per size."""
import nki
import nki.language as nl
import nki.isa as nisa


def matmul_tile(a_t, b, out):
    n = a_t.shape[0]
    acc = nl.ndarray((64, 64), dtype=nl.float32, buffer=nl.psum)
    for k in nl.affine_range(n // 128):
        x = nl.ndarray((128, 64), dtype=a_t.dtype, buffer=nl.sbuf)
        y = nl.ndarray((128, 64), dtype=b.dtype, buffer=nl.sbuf)
        nisa.dma_copy(dst=x, src=a_t[k * 128:(k + 1) * 128, 0:64])
        nisa.dma_copy(dst=y, src=b[k * 128:(k + 1) * 128, 0:64])
        nisa.nc_matmul(dst=acc, stationary=x, moving=y)
    z = nl.ndarray((64, 64), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_copy(dst=z, src=acc)
    nisa.dma_copy(dst=out[0:64, 0:64], src=z)


@nki.jit
def matmul_128(a_t, b, out):
    assert a_t.shape == (128, 128)
    assert b.shape == (128, 128)
    assert out.shape == (128, 128)
    matmul_tile(a_t, b, out)


@nki.jit
def matmul_256(a_t, b, out):
    assert a_t.shape == (256, 256)
    assert b.shape == (256, 256)
    assert out.shape == (256, 256)
    matmul_tile(a_t, b, out)


@nki.jit
def matmul_512(a_t, b, out):
    assert a_t.shape == (512, 512)
    assert b.shape == (512, 512)
    assert out.shape == (512, 512)
    matmul_tile(a_t, b, out)


@nki.jit
def matmul_1024(a_t, b, out):
    assert a_t.shape == (1024, 1024)
    assert b.shape == (1024, 1024)
    assert out.shape == (1024, 1024)
    matmul_tile(a_t, b, out)


@nki.jit
def matmul_2048(a_t, b, out):
    assert a_t.shape == (2048, 2048)
    assert b.shape == (2048, 2048)
    assert out.shape == (2048, 2048)
    matmul_tile(a_t, b, out)


@nki.jit
def matmul_4096(a_t, b, out):
    assert a_t.shape == (4096, 4096)
    assert b.shape == (4096, 4096)
    assert out.shape == (4096, 4096)
    matmul_tile(a_t, b, out)


@nki.jit
def matmul_8192(a_t, b, out):
    assert a_t.shape == (8192, 8192)
    assert b.shape == (8192, 8192)
    assert out.shape == (8192, 8192)
    matmul_tile(a_t, b, out)
