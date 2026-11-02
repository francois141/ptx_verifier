// Compiled with -cl-fast-relaxed-math in addition to the copy fixture's flags. Each work-item
// writes one result per BinOp and TernaryOp to its own 64-word row of `out`; the f32 ops
// reinterpret the input words as floats, and `base` is `b`'s low word, an SGPR.
__kernel void bit_ops(__global const unsigned *a, __global const unsigned *b,
                      __global unsigned *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    unsigned x = a[i], y = b[i], z = a[i + 64];
    float u = as_float(x), v = as_float(y), w = as_float(z);
    unsigned base = (unsigned)(ulong)b;
    // The signed, 24-bit and three-input logic ops take concrete words: `t` mixes `i` with
    // `base` so that Clang cannot bound it, and `p`, `q` and `r` are its 24-bit sign extensions.
    unsigned t = ((i << 20) | i) ^ base;
    int p = ((int)t << 8) >> 8, q = ((int)(t ^ 0x5a5a5a) << 8) >> 8;
    int r = ((int)(t + 0x123456) << 8) >> 8, s = (int)(t ^ 0xf0f0f0f0);
    __global unsigned *row = out + 64 * i;
    row[0] = x & y;
    row[1] = x | y;
    row[2] = x ^ y;
    row[3] = x << y;
    row[4] = x >> y;
    row[5] = (x + y) << 3;
    row[6] = (x >> 5) & 0xff;
    row[7] = (x << 4) | y;
    row[8] = x | z | (y & 0xf0);
    row[9] = as_uint(u + v);
    row[10] = as_uint(u - v);
    row[11] = as_uint(u * v);
    row[12] = as_uint(fmin(u, v));
    row[13] = as_uint(fmax(u, v));
    row[14] = x + z;
    row[15] = z - y;
    row[16] = x - base;
    row[17] = (z << 3) + y;
    row[18] = y + z + (x >> 2);
    row[19] = (x & z) | y;
    row[21] = as_uint(u - as_float(base));
    row[22] = ~(y ^ z);
    row[23] = x < y ? x : y;
    row[24] = x > y ? x : y;
    row[25] = (x ^ z) + y;
    row[26] = (x & y) | (~x & z);
    row[27] = __builtin_amdgcn_alignbit(x, y, z);
    row[28] = __builtin_amdgcn_alignbyte(x, y, z);
    row[29] = (x > y ? x : y) - (x < y ? x : y) + z;
    unsigned h = y >> 1, xz = x < z ? x : z, zh = z > h ? z : h;
    row[30] = xz < h ? xz : h;
    row[31] = zh > x ? zh : x;
    unsigned ulo = x > 3 ? x : 3;
    row[32] = ulo < 60 ? ulo : 60;
    row[33] = as_uint(fmin(fmin(u, w), v));
    row[34] = as_uint(fmax(fmax(u, w), v));
    row[35] = as_uint(__builtin_amdgcn_fmed3f(u, v, w));
    row[36] = as_uint(__builtin_elementwise_minimum(__builtin_elementwise_minimum(v, w), u));
    row[37] = as_uint(__builtin_elementwise_maximum(__builtin_elementwise_maximum(v, w), u));
    // The wait model counts no stores, so none may be issued before the loads complete.
    __builtin_amdgcn_sched_barrier(0);
    row[20] = (i ^ (i >> 1)) & (i >> 2);
    row[38] = s >> (i & 7);
    row[39] = p < q ? p : q;
    row[40] = p > q ? p : q;
    row[41] = (t & 0xffffff) * ((t >> 3) & 0xffffff);
    row[42] = ((ulong)(t & 0xffffff) * (t >> 8)) >> 32;
    row[43] = p * q;
    row[44] = ((long)p * r) >> 32;
    row[45] = (s << 8) >> 20;
    row[46] = (t & 0xffffff) * (t >> 8) + s;
    row[47] = q * r + s;
    int pr = p < r ? p : r, qs = q > s ? q : s;
    row[48] = pr < s ? pr : s;
    row[49] = qs > r ? qs : r;
    int plo = p > 2 ? p : 2;
    row[50] = plo < 9 ? plo : 9;
}
