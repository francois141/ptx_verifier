//! Generate Lean 4 statements that compare candidate outputs with baseline outputs.
//!
//! Each output element gets one `Prop`: the values must either be equal or differ by
//! at most a given tolerance. Proofs belong in a separate module so that proving a
//! statement does not change what it claims.

use std::collections::{BTreeSet, HashMap};
use std::fmt::{self, Write as _};

use rug::{Integer, Rational};

use crate::outputs::SymbolicOutputs;
use crate::symbolic::{ExprArena, ExprId, ExprNode, RealRepr};
use crate::text::op_name;

/// What each statement claims of a candidate value `c` and its baseline value `b`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Claim {
    /// `c = b`.
    Equal,

    /// `|c - b| ≤ tolerance`.
    Within(Rational),
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

    /// An array or parameter name that would capture a name the statements use.
    ReservedName(String),

    /// Two inputs that would become the same Lean variable (a parameter `a_0` and `a[0]`).
    DuplicateName(String),

    /// A node with no real-number meaning: bitwise ops, infinities, undefined values.
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
            Self::ReservedName(name) => write!(
                f,
                "`{name}` would capture a name the Lean statements use; rename it"
            ),
            Self::DuplicateName(name) => write!(
                f,
                "two inputs would both become the Lean variable `{name}`; rename one"
            ),
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

/// Generate a Lean module with one `def <array>_<index> : Prop` per output element.
/// Each definition compares the candidate and baseline using `claim`.
///
/// Each input element `a[i]` becomes the real variable `a_i`. Repeated
/// expressions use `let` bindings. The generated code follows Lean's arithmetic
/// rules, including `x / 0 = 0` and its definitions of `log` and `sqrt`.
pub fn to_lean(
    candidate: &SymbolicOutputs,
    baseline: &SymbolicOutputs,
    arrays: &[String],
    claim: &Claim,
    namespace: &str,
) -> Result<String, LeanError> {
    validate_request(arrays, claim, namespace)?;

    let mut out = String::new();
    write_module_header(&mut out, claim, namespace);

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
            let mut variables = BTreeSet::new();

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

            write_statement(&mut out, array, index, &variables, &bindings, &body)?;
        }
    }

    writeln!(out, "\nend {namespace}\n\nend").unwrap();

    Ok(out)
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

fn write_module_header(out: &mut String, claim: &Claim, namespace: &str) {
    let relation = match claim {
        Claim::Equal => "is equal to".to_string(),
        Claim::Within(tolerance) => format!("is within {} of", format_rational(tolerance)),
    };

    writeln!(
        out,
        "import Mathlib

/-!
Generated by Volta: each definition states that one output element of the candidate
{relation} the same element of the baseline. Each input element `a[i]` is the real `a_i`.
Prove `theorem <name> : {namespace}.<name>` in another module without editing this file.
-/

noncomputable section

namespace {namespace}"
    )
    .unwrap();
}

fn write_statement(
    out: &mut String,
    array: &str,
    index: u64,
    variables: &BTreeSet<Variable>,
    bindings: &[(String, String)],
    body: &str,
) -> Result<(), LeanError> {
    let name = lean_identifier(&format!("{array}_{index}"));
    writeln!(out, "\n/-- `{array}[{index}]` -/\ndef {name} : Prop :=").unwrap();

    let mut indent = "  ";

    if !variables.is_empty() {
        let mut names = Vec::new();

        for variable in variables {
            let name = variable.name()?;
            if names.contains(&name) {
                return Err(LeanError::DuplicateName(name));
            }
            names.push(name);
        }

        writeln!(out, "  ∀ ({} : ℝ),", names.join(" ")).unwrap();
        indent = "    ";
    }

    for (name, value) in bindings {
        writeln!(out, "{indent}let {name} := {value}").unwrap();
    }

    writeln!(out, "{indent}{body}").unwrap();

    Ok(())
}

#[derive(Clone, Copy)]
struct OutputElement<'a> {
    side: Side,
    array: &'a str,
    index: u64,
}

/// A statement's universally quantified real variables, input elements first.
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
enum Variable {
    Element(String, u64),
    Parameter(String),
    Machine(u64),
}

impl Variable {
    fn name(&self) -> Result<String, LeanError> {
        match self {
            Variable::Element(array, index) => element_identifier(array, *index),
            Variable::Parameter(name) => user_identifier(name),
            Variable::Machine(id) => Ok(machine_name(*id)),
        }
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
    variables: &mut BTreeSet<Variable>,
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
    variables: &mut BTreeSet<Variable>,
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
            RealRepr::NegInf | RealRepr::PosInf => return Err(element.unsupported(node)),
        },

        BoolConst(b) => Term::new(
            TermType::Prop,
            Atomic,
            if *b { "True" } else { "False" }.into(),
        ),

        Symbol(s) => {
            variables.insert(Variable::Machine(s.0));
            Term::new(TermType::Real, Atomic, machine_name(s.0))
        }

        ParamSymbol(name) => {
            let name = arena.string(*name);
            variables.insert(Variable::Parameter(name.to_string()));
            Term::new(TermType::Real, Atomic, user_identifier(name)?)
        }

        InputElement { array, index } => {
            let name = arena.string(*array);
            variables.insert(Variable::Element(name.to_string(), *index));
            Term::new(TermType::Real, Atomic, element_identifier(name, *index)?)
        }

        SymbolicRead { .. }
        | Discarded
        | Undefined
        | Rem(..)
        | BitNot(_)
        | BitAnd(..)
        | BitOr(..)
        | BitXor(..)
        | Shl(..)
        | Shr(..)
        | LShr(..) => {
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

        Rcp(a) => Term::new(
            TermType::Real,
            Application,
            format!("{}⁻¹", operands.real(*a)?.argument()),
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

        Fma(a, b, c) => {
            let text = format!(
                "{} * {} + {}",
                operands.real(*a)?.operand(),
                operands.real(*b)?.operand(),
                operands.real(*c)?.operand()
            );
            Term::new(TermType::Real, Compound, text)
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

fn element_identifier(array: &str, index: u64) -> Result<String, LeanError> {
    user_identifier(&format!("{array}_{index}"))
}

fn machine_name(id: u64) -> String {
    format!("sym{id}")
}

/// Names the statements bind (`x0`, `sym0`, ...) or refer to.
fn is_reserved_name(name: &str) -> bool {
    let numbered = |prefix: &str| {
        name.strip_prefix(prefix)
            .is_some_and(|n| !n.is_empty() && n.bytes().all(|b| b.is_ascii_digit()))
    };
    numbered("x") || numbered("sym") || ["Real", "min", "max", "True", "False"].contains(&name)
}

fn user_identifier(name: &str) -> Result<String, LeanError> {
    if is_reserved_name(name) || name.contains('»') {
        return Err(LeanError::ReservedName(name.to_string()));
    }

    Ok(lean_identifier(name))
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
