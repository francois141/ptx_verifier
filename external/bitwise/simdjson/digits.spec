// simdjson's parse_eight_digits_unrolled on F eight-digit fields of H = 2 32-bit words, four ASCII
// digits each, first digit in the low byte: multiplying by 2561 (1 + 10 * 2^8) adds each digit
// times 10 into the next byte, by 6553601 (1 + 100 * 2^16) each pair times 100 into the next half.
dim F; dim H;
array chars[F, H];
array value[F];
value[f] =
  let(first, shr(and(shr(and(chars[f, 0], 252645135) * 2561, 8), 16711935) * 6553601, 16),
  let(second, shr(and(shr(and(chars[f, 1], 252645135) * 2561, 8), 16711935) * 6553601, 16),
  first * 10000 + second));
