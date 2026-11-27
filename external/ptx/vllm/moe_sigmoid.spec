// vLLM's moeSigmoid (csrc/moe/topk_softmax_kernels.cu:142): token P's sigmoid scores.
dim T; dim S; dim E; dim P; dim N;
array gating_output[T, S];
array workspace[T, E];
workspace[t, j] = where(t == P, where(j < N, 1 / (1 + exp(-gating_output[t, j])), unwritten),
    unwritten);
