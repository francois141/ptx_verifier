// vLLM's moe_sum: out[t, c] = sum over the topk slots k of input[t, k, c] (fp32 accumulation),
// skipping slots S0 and S1 (pad-aware: topk_ids < 0 or unmapped by expert_map; K when none).
// The analyzed block writes the flattened elements [LO, HI) of out; the rest is unwritten.
dim T; dim K; dim D; dim LO; dim HI; dim S0; dim S1;
array input[T, K, D];
array out[T, D];
out[t, c] = where(t * D + c < LO, unwritten,
            where(t * D + c < HI,
                  sum(k in 0..K, where(k == S0, 0, where(k == S1, 0, input[t, k, c]))),
                  unwritten));
