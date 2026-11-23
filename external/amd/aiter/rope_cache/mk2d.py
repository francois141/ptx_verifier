"""Launch files for kn_entry_1c_2d_cached (rope_common.h:4096), args as dispatch_1c_2d_cached
(rope_common.h:6229) computes them: threads_per_sb from get_grid_config (VecPairs falls back to 1
for a problem this small), total_sb = H*W*B, contiguous (b, s, h, d) input and output."""
import json, sys

def launch(kernel, reuse, B, HH, WW, N, d, RH, RW, F, tps, spec_g, name):
    J = d // 4
    s = HH * WW
    arrays = [
        {"name": "x", "kind": "in", "dtype": "f32", "shape": [B, HH, WW, N, 2, 2, J]},
        {"name": "ch", "kind": "in", "dtype": "f32", "shape": [RH, F]},
        {"name": "sh", "kind": "in", "dtype": "f32", "shape": [RH, F]},
        {"name": "cw", "kind": "in", "dtype": "f32", "shape": [RW, F]},
        {"name": "sw", "kind": "in", "dtype": "f32", "shape": [RW, F]},
        {"name": "out", "kind": "out", "dtype": "f32", "shape": [B, HH, WW, N, 2, 2, J]},
    ]
    st = [s * N * d, N * d, d, 1]          # b, s, h, d strides
    ints = [("img_width", WW), ("size_h", N), ("size_d", d),
            ("stride_i_b", st[0]), ("stride_i_s", st[1]), ("stride_i_h", st[2]), ("stride_i_d", st[3]),
            ("stride_o_b", st[0]), ("stride_o_s", st[1]), ("stride_o_h", st[2]), ("stride_o_d", st[3]),
            ("size_s_h", HH), ("threads_per_sb", tps), ("total_sb", HH * WW * B)]
    params = [{"name": "p_output", "ptr": "out"}, {"name": "p_input", "ptr": "x"},
              {"name": "p_cos_h", "ptr": "ch"}, {"name": "p_sin_h", "ptr": "sh"},
              {"name": "p_cos_w", "ptr": "cw"}, {"name": "p_sin_w", "ptr": "sw"}]
    params += [{"name": n, "int": v} for n, v in ints]
    total = HH * WW * B * tps
    grid = (total + 255) // 256
    out = {"kernel": kernel, "grid": [grid, 1, 1], "block": 256, "arrays": arrays, "params": params,
           "spec": "rope2d.spec",
           "dims": {"B": B, "HH": HH, "WW": WW, "N": N, "T": 2, "Q": 2, "J": J, "RH": RH, "RW": RW, "F": F, "G": spec_g}}
    json.dump(out, open(name, "w"), indent=1)

K0 = "_ZN5aiter21kn_entry_1c_2d_cachedINS_11OpCachedFwdELi0ELb0ELb0ELb1ELb1ELi1EffEEvPT6_PKS2_PKT7_S8_S8_S8_iiiiiiiiiiiiii"
K1 = "_ZN5aiter21kn_entry_1c_2d_cachedINS_11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS2_PKT7_S8_S8_S8_iiiiiiiiiiiiii"
B, HH, WW, N, d = 1, 2, 2, 2, 8
# reuse_freqs_front_part=False (the tested path): tables (1, H', 1, d/2); size_f = d/2, size_half_r = d/4.
launch(K0, False, B, HH, WW, N, d, HH, WW, d // 2, d // 4, d // 4, "rope2d_noreuse.launch.json")
# reuse_freqs_front_part=True as documented (aiter/ops/rope.py:328): tables (1, H', 1, d/4).
# get_grid_config is called with size_f = size_d >> 1 regardless, so size_r = d, threads_per_sb = d/2.
launch(K1, True, B, HH, WW, N, d, HH, WW, d // 4, d // 2, 0, "rope2d_reuse.launch.json")
# Same, with tables padded to H' = 2H, W' = 2W rows (the test's `margin`) so cos/sin reads stay in bounds.
launch(K1, True, B, HH, WW, N, d, 2 * HH, 2 * WW, d // 4, d // 2, 0, "rope2d_reuse_margin.launch.json")
# Fixed kernel: get_grid_config with size_f = d/4 gives size_half_r = d/4, threads_per_sb = d/4.
KF = "_ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii"
launch(KF, True, B, HH, WW, N, d, HH, WW, d // 4, d // 4, 0, "rope2d_reuse_fixed.launch.json")
