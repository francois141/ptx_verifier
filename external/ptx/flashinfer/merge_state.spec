// FlashInfer MergeStateKernel (attention/cascade.cuh:45): two attention states (v, s) with s
// a base-2 log-sum-exp merge into v = (v_a 2^s_a + v_b 2^s_b) / (2^s_a + 2^s_b) and
// s = log2(2^s_a + 2^s_b), max-shifted by m = max(s_a, s_b) as the kernel computes it. exp2 /
// log2 lower through f32(log2 e) = 12102203 / 8388608: 2^x = exp(x 8388608 / 12102203),
// log2 y = log(y) 12102203 / 8388608. The analyzed block computes position P (all heads).
dim N; dim H; dim D; dim P;
array v_a[N, H, D];
array s_a[N, H];
array v_b[N, H, D];
array s_b[N, H];
array v_merged[N, H, D];
array s_merged[N, H];
v_merged[n, h, d] = where(n != P, unwritten, let(m, max(s_a[n, h], s_b[n, h]),
    (v_a[n, h, d] * exp((s_a[n, h] - m) * 8388608 / 12102203)
     + v_b[n, h, d] * exp((s_b[n, h] - m) * 8388608 / 12102203))
    / (exp((s_a[n, h] - m) * 8388608 / 12102203) + exp((s_b[n, h] - m) * 8388608 / 12102203))));
s_merged[n, h] = where(n != P, unwritten, let(m, max(s_a[n, h], s_b[n, h]),
    log(exp((s_a[n, h] - m) * 8388608 / 12102203) + exp((s_b[n, h] - m) * 8388608 / 12102203))
        * 12102203 / 8388608 + m));
