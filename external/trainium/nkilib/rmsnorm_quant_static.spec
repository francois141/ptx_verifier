// nkilib's rmsnorm_quant with static quantization, from rmsnorm_quant_torch.py: each of the
// T = B * S tokens RMS-normalized and scaled by gamma, divided by the dequantization scale
// and clipped to float8_e4m3's range as the kernel clips, max(min(x, 240), -240); the cast
// to fp8 itself is not modelled.
// The reference divides by input_dequant_scale[0, 0], taking its 128 rows to be equal; the
// kernel divides token t by row t (for T <= 128), so the spec states that.
dim T;
dim H;
dim ONE;
dim P;
array hidden[T, H];
array ln_w[ONE, H];
array input_dequant_scale[P, ONE];
array out[T, H];

out[t, h] = max(min(hidden[t, h] * ln_w[0, h]
    / sqrt(sum(k in 0..H, hidden[t, k] * hidden[t, k]) / H + 0.000001)
    / input_dequant_scale[t, 0], 240), -240);
