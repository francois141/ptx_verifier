"""vLLM kernels checked by Volta: what each case compiles, launches and checks.

`external/ptx/verify.py` runs them. Each case's kernel is one instantiation in the PTX of a
`csrc/` unit of vLLM at the commit `external/ptx/sources/frameworks.txt` pins, compiled for
sm_100a by `external/ptx/extraction/survey.py` with vLLM's own flags; `symbol` is a substring
of its mangled name. The launch (grid, block, arguments) is the one the unit's host dispatch
makes for the case's shape, read from the source cited in `source`.
"""

import math
from dataclasses import dataclass, field

EPS = 9.999999974752427e-07  # f32(1e-6), the epsilon of vLLM's norm tests


@dataclass(frozen=True)
class Array:
    name: str
    kind: str  # "in", "out" or "inout"
    dtype: str
    shape: tuple


@dataclass(frozen=True)
class Ptr:
    array: str


@dataclass(frozen=True)
class Int:
    value: int
    name: str = ""


@dataclass(frozen=True)
class Float:
    value: float
    name: str = ""


NULL = Int(0, "nullptr")


@dataclass(frozen=True)
class Case:
    """`check` is the verdict the case expects: "ACCEPT" or "REJECT" against `spec`, or
    without one "VERIFIED"/"REJECTED" from the graph checks; "ABORT" an execution error."""

    name: str
    description: str
    source: str
    unit: str
    symbol: str
    args: tuple
    arrays: tuple
    grid: tuple
    block: int
    check: str
    spec: str | None = None
    dims: dict = field(default_factory=dict)


# ===== RMSNorm (csrc/layernorm_kernels.cu) =====

LAYERNORM = "csrc/layernorm_kernels.cu"
DTYPE_MANGLED = {"bf16": "N3c108BFloat16E", "f16": "N3c104HalfE"}


def rms_norm(name, hidden, dtype="bf16", weight=True, check="ACCEPT", note=""):
    """`rms_norm(out, input, weight, eps)` on one 2-D row: VEC = gcd(16 / sizeof, hidden),
    block = min(hidden / VEC, 1024) (fewer than 256 tokens), dispatch :222."""
    vec = math.gcd(8, hidden)
    weight_args = (Ptr("weight"), Int(0, "weight_stride")) if weight else (NULL, Int(0))
    arrays = [Array("input", "in", dtype, (1, hidden)), Array("out", "out", dtype, (1, hidden))]
    if weight:
        arrays.insert(1, Array("weight", "in", dtype, (hidden,)))
    return Case(
        name=name,
        description=f"rms_norm, {dtype}, 1 token of {hidden}, VEC_SIZE={vec}, "
                    f"{'' if weight else 'no '}weight{note}",
        source=f"{LAYERNORM}:15 (rms_norm_kernel), dispatch :222",
        unit=LAYERNORM,
        symbol=f"15rms_norm_kernelI{DTYPE_MANGLED[dtype]}Li{vec}ELi2ELb{int(weight)}E",
        args=(Ptr("out"), Ptr("input"), Int(hidden, "input_stride_d2"), Int(0), Int(0), Int(0),
              Int(0), *weight_args, Float(EPS, "epsilon"), Int(1, "num_tokens"),
              Int(hidden, "hidden_size")),
        arrays=tuple(arrays),
        grid=(1, 1, 1),
        block=min(hidden // vec, 1024),
        check=check,
        spec="rms_norm.spec" if weight else "rms_norm_no_weight.spec",
        dims={"T": 1, "N": hidden},
    )


def fused_add_rms_norm(name, hidden, width=8, check="ACCEPT", note=""):
    """`fused_add_rms_norm(input, residual, weight, eps)` in place on one row: width 8 when
    the pointers are 16-byte aligned and hidden a multiple of 8, else the generic width 0;
    block = min(hidden, 1024), dispatch :315."""
    return Case(
        name=name,
        description=f"fused_add_rms_norm, bf16, 1 token of {hidden}, width {width}{note}",
        source=f"{LAYERNORM}:{109 if width else 182} (fused_add_rms_norm_kernel), dispatch :315",
        unit=LAYERNORM,
        symbol=f"25fused_add_rms_norm_kernelI{DTYPE_MANGLED['bf16']}Li{width}ELb1E",
        args=(Ptr("input"), Int(hidden, "input_stride"), Ptr("residual"), Ptr("weight"),
              Float(EPS, "epsilon"), Int(1, "num_tokens"), Int(hidden, "hidden_size"),
              Int(hidden, "residual_stride")),
        arrays=(Array("input", "inout", "bf16", (1, hidden)),
                Array("residual", "inout", "bf16", (1, hidden)),
                Array("weight", "in", "bf16", (hidden,))),
        grid=(1, 1, 1),
        block=min(hidden, 1024),
        check=check,
        spec="fused_add_rms_norm.spec",
        dims={"T": 1, "N": hidden},
    )


CASES = (
    rms_norm("rms_norm_4096", 4096),
    rms_norm("rms_norm_100", 100, note=" (25 threads)"),
    rms_norm("rms_norm_4096_no_weight", 4096, weight=False),
    rms_norm("rms_norm_f16_2048", 2048, dtype="f16"),
    fused_add_rms_norm("fused_add_rms_norm_4096", 4096),
    fused_add_rms_norm("fused_add_rms_norm_generic_100", 100, width=0),
)
