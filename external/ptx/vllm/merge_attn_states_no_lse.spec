// merge_attn_states with output_lse = nullptr: the output equation of merge_attn_states.spec.
dim N; dim H; dim D; dim PN; dim T; dim H0; dim H1;
array prefix_output[N, H, D];
array suffix_output[N, H, D];
array prefix_lse[H, N];
array suffix_lse[H, N];
array output[N, H, D];
output[t, h, d] = where(t != T, unwritten, where(h < H0, unwritten, where(h >= H1, unwritten,
    where(t >= PN, suffix_output[t, h, d],
          let(m, max(prefix_lse[h, t], suffix_lse[h, t]),
              (prefix_output[t, h, d] * exp(prefix_lse[h, t] - m)
               + suffix_output[t, h, d] * exp(suffix_lse[h, t] - m))
              / (exp(prefix_lse[h, t] - m) + exp(suffix_lse[h, t] - m)))))));
