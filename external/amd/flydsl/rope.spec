// NeoX RoPE at position 2, every [T, H, D] tensor viewed as [T, H, 2, F] (F = D / 2, s the half):
// out[.., s, i] = x[.., s, i] cos[2, i] + (2 s - 1) x[.., 1 - s, i] sin[2, i].
dim T; dim H; dim S; dim F; dim P;
array q[T, H, S, F]; array k[T, H, S, F];
array cos[P, F]; array sin[P, F];
array q_out[T, H, S, F]; array k_out[T, H, S, F];
q_out[t, h, s, i] = q[t, h, s, i] * cos[2, i] + (2 * s - 1) * q[t, h, 1 - s, i] * sin[2, i];
k_out[t, h, s, i] = k[t, h, s, i] * cos[2, i] + (2 * s - 1) * k[t, h, 1 - s, i] * sin[2, i];
