//! Generate Lean 4 statements that compare candidate outputs with baseline outputs.
//!
//! Each output element gets one `Prop`: the values must either be equal or differ by
//! at most a given tolerance. Elements whose statements coincide share one definition.
//! Proofs belong in a separate module so that proving a statement does not change what it claims.

use std::collections::HashMap;
use std::fmt::{self, Write as _};

use rug::{Integer, Rational};

use volta_expr::SymbolicOutputs;
use volta_expr::symbolic::{ExprArena, ExprId, ExprNode, RealRepr};
use volta_expr::text::op_name;

/// What each statement claims of a candidate value `c` and its baseline value `b`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Claim {
    /// `c = b`.
    Equal,

    /// `|c - b| ≤ tolerance`.
    Within(Rational),
}

/// The inputs a claim covers: every real, or those within a bound in absolute value, where the
/// kernel's own floats saturate or overflow beyond it.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub enum Domain {
    #[default]
    AllReals,
    InputsWithin(Rational),
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Side {
    Candidate,
    Baseline,
}

impl fmt::Display for Side {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(match self {
            Side::Candidate => "candidate",
            Side::Baseline => "baseline",
        })
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum LeanError {
    NoArrays,

    MissingArray {
        side: Side,
        array: String,
    },

    IndexMismatch {
        array: String,
    },

    NegativeTolerance,
    InvalidNamespace(String),

    /// A node Lean is not given: bitwise ops, roundings, `erf`, infinities, undefined values.
    Unsupported {
        side: Side,
        array: String,
        index: u64,
        op: &'static str,
    },

    /// A truth value used as a number, or a number used as a truth value.
    SortMismatch {
        side: Side,
        array: String,
        index: u64,
        op: &'static str,
    },
}

impl fmt::Display for LeanError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::NoArrays => write!(f, "no output array to state"),
            Self::MissingArray { side, array } => {
                write!(f, "the {side} has no output array `{array}`")
            }
            Self::IndexMismatch { array } => write!(
                f,
                "the candidate and the baseline write different elements of `{array}`"
            ),
            Self::NegativeTolerance => write!(f, "the tolerance must be nonnegative"),
            Self::InvalidNamespace(ns) => write!(f, "`{ns}` is not a Lean namespace"),
            Self::Unsupported {
                side,
                array,
                index,
                op,
            } => write!(
                f,
                "the {side}'s `{array}[{index}]` uses `{op}`, which has no real-number form in Lean"
            ),
            Self::SortMismatch {
                side,
                array,
                index,
                op,
            } => write!(
                f,
                "the {side}'s `{array}[{index}]` mixes truth values and numbers at `{op}`"
            ),
        }
    }
}

impl std::error::Error for LeanError {}

/// A generated Lean module and the number of `Prop` definitions it states.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LeanModule {
    pub text: String,
    pub statements: usize,
}

/// Generate a Lean module with one `def : Prop` per distinct output-element statement,
/// named `<array>_<index>` after the first element it states. Each compares the candidate
/// and baseline using `claim`.
///
/// Variables are `v0, v1, ...` in order of first use, so elements that differ only in their
/// inputs share a statement. Repeated expressions use `let` bindings. The generated code
/// follows Lean's arithmetic rules, including `x / 0 = 0` and its definitions of `log` and `sqrt`.
pub fn to_lean(
    candidate: &SymbolicOutputs,
    baseline: &SymbolicOutputs,
    arrays: &[String],
    claim: &Claim,
    domain: &Domain,
    namespace: &str,
) -> Result<LeanModule, LeanError> {
    validate_request(arrays, claim, namespace)?;

    let mut statements: Vec<Statement> = Vec::new();
    let mut by_definition: HashMap<String, usize> = HashMap::new();

    for array in arrays {
        let candidate_elements = find_output_elements(candidate, Side::Candidate, array)?;
        let baseline_elements = find_output_elements(baseline, Side::Baseline, array)?;

        let candidate_indices = candidate_elements.iter().map(|(index, _)| index);
        let baseline_indices = baseline_elements.iter().map(|(index, _)| index);

        if !candidate_indices.eq(baseline_indices) {
            return Err(LeanError::IndexMismatch {
                array: array.clone(),
            });
        }

        for (&(index, candidate_root), &(_, baseline_root)) in
            candidate_elements.iter().zip(baseline_elements)
        {
            let mut bindings = Vec::new();
            let mut variables = Variables::default();

            let candidate_value = render_expression(
                &candidate.arena,
                candidate_root,
                OutputElement {
                    side: Side::Candidate,
                    array,
                    index,
                },
                &mut bindings,
                &mut variables,
            )?;

            let baseline_value = render_expression(
                &baseline.arena,
                baseline_root,
                OutputElement {
                    side: Side::Baseline,
                    array,
                    index,
                },
                &mut bindings,
                &mut variables,
            )?;

            let body = match claim {
                Claim::Equal => format!(
                    "{} = {}",
                    candidate_value.operand(),
                    baseline_value.operand()
                ),
                Claim::Within(tolerance) => format!(
                    "|{} - {}| ≤ {}",
                    candidate_value.operand(),
                    baseline_value.operand(),
                    real_literal(tolerance).text
                ),
            };

            let definition = definition(&variables.order, domain, &bindings, &body);
            let element = (array.as_str(), index);

            match by_definition.get(&definition) {
                Some(&statement) => statements[statement].elements.push(element),
                None => {
                    by_definition.insert(definition.clone(), statements.len());
                    statements.push(Statement {
                        elements: vec![element],
                        variables: variables.order,
                        definition,
                    });
                }
            }
        }
    }

    let mut text = String::new();
    write_module_header(&mut text, claim, domain, namespace);
    for (name, definition) in [(ERF, ERF_DEFINITION), (RINT, RINT_DEFINITION)] {
        if statements
            .iter()
            .any(|s| s.definition.contains(&format!("{name} ")))
        {
            writeln!(text, "{definition}").unwrap();
        }
    }
    for statement in &statements {
        statement.write(&mut text);
    }
    writeln!(text, "\nend {namespace}\n\nend").unwrap();

    Ok(LeanModule {
        text,
        statements: statements.len(),
    })
}

fn validate_request(arrays: &[String], claim: &Claim, namespace: &str) -> Result<(), LeanError> {
    if arrays.is_empty() {
        return Err(LeanError::NoArrays);
    }

    if let Claim::Within(tolerance) = claim {
        if *tolerance < 0 {
            return Err(LeanError::NegativeTolerance);
        }
    }

    if namespace.split('.').any(|part| !is_plain_identifier(part)) {
        return Err(LeanError::InvalidNamespace(namespace.to_string()));
    }

    Ok(())
}

fn find_output_elements<'a>(
    outputs: &'a SymbolicOutputs,
    side: Side,
    array: &str,
) -> Result<&'a [(u64, ExprId)], LeanError> {
    for (name, elements) in &outputs.outputs {
        if name == array {
            return Ok(elements);
        }
    }

    Err(LeanError::MissingArray {
        side,
        array: array.to_string(),
    })
}

/// The error function's name in a challenge, defined there only when a statement uses it:
/// Mathlib has none.
const ERF: &str = "erf";
const ERF_DEFINITION: &str = "
/-- The error function, `2 / √π * ∫₀ˣ e^(-t²) dt`. -/
def erf (x : ℝ) : ℝ := 2 / Real.sqrt Real.pi * ∫ t in (0 : ℝ)..x, Real.exp (-t ^ 2)";

/// Rounding to the nearest integer, ties to even (`rintf`, `v_rndne_f32`), likewise defined only
/// where used: Mathlib's `round` takes ties up.
const RINT: &str = "rint";
const RINT_DEFINITION: &str = "
/-- The integer nearest `x`, ties to even. -/
def rint (x : ℝ) : ℝ :=
  if x - ⌊x⌋ = 1 / 2 then (if Even ⌊x⌋ then (⌊x⌋ : ℝ) else ⌊x⌋ + 1) else (round x : ℝ)";

fn write_module_header(out: &mut String, claim: &Claim, domain: &Domain, namespace: &str) {
    let relation = match claim {
        Claim::Equal => "is equal to".to_string(),
        Claim::Within(tolerance) => format!("is within {} of", format_rational(tolerance)),
    };
    let scope = match domain {
        Domain::AllReals => String::new(),
        Domain::InputsWithin(bound) => format!(
            " It covers only the inputs within {} in absolute value.",
            format_rational(bound)
        ),
    };

    writeln!(
        out,
        "import Mathlib

/-!
Generated by Volta: each definition states that every output element of the candidate its
comment lists {relation} the same element of the baseline.{scope} Elements whose statements
coincide share one definition, named after the first, at which the comment says what each
variable `vK` is.
Prove `theorem <name> : {namespace}.<name>` in another module without editing this file.
-/

-- A wide reduction nests a statement deeply; these options hold for this file only.
set_option maxRecDepth 16384
set_option maxHeartbeats 0

noncomputable section

namespace {namespace}"
    )
    .unwrap();
}

/// The text after `def <name> : Prop :=`, the same for statements that coincide.
fn definition(
    variables: &[Variable],
    domain: &Domain,
    bindings: &[(String, String)],
    body: &str,
) -> String {
    let mut out = String::new();
    let mut indent = "  ";

    if !variables.is_empty() {
        let names: Vec<String> = (0..variables.len()).map(variable_name).collect();
        writeln!(out, "  ∀ ({} : ℝ),", names.join(" ")).unwrap();
        indent = "    ";
    }

    if let Domain::InputsWithin(bound) = domain {
        let bound = real_literal(bound).text;
        let inputs = variables
            .iter()
            .enumerate()
            .filter(|(_, variable)| matches!(variable, Variable::Element(..)));
        for (position, _) in inputs {
            writeln!(out, "{indent}|{}| ≤ {bound} →", variable_name(position)).unwrap();
        }
    }

    for (name, value) in bindings {
        writeln!(out, "{indent}let {name} := {value}").unwrap();
    }

    writeln!(out, "{indent}{body}").unwrap();
    out
}

fn variable_name(position: usize) -> String {
    format!("v{position}")
}

/// Runs of consecutive elements a statement's comment lists before summarizing the rest.
const LISTED_RUNS: usize = 8;

/// One definition: the elements it states, in order, and its first element's variables.
struct Statement<'a> {
    elements: Vec<(&'a str, u64)>,
    variables: Vec<Variable>,
    definition: String,
}

impl Statement<'_> {
    fn write(&self, out: &mut String) {
        let (array, index) = self.elements[0];
        let name = lean_identifier(&format!("{array}_{index}"));

        let mut runs: Vec<((&str, u64), u64)> = Vec::new();
        for &(array, index) in &self.elements {
            match runs.last_mut() {
                Some(((last_array, start), length))
                    if *last_array == array && *start + *length == index =>
                {
                    *length += 1;
                }
                _ => runs.push(((array, index), 1)),
            }
        }

        let mut listed: Vec<String> = runs
            .iter()
            .take(LISTED_RUNS)
            .map(|&((array, start), length)| match length {
                1 => format!("`{array}[{start}]`"),
                _ => format!("`{array}[{start}]` to `{array}[{}]`", start + length - 1),
            })
            .collect();
        let unlisted: u64 = runs
            .iter()
            .skip(LISTED_RUNS)
            .map(|(_, length)| length)
            .sum();
        if unlisted > 0 {
            listed.push(format!("{unlisted} more"));
        }

        write!(out, "\n/-- {}", listed.join(", ")).unwrap();
        if !self.variables.is_empty() {
            let meanings: Vec<String> = self
                .variables
                .iter()
                .enumerate()
                .map(|(position, variable)| format!("`{}` is {variable}", variable_name(position)))
                .collect();
            write!(out, "; at `{array}[{index}]`, {}", meanings.join(", ")).unwrap();
        }
        write!(out, " -/\ndef {name} : Prop :=\n{}", self.definition).unwrap();
    }
}

#[derive(Clone, Copy)]
struct OutputElement<'a> {
    side: Side,
    array: &'a str,
    index: u64,
}

/// What a statement's universally quantified real variable stands for.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
enum Variable {
    Element(String, u64),
    Parameter(String),
    Machine(u64),
    Infinity(Infinity),
}

/// Which infinity a variable stands for. Any real may: a claim proved for every value holds
/// however the kernel's infinite value would behave.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum Infinity {
    Positive,
    Negative,
}

impl fmt::Display for Variable {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Variable::Element(array, index) => write!(f, "`{array}[{index}]`"),
            Variable::Parameter(name) => write!(f, "the parameter `{name}`"),
            Variable::Machine(id) => write!(f, "machine symbol {id}"),
            Variable::Infinity(Infinity::Positive) => write!(f, "+∞ (any real)"),
            Variable::Infinity(Infinity::Negative) => write!(f, "-∞ (any real)"),
        }
    }
}

/// One statement's variables in order of first use, the `k`-th named `vk`.
#[derive(Default)]
struct Variables {
    order: Vec<Variable>,
    positions: HashMap<Variable, usize>,
}

impl Variables {
    fn name(&mut self, variable: Variable) -> String {
        let position = match self.positions.get(&variable) {
            Some(&position) => position,
            None => {
                let position = self.order.len();
                self.positions.insert(variable.clone(), position);
                self.order.push(variable);
                position
            }
        };
        variable_name(position)
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum TermType {
    Real,
    Prop,
}

/// Decide when a term needs parentheses.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Precedence {
    /// A name or literal: safe in any position.
    Atomic,

    /// A function call: needs parentheses when passed to another function.
    Application,

    /// An operator or conditional: needs parentheses as an argument or operand.
    Compound,
}

#[derive(Debug, Clone)]
struct Term {
    term_type: TermType,
    precedence: Precedence,
    text: String,
}

impl Term {
    fn new(term_type: TermType, precedence: Precedence, text: String) -> Self {
        Self {
            term_type,
            precedence,
            text,
        }
    }

    fn argument(&self) -> String {
        match self.precedence {
            Precedence::Atomic => self.text.clone(),
            Precedence::Application | Precedence::Compound => format!("({})", self.text),
        }
    }

    fn operand(&self) -> String {
        match self.precedence {
            Precedence::Atomic | Precedence::Application => self.text.clone(),
            Precedence::Compound => format!("({})", self.text),
        }
    }
}

/// Convert an expression tree to a Lean term.
/// Repeated real expressions get a `let` binding, with dependencies written first.
fn render_expression(
    arena: &ExprArena,
    root: ExprId,
    element: OutputElement,
    bindings: &mut Vec<(String, String)>,
    variables: &mut Variables,
) -> Result<Term, LeanError> {
    // Visit each reachable node once and count references to its children.
    let mut use_counts: HashMap<ExprId, u32> = HashMap::new();
    let mut reachable = vec![root];
    let mut stack = vec![root];

    while let Some(id) = stack.pop() {
        arena.node(id).for_each_child(|child| {
            let count = use_counts.entry(child).or_insert(0);
            *count += 1;

            if *count == 1 {
                reachable.push(child);
                stack.push(child);
            }
        });
    }

    // Arena nodes are stored after their children. Render in that same order.
    reachable.sort_unstable_by_key(|id| id.0);

    let mut terms: HashMap<ExprId, Term> = HashMap::with_capacity(reachable.len());

    for id in reachable {
        let node = arena.node(id);
        let term = render_node(arena, node, &terms, element, variables)?;

        let mut has_children = false;
        node.for_each_child(|_| has_children = true);
        let is_shared = use_counts.get(&id).copied().unwrap_or(0) > 1;

        let term = if term.term_type == TermType::Real && has_children && is_shared {
            let name = format!("x{}", bindings.len());
            bindings.push((name.clone(), term.text));
            Term::new(TermType::Real, Precedence::Atomic, name)
        } else {
            term
        };

        terms.insert(id, term);
    }

    let value = terms.remove(&root).expect("the root is reachable");

    match value.term_type {
        TermType::Real => Ok(value),
        TermType::Prop => Err(element.mismatch(arena.node(root))),
    }
}

impl OutputElement<'_> {
    fn unsupported(&self, node: &ExprNode) -> LeanError {
        LeanError::Unsupported {
            side: self.side,
            array: self.array.to_string(),
            index: self.index,
            op: op_name(node),
        }
    }

    fn mismatch(&self, node: &ExprNode) -> LeanError {
        LeanError::SortMismatch {
            side: self.side,
            array: self.array.to_string(),
            index: self.index,
            op: op_name(node),
        }
    }
}

fn render_node(
    arena: &ExprArena,
    node: &ExprNode,
    terms: &HashMap<ExprId, Term>,
    element: OutputElement,
    variables: &mut Variables,
) -> Result<Term, LeanError> {
    use ExprNode::*;
    use Precedence::{Application, Atomic, Compound};

    let operands = Operands {
        terms,
        node,
        element,
    };

    Ok(match node {
        IntConst(v) => real_literal(&Rational::from(*v)),

        RealConst(r) => match r.repr() {
            RealRepr::Rational(q) => real_literal(q),
            RealRepr::NegInf => Term::new(
                TermType::Real,
                Atomic,
                variables.name(Variable::Infinity(Infinity::Negative)),
            ),
            RealRepr::PosInf => Term::new(
                TermType::Real,
                Atomic,
                variables.name(Variable::Infinity(Infinity::Positive)),
            ),
        },

        BoolConst(b) => Term::new(
            TermType::Prop,
            Atomic,
            if *b { "True" } else { "False" }.into(),
        ),

        Symbol(s) => Term::new(
            TermType::Real,
            Atomic,
            variables.name(Variable::Machine(s.0)),
        ),

        ParamSymbol(name) => {
            let variable = Variable::Parameter(arena.string(*name).to_string());
            Term::new(TermType::Real, Atomic, variables.name(variable))
        }

        InputElement { array, index } => {
            let variable = Variable::Element(arena.string(*array).to_string(), *index);
            Term::new(TermType::Real, Atomic, variables.name(variable))
        }

        SymbolicRead { .. }
        | Discarded
        | Undefined
        | Rem(..)
        | BitNot(_)
        | Popc(_)
        | BitAnd(..)
        | BitOr(..)
        | BitXor(..)
        | Shl(..)
        | Shr(..)
        | LShr(..)
        | Gelu(..)
        | Trunc(_) => {
            return Err(element.unsupported(node));
        }

        Neg(a) => Term::new(
            TermType::Real,
            Compound,
            format!("-{}", operands.real(*a)?.operand()),
        ),

        Exp(a) => operands.call("Real.exp", *a)?,
        Log(a) => operands.call("Real.log", *a)?,
        Sqrt(a) => operands.call("Real.sqrt", *a)?,
        Erf(a) => operands.call(ERF, *a)?,
        RoundEven(a) => operands.call(RINT, *a)?,

        Floor(a) => Term::new(
            TermType::Real,
            Atomic,
            format!("(⌊{}⌋ : ℝ)", operands.real(*a)?.operand()),
        ),

        Abs(a) => Term::new(
            TermType::Real,
            Compound,
            format!("|{}|", operands.real(*a)?.argument()),
        ),

        Sign(a) => {
            let a = operands.real(*a)?.operand();
            Term::new(
                TermType::Real,
                Compound,
                format!("if 0 < {a} then (1 : ℝ) else -1"),
            )
        }

        ToFloat(a) => operands.real(*a)?.clone(),

        Add(a, b) => operands.infix(TermType::Real, *a, "+", *b)?,
        Sub(a, b) => operands.infix(TermType::Real, *a, "-", *b)?,
        Mul(a, b) => operands.infix(TermType::Real, *a, "*", *b)?,
        Div(a, b) => operands.infix(TermType::Real, *a, "/", *b)?,

        Max(a, b) | Min(a, b) => {
            let f = if matches!(node, Max(..)) {
                "max"
            } else {
                "min"
            };
            let text = format!(
                "{f} {} {}",
                operands.real(*a)?.argument(),
                operands.real(*b)?.argument()
            );
            Term::new(TermType::Real, Application, text)
        }

        Eq(a, b) => operands.equality(*a, *b, false)?,
        Ne(a, b) => operands.equality(*a, *b, true)?,

        Lt(a, b) => operands.infix(TermType::Prop, *a, "<", *b)?,
        Le(a, b) => operands.infix(TermType::Prop, *a, "≤", *b)?,
        Gt(a, b) => operands.infix(TermType::Prop, *a, ">", *b)?,
        Ge(a, b) => operands.infix(TermType::Prop, *a, "≥", *b)?,

        And(a, b) => operands.logical(*a, "∧", *b)?,
        Or(a, b) => operands.logical(*a, "∨", *b)?,

        Not(a) => Term::new(
            TermType::Prop,
            Compound,
            format!("¬{}", operands.proposition(*a)?.argument()),
        ),

        Select(condition, then_branch, else_branch) => {
            let then_value = &terms[then_branch];
            let else_value = &terms[else_branch];

            if then_value.term_type != else_value.term_type {
                return Err(element.mismatch(node));
            }

            let text = format!(
                "if {} then {} else {}",
                operands.proposition(*condition)?.text,
                then_value.text,
                else_value.text,
            );
            Term::new(then_value.term_type, Compound, text)
        }
    })
}

/// Look up child terms and check that they have the type their parent needs.
struct Operands<'a> {
    terms: &'a HashMap<ExprId, Term>,
    node: &'a ExprNode,
    element: OutputElement<'a>,
}

impl<'a> Operands<'a> {
    fn real(&self, id: ExprId) -> Result<&'a Term, LeanError> {
        self.of(id, TermType::Real)
    }

    fn proposition(&self, id: ExprId) -> Result<&'a Term, LeanError> {
        self.of(id, TermType::Prop)
    }

    fn call(&self, function: &str, argument: ExprId) -> Result<Term, LeanError> {
        let text = format!("{function} {}", self.real(argument)?.argument());
        Ok(Term::new(TermType::Real, Precedence::Application, text))
    }

    fn logical(&self, left: ExprId, operator: &str, right: ExprId) -> Result<Term, LeanError> {
        let left = self.proposition(left)?;
        let right = self.proposition(right)?;
        let text = format!("{} {operator} {}", left.operand(), right.operand());
        Ok(Term::new(TermType::Prop, Precedence::Compound, text))
    }

    fn of(&self, id: ExprId, term_type: TermType) -> Result<&'a Term, LeanError> {
        let term = &self.terms[&id];

        if term.term_type == term_type {
            Ok(term)
        } else {
            Err(self.element.mismatch(self.node))
        }
    }

    fn infix(
        &self,
        term_type: TermType,
        a: ExprId,
        op: &str,
        b: ExprId,
    ) -> Result<Term, LeanError> {
        let (a, b) = (self.of(a, TermType::Real)?, self.of(b, TermType::Real)?);
        let text = format!("{} {op} {}", a.operand(), b.operand());
        Ok(Term::new(term_type, Precedence::Compound, text))
    }

    fn equality(&self, a: ExprId, b: ExprId, negated: bool) -> Result<Term, LeanError> {
        let (a, b) = (&self.terms[&a], &self.terms[&b]);
        let text = match (a.term_type, b.term_type, negated) {
            (TermType::Real, TermType::Real, false) => format!("{} = {}", a.operand(), b.operand()),
            (TermType::Real, TermType::Real, true) => format!("{} ≠ {}", a.operand(), b.operand()),
            (TermType::Prop, TermType::Prop, false) => format!("({} ↔ {})", a.text, b.text),
            (TermType::Prop, TermType::Prop, true) => format!("¬({} ↔ {})", a.text, b.text),
            _ => return Err(self.element.mismatch(self.node)),
        };
        Ok(Term::new(TermType::Prop, Precedence::Compound, text))
    }
}

/// Use a fraction when an exact decimal would exceed this length.
const MAX_DECIMAL_LENGTH: usize = 24;

fn real_literal(value: &Rational) -> Term {
    Term::new(
        TermType::Real,
        Precedence::Atomic,
        format!("({} : ℝ)", format_rational(value)),
    )
}

/// Format a rational exactly as an integer, a short decimal, or a fraction.
fn format_rational(value: &Rational) -> String {
    let (numerator, denominator) = (value.numer(), value.denom());

    if *denominator == 1 {
        return numerator.to_string();
    }

    if let Some(decimal) = short_decimal(numerator, denominator) {
        return decimal;
    }

    // Keep large powers of two compact, for example `1 / 2 ^ 100`.
    let exponent = denominator.find_one(0).expect("a denominator is positive");

    if Integer::from(denominator >> exponent) == 1 {
        return format!("{numerator} / 2 ^ {exponent}");
    }

    format!("{numerator} / {denominator}")
}

/// Use long division to produce an exact decimal, stopping at the length limit.
fn short_decimal(numerator: &Integer, denominator: &Integer) -> Option<String> {
    let magnitude = numerator.clone().abs();
    let whole = Integer::from(&magnitude / denominator);
    let mut remainder = Integer::from(&magnitude % denominator);
    let sign = if *numerator < 0 { "-" } else { "" };
    let mut decimal = format!("{sign}{whole}.");

    while remainder != 0 {
        if decimal.len() >= MAX_DECIMAL_LENGTH {
            return None;
        }

        remainder *= 10;
        let digit = Integer::from(&remainder / denominator);
        decimal.push_str(&digit.to_string());
        remainder %= denominator;
    }

    Some(decimal)
}

fn lean_identifier(name: &str) -> String {
    if is_plain_identifier(name) {
        name.to_string()
    } else {
        format!("«{name}»")
    }
}

const KEYWORDS: &[&str] = &[
    "abbrev",
    "at",
    "axiom",
    "by",
    "calc",
    "def",
    "do",
    "else",
    "end",
    "example",
    "for",
    "from",
    "fun",
    "have",
    "if",
    "import",
    "in",
    "instance",
    "let",
    "match",
    "namespace",
    "open",
    "Prop",
    "section",
    "show",
    "Sort",
    "structure",
    "then",
    "theorem",
    "Type",
    "variable",
    "where",
    "with",
];

fn is_plain_identifier(name: &str) -> bool {
    let mut chars = name.chars();
    let Some(first) = chars.next() else {
        return false;
    };

    if !first.is_ascii_alphabetic() && first != '_' {
        return false;
    }

    for character in chars {
        if !character.is_ascii_alphanumeric() && character != '_' {
            return false;
        }
    }

    !KEYWORDS.contains(&name)
}
