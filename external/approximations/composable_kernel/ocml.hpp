// ROCm 7.0.0's device-library (OCML, amd/device-libs/ocml/src) definitions of the functions CK's
// element-wise operations call, as hipcc links them under -ffast-math (oclc's finite-only and
// unsafe-math controls on). -nogpulib omits that library, so the kernels define them here. exp, log
// and the native reciprocal are the compiler's builtins (v_exp_f32, v_log_f32 and v_rcp_f32);
// expm1, tanh and erf are OCML's polynomial algorithms (expm1F.cl, tanhF.cl, erfF.cl), since no
// hardware instruction computes them.
#pragma once

#define OCML extern "C" __device__ __attribute__((const)) float

// expF.cl
OCML __ocml_exp_f32(float x) { return __builtin_expf(x); }

// logF.cl
OCML __ocml_log_f32(float x) { return __builtin_logf(x); }

// ck::math::rcp's __ocml_native_recip_f32
OCML __ocml_native_recip_f32(float x) { return __builtin_amdgcn_rcpf(x); }

// expm1F.cl: exp(x) - 1 as 2^n * p(t) + (2^n - 1), t the reduced argument, p a degree-6 polynomial.
OCML __ocml_expm1_f32(float x)
{
    float fn = __builtin_rintf(x * 0x1.715476p+0f);
    float t = __builtin_fmaf(-fn, -0x1.05c610p-29f, __builtin_fmaf(-fn, 0x1.62e430p-1f, x));
    float p = __builtin_fmaf(t, __builtin_fmaf(t, __builtin_fmaf(t, __builtin_fmaf(t, __builtin_fmaf(t,
                  0x1.a26762p-13f, 0x1.6d2e00p-10f), 0x1.110ff2p-7f), 0x1.555502p-5f),
                  0x1.555556p-3f), 0x1.000000p-1f);
    p = __builtin_fmaf(t, t * p, t);
    int e = fn == 128.0f ? 127 : (int)fn;
    float s = __builtin_amdgcn_ldexpf(1.0f, e);
    float z = __builtin_fmaf(s, p, s - 1.0f);
    z = fn == 128.0f ? 2.0f * z : z;
    z = x < -17.0f ? -1.0f : z;
    return z;
}

// tanhF.cl: an odd degree-11 polynomial below 0.625, else 1 - 2 / (exp(2|x|) + 1).
OCML __ocml_tanh_f32(float x)
{
    float y = __builtin_fabsf(x);
    float z;
    if (y < 0.625f) {
        float y2 = y * y;
        float p = __builtin_fmaf(y2, __builtin_fmaf(y2, __builtin_fmaf(y2, __builtin_fmaf(y2,
                    -0x1.758e7ap-8f, 0x1.521192p-6f), -0x1.b8389cp-5f),
                    0x1.110704p-3f), -0x1.555532p-2f);
        z = __builtin_fmaf(y2, y * p, y);
    } else {
        float t = __ocml_exp_f32(2.0f * y);
        z = __builtin_fmaf(-2.0f, __builtin_amdgcn_rcpf(t + 1.0f), 1.0f);
    }
    return __builtin_copysignf(z, x);
}

// erfF.cl: a degree-11 odd polynomial below 1, else 1 - exp(-p(|x|)) for a degree-7 polynomial p.
OCML __ocml_erf_f32(float x)
{
    float ax = __builtin_fabsf(x);
    float ret;
    if (ax < 1.0f) {
        float t = ax * ax;
        float p = __builtin_fmaf(t, __builtin_fmaf(t, __builtin_fmaf(t, __builtin_fmaf(t,
                  __builtin_fmaf(t,
                      -0x1.268bc2p-11f, 0x1.420828p-8f), -0x1.b5937p-6f), 0x1.ce077cp-4f),
                      -0x1.81266p-2f), 0x1.06eba0p-3f);
        ret = __builtin_fmaf(ax, p, ax);
    } else {
        float p = __builtin_fmaf(ax, __builtin_fmaf(ax, __builtin_fmaf(ax, __builtin_fmaf(ax,
                  __builtin_fmaf(ax, __builtin_fmaf(ax,
                      0x1.1d3156p-16f, -0x1.8d129p-12f), 0x1.f9a6d2p-9f), -0x1.8c3164p-6f),
                      0x1.b4e9c8p-4f), 0x1.4515fap-1f), 0x1.078e50p-3f);
        p = __builtin_fmaf(ax, p, ax);
        ret = 1.0f - __ocml_exp_f32(-p);
    }
    return __builtin_copysignf(ret, x);
}
