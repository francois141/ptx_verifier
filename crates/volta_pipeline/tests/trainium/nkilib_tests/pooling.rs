//! nkilib's pooling and padding kernels, found correct: each call proved equal to its spec on
//! every element and race free.

use volta_trainium_analysis::OrderingPolicy;

use super::{Arg, WAW, assert_proved, lowered, pool_bounds, spec};

/// A pooling window: its side, stride and padding, the same along every axis.
#[derive(Clone, Copy, Debug)]
struct Window {
    kernel: u64,
    stride: u64,
    padding: u64,
}

const fn window(kernel: u64, stride: u64, padding: u64) -> Window {
    Window {
        kernel,
        stride,
        padding,
    }
}

impl Window {
    fn output(self, input: u64) -> u64 {
        (input + 2 * self.padding - self.kernel) / self.stride + 1
    }

    fn args(self) -> [Arg; 3] {
        [
            Arg::Int("kernel_size", self.kernel as i64),
            Arg::Int("stride", self.stride as i64),
            Arg::Int("padding", self.padding as i64),
        ]
    }

    /// The spec dims of pooling an NCDHW `input` through this window.
    fn dims(self, input: [u64; 5]) -> Vec<(&'static str, u64)> {
        let [b, c, d, h, w] = input;
        let mut dims = vec![("B", b), ("C", c), ("D", d), ("H", h), ("W", w)];
        dims.extend(
            ["OD", "OH", "OW"]
                .into_iter()
                .zip([d, h, w].map(|n| self.output(n))),
        );
        dims.extend(["KD", "KH", "KW"].map(|name| (name, self.kernel)));
        dims.extend(["SD", "SH", "SW"].map(|name| (name, self.stride)));
        dims.extend(["PD", "PH", "PW"].map(|name| (name, self.padding)));
        dims
    }

    /// The averaging specs divide by the window's volume, which matches the kernel's double
    /// reciprocal only for a power of two; a 3 x 3 x 3 window's spec uses its rounded 1/27.
    fn spec_file(self, stem: &str) -> String {
        match self.kernel {
            3 => format!("{stem}_k3.spec"),
            _ => format!("{stem}.spec"),
        }
    }
}

fn borrowed(indices: &[(String, Vec<i64>)]) -> Vec<(&str, Vec<i64>)> {
    indices
        .iter()
        .map(|(name, values)| (name.as_str(), values.clone()))
        .collect()
}

/// Avg pooling's layouts: NCDHW, NDHWC, and NCDHW in with NDHWC out.
#[derive(Clone, Copy)]
enum Layout {
    Ncdhw,
    Ndhwc,
    NcdhwToNdhwc,
}

impl Layout {
    fn stem(self) -> &'static str {
        match self {
            Layout::Ncdhw => "avg_pooling_3d",
            Layout::Ndhwc => "avg_pooling_3d_ndhwc",
            Layout::NcdhwToNdhwc => "avg_pooling_3d_to_ndhwc",
        }
    }

    fn input_shape(self, [b, c, d, h, w]: [u64; 5]) -> Vec<u64> {
        match self {
            Layout::Ncdhw | Layout::NcdhwToNdhwc => vec![b, c, d, h, w],
            Layout::Ndhwc => vec![b, d, h, w, c],
        }
    }
}

fn check_avg_pooling(layout: Layout, input: [u64; 5], window: Window) {
    let mut args = vec![Arg::Tensor("src_tensor", layout.input_shape(input))];
    args.extend(window.args());
    let spec = spec(&window.spec_file(layout.stem()), &window.dims(input), &[]);
    // Padded windows memset a tile and then DMA the input over it.
    assert_proved(
        WAW,
        &lowered(&format!("{}.py", layout.stem()), &args),
        &spec,
        "out",
    );
}

const SMALL: [u64; 5] = [1, 2, 5, 6, 7];

#[test]
fn nkilib_avg_pooling_3d_matches_avg_pool3d_in_each_layout() {
    for window in [window(2, 2, 0), window(2, 1, 1), window(3, 2, 1)] {
        check_avg_pooling(Layout::Ncdhw, SMALL, window);
    }
    for window in [window(2, 2, 0), window(2, 1, 1)] {
        check_avg_pooling(Layout::Ndhwc, SMALL, window);
        check_avg_pooling(Layout::NcdhwToNdhwc, SMALL, window);
    }
}

/// 260 planes, more than one group of 128 partitions.
#[test]
fn nkilib_avg_pooling_3d_matches_avg_pool3d_over_more_planes_than_partitions() {
    for window in [window(2, 2, 0), window(3, 2, 1)] {
        check_avg_pooling(Layout::Ncdhw, [2, 130, 5, 6, 7], window);
    }
}

/// For each input position along an axis of extent `input`, the outputs whose window
/// contains it, `[low, high)` clamped to the output: `avg_pooling_3d_backward.spec`'s `L`
/// and `H` index arrays.
fn windows_containing(input: u64, window: Window) -> [Vec<i64>; 2] {
    let [k, s, p] = [window.kernel, window.stride, window.padding].map(|v| v as i64);
    let out = window.output(input) as i64;
    let low: Vec<i64> = (0..input as i64)
        .map(|x| (x + p - k + s).div_euclid(s).max(0))
        .collect();
    let high = (0..input as i64)
        .zip(&low)
        .map(|(x, &first)| ((x + p) / s + 1).min(out).max(first))
        .collect();
    [low, high]
}

#[test]
fn nkilib_avg_pooling_3d_backward_matches_the_gradient_of_avg_pool3d() {
    let calls = [
        (SMALL, window(2, 2, 0)),
        (SMALL, window(3, 1, 1)),
        (SMALL, window(3, 2, 1)),
        (SMALL, window(2, 1, 1)),
        (SMALL, window(4, 1, 2)),
        (SMALL, window(2, 1, 0)),
        (SMALL, window(3, 2, 0)),
        ([1, 2, 4, 6, 6], window(3, 2, 1)),
    ];
    for (input, window) in calls {
        let [b, c, d, h, w] = input;
        let mut indices = vec![];
        for (axis, extent) in ["D", "H", "W"].into_iter().zip([d, h, w]) {
            let [low, high] = windows_containing(extent, window);
            indices.push((["L", axis].concat(), low));
            indices.push((["H", axis].concat(), high));
        }
        let spec = spec(
            &window.spec_file("avg_pooling_3d_backward"),
            &window.dims(input),
            &borrowed(&indices),
        );
        let grad_output = [d, h, w].map(|n| window.output(n));
        let mut args = vec![
            Arg::Tensor("grad_output", [[b, c].as_slice(), &grad_output].concat()),
            Arg::Tensor("input_tensor", input.to_vec()),
        ];
        args.extend(window.args());
        let kernel = lowered("avg_pooling_3d_backward.py", &args);
        assert_proved(OrderingPolicy::BASELINE, &kernel, &spec, "grad_input");
    }
}

/// Windows whose outputs are no larger than their inputs; growing ones are F7 (`bugs`).
#[test]
fn nkilib_max_pooling_3d_matches_max_pool3d_where_no_axis_grows() {
    for window in [window(2, 2, 0), window(3, 2, 1), window(3, 1, 1)] {
        let [b, c, d, h, w] = SMALL;
        let mut dims = vec![("B", b), ("C", c), ("D", d), ("H", h), ("W", w)];
        let mut indices = vec![];
        for ((axis, out_dim), extent) in ["D", "H", "W"]
            .into_iter()
            .zip(["OD", "OH", "OW"])
            .zip([d, h, w])
        {
            let (out, [low, high]) =
                pool_bounds(extent, window.kernel, window.stride, window.padding);
            dims.push((out_dim, out));
            indices.push((["L", axis].concat(), low));
            indices.push((["H", axis].concat(), high));
        }
        let spec = spec("max_pooling_3d.spec", &dims, &borrowed(&indices));
        let mut args = vec![Arg::Tensor("src_tensor", SMALL.to_vec())];
        args.extend(window.args());
        let kernel = lowered("max_pooling_3d.py", &args);
        assert_proved(OrderingPolicy::BASELINE, &kernel, &spec, "out");
    }
}

/// `pad`'s modes, in the wrapper's `MODES` order.
#[derive(Clone, Copy, Debug)]
enum PadMode {
    Constant,
    Replicate,
    Reflect,
    Circular,
}

impl PadMode {
    /// The input position output `o` reads along an axis of extent `n` padded by `low`
    /// before, or `-1`, a zero of `pad.spec`'s padded input.
    fn source(self, o: i64, n: i64, low: i64) -> i64 {
        let i = o - low;
        match self {
            _ if (0..n).contains(&i) => i,
            PadMode::Constant => -1,
            PadMode::Replicate => i.clamp(0, n - 1),
            PadMode::Reflect if i < 0 => -i,
            PadMode::Reflect => 2 * (n - 1) - i,
            PadMode::Circular => i.rem_euclid(n),
        }
    }
}

/// `pad` of an `[N, C, D, H, W]` input with `padding` in PyTorch's order, innermost axis
/// first, one `(low, high)` pair per padded axis.
fn check_pad(mode: PadMode, input: [u64; 5], padding: &[i64]) {
    let mut per_axis = [(0, 0); 3];
    for (axis, pair) in padding.chunks(2).enumerate() {
        per_axis[2 - axis] = (pair[0], pair[1]);
    }
    let [n, c, d, h, w] = input;
    let mut dims = vec![("N", n), ("C", c), ("D", d), ("H", h), ("W", w)];
    let mut indices = vec![];
    for (((name, out_dim), extent), (low, high)) in ["MD", "MH", "MW"]
        .into_iter()
        .zip(["OD", "OH", "OW"])
        .zip([d, h, w])
        .zip(per_axis)
    {
        let extent = extent as i64;
        let map: Vec<i64> = (0..extent + low + high)
            .map(|o| mode.source(o, extent, low))
            .collect();
        dims.push((out_dim, map.len() as u64));
        indices.push((name, map));
    }
    let spec = spec("pad.spec", &dims, &indices);
    let args = [
        Arg::Tensor("x_ref", input.to_vec()),
        Arg::Ints("padding", padding.to_vec()),
        Arg::Int("mode", mode as i64),
    ];
    assert_proved(
        OrderingPolicy::BASELINE,
        &lowered("pad.py", &args),
        &spec,
        "out",
    );
}

#[test]
fn nkilib_pad_matches_torch_pad_in_each_mode() {
    check_pad(PadMode::Constant, [1, 3, 4, 5, 6], &[1, 2]);
    check_pad(PadMode::Constant, [2, 2, 3, 4, 5], &[0, 3, 2, 1, 1, 0]);
    check_pad(PadMode::Replicate, [2, 2, 3, 4, 5], &[2, 1, 0, 3]);
    check_pad(PadMode::Replicate, [1, 3, 2, 3, 4], &[4, 0, 1, 2, 3, 1]);
    check_pad(PadMode::Reflect, [1, 2, 3, 4, 5], &[4, 1]);
    check_pad(PadMode::Reflect, [1, 2, 3, 4, 5], &[1, 2, 3, 0, 2, 1]);
    check_pad(PadMode::Circular, [1, 3, 2, 4, 3], &[3, 1, 2, 4]);
    check_pad(PadMode::Circular, [1, 130, 2, 3, 4], &[4, 1, 0, 3, 2, 2]);
}
