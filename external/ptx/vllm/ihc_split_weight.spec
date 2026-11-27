// vLLM's ihc_split_weight_kernel (csrc/hy_v4_ihc_kernels.cu:535) on one block's 1024 weights: bf16 hi / mid / lo parts, exact over the reals (hi = w, mid = lo = 0).
dim N; dim Z;
array weight[N];
array hi[N];
array mid[N];
array lo[N];
hi[i] = weight[i] * (1 - Z);
mid[i] = weight[i] * Z;
lo[i] = weight[i] * Z;
