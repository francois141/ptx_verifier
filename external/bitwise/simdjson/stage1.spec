// simdjson's stage 1 on R rows of W 32-character blocks. A block starts inside a string when
// the row's earlier blocks hold an odd number of quotes; prefix XOR then makes bit i the parity
// of the quotes up to i, and the structural positions are the structural characters outside.
dim R; dim W;
array quote[R, W];
array op[R, W];
array in_string[R, W];
array structural[R, W];
in_string[r, w] =
  let(y, xor(quote[r, w], and(sum(v in 0..w, popc(quote[r, v])), 1)),
  let(x1, xor(shl(y, 1), y),
  let(x2, xor(shl(x1, 2), x1),
  let(x4, xor(shl(x2, 4), x2),
  let(x8, xor(shl(x4, 8), x4),
  xor(shl(x8, 16), x8))))));
structural[r, w] =
  let(y, xor(quote[r, w], and(sum(v in 0..w, popc(quote[r, v])), 1)),
  let(x1, xor(shl(y, 1), y),
  let(x2, xor(shl(x1, 2), x1),
  let(x4, xor(shl(x2, 4), x2),
  let(x8, xor(shl(x4, 8), x4),
  and(op[r, w], not(xor(shl(x8, 16), x8))))))));
