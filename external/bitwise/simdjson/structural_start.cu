// simdjson's structural starts on 32-character blocks, one thread per block: where each
// structural character, string and scalar (number, true, false, null) begins, outside strings.
// quote, op and ws mark unescaped quotes, the characters { } [ ] : , and whitespace.
#define __global__ __attribute__((global))

extern "C" __global__ void structural_start(const unsigned *quote, const unsigned *op,
                                            const unsigned *ws, unsigned *start, int words) {
    int w = __nvvm_read_ptx_sreg_tid_x();
    int r = __nvvm_read_ptx_sreg_tid_y();
    int at = r * words + w;
    const unsigned *row = quote + r * words;
    unsigned before = 0;
    for (int v = 0; v < w; ++v) before += __builtin_popcount(row[v]);
    unsigned in_string = row[w] ^ (before & 1);
    in_string ^= in_string << 1;
    in_string ^= in_string << 2;
    in_string ^= in_string << 4;
    in_string ^= in_string << 8;
    in_string ^= in_string << 16;
    // A string's characters after its opening quote, its closing quote included.
    unsigned string_tail = in_string ^ row[w];
    unsigned scalar = ~(op[at] | ws[at]);
    // A scalar character that follows another one, a quote not counting, continues a scalar;
    // the previous block's last character decides for bit 0.
    unsigned prev_scalar = 0;
    if (w > 0) prev_scalar = (~(op[at - 1] | ws[at - 1]) & ~row[w - 1]) >> 31;
    unsigned follows_scalar = ((scalar & ~row[w]) << 1) | prev_scalar;
    unsigned potential_start = op[at] | (scalar & ~follows_scalar);
    start[at] = potential_start & ~string_tail;
}
