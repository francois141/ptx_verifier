// TensorRT-LLM reverseRowsKernel (rotateRows.cu:34), one of rotateRowsLeft's three passes: block
// (x, y) swaps element BEGIN + i with END - 1 - i for i in [I0, I1) of rows Y0 and Y0 + GY (when
// below R) of data [R, S]; an odd range's middle element and everything else is not written.
dim R; dim S; dim BEGIN; dim END; dim I0; dim I1; dim Y0; dim GY;
array data[R, S];
data[r, c] = where(r == Y0,
    where(c >= BEGIN + I0, where(c < BEGIN + I1, data[r, END + BEGIN - 1 - c],
        where(c + I1 >= END, where(c + I0 < END, data[r, END + BEGIN - 1 - c], unwritten), unwritten)),
      unwritten),
    where(r == Y0 + GY,
    where(c >= BEGIN + I0, where(c < BEGIN + I1, data[r, END + BEGIN - 1 - c],
        where(c + I1 >= END, where(c + I0 < END, data[r, END + BEGIN - 1 - c], unwritten), unwritten)),
      unwritten), unwritten));
