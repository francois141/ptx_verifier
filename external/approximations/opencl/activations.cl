// The activations of ../composable_kernel in OpenCL C, each as CK's element-wise operation (or
// ../composable_kernel/activations.hpp's PyTorch functor) computes it, its parameters literals,
// fused after a GEMM. compile.py instantiates one kernel per activation: -DACTIVATION=name.
#include "ocml.h"

static inline float act_relu(float x) { return x > 0.0f ? x : 0.0f; }

static inline float act_leaky_relu(float x) { return x >= 0.0f ? x : x * 0.01f; }

static inline float act_hardtanh(float x) { return fmin(fmax(x, -1.0f), 1.0f); }

static inline float act_hardsigmoid(float x)
{
    const float one_sixth = 1.0f / 6.0f;
    return fmin(fmax(x + 3.0f, 0.0f), 6.0f) * one_sixth;
}

static inline float act_hardswish(float x)
{
    const float one_sixth = 1.0f / 6.0f;
    return x * fmin(fmax(x + 3.0f, 0.0f), 6.0f) * one_sixth;
}

static inline float act_softshrink(float x) { return fmax(x - 0.5f, 0.0f) + fmin(x + 0.5f, 0.0f); }

static inline float act_elu(float x) { return x > 0.0f ? x : 1.0f * ocml_expm1(x); }

static inline float act_celu(float x) { return x <= 0.0f ? (exp(x * 0.5f) - 1.0f) * 2.0f : x; }

static inline float act_selu(float x)
{
    const float alpha = 1.6732632423543772848170429916717f;
    const float poscoef = 1.0507009873554804934193349852946f;
    const float negcoef = alpha * poscoef;
    return x <= 0.0f ? (exp(x) - 1.0f) * negcoef : x * poscoef;
}

static inline float act_fast_gelu(float x)
{
    const float c1 = -2.0f * 0.035677f;
    const float c2 = -2.0f * 0.797885f;
    const float u = x * (c1 * x * x + c2);
    return x * __builtin_amdgcn_rcpf(1.0f + exp(u));
}

static inline float act_gelu(float x) { return 0.5f * x * (1.0f + ocml_erf(0.70710678118f * x)); }

static inline float act_sigmoid(float x) { return 1.0f / (1.0f + exp(-x)); }

static inline float act_silu(float x) { return x * (1.0f / (1.0f + exp(-x))); }

static inline float act_tanh(float x) { return ocml_tanh(x); }

static inline float act_softrelu(float x) { return log(1.0f + exp(x * 1.0f)) / 1.0f; }

#define THREADS 64
#define CONCAT(a, b) a##b
// One fma per k: clang's two-wide vectorization (global_load_dwordx2, v_pk_fma_f32) is outside the
// AMD frontend's subset.
#define LOOP_SCALAR _Pragma("clang loop vectorize(disable) interleave(disable) unroll(disable)")

// Element `index` of `base` at a 32-bit byte offset, which clang addresses as a scalar base plus a
// 32-bit vector offset: a 64-bit vector address (`off`) is outside the AMD frontend's subset.
static inline float load(__global const float *base, uint index)
{
    return *(__global const float *)((__global const char *)base + index * 4u);
}

static inline void store(__global float *base, uint index, float value)
{
    *(__global float *)((__global char *)base + index * 4u) = value;
}

// c[m, n] = act(sum_k a[m, k] * b[n, k]) in one workgroup of THREADS work-items, each computing
// columns tid, tid + THREADS, ... of every row: A is M x K and B N x K, both row-major.
#define KERNEL(name)                                                                       \
    __kernel __attribute__((reqd_work_group_size(THREADS, 1, 1))) void name(              \
        __global const float *a, __global const float *b, __global float *c, uint m_size, \
        uint n_size, uint k_size)                                                          \
    {                                                                                      \
        uint tid = __builtin_amdgcn_workitem_id_x();                                       \
        for (uint m = 0; m < m_size; ++m) {                                                \
            for (uint column = 0; column < n_size; column += THREADS) {                    \
                uint n = column + tid;                                                     \
                if (n < n_size) {                                                          \
                    float acc = 0.0f;                                                      \
                    LOOP_SCALAR for (uint k = 0; k < k_size; ++k)                          \
                        acc += load(a, m * k_size + k) * load(b, n * k_size + k);          \
                    store(c, m * n_size + n, CONCAT(act_, name)(acc));                     \
                }                                                                          \
            }                                                                              \
        }                                                                                  \
    }

KERNEL(ACTIVATION)
