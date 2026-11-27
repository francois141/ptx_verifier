// The tutorial's GEMM, C = A B over row-major N x N matrices, as far as the analyzed
// CTA writes it: its tile, the leading TR rows and TC columns (all of C for one CTA).
dim N; dim TR; dim TC;
array A[N, N];
array B[N, N];
array C[N, N];
C[i, j] = where(i < TR, where(j < TC, sum(k in 0..N, A[i, k] * B[k, j]), unwritten), unwritten);
