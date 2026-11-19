// nkilib experimental foreach lerp, from foreach_elementwise_torch.py; the scalar operand is the
// constant 3 the call fills its [P, 1] broadcast tensor with.
dim N;
array data[N];
array end[N];
array out_hbm[N];

out_hbm[i] = data[i] + 3 * (end[i] - data[i]);
