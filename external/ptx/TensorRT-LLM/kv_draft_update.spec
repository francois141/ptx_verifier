// TensorRT-LLM updateKVCacheDraftTokenLocationBatchedKernel<KVLinearBuffer> (speculativeDecoding/
// kvCacheUpdateKernels.cu:37) on block (sequence, head HI, layer LI): the sequence's CNT (<= 4)
// accepted draft tokens move to the positions after ST = pastLen[SLOT] - rewind in its K and V rows:
// cache[LI, SLOT, kv, HI, ST + j, :] = old cache[..., Pj, :] with Pj = ST + packedIndices[OFF + j].
// (Positions as dims: `volta solve` gives a spec no index-array integers.)
dim NL; dim S; dim TWO; dim H; dim ML; dim D; dim LI; dim SLOT; dim HI; dim ST; dim CNT; dim P0; dim P1; dim P2; dim P3;
array cache[NL, S, TWO, H, ML, D];
cache[l, s, kv, h, t, c] = where(l == LI, where(s == SLOT, where(h == HI, where(t >= ST, where(t < ST + CNT,
    where(t == ST, cache[l, s, kv, h, P0, c], where(t == ST + 1, cache[l, s, kv, h, P1, c],
    where(t == ST + 2, cache[l, s, kv, h, P2, c], cache[l, s, kv, h, P3, c]))),
    unwritten), unwritten), unwritten), unwritten), unwritten);
