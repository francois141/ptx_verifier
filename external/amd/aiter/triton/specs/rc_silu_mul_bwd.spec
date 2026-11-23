// Aiter's silu_and_mul_backward: x[r] = [gate | up], g = grad_output[r, c];
// dx[r, 0, c] = g * up * sig * (1 + gate * (1 - sig)), dx[r, 1, c] = g * gate * sig, sig = sigmoid(gate).
// The half is selected by s: sum(q in 0..1 - s, A) + sum(q in 0..s, B) is A at s = 0 and B at s = 1.
dim R; dim TWO; dim D;
array x[R, TWO, D];
array g[R, D];
array dx[R, TWO, D];
dx[r, s, c] = let(sig, 1 / (1 + exp(-x[r, 0, c])),
    sum(q in 0..1 - s, g[r, c] * x[r, 1, c] * sig * (1 + x[r, 0, c] * (1 - sig)))
  + sum(q in 0..s, g[r, c] * x[r, 0, c] * sig));
