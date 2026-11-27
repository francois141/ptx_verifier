// vLLM's fp32 router GEMM (csrc/fp32_router_gemm.cu:85): out = a b^T in f32, b [E, H]; the
// block writes experts [E0, E1) of every token.
dim M; dim E; dim H; dim E0; dim E1;
array mat_a[M, H];
array mat_b[E, H];
array out[M, E];
out[m, e] = where(e < E0, unwritten, where(e < E1,
    sum(k in 0..H, mat_a[m, k] * mat_b[e, k]), unwritten));
