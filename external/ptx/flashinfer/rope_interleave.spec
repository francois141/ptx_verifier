// FlashInfer BatchQKApplyRotaryPosIdsCosSinCache kernels (pos_enc.cuh:352, :419), GPT-J style
// (interleave true), out of place: a head viewed [E, TWO] (E = D / 2) rotates its pair e < RH
// by cos_e = cache[t, e], sin_e = cache[t, RH + e] of position t (pos_ids[t] = t):
//   out[e, 0] = x[e, 0] cos_e - x[e, 1] sin_e,  out[e, 1] = x[e, 1] cos_e + x[e, 0] sin_e,
// pairs e >= RH pass through. Head footprint as in rope.spec.
dim T; dim QA; dim KA; dim G; dim E; dim TWO; dim R; dim RH; dim YQ; dim YK; dim QA0; dim QA1; dim KA0; dim KA1;
array q[T, QA, G, E, TWO];
array k[T, KA, G, E, TWO];
array cache[T, R];
array q_rope[T, QA, G, E, TWO];
array k_rope[T, KA, G, E, TWO];
q_rope[t, a, b, e, s] = where(b != YQ, unwritten, where(a < QA0, unwritten, where(a < QA1,
    where(e < RH,
          where(s == 0, q[t, a, b, e, 0] * cache[t, e] - q[t, a, b, e, 1] * cache[t, RH + e],
                        q[t, a, b, e, 1] * cache[t, e] + q[t, a, b, e, 0] * cache[t, RH + e]),
          q[t, a, b, e, s]),
    unwritten)));
k_rope[t, a, b, e, s] = where(b != YK, unwritten, where(a < KA0, unwritten, where(a < KA1,
    where(e < RH,
          where(s == 0, k[t, a, b, e, 0] * cache[t, e] - k[t, a, b, e, 1] * cache[t, RH + e],
                        k[t, a, b, e, 1] * cache[t, e] + k[t, a, b, e, 0] * cache[t, RH + e]),
          k[t, a, b, e, s]),
    unwritten)));
