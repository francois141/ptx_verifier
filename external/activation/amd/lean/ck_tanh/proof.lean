import challenge

set_option maxRecDepth 16384
set_option maxHeartbeats 0

namespace VoltaProofs

lemma hX_eq (F : ℝ) (hF : 0 ≤ F) : 1 / (1 + F) * -2 + 1 = (F - 1) / (F + 1) := by
  have h1 : (1 + F) ≠ 0 := by positivity
  have h2 : (F + 1) ≠ 0 := by positivity
  rw [eq_div_iff h2]
  have := one_div_mul_cancel h1
  linear_combination (-2) * this

lemma hT_eq (E F : ℝ) (hE : 0 < E) (hF : 0 < F) (hEF : E * F = 1) :
    (E - 1) / (E + 1) = -((F - 1) / (F + 1)) := by
  rw [neg_div', div_eq_div_iff (by positivity) (by positivity)]
  linear_combination 2 * hEF

lemma algA (E : ℝ) (hE : 1 ≤ E) :
    |(|1 / (1 + E) * -2 + 1|) - (E - 1) / (E + 1)| ≤ (0.001 : ℝ) := by
  have hX0 : 0 ≤ (E - 1) / (E + 1) := div_nonneg (by linarith) (by linarith)
  rw [hX_eq E (by linarith), abs_of_nonneg hX0, sub_self, abs_zero]
  norm_num

lemma algB (E F : ℝ) (hE : 0 < E) (hF : 1 ≤ F) (hEF : E * F = 1) :
    |-(|1 / (1 + F) * -2 + 1|) - (E - 1) / (E + 1)| ≤ (0.001 : ℝ) := by
  have hX0 : 0 ≤ (F - 1) / (F + 1) := div_nonneg (by linarith) (by linarith)
  rw [hX_eq F (by linarith), abs_of_nonneg hX0, hT_eq E F hE (by linarith) hEF]
  rw [show -((F - 1) / (F + 1)) - -((F - 1) / (F + 1)) = 0 by ring, abs_zero]
  norm_num

lemma algC (Pv E F : ℝ) (hE : 0 < E) (hF : 0 < F) (hEF : E * F = 1)
    (hb : |Pv - (F - 1) / (F + 1)| ≤ (0.001 : ℝ)) :
    |-Pv - (E - 1) / (E + 1)| ≤ (0.001 : ℝ) := by
  rw [hT_eq E F hE hF hEF, show -Pv - -((F - 1) / (F + 1)) = -(Pv - (F - 1) / (F + 1)) by ring,
    abs_neg]
  exact hb

lemma poly_bound (t : ℝ) (h0 : 0 ≤ t) (h1 : t < (0.625 : ℝ)) :
    |(((t * t) * ((((t * t) * (((t * t) * (((t * t) * (((-12240701 / 2 ^ 31 : ℝ) * (t * t)) + (11077833 / 2 ^ 29 : ℝ))) + (-7212583 / 2 ^ 27 : ℝ))) + (4473281 / 2 ^ 25 : ℝ))) + (-11184793 / 2 ^ 25 : ℝ)) * t)) + t)
      - (Real.exp ((2 : ℝ) * t) - (1 : ℝ)) / (Real.exp ((2 : ℝ) * t) + (1 : ℝ))| ≤ (0.001 : ℝ)
    ∧ 0 ≤ (((t * t) * ((((t * t) * (((t * t) * (((t * t) * (((-12240701 / 2 ^ 31 : ℝ) * (t * t)) + (11077833 / 2 ^ 29 : ℝ))) + (-7212583 / 2 ^ 27 : ℝ))) + (4473281 / 2 ^ 25 : ℝ))) + (-11184793 / 2 ^ 25 : ℝ)) * t)) + t) := by
  have ht : t ≤ 5 / 8 := by norm_num at h1; linarith
  have hk : ∀ k : ℕ, t ^ k ≤ (5 / 8 : ℝ) ^ k := fun k => pow_le_pow_left₀ h0 ht k
  have hn : ∀ k : ℕ, 0 ≤ t ^ k := fun k => pow_nonneg h0 k
  have hlo : 1 + t + t ^ 2 / 2 + t ^ 3 / 6 + t ^ 4 / 24 + t ^ 5 / 120 + t ^ 6 / 720 ≤ Real.exp t := by
    have := Real.sum_le_exp_of_nonneg h0 7
    norm_num [Finset.sum_range_succ, Nat.factorial] at this
    linarith
  have hhi : Real.exp t ≤ 1 + t + t ^ 2 / 2 + t ^ 3 / 6 + t ^ 4 / 24 + t ^ 5 / 120 + t ^ 6 / 720
      + t ^ 7 / 4410 := by
    have := Real.exp_bound' h0 (by linarith) (n := 7) (by norm_num)
    norm_num [Finset.sum_range_succ, Nat.factorial] at this
    linarith
  have hQ : 0 ≤ 1 + (-11184793 / 2 ^ 25 : ℝ) * t ^ 2 + (4473281 / 2 ^ 25 : ℝ) * t ^ 4
      + (-7212583 / 2 ^ 27 : ℝ) * t ^ 6 + (11077833 / 2 ^ 29 : ℝ) * t ^ 8
      + (-12240701 / 2 ^ 31 : ℝ) * t ^ 10 := by
    linarith only [hk 2, hk 4, hk 6, hk 8, hk 10, hn 2, hn 4, hn 6, hn 8, hn 10]
  have hPpos : 0 ≤ (((t * t) * ((((t * t) * (((t * t) * (((t * t) * (((-12240701 / 2 ^ 31 : ℝ) * (t * t)) + (11077833 / 2 ^ 29 : ℝ))) + (-7212583 / 2 ^ 27 : ℝ))) + (4473281 / 2 ^ 25 : ℝ))) + (-11184793 / 2 ^ 25 : ℝ)) * t)) + t) := by
    have := mul_nonneg h0 hQ
    linarith
  refine ⟨?_, hPpos⟩
  generalize hPdef : (((t * t) * ((((t * t) * (((t * t) * (((t * t) * (((-12240701 / 2 ^ 31 : ℝ) * (t * t)) + (11077833 / 2 ^ 29 : ℝ))) + (-7212583 / 2 ^ 27 : ℝ))) + (4473281 / 2 ^ 25 : ℝ))) + (-11184793 / 2 ^ 25 : ℝ)) * t)) + t) = P at hPpos
  have hP1 : P ≤ 9 / 10 := by
    rw [← hPdef]
    linarith only [hk 1, hk 3, hk 5, hk 7, hk 9, hk 11, hn 1, hn 3, hn 5, hn 7, hn 9, hn 11]
  have hA : (1 + t + t ^ 2 / 2 + t ^ 3 / 6 + t ^ 4 / 24 + t ^ 5 / 120 + t ^ 6 / 720)
      * (1 + t + t ^ 2 / 2 + t ^ 3 / 6 + t ^ 4 / 24 + t ^ 5 / 120 + t ^ 6 / 720)
      * (1 - P + 1 / 1000) - (1 + P - 1 / 1000) ≥ 0 := by
    rw [← hPdef]
    linarith only [hk 1, hk 2, hk 3, hk 4, hk 5, hk 6, hk 7, hk 8, hk 9, hk 10, hk 11, hk 12,
      hk 13, hk 14, hk 15, hk 16, hk 17, hk 18, hk 19, hk 20, hk 21, hk 22, hk 23,
      hn 1, hn 2, hn 3, hn 4, hn 5, hn 6, hn 7, hn 8, hn 9, hn 10, hn 11, hn 12,
      hn 13, hn 14, hn 15, hn 16, hn 17, hn 18, hn 19, hn 20, hn 21, hn 22, hn 23]
  have hB : (1 + P + 1 / 1000) - (1 + t + t ^ 2 / 2 + t ^ 3 / 6 + t ^ 4 / 24 + t ^ 5 / 120
      + t ^ 6 / 720 + t ^ 7 / 4410) * (1 + t + t ^ 2 / 2 + t ^ 3 / 6 + t ^ 4 / 24 + t ^ 5 / 120
      + t ^ 6 / 720 + t ^ 7 / 4410) * (1 - P - 1 / 1000) ≥ 0 := by
    rw [← hPdef]
    linarith only [hk 1, hk 2, hk 3, hk 4, hk 5, hk 6, hk 7, hk 8, hk 9, hk 10, hk 11, hk 12,
      hk 13, hk 14, hk 15, hk 16, hk 17, hk 18, hk 19, hk 20, hk 21, hk 22, hk 23, hk 24, hk 25,
      hn 1, hn 2, hn 3, hn 4, hn 5, hn 6, hn 7, hn 8, hn 9, hn 10, hn 11, hn 12,
      hn 13, hn 14, hn 15, hn 16, hn 17, hn 18, hn 19, hn 20, hn 21, hn 22, hn 23, hn 24, hn 25]
  have hE : Real.exp ((2 : ℝ) * t) = Real.exp t * Real.exp t := by
    rw [← Real.exp_add]; ring_nf
  have hs0 : 0 < Real.exp t := Real.exp_pos t
  have hL0 : 0 ≤ 1 + t + t ^ 2 / 2 + t ^ 3 / 6 + t ^ 4 / 24 + t ^ 5 / 120 + t ^ 6 / 720 := by
    positivity
  have hsL := mul_self_le_mul_self hL0 hlo
  have hsU := mul_self_le_mul_self hs0.le hhi
  rw [hE]
  generalize Real.exp t = s at hsL hsU hs0
  generalize (1 + t + t ^ 2 / 2 + t ^ 3 / 6 + t ^ 4 / 24 + t ^ 5 / 120 + t ^ 6 / 720) = L at hA hsL
  generalize (1 + t + t ^ 2 / 2 + t ^ 3 / 6 + t ^ 4 / 24 + t ^ 5 / 120 + t ^ 6 / 720
      + t ^ 7 / 4410) = U at hB hsU
  have hden : 0 < s * s + 1 := by positivity
  have hA' := mul_le_mul_of_nonneg_right hsL (show (0 : ℝ) ≤ 1 - P + 1 / 1000 by linarith)
  have hB' := mul_le_mul_of_nonneg_right hsU (show (0 : ℝ) ≤ 1 - P - 1 / 1000 by linarith)
  have h1' : (P - 1 / 1000) * (s * s + 1) ≤ s * s - 1 := by nlinarith
  have h2' : s * s - 1 ≤ (P + 1 / 1000) * (s * s + 1) := by nlinarith
  have h1'' := (le_div_iff₀ hden).mpr h1'
  have h2'' := (div_le_iff₀ hden).mpr h2'
  rw [abs_sub_le_iff]
  norm_num
  constructor <;> linarith

theorem key (a b : ℝ) (h : a = b) :
    let x0 := a
    let x1 := (|x0|) + (|x0|)
    let x2 := Real.exp (if ((|x0|) ≥ (0.625 : ℝ)) ∧ ((-87.3365478515625 : ℝ) > x1) then ((|x0|) * (2 : ℝ)) + (64 : ℝ) else x1)
    let x3 := x0 * x0
    let x4 := |(if (|x0|) ≥ (0.625 : ℝ) then (((1 : ℝ) / ((1 : ℝ) + (if ((|x0|) ≥ (0.625 : ℝ)) ∧ ((-87.3365478515625 : ℝ) > x1) then (3330985 / 2 ^ 114 : ℝ) * x2 else x2))) * (-2 : ℝ)) + (1 : ℝ) else (x3 * (((x3 * ((x3 * ((x3 * (((-12240701 / 2 ^ 31 : ℝ) * x3) + (11077833 / 2 ^ 29 : ℝ))) + (-7212583 / 2 ^ 27 : ℝ))) + (4473281 / 2 ^ 25 : ℝ))) + (-11184793 / 2 ^ 25 : ℝ)) * (|x0|))) + (|x0|))|
    let x5 := b
    |(if x0 < (0 : ℝ) then -x4 else x4) - ((Real.exp ((2 : ℝ) * x5) - (1 : ℝ)) / (Real.exp ((2 : ℝ) * x5) + (1 : ℝ)))| ≤ (0.001 : ℝ) := by
  dsimp only
  subst h
  have hc2 : ¬ ((|a|) ≥ (0.625 : ℝ) ∧ (-87.3365478515625 : ℝ) > |a| + |a|) := by
    intro h
    have h' := h.2
    have := abs_nonneg a
    norm_num at h' <;> linarith
  by_cases hc : (|a|) ≥ (0.625 : ℝ)
  · simp only [if_pos hc, if_neg hc2]
    by_cases ha : a < 0
    · rw [if_pos ha, abs_of_neg ha]
      have hEF : Real.exp (2 * a) * Real.exp (-a + -a) = 1 := by
        rw [← Real.exp_add, show 2 * a + (-a + -a) = 0 by ring, Real.exp_zero]
      exact algB _ _ (Real.exp_pos _) (Real.one_le_exp (by linarith)) hEF
    · rw [if_neg ha, abs_of_nonneg (not_lt.mp ha), show a + a = 2 * a by ring]
      exact algA _ (Real.one_le_exp (by linarith [not_lt.mp ha]))
  · simp only [if_neg hc]
    rw [← abs_mul_abs_self a]
    have hlt : |a| < (0.625 : ℝ) := not_le.mp hc
    obtain ⟨hb, hpos⟩ := poly_bound |a| (abs_nonneg a) hlt
    rw [abs_of_nonneg hpos]
    by_cases ha : a < 0
    · rw [if_pos ha]
      have hEF : Real.exp (2 * a) * Real.exp (2 * |a|) = 1 := by
        rw [abs_of_neg ha, ← Real.exp_add, show 2 * a + 2 * -a = 0 by ring, Real.exp_zero]
      exact algC _ _ _ (Real.exp_pos _) (Real.exp_pos _) hEF hb
    · rw [if_neg ha]
      have habs : |a| = a := abs_of_nonneg (not_lt.mp ha)
      rw [habs] at hb
      rw [habs]
      exact hb

theorem c_0 : VoltaChallenge.c_0 := by
  unfold VoltaChallenge.c_0
  iterate 512 intro
  exact key _ _ (by ring)
theorem c_64 : VoltaChallenge.c_64 := by
  unfold VoltaChallenge.c_64
  iterate 512 intro
  exact key _ _ (by ring)
theorem c_4096 : VoltaChallenge.c_4096 := by
  unfold VoltaChallenge.c_4096
  iterate 512 intro
  exact key _ _ (by ring)

end VoltaProofs
