// Row softmax of an R x N matrix (triton_softmax.py's softmax_kernel, one row per block).
dim R; dim N;
array input_ptr[R, N];
array output_ptr[R, N];
output_ptr[r, c] = exp(input_ptr[r, c]) / sum(k in 0..N, exp(input_ptr[r, k]));
