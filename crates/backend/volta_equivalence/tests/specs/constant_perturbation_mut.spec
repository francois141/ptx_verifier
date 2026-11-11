// x * the f32 nearest 0.5000001, i.e. (2^23 + 2) / 2^24.
dim N;
array x[N];
array out[N];

out[i] = x[i] * 0.50000011920928955078125;
