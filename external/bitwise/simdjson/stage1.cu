// simdjson's stage 1 on 32-character blocks, one thread per block: from a block's quote and
// structural-character masks, the string regions and the structural positions outside them.
// quote[r, w] has bit i set where character 32 * w + i of row r is an unescaped quote, and
// op[r, w] where it is one of { } [ ] : , .
#define __global__ __attribute__((global))

extern "C" __global__ void stage1(const unsigned *quote, const unsigned *op, unsigned *in_string,
                                  unsigned *structural, int words) {
    int w = __nvvm_read_ptx_sreg_tid_x();
    int r = __nvvm_read_ptx_sreg_tid_y();
    const unsigned *row = quote + r * words;
    // The block starts inside a string when the row's earlier blocks hold an odd number of quotes.
    unsigned before = 0;
    for (int v = 0; v < w; ++v) before += __builtin_popcount(row[v]);
    // Prefix XOR: bit i is the parity of the quotes up to i, so a string region runs from its
    // opening quote up to, not including, its closing quote.
    unsigned x = row[w] ^ (before & 1);
    x ^= x << 1;
    x ^= x << 2;
    x ^= x << 4;
    x ^= x << 8;
    x ^= x << 16;
    int at = r * words + w;
    in_string[at] = x;
    structural[at] = op[at] & ~x;
}
