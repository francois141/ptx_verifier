// TensorRT batchedTranspose2DKernel: dst[o, c, r] = src[o, r, c].
dim O; dim R; dim C;
array src[O, R, C];
array dst[O, C, R];
dst[o, c, r] = src[o, r, c];
