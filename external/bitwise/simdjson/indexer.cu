// The offsets of simdjson's structural indexer, one thread per 32-character block: each block
// writes its structural positions to the tape after those of the row's earlier blocks, so its
// offset is the number of structurals they hold; the row's last block also writes the total.
// start[r, w] is stage 1's structural-start mask.
#define __global__ __attribute__((global))

extern "C" __global__ void indexer(const unsigned *start, unsigned *offset, unsigned *total,
                                   int words) {
    int w = __nvvm_read_ptx_sreg_tid_x();
    int r = __nvvm_read_ptx_sreg_tid_y();
    const unsigned *row = start + r * words;
    unsigned before = 0;
    for (int v = 0; v < w; ++v) before += __builtin_popcount(row[v]);
    offset[r * words + w] = before;
    if (w == words - 1) total[r] = before + __builtin_popcount(row[w]);
}
