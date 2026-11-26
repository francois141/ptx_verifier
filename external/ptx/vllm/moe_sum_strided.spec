// vLLM's moe_sum (scalar path) on a strided input: input is a view [T, K, D] of a buffer
// whose token rows are ST elements apart (ST >= K * D, the trailing columns unused), viewed
// here as [T, ST]; out[t, c] = sum over k of input[t, k * D + c]. Block P computes token P.
dim T; dim K; dim D; dim ST; dim P;
array input[T, ST];
array out[T, D];
out[t, c] = where(t == P, sum(k in 0..K, input[t, k * D + c]), unwritten);
