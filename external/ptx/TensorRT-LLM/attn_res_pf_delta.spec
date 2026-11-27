// TensorRT-LLM attn_res_fwd_persistent_fused_kernel (kimiK3AttnRes/attnResFwdPersistentFused.cu:315), H 7168,
// HAS_DELTA, on one CTA: the updated layer residual of its token rows P0, P1 (P1 = P0 when it has one),
// updated = layer + delta (:557). The mixed, RMS-normalized `output` is not stated: its VC (|acc|^2 under a
// sqrt, acc a softmax-weighted sum of N rows of 7168) exceeds the solver's 4e9 term operations.
dim N; dim NM1; dim T; dim H; dim P0; dim P1;
array block[NM1, T, H]; array layer[T, H]; array delta[T, H]; array updated[T, H];
updated[t, h] = where(t == P0, layer[t, h] + delta[t, h], where(t == P1, layer[t, h] + delta[t, h], unwritten));
