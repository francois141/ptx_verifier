import nki
import nki.language as nl
import nki.isa as nisa


# `a`'s columns at the offsets `first` and `second` hold for its two 16-partition groups.
@nki.jit
def two_groups(a, first, second):
    out = nl.ndarray((32, 2), dtype=a.dtype, buffer=nl.shared_hbm)
    t = nl.load(a)
    offsets = nl.ndarray((32, 1), dtype=nl.uint16, buffer=nl.sbuf)
    nisa.dma_copy(dst=offsets[0:16, :], src=first)
    nisa.dma_copy(dst=offsets[16:32, :], src=second)
    gathered = nl.ndarray((32, 2), dtype=a.dtype, buffer=nl.sbuf)
    nisa.tensor_copy(dst=gathered, src=t.indirect(offsets, num_elem=2))
    nl.store(out, value=gathered)
    return out


@nki.jit
def on_gpsimd(a, idx):
    t = nl.load(a)
    offsets = nl.load(idx)
    gathered = nl.ndarray((16, 2), dtype=a.dtype, buffer=nl.sbuf)
    nisa.tensor_copy(gathered, t.indirect(offsets, num_elem=2), engine=nisa.engine.gpsimd)


@nki.jit
def scatter(a, idx):
    t = nl.load(a)
    offsets = nl.load(idx)
    nisa.tensor_copy(dst=t.indirect(offsets, num_elem=2), src=t)


# `idx`'s columns hold 16 offsets each, fewer than `count`.
@nki.jit
def gather(a, idx, count):
    t = nl.load(a)
    offsets = nl.load(idx)
    gathered = nl.ndarray((a.shape[0], count), dtype=a.dtype, buffer=nl.sbuf)
    nisa.tensor_copy(dst=gathered, src=t.indirect(offsets, num_elem=count))
