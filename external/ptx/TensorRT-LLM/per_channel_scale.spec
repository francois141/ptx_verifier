// TensorRT-LLM apply_per_channel_scale<T, T, kProcessRows, float4> (preQuantScaleKernel.cu:44) on
// block (x, y): rows [R0, R1) and columns [C0, C1) of act [R, C] scaled by per_channel_scale[c]
// (one expert: no expert offsets); nothing else is written.
dim R; dim C; dim R0; dim R1; dim C0; dim C1;
array act[R, C]; array scale[C];
array out[R, C];
out[r, c] = where(r >= R0, where(r < R1, where(c >= C0, where(c < C1, act[r, c] * scale[c],
    unwritten), unwritten), unwritten), unwritten);
