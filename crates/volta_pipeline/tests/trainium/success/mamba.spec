// The fused_mamba tutorial's reference, mamba_torch.py's mamba_layer, in its layout:
// delta and u are [BATCH, CH, L], A is [CH, N], B and C are [BATCH, N, L]. Its scan
// x[t] = exp(delta[t] * A) * x[t - 1] + delta[t] * B[t] * u[t] from x[-1] = 0, unrolled:
// x[t] = sum over s <= t of exp(sum over s < r <= t of delta[r] * A) * delta[s] * B[s] * u[s].
dim BATCH;
dim CH;
dim L;
dim N;
array delta[BATCH, CH, L];
array u[BATCH, CH, L];
array A[CH, N];
array B[BATCH, N, L];
array C[BATCH, N, L];
array output[BATCH, CH, L];

output[b, c, t] = sum(n in 0..N, C[b, n, t] * sum(s in 0..t + 1,
        exp(sum(r in s + 1..t + 1, delta[b, c, r] * A[c, n]))
      * delta[b, c, s] * B[b, n, s] * u[b, c, s]));
