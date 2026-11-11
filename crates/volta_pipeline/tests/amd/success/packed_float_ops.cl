// Each work-item writes sixteen pairs of symbolic float results to its own 32-float row.
// A compiler memory barrier prevents adjacent input loads from becoming one wide load.
__kernel void packed_float_ops(__global const float *a,
                               __global const float *b,
                               __global const float *c,
                               __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float x_low = a[2 * i], y_low = b[2 * i], z_low = c[2 * i];
    __asm__ volatile("" : : : "memory");
    float2 x = (float2)(x_low, a[2 * i + 1]);
    float2 y = (float2)(y_low, b[2 * i + 1]);
    float2 z = (float2)(z_low, c[2 * i + 1]);
    __global float *row = out + 32 * i;
    float2 result;

    // FMA consumes every input before stores, avoiding dependence on partial VM waits.
    // Default selectors operate on the corresponding components of each source.
    __asm__ volatile("v_pk_fma_f32 %0, %1, %2, %3"
                     : "=v"(result) : "v"(x), "v"(y), "v"(z));
    row[4] = result.s0;
    row[5] = result.s1;
    __asm__ volatile("v_pk_add_f32 %0, %1, %2" : "=v"(result) : "v"(x), "v"(y));
    row[0] = result.s0;
    row[1] = result.s1;
    __asm__ volatile("v_pk_mul_f32 %0, %1, %2" : "=v"(result) : "v"(x), "v"(y));
    row[2] = result.s0;
    row[3] = result.s1;

    // Select either component, including broadcasting either source's low component.
    __asm__ volatile("v_pk_add_f32 %0, %1, %2 op_sel:[1,0] op_sel_hi:[0,1]"
                     : "=v"(result) : "v"(x), "v"(y));
    row[6] = result.s0;
    row[7] = result.s1;
    __asm__ volatile("v_pk_mul_f32 %0, %1, %2 op_sel_hi:[1,0]"
                     : "=v"(result) : "v"(x), "v"(y));
    row[8] = result.s0;
    row[9] = result.s1;
    __asm__ volatile("v_pk_mul_f32 %0, %1, %2 op_sel_hi:[0,1]"
                     : "=v"(result) : "v"(x), "v"(y));
    row[10] = result.s0;
    row[11] = result.s1;
    __asm__ volatile("v_pk_fma_f32 %0, %1, %2, %3 op_sel:[1,0,0] op_sel_hi:[0,1,0]"
                     : "=v"(result) : "v"(x), "v"(y), "v"(z));
    row[12] = result.s0;
    row[13] = result.s1;

    // Negation is independent for each source and for each output component.
    __asm__ volatile("v_pk_add_f32 %0, %1, %2 neg_lo:[1,0] neg_hi:[0,1]"
                     : "=v"(result) : "v"(x), "v"(y));
    row[14] = result.s0;
    row[15] = result.s1;
    __asm__ volatile("v_pk_mul_f32 %0, %1, %2 neg_lo:[0,1] neg_hi:[1,0]"
                     : "=v"(result) : "v"(x), "v"(y));
    row[16] = result.s0;
    row[17] = result.s1;
    __asm__ volatile("v_pk_fma_f32 %0, %1, %2, %3 neg_lo:[1,0,0] neg_hi:[0,1,0]"
                     : "=v"(result) : "v"(x), "v"(y), "v"(z));
    row[18] = result.s0;
    row[19] = result.s1;
    __asm__ volatile("v_pk_fma_f32 %0, %1, %2, %3 neg_lo:[0,0,1] neg_hi:[1,1,1]"
                     : "=v"(result) : "v"(x), "v"(y), "v"(z));
    row[20] = result.s0;
    row[21] = result.s1;

    // A scalar pair retains lane zero's symbols; either selector reads the same inline constant.
    uint2 uniform = (uint2)(__builtin_amdgcn_readfirstlane(as_uint(x.s0)),
                            __builtin_amdgcn_readfirstlane(as_uint(x.s1)));
    __asm__ volatile("v_pk_mul_f32 %0, %1, %2"
                     : "=v"(result) : "s"(uniform), "v"(y));
    row[22] = result.s0;
    row[23] = result.s1;
    __asm__ volatile("v_pk_add_f32 %0, %1, 2.0 op_sel_hi:[1,0]"
                     : "=v"(result) : "v"(x));
    row[24] = result.s0;
    row[25] = result.s1;
    __asm__ volatile("v_pk_fma_f32 %0, %1, 2.0, %2"
                     : "=v"(result) : "v"(x), "v"(z));
    row[26] = result.s0;
    row[27] = result.s1;

    // Both results must read the original pair when the destination is also a source.
    result = x;
    __asm__ volatile("v_pk_mul_f32 %0, %0, %1 op_sel:[1,0] op_sel_hi:[0,1]"
                     : "+v"(result) : "v"(y));
    row[28] = result.s0;
    row[29] = result.s1;
    result = z;
    __asm__ volatile("v_pk_fma_f32 %0, %1, %2, %0 op_sel_hi:[1,1,0]"
                     : "+v"(result) : "v"(x), "v"(y));
    row[30] = result.s0;
    row[31] = result.s1;
}
