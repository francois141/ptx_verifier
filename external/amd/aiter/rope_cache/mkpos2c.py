"""Launch files for kn_entry_2c_sbhd_cached_indirect (rope_common.h:3385) with the args
rope_cached_positions_2c_fwd_impl / dispatch_2c_sbhd_cached_indirect pass: s = 1, b = 2 tokens,
h_x = 4, h_y = 2 (GQA), d = 128, cos/sin [4, 1, 1, 32] (rotary 64, reuse), positions int64 [3, 1]."""
import json
S, B, HX, HY, D, F, P = 1, 2, 4, 2, 128, 32, 4

def launch(kernel, vp, style, name):
    lay = [2, 2, 32] if style == "neox" else [2, 32, 2]
    arrays = [
        {"name": "x", "kind": "in", "dtype": "bf16", "shape": [S, B, HX] + lay},
        {"name": "y", "kind": "in", "dtype": "bf16", "shape": [S, B, HY] + lay},
        {"name": "c", "kind": "in", "dtype": "bf16", "shape": [P, F]},
        {"name": "sn", "kind": "in", "dtype": "bf16", "shape": [P, F]},
        {"name": "pos", "kind": "in", "dtype": "i32", "shape": [2 * B], "contents": [3, 0, 1, 0]},
        {"name": "ox", "kind": "out", "dtype": "bf16", "shape": [S, B, HX] + lay},
        {"name": "oy", "kind": "out", "dtype": "bf16", "shape": [S, B, HY] + lay},
    ]
    sx = [B * HX * D, HX * D, D, 1]
    sy = [B * HY * D, HY * D, D, 1]
    tps = (F // vp)                        # size_half_r / vec_pairs, size_half_r = F under reuse
    ints = [("max_position", P), ("size_h_x", HX), ("size_h_y", HY), ("size_d", D), ("size_f", F)]
    ints += [(f"stride_ix_{k}", v) for k, v in zip("sbhd", sx)] + [(f"stride_iy_{k}", v) for k, v in zip("sbhd", sy)]
    ints += [(f"stride_ox_{k}", v) for k, v in zip("sbhd", sx)] + [(f"stride_oy_{k}", v) for k, v in zip("sbhd", sy)]
    ints += [("size_s", S), ("threads_per_sb", tps), ("total_sb", S * B)]
    params = [{"name": n, "ptr": a} for n, a in [("p_output_x", "ox"), ("p_output_y", "oy"), ("p_input_x", "x"),
              ("p_input_y", "y"), ("p_cos", "c"), ("p_sin", "sn"), ("p_indirect_buffer", "pos")]]
    params += [{"name": n, "int": v} for n, v in ints]
    out = {"kernel": kernel, "grid": [(S * B * tps + 255) // 256, 1, 1], "block": 256, "arrays": arrays,
           "params": params, "spec": f"pos2c_{style}.spec",
           "dims": {"S": S, "B": B, "HX": HX, "HY": HY, "T": 2, "Q": 2, "J": 32, "P": P}}
    json.dump(out, open(name, "w"), indent=1)

pre = "_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi"
suf = "ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii"
launch(pre + "0ELb1ELb0ELb1ELb1ELb1ELb1ELi2" + suf, 2, "neox", "pos2c_neox_vp2.launch.json")
launch(pre + "0ELb1ELb0ELb1ELb1ELb1ELb1ELi1" + suf, 1, "neox", "pos2c_neox_vp1.launch.json")
launch(pre + "1ELb1ELb0ELb1ELb1ELb1ELb1ELi4" + suf, 4, "gptj", "pos2c_gptj_vp4.launch.json")
launch(pre + "1ELb1ELb0ELb1ELb1ELb1ELb1ELi2" + suf, 2, "gptj", "pos2c_gptj_vp2.launch.json")
launch(pre + "1ELb1ELb0ELb1ELb1ELb1ELb1ELi1" + suf, 1, "gptj", "pos2c_gptj_vp1.launch.json")
