import challenge

namespace VoltaProofs

noncomputable def T (v : ℝ) : ℝ := (Real.exp (2 * v) - 1) / (Real.exp (2 * v) + 1)

noncomputable def P (v : ℝ) : ℝ :=
  (((((((((4225089 / 2 ^ 28 : ℝ) * (v * v)) + (-7020119 / 2 ^ 27 : ℝ)) * (v * v)) + (8935745 / 2 ^ 26 : ℝ)) * (v * v)) + (-11184621 / 2 ^ 25 : ℝ)) * (v * v)) * v) + v

lemma exp_taylor (x : ℝ) (hx : |x| ≤ 1) :
    |Real.exp x - (1 + x + x^2/2 + x^3/6 + x^4/24 + x^5/120)| ≤ |x|^6 * (7/4320) := by
  calc |Real.exp x - (1 + x + x^2/2 + x^3/6 + x^4/24 + x^5/120)|
      = |Real.exp x - ∑ i ∈ Finset.range 6, x^i / (i.factorial : ℝ)| := by
        congr 2
        simp [Finset.sum_range_succ, Nat.factorial]
    _ ≤ _ := Real.exp_bound hx (by norm_num)
    _ = |x|^6 * (7/4320) := by norm_num [Nat.factorial]

lemma T_eq (v : ℝ) : T v = (Real.exp v - Real.exp (-v)) / (Real.exp v + Real.exp (-v)) := by
  unfold T
  have h2 : Real.exp (2*v) = Real.exp v * Real.exp v := by rw [← Real.exp_add]; ring_nf
  have hn : Real.exp (-v) = (Real.exp v)⁻¹ := Real.exp_neg v
  have hpos := Real.exp_pos v
  rw [h2, hn]
  field_simp

lemma T_neg (v : ℝ) : T (-v) = - T v := by
  unfold T
  have : Real.exp (2*(-v)) = (Real.exp (2*v))⁻¹ := by rw [← Real.exp_neg]; ring_nf
  rw [this]
  have hp := Real.exp_pos (2*v)
  field_simp
  ring

lemma T_nonneg (v : ℝ) (hv : 0 ≤ v) : 0 ≤ T v := by
  unfold T
  have := Real.one_le_exp (show 0 ≤ 2 * v by linarith)
  apply div_nonneg <;> linarith

lemma aux (E e p c s r : ℝ) (hE : |E - (c + s)| ≤ r) (he : |e - (c - s)| ≤ r)
    (hp1 : p ≤ 0.999) (hp2 : -0.999 ≤ p) (h1 : 0 ≤ (p+0.001)*c - s - r)
    (h2 : 0 ≤ s - (p-0.001)*c - r) (hpos : 0 < E + e) :
    |p - (E - e)/(E + e)| ≤ 0.001 := by
  rw [abs_le] at hE he
  obtain ⟨hE1, hE2⟩ := hE
  obtain ⟨he1, he2⟩ := he
  have k1 : E - e ≤ (p + 0.001) * (E + e) := by
    nlinarith [mul_nonneg (sub_nonneg.2 hp1) (sub_nonneg.2 hE2),
      mul_nonneg (by linarith : (0:ℝ) ≤ p + 1.001) (by linarith : 0 ≤ e - (c - s) + r)]
  have k2 : (p - 0.001) * (E + e) ≤ E - e := by
    nlinarith [mul_nonneg (by linarith : (0:ℝ) ≤ 1.001 - p) (by linarith : 0 ≤ E - (c + s) + r),
      mul_nonneg (by linarith : (0:ℝ) ≤ p + 0.999) (sub_nonneg.2 he2)]
  rw [abs_le]
  constructor
  · have : (E - e)/(E+e) ≤ p + 0.001 := by rw [div_le_iff₀ hpos]; linarith
    linarith
  · have : p - 0.001 ≤ (E-e)/(E+e) := by rw [le_div_iff₀ hpos]; linarith
    linarith

lemma small_nonneg (v : ℝ) (h0 : 0 ≤ v) (h1 : v ≤ 0.61) : |P v - T v| ≤ 0.001 := by
  rw [T_eq]
  have hE := exp_taylor v (by rw [abs_of_nonneg h0]; linarith)
  have he := exp_taylor (-v) (by rw [abs_neg, abs_of_nonneg h0]; linarith)
  rw [abs_of_nonneg h0] at hE
  rw [abs_neg, abs_of_nonneg h0] at he
  have b : ∀ k : ℕ, v^k ≤ (0.61:ℝ)^k := fun k => pow_le_pow_left₀ h0 h1 k
  have z : ∀ k : ℕ, 0 ≤ v^k := fun k => pow_nonneg h0 k
  have b1 := b 1; have b2 := b 2; have b3 := b 3; have b4 := b 4; have b5 := b 5
  have b6 := b 6; have b7 := b 7; have b8 := b 8; have b9 := b 9; have b10 := b 10
  have b11 := b 11; have b12 := b 12; have b13 := b 13
  have z1 := z 1; have z2 := z 2; have z3 := z 3; have z4 := z 4; have z5 := z 5
  have z6 := z 6; have z7 := z 7; have z8 := z 8; have z9 := z 9; have z10 := z 10
  have z11 := z 11; have z12 := z 12; have z13 := z 13
  norm_num at b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13
  unfold P
  apply aux _ _ _ (1 + v^2/2 + v^4/24) (v + v^3/6 + v^5/120) (v^6 * (7/4320))
  · rw [show (1 + v^2/2 + v^4/24) + (v + v^3/6 + v^5/120)
        = 1 + v + v^2/2 + v^3/6 + v^4/24 + v^5/120 by ring]
    exact hE
  · rw [show (1 + v^2/2 + v^4/24) - (v + v^3/6 + v^5/120)
        = 1 + (-v) + (-v)^2/2 + (-v)^3/6 + (-v)^4/24 + (-v)^5/120 by ring]
    exact he
  · linarith
  · linarith
  · linarith
  · linarith
  · positivity

lemma P_neg (v : ℝ) : P (-v) = - P v := by unfold P; ring

lemma small (v : ℝ) (h : |v| < (5033165 / 2 ^ 23 : ℝ)) : |P v - T v| ≤ 0.001 := by
  have h' : |v| ≤ 0.61 := by norm_num at h ⊢; linarith
  rcases le_or_gt 0 v with hv | hv
  · rw [abs_of_nonneg hv] at h'
    exact small_nonneg v hv h'
  · rw [abs_of_neg hv] at h'
    have := small_nonneg (-v) (by linarith) h'
    rw [P_neg, T_neg] at this
    rw [show P v - T v = -(-P v - -T v) by ring, abs_neg]
    exact this

lemma large (v : ℝ) (hv : 9 ≤ v) : |1 - T v| ≤ 0.001 := by
  have hF : 1999 ≤ Real.exp (2*v) := by
    have h1 := Real.add_one_le_exp (v/4)
    have h2 : Real.exp (2*v) = Real.exp (v/4)^8 := by
      rw [← Real.exp_nat_mul]; push_cast; ring_nf
    have h3 : (3.25:ℝ)^8 ≤ Real.exp (v/4)^8 := pow_le_pow_left₀ (by norm_num) (by linarith) 8
    rw [h2]; norm_num at h3 ⊢; linarith
  unfold T
  have hne : Real.exp (2*v) + 1 ≠ 0 := by positivity
  have : (Real.exp (2*v) - 1)/(Real.exp (2*v) + 1) = 1 - 2/(Real.exp (2*v) + 1) := by
    rw [eq_sub_iff_add_eq, ← add_div, div_eq_one_iff_eq hne]; ring
  rw [this]
  have h0 : 0 < 2/(Real.exp (2*v) + 1) := by positivity
  have h1 : 2/(Real.exp (2*v) + 1) ≤ 0.001 := by
    rw [div_le_iff₀ (by positivity)]; nlinarith
  rw [abs_le]; constructor <;> linarith

lemma mid (y : ℝ) :
    ((1 : ℝ) / (Real.exp ((y * (2.8853900432586669921875 : ℝ)) * (8388608 / 12102203 : ℝ)) + (1 : ℝ))) * (-2 : ℝ) + (1 : ℝ) = T y := by
  rw [mul_assoc, show (2.8853900432586669921875 : ℝ) * (8388608 / 12102203 : ℝ) = 2 by norm_num,
    mul_comm y 2]
  unfold T
  have : 0 < Real.exp (2*y) + 1 := by positivity
  field_simp
  ring

theorem y_0 : VoltaChallenge.y_0 := by
  intro v
  dsimp only
  by_cases ha : |v| < (5033165 / 2 ^ 23 : ℝ)
  · rw [if_pos ha]
    exact small v ha
  · rw [if_neg ha]
    have hTv : T v = - T (-v) := by rw [T_neg]; ring
    by_cases hb : |v| ≥ (9.010913848876953125 : ℝ)
    · rw [if_pos hb]
      by_cases hc : v < 0
      · rw [if_pos hc, abs_one]
        rw [abs_of_neg hc] at hb
        have := large (-v) (by norm_num at hb; linarith)
        show |-1 - T v| ≤ 0.001
        rw [hTv, show (-1 : ℝ) - -T (-v) = -(1 - T (-v)) by ring, abs_neg]
        exact this
      · rw [if_neg hc]
        rw [abs_of_nonneg (not_lt.1 hc)] at hb
        exact large v (by norm_num at hb; linarith)
    · rw [if_neg hb, mid]
      by_cases hc : v < 0
      · rw [if_pos hc, abs_of_neg hc, abs_of_nonneg (T_nonneg (-v) (by linarith))]
        show |-T (-v) - T v| ≤ 0.001
        rw [hTv]; norm_num
      · rw [if_neg hc, abs_of_nonneg (not_lt.1 hc)]
        show |T v - T v| ≤ 0.001
        norm_num

end VoltaProofs
