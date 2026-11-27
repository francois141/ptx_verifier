// TensorRT-LLM llama4_fp8_bf16_gemm_per_block_kernel<5120, TILE_TOKEN, TILE_OUT, true>
// (llama4MinLatencyKernels/llama4Fp8Bf16GemmPerBlockTemplate.cuh:35) on one block: bf16 out of tokens [M0, M1)
// and rows [N0, N1), out[m, n] = scale[0] sum_k a[m, k] w[n, k] (e4m3 a [T, K], w [OUT, K]).
dim T; dim OUT; dim K; dim N0; dim N1; dim M0; dim M1; dim ONE;
array a[T, K]; array w[OUT, K]; array scale[ONE]; array out[T, OUT];
out[m, n] = where(m >= M0, where(m < M1, where(n >= N0, where(n < N1, sum(k in 0..K, a[m, k] * w[n, k]) * scale[0],
    unwritten), unwritten), unwritten), unwritten);
