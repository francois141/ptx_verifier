// im2col of one image with a stride-1, unpadded window: the column of output pixel (ho, wo) holds
// the window's pixels (ho + y, wo + x), all channels of each.
dim H;
dim W;
dim C;
dim Ho;
dim Wo;
dim Y;
dim X;
array image[H, W, C];
array columns[Ho, Wo, Y, X, C];

columns[ho, wo, y, x, c] = image[ho + y, wo + x, c];
