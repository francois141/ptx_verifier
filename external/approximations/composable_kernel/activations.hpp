// PyTorch's activations that CK has no element-wise operation for, written as PyTorch's CUDA
// functors write them (aten/src/ATen/native/cuda/Activation*.cu) in the form of CK's
// unary_element_wise_operation.hpp: `op(y, x)` on fp32, parameters passed by value like CK's.
// expm1 is exp (the hardware exp2 of x * log2(e)) minus 1, as external/activation's kernels take it.
#pragma once

#include "ck/utility/math_v2.hpp"

namespace pytorch {

// Hardsigmoid: min(max(x + 3, 0), 6) * one_sixth, one_sixth = 1.0f / 6.0f.
struct Hardsigmoid
{
    template <typename T>
    __host__ __device__ void operator()(T& y, const T& x) const
    {
        static_assert(ck::is_same_v<T, float>, "fp32 only");
        const float one_sixth = 1.0f / 6.0f;
        y = ck::math::min(ck::math::max(x + 3.0f, 0.0f), 6.0f) * one_sixth;
    }
};

// Hardswish: x * min(max(x + 3, 0), 6) * one_sixth.
struct Hardswish
{
    template <typename T>
    __host__ __device__ void operator()(T& y, const T& x) const
    {
        static_assert(ck::is_same_v<T, float>, "fp32 only");
        const float one_sixth = 1.0f / 6.0f;
        y = x * ck::math::min(ck::math::max(x + 3.0f, 0.0f), 6.0f) * one_sixth;
    }
};

// Softshrink: x - lambd above lambd, x + lambd below -lambd, 0 between, as max(x - lambd, 0) +
// min(x + lambd, 0): clang compiles the nested ternary to exec-masked branches on the data.
struct Softshrink
{
    Softshrink(float lambd = 0.5f) : lambd_(lambd) {}

    template <typename T>
    __host__ __device__ void operator()(T& y, const T& x) const
    {
        static_assert(ck::is_same_v<T, float>, "fp32 only");
        y = ck::math::max(x - lambd_, 0.0f) + ck::math::min(x + lambd_, 0.0f);
    }

    const float lambd_;
};

// CELU as PyTorch's elu_kernel computes elu(x, alpha, 1, 1 / alpha): x <= 0 ? (exp(x * inv_alpha)
// - 1) * alpha : x, inv_alpha = 1 / alpha computed by the host.
struct Celu
{
    Celu(float alpha = 1.0f, float inv_alpha = 1.0f) : alpha_(alpha), inv_alpha_(inv_alpha) {}

    template <typename T>
    __host__ __device__ void operator()(T& y, const T& x) const
    {
        static_assert(ck::is_same_v<T, float>, "fp32 only");
        y = x <= 0.0f ? (ck::math::exp(x * inv_alpha_) - 1.0f) * alpha_ : x;
    }

    const float alpha_;
    const float inv_alpha_;
};

// SELU as PyTorch's elu_kernel computes elu(x, alpha, scale, 1): x <= 0 ? (exp(x) - 1) * negcoef
// : x * poscoef, negcoef the f32 product alpha * scale and poscoef = scale.
struct Selu
{
    template <typename T>
    __host__ __device__ void operator()(T& y, const T& x) const
    {
        static_assert(ck::is_same_v<T, float>, "fp32 only");
        const float alpha   = 1.6732632423543772848170429916717f;
        const float poscoef = 1.0507009873554804934193349852946f;
        const float negcoef = alpha * poscoef;
        y = x <= 0.0f ? (ck::math::exp(x) - 1.0f) * negcoef : x * poscoef;
    }
};

} // namespace pytorch
