import challenge

set_option maxRecDepth 16384
set_option maxHeartbeats 0

namespace VoltaProofs

lemma sig_close (a D : ℝ) (hD : |D| ≤ 1) :
    |1 / (Real.exp (a + D) + 1) - 1 / (1 + Real.exp a)| ≤ 2 * |D| := by
  have h1 := Real.abs_exp_sub_one_le hD
  rw [Real.exp_add]
  have hXp : 0 < Real.exp a := Real.exp_pos a
  have hYp : 0 < Real.exp D := Real.exp_pos D
  have hne1 : Real.exp a * Real.exp D + 1 ≠ 0 := by positivity
  have hne2 : 1 + Real.exp a ≠ 0 := by positivity
  have key : 1 / (Real.exp a * Real.exp D + 1) - 1 / (1 + Real.exp a)
      = Real.exp a * (1 - Real.exp D) / ((Real.exp a * Real.exp D + 1) * (1 + Real.exp a)) := by
    rw [div_sub_div _ _ hne1 hne2]; congr 1; ring
  have hpos : (0:ℝ) < (Real.exp a * Real.exp D + 1) * (1 + Real.exp a) := by positivity
  rw [key, abs_div, abs_mul, abs_of_pos hXp, abs_of_pos hpos, div_le_iff₀ hpos, abs_sub_comm]
  have hz : 0 ≤ |Real.exp D - 1| := abs_nonneg _
  have hb : Real.exp a ≤ (Real.exp a * Real.exp D + 1) * (1 + Real.exp a) := by
    nlinarith [mul_pos hXp hYp, mul_pos (mul_pos hXp hXp) hYp]
  calc Real.exp a * |Real.exp D - 1|
      ≤ ((Real.exp a * Real.exp D + 1) * (1 + Real.exp a)) * |Real.exp D - 1| :=
        mul_le_mul_of_nonneg_right hb hz
    _ ≤ ((Real.exp a * Real.exp D + 1) * (1 + Real.exp a)) * (2 * |D|) :=
        mul_le_mul_of_nonneg_left h1 hpos.le
    _ = 2 * |D| * ((Real.exp a * Real.exp D + 1) * (1 + Real.exp a)) := by ring

lemma small_pos (t : ℝ) (ht : 999 ≤ t) :
    0 < 1 / (Real.exp t + 1) ∧ 1 / (Real.exp t + 1) ≤ 1 / 1000 := by
  have h := Real.add_one_le_exp t
  have hp : 0 < Real.exp t + 1 := by positivity
  refine ⟨by positivity, ?_⟩
  rw [div_le_iff₀ hp]
  linarith

lemma small_neg (t : ℝ) (ht : t ≤ -999) :
    999 / 1000 ≤ 1 / (Real.exp t + 1) ∧ 1 / (Real.exp t + 1) ≤ 1 := by
  have h := Real.add_one_le_exp (-t)
  have hu : 0 < Real.exp t := Real.exp_pos t
  have huv : Real.exp t * Real.exp (-t) = 1 := by
    rw [← Real.exp_add, add_neg_cancel, Real.exp_zero]
  have h2 : Real.exp t * 1000 ≤ Real.exp t * Real.exp (-t) :=
    mul_le_mul_of_nonneg_left (by linarith) hu.le
  have hp : 0 < Real.exp t + 1 := by positivity
  constructor
  · rw [le_div_iff₀ hp]; linarith
  · rw [div_le_one hp]; linarith

theorem key (E s : ℝ) (hs : s = -E) :
    |((1 : ℝ) / ((Real.exp (((E * (338819 / 2 ^ 44 : ℝ)) + ((E * (12102203 / 2 ^ 23 : ℝ)) + (-(((min (max ((E * (12294301 / 2 ^ 31 : ℝ)) + (0.5 : ℝ)) (0 : ℝ)) (1 : ℝ) * (252 : ℝ)) + (12582913 : ℝ)) + (-12583039 : ℝ))))) * (8388608 / 12102203 : ℝ)) * Real.exp ((((min (max ((E * (12294301 / 2 ^ 31 : ℝ)) + (0.5 : ℝ)) (0 : ℝ)) (1 : ℝ) * (252 : ℝ)) + (12582913 : ℝ)) - (12583039 : ℝ)) * Real.log (2 : ℝ))) + (1 : ℝ))) - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-s)))| ≤ (0.001 : ℝ) := by
  subst hs
  rw [neg_neg]
  generalize hm : min (max ((E * (12294301 / 2 ^ 31 : ℝ)) + (0.5 : ℝ)) (0 : ℝ)) (1 : ℝ) = m
  have hm0 : 0 ≤ m := by rw [← hm]; exact le_min (le_max_right _ _) zero_le_one
  have hm1 : m ≤ 1 := by rw [← hm]; exact min_le_right _ _
  have hexp : Real.exp ((E * (338819 / 2 ^ 44 : ℝ) + (E * (12102203 / 2 ^ 23 : ℝ) + -((m * 252 + 12582913) + (-12583039 : ℝ)))) * (8388608 / 12102203 : ℝ)) * Real.exp (((m * 252 + 12582913) - 12583039) * Real.log 2)
      = Real.exp (E + (E * (338819 / (2 ^ 21 * 12102203)) + (m * 252 - 126) * (Real.log 2 - 8388608 / 12102203))) := by
    rw [← Real.exp_add]; congr 1; ring
  rw [hexp]
  have hδ0 : (0:ℝ) ≤ 338819 / (2 ^ 21 * 12102203) := by norm_num
  have hδ1 : (338819 / (2 ^ 21 * 12102203) : ℝ) ≤ 2 / 10 ^ 8 := by norm_num
  generalize (338819 / (2 ^ 21 * 12102203) : ℝ) = δ at hδ0 hδ1 ⊢
  have hl1 : (6931471803 / 10 ^ 10 : ℝ) < Real.log 2 :=
    lt_of_le_of_lt (by norm_num) Real.log_two_gt_d9
  have hl2 : Real.log 2 < (6931471808 / 10 ^ 10 : ℝ) :=
    lt_of_lt_of_le Real.log_two_lt_d9 (by norm_num)
  have hc : |Real.log 2 - 8388608 / 12102203| ≤ 1 / 10 ^ 8 := by
    rw [abs_le]; constructor <;> linarith
  have hn : |m * 252 - 126| ≤ 126 := by rw [abs_le]; constructor <;> linarith
  have hnc : |(m * 252 - 126) * (Real.log 2 - 8388608 / 12102203)| ≤ 126 / 10 ^ 8 := by
    rw [abs_mul]
    calc _ ≤ 126 * (1 / 10 ^ 8) := mul_le_mul hn hc (abs_nonneg _) (by norm_num)
      _ = 126 / 10 ^ 8 := by ring
  generalize (m * 252 - 126) * (Real.log 2 - 8388608 / 12102203) = r at hnc ⊢
  rw [abs_le] at hnc
  obtain ⟨r1, r2⟩ := hnc
  have h001 : (0.001 : ℝ) = 1 / 1000 := by norm_num
  rw [h001]
  rcases le_or_gt (|E|) 10000 with hE | hE
  · have hEδ : |E * δ| ≤ 10000 * δ := by
      rw [abs_mul, abs_of_nonneg hδ0]; exact mul_le_mul_of_nonneg_right hE hδ0
    rw [abs_le] at hEδ
    obtain ⟨e1, e2⟩ := hEδ
    have hD : |E * δ + r| ≤ 1 / 2000 := by rw [abs_le]; constructor <;> linarith
    have := sig_close E (E * δ + r) (by linarith)
    linarith
  · rcases lt_or_ge 0 E with hpos | hneg
    · rw [abs_of_pos hpos] at hE
      have hEδ : 0 ≤ E * δ := mul_nonneg hpos.le hδ0
      obtain ⟨a1, a2⟩ := small_pos (E + (E * δ + r)) (by linarith)
      obtain ⟨b1, b2⟩ := small_pos E (by linarith)
      rw [add_comm 1 (Real.exp E)]
      rw [abs_le]; constructor <;> linarith
    · rw [abs_of_nonpos hneg] at hE
      have hEδ : E * δ ≤ 0 := by nlinarith
      obtain ⟨a1, a2⟩ := small_neg (E + (E * δ + r)) (by linarith)
      obtain ⟨b1, b2⟩ := small_neg E (by linarith)
      rw [add_comm 1 (Real.exp E)]
      rw [abs_le]; constructor <;> linarith

theorem c_0 : VoltaChallenge.c_0 := by
  unfold VoltaChallenge.c_0
  intros
  rename_i x0 x1
  revert x0
  exact key _ _ (by ring)
theorem c_1 : VoltaChallenge.c_1 := by
  unfold VoltaChallenge.c_1
  intros
  rename_i x0 x1
  revert x0
  exact key _ _ (by ring)
theorem c_16 : VoltaChallenge.c_16 := by
  unfold VoltaChallenge.c_16
  intros
  rename_i x0 x1
  revert x0
  exact key _ _ (by ring)
theorem c_256 : VoltaChallenge.c_256 := by
  unfold VoltaChallenge.c_256
  intros
  rename_i x0 x1
  revert x0
  exact key _ _ (by ring)
theorem c_272 : VoltaChallenge.c_272 := by
  unfold VoltaChallenge.c_272
  intros
  rename_i x0 x1
  revert x0
  exact key _ _ (by ring)
theorem c_1024 : VoltaChallenge.c_1024 := by
  unfold VoltaChallenge.c_1024
  intros
  rename_i x0 x1
  revert x0
  exact key _ _ (by ring)
theorem c_1025 : VoltaChallenge.c_1025 := by
  unfold VoltaChallenge.c_1025
  intros
  rename_i x0 x1
  revert x0
  exact key _ _ (by ring)
theorem c_3104 : VoltaChallenge.c_3104 := by
  unfold VoltaChallenge.c_3104
  intros
  rename_i x0 x1
  revert x0
  exact key _ _ (by ring)

end VoltaProofs
