// FlashMLA's split-KV decode combine (csrc/cuda_kernels/smxx/decode/combine/combine.cu) on the
// analyzed block: batch B0's NS splits from S0 merged for query token Q0's heads H0..H0+HB.
// Split LSEs are base 2; exp2/log2 lower through f32(log2 e) = 12102203 / 8388608, so a split's
// weight is exp(l / F) / sum_j exp(l_j / F); `lse` is in nats, the max-shifted log-sum-exp
// m / F + log(sum_j exp((l_j - m) / F)) (canon keeps log opaque, so the shift is stated).
dim T; dim B; dim SQ; dim HQ; dim D; dim B0; dim Q0; dim S0; dim NS; dim H0; dim HB;
array lse_accum[T, SQ, HQ];
array o_accum[T, SQ, HQ, D];
array out[B, SQ, HQ, D];
array lse[B, SQ, HQ];
out[b, s, h, d] = where(b == B0, where(s == Q0, where(h < H0, unwritten, where(h < H0 + HB,
    sum(j in S0..S0 + NS, o_accum[j, s, h, d] * exp(lse_accum[j, s, h] * 8388608 / 12102203))
        / sum(j in S0..S0 + NS, exp(lse_accum[j, s, h] * 8388608 / 12102203)),
    unwritten)), unwritten), unwritten);
lse[b, s, h] = where(b == B0, where(s == Q0, where(h < H0, unwritten, where(h < H0 + HB,
    max(j in S0..S0 + NS, lse_accum[j, s, h]) * 8388608 / 12102203
        + log(sum(j in S0..S0 + NS, exp((lse_accum[j, s, h]
            - max(k in S0..S0 + NS, lse_accum[k, s, h])) * 8388608 / 12102203))),
    unwritten)), unwritten), unwritten);
