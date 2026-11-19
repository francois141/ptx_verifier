"""Proposed fixes of the nkilib bugs, applied to nki-library's unmodified source as it is
imported: `apply(module)` replaces each fix's `old` text (which must occur exactly once) with
its `new` text, keeping the file's name and line count so traced lines still point at it.
A fixed wrapper applies its fixes before importing the kernel, so every importer sees them."""

import importlib.util
import sys

FIXES = {
    # F7: one section per reduced axis, so axis 2's output never reuses axis 0's bytes while
    # axis 1's (possibly larger) output still lies past them.
    "nkilib.experimental.pooling.max_pooling_3d": [
        (
            'sbm.open_scope(interleave_degree=cfg.reduce_interleave, name="pool_reduce")',
            'sbm.open_scope(interleave_degree=cfg.pool_rank, name="pool_reduce")',
        ),
    ],
    # F9: a K-outer tile's matmul writes the rectangle of its valid rows and columns, not the
    # flattened span between them; mark only that rectangle as written.
    "nkilib.experimental.conv.conv3d_helpers": [
        (
            "        valid_start, valid_end = _compute_valid_free_range(\n"
            "            cfg,\n"
            "            dh_positions,\n"
            "            w_start,\n"
            "            w_end,\n"
            "            tile_cfg.used_k_positions,\n"
            "            k_start,\n"
            "            k_end,\n"
            "        )\n"
            "        for pos in range(valid_start, valid_end):\n"
            "            written[pos] = True\n",
            "        valid_start, valid_end = _compute_valid_free_range(\n"
            "            cfg, dh_positions, w_start, w_end, tile_cfg.used_k_positions, k_start, k_end\n"
            "        )\n"
            "        if valid_start >= valid_end:\n"
            "            continue\n"
            "        first_dh, w_lo = divmod(valid_start, w_tile_size)\n"
            "        last_dh = (valid_end - 1) // w_tile_size\n"
            "        w_hi = valid_end - last_dh * w_tile_size\n"
            "        for dh_idx in range(first_dh, last_dh + 1):\n"
            "            for pos in range(dh_idx * w_tile_size + w_lo, dh_idx * w_tile_size + w_hi):\n"
            "                written[pos] = True\n",
        ),
    ],
    # F11: the 2-D col2im branch handles only kd = 0 and dx's plane 0; take the 3-D branch
    # whenever depth matters, as _dx_gemm2d_supported requires for the GEMM2D path.
    "nkilib.experimental.conv.conv3d_bwd_kernels": [
        (
            "    outer_is_d = D_out > 1\n",
            "    outer_is_d = D_out > 1 or cfg.D > 1 or cfg.K_d > 1\n",
        ),
    ],
    # F12: a depth tap is (d_in + pad - d_out * stride) / dilation; d_in is not dilated.
    "nkilib.experimental.conv.conv3d_temporal_unroll": [
        (
            "k_d_num = d_in * dilation_d + pad_d_left - d_out * stride_d",
            "k_d_num = d_in + pad_d_left - d_out * stride_d",
        ),
    ],
}


def apply(name):
    """Import nkilib module `name` with its fixes applied."""
    spec = importlib.util.find_spec(name)
    with open(spec.origin) as file:
        source = file.read()
    for old, new in FIXES[name]:
        assert source.count(old) == 1, (
            f"{name}: the text to fix occurs {source.count(old)} times"
        )
        assert old.count("\n") == new.count("\n"), (
            f"{name}: a fix must keep the line count"
        )
        source = source.replace(old, new)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    exec(compile(source, spec.origin, "exec"), module.__dict__)
    return module
