// Average pooling of an NHWC tensor: each output is the sum of its KH x KW window over the
// window size. Windows step by SH and SW, their taps lie DH and DW apart, and PH rows and PW
// columns of zeros precede the input. A tap outside the input adds 0 and still counts.
dim N;
dim H;
dim W;
dim C;
dim HOUT;
dim WOUT;
dim KH;
dim KW;
dim SH;
dim SW;
dim DH;
dim DW;
dim PH;
dim PW;
array input[N, H, W, C] padded;
array output[N, HOUT, WOUT, C];

output[n, i, j, c] =
    sum(a in 0..KH, sum(b in 0..KW, input[n, i * SH + a * DH - PH, j * SW + b * DW - PW, c]))
    / (KH * KW);
