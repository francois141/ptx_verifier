// nkilib experimental depthwise_conv1d_implicit_gemm, as its docs define it: per channel,
// out[n, c, 0, q] = sum over taps s of filter_ref[c, 0, 0, s] * img[n, c, 0, q * SW + s - PL],
// the input zero-padded by PL on the left (and PR on the right, which sets Q only).
dim N;
dim C;
dim W;
dim S;
dim Q;
dim SW;
dim PL;
dim ONE;
array img_ref[N, C, ONE, W] padded;
array filter_ref[C, ONE, ONE, S];
array output[N, C, ONE, Q];

output[n, c, o, q] = sum(s in 0..S, filter_ref[c, 0, 0, s] * img_ref[n, c, 0, q * SW + s - PL]);
