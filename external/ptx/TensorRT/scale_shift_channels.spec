// TensorRT groupNorm's scaleShiftChannelsInplace: x[b, c, i] = gamma[c] x[b, c, i] + beta[c].
dim B; dim C; dim L;
array inOut[B, C, L];
array gamma[C];
array beta[C];
inOut[b, c, i] = gamma[c] * inOut[b, c, i] + beta[c];
