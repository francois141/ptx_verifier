// nkilib experimental foreach linf_norm, from foreach_norm_torch.py: the whole input reduced to
// one value. The kernel's accumulator starts at 0, so its result is max(0, ...): equal to the
// reference since every |x| >= 0, written that way because Volta treats abs as opaque.
dim N;
dim ONE;
array data[N];
array out[ONE, ONE];

out[a, b] = max(0, max(k in 0..N, abs(data[k])));
