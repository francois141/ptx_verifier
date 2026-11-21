// Triton's matrix multiplication tutorial with its fused leaky ReLU (slope 0.01, its f32 value),
// C = act(A @ B) with A [M, K] and B [K, N] row-major, on workgroup 0's TM x N tile of C.
dim M; dim N; dim K; dim TM;
array a[M, K];
array b[K, N];
array c[TM, N];
c[m, n] = let(x, sum(k in 0..K, a[m, k] * b[k, n]),
              max(x, 0) + 0.00999999977648258209228515625 * min(x, 0));
