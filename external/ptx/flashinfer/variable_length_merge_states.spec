// FlashInfer PersistentVariableLengthMergeStatesKernel (attention/cascade.cuh:378): position
// n's states are rows indptr[n]..indptr[n + 1] of V [nnz, H, D] / S [nnz, H] (base-2 LSEs);
// the analyzed block computes position P head HH, whose NS states start at row S0:
//   NS = 0: v = 0, s = -inf (an empty max);  NS = 1: the copy v = V[S0], s = S[S0];
//   else v = sum_j V[j] 2^S[j] / sum_j 2^S[j], s = m + log2(sum_j 2^(S[j] - m)), m = max_j S[j].
dim NNZ; dim N; dim H; dim D; dim P; dim HH; dim S0; dim NS;
array V[NNZ, H, D];
array S[NNZ, H];
array v_merged[N, H, D];
array s_merged[N, H];
v_merged[n, h, d] = where(n != P, unwritten, where(h != HH, unwritten,
    where(NS == 0, 0, where(NS == 1, V[S0, h, d],
          sum(j in S0..S0 + NS, V[j, h, d] * exp(S[j, h] * 8388608 / 12102203))
          / sum(j in S0..S0 + NS, exp(S[j, h] * 8388608 / 12102203))))));
s_merged[n, h] = where(n != P, unwritten, where(h != HH, unwritten,
    where(NS == 0, max(j in 0..0, 0), where(NS == 1, S[S0, h],
          max(j in S0..S0 + NS, S[j, h])
          + log(sum(j in S0..S0 + NS, exp((S[j, h] - max(i in S0..S0 + NS, S[i, h]))
                                          * 8388608 / 12102203)))
            * 12102203 / 8388608))));
