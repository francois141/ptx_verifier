// Aiter's rope_fwd_3d (Wan-style 3-D RoPE), the semantics of its test's reference
// (op_tests/triton_tests/rope/test_rope.py::rope_fwd_3d_torch): grid_sizes (1, 1, 1), so token 0
// is the only valid one (f = h = w = 0: every column band reads freqs row 0) and is multiplied
// by freqs[0]; padding tokens are multiplied by 1 (pad_freqs fills ones), i.e. copied.
// The workgroup's output is split at token and channel boundaries into separate launch arrays:
// out_lo = token 0 pairs 0..CL-1, out_hi = token 0 pairs CL..CT-1 (empty when CL = CT),
// out_p = padding tokens 1..LP. A pair is [real, imag] (s = 0, 1).
dim CT; dim CL; dim CH; dim TWO; dim ONE; dim LP; dim PM; dim LX;
array x[LX, CT, TWO];
array fr[PM, CT];
array fi[PM, CT];
array out_lo[ONE, CL, TWO];
out_lo[l, c, s] = x[l, c, s] * fr[0, c]
    + sum(r in 0..s, 2 * x[l, c, 1 - s] * fi[0, c]) - x[l, c, 1 - s] * fi[0, c];
