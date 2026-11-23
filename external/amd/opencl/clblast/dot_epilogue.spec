// The sum of the P partial dot products.
dim P; dim R;
array partial[P];
array result[R];
result[r] = sum(i in 0..P, partial[i]);
