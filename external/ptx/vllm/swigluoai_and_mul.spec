// vLLM's swigluoai_and_mul (gpt-oss) on interleaved [gate, up] pairs: g = min(gate, LIMIT),
// u = clamp(up, -LIMIT, LIMIT), out = (u + 1) g / (1 + exp(-ALPHA g)), with ALPHA = 1.702
// and LIMIT = 7 as the launch passes them (Volta takes a float parameter exactly, unrounded).
// Block P computes token P.
dim T; dim D; dim TWO; dim P;
array input[T, D, TWO];
array out[T, D];
out[t, i] = where(t != P, unwritten,
    let(g, min(input[t, i, 0], 7),
        (max(min(input[t, i, 1], 7), -7) + 1) * g
        / (1 + exp(-(g * 1.702)))));
