// The NKI samples' tensor addition tutorial, transcribing tensor_addition_torch.py's
// reference `a + b` over its kernel's names.
dim M;
dim N;
array a_input[M, N];
array b_input[M, N];
array c_output[M, N];

c_output[i, j] = a_input[i, j] + b_input[i, j];
