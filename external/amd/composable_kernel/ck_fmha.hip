// CK Tile's fp32 forward attention as example/ck_tile/01_fmha/codegen/ops/fmha_fwd.py (fc2862d712,
// receipt 800) instantiates it for head dimension 64: a 64 x 64 query/key tile, row-major V and
// four waves, without masking, padding, bias, dropout or auxiliary outputs.
#define CK_TILE_FMHA_FWD_FAST_EXP2 1
#include "ck_tile/ops/fmha/block/variants.hpp"
#include "fmha_fwd.hpp"

using Data = FmhaFwdTypeConfig<FmhaFwdFp32>;

// Both GEMMs use the same 4 x 1 x 1 wave arrangement and 16 x 16 x 16 warp tiles.
using Shape = ck_tile::TileFmhaShape<
    ck_tile::sequence<64, 64, 32, 64, 32, 64>,
    ck_tile::sequence<4, 1, 1>, ck_tile::sequence<16, 16, 16>,
    ck_tile::sequence<4, 1, 1>, ck_tile::sequence<16, 16, 16>,
    true>;

// No padding, logits soft cap, bias, LSE, dropout, quantization scale, min-seqlen skip or sink.
using Traits = ck_tile::TileFmhaTraits<
    false, false, false, false, false,
    ck_tile::BlockAttentionBiasEnum::NO_BIAS,
    false, false, false, ck_tile::BlockAttentionQuantScaleEnum::NO_SCALE,
    -1, false, false>;
using Variant = ck_tile::ComposedAttention<0, CK_TILE_FMHA_FWD_FAST_EXP2>;
using Mask = ck_tile::SimplifiedGenericAttentionMask<false>;

using Problem = ck_tile::BlockFmhaPipelineProblem<
    Data::QDataType, Data::KDataType, Data::VDataType,
    Data::SaccDataType, Data::SMPLComputeDataType,
    Data::BiasDataType, Data::RandValOutputDataType, Data::LSEDataType,
    Data::PDataType, Data::OaccDataType, Data::ODataType,
    Shape, false, Variant, Mask, false, Traits>;
using Pipeline = ck_tile::BlockFmhaPipelineQRKSVS<Problem>;
using Epilogue = ck_tile::Default2DEpilogue<
    ck_tile::Default2DEpilogueProblem<Data::OaccDataType, Data::ODataType, false, false>>;
using Kernel = ck_tile::FmhaFwdKernel<Pipeline, Epilogue>;

// Instantiate the device entry make_kernel<kBlockPerCu, gfx950_t> launches; sequence lengths
// and the attention scale come from Kargs.
template __global__ void ck_tile::kentry<
    ck_tile::gfx950_t, Kernel::kBlockPerCu, Kernel, Kernel::Kargs>(Kernel::Kargs);

// The ROCm device library's definitions (ockl's workitem.cl and mul.cl), linked by hipcc.
extern "C" __device__ size_t __ockl_get_group_id(unsigned dim)
{
    return dim == 0 ? __builtin_amdgcn_workgroup_id_x()
         : dim == 1 ? __builtin_amdgcn_workgroup_id_y()
         : dim == 2 ? __builtin_amdgcn_workgroup_id_z() : 0;
}
extern "C" __device__ size_t __ockl_get_local_id(unsigned dim)
{
    return dim == 0 ? __builtin_amdgcn_workitem_id_x()
         : dim == 1 ? __builtin_amdgcn_workitem_id_y()
         : dim == 2 ? __builtin_amdgcn_workitem_id_z() : 0;
}
extern "C" __device__ unsigned __ockl_mul_hi_u32(unsigned a, unsigned b)
{
    return static_cast<unsigned>((static_cast<unsigned long long>(a) * b) >> 32);
}
