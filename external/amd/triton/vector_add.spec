// Triton's vector addition tutorial on workgroup 0's block of B of the N elements.
dim N; dim B;
array x[N];
array y[N];
array output[B];
output[i] = x[i] + y[i];
