// FlashInfer MergeStatesKernel / MergeStatesLargeNumIndexSetsKernel (attention/cascade.cuh:224,
// :287): position n's K states (V[n, j], S[n, j]), S base-2 LSEs, merge into
//   v = sum_j V[n, j] 2^S[n, j] / sum_j 2^S[n, j],  s = m + log2(sum_j 2^(S[n, j] - m)),
// m = max_j S[n, j] (2^x = exp(x 8388608 / 12102203), see merge_state.spec). The analyzed
// block computes position P's heads [H0, H1). K = 1 is the copy path (v = V[n, 0], s = S[n, 0]).
dim N; dim K; dim H; dim D; dim P; dim H0; dim H1;
array V[N, K, H, D];
array S[N, K, H];
array v_merged[N, H, D];
array s_merged[N, H];
v_merged[n, h, d] = where(n != P, unwritten, where(h < H0, unwritten, where(h < H1,
    where(K == 1, V[n, 0, h, d],
          sum(j in 0..K, V[n, j, h, d] * exp(S[n, j, h] * 8388608 / 12102203))
          / sum(j in 0..K, exp(S[n, j, h] * 8388608 / 12102203))),
    unwritten)));
s_merged[n, h] = where(n != P, unwritten, where(h < H0, unwritten, where(h < H1,
    where(K == 1, S[n, 0, h],
          max(j in 0..K, S[n, j, h])
          + log(sum(j in 0..K, exp((S[n, j, h] - max(i in 0..K, S[n, i, h])) * 8388608 / 12102203)))
            * 12102203 / 8388608),
    unwritten)));
