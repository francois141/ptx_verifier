// nkilib experimental foreach div_tensor, from foreach_elementwise_torch.py.
dim N;
array data1[N];
array data2[N];
array out_hbm[N];

out_hbm[i] = data1[i] / data2[i];
