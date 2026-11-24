//! Which checked elements state the same equivalence: their reference and optimized
//! expressions coincide once every symbolic atom is renamed in order of first use.
//!
//! The decision procedure treats every atom as a free variable, so its verdict on one such
//! element is its verdict on all of them, and each group is solved once.

use std::collections::HashMap;
use std::collections::hash_map::DefaultHasher;
use std::hash::{Hash, Hasher};
use std::mem::{Discriminant, discriminant};

use volta_expr::{ExprArena, ExprId, ExprNode, Real, SymbolRef};

/// One step of a pair's preorder walk; `Shared(n)` is the `n`-th node already walked.
#[derive(Debug, PartialEq, Eq, Hash)]
enum Token<'a> {
    Node(Discriminant<ExprNode>),
    Int(i64),
    Real(&'a Real),
    Bool(bool),
    Array(&'a str),
    Variable(usize),
    Shared(usize),
}

/// The pair `(reference, optimized)` as tokens: equal for two pairs exactly when they are
/// the same DAGs up to a renaming of their atoms.
fn shape<'a>(
    reference: (&'a ExprArena, ExprId),
    optimized: (&'a ExprArena, ExprId),
) -> Vec<Token<'a>> {
    let mut tokens = Vec::new();
    let mut variables: HashMap<SymbolRef<'a>, usize> = HashMap::new();
    let mut walked = 0;

    for (arena, root) in [reference, optimized] {
        let mut numbers: HashMap<ExprId, usize> = HashMap::new();
        let mut stack = vec![root];

        while let Some(id) = stack.pop() {
            if let Some(&number) = numbers.get(&id) {
                tokens.push(Token::Shared(number));
                continue;
            }
            numbers.insert(id, walked);
            walked += 1;

            let node = arena.node(id);
            tokens.push(Token::Node(discriminant(node)));

            if let Some(symbol) = node.symbol_ref(arena) {
                let next = variables.len();
                tokens.push(Token::Variable(*variables.entry(symbol).or_insert(next)));
            }
            match node {
                ExprNode::IntConst(value) => tokens.push(Token::Int(*value)),
                ExprNode::RealConst(value) => tokens.push(Token::Real(value)),
                ExprNode::BoolConst(value) => tokens.push(Token::Bool(*value)),
                ExprNode::SymbolicRead { array, .. } => {
                    tokens.push(Token::Array(arena.string(*array)));
                }
                _ => {}
            }

            let start = stack.len();
            node.for_each_child(|child| stack.push(child));
            stack[start..].reverse();
        }
    }

    tokens
}

fn fingerprint(tokens: &[Token]) -> u64 {
    let mut hasher = DefaultHasher::new();
    tokens.hash(&mut hasher);
    hasher.finish()
}

/// For each element, the position of the first element stating the same equivalence
/// (its own position when it is the first).
pub(crate) fn representatives(
    reference: &ExprArena,
    optimized: &ExprArena,
    elements: &[(ExprId, ExprId)],
) -> Vec<usize> {
    let mut by_fingerprint: HashMap<u64, Vec<usize>> = HashMap::new();
    let mut representatives = Vec::with_capacity(elements.len());

    for (position, &(r, o)) in elements.iter().enumerate() {
        let tokens = shape((reference, r), (optimized, o));
        let candidates = by_fingerprint.entry(fingerprint(&tokens)).or_default();

        let found = candidates.iter().copied().find(|&candidate| {
            let (cr, co) = elements[candidate];
            shape((reference, cr), (optimized, co)) == tokens
        });

        representatives.push(found.unwrap_or_else(|| {
            candidates.push(position);
            position
        }));
    }

    representatives
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn pairs_equal_up_to_renaming_their_atoms_share_a_representative() {
        let mut arena = ExprArena::new();
        let element = |arena: &mut ExprArena, array: &str, index| {
            let array = arena.intern_string(array);
            arena.input_element(array, index)
        };
        let pair = |arena: &mut ExprArena, i, j| {
            let (a, b) = (element(arena, "a", i), element(arena, "b", j));
            let product = arena.mul(a, b);
            let sum = arena.add(product, a);
            let one = arena.int(1);
            let shifted = arena.add(b, one);
            (sum, arena.mul(a, shifted))
        };

        let first = pair(&mut arena, 0, 0);
        let renamed = pair(&mut arena, 1, 1);
        let aliased = pair(&mut arena, 2, 2);
        let a3 = element(&mut arena, "a", 3);
        let collapsed = {
            let square = arena.mul(a3, a3);
            let sum = arena.add(square, a3);
            (sum, aliased.1)
        };

        let elements = [first, renamed, collapsed, aliased];
        assert_eq!(representatives(&arena, &arena, &elements), [0, 0, 2, 0]);
    }
}
