import challenge
import Mathlib.Analysis.Complex.ExponentialBounds

set_option maxRecDepth 16384
set_option maxHeartbeats 0

namespace VoltaProofs

lemma bound (x : ℝ) (hx : (87.3365478515625 : ℝ) < x) (u : ℝ) (hu0 : 0 ≤ u)
    (hu : u ≤ 2 * Real.exp (-x)) :
    |1 / (1 + u) * x - x / (1 + Real.exp (-x))| ≤ (0.001 : ℝ) := by
  have hxpos : 0 < x := by linarith
  set w := Real.exp (-x) with hwdef
  have hw0 : 0 < w := Real.exp_pos _
  have hex : x ^ 4 / 24 ≤ Real.exp x := by
    have := Real.pow_div_factorial_le_exp x hxpos.le 4
    simpa [Nat.factorial] using this
  have hprod : Real.exp x * w = 1 := by
    rw [hwdef, ← Real.exp_add]; simp
  have hx3 : (80000 : ℝ) ≤ x ^ 3 := by nlinarith [sq_nonneg x, mul_pos hxpos hxpos]
  have hxw : x * w ≤ 0.0003 := by
    have h1 : x ≤ 0.0003 * Real.exp x := by
      have : x ≤ 0.0003 * (x ^ 4 / 24) := by
        have : x * 80000 ≤ x * x ^ 3 := mul_le_mul_of_nonneg_left hx3 hxpos.le
        nlinarith
      linarith
    have := mul_le_mul_of_nonneg_right h1 hw0.le
    nlinarith
  have hxu : x * u ≤ 2 * (x * w) := by nlinarith
  have hA1 : x / (1 + u) ≤ x := div_le_self hxpos.le (by linarith)
  have hA2 : x - x * u ≤ x / (1 + u) := by
    rw [le_div_iff₀ (by positivity)]; nlinarith [mul_nonneg hxpos.le (sq_nonneg u)]
  have hB1 : x / (1 + w) ≤ x := div_le_self hxpos.le (by linarith)
  have hB2 : x - x * w ≤ x / (1 + w) := by
    rw [le_div_iff₀ (by positivity)]; nlinarith [mul_nonneg hxpos.le (sq_nonneg w)]
  rw [one_div_mul_eq_div, abs_le]
  constructor <;> nlinarith

lemma key (x0 x2 : ℝ) (h : x0 = x2) :
    |((1 : ℝ) / ((1 : ℝ) + (if (87.3365478515625 : ℝ) < x0 then (3330985 / 2 ^ 114 : ℝ) * Real.exp (-(if (87.3365478515625 : ℝ) < x0 then (-64 : ℝ) + x0 else x0)) else Real.exp (-(if (87.3365478515625 : ℝ) < x0 then (-64 : ℝ) + x0 else x0)))) * x0) - (x2 / ((1 : ℝ) + Real.exp (-x2)))| ≤ (0.001 : ℝ) := by
  subst h
  by_cases hx : (87.3365478515625 : ℝ) < x0
  · simp only [hx, if_true]
    have hw : Real.exp (-(-64 + x0)) = Real.exp 64 * Real.exp (-x0) := by
      rw [← Real.exp_add]; ring_nf
    have he64 : Real.exp 64 ≤ (2.7182818286 : ℝ) ^ 64 := by
      calc Real.exp 64 = (Real.exp 1) ^ 64 := by rw [← Real.exp_nat_mul]; norm_num
        _ ≤ (2.7182818286 : ℝ) ^ 64 :=
          pow_le_pow_left₀ (Real.exp_pos 1).le Real.exp_one_lt_d9.le 64
    have hc : (3330985 / 2 ^ 114 : ℝ) * Real.exp 64 ≤ 2 := by
      calc (3330985 / 2 ^ 114 : ℝ) * Real.exp 64
          ≤ (3330985 / 2 ^ 114 : ℝ) * (2.7182818286 : ℝ) ^ 64 :=
            mul_le_mul_of_nonneg_left he64 (by norm_num)
        _ ≤ 2 := by norm_num
    apply bound x0 hx
    · positivity
    · rw [hw, ← mul_assoc]
      exact mul_le_mul_of_nonneg_right hc (Real.exp_pos _).le
  · simp only [hx, if_false]
    rw [one_div_mul_eq_div, sub_self, abs_zero]
    norm_num

theorem c_0 : VoltaChallenge.c_0 := by
  unfold VoltaChallenge.c_0
  iterate 512 intro
  refine key _ _ ?_
  ring

end VoltaProofs
