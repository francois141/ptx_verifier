// Each work-item converts between f32 and 32-bit integers in both signednesses. Inline assembly
// keeps each conversion. Lanes below 32 hold negative values, which separate the signed
// conversions from the unsigned ones.
__kernel void convert_ops(__global float *floats, __global unsigned *words) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    __global float *float_row = floats + 4 * i;
    __global unsigned *word_row = words + 4 * i;
    int small = (int)i - 32;
    // A multiple of 256 keeps each word, signed or unsigned, exactly representable as an f32.
    int wide = small * 256;
    unsigned scalar = (unsigned)__builtin_amdgcn_readfirstlane(wide);
    float converted;

    // A word converts as a signed or an unsigned integer, from a VGPR or an SGPR.
    __asm__ volatile("v_cvt_f32_i32_e32 %0, %1" : "=v"(converted) : "v"(wide));
    float_row[0] = converted;
    __asm__ volatile("v_cvt_f32_u32_e32 %0, %1" : "=v"(converted) : "v"(wide));
    float_row[1] = converted;
    __asm__ volatile("v_cvt_f32_i32_e32 %0, %1" : "=v"(converted) : "s"(scalar));
    float_row[2] = converted;
    __asm__ volatile("v_cvt_f32_u32_e32 %0, %1" : "=v"(converted) : "s"(scalar));
    float_row[3] = converted;

    // A float truncates toward zero: half of `small` has a fraction in the odd lanes, and its
    // negative values clamp to 0 as unsigned.
    unsigned as_signed, as_unsigned;
    float halved;
    __asm__ volatile(
        "v_cvt_f32_i32_e32 %2, %3\n\t"
        "v_mul_f32_e32 %2, 0.5, %2\n\t"
        "v_cvt_i32_f32_e32 %0, %2\n\t"
        "v_cvt_u32_f32_e32 %1, %2"
        : "=&v"(as_signed), "=&v"(as_unsigned), "=&v"(halved) : "v"(small));
    word_row[0] = as_signed;
    word_row[1] = as_unsigned;

    // A float outside the result's range clamps. The literals are 2^27 and 2^28: the first
    // product passes the i32 bounds below lane 16 and from lane 48 on, and the second passes
    // 2^32 from lane 48 on.
    float by_2_27, by_2_28;
    __asm__ volatile(
        "v_cvt_f32_i32_e32 %2, %4\n\t"
        "v_mul_f32_e32 %3, 0x4d800000, %2\n\t"
        "v_mul_f32_e32 %2, 0x4d000000, %2\n\t"
        "v_cvt_i32_f32_e32 %0, %2\n\t"
        "v_cvt_u32_f32_e32 %1, %3"
        : "=&v"(as_signed), "=&v"(as_unsigned), "=&v"(by_2_27), "=&v"(by_2_28) : "v"(small));
    word_row[2] = as_signed;
    word_row[3] = as_unsigned;
}
