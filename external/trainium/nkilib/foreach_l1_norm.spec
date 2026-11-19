// nkilib experimental foreach l1_norm, from foreach_norm_torch.py: the whole input reduced to
// one value.
dim N;
dim ONE;
array data[N];
array out[ONE, ONE];

out[a, b] = sum(k in 0..N, abs(data[k]));
