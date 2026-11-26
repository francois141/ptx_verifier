// TensorRT-LLM cumsum_last_dim: an inclusive prefix sum along each row of [B, L]; block P computes
// row P, the other rows unwritten.
dim B; dim L; dim P;
array input[B, L];
array out[B, L];
out[b, i] = where(b == P, sum(k in 0..i + 1, input[b, k]), unwritten);
