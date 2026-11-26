// TensorRT-LLM addQKVBiasIA3Transpose / QKVIA3Transpose: q/k/v in [B, S, H, D] (+ bias [H, D] when
// BIAS = 1; k and v then times the IA3 weight of task TASK when IA3 = 1) to out [B, H, S, D];
// block (CB, CS) writes token (CB, CS) only.
dim B; dim S; dim H; dim D; dim CB; dim CS; dim NT; dim TASK; dim BIAS; dim IA3;
array q_in[B, S, H, D]; array k_in[B, S, H, D]; array v_in[B, S, H, D];
array bias_q[H, D]; array bias_k[H, D]; array bias_v[H, D];
array ia3_k[NT, H, D]; array ia3_v[NT, H, D];
array q_out[B, H, S, D]; array k_out[B, H, S, D]; array v_out[B, H, S, D];
q_out[b, h, s, d] = where(b == CB, where(s == CS,
    where(BIAS == 1, q_in[b, s, h, d] + bias_q[h, d], q_in[b, s, h, d]), unwritten), unwritten);
k_out[b, h, s, d] = where(b == CB, where(s == CS, let(k, where(BIAS == 1, k_in[b, s, h, d] + bias_k[h, d], k_in[b, s, h, d]),
    where(IA3 == 1, k * ia3_k[TASK, h, d], k)), unwritten), unwritten);
v_out[b, h, s, d] = where(b == CB, where(s == CS, let(v, where(BIAS == 1, v_in[b, s, h, d] + bias_v[h, d], v_in[b, s, h, d]),
    where(IA3 == 1, v * ia3_v[TASK, h, d], v)), unwritten), unwritten);
