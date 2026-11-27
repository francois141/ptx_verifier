// TensorRT-LLM scatterKvSlotsKernel (scatterKvSlots.cu:31) on one block: entry e copies source
// token T_e's K and V rows (k, v [NTOK, H, D]) into pool slot X_e = page * TPP + slot of the paged
// pool [P, 2, H, TPP, D] (K at 0, V at 1), and again into a second slot when dst2 is given; the
// case lists each written slot j with its token T_j and the heads [HA_j, HB_j) the analyzed
// block covers (an unused j has X_j = P * TPP, which no slot equals).
dim P; dim TWO; dim H; dim TPP; dim D; dim NTOK;
dim X0; dim T0; dim HA0; dim HB0; dim X1; dim T1; dim HA1; dim HB1; dim X2; dim T2; dim HA2; dim HB2; dim X3; dim T3; dim HA3; dim HB3; dim X4; dim T4; dim HA4; dim HB4; dim X5; dim T5; dim HA5; dim HB5;
array k[NTOK, H, D]; array v[NTOK, H, D];
array pool[P, TWO, H, TPP, D];
pool[p, c, h, s, d] = where(p * TPP + s == X0, where(h >= HA0, where(h < HB0, where(c == 0, k[T0, h, d], v[T0, h, d]), unwritten), unwritten),
    where(p * TPP + s == X1, where(h >= HA1, where(h < HB1, where(c == 0, k[T1, h, d], v[T1, h, d]), unwritten), unwritten),
    where(p * TPP + s == X2, where(h >= HA2, where(h < HB2, where(c == 0, k[T2, h, d], v[T2, h, d]), unwritten), unwritten),
    where(p * TPP + s == X3, where(h >= HA3, where(h < HB3, where(c == 0, k[T3, h, d], v[T3, h, d]), unwritten), unwritten),
    where(p * TPP + s == X4, where(h >= HA4, where(h < HB4, where(c == 0, k[T4, h, d], v[T4, h, d]), unwritten), unwritten),
    where(p * TPP + s == X5, where(h >= HA5, where(h < HB5, where(c == 0, k[T5, h, d], v[T5, h, d]), unwritten), unwritten),
    unwritten))))));
