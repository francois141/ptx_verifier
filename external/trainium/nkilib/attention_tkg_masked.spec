// attention_tkg.spec with the mask applied: the softmax runs over only the NV prior slots
// VALID lists (those whose mask entry is set; the reference's -inf scores contribute nothing)
// and the SA active ones, whose entries the calls set.
dim D;
dim SP;
dim SA;
dim NV;
dim ONE;
array q[D, SA];
array k_active[D, SA];
array v_active[ONE, ONE, SA, D];
array k_prior[ONE, ONE, D, SP];
array v_prior[ONE, ONE, SP, D];
array VALID[NV] index;
array out[ONE, ONE, D, SA];

out[b, h, d, s] =
    let(m, max(max(n in 0..NV, sum(e in 0..D, k_prior[0, 0, e, VALID[n]] * q[e, s])),
               max(j in 0..SA, sum(e in 0..D, k_active[e, j] * q[e, s]))),
    (sum(n in 0..NV, exp(sum(e in 0..D, k_prior[0, 0, e, VALID[n]] * q[e, s]) - m)
                     * v_prior[0, 0, VALID[n], d])
     + sum(j in 0..SA, exp(sum(e in 0..D, k_active[e, j] * q[e, s]) - m) * v_active[0, 0, j, d]))
    / (sum(n in 0..NV, exp(sum(e in 0..D, k_prior[0, 0, e, VALID[n]] * q[e, s]) - m))
       + sum(j in 0..SA, exp(sum(e in 0..D, k_active[e, j] * q[e, s]) - m))));
