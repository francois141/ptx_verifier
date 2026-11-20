// nkilib's attention_tkg without fused RoPE, from attention_tkg_torch.py's
// _attention_tkg_fwd_ref at one batch and head, every mask entry set: the KV cache's last SA
// slots replaced by the active keys and values, the scores q . k over the cache softmaxed
// and applied to V. The cache is split into its KP = SP - SA prior slots and the SA active
// ones, each score written once per part.
dim D;
dim SP;
dim SA;
dim KP;
dim ONE;
array q[D, SA];
array k_active[D, SA];
array v_active[ONE, ONE, SA, D];
array k_prior[ONE, ONE, D, SP];
array v_prior[ONE, ONE, SP, D];
array out[ONE, ONE, D, SA];

out[b, h, d, s] =
    let(m, max(max(j in 0..KP, sum(e in 0..D, k_prior[0, 0, e, j] * q[e, s])),
               max(j in 0..SA, sum(e in 0..D, k_active[e, j] * q[e, s]))),
    (sum(j in 0..KP, exp(sum(e in 0..D, k_prior[0, 0, e, j] * q[e, s]) - m) * v_prior[0, 0, j, d])
     + sum(j in 0..SA, exp(sum(e in 0..D, k_active[e, j] * q[e, s]) - m) * v_active[0, 0, j, d]))
    / (sum(j in 0..KP, exp(sum(e in 0..D, k_prior[0, 0, e, j] * q[e, s]) - m))
       + sum(j in 0..SA, exp(sum(e in 0..D, k_active[e, j] * q[e, s]) - m))));
