// TensorRT-LLM loadPagedKVCacheForMLAKernel<T, T> (mlaKernels.cu:1223) on block (x, b): local
// tokens 8x .. 8x + 7 of batch b (global tokens G0 + k) are gathered from the paged MLA cache,
// block PB_k slot SL_k of the primary (PL_k = 0) or secondary pool [NB, TPB, HS] (HS = 512 + 64),
// into compressed_kv [T, 512] (the latent) and k_pe [T, 64] (the rope part), when the token
// is below the batch's cached length (V_k = 1); nothing else is written.
dim T; dim NB; dim TPB; dim HS; dim LORA; dim ROPE; dim G0;
dim V0; dim PB0; dim SL0; dim PL0; dim V1; dim PB1; dim SL1; dim PL1; dim V2; dim PB2; dim SL2; dim PL2; dim V3; dim PB3; dim SL3; dim PL3; dim V4; dim PB4; dim SL4; dim PL4; dim V5; dim PB5; dim SL5; dim PL5; dim V6; dim PB6; dim SL6; dim PL6; dim V7; dim PB7; dim SL7; dim PL7;
array pool[NB, TPB, HS]; array pool2[NB, TPB, HS];
array ckv[T, LORA]; array kpe[T, ROPE];
ckv[t, d] = where(t == G0 + 0, where(V0 == 1, where(PL0 == 0, pool[PB0, SL0, d], pool2[PB0, SL0, d]), unwritten),
    where(t == G0 + 1, where(V1 == 1, where(PL1 == 0, pool[PB1, SL1, d], pool2[PB1, SL1, d]), unwritten),
    where(t == G0 + 2, where(V2 == 1, where(PL2 == 0, pool[PB2, SL2, d], pool2[PB2, SL2, d]), unwritten),
    where(t == G0 + 3, where(V3 == 1, where(PL3 == 0, pool[PB3, SL3, d], pool2[PB3, SL3, d]), unwritten),
    where(t == G0 + 4, where(V4 == 1, where(PL4 == 0, pool[PB4, SL4, d], pool2[PB4, SL4, d]), unwritten),
    where(t == G0 + 5, where(V5 == 1, where(PL5 == 0, pool[PB5, SL5, d], pool2[PB5, SL5, d]), unwritten),
    where(t == G0 + 6, where(V6 == 1, where(PL6 == 0, pool[PB6, SL6, d], pool2[PB6, SL6, d]), unwritten),
    where(t == G0 + 7, where(V7 == 1, where(PL7 == 0, pool[PB7, SL7, d], pool2[PB7, SL7, d]), unwritten),
    unwritten))))))));
kpe[t, d] = where(t == G0 + 0, where(V0 == 1, where(PL0 == 0, pool[PB0, SL0, LORA + d], pool2[PB0, SL0, LORA + d]), unwritten),
    where(t == G0 + 1, where(V1 == 1, where(PL1 == 0, pool[PB1, SL1, LORA + d], pool2[PB1, SL1, LORA + d]), unwritten),
    where(t == G0 + 2, where(V2 == 1, where(PL2 == 0, pool[PB2, SL2, LORA + d], pool2[PB2, SL2, LORA + d]), unwritten),
    where(t == G0 + 3, where(V3 == 1, where(PL3 == 0, pool[PB3, SL3, LORA + d], pool2[PB3, SL3, LORA + d]), unwritten),
    where(t == G0 + 4, where(V4 == 1, where(PL4 == 0, pool[PB4, SL4, LORA + d], pool2[PB4, SL4, LORA + d]), unwritten),
    where(t == G0 + 5, where(V5 == 1, where(PL5 == 0, pool[PB5, SL5, LORA + d], pool2[PB5, SL5, LORA + d]), unwritten),
    where(t == G0 + 6, where(V6 == 1, where(PL6 == 0, pool[PB6, SL6, LORA + d], pool2[PB6, SL6, LORA + d]), unwritten),
    where(t == G0 + 7, where(V7 == 1, where(PL7 == 0, pool[PB7, SL7, LORA + d], pool2[PB7, SL7, LORA + d]), unwritten),
    unwritten))))))));
