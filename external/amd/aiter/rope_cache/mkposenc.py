"""Launch files for probe::rotary_embedding_kernel (pos_encoding_kernels.cu:100 with split in/out pointers), args as
rotary_embedding (pos_encoding_kernels.cu:160) computes them for a 2-D [T, H * D] query: grid(T), block(min(H * rot / 2, 512))."""
import json

def words64(v):
    return [v & 0xffffffff, (v >> 32) & 0xffffffff]

def launch(kernel, dtype, style, H, K, D, R, nope_first, name):
    J = R // 2
    eb = 4 if dtype == "f32" else 2
    lay = [2, J] if style == "neox" else [J, 2]
    base = 0x10000
    arrays, ptr = [], {}
    def add(n, kind, dt, shape, extra=None, at=None):
        nonlocal base
        a = {"name": n, "kind": kind, "dtype": dt, "shape": shape, "base": base if at is None else at}
        if extra: a.update(extra)
        arrays.append(a)
        if at is None:
            base += 0x10000
        return a["base"]
    add("pos", "in", "i32", [2], {"contents": [3, 0]})
    for nm, nh in (("q", H), ("k", K)):
        if R == D:
            add(nm, "in", dtype, [nh] + lay)
            add(nm + "o", "out", dtype, [nh] + lay)
        else:   # nope first: head h's rotary part is elements [D - R, D)
            b_in = add(nm + "_nope", "in", dtype, [D - R])       # pointer base; never read
            for h in range(nh):
                if h > 0: add(f"{nm}_nope{h}", "in", dtype, [D - R], at=b_in + (h * D) * eb)
                add(f"{nm}{h}", "in", dtype, lay, at=b_in + (h * D + D - R) * eb)
            b_out = add(nm + "o_nope", "in", dtype, [D - R])
            for h in range(nh):
                if h > 0: add(f"{nm}o_nope{h}", "in", dtype, [D - R], at=b_out + (h * D) * eb)
                add(f"{nm}o{h}", "out", dtype, lay, at=b_out + (h * D + D - R) * eb)
    add("c", "in", dtype, [4, J]); add("sn", "in", dtype, [4, J])
    first = lambda nm: nm if R == D else nm + "_nope"
    block = min(H * R // 2, 512)
    p = [("positions", {"ptr": "pos"}), ("query", {"ptr": first("q")}), ("query_o", {"ptr": first("qo")}),
         ("key", {"ptr": first("k")}), ("key_o", {"ptr": first("ko")}), ("cos", {"ptr": "c"}), ("sin", {"ptr": "sn"})]
    params = [{"name": n, **v} for n, v in p]
    ints = [("rot_dim", [R]), ("pad", [0]), ("query_stride", words64(H * D)), ("key_stride", words64(K * D)),
            ("num_heads", [H]), ("num_kv_heads", [K]), ("head_size", [D]), ("pad", [0]),
            ("hidden_block_count_x", [1]), ("hidden_block_count_y", [1]), ("hidden_block_count_z", [1]),
            ("hidden_group_size_x|y", [block | (1 << 16)]), ("hidden_group_size_z|remainder_x", [1]), ("remainder_y|z", [0])]
    for n, ws in ints:
        params += [{"name": n, "int": w - (1 << 32) if w >= 1 << 31 else w} for w in ws]
    while len(params) - 7 < (160 - 56) // 4: params.append({"name": "pad", "int": 0})
    params.append({"name": "hidden_grid_dims", "int": 1})
    while len(params) - 7 < (352 - 56) // 4: params.append({"name": "pad", "int": 0})
    out = {"kernel": kernel, "grid": [1, 1, 1], "block": block, "arrays": arrays, "params": params}
    if R == D:
        out["spec"] = f"posenc_{style}.spec"
        out["dims"] = {"H": H, "K": K, "Q": 2, "J": J, "P": 4}
    else:
        out["spec"] = f"posenc_{style}_nope{H}{K}.spec"
        spec = [f"// vLLM rotary_embedding, GPT-J, is_nope_first, head {D}, rot_dim {R}, position 3: head h's rotary element 2 j + s.",
                "dim J; dim Q; dim P; dim N;", "array c[P, J]; array sn[P, J];"]
        for nm, nh in (("q", H), ("k", K)):
            for h in range(nh):
                spec.append(f"array {nm}{h}[J, Q]; array {nm}_nope{'' if h == 0 else h}[N]; array {nm}o{h}[J, Q]; array {nm}o_nope{'' if h == 0 else h}[N];")
        for nm, nh in (("q", H), ("k", K)):
            for h in range(nh):
                spec.append(f"{nm}o{h}[j, s] = {nm}{h}[j, s] * c[3, j] + (2 * s - 1) * {nm}{h}[j, 1 - s] * sn[3, j];")
        open(out["spec"], "w").write("\n".join(spec) + "\n")
        out["dims"] = {"J": J, "Q": 2, "P": 4, "N": D - R}
    json.dump(out, open(name, "w"), indent=1)

launch("_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii", "bf16", "neox", 4, 2, 64, 64, False, "posenc_bf16_neox.launch.json")
launch("_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii", "bf16", "gptj", 4, 2, 64, 64, False, "posenc_bf16_gptj.launch.json")
launch("_ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii", "f32", "gptj", 2, 1, 128, 64, True, "posenc_f32_gptj_nopefirst.launch.json")
launch("_ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii", "f32", "neox", 4, 2, 64, 64, False, "posenc_f32_neox.launch.json")
