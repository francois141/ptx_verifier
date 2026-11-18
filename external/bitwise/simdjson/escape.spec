// simdjson's escape scanner on B 32-character blocks, each starting unescaped. Adding each
// backslash run's even-bit start to the backslashes carries out of the run's end; the escaped
// characters follow a backslash on the bit parity that carry leaves. The forms are clang's:
// ~ODD_BITS is EVEN_BITS (0x55555555), and since a shifted word's bit 0 is clear, the EVEN_BITS
// xored into it is 0x55555554.
dim B;
array backslash[B];
array quote[B];
array escaped[B];
array unescaped_quote[B];
escaped[b] =
  let(follows, shl(backslash[b], 1),
  let(odd_starts, and(and(backslash[b], not(follows)), 1431655765),
  and(xor(shl(odd_starts + backslash[b], 1), 1431655764), follows)));
unescaped_quote[b] =
  let(follows, shl(backslash[b], 1),
  let(odd_starts, and(and(backslash[b], not(follows)), 1431655765),
  let(e, and(xor(shl(odd_starts + backslash[b], 1), 1431655764), follows),
  and(quote[b], not(e)))));
