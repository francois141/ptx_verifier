"""`paged_kv_t<DType, int32_t>` (FlashInfer include/flashinfer/page.cuh:37) field offsets under
the x86-64 C ABI, and the fastdiv fields its `uint_fastdiv page_size` carries.

`uint_fastdiv` (fastdiv.cuh:26) is `cuda::fast_mod_div<uint32_t> impl_` (3rdparty/cccl
libcudacxx cuda/__cmath/fast_modulo_division.h:210: `_Tp __divisor; __unsigned_t __multiplier;
unsigned __add; int __shift;`) followed by `uint32_t d_`. `check()` compares the layout with the
PTX: the by-value parameter's `.b8 [N]` size and every `param_0+offset` the kernels load.
"""
import re
from pathlib import Path

FIELDS = [  # (name, size) in declaration order; alignment = size
    ("page_size.divisor", 4), ("page_size.multiplier", 4), ("page_size.add", 4),
    ("page_size.shift", 4), ("page_size.d", 4),
    *[(n, 4) for n in ("num_heads head_dim batch_size stride_page stride_n stride_h "
                       "v_stride_page v_stride_n v_stride_h").split()],
    *[(n, 8) for n in "k_data v_data indices indptr last_page_len rope_pos_offset".split()],
]


def layout():
    offsets, at = {}, 0
    for name, size in FIELDS:
        at = -(-at // size) * size
        offsets[name] = (at, size)
        at += size
    return offsets, -(-at // 8) * 8


OFFSETS, SIZE = layout()


def fastdiv(d: int) -> dict:
    """`fast_mod_div<uint32_t>(d)`'s fields (fast_modulo_division.h:67, the unsigned branch)."""
    shift = d.bit_length() - 1  # floor(log2 d)
    if d & (d - 1) == 0:
        return {"divisor": d, "multiplier": 0, "add": 0, "shift": shift, "d": d}
    quotient, remainder = divmod(1 << (32 + shift), d)
    threshold = d - (1 << shift)
    return {"divisor": d, "multiplier": quotient + (remainder >= threshold),
            "add": int(remainder < threshold), "shift": shift, "d": d}


def check(ptx: Path) -> None:
    """Every paged_kv_t parameter in `ptx` is SIZE bytes and is loaded only at field starts."""
    text = ptx.read_text()
    starts = {offset for offset, _ in OFFSETS.values()}
    params = re.findall(r"\.param \.align 8 \.b8 (\S+paged_kv_t\S+_param_0)\[(\d+)\]", text)
    assert params, "no paged_kv_t parameter"
    for name, size in params:
        assert int(size) == SIZE, f"{name}: {size} bytes, layout says {SIZE}"
        for vector, offset in re.findall(rf"ld\.param(\.v[24])?\.\w+\s+\S+(?:, \S+)*\}}?, "
                                         rf"\[{re.escape(name)}\+(\d+)\]", text):
            assert int(offset) in starts, f"{name}: load at +{offset} is not a field start"


if __name__ == "__main__":
    for name, (offset, size) in OFFSETS.items():
        print(f"{offset:4} {size}  {name}")
    print("size", SIZE)
    check(Path(__file__).resolve().parents[1] / "survey/flashinfer/volta_units/page.ptx")
    print("page.ptx agrees")
