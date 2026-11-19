// nkilib experimental foreach addcdiv, from foreach_elementwise_torch.py; the scalar operand is the
// constant 3 the call fills its [P, 1] broadcast tensor with.
dim N;
array data[N];
array data1[N];
array data2[N];
array out_hbm[N];

out_hbm[i] = data[i] + 3 * (data1[i] / data2[i]);
