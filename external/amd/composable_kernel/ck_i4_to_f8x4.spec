// The OCP E4M3 codes i4_to_f8x4 is named for on the word 0x675c1e93: its nibbles 0, 4, 1 and 5
// (3, -4, -7 and 5 as signed int4), each divided by 16, as amd_assembly_i4_to_fp8x8 orders them.
dim N;
array b0[N];
array b1[N];
array b2[N];
array b3[N];

b0[i] = 36;
b1[i] = 168;
b2[i] = 174;
b3[i] = 42;
