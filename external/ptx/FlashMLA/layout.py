"""SparseAttnDecodeParams (FlashMLA csrc/params.h:118) field offsets under the x86-64 C ABI."""

FIELDS = [  # (name, size) in declaration order; alignment = size
    *[(n, 4) for n in "b s_q h_q h_kv d_qk d_v".split()],
    ("sm_scale", 4), ("sm_scale_div_log2", 4),
    *[(n, 4) for n in "num_blocks page_block_size topk model_type extra_model_type".split()],
    *[(n, 8) for n in "q kv indices topk_length attn_sink lse out".split()],
    *[(n, 4) for n in "extra_num_blocks extra_page_block_size extra_topk".split()],
    *[(n, 8) for n in "extra_kv extra_indices extra_topk_length".split()],
    *[(n, 4) for n in ("stride_q_b stride_q_s_q stride_q_h_q stride_kv_block stride_kv_row "
                       "stride_indices_b stride_indices_s_q stride_lse_b stride_lse_s_q stride_o_b "
                       "stride_o_s_q stride_o_h_q stride_extra_kv_block stride_extra_kv_row "
                       "stride_extra_indices_b stride_extra_indices_s_q num_sm").split()],
    ("stream", 8), ("enable_split_kv", 1),
    ("lse_accum", 8), ("o_accum", 8),
    *[(n, 4) for n in ("stride_lse_accum_split stride_lse_accum_s_q stride_o_accum_split "
                       "stride_o_accum_s_q stride_o_accum_h_q").split()],
    ("tile_scheduler_metadata_ptr", 8), ("num_splits_ptr", 8), ("num_sm_parts", 4),
]


def layout():
    offsets, at = {}, 0
    for name, size in FIELDS:
        at = -(-at // size) * size
        offsets[name] = (at, size)
        at += size
    return offsets, -(-at // 8) * 8


OFFSETS, SIZE = layout()
