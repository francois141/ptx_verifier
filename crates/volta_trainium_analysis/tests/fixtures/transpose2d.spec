// The NKI samples' transpose2d tutorial, transcribing its drivers' reference
// `transpose(a.reshape(P, X, Y), (0, 2, 1)).reshape(P, X * Y)` over its kernel's names:
// each array is its kernel's `[P, X * Y]` viewed row-major as three dimensions.
dim P;
dim X;
dim Y;
array in_tensor[P, X, Y];
array out_tensor[P, Y, X];

out_tensor[p, j, i] = in_tensor[p, i, j];
