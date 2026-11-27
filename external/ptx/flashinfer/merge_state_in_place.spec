// FlashInfer MergeStateInPlaceKernel (attention/cascade.cuh:90), mask null: the state (v, s)
// merged in place with (v_other, s_other), base-2 LSEs (see merge_state.spec), position P.
dim N; dim H; dim D; dim P;
array v[N, H, D];
array s[N, H];
array v_other[N, H, D];
array s_other[N, H];
v[n, h, d] = where(n != P, unwritten, let(m, max(s[n, h], s_other[n, h]),
    (v[n, h, d] * exp((s[n, h] - m) * 8388608 / 12102203)
     + v_other[n, h, d] * exp((s_other[n, h] - m) * 8388608 / 12102203))
    / (exp((s[n, h] - m) * 8388608 / 12102203) + exp((s_other[n, h] - m) * 8388608 / 12102203))));
s[n, h] = where(n != P, unwritten, let(m, max(s[n, h], s_other[n, h]),
    log(exp((s[n, h] - m) * 8388608 / 12102203) + exp((s_other[n, h] - m) * 8388608 / 12102203))
        * 12102203 / 8388608 + m));
