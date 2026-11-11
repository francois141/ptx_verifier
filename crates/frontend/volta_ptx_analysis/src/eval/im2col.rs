//! The `.im2col` load mode of `cp.async.bulk.tensor` (PTX ISA 5.5.4): the column of pixels a
//! load walks from its filter base through its tensor map's bounding box, one shared-memory row
//! of channels per pixel. `async_bulk` issues the copy; this module picks its elements.

use crate::eval::ThreadId;
use crate::eval::async_bulk::{BoxElement, MappedTensor, tma_misuse};
use crate::eval::error::{EvalError, EvalResult, TmaMisuse};
use crate::eval::interp::Interpreter;
use crate::eval::tcgen05_mma;
use crate::ir::tensor_map::Im2colBox;
use crate::ir::{InstrId, Operand};

impl Interpreter<'_> {
    /// An `.im2col` copy's offsets: each operand's 16 bits, at most what a tensor of `rank`
    /// dims allows (ISA 5.5.4.1).
    pub(in crate::eval) fn im2col_offsets(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        offsets: &[Operand],
        rank: usize,
    ) -> EvalResult<Vec<i64>> {
        let max = match rank {
            3 => (1 << 16) - 1,
            4 => (1 << 8) - 1,
            5 => (1 << 5) - 1,
            _ => unreachable!("lowering admits .im2col for .3d to .5d tensors only"),
        };

        let mut values = Vec::with_capacity(offsets.len());
        for offset in offsets {
            let bits = self.concrete_operand(t, pc, offset, "im2col offset")?;
            let offset = bits as u64 & 0xFFFF;
            if offset > max {
                let misuse = TmaMisuse::Im2colOffsetOutOfRange { offset, max };
                return Err(tma_misuse(t, pc, misuse));
            }
            values.push(offset as i64);
        }

        Ok(values)
    }
}

/// An `.im2col` copy's pixel column (ISA 5.5.4): `pixels_per_column` filter bases walked from
/// `coords` through the bounding box, each pixel read `offsets` further on and loaded as one
/// `layout` row of `channels_per_pixel` channels. Dimensions run C, then W, H, D, then N.
pub(in crate::eval) fn im2col_elements(
    t: ThreadId,
    pc: InstrId,
    tensor: &MappedTensor,
    im2col: &Im2colBox,
    coords: &[i64],
    offsets: &[i64],
    layout: &tcgen05_mma::MatrixDescriptor,
) -> EvalResult<Vec<BoxElement>> {
    let rank = coords.len();
    let batch = rank - 1;

    if tensor.element_strides[0] != 1 || tensor.element_strides[batch] != 1 {
        return Err(EvalError::Unsupported {
            pc,
            what: "cp.async.bulk.tensor.im2col: a traversal stride along C or N is not modeled"
                .to_string(),
        });
    }

    // Indexed by dimension like `coords`; C and N have no corners and no offset.
    let mut lower = vec![0i64; rank];
    let mut upper = vec![0i64; rank];
    let mut shift = vec![0i64; rank];
    for d in 1..batch {
        lower[d] = im2col.lower_corner[d - 1] as i64;
        upper[d] = tensor.dims[d] as i64 - 1 + im2col.upper_corner[d - 1] as i64;
        shift[d] = offsets[d - 1];

        if !(lower[d]..=upper[d]).contains(&coords[d]) {
            let misuse = TmaMisuse::FilterBaseOutsideBoundingBox {
                dim: d,
                coord: coords[d],
                lower: lower[d],
                upper: upper[d],
            };
            return Err(tma_misuse(t, pc, misuse));
        }
    }

    let channels = im2col.channels_per_pixel as u64;
    let mut elements = Vec::with_capacity(im2col.pixels_per_column as usize * channels as usize);
    let mut base = coords.to_vec();
    for pixel in 0..im2col.pixels_per_column as u64 {
        let mut index = Vec::with_capacity(rank);
        for d in 0..rank {
            index.push(base[d] + shift[d]);
        }

        for channel in 0..channels {
            index[0] = base[0] + channel as i64;
            elements.push(BoxElement {
                global: tensor.address(&index),
                shared: tcgen05_mma::swizzled_element_addr(
                    layout,
                    pixel,
                    channel,
                    tensor.elem_bytes,
                ),
            });
        }

        next_filter_base(&mut base, &lower, &upper, &tensor.element_strides);
    }

    Ok(elements)
}

/// Step an im2col walk's filter base to its next pixel: W by its traversal stride; a spatial
/// dim stepped past the bounding box's upper corner restarts at its lower corner and steps the
/// next one out, and past the outermost the walk runs on into the next image (N, unbounded).
fn next_filter_base(base: &mut [i64], lower: &[i64], upper: &[i64], element_strides: &[u32]) {
    let batch = base.len() - 1;

    for d in 1..batch {
        base[d] += element_strides[d] as i64;
        if base[d] <= upper[d] {
            return;
        }
        base[d] = lower[d];
    }

    base[batch] += 1;
}

/// The GPU-checked examples of Triton's Gluon im2col tutorial, each run with the tutorial's own
/// arguments (in its N, H, W, C order) and assertion.
#[cfg(test)]
mod tests {
    use super::*;

    const PIXELS: usize = 16;
    const CHANNELS: usize = 32;
    const ELEM_BYTES: u64 = 4;
    const IMAGE_BASE: u64 = 0x10000;
    const TILE_BASE: u64 = 0x400;

    /// The tutorial's `out`: `block_shape` [16, 32], one row of channels per pixel.
    type Out = [[u64; CHANNELS]; PIXELS];

    /// The tutorial's `run_tma_im2col` over an `inp` of `shape` whose pixel `p` holds `p + 1`.
    /// The shared tile is unswizzled: the tutorial's 128B swizzle moves elements within the
    /// tile, which its store undoes, so it does not change `out`.
    fn run_tma_im2col(
        shape: [u64; 4],
        pixel_box_lower_corner: [i32; 2],
        pixel_box_upper_corner: [i32; 2],
        coord: [i64; 4],
        offsets: [i64; 2],
    ) -> Out {
        let [n, h, w, c] = shape;
        let pixel_bytes = c * ELEM_BYTES;
        let tensor = MappedTensor {
            global_address: IMAGE_BASE,
            dims: vec![c, w, h, n],
            strides: vec![pixel_bytes, w * pixel_bytes, h * w * pixel_bytes],
            element_strides: vec![1; 4],
            elem_bytes: ELEM_BYTES,
            float_elements: true,
            swizzle: tcgen05_mma::SwizzleMode::None,
        };

        // PTX orders every coordinate innermost first: C, W, H, N.
        let [lower_h, lower_w] = pixel_box_lower_corner;
        let [upper_h, upper_w] = pixel_box_upper_corner;
        let [coord_n, coord_h, coord_w, coord_c] = coord;
        let [offset_h, offset_w] = offsets;
        let im2col = Im2colBox {
            lower_corner: vec![lower_w, lower_h],
            upper_corner: vec![upper_w, upper_h],
            channels_per_pixel: CHANNELS as u32,
            pixels_per_column: PIXELS as u32,
        };
        let layout = tcgen05_mma::MatrixDescriptor {
            start_addr: TILE_BASE,
            leading_dim_byte_offset: 0,
            stride_dim_byte_offset: pixel_bytes,
            base_offset: 0,
            absolute_leading_stride: false,
            lut_b_offset: false,
            swizzle_mode: tcgen05_mma::SwizzleMode::None,
        };

        let elements = im2col_elements(
            ThreadId(0),
            InstrId(0),
            &tensor,
            &im2col,
            &[coord_c, coord_w, coord_h, coord_n],
            &[offset_w, offset_h],
            &layout,
        )
        .unwrap();

        let mut out = [[None; CHANNELS]; PIXELS];
        for element in elements {
            let value = match element.global {
                Some(addr) => (addr - IMAGE_BASE) / pixel_bytes + 1,
                None => 0,
            };
            let slot = ((element.shared - TILE_BASE) / ELEM_BYTES) as usize;
            let previous = out[slot / CHANNELS][slot % CHANNELS].replace(value);
            assert_eq!(previous, None, "two elements land in out slot {slot}");
        }

        out.map(|row| row.map(|value| value.expect("every out slot is loaded")))
    }

    /// `inp.reshape(16, 32)` of the tutorial's one-image `inp`.
    fn inp_reshaped() -> Out {
        std::array::from_fn(|pixel| [pixel as u64 + 1; CHANNELS])
    }

    /// Example 1 <https://github.com/triton-lang/triton/blob/cd772b3da9d343ea690f1c5daea020083503fd03/python/tutorials/gluon/13-conv-im2col.py#L313-L321>
    /// Input: inp [1, 4, 4, 32], lower/upper corner [0, 0]/[0, 0], coord [0, 0, 0, 0], offsets [0, 0]
    /// Expected: out == inp.reshape(16, 32)
    #[test]
    fn test_tma_im2col_simple() {
        let out = run_tma_im2col([1, 4, 4, 32], [0, 0], [0, 0], [0, 0, 0, 0], [0, 0]);
        assert_eq!(out, inp_reshaped());
    }

    /// Example 2 <https://github.com/triton-lang/triton/blob/cd772b3da9d343ea690f1c5daea020083503fd03/python/tutorials/gluon/13-conv-im2col.py#L394-L404>
    /// Input: inp [1, 4, 4, 32], lower/upper corner [-1, -1]/[-1, -1], coord [0, -1, -1, 0], offsets [0, 0]
    /// Expected: out[:, 0] == [0, 0, 0, 0, 0, 1, 2, 3, 0, 5, 6, 7, 0, 9, 10, 11]
    #[test]
    fn test_tma_im2col_padded() {
        let out = run_tma_im2col([1, 4, 4, 32], [-1, -1], [-1, -1], [0, -1, -1, 0], [0, 0]);
        let expected = [0, 0, 0, 0, 0, 1, 2, 3, 0, 5, 6, 7, 0, 9, 10, 11];
        assert_eq!(out.map(|row| row[0]), expected);
    }

    /// Example 3 <https://github.com/triton-lang/triton/blob/cd772b3da9d343ea690f1c5daea020083503fd03/python/tutorials/gluon/13-conv-im2col.py#L493-L502>
    /// Input: inp [1, 4, 4, 32], lower/upper corner [-1, -1]/[-1, -1], coord [0, -1, -1, 0], offsets [1, 1]
    /// Expected: out == inp.reshape(16, 32)
    #[test]
    fn test_tma_im2col_offset() {
        let out = run_tma_im2col([1, 4, 4, 32], [-1, -1], [-1, -1], [0, -1, -1, 0], [1, 1]);
        assert_eq!(out, inp_reshaped());
    }

    /// Example 4 <https://github.com/triton-lang/triton/blob/cd772b3da9d343ea690f1c5daea020083503fd03/python/tutorials/gluon/13-conv-im2col.py#L581-L616>
    /// Input: inp [2, 4, 4, 32], lower/upper corner [0, 0]/[0, 0], coord [0, 1, 3, 0], offsets [0, 0]
    /// Expected: out[:, 0] == [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
    #[test]
    fn test_tma_im2col_multi_batch() {
        let out = run_tma_im2col([2, 4, 4, 32], [0, 0], [0, 0], [0, 1, 3, 0], [0, 0]);
        let expected = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];
        assert_eq!(out.map(|row| row[0]), expected);
    }

    /// Example 5 <https://github.com/triton-lang/triton/blob/cd772b3da9d343ea690f1c5daea020083503fd03/python/tutorials/gluon/13-conv-im2col.py#L712-L746>
    /// Input: inp [2, 4, 4, 32], lower/upper corner [-1, -1]/[-1, -1], coord [0, 1, 2, 0], offsets [0, 0]
    /// Expected: out[:, 0] == [7, 0, 9, 10, 11, 0, 0, 0, 0, 0, 17, 18, 19, 0, 21, 22]
    #[test]
    fn test_tma_im2col_multi_batch_padded() {
        let out = run_tma_im2col([2, 4, 4, 32], [-1, -1], [-1, -1], [0, 1, 2, 0], [0, 0]);
        let expected = [7, 0, 9, 10, 11, 0, 0, 0, 0, 0, 17, 18, 19, 0, 21, 22];
        assert_eq!(out.map(|row| row[0]), expected);
    }
}
