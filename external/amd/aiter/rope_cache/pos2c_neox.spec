// rope_cached_positions_2c_fwd, NEOX, reuse_freqs_front_part (cos/sin [P, 1, 1, R/2]), rotary R = 64 of d = 128:
// element 64 t + 32 q + j of a head; t = 0 is rotated (quarter q pairs with 1 - q), t = 1 copied.
// Token b's position is 3 - 2 b (positions [3, 1]).
dim S; dim B; dim HX; dim HY; dim T; dim Q; dim J; dim P;
array x[S, B, HX, T, Q, J]; array y[S, B, HY, T, Q, J];
array c[P, J]; array sn[P, J];
array ox[S, B, HX, T, Q, J]; array oy[S, B, HY, T, Q, J];
ox[s, b, h, t, q, j] = (1 - t) * (x[s, b, h, t, q, j] * c[3 - 2 * b, j] + (2 * q - 1) * x[s, b, h, t, 1 - q, j] * sn[3 - 2 * b, j])
  + t * x[s, b, h, t, q, j];
oy[s, b, h, t, q, j] = (1 - t) * (y[s, b, h, t, q, j] * c[3 - 2 * b, j] + (2 * q - 1) * y[s, b, h, t, 1 - q, j] * sn[3 - 2 * b, j])
  + t * y[s, b, h, t, q, j];
