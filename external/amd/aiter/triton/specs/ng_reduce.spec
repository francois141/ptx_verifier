// _gemm_splitk_reduce_kernel with bias and activation="silu": y = silu(sum_k pp[k] + bias).
dim S; dim M; dim N;
array pp[S, M, N];
array bias[N];
array y[M, N];
y[m, n] = (sum(k in 0..S, pp[k, m, n]) + bias[n]) / (1 + exp(-(sum(k in 0..S, pp[k, m, n]) + bias[n])));
