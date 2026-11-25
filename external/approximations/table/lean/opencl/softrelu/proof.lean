import challenge

set_option maxRecDepth 16384
set_option maxHeartbeats 0

namespace VoltaProofs

theorem stepB (a b r : ℝ) (n : ℕ) (ha : |a| ≤ (0.5:ℝ)) (hb : |b| ≤ (0.5:ℝ))
    (hr : |r| ≤ (n:ℝ)/4) : |a*b + r| ≤ ((n+1 : ℕ):ℝ)/4 := by
  have h : |a*b| ≤ 1/4 := by
    rw [abs_mul]; nlinarith [abs_nonneg a, abs_nonneg b]
  calc |a*b+r| ≤ |a*b| + |r| := abs_add_le _ _
    _ ≤ ((n+1 : ℕ):ℝ)/4 := by push_cast; linarith

theorem baseB (a b : ℝ) (ha : |a| ≤ (0.5:ℝ)) (hb : |b| ≤ (0.5:ℝ)) :
    |a*b| ≤ ((1 : ℕ):ℝ)/4 := by
  rw [abs_mul]; push_cast; nlinarith [abs_nonneg a, abs_nonneg b]

theorem key (x s : ℝ) (h : x = s) (hb' : |x| ≤ ((256:ℕ):ℝ)/4) :
    (let x1 := Real.exp (if (-87.3365478515625 : ℝ) > x then (64 : ℝ) + x else x)
    let x2 := (1 : ℝ) + (if (-87.3365478515625 : ℝ) > x then (3330985 / 2 ^ 114 : ℝ) * x1 else x1)
    |(((0.693147182464599609375 : ℝ) * (Real.log (if (1 / 2 ^ 126 : ℝ) > x2 then x2 * (4294967296 : ℝ) else x2) / (8388608 / 12102203 : ℝ))) + (if (1 / 2 ^ 126 : ℝ) > x2 then (-22.1807098388671875 : ℝ) else (0 : ℝ))) - Real.log ((1 : ℝ) + Real.exp s)| ≤ (0.001 : ℝ)) := by
  subst h
  have hb : |x| ≤ 64 := by norm_num at hb'; linarith
  intro x1 x2
  have h1 : ¬ ((-87.3365478515625 : ℝ) > x) := by
    have := (abs_le.mp hb).1
    norm_num; linarith
  have hx2 : x2 = 1 + Real.exp x := by simp only [x2, x1, if_neg h1]
  have h2 : ¬ ((1 / 2 ^ 126 : ℝ) > x2) := by
    rw [hx2]
    have := Real.exp_pos x
    have h3 : (1/2^126:ℝ) ≤ 1 := by norm_num
    push_neg; linarith
  simp only [if_neg h2]
  rw [hx2]
  have hL0 : 0 ≤ Real.log (1 + Real.exp x) := Real.log_nonneg (by linarith [Real.exp_pos x])
  have hL1 : Real.log (1 + Real.exp x) ≤ 65 := by
    rw [Real.log_le_iff_le_exp (by positivity)]
    have e1 : Real.exp x ≤ Real.exp 64 := Real.exp_le_exp.mpr (abs_le.mp hb).2
    have e2 : (1:ℝ) ≤ Real.exp 64 := Real.one_le_exp (by norm_num)
    have e3 : Real.exp 65 = Real.exp 1 * Real.exp 64 := by rw [← Real.exp_add]; norm_num
    have e4 : (2:ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp (1:ℝ)]
    rw [e3]; nlinarith
  generalize Real.log (1 + Real.exp x) = L at *
  rw [abs_le]; constructor <;> norm_num <;> nlinarith

theorem c_0 : VoltaChallenge.c_0 := by
  unfold VoltaChallenge.c_0
  intros
  refine key _ _ ?_ ?_
  · ring
  · repeat (first
      | exact baseB _ _ (by assumption) (by assumption)
      | refine stepB _ _ _ _ (by assumption) (by assumption) ?_)

end VoltaProofs
