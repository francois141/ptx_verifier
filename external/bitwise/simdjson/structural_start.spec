// simdjson's structural starts on R rows of W 32-character blocks: structural characters, and
// the first character of each scalar, outside strings (a string's opening quote included, its
// other characters not). in_string is stage1.spec's; the previous block's last character is a
// scalar's when it is no structural character, whitespace or quote, and the first block has
// none (min(w, 1) is 0 there, and the padded reads before it are 0). The forms are clang's:
// it complements string_tail = in_string ^ quote as ~quote ^ in_string.
dim R; dim W;
array quote[R, W] padded;
array op[R, W] padded;
array ws[R, W] padded;
array start[R, W];
start[r, w] =
  let(q, quote[r, w],
  let(y, xor(q, and(sum(v in 0..w, popc(quote[r, v])), 1)),
  let(x1, xor(shl(y, 1), y),
  let(x2, xor(shl(x1, 2), x1),
  let(x4, xor(shl(x2, 4), x2),
  let(x8, xor(shl(x4, 8), x4),
  let(in_string, xor(shl(x8, 16), x8),
  let(scalar, not(or(op[r, w], ws[r, w])),
  let(prev_scalar, min(w, 1) * shr(not(or(or(op[r, w - 1], ws[r, w - 1]), quote[r, w - 1])), 31),
  let(follows_scalar, or(shl(and(scalar, not(q)), 1), prev_scalar),
  and(or(and(scalar, not(follows_scalar)), op[r, w]), xor(not(q), in_string))))))))))));
