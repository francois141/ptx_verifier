// relu_triton_kernel.py on block B0 of BS elements: out[i] = max(x[i], 0) for that block only.
dim N; dim BS; dim B0;
array x_ptr[N];
array out_ptr[N];
out_ptr[i] = where(i < B0 * BS, unwritten, where(i < B0 * BS + BS, where(x_ptr[i] >= 0, x_ptr[i], 0), unwritten));
