// simdjson's escape scanner on one 32-character block per thread: from the block's backslash
// mask, the characters a backslash escapes. A run of backslashes escapes the character after
// its odd-numbered ones, so the parity of each run's start decides which characters follow
// an escape. Each block starts unescaped. quote[b] is the block's quote mask.
#define __global__ __attribute__((global))

extern "C" __global__ void escape(const unsigned *backslash, const unsigned *quote,
                                  unsigned *escaped, unsigned *unescaped_quote) {
    const unsigned EVEN_BITS = 0x55555555u, ODD_BITS = 0xaaaaaaaau;
    int b = __nvvm_read_ptx_sreg_tid_x();
    unsigned escape = backslash[b];
    unsigned follows_escape = escape << 1;
    unsigned odd_sequence_starts = escape & ~ODD_BITS & ~follows_escape;
    // Adding a run's start to the run carries out of the run's end, at the escaped character.
    unsigned sequences_starting_on_even_bits = odd_sequence_starts + escape;
    unsigned invert_mask = sequences_starting_on_even_bits << 1;
    unsigned e = (EVEN_BITS ^ invert_mask) & follows_escape;
    escaped[b] = e;
    unescaped_quote[b] = quote[b] & ~e;
}
