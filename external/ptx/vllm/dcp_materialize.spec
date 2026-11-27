// vLLM's materialize_kv_gather_kernel (csrc/attention/dcp_utils/dcp_direct_kv_gather.cu:72): elements [E0, E1) of the gathered rows, copied from slot S of the symmetric buffer.
dim TWO; dim MT; dim R; dim D; dim S; dim E0; dim E1;
array received_kv[TWO, MT, D];
array gathered_kv[R, D];
gathered_kv[r, c] = where(r * D + c < E0, unwritten, where(r * D + c < E1, received_kv[S, r, c], unwritten));
