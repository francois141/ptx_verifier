// TensorRT-LLM state_passing_kernel (selectiveScan/statepassing.h:48) on block (x = head HI, sequence
// BI) when N P = 512 (one head per block): the sequence's chunks [CS, CS + C) carry the state
// s_0 = 0, s_{k+1} = exp(dA[CS + k, h, Q - 1]) s_k + St[CS + k, h, e]; chunk k's entering state goes
// to Os[CS + k], the final one to Fs[SLOT].
dim CT; dim H; dim E; dim Q; dim QM1; dim NS; dim CS; dim C; dim HI; dim SLOT;
array St[CT, H, E]; array dA[CT, H, Q];
array Os[CT, H, E]; array Fs[NS, H, E];
Os[k, h, e] = where(h == HI, where(k >= CS, where(k < CS + C,
    sum(j in CS..k, St[j, h, e] * exp(sum(m in j + 1..k, dA[m, h, QM1]))), unwritten), unwritten), unwritten);
Fs[n, h, e] = where(n == SLOT, where(h == HI,
    sum(j in CS..CS + C, St[j, h, e] * exp(sum(m in j + 1..CS + C, dA[m, h, QM1]))), unwritten), unwritten);
