//! Matching the operands of a commutative operation without caring about their order.

/// `f(a, b)`, else `f(b, a)`: the operands of a commutative operation, in either order.
pub fn either<A: Copy, T>(a: A, b: A, f: impl Fn(A, A) -> Option<T>) -> Option<T> {
    f(a, b).or_else(|| f(b, a))
}
