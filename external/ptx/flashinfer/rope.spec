// FlashInfer BatchQKApplyRotaryPosIdsCosSinCache kernels (pos_enc.cuh:352, :419), NeoX style
// (interleave false), out of place: for a head x of token t at position t (pos_ids[t] = t),
// with cos_sin_cache[t] = [cos_0..cos_{RH-1}, sin_0..sin_{RH-1}] (R = 2 RH rotary dims):
//   d < RH:       x[d] cos_d - x[d + RH] sin_d
//   RH <= d < R:  x[d] cos_{d-RH} + x[d - RH] sin_{d-RH}
//   d >= R:       x[d] (passed through).
// Heads are viewed [A, G] (head a G + b): the analyzed block writes q heads with b == YQ and
// a in [QA0, QA1), k heads with b == YK and a in [KA0, KA1), for the T tokens registered.
dim T; dim QA; dim KA; dim G; dim D; dim R; dim RH; dim YQ; dim YK; dim QA0; dim QA1; dim KA0; dim KA1;
array q[T, QA, G, D];
array k[T, KA, G, D];
array cache[T, R];
array q_rope[T, QA, G, D];
array k_rope[T, KA, G, D];
q_rope[t, a, b, d] = where(b != YQ, unwritten, where(a < QA0, unwritten, where(a < QA1,
    where(d < RH, q[t, a, b, d] * cache[t, d] - q[t, a, b, d + RH] * cache[t, RH + d],
    where(d < R, q[t, a, b, d] * cache[t, d - RH] + q[t, a, b, d - RH] * cache[t, d],
          q[t, a, b, d])),
    unwritten)));
k_rope[t, a, b, d] = where(b != YK, unwritten, where(a < KA0, unwritten, where(a < KA1,
    where(d < RH, k[t, a, b, d] * cache[t, d] - k[t, a, b, d + RH] * cache[t, RH + d],
    where(d < R, k[t, a, b, d] * cache[t, d - RH] + k[t, a, b, d - RH] * cache[t, d],
          k[t, a, b, d])),
    unwritten)));
