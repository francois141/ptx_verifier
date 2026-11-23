// HipKittens' rotary embedding (kernels/cdna4/rotary): each 128-wide head viewed as [TWO, HALF],
// the pair (x[0, i], x[1, i]) rotated by angle i: o[j, i] = x[j, i] cos[i] + (2j - 1) x[1 - j, i]
// sin[i], the sign written 2 * (sum over k < j of 1) - 1 as a spec reads indices only in
// subscripts.
dim N;
dim TWO;
dim HALF;
array x[N, TWO, HALF];
array sin[N, HALF];
array cos[N, HALF];
array o[N, TWO, HALF];

o[n, j, i] = x[n, j, i] * cos[n, i] + (2 * sum(k in 0..j, 1) - 1) * x[n, 1 - j, i] * sin[n, i];
