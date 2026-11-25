"""One element-wise Triton kernel over BLOCK fp32 elements, one per thread, applying ACTIVATION:
each a polynomial approximation the compiler or the kernel author substitutes for the function.

- gelu_erf: the exact GELU, libdevice's erf (two degree-6 polynomials split at |x| = 1.003).
- tanh: libdevice's tanh (an odd polynomial below |x| = 0.6, 1 - 2 / (e^2x + 1) above).
- softplus: log(1 + e^x) with tl.log, libdevice's logf (a degree-10 polynomial of the mantissa).
- gelu_erf_as: the exact GELU through Abramowitz and Stegun's 7.1.26 erf, as the AI compiler's
  GELU kernels write it: 1 - (a1 t + ... + a5 t^5) e^(-z^2) with t = 1 / (1 + p |z|).
"""
import triton
import triton.language as tl
from triton.language.extra import libdevice

ACTIVATIONS = ("gelu_erf", "tanh", "softplus", "gelu_erf_as")


@triton.jit
def erf_as(z):
    a = tl.abs(z)
    t = 1.0 / (1.0 + 0.3275911 * a)
    poly = t * (0.254829592 + t * (-0.284496736 + t * (1.421413741 + t * (-1.453152027 + t * 1.061405429))))
    magnitude = 1.0 - poly * tl.exp(-a * a)
    return tl.where(z >= 0.0, magnitude, -magnitude)


@triton.jit
def activation_kernel(x_ptr, y_ptr, BLOCK: tl.constexpr, ACTIVATION: tl.constexpr):
    offsets = tl.arange(0, BLOCK)
    x = tl.load(x_ptr + offsets)
    if ACTIVATION == "gelu_erf":
        y = 0.5 * x * (1.0 + libdevice.erf(x * 0.7071067811865476))
    elif ACTIVATION == "tanh":
        y = libdevice.tanh(x)
    elif ACTIVATION == "softplus":
        y = tl.log(1.0 + tl.exp(x))
    else:
        y = 0.5 * x * (1.0 + erf_as(x * 0.7071067811865476))
    tl.store(y_ptr + offsets, y)
