// TensorRT-LLM transpose4dBatchMajorKVCache<T, T, KVBlockArray> (unfusedAttentionKernels.cu:1645)
// on block (x, BI, HD): source tokens T0 + k of k/v [B, H, L, D] (head HD) inside the attention
// window land in the paged cache pool [NB, H, TPB, D] at block-slot KX_k = block * TPB + slot for
// K and VX_k for V (the case resolves the token's cyclic index and the block tables; a token not
// written has KX_k = VX_k = NB * TPB, matching no slot); nothing else is written.
dim B; dim H; dim L; dim D; dim NB; dim TPB; dim HD; dim T0; dim BI;
dim KX0; dim VX0; dim KX1; dim VX1; dim KX2; dim VX2; dim KX3; dim VX3; dim KX4; dim VX4; dim KX5; dim VX5; dim KX6; dim VX6; dim KX7; dim VX7; dim KX8; dim VX8; dim KX9; dim VX9; dim KX10; dim VX10; dim KX11; dim VX11; dim KX12; dim VX12; dim KX13; dim VX13; dim KX14; dim VX14; dim KX15; dim VX15;
array k[B, H, L, D]; array v[B, H, L, D];
array pool[NB, H, TPB, D];
pool[n, h, s, d] = where(h == HD, where(n * TPB + s == KX0, k[BI, h, T0 + 0, d], where(n * TPB + s == VX0, v[BI, h, T0 + 0, d],
    where(n * TPB + s == KX1, k[BI, h, T0 + 1, d], where(n * TPB + s == VX1, v[BI, h, T0 + 1, d],
    where(n * TPB + s == KX2, k[BI, h, T0 + 2, d], where(n * TPB + s == VX2, v[BI, h, T0 + 2, d],
    where(n * TPB + s == KX3, k[BI, h, T0 + 3, d], where(n * TPB + s == VX3, v[BI, h, T0 + 3, d],
    where(n * TPB + s == KX4, k[BI, h, T0 + 4, d], where(n * TPB + s == VX4, v[BI, h, T0 + 4, d],
    where(n * TPB + s == KX5, k[BI, h, T0 + 5, d], where(n * TPB + s == VX5, v[BI, h, T0 + 5, d],
    where(n * TPB + s == KX6, k[BI, h, T0 + 6, d], where(n * TPB + s == VX6, v[BI, h, T0 + 6, d],
    where(n * TPB + s == KX7, k[BI, h, T0 + 7, d], where(n * TPB + s == VX7, v[BI, h, T0 + 7, d],
    where(n * TPB + s == KX8, k[BI, h, T0 + 8, d], where(n * TPB + s == VX8, v[BI, h, T0 + 8, d],
    where(n * TPB + s == KX9, k[BI, h, T0 + 9, d], where(n * TPB + s == VX9, v[BI, h, T0 + 9, d],
    where(n * TPB + s == KX10, k[BI, h, T0 + 10, d], where(n * TPB + s == VX10, v[BI, h, T0 + 10, d],
    where(n * TPB + s == KX11, k[BI, h, T0 + 11, d], where(n * TPB + s == VX11, v[BI, h, T0 + 11, d],
    where(n * TPB + s == KX12, k[BI, h, T0 + 12, d], where(n * TPB + s == VX12, v[BI, h, T0 + 12, d],
    where(n * TPB + s == KX13, k[BI, h, T0 + 13, d], where(n * TPB + s == VX13, v[BI, h, T0 + 13, d],
    where(n * TPB + s == KX14, k[BI, h, T0 + 14, d], where(n * TPB + s == VX14, v[BI, h, T0 + 14, d],
    where(n * TPB + s == KX15, k[BI, h, T0 + 15, d], where(n * TPB + s == VX15, v[BI, h, T0 + 15, d],
    unwritten)))))))))))))))))))))))))))))))), unwritten);
