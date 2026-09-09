use std::collections::HashMap;
use std::fmt;
use std::sync::OnceLock;

use crate::ascii::{AsciiChar, AsciiSliceExt, AsciiString, ascii};

#[derive(Debug, Clone)]
pub struct InstrTrie {
    value: Option<InstrKind>,
    children: HashMap<&'static [AsciiChar], InstrTrie>,
}

impl Default for InstrTrie {
    fn default() -> Self {
        Self::new()
    }
}

impl InstrTrie {
    pub fn new() -> Self {
        Self {
            value: None,
            children: HashMap::new(),
        }
    }

    fn key_segments(key: &[AsciiChar]) -> impl Iterator<Item = &[AsciiChar]> + Clone {
        key.split(|&c| c == AsciiChar::FullStop)
    }

    fn insert_rec<I>(&mut self, mut key: I, value: InstrKind)
    where
        I: Iterator<Item = &'static [AsciiChar]>,
    {
        match key.next() {
            Some(seg) => {
                let child = self.children.entry(seg).or_default();
                child.insert_rec(key, value);
            }
            None => {
                self.value = Some(value);
            }
        }
    }

    fn insert(&mut self, key: &'static [AsciiChar], value: InstrKind) {
        self.insert_rec(Self::key_segments(key), value);
    }

    fn get_ancestor_rec<'a, I>(&self, mut key: I) -> Option<InstrKind>
    where
        I: Iterator<Item = &'a [AsciiChar]> + Clone,
    {
        let Some(seg) = key.next() else {
            return self.value;
        };

        if let Some(child) = self.children.get(&seg)
            && let Some(result) = child.get_ancestor_rec(key.clone())
        {
            return Some(result);
        }

        // A qualifier can be glued directly onto a mnemonic segment with no `.`
        // separator - that's simply how the PTX ISA names some instructions
        // (`tcgen05.wait::st`, `tcgen05.wait::ld`). Segments only split on `.`,
        // so `seg` here is the whole "wait::st" and never exactly matches a
        // registered child "wait". Retry against the substring before the
        // first `::`; the qualifier itself isn't lost by doing this -
        // `Ident::as_instr` (lex.rs) recovers it later by slicing the original
        // text at `kind.mnemonic().len()`, which lands exactly on this
        // boundary regardless of how the trie found the match.
        if let Some(colon) = seg
            .windows(2)
            .position(|w| w[0] == AsciiChar::Colon && w[1] == AsciiChar::Colon)
        {
            let stem: &[AsciiChar] = &seg[..colon];
            if let Some(child) = self.children.get(&stem)
                && let Some(result) = child.get_ancestor_rec(key)
            {
                return Some(result);
            }
        }

        // There is no value in a deeper node extending `key`; return this node's value (if any)
        self.value
    }

    pub fn get_ancestor(&self, key: &[AsciiChar]) -> Option<InstrKind> {
        self.get_ancestor_rec(Self::key_segments(key))
    }
}

/// PTX 9.1 instruction mnemonics.
///
/// This list is derived from the PTX ISA 9.1 documentation:
/// https://docs.nvidia.com/cuda/parallel-thread-execution/index.html
///
/// Instructions are organized by category as in the documentation (Section 9.7).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum InstrKind {
    // =========================================================================
    // 9.7.1 Integer Arithmetic Instructions
    // =========================================================================
    Add,
    Sub,
    Mul,
    Mad,
    Mul24,
    Mad24,
    Sad,
    Div,
    Rem,
    Abs,
    Neg,
    Min,
    Max,
    Popc,
    Clz,
    Bfind,
    Fns,
    Brev,
    Bfe,
    Bfi,
    Szext,
    Bmsk,
    Dp4a,
    Dp2a,

    // =========================================================================
    // 9.7.2 Extended-Precision Integer Arithmetic Instructions
    // =========================================================================
    AddCc, // add.cc
    Addc,
    SubCc, // sub.cc
    Subc,
    MadCc, // mad.cc
    Madc,

    // =========================================================================
    // 9.7.3 Floating-Point Instructions
    // =========================================================================
    Testp,
    Copysign,
    // add, sub, mul, mad, div, abs, neg, min, max - shared with integer
    Fma,
    Rcp,
    RcpApproxFtzF64, // rcp.approx.ftz.f64
    Sqrt,
    Rsqrt,
    RsqrtApproxFtzF64, // rsqrt.approx.ftz.f64
    Sin,
    Cos,
    Lg2,
    Ex2,
    Tanh,

    // =========================================================================
    // 9.7.4 Half Precision Floating-Point Instructions
    // =========================================================================
    // add, sub, mul, fma, neg, abs, min, max, tanh, ex2 - shared

    // =========================================================================
    // 9.7.5 Mixed Precision Floating-Point Instructions
    // =========================================================================
    // add, sub, fma - shared

    // =========================================================================
    // 9.7.6 Comparison and Selection Instructions
    // =========================================================================
    Set,
    Setp,
    Selp,
    Slct,

    // =========================================================================
    // 9.7.7 Half Precision Comparison Instructions
    // =========================================================================
    // set, setp - shared

    // =========================================================================
    // 9.7.8 Logic and Shift Instructions
    // =========================================================================
    And,
    Or,
    Xor,
    Not,
    Cnot,
    Lop3,
    Shf,
    Shl,
    Shr,

    // =========================================================================
    // 9.7.9 Data Movement and Conversion Instructions
    // =========================================================================
    Mov,
    Shfl,     // deprecated
    ShflSync, // shfl.sync
    Prmt,
    Ld,
    LdGlobalNc, // ld.global.nc
    Ldu,
    St,
    StAsync, // st.async
    StBulk,  // st.bulk
    Prefetch,
    Prefetchu,
    Applypriority,
    Discard,
    Createpolicy,
    Isspacep,
    Cvta,
    Cvt,
    CvtPack, // cvt.pack
    Mapa,
    Getctarank,

    // Asynchronous copy instructions
    CpAsync,                   // cp.async
    CpAsyncCommitGroup,        // cp.async.commit_group
    CpAsyncWaitGroup,          // cp.async.wait_group
    CpAsyncWaitAll,            // cp.async.wait_all
    CpAsyncBulk,               // cp.async.bulk
    CpAsyncBulkPrefetch,       // cp.async.bulk.prefetch
    CpAsyncBulkTensor,         // cp.async.bulk.tensor
    CpAsyncBulkPrefetchTensor, // cp.async.bulk.prefetch.tensor
    CpReduceAsyncBulk,         // cp.reduce.async.bulk
    CpReduceAsyncBulkTensor,   // cp.reduce.async.bulk.tensor
    CpAsyncMbarrierArrive,     // cp.async.mbarrier.arrive

    // Multi-memory instructions
    MultimemLdReduce,          // multimem.ld_reduce
    MultimemSt,                // multimem.st
    MultimemRed,               // multimem.red
    MultimemCpAsyncBulk,       // multimem.cp.async.bulk
    MultimemCpReduceAsyncBulk, // multimem.cp.reduce.async.bulk

    // Tensor map instructions
    TensormapReplace,      // tensormap.replace
    TensormapCpFenceproxy, // tensormap.cp_fenceproxy

    // =========================================================================
    // 9.7.10 Texture Instructions
    // =========================================================================
    Tex,
    Tld4,
    Txq,
    Istypep,

    // =========================================================================
    // 9.7.11 Surface Instructions
    // =========================================================================
    Suld,
    Sust,
    Sured,
    Suq,

    // =========================================================================
    // 9.7.12 Control Flow Instructions
    // =========================================================================
    Bra,
    BrxIdx, // brx.idx
    Call,
    Ret,
    Exit,

    // =========================================================================
    // 9.7.13 Parallel Synchronization and Communication Instructions
    // =========================================================================
    Bar,
    Barrier,
    BarWarpSync,    // bar.warp.sync
    BarrierCluster, // barrier.cluster
    Membar,
    Fence,
    Atom,
    Red,
    RedAsync,  // red.async
    Vote,      // deprecated
    VoteSync,  // vote.sync
    MatchSync, // match.sync
    Activemask,
    ReduxSync, // redux.sync
    Griddepcontrol,
    ElectSync, // elect.sync

    // mbarrier instructions
    MbarrierInit,         // mbarrier.init
    MbarrierInval,        // mbarrier.inval
    MbarrierExpectTx,     // mbarrier.expect_tx
    MbarrierCompleteTx,   // mbarrier.complete_tx
    MbarrierArrive,       // mbarrier.arrive
    MbarrierArriveDrop,   // mbarrier.arrive_drop
    MbarrierTestWait,     // mbarrier.test_wait
    MbarrierTryWait,      // mbarrier.try_wait
    MbarrierPendingCount, // mbarrier.pending_count

    // Cluster launch control
    ClusterlaunchcontrolTryCancel,   // clusterlaunchcontrol.try_cancel
    ClusterlaunchcontrolQueryCancel, // clusterlaunchcontrol.query_cancel

    // =========================================================================
    // 9.7.14 Warp Level Matrix Multiply-Accumulate Instructions
    // =========================================================================
    WmmaLoad,  // wmma.load
    WmmaStore, // wmma.store
    WmmaMma,   // wmma.mma
    Mma,
    MmaSp, // mma.sp
    Ldmatrix,
    Stmatrix,
    Movmatrix,

    // =========================================================================
    // 9.7.15 Asynchronous Warpgroup Level Matrix Multiply-Accumulate Instructions
    // =========================================================================
    WgmmaMmaAsync,    // wgmma.mma_async
    WgmmaMmaAsyncSp,  // wgmma.mma_async.sp
    WgmmaFence,       // wgmma.fence
    WgmmaCommitGroup, // wgmma.commit_group
    WgmmaWaitGroup,   // wgmma.wait_group

    // =========================================================================
    // 9.7.16 TensorCore 5th Generation Family Instructions
    // =========================================================================
    Tcgen05Alloc,                 // tcgen05.alloc
    Tcgen05Dealloc,               // tcgen05.dealloc
    Tcgen05RelinquishAllocPermit, // tcgen05.relinquish_alloc_permit
    Tcgen05Ld,                    // tcgen05.ld
    Tcgen05St,                    // tcgen05.st
    Tcgen05Wait,                  // tcgen05.wait
    Tcgen05Cp,                    // tcgen05.cp
    Tcgen05Shift,                 // tcgen05.shift
    Tcgen05Mma,                   // tcgen05.mma
    Tcgen05MmaSp,                 // tcgen05.mma.sp
    Tcgen05MmaWs,                 // tcgen05.mma.ws
    Tcgen05MmaWsSp,               // tcgen05.mma.ws.sp
    Tcgen05Fence,                 // tcgen05.fence
    Tcgen05Commit,                // tcgen05.commit

    // =========================================================================
    // 9.7.17 Stack Manipulation Instructions
    // =========================================================================
    Stacksave,
    Stackrestore,
    Alloca,

    // =========================================================================
    // 9.7.18 Video Instructions
    // =========================================================================
    // Scalar video instructions
    Vadd,
    Vsub,
    Vabsdiff,
    Vmin,
    Vmax,
    Vshl,
    Vshr,
    Vmad,
    Vset,

    // SIMD video instructions (2-element)
    Vadd2,
    Vsub2,
    Vavrg2,
    Vabsdiff2,
    Vmin2,
    Vmax2,
    Vset2,

    // SIMD video instructions (4-element)
    Vadd4,
    Vsub4,
    Vavrg4,
    Vabsdiff4,
    Vmin4,
    Vmax4,
    Vset4,

    // =========================================================================
    // 9.7.19 Miscellaneous Instructions
    // =========================================================================
    Brkpt,
    Nanosleep,
    Pmevent,
    Trap,
    Setmaxnreg,
}

impl InstrKind {
    pub fn mnemonic(self) -> &'static [AsciiChar] {
        use crate::ascii::ascii;
        use InstrKind::*;
        match self {
            // Integer Arithmetic
            Add => ascii("add"),
            Sub => ascii("sub"),
            Mul => ascii("mul"),
            Mad => ascii("mad"),
            Mul24 => ascii("mul24"),
            Mad24 => ascii("mad24"),
            Sad => ascii("sad"),
            Div => ascii("div"),
            Rem => ascii("rem"),
            Abs => ascii("abs"),
            Neg => ascii("neg"),
            Min => ascii("min"),
            Max => ascii("max"),
            Popc => ascii("popc"),
            Clz => ascii("clz"),
            Bfind => ascii("bfind"),
            Fns => ascii("fns"),
            Brev => ascii("brev"),
            Bfe => ascii("bfe"),
            Bfi => ascii("bfi"),
            Szext => ascii("szext"),
            Bmsk => ascii("bmsk"),
            Dp4a => ascii("dp4a"),
            Dp2a => ascii("dp2a"),

            // Extended-Precision Integer Arithmetic
            AddCc => ascii("add.cc"),
            Addc => ascii("addc"),
            SubCc => ascii("sub.cc"),
            Subc => ascii("subc"),
            MadCc => ascii("mad.cc"),
            Madc => ascii("madc"),

            // Floating-Point
            Testp => ascii("testp"),
            Copysign => ascii("copysign"),
            Fma => ascii("fma"),
            Rcp => ascii("rcp"),
            RcpApproxFtzF64 => ascii("rcp.approx.ftz.f64"),
            Sqrt => ascii("sqrt"),
            Rsqrt => ascii("rsqrt"),
            RsqrtApproxFtzF64 => ascii("rsqrt.approx.ftz.f64"),
            Sin => ascii("sin"),
            Cos => ascii("cos"),
            Lg2 => ascii("lg2"),
            Ex2 => ascii("ex2"),
            Tanh => ascii("tanh"),

            // Comparison and Selection
            Set => ascii("set"),
            Setp => ascii("setp"),
            Selp => ascii("selp"),
            Slct => ascii("slct"),

            // Logic and Shift
            And => ascii("and"),
            Or => ascii("or"),
            Xor => ascii("xor"),
            Not => ascii("not"),
            Cnot => ascii("cnot"),
            Lop3 => ascii("lop3"),
            Shf => ascii("shf"),
            Shl => ascii("shl"),
            Shr => ascii("shr"),

            // Data Movement and Conversion
            Mov => ascii("mov"),
            Shfl => ascii("shfl"),
            ShflSync => ascii("shfl.sync"),
            Prmt => ascii("prmt"),
            Ld => ascii("ld"),
            LdGlobalNc => ascii("ld.global.nc"),
            Ldu => ascii("ldu"),
            St => ascii("st"),
            StAsync => ascii("st.async"),
            StBulk => ascii("st.bulk"),
            Prefetch => ascii("prefetch"),
            Prefetchu => ascii("prefetchu"),
            Applypriority => ascii("applypriority"),
            Discard => ascii("discard"),
            Createpolicy => ascii("createpolicy"),
            Isspacep => ascii("isspacep"),
            Cvta => ascii("cvta"),
            Cvt => ascii("cvt"),
            CvtPack => ascii("cvt.pack"),
            Mapa => ascii("mapa"),
            Getctarank => ascii("getctarank"),

            // Asynchronous copy
            CpAsync => ascii("cp.async"),
            CpAsyncCommitGroup => ascii("cp.async.commit_group"),
            CpAsyncWaitGroup => ascii("cp.async.wait_group"),
            CpAsyncWaitAll => ascii("cp.async.wait_all"),
            CpAsyncBulk => ascii("cp.async.bulk"),
            CpAsyncBulkPrefetch => ascii("cp.async.bulk.prefetch"),
            CpAsyncBulkTensor => ascii("cp.async.bulk.tensor"),
            CpAsyncBulkPrefetchTensor => ascii("cp.async.bulk.prefetch.tensor"),
            CpReduceAsyncBulk => ascii("cp.reduce.async.bulk"),
            CpReduceAsyncBulkTensor => ascii("cp.reduce.async.bulk.tensor"),
            CpAsyncMbarrierArrive => ascii("cp.async.mbarrier.arrive"),

            // Multi-memory
            MultimemLdReduce => ascii("multimem.ld_reduce"),
            MultimemSt => ascii("multimem.st"),
            MultimemRed => ascii("multimem.red"),
            MultimemCpAsyncBulk => ascii("multimem.cp.async.bulk"),
            MultimemCpReduceAsyncBulk => ascii("multimem.cp.reduce.async.bulk"),

            // Tensor map
            TensormapReplace => ascii("tensormap.replace"),
            TensormapCpFenceproxy => ascii("tensormap.cp_fenceproxy"),

            // Texture
            Tex => ascii("tex"),
            Tld4 => ascii("tld4"),
            Txq => ascii("txq"),
            Istypep => ascii("istypep"),

            // Surface
            Suld => ascii("suld"),
            Sust => ascii("sust"),
            Sured => ascii("sured"),
            Suq => ascii("suq"),

            // Control Flow
            Bra => ascii("bra"),
            BrxIdx => ascii("brx.idx"),
            Call => ascii("call"),
            Ret => ascii("ret"),
            Exit => ascii("exit"),

            // Synchronization
            Bar => ascii("bar"),
            Barrier => ascii("barrier"),
            BarWarpSync => ascii("bar.warp.sync"),
            BarrierCluster => ascii("barrier.cluster"),
            Membar => ascii("membar"),
            Fence => ascii("fence"),
            Atom => ascii("atom"),
            Red => ascii("red"),
            RedAsync => ascii("red.async"),
            Vote => ascii("vote"),
            VoteSync => ascii("vote.sync"),
            MatchSync => ascii("match.sync"),
            Activemask => ascii("activemask"),
            ReduxSync => ascii("redux.sync"),
            Griddepcontrol => ascii("griddepcontrol"),
            ElectSync => ascii("elect.sync"),

            // mbarrier
            MbarrierInit => ascii("mbarrier.init"),
            MbarrierInval => ascii("mbarrier.inval"),
            MbarrierExpectTx => ascii("mbarrier.expect_tx"),
            MbarrierCompleteTx => ascii("mbarrier.complete_tx"),
            MbarrierArrive => ascii("mbarrier.arrive"),
            MbarrierArriveDrop => ascii("mbarrier.arrive_drop"),
            MbarrierTestWait => ascii("mbarrier.test_wait"),
            MbarrierTryWait => ascii("mbarrier.try_wait"),
            MbarrierPendingCount => ascii("mbarrier.pending_count"),

            // Cluster launch control
            ClusterlaunchcontrolTryCancel => ascii("clusterlaunchcontrol.try_cancel"),
            ClusterlaunchcontrolQueryCancel => ascii("clusterlaunchcontrol.query_cancel"),

            // Warp Level Matrix
            WmmaLoad => ascii("wmma.load"),
            WmmaStore => ascii("wmma.store"),
            WmmaMma => ascii("wmma.mma"),
            Mma => ascii("mma"),
            MmaSp => ascii("mma.sp"),
            Ldmatrix => ascii("ldmatrix"),
            Stmatrix => ascii("stmatrix"),
            Movmatrix => ascii("movmatrix"),

            // Warpgroup Level Matrix
            WgmmaMmaAsync => ascii("wgmma.mma_async"),
            WgmmaMmaAsyncSp => ascii("wgmma.mma_async.sp"),
            WgmmaFence => ascii("wgmma.fence"),
            WgmmaCommitGroup => ascii("wgmma.commit_group"),
            WgmmaWaitGroup => ascii("wgmma.wait_group"),

            // TensorCore 5th Generation
            Tcgen05Alloc => ascii("tcgen05.alloc"),
            Tcgen05Dealloc => ascii("tcgen05.dealloc"),
            Tcgen05RelinquishAllocPermit => ascii("tcgen05.relinquish_alloc_permit"),
            Tcgen05Ld => ascii("tcgen05.ld"),
            Tcgen05St => ascii("tcgen05.st"),
            Tcgen05Wait => ascii("tcgen05.wait"),
            Tcgen05Cp => ascii("tcgen05.cp"),
            Tcgen05Shift => ascii("tcgen05.shift"),
            Tcgen05Mma => ascii("tcgen05.mma"),
            Tcgen05MmaSp => ascii("tcgen05.mma.sp"),
            Tcgen05MmaWs => ascii("tcgen05.mma.ws"),
            Tcgen05MmaWsSp => ascii("tcgen05.mma.ws.sp"),
            Tcgen05Fence => ascii("tcgen05.fence"),
            Tcgen05Commit => ascii("tcgen05.commit"),

            // Stack Manipulation
            Stacksave => ascii("stacksave"),
            Stackrestore => ascii("stackrestore"),
            Alloca => ascii("alloca"),

            // Video Instructions (Scalar)
            Vadd => ascii("vadd"),
            Vsub => ascii("vsub"),
            Vabsdiff => ascii("vabsdiff"),
            Vmin => ascii("vmin"),
            Vmax => ascii("vmax"),
            Vshl => ascii("vshl"),
            Vshr => ascii("vshr"),
            Vmad => ascii("vmad"),
            Vset => ascii("vset"),

            // Video Instructions (SIMD 2-element)
            Vadd2 => ascii("vadd2"),
            Vsub2 => ascii("vsub2"),
            Vavrg2 => ascii("vavrg2"),
            Vabsdiff2 => ascii("vabsdiff2"),
            Vmin2 => ascii("vmin2"),
            Vmax2 => ascii("vmax2"),
            Vset2 => ascii("vset2"),

            // Video Instructions (SIMD 4-element)
            Vadd4 => ascii("vadd4"),
            Vsub4 => ascii("vsub4"),
            Vavrg4 => ascii("vavrg4"),
            Vabsdiff4 => ascii("vabsdiff4"),
            Vmin4 => ascii("vmin4"),
            Vmax4 => ascii("vmax4"),
            Vset4 => ascii("vset4"),

            // Miscellaneous
            Brkpt => ascii("brkpt"),
            Nanosleep => ascii("nanosleep"),
            Pmevent => ascii("pmevent"),
            Trap => ascii("trap"),
            Setmaxnreg => ascii("setmaxnreg"),
        }
    }

    pub fn to_ascii_string(self) -> AsciiString {
        self.mnemonic().to_owned_ascii()
    }
}

impl fmt::Display for InstrKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.mnemonic().as_str())
    }
}

static INSTR_TRIE: OnceLock<InstrTrie> = OnceLock::new();

/// Returns a segment trie containing all PTX instruction mnemonics.
///
/// The trie maps instruction strings to their corresponding `InstrKind` variant. This supports
/// longest-match lexing for compound instructions like `cp.async.bulk`, while correctly rejecting
/// partial segment matches (e.g., "mov32" won't match "mov").
pub fn get_instr_trie() -> &'static InstrTrie {
    INSTR_TRIE.get_or_init(|| {
        use InstrKind::*;

        let mut trie = InstrTrie::new();

        // Helper macro to insert instructions
        macro_rules! insert {
            ($($name:expr => $variant:ident),* $(,)?) => {
                $(trie.insert(ascii($name), $variant);)*
            };
        }

        insert! {
            // Integer Arithmetic
            "add" => Add,
            "sub" => Sub,
            "mul" => Mul,
            "mad" => Mad,
            "mul24" => Mul24,
            "mad24" => Mad24,
            "sad" => Sad,
            "div" => Div,
            "rem" => Rem,
            "abs" => Abs,
            "neg" => Neg,
            "min" => Min,
            "max" => Max,
            "popc" => Popc,
            "clz" => Clz,
            "bfind" => Bfind,
            "fns" => Fns,
            "brev" => Brev,
            "bfe" => Bfe,
            "bfi" => Bfi,
            "szext" => Szext,
            "bmsk" => Bmsk,
            "dp4a" => Dp4a,
            "dp2a" => Dp2a,

            // Extended-Precision Integer Arithmetic
            "add.cc" => AddCc,
            "addc" => Addc,
            "sub.cc" => SubCc,
            "subc" => Subc,
            "mad.cc" => MadCc,
            "madc" => Madc,

            // Floating-Point
            "testp" => Testp,
            "copysign" => Copysign,
            "fma" => Fma,
            "rcp" => Rcp,
            "rcp.approx.ftz.f64" => RcpApproxFtzF64,
            "sqrt" => Sqrt,
            "rsqrt" => Rsqrt,
            "rsqrt.approx.ftz.f64" => RsqrtApproxFtzF64,
            "sin" => Sin,
            "cos" => Cos,
            "lg2" => Lg2,
            "ex2" => Ex2,
            "tanh" => Tanh,

            // Comparison and Selection
            "set" => Set,
            "setp" => Setp,
            "selp" => Selp,
            "slct" => Slct,

            // Logic and Shift
            "and" => And,
            "or" => Or,
            "xor" => Xor,
            "not" => Not,
            "cnot" => Cnot,
            "lop3" => Lop3,
            "shf" => Shf,
            "shl" => Shl,
            "shr" => Shr,

            // Data Movement and Conversion
            "mov" => Mov,
            "shfl" => Shfl,
            "shfl.sync" => ShflSync,
            "prmt" => Prmt,
            "ld" => Ld,
            "ld.global.nc" => LdGlobalNc,
            "ldu" => Ldu,
            "st" => St,
            "st.async" => StAsync,
            "st.bulk" => StBulk,
            "prefetch" => Prefetch,
            "prefetchu" => Prefetchu,
            "applypriority" => Applypriority,
            "discard" => Discard,
            "createpolicy" => Createpolicy,
            "isspacep" => Isspacep,
            "cvta" => Cvta,
            "cvt" => Cvt,
            "cvt.pack" => CvtPack,
            "mapa" => Mapa,
            "getctarank" => Getctarank,

            // Asynchronous copy
            "cp.async" => CpAsync,
            "cp.async.commit_group" => CpAsyncCommitGroup,
            "cp.async.wait_group" => CpAsyncWaitGroup,
            "cp.async.wait_all" => CpAsyncWaitAll,
            "cp.async.bulk" => CpAsyncBulk,
            "cp.async.bulk.prefetch" => CpAsyncBulkPrefetch,
            "cp.async.bulk.tensor" => CpAsyncBulkTensor,
            "cp.async.bulk.prefetch.tensor" => CpAsyncBulkPrefetchTensor,
            "cp.reduce.async.bulk" => CpReduceAsyncBulk,
            "cp.reduce.async.bulk.tensor" => CpReduceAsyncBulkTensor,
            "cp.async.mbarrier.arrive" => CpAsyncMbarrierArrive,

            // Multi-memory
            "multimem.ld_reduce" => MultimemLdReduce,
            "multimem.st" => MultimemSt,
            "multimem.red" => MultimemRed,
            "multimem.cp.async.bulk" => MultimemCpAsyncBulk,
            "multimem.cp.reduce.async.bulk" => MultimemCpReduceAsyncBulk,

            // Tensor map
            "tensormap.replace" => TensormapReplace,
            "tensormap.cp_fenceproxy" => TensormapCpFenceproxy,

            // Texture
            "tex" => Tex,
            "tld4" => Tld4,
            "txq" => Txq,
            "istypep" => Istypep,

            // Surface
            "suld" => Suld,
            "sust" => Sust,
            "sured" => Sured,
            "suq" => Suq,

            // Control Flow
            "bra" => Bra,
            "brx.idx" => BrxIdx,
            "call" => Call,
            "ret" => Ret,
            "exit" => Exit,

            // Synchronization
            "bar" => Bar,
            "barrier" => Barrier,
            "bar.warp.sync" => BarWarpSync,
            "barrier.cluster" => BarrierCluster,
            "membar" => Membar,
            "fence" => Fence,
            "atom" => Atom,
            "red" => Red,
            "red.async" => RedAsync,
            "vote" => Vote,
            "vote.sync" => VoteSync,
            "match.sync" => MatchSync,
            "activemask" => Activemask,
            "redux.sync" => ReduxSync,
            "griddepcontrol" => Griddepcontrol,
            "elect.sync" => ElectSync,

            // mbarrier
            "mbarrier.init" => MbarrierInit,
            "mbarrier.inval" => MbarrierInval,
            "mbarrier.expect_tx" => MbarrierExpectTx,
            "mbarrier.complete_tx" => MbarrierCompleteTx,
            "mbarrier.arrive" => MbarrierArrive,
            "mbarrier.arrive_drop" => MbarrierArriveDrop,
            "mbarrier.test_wait" => MbarrierTestWait,
            "mbarrier.try_wait" => MbarrierTryWait,
            "mbarrier.pending_count" => MbarrierPendingCount,

            // Cluster launch control
            "clusterlaunchcontrol.try_cancel" => ClusterlaunchcontrolTryCancel,
            "clusterlaunchcontrol.query_cancel" => ClusterlaunchcontrolQueryCancel,

            // Warp Level Matrix
            "wmma.load" => WmmaLoad,
            "wmma.store" => WmmaStore,
            "wmma.mma" => WmmaMma,
            "mma" => Mma,
            "mma.sp" => MmaSp,
            "ldmatrix" => Ldmatrix,
            "stmatrix" => Stmatrix,
            "movmatrix" => Movmatrix,

            // Warpgroup Level Matrix
            "wgmma.mma_async" => WgmmaMmaAsync,
            "wgmma.mma_async.sp" => WgmmaMmaAsyncSp,
            "wgmma.fence" => WgmmaFence,
            "wgmma.commit_group" => WgmmaCommitGroup,
            "wgmma.wait_group" => WgmmaWaitGroup,

            // TensorCore 5th Generation
            "tcgen05.alloc" => Tcgen05Alloc,
            "tcgen05.dealloc" => Tcgen05Dealloc,
            "tcgen05.relinquish_alloc_permit" => Tcgen05RelinquishAllocPermit,
            "tcgen05.ld" => Tcgen05Ld,
            "tcgen05.st" => Tcgen05St,
            "tcgen05.wait" => Tcgen05Wait,
            "tcgen05.cp" => Tcgen05Cp,
            "tcgen05.shift" => Tcgen05Shift,
            "tcgen05.mma" => Tcgen05Mma,
            "tcgen05.mma.sp" => Tcgen05MmaSp,
            "tcgen05.mma.ws" => Tcgen05MmaWs,
            "tcgen05.mma.ws.sp" => Tcgen05MmaWsSp,
            "tcgen05.fence" => Tcgen05Fence,
            "tcgen05.commit" => Tcgen05Commit,

            // Stack Manipulation
            "stacksave" => Stacksave,
            "stackrestore" => Stackrestore,
            "alloca" => Alloca,

            // Video Instructions (Scalar)
            "vadd" => Vadd,
            "vsub" => Vsub,
            "vabsdiff" => Vabsdiff,
            "vmin" => Vmin,
            "vmax" => Vmax,
            "vshl" => Vshl,
            "vshr" => Vshr,
            "vmad" => Vmad,
            "vset" => Vset,

            // Video Instructions (SIMD 2-element)
            "vadd2" => Vadd2,
            "vsub2" => Vsub2,
            "vavrg2" => Vavrg2,
            "vabsdiff2" => Vabsdiff2,
            "vmin2" => Vmin2,
            "vmax2" => Vmax2,
            "vset2" => Vset2,

            // Video Instructions (SIMD 4-element)
            "vadd4" => Vadd4,
            "vsub4" => Vsub4,
            "vavrg4" => Vavrg4,
            "vabsdiff4" => Vabsdiff4,
            "vmin4" => Vmin4,
            "vmax4" => Vmax4,
            "vset4" => Vset4,

            // Miscellaneous
            "brkpt" => Brkpt,
            "nanosleep" => Nanosleep,
            "pmevent" => Pmevent,
            "trap" => Trap,
            "setmaxnreg" => Setmaxnreg,
        }

        trie
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_exact_match() {
        let mut trie = InstrTrie::new();
        trie.insert(ascii("mov"), InstrKind::Mov);

        assert_eq!(trie.get_ancestor(ascii("mov")), Some(InstrKind::Mov));
    }

    #[test]
    fn test_no_partial_seg_match() {
        let mut trie = InstrTrie::new();
        trie.insert(ascii("mov"), InstrKind::Mov);

        // "mov32" as a single seg should not match "mov"
        assert_eq!(trie.get_ancestor(ascii("mov32")), None);
    }

    #[test]
    fn test_longest_match_wins() {
        let mut trie = InstrTrie::new();
        trie.insert(ascii("cp.async"), InstrKind::CpAsync);
        trie.insert(ascii("cp.async.bulk"), InstrKind::CpAsyncBulk);
        trie.insert(ascii("cp.async.bulk.tensor"), InstrKind::CpAsyncBulkTensor);

        assert_eq!(
            trie.get_ancestor(ascii("cp.async")),
            Some(InstrKind::CpAsync)
        );
        assert_eq!(
            trie.get_ancestor(ascii("cp.async.bulk")),
            Some(InstrKind::CpAsyncBulk)
        );
        assert_eq!(
            trie.get_ancestor(ascii("cp.async.bulk.tensor")),
            Some(InstrKind::CpAsyncBulkTensor)
        );
        // Extra segs after longest match
        assert_eq!(
            trie.get_ancestor(ascii("cp.async.bulk.tensor.extra")),
            Some(InstrKind::CpAsyncBulkTensor)
        );
    }

    #[test]
    fn test_qualifier_glued_onto_mnemonic_segment() {
        let mut trie = InstrTrie::new();
        trie.insert(ascii("tcgen05.wait"), InstrKind::Tcgen05Wait);
        trie.insert(ascii("tcgen05.commit"), InstrKind::Tcgen05Commit);

        // `tcgen05.wait::st`/`::ld` are the PTX ISA's own instruction names -
        // the `::st`/`::ld` qualifier is glued directly onto the "wait"
        // segment with no `.` separator, unlike a trailing modifier.
        assert_eq!(
            trie.get_ancestor(ascii("tcgen05.wait::st.sync.aligned")),
            Some(InstrKind::Tcgen05Wait)
        );
        assert_eq!(
            trie.get_ancestor(ascii("tcgen05.wait::ld.sync.aligned")),
            Some(InstrKind::Tcgen05Wait)
        );
        // A single `:` is not a qualifier separator and must not match.
        assert_eq!(trie.get_ancestor(ascii("tcgen05.wait:st")), None);
        // No bare "tcgen05" instruction exists, so a totally unknown
        // qualified segment must not spuriously match some other sibling.
        assert_eq!(trie.get_ancestor(ascii("tcgen05.unknown::st")), None);
    }

    #[test]
    fn test_no_match() {
        let mut trie = InstrTrie::new();
        trie.insert(ascii("mov"), InstrKind::Mov);

        assert_eq!(trie.get_ancestor(ascii("add")), None);
        assert_eq!(trie.get_ancestor(ascii("")), None);
    }

    #[test]
    fn test_intermediate_node_without_value() {
        let mut trie = InstrTrie::new();
        // Only insert "cp.async.bulk", not "cp" or "cp.async"
        trie.insert(ascii("cp.async.bulk"), InstrKind::CpAsyncBulk);

        assert_eq!(trie.get_ancestor(ascii("cp")), None);
        assert_eq!(trie.get_ancestor(ascii("cp.async")), None);
        assert_eq!(
            trie.get_ancestor(ascii("cp.async.bulk")),
            Some(InstrKind::CpAsyncBulk)
        );
    }

    #[test]
    fn test_branching_trie() {
        let mut trie = InstrTrie::new();
        // Create a trie that branches: st -> {async, bulk}
        trie.insert(ascii("st"), InstrKind::St);
        trie.insert(ascii("st.async"), InstrKind::StAsync);
        trie.insert(ascii("st.bulk"), InstrKind::StBulk);
        trie.insert(ascii("ld"), InstrKind::Ld);
        trie.insert(ascii("ld.global.nc"), InstrKind::LdGlobalNc);

        // Test both branches from st
        assert_eq!(trie.get_ancestor(ascii("st")), Some(InstrKind::St));
        assert_eq!(
            trie.get_ancestor(ascii("st.async")),
            Some(InstrKind::StAsync)
        );
        assert_eq!(trie.get_ancestor(ascii("st.bulk")), Some(InstrKind::StBulk));
        assert_eq!(
            trie.get_ancestor(ascii("st.async.extra")),
            Some(InstrKind::StAsync)
        );
        assert_eq!(
            trie.get_ancestor(ascii("st.bulk.extra")),
            Some(InstrKind::StBulk)
        );

        // Test separate branch (ld)
        assert_eq!(trie.get_ancestor(ascii("ld")), Some(InstrKind::Ld));
        assert_eq!(
            trie.get_ancestor(ascii("ld.global.nc")),
            Some(InstrKind::LdGlobalNc)
        );
    }
}
