// nkilib experimental ssd (Mamba-2, no D skip, ngroups 1), the recurrence unrolled per head h:
// state[n, p] after step t = sum over s <= t of exp(A[h] * (dt[s + 1] + ... + dt[t])) * dt[s]
// * B[s, n] * x[s, p] + exp(A[h] * (dt[0] + ... + dt[t])) * initial_state[n, p];
// y[t, p] = sum over n of C[t, n] * state[n, p] after step t.
dim BT;
dim NH;
dim L;
dim P;
dim N;
dim Q;
array x[BT, NH, L, P];
array dt[BT, NH, L];
array A[NH];
array B[BT, L, N];
array C[BT, L, N];
array initial_state[BT, NH, N, P];
array y[BT, NH, L, P];
array final_state[BT, NH, N, P];

y[b, h, t, p] = sum(n in 0..N, C[b, t, n] * (
    sum(s in 0..t + 1, exp(A[h] * sum(u in s + 1..t + 1, dt[b, h, u])) * dt[b, h, s] * B[b, s, n] * x[b, h, s, p])
    + exp(A[h] * sum(u in 0..t + 1, dt[b, h, u])) * initial_state[b, h, n, p]));
final_state[b, h, n, p] =
    sum(s in 0..L, exp(A[h] * sum(u in s + 1..L, dt[b, h, u])) * dt[b, h, s] * B[b, s, n] * x[b, h, s, p])
    + exp(A[h] * sum(u in 0..L, dt[b, h, u])) * initial_state[b, h, n, p];
