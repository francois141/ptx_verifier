// Softmax along each row, max-subtracted, as softmax_isa computes it over a [P, F] tile.
dim P;
dim F;
array x[P, F];
array kernel_out[P, F];

kernel_out[p, f] = exp(x[p, f] - max(g in 0..F, x[p, g]))
      / sum(g in 0..F, exp(x[p, g] - max(h in 0..F, x[p, h])));
