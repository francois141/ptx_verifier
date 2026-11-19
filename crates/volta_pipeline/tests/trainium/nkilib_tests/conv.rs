//! nkilib's convolutions found correct: each call proved equal to its spec, and race free once
//! write after write is ordered (their only other conflicts are tiles written, such as by a
//! `memset`, then overwritten unread).

use volta_expr::SymbolicOutputs;

use super::{Arg, WAW, assert_proved, conv_args, conv_dims, lowered, spec};

/// One `conv1d` call: input `[B, C_in, L]`, `C_out`, taps, stride, dilation, `(left, right)`
/// padding, and whether it has a bias.
struct Conv1d {
    x: [u64; 3],
    c_out: u64,
    taps: u64,
    stride: u64,
    dilation: u64,
    padding: [u64; 2],
    bias: bool,
}

impl Conv1d {
    fn call(&self) -> (SymbolicOutputs, Vec<Arg>) {
        let [b, c_in, l] = self.x;
        let out = (l + self.padding[0] + self.padding[1] - self.dilation * (self.taps - 1) - 1)
            / self.stride
            + 1;
        let dims = [
            ("B", b),
            ("CI", c_in),
            ("CO", self.c_out),
            ("L", l),
            ("LO", out),
            ("K", self.taps),
            ("S", self.stride),
            ("DL", self.dilation),
            ("PL", self.padding[0]),
        ];
        let mut args = vec![
            Arg::Tensor("x_in", self.x.to_vec()),
            Arg::Tensor("filters", vec![self.taps, c_in, self.c_out]),
            Arg::Int("stride", self.stride as i64),
            Arg::Ints("padding", self.padding.map(|p| p as i64).to_vec()),
            Arg::Int("dilation", self.dilation as i64),
        ];
        let file = if self.bias {
            args.push(Arg::Tensor("bias", vec![self.c_out]));
            "conv1d.spec"
        } else {
            "conv1d_nobias.spec"
        };
        (spec(file, &dims, &[]), args)
    }
}

#[test]
fn nkilib_conv1d_matches_conv1d_with_stride_dilation_padding_and_many_channels() {
    let calls = [
        Conv1d {
            x: [2, 64, 40],
            c_out: 128,
            taps: 3,
            stride: 2,
            dilation: 2,
            padding: [2, 1],
            bias: true,
        },
        Conv1d {
            x: [1, 130, 21],
            c_out: 130,
            taps: 2,
            stride: 1,
            dilation: 3,
            padding: [0, 3],
            bias: false,
        },
        Conv1d {
            x: [1, 2, 515],
            c_out: 2,
            taps: 3,
            stride: 1,
            dilation: 1,
            padding: [1, 1],
            bias: true,
        },
    ];
    for call in calls {
        let (spec, args) = call.call();
        assert_proved(WAW, &lowered("conv1d.py", &args), &spec, "y_out");
    }
}

/// `depthwise_conv1d_implicit_gemm` on `[N, C, 1, W]` with `S` taps: a stride and asymmetric
/// padding its torch reference cannot express (it pads both sides by the left padding).
#[test]
fn nkilib_depthwise_conv1d_matches_its_definition_across_tap_and_channel_tiles() {
    for (n, c, w, taps, stride, padding) in [
        (2, 130, 12, 3, 2, [2, 1]),
        (1, 2, 210, 200, 3, [2, 5]),
        (1, 3, 9, 1, 4, [0, 3]),
    ] {
        let out = (w + padding[0] + padding[1] - taps) / stride + 1;
        let dims = [
            ("N", n),
            ("C", c),
            ("W", w),
            ("S", taps),
            ("Q", out),
            ("SW", stride),
            ("PL", padding[0]),
            ("ONE", 1),
        ];
        let args = vec![
            Arg::Tensor("img_ref", vec![n, c, 1, w]),
            Arg::Tensor("filter_ref", vec![c, 1, 1, taps]),
            Arg::Ints("padding", padding.map(|p| p as i64).to_vec()),
            Arg::Int("stride", stride as i64),
        ];
        let kernel = lowered("depthwise_conv1d.py", &args);
        let spec = spec("depthwise_conv1d.spec", &dims, &[]);
        assert_proved(WAW, &kernel, &spec, "output");
    }
}

/// A convolution call: input, filters `[Kd, Kh, Kw, C_in, C_out]`, stride, padding
/// `[d_lo, d_hi, h_lo, h_hi, w_lo, w_hi]` and dilation.
type Conv3d = ([u64; 5], [u64; 5], [u64; 3], [u64; 6], [u64; 3]);

fn conv3d_call((x, f, s, p, dl): Conv3d) -> (SymbolicOutputs, Vec<Arg>) {
    let mut args = conv_args(x, f, s, p, dl);
    args.push(Arg::Tensor("bias", vec![f[4]]));
    let spec = spec("conv3d.spec", &conv_dims(x, f, s, p, dl), &[]);
    (spec, args)
}

/// Low-channel calls (`C_in <= 64`), clear of F9 (the fallback path's W padding) and F10.
#[test]
fn nkilib_conv3d_matches_conv3d_with_stride_dilation_and_padding() {
    let calls: [Conv3d; 4] = [
        ([2, 4, 3, 4, 5], [2, 2, 2, 4, 6], [1; 3], [0; 6], [1; 3]),
        ([1, 3, 5, 6, 7], [3, 3, 3, 3, 2], [2; 3], [1; 6], [1; 3]),
        (
            [1, 2, 5, 6, 5],
            [2, 2, 2, 2, 3],
            [1; 3],
            [2, 0, 1, 2, 0, 1],
            [2; 3],
        ),
        (
            [2, 3, 4, 5, 6],
            [2, 3, 2, 3, 2],
            [2, 1, 2],
            [1, 0, 0, 1, 2, 1],
            [1; 3],
        ),
    ];
    for call in calls {
        let (spec, args) = conv3d_call(call);
        assert_proved(WAW, &lowered("conv3d.py", &args), &spec, "conv_out");
    }
}

/// `conv3d_bwd.spec`'s dims, index arrays and the kernel's arguments for one call. `MD`, `MH`
/// and `MW` map a coordinate of `dy` zero-padded by the dilated filter's reach and dilated by
/// the stride to its output position, or `-1`.
fn conv3d_bwd_call((x, f, s, p, dl): Conv3d) -> (SymbolicOutputs, Vec<Arg>) {
    let mut dims = conv_dims(x, f, s, p, dl);
    let out: Vec<u64> = ["OD", "OH", "OW"]
        .iter()
        .map(|name| dims.iter().find(|(d, _)| d == name).unwrap().1)
        .collect();
    let mut indices = vec![];
    for (i, (map_name, size_name)) in [("MD", "ZD"), ("MH", "ZH"), ("MW", "ZW")]
        .into_iter()
        .enumerate()
    {
        let reach = (dl[i] * (f[i] - 1)) as i64;
        let (stride, out) = (s[i] as i64, out[i] as i64);
        let map: Vec<i64> = (0..x[2 + i] as i64 + p[2 * i] as i64 + reach)
            .map(|q| {
                let shifted = q - reach;
                if shifted >= 0 && shifted % stride == 0 && shifted / stride < out {
                    shifted / stride
                } else {
                    -1
                }
            })
            .collect();
        dims.push((size_name, map.len() as u64));
        indices.push((map_name, map));
    }
    let mut args = vec![Arg::Tensor("dy", vec![x[0], f[4], out[0], out[1], out[2]])];
    args.extend(conv_args(x, f, s, p, dl));
    (spec("conv3d_bwd.spec", &dims, &indices), args)
}

/// Each gradient alone, `C_out` within the low-channel paths and past 64 (`dx`'s col2im path
/// with `D_out > 1`, clear of F11); strides, dilation, asymmetric padding and two batches.
#[test]
fn nkilib_conv3d_bwd_gradients_match_the_convolutions_gradients() {
    let calls: [Conv3d; 3] = [
        (
            [2, 3, 4, 5, 5],
            [2, 2, 2, 3, 2],
            [1; 3],
            [1, 0, 0, 1, 1, 1],
            [1; 3],
        ),
        ([1, 2, 5, 6, 6], [2, 2, 2, 2, 3], [2; 3], [1; 6], [1, 2, 1]),
        (
            [1, 2, 3, 3, 4],
            [2, 2, 2, 2, 65],
            [1; 3],
            [0, 1, 1, 0, 0, 0],
            [1; 3],
        ),
    ];
    for call in calls {
        let (spec, args) = conv3d_bwd_call(call);
        for (wrapper, gradient) in [
            ("conv3d_bwd_dx.py", "dx"),
            ("conv3d_bwd_dw.py", "dw"),
            ("conv3d_bwd_db.py", "db"),
        ] {
            assert_proved(WAW, &lowered(wrapper, &args), &spec, gradient);
        }
    }
}

/// Its intended range (`C_in` 65 to 128, `C_out` at most 32, `W_out` above 512), without depth
/// dilation (F12): outputs `[2, 1, 520]` and, strided and padded, `[3, 1, 522]`.
#[test]
fn nkilib_conv3d_temporal_unroll_matches_conv3d_without_depth_dilation() {
    let calls: [Conv3d; 2] = [
        ([1, 65, 2, 1, 520], [1, 1, 1, 65, 1], [1; 3], [0; 6], [1; 3]),
        (
            [1, 65, 5, 3, 522],
            [3, 3, 3, 65, 1],
            [2, 1, 1],
            [1, 1, 0, 0, 1, 1],
            [1; 3],
        ),
    ];
    for call in calls {
        let (spec, args) = conv3d_call(call);
        let kernel = lowered("conv3d_temporal_unroll.py", &args);
        assert_proved(WAW, &kernel, &spec, "y_out");
    }
}

/// `conv3d_transpose` with cubic filter side `k`, stride `s`, symmetric padding `p` and
/// dilation `dl`: `conv3d_transpose.spec`'s `MD`, `MH` and `MW` map a coordinate of the input
/// dilated by the stride and padded by `dl * (k - 1) - p` to its input position, or `-1`.
fn conv3d_transpose_call(
    x: [u64; 5],
    c_out: u64,
    k: u64,
    s: u64,
    p: u64,
    dl: u64,
) -> (SymbolicOutputs, Vec<Arg>) {
    let (reach, pad) = ((dl * (k - 1)) as i64, (dl * (k - 1)) as i64 - p as i64);
    let mut dims = vec![
        ("B", x[0]),
        ("CI", x[1]),
        ("CO", c_out),
        ("D", x[2]),
        ("H", x[3]),
        ("W", x[4]),
        ("KD", k),
        ("KH", k),
        ("KW", k),
        ("DD", dl),
        ("DH", dl),
        ("DW", dl),
    ];
    let mut indices = vec![];
    for (i, (out_name, map_name, size_name)) in
        [("OD", "MD", "ZD"), ("OH", "MH", "ZH"), ("OW", "MW", "ZW")]
            .into_iter()
            .enumerate()
    {
        let (input, stride) = (x[2 + i] as i64, s as i64);
        let out = (input - 1) * stride + reach - 2 * p as i64 + 1;
        let map: Vec<i64> = (0..out + reach)
            .map(|q| {
                let shifted = q - pad;
                if shifted >= 0 && shifted % stride == 0 && shifted / stride < input {
                    shifted / stride
                } else {
                    -1
                }
            })
            .collect();
        dims.push((out_name, out as u64));
        dims.push((size_name, map.len() as u64));
        indices.push((map_name, map));
    }
    let args = vec![
        Arg::Tensor("x_in", x.to_vec()),
        Arg::Tensor("filters", vec![k, k, k, x[1], c_out]),
        Arg::Tensor("bias", vec![c_out]),
        Arg::Ints("stride", vec![s as i64; 3]),
        Arg::Ints("padding", vec![p as i64; 6]),
        Arg::Ints("dilation", vec![dl as i64; 3]),
    ];
    (spec("conv3d_transpose.spec", &dims, &indices), args)
}

#[test]
fn nkilib_conv3d_transpose_matches_conv_transpose3d() {
    for (x, c_out, k, s, p, dl) in [
        ([1, 2, 2, 2, 2], 2, 2, 2, 0, 1),
        ([1, 3, 3, 3, 3], 2, 3, 1, 1, 2),
        ([1, 65, 2, 2, 2], 1, 2, 3, 1, 1),
    ] {
        let (spec, args) = conv3d_transpose_call(x, c_out, k, s, p, dl);
        assert_proved(
            WAW,
            &lowered("conv3d_transpose.py", &args),
            &spec,
            "core_out",
        );
    }
}
