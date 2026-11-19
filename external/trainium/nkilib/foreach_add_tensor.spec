// nkilib experimental foreach add_tensor, from foreach_elementwise_torch.py; the scalar operand is the
// constant 3 the call fills its [P, 1] broadcast tensor with.
dim N;
array data1[N];
array data2[N];
array out_hbm[N];

out_hbm[i] = data1[i] + 3 * data2[i];
