import challenge

set_option maxRecDepth 16384
set_option maxHeartbeats 0

namespace VoltaProofs

open Real

noncomputable def T (s : ℝ) : ℝ := (Real.exp s - 1) / (Real.exp s + 1)

noncomputable def Af (x : ℝ) : ℝ :=
  (((x * (x * (x * (12003091 / 2 ^ 28 : ℝ)))) + x) * (6693141 / 2 ^ 23 : ℝ)) * (2 : ℝ)

noncomputable def Bf (x : ℝ) : ℝ :=
  (2 : ℝ) * ((7186705221432913 / 2 ^ 53 : ℝ) * (x + ((((6444110634811895 / 2 ^ 57 : ℝ) * x) * x) * x)))

lemma T_sub (A B : ℝ) (h : B ≤ A) : 0 ≤ T A - T B ∧ T A - T B ≤ 2 * (A - B) := by
  unfold T
  have hu := exp_pos A
  have hv := exp_pos B
  have hle : exp B ≤ exp A := exp_le_exp.mpr h
  have key : exp A * (1 + (B - A)) ≤ exp B := by
    have h1 := add_one_le_exp (B - A)
    rw [exp_sub, le_div_iff₀ hu] at h1
    linarith
  rw [div_sub_div _ _ (by positivity) (by positivity)]
  have hd : 0 ≤ A - B := by linarith
  constructor
  · apply div_nonneg
    · nlinarith
    · positivity
  · rw [div_le_iff₀ (by positivity)]
    nlinarith [mul_nonneg hd (by positivity : 0 ≤ exp A * exp B + exp B + 1)]

lemma T_abs_sub (A B : ℝ) : |T A - T B| ≤ 2 * |A - B| := by
  rcases le_total B A with h | h
  · obtain ⟨h1, h2⟩ := T_sub A B h
    rw [abs_of_nonneg h1, abs_of_nonneg (by linarith)]
    exact h2
  · obtain ⟨h1, h2⟩ := T_sub B A h
    rw [abs_sub_comm, abs_of_nonneg h1, abs_sub_comm, abs_of_nonneg (by linarith)]
    exact h2

lemma T_neg (s : ℝ) : T (-s) = - T s := by
  unfold T
  have e := exp_pos s
  rw [exp_neg]
  field_simp
  ring

lemma T_tail (s : ℝ) (hs : 0 ≤ s) : 0 ≤ 1 - T s ∧ (1 - T s) * s ^ 2 ≤ 4 := by
  unfold T
  have hp := exp_pos s
  have hq := quadratic_le_exp_of_nonneg hs
  have e : 1 - (exp s - 1) / (exp s + 1) = 2 / (exp s + 1) := by
    field_simp
    ring
  rw [e]
  constructor
  · positivity
  · rw [div_mul_eq_mul_div, div_le_iff₀ (by positivity)]
    nlinarith

lemma poly_bound (x d1 d3 : ℝ) (hx : 0 ≤ x) (hx16 : x ≤ 16)
    (h1 : |d1| ≤ 3e-8) (h3 : |d3| ≤ 1e-9) :
    x * (2 * |2 * d1 * x + 2 * d3 * x ^ 3|) ≤ 0.002 := by
  have hx3 : 0 ≤ x ^ 3 := by positivity
  have hb : |2 * d1 * x + 2 * d3 * x ^ 3| ≤ 6e-8 * x + 2e-9 * x ^ 3 := by
    calc |2 * d1 * x + 2 * d3 * x ^ 3| ≤ |2 * d1 * x| + |2 * d3 * x ^ 3| := abs_add_le _ _
      _ = 2 * |d1| * x + 2 * |d3| * x ^ 3 := by
        rw [abs_mul, abs_mul, abs_mul, abs_mul, abs_of_nonneg hx, abs_of_nonneg hx3]
        norm_num
      _ ≤ _ := by nlinarith [mul_le_mul_of_nonneg_right h1 hx, mul_le_mul_of_nonneg_right h3 hx3]
  have hx2 : x ^ 2 ≤ 16 ^ 2 := pow_le_pow_left₀ hx hx16 2
  have hx4 : x ^ 4 ≤ 16 ^ 4 := pow_le_pow_left₀ hx hx16 4
  calc x * (2 * |2 * d1 * x + 2 * d3 * x ^ 3|) ≤ x * (2 * (6e-8 * x + 2e-9 * x ^ 3)) := by
        gcongr
    _ = 1.2e-7 * x ^ 2 + 4e-9 * x ^ 4 := by ring
    _ ≤ 0.002 := by norm_num at hx2 hx4 ⊢; linarith

lemma lb (x a b : ℝ) (hx : 0 ≤ x) (ha : 0 ≤ a) (hb : 0.07 ≤ b) :
    0.07 * x ^ 3 ≤ a * x + b * x ^ 3 := by
  nlinarith [mul_nonneg ha hx, mul_le_mul_of_nonneg_right hb (pow_nonneg hx 3)]

lemma big (x A B : ℝ) (hx : 16 ≤ x) (hA : 0.07 * x ^ 3 ≤ A) (hB : 0.07 * x ^ 3 ≤ B) :
    x * |T A - T B| ≤ 0.002 := by
  have hx0 : 0 ≤ x := by linarith
  have h5 : (16:ℝ) ^ 5 ≤ x ^ 5 := pow_le_pow_left₀ (by norm_num) hx 5
  have h6 : (16:ℝ) ^ 5 * x ≤ x ^ 5 * x := mul_le_mul_of_nonneg_right h5 hx0
  have hk0 : 0 ≤ 0.07 * x ^ 3 := by positivity
  have e : (0.07 * x ^ 3) ^ 2 = 0.0049 * (x ^ 5 * x) := by ring
  have hA2 : (0.07 * x ^ 3) ^ 2 ≤ A ^ 2 := pow_le_pow_left₀ hk0 hA 2
  have hB2 : (0.07 * x ^ 3) ^ 2 ≤ B ^ 2 := pow_le_pow_left₀ hk0 hB 2
  have hkA : 4000 * x ≤ A ^ 2 := by norm_num at h6 e hA2 ⊢; nlinarith
  have hkB : 4000 * x ≤ B ^ 2 := by norm_num at h6 e hB2 ⊢; nlinarith
  obtain ⟨p0, p1⟩ := T_tail A (le_trans hk0 hA)
  obtain ⟨q0, q1⟩ := T_tail B (le_trans hk0 hB)
  have a1 := mul_le_mul_of_nonneg_left hkA p0
  have b1 := mul_le_mul_of_nonneg_left hkB q0
  have a2 : x * (1 - T A) ≤ 0.001 := by nlinarith
  have b2 : x * (1 - T B) ≤ 0.001 := by nlinarith
  have a3 : 0 ≤ x * (1 - T A) := mul_nonneg hx0 p0
  have b3 : 0 ≤ x * (1 - T B) := mul_nonneg hx0 q0
  rcases abs_cases (T A - T B) with ⟨h, _⟩ | ⟨h, _⟩
  · rw [h]; nlinarith
  · rw [h]; nlinarith

lemma K (x : ℝ) : |x| * |T (Af x) - T (Bf x)| ≤ 0.002 := by
  have pos : ∀ y : ℝ, 0 ≤ y → y * |T (Af y) - T (Bf y)| ≤ 0.002 := by
    intro y hy
    rcases le_total y 16 with h | h
    · calc y * |T (Af y) - T (Bf y)| ≤ y * (2 * |Af y - Bf y|) := by
            gcongr
            exact T_abs_sub _ _
        _ = y * (2 * |2 * ((6693141 / 2 ^ 23 : ℝ) - (7186705221432913 / 2 ^ 53 : ℝ)) * y
              + 2 * ((6693141 / 2 ^ 23 : ℝ) * (12003091 / 2 ^ 28 : ℝ)
                - (7186705221432913 / 2 ^ 53 : ℝ) * (6444110634811895 / 2 ^ 57 : ℝ)) * y ^ 3|) := by
            congr 3
            unfold Af Bf
            ring
        _ ≤ 0.002 := poly_bound y _ _ hy h
            (abs_le.mpr ⟨by norm_num, by norm_num⟩) (abs_le.mpr ⟨by norm_num, by norm_num⟩)
    · apply big y _ _ h
      · rw [show Af y = (2 * (6693141 / 2 ^ 23 : ℝ)) * y
            + (2 * (6693141 / 2 ^ 23 : ℝ) * (12003091 / 2 ^ 28 : ℝ)) * y ^ 3 by unfold Af; ring]
        exact lb y _ _ hy (by norm_num) (by norm_num)
      · rw [show Bf y = (2 * (7186705221432913 / 2 ^ 53 : ℝ)) * y
            + (2 * (7186705221432913 / 2 ^ 53 : ℝ) * (6444110634811895 / 2 ^ 57 : ℝ)) * y ^ 3 by
              unfold Bf; ring]
        exact lb y _ _ hy (by norm_num) (by norm_num)
  rcases le_total 0 x with hx | hx
  · rw [abs_of_nonneg hx]; exact pos x hx
  · have := pos (-x) (by linarith)
    rw [abs_of_nonpos hx]
    rw [show Af (-x) = -(Af x) by unfold Af; ring, show Bf (-x) = -(Bf x) by unfold Bf; ring,
      T_neg, T_neg, show -T (Af x) - -T (Bf x) = -(T (Af x) - T (Bf x)) by ring, abs_neg] at this
    exact this

lemma main (x y : ℝ) (h : x = y) :
    |((x * (0.5 : ℝ)) * (((Real.exp ((((x * (x * (x * (12003091 / 2 ^ 28 : ℝ)))) + x) * (6693141 / 2 ^ 23 : ℝ)) * (2 : ℝ)) - (1 : ℝ)) / (Real.exp ((((x * (x * (x * (12003091 / 2 ^ 28 : ℝ)))) + x) * (6693141 / 2 ^ 23 : ℝ)) * (2 : ℝ)) + (1 : ℝ))) + (1 : ℝ))) - (((0.5 : ℝ) * y) * ((1 : ℝ) + ((Real.exp ((2 : ℝ) * ((7186705221432913 / 2 ^ 53 : ℝ) * (y + ((((6444110634811895 / 2 ^ 57 : ℝ) * y) * y) * y)))) - (1 : ℝ)) / (Real.exp ((2 : ℝ) * ((7186705221432913 / 2 ^ 53 : ℝ) * (y + ((((6444110634811895 / 2 ^ 57 : ℝ) * y) * y) * y)))) + (1 : ℝ)))))| ≤ (0.001 : ℝ) := by
  subst h
  have hK := K x
  change |(x * 0.5) * (T (Af x) + 1) - (0.5 * x) * (1 + T (Bf x))| ≤ 0.001
  rw [show (x * 0.5) * (T (Af x) + 1) - (0.5 * x) * (1 + T (Bf x))
      = (x * (T (Af x) - T (Bf x))) / 2 by ring, abs_div, abs_mul,
    abs_of_pos (by norm_num : (0:ℝ) < 2)]
  linarith

theorem c_0 : VoltaChallenge.c_0 := by
  unfold VoltaChallenge.c_0
  intros
  rename_i x0 x1 x2
  exact main x0 x2 (by simp only [x0, x2]; ring)
theorem c_1 : VoltaChallenge.c_1 := by
  unfold VoltaChallenge.c_1
  intros
  rename_i x0 x1 x2
  exact main x0 x2 (by simp only [x0, x2]; ring)
theorem c_256 : VoltaChallenge.c_256 := by
  unfold VoltaChallenge.c_256
  intros
  rename_i x0 x1 x2
  exact main x0 x2 (by simp only [x0, x2]; ring)

end VoltaProofs
