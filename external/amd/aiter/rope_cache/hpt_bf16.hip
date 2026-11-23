// Verbatim copy of fused_qk_rope_concat_and_cache_mla_seg_kernel (csrc/kernels/cache_kernels.cu lines
// 2554-3292, Aiter 183a6ce) instantiated as launch_mla_rope_hpt picks it on gfx950 for a small decode
// (T*H/num_CUs < 12 -> HPT 1, LAT, K_EARLY, NOPE_EARLY), bf16, kv_cache/q_out bf16, NeoX, nope first.
#define AITER_NO_TORCH_TYPES
#include "prelude.h"
#include "aiter_hip_common.h"
#include "attention_dtypes.h"
#include "opus/opus.hpp"
#include "aiter_opus_plus.h"
// ockl's __umulhi, which -nogpulib omits.
extern "C" __device__ unsigned int __ockl_mul_hi_u32(unsigned int a, unsigned int b) { return (unsigned int)(((unsigned long long)a * b) >> 32); }
namespace aiter {
#ifndef AITER_MLA_SEG_TDM_HPT_MASK
#define AITER_MLA_SEG_TDM_HPT_MASK 0x114
#endif

//
// PAGE_SIZE == 0 selects the plain per-entry layout of
// fused_qk_rope_concat_and_cache_mla instead (runtime block_size/entry_stride,
// entry = [nope | pe], or [pe | nope] when !NOPE_FIRST; q_out rows likewise).
// An output whose type equals the input's is stored unscaled, as kAuto.
//
// LAT selects the latency-floor form one head per block has always used --
// direct Q loads, the padded-token return deferred past them, the cos/sin row
// in the buffer offset -- so that the per-entry layout can also run it at two
// or four heads per block for mid-size launches.
//
// !ROPE is the identity rotation (cos 1, sin 0, a model without positional
// encoding): positions and the cos/sin caches are not read, and pe is only
// converted.
template <typename scalar_t, typename cache_t, typename query_t, int KV_LORA, int PE_DIM,
          int PAGE_SIZE, bool IS_NEOX, bool NOPE_FIRST, int VEC, int HPT,
          bool COMPUTE_ALL_Q_ROPE = false, bool K_EARLY = (HPT <= 2),
          bool LAT = (HPT == 1), bool NOPE_EARLY = LAT, bool ROPE = true>
__global__ void fused_qk_rope_concat_and_cache_mla_seg_kernel(
    // The first 120 bytes of kernel arguments are preloaded into SGPRs; the
    // rest cost a scalar round trip. Preloaded: what addresses the nope loads,
    // which the latency path issues before any other load, and the token
    // divide.
    const scalar_t* __restrict__ q_nope,    // [T, H, KV_LORA]
    const int64_t q_nope_stride_0, const int64_t q_nope_stride_1,
    const int num_tokens,
    const uint32_t tok_magic, // blockIdx.x / num_tokens, see mla_rope_fast_div
    const int tok_shift,
    // Every dword argument is preloaded too: one past the preloaded ones
    // gets a load of its own, which the compiler placed behind a wait on one
    // path and ahead of the nope loads on another.
    const int max_position,
    const int num_heads,
    const scalar_t* __restrict__ q_pe,      // [T, H, PE_DIM]
    const scalar_t* __restrict__ kv_c,      // [T, KV_LORA]
    const scalar_t* __restrict__ k_pe,      // [T, PE_DIM]
    cache_t* __restrict__ kv_cache,         // flat [num_blocks, block_stride]
    query_t* __restrict__ q_out,            // [T, H, Q_OUT_DIM]
    const int64_t* __restrict__ slot_mapping,
    const int64_t* __restrict__ positions,
    const float* __restrict__ q_scale,
    const float* __restrict__ k_scale,
    // Not preloaded: both are addressed by positions[token], so their loads
    // go out with that one.
    const scalar_t* __restrict__ cos_cache, // [max_pos, PE_DIM/2]
    const scalar_t* __restrict__ sin_cache, // [max_pos, PE_DIM/2]
    const int64_t q_pe_stride_0,   const int64_t q_pe_stride_1,
    const int64_t q_out_stride_0,  const int64_t q_out_stride_1,
    const int64_t kv_c_stride,
    const int64_t k_pe_stride,
    const int64_t cos_stride0,
    const int64_t sin_stride0,
    const int64_t block_stride,
    const int64_t entry_stride = 0,
    const int block_size = PAGE_SIZE,
    const uint32_t bs_magic = 0, // slot / block_size
    const int bs_shift = 0)
{
    constexpr int HALF    = PE_DIM / 2;
    constexpr int NUM_VEC = KV_LORA / VEC; // nope vectors per row
    constexpr int NOPE_OFF = NOPE_FIRST ? 0 : PE_DIM;
    constexpr int PE_OFF   = NOPE_FIRST ? KV_LORA : 0;
    static_assert(PAGE_SIZE == 0 || NOPE_FIRST, "the segmented layout is nope-first");
    using in_vec_t  = opus::vector_t<scalar_t, VEC>;
    using out_vec_t = opus::vector_t<cache_t, VEC>;
    using q_vec_t   = opus::vector_t<query_t, VEC>;
    // A template parameter: tested at run time it cost ~3% at eight heads per
    // block (H=128 T=1536), even when false.
    constexpr bool compute_all_q_rope = COMPUTE_ALL_Q_ROPE;
    static_assert(PAGE_SIZE == 0 || !COMPUTE_ALL_Q_ROPE);
    auto cvt_vec = [](const in_vec_t& v, float inv_scale, auto* out) {
        using out_t = std::remove_cv_t<std::remove_pointer_t<decltype(out)>>;
        if constexpr(std::is_same_v<out_t, scalar_t>)
            return v;
        else
            return aiter::scaled_cast<out_t>(v, inv_scale);
    };

    // Two-dimensional grid so the coordinates arrive directly. A flat grid has
    // to divide and modulo by num_heads, which is a runtime value, and
    // token_idx heads every address chain in the block -- so that divide sits
    // at the front of the critical path, once per block, across T*H blocks.
    // x is the head so that consecutive blocks stay within one token and keep
    // sharing its slot, position and cos/sin row, which is the order the flat
    // grid already produced.
    //
    // The per-entry layout (PAGE_SIZE == 0) runs a flat grid, head-group
    // major: block = group * T + token. Consecutive blocks round-robin over
    // the XCDs, and token-major put every K-writing (group 0) block on one
    // XCD whenever H / HPT is a multiple of 8 (H=16 T=1536 7.50 -> 6.62 us,
    // H=128 T=192 7.14 -> 6.25 us). The grid stays one-dimensional because a
    // tall grid dispatches slower (T=1 H=16: 3.34 us as 1 x 16, 3.22 as
    // 16 x 1), and the divide by T is a host-built magic multiply, kept off
    // the front of every block's address chain.
    static_assert(LAT == (HPT == 1) || PAGE_SIZE == 0);
    int64_t token_idx;
    int     head_base;
    if constexpr(PAGE_SIZE == 0)
    {
        const uint32_t bid   = blockIdx.x;
        const uint32_t group = (__umulhi(bid, tok_magic) + bid) >> tok_shift;
        token_idx            = bid - group * static_cast<uint32_t>(num_tokens);
        head_base            = group * HPT;
    }
    else
    {
        token_idx = blockIdx.y;
        head_base = blockIdx.x * HPT;
    }

    // One descriptor over the HPT heads, the head picked by soffset. Each
    // head needs its own soffset SGPR: a buffer op that reuses an address
    // register of an in-flight one waits (s_wait_xcnt) for its address
    // translation, which serializes the cold loads behind TLB misses.
    // The loads need only preloaded arguments, so with NOPE_EARLY they go out
    // ahead of the slot and position loads, not behind their round trip; the
    // memory clobber keeps those loads from being hoisted above. That pays
    // with few blocks per CU and costs with many, see
    // mla_rope_entry_heads_per_block.
    static_assert(LAT || !NOPE_EARLY);
    in_vec_t nope_in[HPT];
    auto issue_nope = [&]() {
        auto in_buf = opus::make_gmem<scalar_t>(
            q_nope + token_idx * q_nope_stride_0 + head_base * q_nope_stride_1,
            (static_cast<int>((HPT - 1) * q_nope_stride_1) + KV_LORA) * sizeof(scalar_t));
        int soff[HPT];
#pragma unroll
        for(int k = 0; k < HPT; ++k)
        {
            soff[k] = static_cast<int>(k * q_nope_stride_1 * sizeof(scalar_t));
#if defined(__HIP_DEVICE_COMPILE__)
            if(k > 0)
                asm volatile("" : "+s"(soff[k]));
#endif
        }
#pragma unroll
        for(int k = 0; k < HPT; ++k)
            nope_in[k] = in_buf.template _load<VEC>(
                static_cast<int>(threadIdx.x * VEC * sizeof(scalar_t)), soff[k]);
#if defined(__HIP_DEVICE_COMPILE__)
#pragma unroll
        for(int k = 1; k < HPT; ++k)
            asm volatile("" ::"s"(soff[k]));
#endif
    };
    if constexpr(NOPE_EARLY)
    {
        issue_nope();
#if defined(__HIP_DEVICE_COMPILE__)
        asm volatile("" ::: "memory");
#endif
    }

    // The slot only gates the writes. Every Q load is addressed from
    // token/head alone and stays in bounds for a padded token too, so on the
    // one-head-per-block path -- on its latency floor -- the early return waits
    // until they are issued: taken first, it held every Q load behind the
    // slot_mapping round trip (H=16 T=192 -8.3%, H=32 T=192 -7.3%). With more
    // heads per block the op is bandwidth-bound, and deferring it measured ~1%
    // slower there, so that path returns up front as before.
    const int64_t slot_idx = slot_mapping[token_idx];
    // compute_all_q_rope (DCP) keeps a padded token's Q; only K is skipped.
    if constexpr(!LAT)
    {
        if(slot_idx < 0 && !compute_all_q_rope)
            return; // uniform across the block (same token)
    }

    // cos/sin are read at <buf>[<row> + i]; <end> is an offset past the buffer.
    // A padded token reaches this on the one-head path and may carry a stale
    // position, so there the descriptors span the whole cache with the row in
    // the offset: the hardware range check then covers the row too, and any
    // position reads in bounds or not at all. Clamping it instead cost that
    // path 3-5% (H=16/32 T=192), and gating it on the slot would put the slot
    // round trip back in front of the cos/sin loads. With more heads per block
    // a padded token has already returned, and a per-row descriptor keeps the
    // row offset scalar (~2% at H=128 T=1536).
    int64_t pos = ROPE ? positions[token_idx] : 0;
#if defined(__HIP_DEVICE_COMPILE__)
    // One scalar round trip for everything the Q addresses need: the
    // compiler otherwise issued the stride kernargs after waiting on
    // positions[token], a second trip in front of every Q load.
    if constexpr(LAT && PAGE_SIZE == 0)
        asm volatile("" ::"s"(pos), "s"(slot_idx), "s"(q_nope_stride_0), "s"(q_nope_stride_1),
                     "s"(q_pe_stride_0), "s"(q_pe_stride_1), "s"(q_out_stride_0),
                     "s"(q_out_stride_1), "s"(cos_stride0), "s"(sin_stride0));
#endif
    // Clamp pos into the cos/sin cache. Padded tokens can carry stale positions.
    // Per-entry callers may pass a short cache, like a NoPE model's one identity row.
    if(PAGE_SIZE == 0 || compute_all_q_rope)
        pos = pos < 0 ? 0 : (pos >= max_position ? max_position - 1 : pos);
    const scalar_t* cos_base = cos_cache;
    const scalar_t* sin_base = sin_cache;
    int cos_row = 0, sin_row = 0, cos_end = HALF, sin_end = HALF;
    if constexpr(LAT)
    {
        cos_row = static_cast<int>(pos * cos_stride0);
        sin_row = static_cast<int>(pos * sin_stride0);
        cos_end = static_cast<int>(max_position * cos_stride0);
        sin_end = static_cast<int>(max_position * sin_stride0);
    }
    else
    {
        cos_base += pos * cos_stride0;
        sin_base += pos * sin_stride0;
    }
    auto cos_buf = opus::make_gmem<scalar_t>(cos_base, cos_end * sizeof(scalar_t));
    auto sin_buf = opus::make_gmem<scalar_t>(sin_base, sin_end * sizeof(scalar_t));

    // ---- helper: the whole pe segment, VEC elements per thread ----
    //
    // The segment is walked a chunk at a time rather than an element at a
    // time. Taken per element it costs four narrow loads and a one-byte store
    // for every 2 bytes of input, against one wide load per 8 elements on the
    // nope path; the segment is an eighth of Q's bytes and was measuring ~30%
    // of the kernel.
    //
    // Both pairings keep a chunk's operands inside one load. NEOX pairs across
    // HALF, a multiple of VEC, so a chunk's partner is a whole chunk and its
    // cos/sin indices are the chunk's own folded into the low half. GPT-J
    // pairs adjacent elements, so a chunk already holds both halves of every
    // pair and only cos/sin narrows, to VEC/2.
    constexpr int PE_CHUNKS = PE_DIM / VEC;
    static_assert(PE_DIM % VEC == 0 && HALF % VEC == 0);
    using half_vec_t = opus::vector_t<scalar_t, VEC / 2>;
    using pe_cs_t    = std::conditional_t<IS_NEOX, in_vec_t, half_vec_t>;

    // Issue and consume are split so the caller can put the segment's loads in
    // front of the nope pass. Every operand address is known as soon as the
    // token is -- pe from the row, cos/sin from positions[token] -- so nothing
    // here has to wait for nope, and the four loads then overlap it instead of
    // starting a fresh dependency chain after it.
    // With more than one head per block the NEOX partner chunk is taken
    // across lanes (see rope_pe_emit); with one, the op is on its latency
    // floor and a second parallel load beats waiting on x to exchange it
    // (H=32 T=192: +0.7% exchanged, against -6..-8.5% at HPT > 1).
    constexpr bool PE_EXCHANGE = IS_NEOX && HPT > 1;
    struct PeOperands
    {
        in_vec_t x, y;
        pe_cs_t c, s;
    };

    // `active` masks like rope_pe_emit's: an inactive lane reads past
    // num_records, which returns zero without touching the cache -- no branch,
    // and no extra requests either (clamping to a live row instead cost the
    // one-head path eight times its pe loads).
    //
    // pe_ptr is the wave's first head row and row_off (elements) the lane's
    // own row within the `extent` elements after it. The buffer descriptor has
    // to stay wave-uniform: built from a lane-derived head, it landed in VGPRs
    // and the compiler wrapped every access in a readfirstlane waterfall loop.
    auto rope_pe_issue = [&](const scalar_t* pe_ptr, int row_off, int extent, int chunk,
                             bool active) -> PeOperands {
        PeOperands o{};
        const int d0 = chunk * VEC;
        auto pe_buf  = opus::make_gmem<scalar_t>(pe_ptr, extent * sizeof(scalar_t));
        o.x = pe_buf.template load<VEC>(active ? row_off + d0 : extent);
        if constexpr(!ROPE) {}
        else if constexpr(IS_NEOX)
        {
            const int cidx = d0 < HALF ? d0 : d0 - HALF;
            if constexpr(!PE_EXCHANGE)
                o.y = pe_buf.template load<VEC>(active ? row_off + (d0 ^ HALF) : extent);
            o.c = cos_buf.template load<VEC>(active ? cos_row + cidx : cos_end);
            o.s = sin_buf.template load<VEC>(active ? sin_row + cidx : sin_end);
        }
        else
        {
            o.c = cos_buf.template load<VEC / 2>(active ? cos_row + d0 / 2 : cos_end);
            o.s = sin_buf.template load<VEC / 2>(active ? sin_row + d0 / 2 : sin_end);
        }
        return o;
    };
    // Same row_off / extent convention as rope_pe_issue.

    // `active` masks the store without touching EXEC: an inactive lane writes
    // at PE_DIM, past the buffer's num_records, which the hardware drops. A
    // divergent `if` here put s_and_saveexec right behind the nope store, and
    // EXEC being an operand of that in-flight store it had to drain the whole
    // address queue first -- s_wait_xcnt, 18% of the wave at H=32 T=192 in ATT.
    // The rotated, converted chunk. `exchange` (a constant at every call)
    // takes the NEOX partner across lanes rather than from o.y.
    auto rope_pe_calc = [&](const PeOperands& o, auto* out_tag, float inv_scale, int chunk,
                            bool exchange) {
        using o_t = std::remove_pointer_t<decltype(out_tag)>;
        using o_vec_t = opus::vector_t<o_t, VEC>;
        auto cvt = [](float r, float s) -> o_t {
            if constexpr(std::is_same_v<o_t, opus::fp8_t>)
                return opus::cast<o_t>(r * s);
            else
                return static_cast<o_t>(r);
        };
        const int d0 = chunk * VEC;
        o_vec_t vout;
        if constexpr(!ROPE)
        {
#pragma unroll
            for(int i = 0; i < VEC; ++i)
                vout[i] = cvt(static_cast<float>(o.x[i]), inv_scale);
        }
        else if constexpr(IS_NEOX)
        {
            // The partner chunk is the one lane chunk^HALF/VEC already loaded
            // -- the same 128 B row -- so take it across lanes instead of
            // reading it again. Loaded twice, it went to GL2 as a second
            // 128 B request per head (34% of read requests at H=128, against
            // 4 x 256 B for the nope row). Done here rather than at issue so
            // the exchange does not force a wait on x before the nope loads go
            // out. Partners share a PE_CHUNKS-lane group on every caller.
            in_vec_t y = o.y;
            if(PE_EXCHANGE && exchange)
            {
                constexpr int PARTNER = HALF / VEC;
                using u32x4 = uint32_t __attribute__((ext_vector_type(4)));
                static_assert(sizeof(in_vec_t) == sizeof(u32x4));
                const u32x4 xw = __builtin_bit_cast(u32x4, o.x);
                u32x4 yw;
#pragma unroll
                for(int w = 0; w < 4; ++w)
                    yw[w] = static_cast<uint32_t>(
                        __shfl_xor(static_cast<int>(xw[w]), PARTNER, PE_CHUNKS));
                y = __builtin_bit_cast(in_vec_t, yw);
            }
            const bool low   = d0 < HALF;
#pragma unroll
            for(int i = 0; i < VEC; ++i)
            {
                const float xv = static_cast<float>(o.x[i]);
                const float yv = static_cast<float>(y[i]);
                const float cv = static_cast<float>(o.c[i]);
                const float sv = static_cast<float>(o.s[i]);
                const float r  = low ? (xv * cv - yv * sv) : (xv * cv + yv * sv);
                vout[i]        = cvt(r, inv_scale);
            }
        }
        else
        {
#pragma unroll
            for(int k = 0; k < VEC / 2; ++k)
            {
                const float a  = static_cast<float>(o.x[2 * k]);
                const float b  = static_cast<float>(o.x[2 * k + 1]);
                const float cv = static_cast<float>(o.c[k]);
                const float sv = static_cast<float>(o.s[k]);
                vout[2 * k]     = cvt(a * cv - b * sv, inv_scale);
                vout[2 * k + 1] = cvt(b * cv + a * sv, inv_scale);
            }
        }
        return vout;
    };
    auto rope_pe_emit = [&](const PeOperands& o, auto* out_ptr, int row_off, int extent,
                            float inv_scale, int chunk, bool active) {
        using o_t     = std::remove_pointer_t<decltype(out_ptr)>;
        using o_vec_t = opus::vector_t<o_t, VEC>;
        auto out_buf  = opus::make_gmem<o_t>(out_ptr, extent * sizeof(o_t));
        out_buf.template store<VEC, o_vec_t>(rope_pe_calc(o, out_ptr, inv_scale, chunk, true),
                                             active ? row_off + chunk * VEC : extent);
    };

    auto rope_pe_seg = [&](const scalar_t* pe_ptr, cache_t* out_ptr, float inv_scale) {
        if(threadIdx.x < PE_CHUNKS)
            rope_pe_emit(rope_pe_issue(pe_ptr, 0, PE_DIM, threadIdx.x, true), out_ptr, 0,
                         PE_DIM, inv_scale, threadIdx.x, true);
    };

    // K_EARLY: K's loads go out with Q's, so the K block pays one memory
    // round trip rather than a second one after its Q stores. That wins while
    // the op is latency-bound (H=16 T=192 4.24 -> 3.47 us, H=128 T=32 4.15 ->
    // 3.52 us); once it is bandwidth-bound the registers they hold cost more
    // (+5..8% at eight heads, +10% at two heads with 64 rows per CU).
    in_vec_t k_nope_in{};
    PeOperands k_pe_op{};
    if(K_EARLY && head_base == 0) // uniform
    {
        auto in_buf = opus::make_gmem<scalar_t>(kv_c + token_idx * kv_c_stride,
                                                KV_LORA * sizeof(scalar_t));
        k_nope_in   = in_buf.template load<VEC>(threadIdx.x * VEC);
        k_pe_op     = rope_pe_issue(k_pe + token_idx * k_pe_stride, 0, PE_DIM,
                                    threadIdx.x % PE_CHUNKS, threadIdx.x < PE_CHUNKS);
    }

    // ================= Q (HPT heads per block) =================
    //
    // The block is one thread per nope vector, so a thread carries a single
    // 16 B load per head. With one head per block that is all it ever has in
    // flight, which is far short of what it takes to cover memory latency on
    // this part: a plain bf16->fp8 cast of the same footprint runs ~1.7x
    // faster. So each block takes HPT heads of one token and issues every
    // head's nope and pe loads before consuming any -- HPT independent 16 B
    // requests per thread instead of one. The head index comes from blockIdx
    // and the unrolled loop counter, so it stays scalar; widening the block
    // with more threads instead made it thread-derived, pushed the address
    // chain into VGPRs and measured slower at every width.
#if defined(__gfx1250__) || defined(__gfx1250_strict__)
    // gfx1250: stage Q through the tensor engine, within the three tensor ops
    // a wave can hold in flight. A wave consumes only what it staged, so there
    // is no block barrier, just the tensor wait. The host sizes the dynamic
    // LDS to match (two waves x WAVE_ELEMS, the same for both layouts at
    // eight heads).
    //
    // Per-entry layout, eight heads, contiguous q_out rows: each wave owns
    // four whole heads -- a nope tile (512 x 4) and a pe tile (64 x 4) --
    // converts them in place into q_out's row layout, and stores from there
    // in address order, nine contiguous 256 B runs. Stored per head (nope by
    // column, pe by chunk), the 576-element rows split their 128 B lines
    // across stores and waves, and GL2 sent 3.6x the write requests and 1.8x
    // the reads to memory (H=128 T=4096 68.3 -> 59.8 us, T=1536 26.4 -> 24.7
    // us).
    if constexpr(!LAT && ((AITER_MLA_SEG_TDM_HPT_MASK >> HPT) & 1) != 0)
    {
        if(PAGE_SIZE == 0 && HPT == 8 && q_out_stride_1 == KV_LORA + PE_DIM)
        {
            if constexpr(PAGE_SIZE == 0 && HPT == 8)
            {
                static_assert(sizeof(query_t) <= sizeof(scalar_t));
                constexpr int W          = 32;
                constexpr int ROWS       = HPT / 2;
                constexpr int ROW        = KV_LORA + PE_DIM;
                constexpr int WAVE_ELEMS = ROWS * ROW;
                constexpr int ROW_CH     = ROW / VEC; // output chunks per head
                static_assert(NUM_VEC == 2 * W && ROWS * PE_CHUNKS == W &&
                              ROWS * ROW_CH % W == 0);
                extern __shared__ char mla_seg_lds[];
                using NopeWin = opus::tdm<scalar_t, opus::seq<KV_LORA, ROWS>>;
                using PeWin   = opus::tdm<scalar_t, opus::seq<PE_DIM, ROWS>>;
#if defined(__HIP_DEVICE_COMPILE__)
                const int wave = __builtin_amdgcn_readfirstlane(threadIdx.x / W);
#else
                const int wave = threadIdx.x / W;
#endif
                const int wave_head = head_base + wave * ROWS;
                const opus::u32_t lds_base =
                    static_cast<opus::u32_t>(reinterpret_cast<__UINTPTR_TYPE__>(mla_seg_lds));
                const opus::u32_t wave_off = static_cast<opus::u32_t>(wave * WAVE_ELEMS);

                auto wn =
                    opus::make_tdm<NopeWin>(lds_base, q_nope + token_idx * q_nope_stride_0,
                                            KV_LORA, num_heads, q_nope_stride_1, 0, wave_head);
                wn.async_load(wave_off);
                auto wp = opus::make_tdm<PeWin>(lds_base, q_pe + token_idx * q_pe_stride_0, PE_DIM,
                                                num_heads, q_pe_stride_1, 0, wave_head);
                wp.async_load(wave_off + ROWS * KV_LORA);

                // cos/sin go the ordinary way, issued while the tiles are in flight.
                const int lane     = threadIdx.x % W;
                const int pe_r     = lane / PE_CHUNKS;
                const int pe_chunk = lane % PE_CHUNKS;
                const int d0       = pe_chunk * VEC;
                PeOperands pe_op{};
                if constexpr(!ROPE) {}
                else if constexpr(IS_NEOX)
                {
                    const int cidx = d0 < HALF ? d0 : d0 - HALF;
                    pe_op.c        = cos_buf.template load<VEC>(cos_row + cidx);
                    pe_op.s        = sin_buf.template load<VEC>(sin_row + cidx);
                }
                else
                {
                    pe_op.c = cos_buf.template load<VEC / 2>(cos_row + d0 / 2);
                    pe_op.s = sin_buf.template load<VEC / 2>(sin_row + d0 / 2);
                }
                const float inv_qscale = 1.0f / (*q_scale);
                opus::s_wait_tensorcnt<0>();

                const __UINTPTR_TYPE__ lds =
                    reinterpret_cast<__UINTPTR_TYPE__>(mla_seg_lds) + wave_off * sizeof(scalar_t);
                auto lds_in = [&](int elem) -> in_vec_t {
                    return *reinterpret_cast<const OPUS_LDS_ADDR in_vec_t*>(
                        lds + elem * sizeof(scalar_t));
                };
                auto lds_out = [&](int elem) -> OPUS_LDS_ADDR q_vec_t* {
                    return reinterpret_cast<OPUS_LDS_ADDR q_vec_t*>(lds + elem * sizeof(query_t));
                };
                // Lane chunk i * W + lane of the nope tile: head i / 2, a whole row
                // per two chunks since NUM_VEC == 2 * W.
                in_vec_t nope_in[2 * ROWS];
#pragma unroll
                for(int i = 0; i < 2 * ROWS; ++i)
                    nope_in[i] = lds_in((i / 2) * KV_LORA + ((i % 2) * W + lane) * VEC);
                pe_op.x = lds_in(ROWS * KV_LORA + pe_r * PE_DIM + d0);
                if constexpr(IS_NEOX)
                    pe_op.y = lds_in(ROWS * KV_LORA + pe_r * PE_DIM + (d0 ^ HALF));
                // Every staged read precedes the first in-place write.
#pragma unroll
                for(int i = 0; i < 2 * ROWS; ++i)
                    *lds_out((i / 2) * ROW + NOPE_OFF + ((i % 2) * W + lane) * VEC) =
                        cvt_vec(nope_in[i], inv_qscale, q_out);
                *lds_out(pe_r * ROW + PE_OFF + d0) =
                    rope_pe_calc(pe_op, q_out, inv_qscale, pe_chunk, false);

                // The rows are contiguous, so chunk j of the wave's heads, at LDS
                // element j * VEC, goes to the same offset in q_out.
                auto out_buf =
                    opus::make_gmem<query_t>(q_out + token_idx * q_out_stride_0 + wave_head * ROW,
                                             ROWS * ROW * sizeof(query_t));
#pragma unroll
                for(int i = 0; i < ROWS * ROW_CH / W; ++i)
                    out_buf.template store<VEC, q_vec_t>(*lds_out((i * W + lane) * VEC),
                                                         (i * W + lane) * VEC);
            }
        }
        // Otherwise each wave owns half the nope columns of every head plus up
        // to four heads' pe rows, as two tiles (256 x HPT and 64 x PE_ROWS).
        // Two heads a wave are too few for the in-order store to pay (H=16
        // T=1536, H=128 T=192: +4..5%), and padded rows break the address
        // order, leaving the staging pure latency (768-wide rows, H=128
        // T=4096: 72.1 us against 68.9 per head). The segmented layout's
        // q_out is padded, and even the untaken branch cost it 1.5..3%.
        else
        {
            constexpr int W          = 32;
            constexpr int COLS       = KV_LORA / 2;
            // pe lanes are threadIdx.x / PE_CHUNKS, so a wave's 32 lanes carry at
            // most four heads' pe: all of them in wave 0 for HPT <= 4, four each
            // for HPT == 8.
            constexpr int PE_ROWS    = HPT < 4 ? HPT : 4;
            constexpr int WAVE_ELEMS = HPT * COLS + PE_ROWS * PE_DIM;
            static_assert(NUM_VEC == 2 * W && COLS == W * VEC && 4 * PE_CHUNKS == W);
            extern __shared__ char mla_seg_lds[];
            using NopeWin = opus::tdm<scalar_t, opus::seq<COLS, HPT>>;
            using PeWin   = opus::tdm<scalar_t, opus::seq<PE_DIM, PE_ROWS>>;
#if defined(__HIP_DEVICE_COMPILE__)
            const int wave = __builtin_amdgcn_readfirstlane(threadIdx.x / W);
#else
            const int wave = threadIdx.x / W;
#endif
            const opus::u32_t lds_base =
                static_cast<opus::u32_t>(reinterpret_cast<__UINTPTR_TYPE__>(mla_seg_lds));
            const opus::u32_t wave_off = static_cast<opus::u32_t>(wave * WAVE_ELEMS);

            auto wn = opus::make_tdm<NopeWin>(lds_base, q_nope + token_idx * q_nope_stride_0,
                                              KV_LORA, num_heads, q_nope_stride_1,
                                              wave * COLS, head_base);
            wn.async_load(wave_off);
            const bool wave_has_pe = wave * PE_ROWS < HPT;
            if(wave_has_pe)
            {
                auto wp = opus::make_tdm<PeWin>(lds_base, q_pe + token_idx * q_pe_stride_0,
                                                PE_DIM, num_heads, q_pe_stride_1,
                                                0, head_base + wave * PE_ROWS);
                wp.async_load(wave_off + HPT * COLS);
            }

            // cos/sin go the ordinary way, issued while the tiles are in flight.
            const int pe_row   = (threadIdx.x % W) / PE_CHUNKS;
            const int pe_chunk = threadIdx.x % PE_CHUNKS;
            const int d0       = pe_chunk * VEC;
            PeOperands pe_op{};
            if constexpr(!ROPE) {}
            else if constexpr(IS_NEOX)
            {
                const int cidx = d0 < HALF ? d0 : d0 - HALF;
                pe_op.c        = cos_buf.template load<VEC>(cos_row + cidx);
                pe_op.s        = sin_buf.template load<VEC>(sin_row + cidx);
            }
            else
            {
                pe_op.c = cos_buf.template load<VEC / 2>(cos_row + d0 / 2);
                pe_op.s = sin_buf.template load<VEC / 2>(sin_row + d0 / 2);
            }
            const float inv_qscale = 1.0f / (*q_scale);
            opus::s_wait_tensorcnt<0>();
            // One head per block defers the padded-token return until the loads
            // are out (see slot_idx); it must also wait for them, or the block
            // could retire with a tensor DMA still writing its LDS.
            if constexpr(HPT == 1)
            {
                if(slot_idx < 0 && !compute_all_q_rope)
                    return;
            }

            const __UINTPTR_TYPE__ lds = reinterpret_cast<__UINTPTR_TYPE__>(mla_seg_lds);
            auto lds_vec = [&](int elem) -> in_vec_t {
                return *reinterpret_cast<const OPUS_LDS_ADDR in_vec_t*>(
                    lds + static_cast<__UINTPTR_TYPE__>(wave_off + elem) * sizeof(scalar_t));
            };
            const int col = (threadIdx.x % W) * VEC;
            // Every head is converted before any is stored. Converted and stored
            // one at a time, each head's store data landed in the registers the
            // next head's was about to use, and the wave sat in s_wait_xcnt behind
            // every store until the memory pipe had read it out.
            q_vec_t nope_out[HPT];
#pragma unroll
            for(int k = 0; k < HPT; ++k)
                nope_out[k] = cvt_vec(lds_vec(k * COLS + col), inv_qscale, q_out);
            query_t* q_out_tok = q_out + token_idx * q_out_stride_0;
#pragma unroll
            for(int k = 0; k < HPT; ++k)
            {
                auto out_buf = opus::make_gmem<query_t>(
                    q_out_tok + (head_base + k) * q_out_stride_1 + NOPE_OFF,
                    KV_LORA * sizeof(query_t));
                out_buf.template store<VEC, q_vec_t>(nope_out[k], wave * COLS + col);
            }
            {
                const bool pe_active = wave * PE_ROWS + pe_row < HPT;
                const int  pe_r      = pe_active ? pe_row : 0; // keep the LDS read in range
                pe_op.x = lds_vec(HPT * COLS + pe_r * PE_DIM + d0);
                // Without the lane exchange rope_pe_emit reads the NEOX partner
                // from o.y; here it is the same staged row, HALF elements over.
                if constexpr(IS_NEOX && !PE_EXCHANGE)
                    pe_op.y = lds_vec(HPT * COLS + pe_r * PE_DIM + (d0 ^ HALF));
                rope_pe_emit(pe_op,
                             q_out_tok + (head_base + wave * PE_ROWS) * q_out_stride_1 + PE_OFF,
                             static_cast<int>(pe_r * q_out_stride_1),
                             static_cast<int>((PE_ROWS - 1) * q_out_stride_1) + PE_DIM,
                             inv_qscale, pe_chunk, pe_active);
            }
        }
    }
    else
#endif
    {
        const float inv_qscale = 1.0f / (*q_scale);

        // pe is spread across the block, one head per PE_CHUNKS lanes, rather
        // than every head's pe queued on lanes 0..PE_CHUNKS-1. A head's pe
        // operands are four VEC-wide vectors, and VGPRs are allocated per
        // wave however few lanes use them, so stacking HPT heads on the same
        // lanes costs 16*HPT registers for the whole wave -- the reason HPT=8
        // collapsed. Spread, each lane holds at most one head's pe whatever
        // HPT is. pe_head is lane-derived, which is fine: pe addressing was
        // per-lane already, and the nope path keeps its scalar head index.
        static_assert(HPT * PE_CHUNKS <= NUM_VEC, "pe lanes must fit in the block");
        const int pe_head  = threadIdx.x / PE_CHUNKS;
        const int pe_chunk = threadIdx.x % PE_CHUNKS;
        const bool pe_lane = pe_head < HPT;
        // Lanes past the last head are masked by offset, not by a branch: no
        // EXEC write near in-flight memory ops.
        const int pe_h     = pe_lane ? pe_head : 0;
        // A wave holding no pe lane at all skips the segment outright. The
        // test is on the wave's first lane, so it is uniform and compiles to a
        // scalar branch -- it moves SCC, not EXEC, and costs no drain. Without
        // it the one-head path's second wave ran the whole pe segment masked
        // off, which cost more than the drain saved once the grid reached
        // ~6K blocks (+2.6% at H=32 T=192).
#if defined(__HIP_DEVICE_COMPILE__)
        const bool wave_pe =
            __builtin_amdgcn_readfirstlane(static_cast<int>(threadIdx.x)) < HPT * PE_CHUNKS;
#else
        const bool wave_pe = true;
#endif
        PeOperands pe_op{};
        if(wave_pe)
            pe_op = rope_pe_issue(q_pe + token_idx * q_pe_stride_0 + head_base * q_pe_stride_1,
                                  static_cast<int>(pe_h * q_pe_stride_1),
                                  static_cast<int>((HPT - 1) * q_pe_stride_1) + PE_DIM,
                                  pe_chunk, pe_lane);

        if constexpr(!NOPE_EARLY)
            issue_nope();
        // A padded token (HPT > 1 returned up front) is dropped the same way,
        // by an out-of-bounds offset: a return here is a branch the compiler
        // may sink the nope load past, which ATT showed it doing.
        const bool q_live =
            !LAT || slot_idx >= 0 || compute_all_q_rope; // uniform over the block
        {
            const int extent = static_cast<int>((HPT - 1) * q_out_stride_1) + KV_LORA;
            auto out_buf     = opus::make_gmem<query_t>(
                q_out + token_idx * q_out_stride_0 + head_base * q_out_stride_1 + NOPE_OFF,
                extent * sizeof(query_t));
#pragma unroll
            for(int k = 0; k < HPT; ++k)
                out_buf.template store<VEC, q_vec_t>(
                    cvt_vec(nope_in[k], inv_qscale, q_out),
                    q_live ? static_cast<int>(threadIdx.x) * VEC : extent,
                    static_cast<int>(k * q_out_stride_1));
        }
        if(wave_pe)
            rope_pe_emit(pe_op,
                         q_out + token_idx * q_out_stride_0 + head_base * q_out_stride_1 +
                             PE_OFF,
                         static_cast<int>(pe_h * q_out_stride_1),
                         static_cast<int>((HPT - 1) * q_out_stride_1) + PE_DIM,
                         inv_qscale, pe_chunk, pe_lane && q_live);
    }

    // ================= K (only head 0, kv=1) =================
    // A scalar branch (SCC, not EXEC), so no WAR drain: the one-head direct
    // path no longer returns early for a padded token.
    if(head_base == 0 && slot_idx >= 0)
    {
        const float inv_kscale = 1.0f / (*k_scale);
        int64_t nope_base, rope_base;
        if constexpr(PAGE_SIZE > 0)
        {
            const int64_t block_idx    = slot_idx / PAGE_SIZE;
            const int64_t block_offset = slot_idx % PAGE_SIZE;
            nope_base = block_idx * block_stride + block_offset * KV_LORA;
            rope_base =
                block_idx * block_stride + (int64_t)PAGE_SIZE * KV_LORA + block_offset * PE_DIM;
        }
        else
        {
            int64_t block_idx, block_offset;
            if(slot_idx < (int64_t(1) << 31))
            {
                const uint32_t s = static_cast<uint32_t>(slot_idx);
                const uint32_t b = (__umulhi(s, bs_magic) + s) >> bs_shift;
                block_idx        = b;
                block_offset     = s - b * static_cast<uint32_t>(block_size);
            }
            else
            {
                block_idx    = slot_idx / block_size;
                block_offset = slot_idx % block_size;
            }
            const int64_t entry = block_idx * block_stride + block_offset * entry_stride;
            nope_base = entry + NOPE_OFF;
            rope_base = entry + PE_OFF;
        }
        auto out_buf = opus::make_gmem<cache_t>(kv_cache + nope_base, KV_LORA * sizeof(cache_t));
        if constexpr(K_EARLY)
        {
            out_buf.template store<VEC, out_vec_t>(cvt_vec(k_nope_in, inv_kscale, kv_cache),
                                                   threadIdx.x * VEC);
            rope_pe_emit(k_pe_op, kv_cache + rope_base, 0, PE_DIM, inv_kscale,
                         threadIdx.x % PE_CHUNKS, threadIdx.x < PE_CHUNKS);
        }
        else
        {
            // nope: vectorized static quant.
            const scalar_t* kv_c_row = kv_c + token_idx * kv_c_stride;
            auto in_buf = opus::make_gmem<scalar_t>(kv_c_row, KV_LORA * sizeof(scalar_t));
            in_vec_t vin = in_buf.template load<VEC>(threadIdx.x * VEC);
            out_buf.template store<VEC, out_vec_t>(cvt_vec(vin, inv_kscale, kv_cache),
                                                   threadIdx.x * VEC);

            // pe: RoPE then static quant.
            const scalar_t* k_pe_row = k_pe + token_idx * k_pe_stride;
            rope_pe_seg(k_pe_row, kv_cache + rope_base, inv_kscale);
        }
    }
}

template __global__ void fused_qk_rope_concat_and_cache_mla_seg_kernel<opus::bf16_t, opus::bf16_t, opus::bf16_t, 512, 64, 0, true, true, 8, 1, false, true, true, true, true>(
    const opus::bf16_t*, const int64_t, const int64_t, const int, const uint32_t, const int, const int, const int,
    const opus::bf16_t*, const opus::bf16_t*, const opus::bf16_t*, opus::bf16_t*, opus::bf16_t*, const int64_t*,
    const int64_t*, const float*, const float*, const opus::bf16_t*, const opus::bf16_t*, const int64_t, const int64_t,
    const int64_t, const int64_t, const int64_t, const int64_t, const int64_t, const int64_t, const int64_t,
    const int64_t, const int, const uint32_t, const int);
}
