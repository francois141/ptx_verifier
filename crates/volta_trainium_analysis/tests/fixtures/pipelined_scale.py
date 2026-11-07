import nki
import nki.language as nl
import nki.isa as nisa


# Counts the SBUF bytes per partition its tiles take, aligned as attn_fwd_v10's
# allocator aligns them.
class Allocator(nl.NKIObject):
    def __init__(self, alignment=4):
        self.offset = 0
        self.alignment = alignment

    def element_bytes(self, dtype):
        if dtype == nl.float32:
            return 4
        elif dtype == nl.bfloat16:
            return 2
        else:
            assert False, f"Unsupported dtype: {dtype}"

    def tile(self, shape, dtype=nl.float32):
        size = self.element_bytes(dtype)
        for extent in shape[1:]:
            size *= extent
        self.offset = (self.offset + size + self.alignment - 1) & ~(self.alignment - 1)
        assert len(shape) == 3 and not self.offset > 1024, \
            f"Can't allocate {size} bytes"
        return nl.ndarray(shape, dtype=dtype, buffer=nl.sbuf)


class Buffers(nl.NKIObject):
    tiles = None
    out = None


# Three stages, each skipping the indices outside the tiles, as v10's do.
def load(i, count, a, bufs):
    if i < 0 or i > count - 1:
        return
    nisa.dma_copy(dst=bufs.tiles[:, i % 2, :], src=a[i * 2:i * 2 + 2, :])


def scale(i, count, bufs):
    if (i < 0 or i > count - 1):
        return
    nisa.tensor_scalar(dst=bufs.scaled[:, i % 2, :], data=bufs.tiles[:, i % 2, :],
                       op0=nl.multiply, operand0=2.0)


def store(i, count, bufs):
    if not 0 <= i < count:
        return
    nisa.dma_copy(dst=bufs.out[i * 2:i * 2 + 2, :], src=bufs.scaled[:, i % 2, :])


@nki.jit
def kernel(a):
    rows, cols = a.shape
    count = rows // 2
    assert -7 // 2 == -4 and -7 % 2 == 1 and 7 % -2 == -1

    allocator = Allocator()
    bufs = Buffers()
    assert bufs.out == None

    # out = 2 * a, one two-row tile at a time, software pipelined over double buffers.
    bufs.out = nl.ndarray((rows, cols), dtype=a.dtype, buffer=nl.shared_hbm)
    bufs.tiles = allocator.tile((2, 2, cols), dtype=a.dtype)
    bufs.scaled = allocator.tile((2, 2, cols))
    assert allocator.offset == 48

    with nl.no_reorder():
        for i in range(0, count + 2):
            store(i - 2, count, bufs)
            scale(i - 1, count, bufs)
            load(i, count, a, bufs)

    return bufs.out
