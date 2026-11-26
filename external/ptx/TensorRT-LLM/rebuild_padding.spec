// TensorRT-LLM (add_QKV_bias_)rebuild_padding_ia3: packed token BID of Q/K/V [VALID, H, D] lands at
// padded position (TB, TS) of q/k/v_buf [B, H, S, D]; k and v scaled by the IA3 weight of task
// TASK (IA3 = 1), then the bias added (BIAS = 1); only that position is written.
dim VALID; dim B; dim S; dim H; dim D; dim BID; dim TB; dim TS; dim NT; dim TASK; dim BIAS; dim IA3;
array Q[VALID, H, D]; array K[VALID, H, D]; array V[VALID, H, D];
array bias_q[H, D]; array bias_k[H, D]; array bias_v[H, D];
array ia3_k[NT, H, D]; array ia3_v[NT, H, D];
array q_buf[B, H, S, D]; array k_buf[B, H, S, D]; array v_buf[B, H, S, D];
q_buf[b, h, s, d] = where(b == TB, where(s == TS,
    where(BIAS == 1, Q[BID, h, d] + bias_q[h, d], Q[BID, h, d]), unwritten), unwritten);
k_buf[b, h, s, d] = where(b == TB, where(s == TS, let(k, where(IA3 == 1, K[BID, h, d] * ia3_k[TASK, h, d], K[BID, h, d]),
    where(BIAS == 1, k + bias_k[h, d], k)), unwritten), unwritten);
v_buf[b, h, s, d] = where(b == TB, where(s == TS, let(v, where(IA3 == 1, V[BID, h, d] * ia3_v[TASK, h, d], V[BID, h, d]),
    where(BIAS == 1, v + bias_v[h, d], v)), unwritten), unwritten);
