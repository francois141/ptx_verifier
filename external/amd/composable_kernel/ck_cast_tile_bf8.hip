// CK Tile's cast_tile<bf8_t> (5a74dec) encodes with the fp8 (E4M3) builtin, so its bf8 (E5M2)
// tile holds fp8 codes: 1.0 becomes 0x38 instead of 0x3c.
#include "ck_tile/core.hpp"

using namespace ck_tile;

// 64 work-items, four elements each: cast_tile's packed path needs a multiple of four.
using FourPerLane = tile_distribution_encoding<sequence<>, tuple<sequence<64, 4>>,
                                               tuple<sequence<1>>, tuple<sequence<0>>,
                                               sequence<1>, sequence<1>>;

// `y` only makes the compiler initialize the half of the word the first conversion keeps.
extern "C" __global__ void ck_cast_tile_bf8(float x, float y, float* b)
{
    const unsigned lane = __builtin_amdgcn_workitem_id_x();
    auto tile = make_static_distributed_tensor<float>(make_static_tile_distribution(FourPerLane{}));
    set_tile(tile, x);
    tile.get_thread_buffer()[1] = y;
    b[lane] = bit_cast<uint8_t>(cast_tile<bf8_t>(tile).get_thread_buffer()[0]);
}

// The conversion cast_tile<bf8_t> should use.
extern "C" __global__ void ck_cast_tile_bf8_fixed(float x, float* b)
{
    const unsigned lane = __builtin_amdgcn_workitem_id_x();
    b[lane] = __builtin_amdgcn_cvt_pk_bf8_f32(x, x, 0, false) & 0xff;
}
