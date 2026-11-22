// Each work-item writes one row of DPP results: a move of `i + 100` from the lane each selection
// picks into a register holding 7, which a lane keeps when its source lane is out of range.

// Move `i + 100` from the lane `controls` selects into a register holding 7.
#define DPP_MOV(controls, column) do { \
    unsigned moved = 7; \
    __asm__ volatile("v_mov_b32_dpp %0, %1 " controls : "+v"(moved) : "v"(i + 100)); \
    row[column] = moved; \
} while (0)

__kernel void dpp_ops(__global unsigned *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    __global unsigned *row = out + 32 * i;

    DPP_MOV("quad_perm:[2,0,3,1] row_mask:0xf bank_mask:0xf", 0);
    DPP_MOV("row_shl:3 row_mask:0xf bank_mask:0xf", 1);
    DPP_MOV("row_shr:5 row_mask:0xf bank_mask:0xf", 2);
    DPP_MOV("row_ror:7 row_mask:0xf bank_mask:0xf", 3);
    DPP_MOV("wave_shl:1 row_mask:0xf bank_mask:0xf", 4);
    DPP_MOV("wave_rol:1 row_mask:0xf bank_mask:0xf", 5);
    DPP_MOV("wave_shr:1 row_mask:0xf bank_mask:0xf", 6);
    DPP_MOV("wave_ror:1 row_mask:0xf bank_mask:0xf", 7);
    DPP_MOV("row_mirror row_mask:0xf bank_mask:0xf", 8);
    DPP_MOV("row_half_mirror row_mask:0xf bank_mask:0xf", 9);
    DPP_MOV("row_bcast:15 row_mask:0xa bank_mask:0xf", 10);
    DPP_MOV("row_bcast:31 row_mask:0xc bank_mask:0xf", 11);

    // bound_ctrl reads 0 from an out-of-range source; the masks leave rows 1 and 3, and in each
    // row the lanes of banks 0 and 2, keeping 7.
    DPP_MOV("row_shr:5 row_mask:0xf bank_mask:0xf bound_ctrl:1", 12);
    DPP_MOV("row_shl:1 row_mask:0x5 bank_mask:0xa", 13);

    // A VOP2 operation adds this lane's second source to the moved first one.
    unsigned sum;
    __asm__ volatile("v_add_u32_dpp %0, %1, %2 row_ror:1 row_mask:0xf bank_mask:0xf"
                     : "=v"(sum) : "v"(i + 100), "v"(1000 * i));
    row[14] = sum;

    // With only the odd lanes active, each reads its inactive even neighbor: it keeps 7, or reads
    // 0 under bound_ctrl. The even lanes do not run and keep 7.
    ulong saved, odd;
    __asm__ volatile("v_cmp_ne_u32_e64 %0, 0, %1" : "=s"(odd) : "v"(i & 1));
    unsigned kept = 7, zeroed = 7;
    __asm__ volatile(
        "s_mov_b64 %2, exec\n\t"
        "s_mov_b64 exec, %3\n\t"
        "v_mov_b32_dpp %0, %4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf\n\t"
        "v_mov_b32_dpp %1, %4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1\n\t"
        "s_mov_b64 exec, %2"
        : "+v"(kept), "+v"(zeroed), "=&s"(saved) : "s"(odd), "v"(i + 100));
    row[15] = kept;
    row[16] = zeroed;
}
