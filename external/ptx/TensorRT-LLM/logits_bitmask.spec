// TensorRT-LLM (contiguous)LogitsBitmaskKernel (logitsBitmask.cu:67, :185) on block (x, CB): row CB
// of logits [B, V], positions [V0, V1). A position whose bitmask bit is 0 (read through d2t when
// given) becomes -inf (the empty max); the other positions of a packed vector holding a masked one
// are rewritten with their own value; a vector with no masked position is not written. The case
// splits [V0, V1) into segments [P_k, P_k+1) of one kind T_k: 0 unwritten, 1 masked, 2 rewritten.
dim B; dim V; dim CB; dim V0; dim V1;
dim P1; dim P2; dim P3; dim P4; dim P5; dim P6; dim P7; dim P8; dim P9; dim P10; dim P11; dim P12;
dim T0; dim T1; dim T2; dim T3; dim T4; dim T5; dim T6; dim T7; dim T8; dim T9; dim T10; dim T11; dim T12;
array logits[B, V];
logits[b, v] = where(b == CB, where(v >= V0, where(v < V1,
    where(v < P1, where(T0 == 1, max(z in 0..0, 0), where(T0 == 2, logits[b, v], unwritten)),
    where(v < P2, where(T1 == 1, max(z in 0..0, 0), where(T1 == 2, logits[b, v], unwritten)),
    where(v < P3, where(T2 == 1, max(z in 0..0, 0), where(T2 == 2, logits[b, v], unwritten)),
    where(v < P4, where(T3 == 1, max(z in 0..0, 0), where(T3 == 2, logits[b, v], unwritten)),
    where(v < P5, where(T4 == 1, max(z in 0..0, 0), where(T4 == 2, logits[b, v], unwritten)),
    where(v < P6, where(T5 == 1, max(z in 0..0, 0), where(T5 == 2, logits[b, v], unwritten)),
    where(v < P7, where(T6 == 1, max(z in 0..0, 0), where(T6 == 2, logits[b, v], unwritten)),
    where(v < P8, where(T7 == 1, max(z in 0..0, 0), where(T7 == 2, logits[b, v], unwritten)),
    where(v < P9, where(T8 == 1, max(z in 0..0, 0), where(T8 == 2, logits[b, v], unwritten)),
    where(v < P10, where(T9 == 1, max(z in 0..0, 0), where(T9 == 2, logits[b, v], unwritten)),
    where(v < P11, where(T10 == 1, max(z in 0..0, 0), where(T10 == 2, logits[b, v], unwritten)),
    where(v < P12, where(T11 == 1, max(z in 0..0, 0), where(T11 == 2, logits[b, v], unwritten)),
    where(T12 == 1, max(z in 0..0, 0), where(T12 == 2, logits[b, v], unwritten)))))))))))))), unwritten), unwritten), unwritten);
