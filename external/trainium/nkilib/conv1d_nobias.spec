// nkilib experimental conv1d, from conv1d_torch.py (nn.Conv1d, asymmetric padding by F.pad):
// out[b, co, l] = sum over input channels and taps of filters[k, ci, co] times the
// zero-padded input at l * S + k * DL - PL. Filters are [K, C_in, C_out].
dim B;
dim CI;
dim CO;
dim L;
dim LO;
dim K;
dim S;
dim DL;
dim PL;
array x_in[B, CI, L] padded;
array filters[K, CI, CO];

array y_out[B, CO, LO];

y_out[b, co, l] = sum(ci in 0..CI, sum(k in 0..K,
    filters[k, ci, co] * x_in[b, ci, l * S + k * DL - PL]));
