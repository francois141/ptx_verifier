// 2-D RoPE (op_tests/test_rope.py ref_rope_2d_fwd, NEOX): head n of token (i, k) of an HH x WW image is
// [x1 | x2]; x1 (t = 0) is rotated with row i of cos_h/sin_h, x2 (t = 1) with row k of cos_w/sin_w.
// Each half is NEOX-rotated: quarter q pairs with quarter 1 - q. Its cos/sin column is G * q + j:
// G = J when the tables are d/2 wide (reuse_freqs_front_part = False), G = 0 when they are d/4 wide (True).
dim B; dim HH; dim WW; dim N; dim T; dim Q; dim J; dim RH; dim RW; dim F; dim G;
array x[B, HH, WW, N, T, Q, J];
array ch[RH, F]; array sh[RH, F]; array cw[RW, F]; array sw[RW, F];
array out[B, HH, WW, N, T, Q, J];
out[b, i, k, n, t, q, j] =
    (1 - t) * (x[b, i, k, n, t, q, j] * ch[i, G * q + j] + (2 * q - 1) * x[b, i, k, n, t, 1 - q, j] * sh[i, G * q + j])
  + t * (x[b, i, k, n, t, q, j] * cw[k, G * q + j] + (2 * q - 1) * x[b, i, k, n, t, 1 - q, j] * sw[k, G * q + j]);
