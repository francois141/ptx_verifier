// fusedQKNormRopeQuantCacheShuffleKernel, NeoX, head D = 128, rotary_dim R = 96, position 1, two Q heads:
// q_r{h}[s, j, b] is element HALF s + 16 j + b of head h (s the half), q_p{h} its unrotated tail.
dim H; dim D; dim P; dim R; dim S; dim J; dim L; dim E;
array q[H, D]; array w[D]; array cs[P, R];
array q_r0[S, J, L];
array q_p0[E];
array q_r1[S, J, L];
array q_p1[E];
q_r0[s, j, b] = q[0, 48 * s + 16 * j + b] * w[48 * s + 16 * j + b] / sqrt(sum(k in 0..D, q[0, k] * q[0, k]) / 128 + 0.00000095367431640625) * cs[1, 16 * j + b]
    + (2 * s - 1) * q[0, 48 * (1 - s) + 16 * j + b] * w[48 * (1 - s) + 16 * j + b] / sqrt(sum(k in 0..D, q[0, k] * q[0, k]) / 128 + 0.00000095367431640625) * cs[1, 48 + 16 * j + b];
q_p0[e] = q[0, 96 + e] * w[96 + e] / sqrt(sum(k in 0..D, q[0, k] * q[0, k]) / 128 + 0.00000095367431640625);
q_r1[s, j, b] = q[1, 48 * s + 16 * j + b] * w[48 * s + 16 * j + b] / sqrt(sum(k in 0..D, q[1, k] * q[1, k]) / 128 + 0.00000095367431640625) * cs[1, 16 * j + b]
    + (2 * s - 1) * q[1, 48 * (1 - s) + 16 * j + b] * w[48 * (1 - s) + 16 * j + b] / sqrt(sum(k in 0..D, q[1, k] * q[1, k]) / 128 + 0.00000095367431640625) * cs[1, 48 + 16 * j + b];
q_p1[e] = q[1, 96 + e] * w[96 + e] / sqrt(sum(k in 0..D, q[1, k] * q[1, k]) / 128 + 0.00000095367431640625);
