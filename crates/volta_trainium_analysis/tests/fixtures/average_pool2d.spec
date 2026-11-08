// The NKI samples' average_pool2d tutorial, transcribing its reference
// `nanmean(in_tensor.reshape(C, H // S, S, W // S, S), axis=(2, 4))` over its kernel's
// names, `S` the pool size and `HOUT`, `WOUT` the pooled extents: no input is NaN, so
// `nanmean` is the mean of each `S x S` window.
dim C;
dim H;
dim W;
dim S;
dim HOUT;
dim WOUT;
array in_tensor[C, H, W];
array out_tensor[C, HOUT, WOUT];

out_tensor[c, i, j] = sum(a in 0..S, sum(b in 0..S, in_tensor[c, i * S + a, j * S + b])) / (S * S);
