// ROCm 7.0.0's device-library (OCML, amd/device-libs/ocml/src) algorithms for the OpenCL builtins
// clang does not lower to an instruction: expm1, tanh and erf (expm1F.cl, tanhF.cl, erfF.cl), as
// ../composable_kernel/ocml.hpp defines them. -nogpulib omits that library, so the kernels use these.
#pragma once

// expm1F.cl: exp(x) - 1 as 2^n * p(t) + (2^n - 1), t the reduced argument, p a degree-6 polynomial.
static inline float ocml_expm1(float x)
{
    float fn = rint(x * 0x1.715476p+0f);
    float t = fma(-fn, -0x1.05c610p-29f, fma(-fn, 0x1.62e430p-1f, x));
    float p = fma(t, fma(t, fma(t, fma(t, fma(t,
                  0x1.a26762p-13f, 0x1.6d2e00p-10f), 0x1.110ff2p-7f), 0x1.555502p-5f),
                  0x1.555556p-3f), 0x1.000000p-1f);
    p = fma(t, t * p, t);
    int e = fn == 128.0f ? 127 : (int)fn;
    float s = ldexp(1.0f, e);
    float z = fma(s, p, s - 1.0f);
    z = fn == 128.0f ? 2.0f * z : z;
    z = x < -17.0f ? -1.0f : z;
    return z;
}

// tanhF.cl: an odd degree-11 polynomial below 0.625, else 1 - 2 / (exp(2|x|) + 1).
static inline float ocml_tanh(float x)
{
    float y = fabs(x);
    float z;
    if (y < 0.625f) {
        float y2 = y * y;
        float p = fma(y2, fma(y2, fma(y2, fma(y2,
                    -0x1.758e7ap-8f, 0x1.521192p-6f), -0x1.b8389cp-5f),
                    0x1.110704p-3f), -0x1.555532p-2f);
        z = fma(y2, y * p, y);
    } else {
        float t = exp(2.0f * y);
        z = fma(-2.0f, __builtin_amdgcn_rcpf(t + 1.0f), 1.0f);
    }
    return copysign(z, x);
}

// erfF.cl: a degree-11 odd polynomial below 1, else 1 - exp(-p(|x|)) for a degree-7 polynomial p.
static inline float ocml_erf(float x)
{
    float ax = fabs(x);
    float ret;
    if (ax < 1.0f) {
        float t = ax * ax;
        float p = fma(t, fma(t, fma(t, fma(t, fma(t,
                      -0x1.268bc2p-11f, 0x1.420828p-8f), -0x1.b5937p-6f), 0x1.ce077cp-4f),
                      -0x1.81266p-2f), 0x1.06eba0p-3f);
        ret = fma(ax, p, ax);
    } else {
        float p = fma(ax, fma(ax, fma(ax, fma(ax, fma(ax, fma(ax,
                      0x1.1d3156p-16f, -0x1.8d129p-12f), 0x1.f9a6d2p-9f), -0x1.8c3164p-6f),
                      0x1.b4e9c8p-4f), 0x1.4515fap-1f), 0x1.078e50p-3f);
        p = fma(ax, p, ax);
        ret = 1.0f - exp(-p);
    }
    return copysign(ret, x);
}
