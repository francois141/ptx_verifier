// TensorRT-LLM mergeAttnWithSoftmaxKernel (mlaChunkedPrefill.cu:174) with separate previous-chunk
// buffers pa/ps (not the in-place call of mlaPreprocessOp.cpp:102): merge_attn.spec with the
// previous chunk read from pa/ps and the result written to ma/ms.
dim T; dim H; dim D; dim TWO; dim HD; dim T0; dim T1; dim OP;
array ma[T, H, D]; array ms[T, H, TWO]; array pa[T, H, D]; array ps[T, H, TWO]; array ca[T, H, D]; array cs[T, H, TWO];
ma[t, h, d] = where(h == HD, where(t >= T0, where(t < T1,
    where(OP == 1, let(m, max(ps[t, h, 0], cs[t, h, 0]),
        let(wp, ps[t, h, 1] * exp(ps[t, h, 0] - m), let(wc, cs[t, h, 1] * exp(cs[t, h, 0] - m),
            (pa[t, h, d] * wp + ca[t, h, d] * wc) / (wp + wc)))),
      where(OP == 2, ca[t, h, d], unwritten)),
    unwritten), unwritten), unwritten);
ms[t, h, k] = where(h == HD, where(t >= T0, where(t < T1,
    where(OP == 1, let(m, max(ps[t, h, 0], cs[t, h, 0]),
        where(k == 0, m, ps[t, h, 1] * exp(ps[t, h, 0] - m) + cs[t, h, 1] * exp(cs[t, h, 0] - m))),
      where(OP == 2, cs[t, h, k], unwritten)),
    unwritten), unwritten), unwritten);
