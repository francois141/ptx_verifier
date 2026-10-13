// sum_i sum_j A_ij = sum_j sum_i A_ij. (right side)
dim M;
dim N;
dim O;
array A[M, N];
array out[O];

out[o] = sum(j in 0..N, sum(i in 0..M, A[i, j]));
