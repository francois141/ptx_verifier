// FlashInfer AppendPagedKVCacheDecodeKernel / AppendPagedKVCacheKernel (page.cuh:383, :419),
// HND pages [NP, H, PS, D]: the analyzed block copies its token I's key / value heads into
// entry ENTRY of page PAGE (decode: the last page of the request and entry last_page_len - 1;
// append: page indices[indptr[b] + pos / PS], entry pos % PS); nothing else is written.
// key / value are [NT, HS, D], the first H of HS heads being the kv heads.
dim NP; dim H; dim PS; dim D; dim NT; dim HS; dim I; dim PAGE; dim ENTRY;
array key[NT, HS, D];
array value[NT, HS, D];
array k_data[NP, H, PS, D];
array v_data[NP, H, PS, D];
k_data[p, h, e, d] = where(p != PAGE, unwritten, where(e != ENTRY, unwritten, key[I, h, d]));
v_data[p, h, e, d] = where(p != PAGE, unwritten, where(e != ENTRY, unwritten, value[I, h, d]));
