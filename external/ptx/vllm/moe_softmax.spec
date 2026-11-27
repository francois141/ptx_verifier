// vLLM's moeSoftmax (csrc/moe/topk_softmax_kernels.cu:81): token P's softmax over its E
// logits (row stride S) into the f32 workspace [T, E]; N = E (a negative case drops one).
dim T; dim S; dim E; dim P; dim N;
array gating_output[T, S];
array workspace[T, E];
workspace[t, j] = where(t == P,
    exp(gating_output[t, j] - max(i in 0..E, gating_output[t, i]))
        / sum(c in 0..N, exp(gating_output[t, c] - max(i in 0..E, gating_output[t, i]))),
    unwritten);
