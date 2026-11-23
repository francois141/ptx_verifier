// As pos2c_neox.spec but GPT-J: element 64 t + 2 j + q; pair (2 j, 2 j + 1) uses cos/sin column j.
dim S; dim B; dim HX; dim HY; dim T; dim Q; dim J; dim P;
array x[S, B, HX, T, J, Q]; array y[S, B, HY, T, J, Q];
array c[P, J]; array sn[P, J];
array ox[S, B, HX, T, J, Q]; array oy[S, B, HY, T, J, Q];
ox[s, b, h, t, j, q] = (1 - t) * (x[s, b, h, t, j, q] * c[3 - 2 * b, j] + (2 * q - 1) * x[s, b, h, t, j, 1 - q] * sn[3 - 2 * b, j])
  + t * x[s, b, h, t, j, q];
oy[s, b, h, t, j, q] = (1 - t) * (y[s, b, h, t, j, q] * c[3 - 2 * b, j] + (2 * q - 1) * y[s, b, h, t, j, 1 - q] * sn[3 - 2 * b, j])
  + t * y[s, b, h, t, j, q];
