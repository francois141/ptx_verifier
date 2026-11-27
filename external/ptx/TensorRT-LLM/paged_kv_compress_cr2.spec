// TensorRT-LLM pagedKvCompressKernel<HD, 4, 4, CR 2, 1 warp> (compressorKernels.cu:304) on block (batch,
// 0, 0), next_n <= 2. Phase 1 stores each new token u (NW of them) into the paged state: kv at page
// WKu row WOu, score (+ ape[token % 2]) at page WQu row WOu. With NC = 1 the chunk's two positions r
// (new: kv_score row Tr and ape row r; old: pages Kr / Qr row Or) reduce by softmax over the score:
// out[OUT, d] = sum_r K_r exp(S_r - m) / sum_r exp(S_r - m), m = max_r S_r.
dim NT; dim SD2; dim SD; dim NP; dim PS; dim NO; dim CR; dim NW; dim NC; dim OUT;
dim WT0; dim WK0; dim WQ0; dim WO0; dim WA0; dim WT1; dim WK1; dim WQ1; dim WO1; dim WA1;
dim N0; dim T0; dim K0; dim Q0; dim O0; dim N1; dim T1; dim K1; dim Q1; dim O1;
array kvs[NT, SD2]; array ape[CR, SD];
array pkv[NP, PS, SD]; array psc[NP, PS, SD]; array out[NO, SD];
pkv[p, o, d] = where(NW > 0, where(p == WK0, where(o == WO0, kvs[WT0, d],
        where(NW > 1, where(p == WK1, where(o == WO1, kvs[WT1, d], unwritten), unwritten), unwritten)),
    where(NW > 1, where(p == WK1, where(o == WO1, kvs[WT1, d], unwritten), unwritten), unwritten)), unwritten);
psc[p, o, d] = where(NW > 0, where(p == WQ0, where(o == WO0, kvs[WT0, SD + d] + ape[WA0, d],
        where(NW > 1, where(p == WQ1, where(o == WO1, kvs[WT1, SD + d] + ape[WA1, d], unwritten), unwritten), unwritten)),
    where(NW > 1, where(p == WQ1, where(o == WO1, kvs[WT1, SD + d] + ape[WA1, d], unwritten), unwritten), unwritten)),
    unwritten);
out[i, d] = where(NC == 1, where(i == OUT,
    let(k0, where(N0 == 1, kvs[T0, d], pkv[K0, O0, d]),
    let(s0, where(N0 == 1, kvs[T0, SD + d] + ape[0, d], psc[Q0, O0, d]),
    let(k1, where(N1 == 1, kvs[T1, d], pkv[K1, O1, d]),
    let(s1, where(N1 == 1, kvs[T1, SD + d] + ape[1, d], psc[Q1, O1, d]),
    let(m, max(s0, s1),
        (k0 * exp(s0 - m) + k1 * exp(s1 - m)) / (exp(s0 - m) + exp(s1 - m))))))),
    unwritten), unwritten);
