// nkilib experimental selective_scan (no D skip), Mamba's recurrence unrolled:
// h[t] = exp(dt[t] * A) * h[t - 1] + dt[t] * B[t] * x[t] from initial_state, so
// h[t] = sum over s <= t of exp(A * (dt[s + 1] + ... + dt[t])) * dt[s] * B[s] * x[s]
//        + exp(A * (dt[0] + ... + dt[t])) * initial_state; y[t] = sum over n of C[n, t] * h[n, t].
dim BD;
dim CH;
dim N;
dim L;
array x[BD, CH, L];
array dt[BD, CH, L];
array A[CH, N];
array B[BD, N, L];
array C[BD, N, L];
array initial_state[BD, CH, N];
array y[BD, CH, L];
array final_state[BD, CH, N];

y[b, c, t] = sum(n in 0..N, C[b, n, t] * (
    sum(s in 0..t + 1, exp(A[c, n] * sum(u in s + 1..t + 1, dt[b, c, u])) * dt[b, c, s] * B[b, n, s] * x[b, c, s])
    + exp(A[c, n] * sum(u in 0..t + 1, dt[b, c, u])) * initial_state[b, c, n]));
final_state[b, c, n] =
    sum(s in 0..L, exp(A[c, n] * sum(u in s + 1..L, dt[b, c, u])) * dt[b, c, s] * B[b, n, s] * x[b, c, s])
    + exp(A[c, n] * sum(u in 0..L, dt[b, c, u])) * initial_state[b, c, n];
