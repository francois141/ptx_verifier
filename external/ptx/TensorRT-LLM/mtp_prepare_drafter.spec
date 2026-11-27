// TensorRT-LLM mtpPrepareDrafterInputsKernel (speculativeDecoding/mtpKernels.cu:67) on block BI (one
// request). Its tokens start at IO in inputIds/hiddenStates and at RO in the returns. A context
// request (CTX) of L tokens returns inputIds[IO + 1 ..] then acceptedTokens[BI, 0] and its L hidden
// rows; a generation request returns past tokens [1, M) of its past row PR then acceptedTokens[BI,
// NA - 1], and its M past hidden rows.
dim N; dim NR; dim B; dim M; dim M1; dim HS; dim R; dim BI; dim IO; dim RO; dim L; dim CTX; dim PR; dim NA;
array input_ids[N]; array accepted[B, M1]; array past_tokens[R, M]; array hidden[N, HS]; array past_hidden[R, M, HS];
array ret_ids[NR]; array ret_hidden[NR, HS];
ret_ids[i] = where(CTX == 1,
    where(i >= RO, where(i < RO + L - 1, input_ids[IO + i - RO + 1], where(i == RO + L - 1, accepted[BI, 0],
        unwritten)), unwritten),
    where(i >= RO, where(i < RO + M - 1, past_tokens[PR, i - RO + 1], where(i == RO + M - 1, accepted[BI, NA - 1],
        unwritten)), unwritten));
ret_hidden[i, h] = where(CTX == 1,
    where(i >= RO, where(i < RO + L, hidden[IO + i - RO, h], unwritten), unwritten),
    where(i >= RO, where(i < RO + M, past_hidden[PR, i - RO, h], unwritten), unwritten));
