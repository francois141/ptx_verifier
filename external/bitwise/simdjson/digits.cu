// simdjson's parse_eight_digits_unrolled on 32-bit words, one thread per eight-digit field:
// each word holds four ASCII digits, first digit in its low byte. SWAR multiplies combine
// adjacent digits, then adjacent pairs, into the word's four-digit value, and the field's value
// is its first word's times 10000 plus its second's.
#define __global__ __attribute__((global))

static __attribute__((device)) unsigned four_digits(unsigned val) {
    val = (val & 0x0F0F0F0Fu) * 2561 >> 8;
    val = (val & 0x00FF00FFu) * 6553601 >> 16;
    return val;
}

extern "C" __global__ void digits(const unsigned *chars, unsigned *value) {
    int f = __nvvm_read_ptx_sreg_tid_x();
    value[f] = four_digits(chars[2 * f]) * 10000 + four_digits(chars[2 * f + 1]);
}
