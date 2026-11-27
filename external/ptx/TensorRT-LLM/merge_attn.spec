// TensorRT-LLM mergeAttnWithSoftmaxKernel<T, D, IsLse = false> (mlaChunkedPrefill.cu:174) on block
// (x, b, HD): tokens [T0, T1) of batch b, head HD. Stats are (max, sum) pairs; in place as the
// host calls it (mlaPreprocessOp.cpp:102: pre_attn = merged_attn, pre_stats = merged_stats), so
// ma/ms hold the previous chunk on entry. OP 1 merges the chunk ca/cs in with the max-shifted
// softmax weights; OP 2 copies it; other blocks write nothing.
dim T; dim H; dim D; dim TWO; dim HD; dim T0; dim T1; dim OP;
array ma[T, H, D]; array ms[T, H, TWO]; array ca[T, H, D]; array cs[T, H, TWO];
ma[t, h, d] = where(h == HD, where(t >= T0, where(t < T1,
    where(OP == 1, let(m, max(ms[t, h, 0], cs[t, h, 0]),
        let(wp, ms[t, h, 1] * exp(ms[t, h, 0] - m), let(wc, cs[t, h, 1] * exp(cs[t, h, 0] - m),
            (ma[t, h, d] * wp + ca[t, h, d] * wc) / (wp + wc)))),
      where(OP == 2, ca[t, h, d], unwritten)),
    unwritten), unwritten), unwritten);
ms[t, h, k] = where(h == HD, where(t >= T0, where(t < T1,
    where(OP == 1, let(m, max(ms[t, h, 0], cs[t, h, 0]),
        where(k == 0, m, ms[t, h, 1] * exp(ms[t, h, 0] - m) + cs[t, h, 1] * exp(cs[t, h, 0] - m))),
      where(OP == 2, cs[t, h, k], unwritten)),
    unwritten), unwritten), unwritten);
