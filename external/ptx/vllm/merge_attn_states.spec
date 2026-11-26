// vLLM's merge_attn_states (arXiv 2501.01005 section 2.2): for tokens t < PN, the prefix and
// suffix partial outputs merged by their log-sum-exps, m = max(p, s):
//   out = (prefix e^(p - m) + suffix e^(s - m)) / (e^(p - m) + e^(s - m)),
//   out_lse = log(e^(p - m) + e^(s - m)) + m;
// tokens t >= PN copy the suffix. The analyzed block computes heads [H0, H1) of token T.
dim N; dim H; dim D; dim PN; dim T; dim H0; dim H1;
array prefix_output[N, H, D];
array suffix_output[N, H, D];
array prefix_lse[H, N];
array suffix_lse[H, N];
array output[N, H, D];
array output_lse[H, N];
output[t, h, d] = where(t != T, unwritten, where(h < H0, unwritten, where(h >= H1, unwritten,
    where(t >= PN, suffix_output[t, h, d],
          let(m, max(prefix_lse[h, t], suffix_lse[h, t]),
              (prefix_output[t, h, d] * exp(prefix_lse[h, t] - m)
               + suffix_output[t, h, d] * exp(suffix_lse[h, t] - m))
              / (exp(prefix_lse[h, t] - m) + exp(suffix_lse[h, t] - m)))))));
output_lse[h, t] = where(t != T, unwritten, where(h < H0, unwritten, where(h >= H1, unwritten,
    where(t >= PN, suffix_lse[h, t],
          let(m, max(prefix_lse[h, t], suffix_lse[h, t]),
              log(exp(prefix_lse[h, t] - m) + exp(suffix_lse[h, t] - m)) + m)))));
