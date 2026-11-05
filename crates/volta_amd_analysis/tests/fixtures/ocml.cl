// ROCm 7.0.0's ocml definition of the function CK's Sigmoid calls (expF.cl), compiled separately
// because hipcc links ocml as bitcode built without fast-math.

__attribute__((const)) float __ocml_exp_f32(float x) { return __builtin_expf(x); }
