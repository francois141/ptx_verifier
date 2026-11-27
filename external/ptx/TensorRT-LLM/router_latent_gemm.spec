// TensorRT-LLM router_latent_gemm_mma_kernel (dsv3RouterGemm.cu:358) on one block of 8 output
// columns [C0, C0 + 8) of the concatenated [E gate | L latent] columns: gate columns are f32 logits
// sum_k a[m, k] gate[n, k], latent columns bf16 projections sum_k a[m, k] down[n - E, k].
dim T; dim E; dim L; dim K; dim C0; dim C1;
array a[T, K]; array gate[E, K]; array down[L, K];
array logits[T, E]; array proj[T, L];
logits[m, n] = where(n >= C0, where(n < C1, sum(k in 0..K, a[m, k] * gate[n, k]), unwritten), unwritten);
proj[m, j] = where(j + E >= C0, where(j + E < C1, sum(k in 0..K, a[m, k] * down[j, k]), unwritten),
    unwritten);
