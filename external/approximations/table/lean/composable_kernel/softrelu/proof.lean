import challenge

set_option maxRecDepth 16384
set_option maxHeartbeats 0

namespace VoltaProofs

theorem bnd_mul {a b : ℝ} (ha : |a| ≤ 0.5) (hb : |b| ≤ 0.5) : |a * b| ≤ 0.25 := by
  rw [abs_mul]
  calc |a| * |b| ≤ 0.5 * 0.5 := mul_le_mul ha hb (abs_nonneg _) (by norm_num)
    _ = 0.25 := by norm_num

theorem bnd_add {a b m n : ℝ} (ha : |a| ≤ m) (hb : |b| ≤ n) : |a + b| ≤ m + n :=
  (abs_add_le a b).trans (add_le_add ha hb)

theorem main (x y : ℝ) (hxy : x = y) (hb : |x| ≤ 64) :
    let x0 := x
    let x1 := Real.exp (if (-87.3365478515625 : ℝ) > x0 then x0 + (64 : ℝ) else x0)
    let x2 := if (-87.3365478515625 : ℝ) > x0 then (3330985 / 2 ^ 114 : ℝ) * x1 else x1
    |(((0.693147182464599609375 : ℝ) * (Real.log ((x2 * (if (1 / 2 ^ 126 : ℝ) > ((1 : ℝ) + x2) then (4294967296 : ℝ) else (1 : ℝ))) + (if (1 / 2 ^ 126 : ℝ) > ((1 : ℝ) + x2) then (4294967296 : ℝ) else (1 : ℝ))) / (8388608 / 12102203 : ℝ))) + (if (1 / 2 ^ 126 : ℝ) > ((1 : ℝ) + x2) then (-22.1807098388671875 : ℝ) else (0 : ℝ))) - Real.log ((1 : ℝ) + Real.exp y)| ≤ (0.001 : ℝ) := by
  intro x0 x1 x2
  dsimp only [x0, x1, x2]
  rw [← hxy]
  have hab := abs_le.mp hb
  have h1 : ¬ ((-87.3365478515625 : ℝ) > x) := by
    intro h; linarith [hab.1]
  have h2 : ¬ ((1 / 2 ^ 126 : ℝ) > 1 + Real.exp x) := by
    intro h
    have := Real.exp_pos x
    have : (1 / 2 ^ 126 : ℝ) < 1 := by norm_num
    linarith
  simp only [if_neg h1, if_neg h2, mul_one, add_zero]
  rw [add_comm (Real.exp x) 1]
  have hL0 : 0 ≤ Real.log (1 + Real.exp x) := Real.log_nonneg (by linarith [Real.exp_pos x])
  have hL1 : Real.log (1 + Real.exp x) ≤ 65 := by
    rw [Real.log_le_iff_le_exp (by positivity)]
    have e1 : Real.exp x ≤ Real.exp 64 := Real.exp_le_exp.mpr hab.2
    have e2 : (1:ℝ) ≤ Real.exp 64 := Real.one_le_exp (by norm_num)
    have e3 : Real.exp 65 = Real.exp 1 * Real.exp 64 := by rw [← Real.exp_add]; norm_num
    have e4 : (2:ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp (1:ℝ)]
    nlinarith
  generalize Real.log (1 + Real.exp x) = L at hL0 hL1 ⊢
  rw [abs_le]
  constructor <;> linarith

theorem c_0 : VoltaChallenge.c_0 := by
  unfold VoltaChallenge.c_0
  iterate 1024 intro
  refine main _ _ ?_ ?_
  · ring
  · apply le_trans
    · repeat' (first | (apply bnd_mul <;> assumption) | apply bnd_add)
    · norm_num
theorem c_64 : VoltaChallenge.c_64 := by
  unfold VoltaChallenge.c_64
  iterate 1024 intro
  refine main _ _ ?_ ?_
  · ring
  · apply le_trans
    · repeat' (first | (apply bnd_mul <;> assumption) | apply bnd_add)
    · norm_num
theorem c_4096 : VoltaChallenge.c_4096 := by
  unfold VoltaChallenge.c_4096
  iterate 1024 intro
  refine main _ _ ?_ ?_
  · ring
  · apply le_trans
    · repeat' (first | (apply bnd_mul <;> assumption) | apply bnd_add)
    · norm_num

end VoltaProofs
