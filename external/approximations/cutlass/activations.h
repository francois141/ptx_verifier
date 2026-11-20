// PyTorch's activations that CUTLASS has no epilogue functor for, written as PyTorch's CUDA
// functors write them (aten/src/ATen/native/cuda/Activation*.cu) in the form of CUTLASS's
// epilogue/thread/activation.h: a scalar functor and its Array form. log is cutlass::fast_log
// (logf: lg2.approx under -use_fast_math) and the exponential is the ex2.approx instruction
// expf lowers to under -use_fast_math, issued before the select so nvcc keeps it a select rather
// than branching around it; expm1 is that exp minus 1, as external/activation's kernels take it.
#pragma once

#include <cutlass/array.h>
#include <cutlass/cutlass.h>
#include <cutlass/fast_math.h>
#include <cutlass/functional.h>

namespace pytorch {

#define PYTORCH_ARRAY_FORM(Functor)                                        \
  template <typename T, int N>                                             \
  struct Functor<cutlass::Array<T, N>> {                                   \
    CUTLASS_HOST_DEVICE                                                    \
    cutlass::Array<T, N> operator()(cutlass::Array<T, N> const &x) const { \
      cutlass::Array<T, N> y;                                              \
      Functor<T> f;                                                        \
      _Pragma("unroll")                                                    \
      for (int i = 0; i < N; ++i) {                                        \
        y[i] = f(x[i]);                                                    \
      }                                                                    \
      return y;                                                            \
    }                                                                      \
  };

// exp(x) as -use_fast_math's expf: ex2.approx.ftz.f32 of x * log2(e). The asm is volatile so that
// nvcc evaluates it on both sides of a select instead of branching to it.
CUTLASS_DEVICE
float fast_exp_select(float x) {
  float y;
  asm volatile("ex2.approx.ftz.f32 %0, %1;" : "=f"(y) : "f"(x * 1.4426950408889634f));
  return y;
}

// Hardsigmoid: min(max(x + 3, 0), 6) * one_sixth, one_sixth = 1.0f / 6.0f.
template <typename T>
struct Hardsigmoid {
  CUTLASS_HOST_DEVICE
  T operator()(T const &x) const {
    cutlass::maximum<T> mx;
    cutlass::minimum<T> mn;
    T const one_sixth = T(1) / T(6);
    return mn(mx(x + T(3), T(0)), T(6)) * one_sixth;
  }
};
PYTORCH_ARRAY_FORM(Hardsigmoid)

// Softshrink (lambd 0.5): x - lambd above lambd, x + lambd below -lambd, 0 between, as
// max(x - lambd, 0) + min(x + lambd, 0): nvcc compiles PyTorch's nested ternary to branches.
template <typename T>
struct Softshrink {
  CUTLASS_HOST_DEVICE
  T operator()(T const &x) const {
    cutlass::maximum<T> mx;
    cutlass::minimum<T> mn;
    T const lambd = T(0.5);
    return mx(x - lambd, T(0)) + mn(x + lambd, T(0));
  }
};
PYTORCH_ARRAY_FORM(Softshrink)

// ELU (alpha 1) as PyTorch's elu_kernel computes it: x <= 0 ? exp(x) - 1 : x.
template <typename T>
struct ELU {
  CUTLASS_DEVICE
  T operator()(T const &x) const {
    T const negative = fast_exp_select(x) - T(1);
    return x <= T(0) ? negative : x;
  }
};
PYTORCH_ARRAY_FORM(ELU)

// CELU (alpha 2) as elu(x, alpha, 1, 1 / alpha): x <= 0 ? (exp(x * inv_alpha) - 1) * alpha : x.
template <typename T>
struct CELU {
  CUTLASS_DEVICE
  T operator()(T const &x) const {
    T const alpha = T(2);
    T const inv_alpha = T(0.5);
    T const negative = (fast_exp_select(x * inv_alpha) - T(1)) * alpha;
    return x <= T(0) ? negative : x;
  }
};
PYTORCH_ARRAY_FORM(CELU)

// SELU as elu(x, alpha, scale, 1): x <= 0 ? (exp(x) - 1) * negcoef : x * poscoef, negcoef the
// fp32 product alpha * scale and poscoef = scale.
template <typename T>
struct SELU {
  CUTLASS_DEVICE
  T operator()(T const &x) const {
    T const alpha = T(1.6732632423543772848170429916717);
    T const poscoef = T(1.0507009873554804934193349852946);
    T const negcoef = alpha * poscoef;
    T const negative = (fast_exp_select(x) - T(1)) * negcoef;
    return x <= T(0) ? negative : x * poscoef;
  }
};
PYTORCH_ARRAY_FORM(SELU)

// Softplus with no threshold: log(1 + exp(x)).
template <typename T>
struct Softplus {
  CUTLASS_HOST_DEVICE
  T operator()(T const &x) const {
    return cutlass::fast_log(T(1) + cutlass::fast_exp(x));
  }
};
PYTORCH_ARRAY_FORM(Softplus)

// log(x) as -use_fast_math's logf: lg2.approx.ftz.f32 times ln 2, volatile like fast_exp_select.
CUTLASS_DEVICE
float fast_log_select(float x) {
  float y;
  asm volatile("lg2.approx.ftz.f32 %0, %1;" : "=f"(y) : "f"(x));
  return y * 0.6931471805599453f;
}

// Softplus as PyTorch computes it (beta 1, threshold 20): x above the threshold, else
// log(1 + exp(x)), where the two differ by exp(-x) < 1e-8.
template <typename T>
struct SoftplusThreshold {
  CUTLASS_DEVICE
  T operator()(T const &x) const {
    T const smooth = fast_log_select(T(1) + fast_exp_select(x));
    return x > T(20) ? x : smooth;
  }
};
PYTORCH_ARRAY_FORM(SoftplusThreshold)

#undef PYTORCH_ARRAY_FORM

}  // namespace pytorch
