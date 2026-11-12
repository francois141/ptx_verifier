// ROCm 7.0.0's device-library (OCML, amd/device-libs/ocml/src) definitions of the functions CK
// Tile's activations call, as hipcc links them under -ffast-math: oclc's finite-only and
// unsafe-math controls on. -nogpulib omits that library, so the kernels define them here.
#pragma once

#define OCML extern "C" __device__ __attribute__((const)) float

// expF.cl
OCML __ocml_exp_f32(float x) { return __builtin_expf(x); }
