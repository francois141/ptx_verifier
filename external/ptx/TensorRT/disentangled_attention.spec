// TensorRT DisentangledAttention (DeBERTa v2): result = (c2c + c2p + p2c) * factor, with the
// relative position j - k + span of the preserved region |j - k| <= span / 2 (no log bucket):
// result[i, j, k] = (data0[i, j, k] + data1[i, j, j - k + span] + data2[i, k, j - k + span]) / 8.
dim H; dim S; dim P; dim SPAN;
array data0[H, S, S];
array data1[H, S, P];
array data2[H, S, P];
array result[H, S, S];
result[i, j, k] = (data0[i, j, k] + data1[i, j, j + SPAN - k] + data2[i, k, j + SPAN - k]) * 0.125;
