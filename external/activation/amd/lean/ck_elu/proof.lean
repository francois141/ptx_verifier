import challenge

set_option maxRecDepth 16384
set_option maxHeartbeats 0

namespace VoltaProofs

lemma rint_near (y : ℝ) : |y - VoltaChallenge.rint y| ≤ 1/2 := by
  unfold VoltaChallenge.rint
  split_ifs with h1 h2
  · rw [h1]; norm_num
  · have : y - ((⌊y⌋ : ℝ) + 1) = -(1/2) := by linarith
    rw [this]; norm_num
  · exact abs_sub_round y

lemma polypart (r : ℝ) (hr : |r| ≤ 0.35) :
    |r * ((r * (r * (r * (r * (13710257 / 2 ^ 36 * r + 46743 / 2 ^ 25) + 8947705 / 2 ^ 30)
      + 11184769 / 2 ^ 28) + 11184811 / 2 ^ 26) + 1/2) * r) + r + 1 - Real.exp r| ≤ 2e-4 := by
  have hr1 : |r| ≤ 1 := by linarith
  have hb := Real.exp_bound hr1 (n := 5) (by norm_num)
  norm_num [Finset.sum_range_succ, Nat.factorial] at hb
  have h5 : |r|^5 ≤ 0.35^5 := pow_le_pow_left₀ (abs_nonneg r) hr 5
  have h2 : |r^2| ≤ 0.35^2 := by rw [abs_pow]; exact pow_le_pow_left₀ (abs_nonneg r) hr 2
  have h3 : |r^3| ≤ 0.35^3 := by rw [abs_pow]; exact pow_le_pow_left₀ (abs_nonneg r) hr 3
  have h4 : |r^4| ≤ 0.35^4 := by rw [abs_pow]; exact pow_le_pow_left₀ (abs_nonneg r) hr 4
  have h5' : |r^5| ≤ 0.35^5 := by rw [abs_pow]; exact pow_le_pow_left₀ (abs_nonneg r) hr 5
  have h6 : |r^6| ≤ 0.35^6 := by rw [abs_pow]; exact pow_le_pow_left₀ (abs_nonneg r) hr 6
  have h7 : |r^7| ≤ 0.35^7 := by rw [abs_pow]; exact pow_le_pow_left₀ (abs_nonneg r) hr 7
  rw [abs_le] at hb h2 h3 h4 h5' h6 h7 ⊢
  obtain ⟨a1, a2⟩ := hb
  obtain ⟨b2, c2⟩ := h2
  obtain ⟨b3, c3⟩ := h3
  obtain ⟨b4, c4⟩ := h4
  obtain ⟨b5, c5⟩ := h5'
  obtain ⟨b6, c6⟩ := h6
  obtain ⟨b7, c7⟩ := h7
  constructor <;> nlinarith

lemma core (x k r x4 : ℝ) (hkb : |12102203 / 2 ^ 23 * x - k| ≤ 1/2) (h0 : x ≤ 0) (h17 : -17 ≤ x)
    (hr : r = k * (1072225 / 2 ^ 49 : ℝ) + (k * (-0.693147182464599609375 : ℝ) + x))
    (hx4_def : x4 = Real.exp (k * (8388608 / 12102203 : ℝ))) :
    |(x4 * ((r * (((r * ((r * ((r * ((r * (((13710257 / 2 ^ 36 : ℝ) * r) + (46743 / 2 ^ 25 : ℝ))) + (8947705 / 2 ^ 30 : ℝ))) + (11184769 / 2 ^ 28 : ℝ))) + (11184811 / 2 ^ 26 : ℝ))) + (0.5 : ℝ)) * r)) + r)) + ((-1 : ℝ) + x4) - (Real.exp x - 1)| ≤ 0.001 := by
  have hlit : (-0.693147182464599609375 : ℝ) = -693147182464599609375 / 10^21 := by norm_num
  have hhalf : (0.5 : ℝ) = 1/2 := by norm_num
  rw [hlit] at hr
  rw [hhalf]
  rw [abs_le] at hkb
  obtain ⟨hk1, hk2⟩ := hkb
  have hrb : |r| ≤ 0.35 := by
    rw [abs_le]; constructor <;> rw [hr] <;> norm_num <;> linarith
  have hP := polypart r hrb
  set d := k * (8388608 / 12102203 : ℝ) + r - x with hd_def
  have hd : |d| ≤ 1e-6 := by
    rw [abs_le, hd_def, hr]; constructor <;> norm_num <;> linarith
  have hx4 : x4 ≤ 2.7182818286 := by
    have : x4 ≤ Real.exp 1 := by
      rw [hx4_def]; exact Real.exp_le_exp.mpr (by norm_num; linarith)
    linarith [Real.exp_one_lt_d9]
  have hx4pos : 0 < x4 := by rw [hx4_def]; exact Real.exp_pos _
  have hexp : x4 * Real.exp r = Real.exp x * Real.exp d := by
    rw [hx4_def, ← Real.exp_add, ← Real.exp_add, hd_def]; congr 1; ring
  have hed : |Real.exp d - 1| ≤ 2 * 1e-6 := by
    have := Real.abs_exp_sub_one_le (x := d) (by rw [abs_le] at hd ⊢; constructor <;> linarith)
    linarith
  have hex : Real.exp x ≤ 1 := by
    have := Real.exp_le_exp.mpr h0
    rwa [Real.exp_zero] at this
  have hexpos : 0 < Real.exp x := Real.exp_pos _
  set P := r * ((r * (r * (r * (r * (13710257 / 2 ^ 36 * r + 46743 / 2 ^ 25) + 8947705 / 2 ^ 30)
      + 11184769 / 2 ^ 28) + 11184811 / 2 ^ 26) + 1/2) * r) + r with hP_def
  have key : x4 * P + (-1 + x4) - (Real.exp x - 1)
      = x4 * (P + 1 - Real.exp r) + Real.exp x * (Real.exp d - 1) := by
    linear_combination hexp
  rw [key]
  have hP' : |P + 1 - Real.exp r| ≤ 2e-4 := hP
  calc |x4 * (P + 1 - Real.exp r) + Real.exp x * (Real.exp d - 1)|
      ≤ |x4 * (P + 1 - Real.exp r)| + |Real.exp x * (Real.exp d - 1)| := abs_add_le _ _
    _ = x4 * |P + 1 - Real.exp r| + Real.exp x * |Real.exp d - 1| := by
        rw [abs_mul, abs_mul, abs_of_pos hx4pos, abs_of_pos hexpos]
    _ ≤ 2.7182818286 * 2e-4 + 1 * (2 * 1e-6) := by
        gcongr
    _ ≤ 0.001 := by norm_num

lemma tail (x0 : ℝ) (hneg : x0 ≤ 0) (h17 : ¬ (-17:ℝ) ≤ x0) :
    |-1 - (Real.exp x0 - 1)| ≤ (0.001 : ℝ) := by
  have h1 : (25/8 : ℝ) ≤ Real.exp (17/8) := by
    have := Real.add_one_le_exp (17/8 : ℝ); linarith
  have h2 : (25/8:ℝ)^8 ≤ Real.exp (17/8) ^ 8 := pow_le_pow_left₀ (by norm_num) h1 8
  have h3 : Real.exp (17/8) ^ 8 = Real.exp 17 := by
    rw [← Real.exp_nat_mul]; norm_num
  have h4 : Real.exp x0 * Real.exp 17 ≤ 1 := by
    rw [← Real.exp_add]
    have := Real.exp_le_exp.mpr (show x0 + 17 ≤ 0 by linarith)
    rwa [Real.exp_zero] at this
  have hp := Real.exp_pos x0
  have h5 : Real.exp x0 ≤ 0.001 := by nlinarith
  rw [abs_le]; constructor <;> linarith

theorem gen (x0 x7 : ℝ) (h : x0 = x7) :
    let x1 := (12102203 / 2 ^ 23 : ℝ) * x0
    let x2 := VoltaChallenge.rint x1
    let x3 := (x2 * (1072225 / 2 ^ 49 : ℝ)) + ((x2 * (-0.693147182464599609375 : ℝ)) + x0)
    let x4 := Real.exp ((if ((0 : ℝ) ≥ x0) ∧ ((128 : ℝ) = x2) then (127 : ℝ) else VoltaChallenge.rint x1) * (8388608 / 12102203 : ℝ))
    let x5 := (x4 * ((x3 * (((x3 * ((x3 * ((x3 * ((x3 * (((13710257 / 2 ^ 36 : ℝ) * x3) + (46743 / 2 ^ 25 : ℝ))) + (8947705 / 2 ^ 30 : ℝ))) + (11184769 / 2 ^ 28 : ℝ))) + (11184811 / 2 ^ 26 : ℝ))) + (0.5 : ℝ)) * x3)) + x3)) + ((-1 : ℝ) + x4)
    let x6 := if ((0 : ℝ) ≥ x0) ∧ ((-17 : ℝ) ≤ x0) then if ((0 : ℝ) ≥ x0) ∧ ((128 : ℝ) = x2) then x5 + x5 else x5 else (-1 : ℝ)
    |(if (0 : ℝ) ≥ x0 then x6 else if (0 : ℝ) ≥ x0 then x6 else x0) - (max x7 (0 : ℝ) + (Real.exp (min x7 (0 : ℝ)) - (1 : ℝ)))| ≤ (0.001 : ℝ) := by
  subst h
  dsimp only
  have hkb := rint_near ((12102203 / 2 ^ 23 : ℝ) * x0)
  generalize VoltaChallenge.rint ((12102203 / 2 ^ 23 : ℝ) * x0) = k at hkb ⊢
  rcases le_or_gt x0 0 with hneg | hpos
  · have hge : (0:ℝ) ≥ x0 := hneg
    have hne : ¬ ((0:ℝ) ≥ x0 ∧ (128:ℝ) = k) := fun h => by
      rw [abs_le] at hkb; linarith [h.2]
    simp only [if_pos hge, if_neg hne]
    rw [max_eq_right hneg, min_eq_left hneg, zero_add]
    by_cases h17 : (-17:ℝ) ≤ x0
    · rw [if_pos (show (0:ℝ) ≥ x0 ∧ (-17:ℝ) ≤ x0 from ⟨hge, h17⟩)]
      generalize hr : k * (1072225 / 2 ^ 49 : ℝ) + (k * (-0.693147182464599609375 : ℝ) + x0) = r
      generalize hx4 : Real.exp (k * (8388608 / 12102203 : ℝ)) = x4
      exact core x0 k r x4 hkb hneg h17 hr.symm hx4.symm
    · rw [if_neg (fun h => h17 h.2)]
      exact tail x0 hneg h17
  · have hng : ¬ ((0:ℝ) ≥ x0) := not_le.mpr hpos
    simp only [if_neg hng]
    rw [max_eq_left hpos.le, min_eq_right hpos.le]
    norm_num

theorem gen2 (x0 x6 : ℝ) (h : x0 = x6) :
    let x1 := (12102203 / 2 ^ 23 : ℝ) * x0
    let x2 := VoltaChallenge.rint x1
    let x3 := (x2 * (1072225 / 2 ^ 49 : ℝ)) + ((x2 * (-0.693147182464599609375 : ℝ)) + x0)
    let x4 := Real.exp ((if ((0 : ℝ) ≥ x0) ∧ ((128 : ℝ) = x2) then (127 : ℝ) else VoltaChallenge.rint x1) * (8388608 / 12102203 : ℝ))
    let x5 := (x4 * ((x3 * (((x3 * ((x3 * ((x3 * ((x3 * (((13710257 / 2 ^ 36 : ℝ) * x3) + (46743 / 2 ^ 25 : ℝ))) + (8947705 / 2 ^ 30 : ℝ))) + (11184769 / 2 ^ 28 : ℝ))) + (11184811 / 2 ^ 26 : ℝ))) + (0.5 : ℝ)) * x3)) + x3)) + ((-1 : ℝ) + x4)
    |(if (0 : ℝ) ≥ x0 then (if ((0 : ℝ) ≥ x0) ∧ ((-17 : ℝ) ≤ x0) then if ((0 : ℝ) ≥ x0) ∧ ((128 : ℝ) = x2) then x5 + x5 else x5 else (-1 : ℝ)) else x0) - (max x6 (0 : ℝ) + (Real.exp (min x6 (0 : ℝ)) - (1 : ℝ)))| ≤ (0.001 : ℝ) := by
  subst h
  dsimp only
  have hkb := rint_near ((12102203 / 2 ^ 23 : ℝ) * x0)
  generalize VoltaChallenge.rint ((12102203 / 2 ^ 23 : ℝ) * x0) = k at hkb ⊢
  rcases le_or_gt x0 0 with hneg | hpos
  · have hge : (0:ℝ) ≥ x0 := hneg
    have hne : ¬ ((0:ℝ) ≥ x0 ∧ (128:ℝ) = k) := fun h => by
      rw [abs_le] at hkb; linarith [h.2]
    simp only [if_pos hge, if_neg hne]
    rw [max_eq_right hneg, min_eq_left hneg, zero_add]
    by_cases h17 : (-17:ℝ) ≤ x0
    · rw [if_pos (show (0:ℝ) ≥ x0 ∧ (-17:ℝ) ≤ x0 from ⟨hge, h17⟩)]
      generalize hr : k * (1072225 / 2 ^ 49 : ℝ) + (k * (-0.693147182464599609375 : ℝ) + x0) = r
      generalize hx4 : Real.exp (k * (8388608 / 12102203 : ℝ)) = x4
      exact core x0 k r x4 hkb hneg h17 hr.symm hx4.symm
    · rw [if_neg (fun h => h17 h.2)]
      exact tail x0 hneg h17
  · have hng : ¬ ((0:ℝ) ≥ x0) := not_le.mpr hpos
    simp only [if_neg hng]
    rw [max_eq_left hpos.le, min_eq_right hpos.le]
    norm_num

theorem c_0 : VoltaChallenge.c_0 := by
  unfold VoltaChallenge.c_0
  intros
  first
  | exact gen _ _ (by ring)
  | exact gen2 _ _ (by ring)
theorem c_4 : VoltaChallenge.c_4 := by
  unfold VoltaChallenge.c_4
  intros
  first
  | exact gen _ _ (by ring)
  | exact gen2 _ _ (by ring)
theorem c_64 : VoltaChallenge.c_64 := by
  unfold VoltaChallenge.c_64
  intros
  first
  | exact gen _ _ (by ring)
  | exact gen2 _ _ (by ring)
theorem c_68 : VoltaChallenge.c_68 := by
  unfold VoltaChallenge.c_68
  intros
  first
  | exact gen _ _ (by ring)
  | exact gen2 _ _ (by ring)
theorem c_4096 : VoltaChallenge.c_4096 := by
  unfold VoltaChallenge.c_4096
  intros
  first
  | exact gen _ _ (by ring)
  | exact gen2 _ _ (by ring)
theorem c_4100 : VoltaChallenge.c_4100 := by
  unfold VoltaChallenge.c_4100
  intros
  first
  | exact gen _ _ (by ring)
  | exact gen2 _ _ (by ring)

end VoltaProofs
