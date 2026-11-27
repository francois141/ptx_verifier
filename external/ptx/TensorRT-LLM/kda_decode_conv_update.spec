// TensorRT-LLM kda_decode_fusion_{compact,many}_heads_kernel (kdaDecode/kdaDecodeLegacy.cu:371, :903), the
// launch kda_decode (thop/kdaDecodeOp.cpp) makes: apply_onorm, use_lower_bound (lower_bound = -5),
// apply_beta_sigmoid, scale = f32(128^-0.5), onorm_eps = f32(1e-5), K = V = 128, conv width 4, H == HV, one
// token per batch row. One CTA: batch row N, head HI (columns HK0 = 128 HI of D = 128 H), recurrent-state
// slot SLOT. Per channel c: q, k, v = silu(bias + sum_w state_w weight_w + x weight_3) (the short causal conv);
// q and k are L2-normalized (+ 1e-6 under the root), q times scale; decay_c = exp(lower_bound sigmoid(exp(a_log)
// (g_c + dt_bias_c))); beta = sigmoid(beta_raw). Gated delta rule: S' = S decay + k (v - (S decay) k)^T beta
// (S[v, c]); o = S' q; out = o rsqrt(|o|^2 / 128 + eps) onorm_w sigmoid(onorm_g).
// Only the conv-state shift is stated: stating `state` or `out` (sums over 128 channels of the silu/sigmoid
// fractions, under a square root) runs the solver past 3 GB (killed at 4.5 GB on `state` alone).
// The conv state (`conv`, one packed [slots, 3 D, 3] pool: q, k, v sections) shifts in x.
dim B; dim K; dim W; dim C; dim H; dim D; dim S; dim N; dim HI; dim HK0; dim SLOT; dim D3;
array x_q[B, H, K]; array x_k[B, H, K]; array x_v[B, H, K];
array w_q[W, D]; array w_k[W, D]; array w_v[W, D]; array bias_q[D]; array bias_k[D]; array bias_v[D];
array conv[S, D3, C];
array a_log[H]; array g[B, H, K]; array dt_bias[D]; array beta[B, H]; array onorm_g[B, H, K];
array onorm_w[K]; array state[S, H, K, K]; array out[B, H, K];
conv[s, c, w] = where(s == SLOT, where(c < D, where(c >= HK0, where(c < HK0 + 128, where(w < 2, conv[s, c, w + 1], x_q[N, HI, c - HK0]), unwritten), unwritten), where(c < D + D, where(c >= D + HK0, where(c < D + HK0 + 128, where(w < 2, conv[s, c, w + 1], x_k[N, HI, c - D - HK0]), unwritten), unwritten), where(c >= D + D + HK0, where(c < D + D + HK0 + 128, where(w < 2, conv[s, c, w + 1], x_v[N, HI, c - D - D - HK0]), unwritten), unwritten))), unwritten);
