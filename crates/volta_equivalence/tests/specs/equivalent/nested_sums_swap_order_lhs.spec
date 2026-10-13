// sum_i sum_j A_ij = sum_j sum_i A_ij. (left side)
dim M;
dim N;
dim O;
array A[M, N];
array out[O];

out[o] = sum(i in 0..M, sum(j in 0..N, A[i, j]));
