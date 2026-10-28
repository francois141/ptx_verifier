//! Direct IR execution through the public API, without a source-language frontend.

use volta_graph::{Assumption, InstructionInfo, Provenance};
use volta_graph_check::{GraphConclusion, check_graph};
use volta_ptx_analysis::{
    AnalysisConfig, ArrayDef, ArrayKind, InstrId, LoweredInstr, LoweredProgram, MemSpace, Operand,
    ScalarType, SourceMap, SymbolTable, analyze_lowered,
};

#[test]
fn executes_a_lowered_store() {
    const OUTPUT_BASE: u64 = 0x20000;

    // Direct callers must finalize the layout even when no shared memory is declared.
    let mut symbols = SymbolTable::new();
    symbols.finalize_shared_layout().unwrap();

    // out[0] = 42; return. This needs no parameters or registers.
    let mut program = LoweredProgram {
        instructions: Default::default(),
        predicates: Default::default(),
        symbols,
        source_map: SourceMap::default(),
        entry_pc: InstrId(0),
    };
    for instruction in [
        LoweredInstr::Store {
            space: MemSpace::Global,
            base: Operand::ImmU64(OUTPUT_BASE),
            offset: 0,
            src: Operand::ImmI64(42),
            ty: ScalarType::U32,
        },
        LoweredInstr::Exit,
    ] {
        let _ = program.instructions.push(instruction);
        let _ = program.predicates.push(None);
    }

    // One thread and one output element suffice to exercise result extraction.
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".into(),
        base: OUTPUT_BASE,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    let provenance = provenance(&program, &config);
    let result = analyze_lowered(&program, config, provenance).unwrap();

    // An Ok result alone does not establish that execution completed.
    assert_eq!(
        check_graph(&result.graph).conclusion(),
        GraphConclusion::Verified
    );
    let outputs = result.symbolic_outputs().unwrap();
    assert_eq!(
        outputs
            .arena
            .display_expr(outputs.element("out", 0).unwrap()),
        "42"
    );
}

/// Record the interpreter's assumptions and the supplied program and launch configuration.
fn provenance(program: &LoweredProgram, config: &AnalysisConfig) -> Provenance {
    Provenance {
        kernel: "store".into(),
        block_dim: config.block_dim,
        grid_dim: config.grid_dim,
        targets: Vec::new(),
        assumptions: vec![
            Assumption::StructuredCta,
            Assumption::SingleCtaAnalyzed,
            Assumption::SingleCtaCluster,
            Assumption::NeverStealClusterLaunchControl,
            Assumption::ExitedThreadsArrive,
            Assumption::EagerAsyncData,
        ],
        instructions: program
            .instructions
            .values()
            .map(|instruction| InstructionInfo {
                kind: instruction.kind_name(),
                span: None,
            })
            .collect(),
    }
}
