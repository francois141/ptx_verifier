import challenge

namespace VoltaProofs

noncomputable def G (u : ℝ) : ℝ := 1 / (Real.exp u + 1) * (-2) + 1

noncomputable def Pl (y : ℝ) : ℝ :=
  ((((((4225089 / 2 ^ 28 : ℝ) * (y * y)) + (-7020119 / 2 ^ 27 : ℝ)) * (y * y) + (8935745 / 2 ^ 26 : ℝ)) * (y * y) + (-11184621 / 2 ^ 25 : ℝ)) * (y * y)) * y + y

lemma G_eq (u : ℝ) : G u = (Real.exp u - 1) / (Real.exp u + 1) := by
  have h : Real.exp u + 1 ≠ 0 := by positivity
  unfold G
  rw [eq_div_iff h, add_mul, one_mul, mul_comm (1 / (Real.exp u + 1)) (-2), mul_assoc,
    one_div_mul_cancel h]
  ring

lemma one_sub_G (u : ℝ) : 1 - G u = 2 / (Real.exp u + 1) := by
  unfold G; ring

lemma G_alt (u : ℝ) : G u = 1 - 2 / (Real.exp u + 1) := by
  unfold G; ring

lemma G_neg (u : ℝ) : G (-u) = - G u := by
  have h : Real.exp u ≠ 0 := (Real.exp_pos u).ne'
  have h1 : Real.exp u + 1 ≠ 0 := by positivity
  have h2 : (Real.exp u)⁻¹ + 1 ≠ 0 := by positivity
  have e1 : 1 / ((Real.exp u)⁻¹ + 1) = Real.exp u / (Real.exp u + 1) := by
    rw [div_eq_div_iff h2 h1, one_mul, mul_add, mul_inv_cancel₀ h, mul_one, add_comm]
  have e2 : Real.exp u / (Real.exp u + 1) = 1 - 1 / (Real.exp u + 1) := by
    rw [eq_sub_iff_add_eq, ← add_div, div_self h1]
  unfold G
  rw [Real.exp_neg, e1, e2]
  ring

lemma G_nonneg (u : ℝ) (hu : 0 ≤ u) : 0 ≤ G u := by
  rw [G_eq]
  apply div_nonneg
  · linarith [Real.one_le_exp hu]
  · positivity

lemma G_nonpos (u : ℝ) (hu : u ≤ 0) : G u ≤ 0 := by
  have := G_nonneg (-u) (by linarith)
  rw [G_neg] at this
  linarith

lemma pos_case (u : ℝ) : |1 - G u| = 2 / (Real.exp u + 1) := by
  rw [one_sub_G, abs_of_pos (by positivity)]

lemma neg_case (u : ℝ) : |-1 - -G u| = 2 / (Real.exp u + 1) := by
  rw [show (-1 : ℝ) - -G u = -(1 - G u) by ring, abs_neg, one_sub_G, abs_of_pos (by positivity)]

lemma G_lip (u v : ℝ) (h : |u - v| ≤ 1) : |G u - G v| ≤ 4 * |u - v| := by
  have hu := Real.exp_pos u
  have hv := Real.exp_pos v
  have hd : |Real.exp u - Real.exp v| ≤ 2 * |u - v| * Real.exp v := by
    have h1 : Real.exp u - Real.exp v = Real.exp v * (Real.exp (u - v) - 1) := by
      rw [mul_sub, ← Real.exp_add, mul_one, show v + (u - v) = u by ring]
    rw [h1, abs_mul, abs_of_pos hv]
    have := Real.abs_exp_sub_one_le h
    nlinarith [mul_le_mul_of_nonneg_left this hv.le]
  have hu1 : Real.exp u + 1 ≠ 0 := by positivity
  have hv1 : Real.exp v + 1 ≠ 0 := by positivity
  have hG : G u - G v = 2 * (Real.exp u - Real.exp v) / ((Real.exp u + 1) * (Real.exp v + 1)) := by
    rw [G_alt, G_alt, show (1 - 2 / (Real.exp u + 1)) - (1 - 2 / (Real.exp v + 1))
      = 2 / (Real.exp v + 1) - 2 / (Real.exp u + 1) by ring, div_sub_div _ _ hv1 hu1]
    ring
  rw [hG, abs_div, abs_mul, abs_of_pos (show (0:ℝ) < (Real.exp u + 1) * (Real.exp v + 1) by positivity),
    div_le_iff₀ (by positivity)]
  have h2 : |(2:ℝ)| = 2 := abs_of_pos (by norm_num)
  rw [h2]
  have := abs_nonneg (u - v)
  nlinarith [mul_nonneg this (show (0:ℝ) ≤ Real.exp u * Real.exp v + Real.exp u + 1 by positivity)]

lemma sum6 (x : ℝ) : ∑ m ∈ Finset.range 6, x ^ m / (m.factorial : ℝ)
    = 1 + x + x ^ 2 / 2 + x ^ 3 / 6 + x ^ 4 / 24 + x ^ 5 / 120 := by
  rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_one]
  norm_num [Nat.factorial]

lemma exp6 (x : ℝ) (hx : |x| ≤ 1) :
    |Real.exp x - (1 + x + x ^ 2 / 2 + x ^ 3 / 6 + x ^ 4 / 24 + x ^ 5 / 120)| ≤ x ^ 6 * (7 / 4320) := by
  have h := Real.exp_bound hx (n := 6) (by norm_num)
  rw [sum6] at h
  have h6 : |x| ^ 6 = x ^ 6 := by
    rw [← abs_pow]; exact abs_of_nonneg (by positivity)
  rw [h6] at h
  calc _ ≤ _ := h
    _ = x ^ 6 * (7 / 4320) := by norm_num [Nat.factorial]

set_option maxHeartbeats 4000000 in
lemma poly_bound (y : ℝ) (hy : |y| ≤ 61/100) : |Pl y - G (2 * y)| ≤ 1/400 := by
  have hy1 : |y| ≤ 1 := by linarith
  have hny1 : |-y| ≤ 1 := by rw [abs_neg]; linarith
  have e1 := exp6 y hy1
  have e2 := exp6 (-y) hny1
  obtain ⟨e1l, e1u⟩ := abs_le.mp e1
  obtain ⟨e2l, e2u⟩ := abs_le.mp e2
  have hk : Real.exp y * Real.exp (-y) = 1 := by
    rw [← Real.exp_add]; simp
  have hE : Real.exp (2 * y) = Real.exp y * Real.exp y := by
    rw [← Real.exp_add]; ring_nf
  have hhp := Real.exp_pos y
  have hkp := Real.exp_pos (-y)
  have hpos : 0 < Real.exp y + Real.exp (-y) := by positivity
  have hG : G (2 * y) = (Real.exp y - Real.exp (-y)) / (Real.exp y + Real.exp (-y)) := by
    rw [G_eq, hE, div_eq_div_iff (by positivity) hpos.ne']
    linear_combination (2 * Real.exp y) * hk
  have hs0 : 0 ≤ y * y := mul_self_nonneg y
  have hs1 : y * y ≤ 3721/10000 := by
    have := mul_le_mul hy hy (abs_nonneg y) (by norm_num : (0:ℝ) ≤ 61/100)
    have h2 := abs_mul_abs_self y
    linarith
  have hp2 := pow_le_pow_left₀ hs0 hs1 2
  have hp3 := pow_le_pow_left₀ hs0 hs1 3
  have hp4 := pow_le_pow_left₀ hs0 hs1 4
  have hp5 := pow_le_pow_left₀ hs0 hs1 5
  have hp6 := pow_le_pow_left₀ hs0 hs1 6
  have hq2 := pow_nonneg hs0 2
  have hq3 := pow_nonneg hs0 3
  have hq4 := pow_nonneg hs0 4
  have hq5 := pow_nonneg hs0 5
  have hq6 := pow_nonneg hs0 6
  have hW : |((-11184621 / 2 ^ 25 : ℝ) + 1/3) * (y * y)
      + ((8935745 / 2 ^ 26 : ℝ) + (-11184621 / 2 ^ 25 : ℝ) / 2 + 1/30) * (y * y) ^ 2
      + ((-7020119 / 2 ^ 27 : ℝ) + (8935745 / 2 ^ 26 : ℝ) / 2 + (-11184621 / 2 ^ 25 : ℝ) / 24) * (y * y) ^ 3
      + ((4225089 / 2 ^ 28 : ℝ) + (-7020119 / 2 ^ 27 : ℝ) / 2 + (8935745 / 2 ^ 26 : ℝ) / 24) * (y * y) ^ 4
      + ((4225089 / 2 ^ 28 : ℝ) / 2 + (-7020119 / 2 ^ 27 : ℝ) / 24) * (y * y) ^ 5
      + ((4225089 / 2 ^ 28 : ℝ) / 24) * (y * y) ^ 6| ≤ 3/10000 := by
    rw [abs_le]; constructor
    · linarith only [hs0, hs1, hp2, hp3, hp4, hp5, hp6, hq2, hq3, hq4, hq5, hq6]
    · linarith only [hs0, hs1, hp2, hp3, hp4, hp5, hp6, hq2, hq3, hq4, hq5, hq6]
  have hPC : Pl y * (1 + y ^ 2 / 2 + y ^ 4 / 24) - (y + y ^ 3 / 6 + y ^ 5 / 120) = y * (
      ((-11184621 / 2 ^ 25 : ℝ) + 1/3) * (y * y)
      + ((8935745 / 2 ^ 26 : ℝ) + (-11184621 / 2 ^ 25 : ℝ) / 2 + 1/30) * (y * y) ^ 2
      + ((-7020119 / 2 ^ 27 : ℝ) + (8935745 / 2 ^ 26 : ℝ) / 2 + (-11184621 / 2 ^ 25 : ℝ) / 24) * (y * y) ^ 3
      + ((4225089 / 2 ^ 28 : ℝ) + (-7020119 / 2 ^ 27 : ℝ) / 2 + (8935745 / 2 ^ 26 : ℝ) / 24) * (y * y) ^ 4
      + ((4225089 / 2 ^ 28 : ℝ) / 2 + (-7020119 / 2 ^ 27 : ℝ) / 24) * (y * y) ^ 5
      + ((4225089 / 2 ^ 28 : ℝ) / 24) * (y * y) ^ 6) := by
    unfold Pl; ring
  have hB : |Pl y * (1 + y ^ 2 / 2 + y ^ 4 / 24) - (y + y ^ 3 / 6 + y ^ 5 / 120)| ≤ 2/10000 := by
    rw [hPC, abs_mul]
    calc _ ≤ (61/100) * (3/10000) := mul_le_mul hy hW (abs_nonneg _) (by norm_num)
      _ ≤ 2/10000 := by norm_num
  have hV : Pl y = y * (1 + (-11184621 / 2 ^ 25 : ℝ) * (y * y) + (8935745 / 2 ^ 26 : ℝ) * (y * y) ^ 2
      + (-7020119 / 2 ^ 27 : ℝ) * (y * y) ^ 3 + (4225089 / 2 ^ 28 : ℝ) * (y * y) ^ 4) := by
    unfold Pl; ring
  have hVb : |1 + (-11184621 / 2 ^ 25 : ℝ) * (y * y) + (8935745 / 2 ^ 26 : ℝ) * (y * y) ^ 2
      + (-7020119 / 2 ^ 27 : ℝ) * (y * y) ^ 3 + (4225089 / 2 ^ 28 : ℝ) * (y * y) ^ 4| ≤ 3/2 := by
    rw [abs_le]; constructor
    · linarith only [hs0, hs1, hp2, hp3, hp4, hq2, hq3, hq4]
    · linarith only [hs0, hs1, hp2, hp3, hp4, hq2, hq3, hq4]
  have hPb : |Pl y| ≤ 99/100 := by
    rw [hV, abs_mul]
    calc _ ≤ (61/100) * (3/2) := mul_le_mul hy hVb (abs_nonneg _) (by norm_num)
      _ ≤ 99/100 := by norm_num
  have y6 : y ^ 6 ≤ (3721/10000) ^ 3 := by
    have : y ^ 6 = (y * y) ^ 3 := by ring
    rw [this]; exact hp3
  have y2n : 0 ≤ y ^ 2 := sq_nonneg y
  have y4n : 0 ≤ y ^ 4 := by positivity
  obtain ⟨hB1, hB2⟩ := abs_le.mp hB
  obtain ⟨hP1, hP2⟩ := abs_le.mp hPb
  clear hW hPC hV hVb hp2 hp4 hp5 hp6 hq2 hq3 hq4 hq5 hq6 hB hPb e1 e2
  rw [hG, abs_le]
  constructor
  · have H : (Real.exp y - Real.exp (-y)) / (Real.exp y + Real.exp (-y)) ≤ Pl y + 1/400 := by
      rw [div_le_iff₀ hpos]
      have H1 : 0 ≤ (y ^ 6 * (7 / 4320) - (Real.exp y - (1 + y + y ^ 2 / 2 + y ^ 3 / 6 + y ^ 4 / 24 + y ^ 5 / 120)))
          * (1 - Pl y - 1/400) := mul_nonneg (by linarith) (by linarith)
      have H2 : 0 ≤ ((-y) ^ 6 * (7 / 4320) + (Real.exp (-y) - (1 + (-y) + (-y) ^ 2 / 2 + (-y) ^ 3 / 6 + (-y) ^ 4 / 24 + (-y) ^ 5 / 120)))
          * (1 + Pl y + 1/400) := mul_nonneg (by linarith) (by linarith)
      linarith only [H1, H2, hB1, hB2, y6, y2n, y4n]
    linarith only [H]
  · have H : Pl y - 1/400 ≤ (Real.exp y - Real.exp (-y)) / (Real.exp y + Real.exp (-y)) := by
      rw [le_div_iff₀ hpos]
      have H1 : 0 ≤ (y ^ 6 * (7 / 4320) + (Real.exp y - (1 + y + y ^ 2 / 2 + y ^ 3 / 6 + y ^ 4 / 24 + y ^ 5 / 120)))
          * (1 - Pl y + 1/400) := mul_nonneg (by linarith) (by linarith)
      have H2 : 0 ≤ ((-y) ^ 6 * (7 / 4320) - (Real.exp (-y) - (1 + (-y) + (-y) ^ 2 / 2 + (-y) ^ 3 / 6 + (-y) ^ 4 / 24 + (-y) ^ 5 / 120)))
          * (1 + Pl y - 1/400) := mul_nonneg (by linarith) (by linarith)
      linarith only [H1, H2, hB1, hB2, y6, y2n, y4n]
    linarith only [H]

lemma tail (b : ℝ) (hb : 51/10 ≤ b) :
    b * (2 / (Real.exp (2 * ((7186705221432913 / 2 ^ 53 : ℝ) * (b + ((((6444110634811895 / 2 ^ 57 : ℝ) * b) * b) * b)))) + 1)) ≤ 2/1000 := by
  have hb0 : 0 ≤ b := by linarith
  have hbb : (51/10) * (51/10) ≤ b * b := mul_le_mul hb hb (by norm_num) hb0
  have hu3 : 3 * b ≤ 2 * ((7186705221432913 / 2 ^ 53 : ℝ) * (b + ((((6444110634811895 / 2 ^ 57 : ℝ) * b) * b) * b))) := by
    nlinarith [mul_le_mul_of_nonneg_left hbb hb0]
  generalize hu : 2 * ((7186705221432913 / 2 ^ 53 : ℝ) * (b + ((((6444110634811895 / 2 ^ 57 : ℝ) * b) * b) * b))) = u at hu3 ⊢
  have hu0 : 0 ≤ u := by linarith
  have he : u ^ 5 / 120 ≤ Real.exp u := by
    have := Real.pow_div_factorial_le_exp u hu0 5
    norm_num [Nat.factorial] at this
    linarith
  have h5 : (3 * b) ^ 5 ≤ u ^ 5 := pow_le_pow_left₀ (by linarith) hu3 5
  have h4 : (51/10 : ℝ) ^ 4 ≤ b ^ 4 := pow_le_pow_left₀ (by norm_num) hb 4
  have hpos : 0 < Real.exp u + 1 := by positivity
  rw [← mul_div_assoc, div_le_iff₀ hpos]
  nlinarith [mul_le_mul_of_nonneg_right h4 hb0]

lemma reduce (a T g : ℝ) (h : |a| * |T - g| ≤ 2/1000) :
    |a * (0.5 : ℝ) * (T + 1) - (0.5 : ℝ) * a * (1 + g)| ≤ (0.001 : ℝ) := by
  have e : a * (0.5 : ℝ) * (T + 1) - (0.5 : ℝ) * a * (1 + g) = (a * (T - g)) / 2 := by
    rw [show (0.5 : ℝ) = 1/2 by norm_num]; ring
  rw [e, abs_div, abs_mul, abs_of_pos (by norm_num : (0:ℝ) < 2), show (0.001 : ℝ) = 1/1000 by norm_num]
  linarith

set_option maxHeartbeats 4000000 in
lemma key (x0 x5 : ℝ) (h : x5 = x0) :
    let x1 := ((x0 * (x0 * (x0 * (12003091 / 2 ^ 28 : ℝ)))) + x0) * (6693141 / 2 ^ 23 : ℝ)
    let x2 := |x1|
    let x3 := x1 * x1
    let x4 := if x2 ≥ (9.010913848876953125 : ℝ) then (1 : ℝ) else (((1 : ℝ) / (Real.exp ((x2 * (2.8853900432586669921875 : ℝ)) * (8388608 / 12102203 : ℝ)) + (1 : ℝ))) * (-2 : ℝ)) + (1 : ℝ)
    |((x0 * (0.5 : ℝ)) * ((if x2 < (5033165 / 2 ^ 23 : ℝ) then (((((((((4225089 / 2 ^ 28 : ℝ) * x3) + (-7020119 / 2 ^ 27 : ℝ)) * x3) + (8935745 / 2 ^ 26 : ℝ)) * x3) + (-11184621 / 2 ^ 25 : ℝ)) * x3) * x1) + x1 else if x1 < (0 : ℝ) then -(|x4|) else x4) + (1 : ℝ))) - (((0.5 : ℝ) * x5) * ((1 : ℝ) + ((Real.exp ((2 : ℝ) * ((7186705221432913 / 2 ^ 53 : ℝ) * (x5 + ((((6444110634811895 / 2 ^ 57 : ℝ) * x5) * x5) * x5)))) - (1 : ℝ)) / (Real.exp ((2 : ℝ) * ((7186705221432913 / 2 ^ 53 : ℝ) * (x5 + ((((6444110634811895 / 2 ^ 57 : ℝ) * x5) * x5) * x5)))) + (1 : ℝ)))))| ≤ (0.001 : ℝ) := by
  intro x1 x2 x3 x4
  rw [h, ← G_eq]
  obtain ⟨Y, hY⟩ : ∃ Y : ℝ, Y = (7186705221432913 / 2 ^ 53 : ℝ) * (x0 + ((((6444110634811895 / 2 ^ 57 : ℝ) * x0) * x0) * x0)) := ⟨_, rfl⟩
  rw [← hY]
  apply reduce
  have hx1 : x1 = ((x0 * (x0 * (x0 * (12003091 / 2 ^ 28 : ℝ)))) + x0) * (6693141 / 2 ^ 23 : ℝ) := rfl
  have hx2 : x2 = |x1| := rfl
  have hx4 : x4 = if x2 ≥ (9.010913848876953125 : ℝ) then (1 : ℝ) else G ((x2 * (2.8853900432586669921875 : ℝ)) * (8388608 / 12102203 : ℝ)) := rfl
  have hκ : (x2 * (2.8853900432586669921875 : ℝ)) * (8388608 / 12102203 : ℝ) = 2 * x2 := by
    rw [mul_assoc, show (2.8853900432586669921875 : ℝ) * (8388608 / 12102203 : ℝ) = 2 by norm_num, mul_comm]
  rw [hκ] at hx4
  have hfac : x1 = x0 * ((x0 * x0 * (12003091 / 2 ^ 28 : ℝ) + 1) * (6693141 / 2 ^ 23 : ℝ)) := by
    rw [hx1]; ring
  have hPpos : 0 < (x0 * x0 * (12003091 / 2 ^ 28 : ℝ) + 1) * (6693141 / 2 ^ 23 : ℝ) :=
    mul_pos (by nlinarith [mul_self_nonneg x0]) (by norm_num)
  have habs1 : |x1| = |x0| * ((|x0| * |x0| * (12003091 / 2 ^ 28 : ℝ) + 1) * (6693141 / 2 ^ 23 : ℝ)) := by
    rw [hfac, abs_mul, abs_of_pos hPpos, abs_mul_abs_self]
  have hA1 : (6693141 / 2 ^ 23 : ℝ) * |x0| ≤ |x1| := by
    rw [habs1]; nlinarith [mul_nonneg (abs_nonneg x0) (mul_self_nonneg (|x0|))]
  have hD : x1 - Y = ((6693141 / 2 ^ 23 : ℝ) - (7186705221432913 / 2 ^ 53 : ℝ)) * x0
      + ((12003091 / 2 ^ 28 : ℝ) * (6693141 / 2 ^ 23 : ℝ) - (7186705221432913 / 2 ^ 53 : ℝ) * (6444110634811895 / 2 ^ 57 : ℝ)) * (x0 * x0 * x0) := by
    rw [hx1, hY]; ring
  have hd : |x1 - Y| ≤ 3/10^8 * |x0| + 1/10^9 * (|x0| * |x0| * |x0|) := by
    rw [hD]
    have hc1 : |((6693141 / 2 ^ 23 : ℝ) - (7186705221432913 / 2 ^ 53 : ℝ))| ≤ 3/10^8 := by
      rw [abs_le]; constructor <;> norm_num
    have hc2 : |(12003091 / 2 ^ 28 : ℝ) * (6693141 / 2 ^ 23 : ℝ) - (7186705221432913 / 2 ^ 53 : ℝ) * (6444110634811895 / 2 ^ 57 : ℝ)| ≤ 1/10^9 := by
      rw [abs_le]; constructor <;> norm_num
    have t1 : |((6693141 / 2 ^ 23 : ℝ) - (7186705221432913 / 2 ^ 53 : ℝ)) * x0| ≤ 3/10^8 * |x0| := by
      rw [abs_mul]; exact mul_le_mul_of_nonneg_right hc1 (abs_nonneg _)
    have t2 : |((12003091 / 2 ^ 28 : ℝ) * (6693141 / 2 ^ 23 : ℝ) - (7186705221432913 / 2 ^ 53 : ℝ) * (6444110634811895 / 2 ^ 57 : ℝ)) * (x0 * x0 * x0)| ≤ 1/10^9 * (|x0| * |x0| * |x0|) := by
      rw [abs_mul, abs_mul, abs_mul]; exact mul_le_mul_of_nonneg_right hc2 (by positivity)
    obtain ⟨t1l, t1u⟩ := abs_le.mp t1
    obtain ⟨t2l, t2u⟩ := abs_le.mp t2
    rw [abs_le]; constructor <;> linarith
  have h2d : |2 * x1 - 2 * Y| = 2 * |x1 - Y| := by
    rw [← mul_sub, abs_mul, abs_of_pos (by norm_num : (0:ℝ) < 2)]
  by_cases hA : x2 < (5033165 / 2 ^ 23 : ℝ)
  · rw [if_pos hA]
    rw [hx2] at hA
    have hx1b : |x1| ≤ 61/100 := by
      have : (5033165 / 2 ^ 23 : ℝ) ≤ 61/100 := by norm_num
      linarith
    have ha : |x0| ≤ 77/100 := by linarith
    have hδ : |x1 - Y| ≤ 1/10^7 := by
      have h3 : |x0| * |x0| * |x0| ≤ (77/100) * (77/100) * (77/100) := by
        have := abs_nonneg x0
        gcongr
      linarith
    have hL := G_lip (2 * x1) (2 * Y) (by rw [h2d]; linarith)
    rw [h2d] at hL
    have hP := poly_bound x1 hx1b
    change |x0| * |Pl x1 - G (2 * Y)| ≤ 2/1000
    have htri : |Pl x1 - G (2 * Y)| ≤ |Pl x1 - G (2 * x1)| + |G (2 * x1) - G (2 * Y)| := abs_sub_le _ _ _
    have hb : |Pl x1 - G (2 * Y)| ≤ 1/400 + 8/10^7 := by linarith
    calc |x0| * |Pl x1 - G (2 * Y)| ≤ (77/100) * (1/400 + 8/10^7) :=
          mul_le_mul ha hb (abs_nonneg _) (by norm_num)
      _ ≤ 2/1000 := by norm_num
  · rw [if_neg hA]
    by_cases hC : x2 ≥ (9.010913848876953125 : ℝ)
    · rw [if_pos hC] at hx4
      rw [hx2] at hC
      have h9 : (9:ℝ) ≤ |x1| := by
        have : (9:ℝ) ≤ 9.010913848876953125 := by norm_num
        linarith
      have hb : 51/10 ≤ |x0| := by
        by_contra hc
        push_neg at hc
        have h0 := abs_nonneg x0
        have hsq : |x0| * |x0| ≤ 51/10 * (51/10) := mul_le_mul hc.le hc.le h0 (by norm_num)
        have hcube : |x0| * |x0| * |x0| ≤ 51/10 * (51/10) * (51/10) :=
          mul_le_mul hsq hc.le h0 (by norm_num)
        rw [habs1] at h9
        nlinarith
      rw [hx4]
      by_cases hneg : x1 < 0
      · rw [if_pos hneg, abs_one]
        have hx0n : x0 < 0 := by
          by_contra hc
          push_neg at hc
          have := mul_nonneg hc hPpos.le
          rw [← hfac] at this
          linarith
        rw [abs_of_neg hx0n] at hb
        rw [abs_of_neg hx0n]
        have hY' : 2 * Y = -(2 * ((7186705221432913 / 2 ^ 53 : ℝ) * (-x0 + ((((6444110634811895 / 2 ^ 57 : ℝ) * -x0) * -x0) * -x0)))) := by
          rw [hY]; ring
        rw [hY', G_neg, neg_case]
        exact tail (-x0) hb
      · rw [if_neg hneg]
        push_neg at hneg
        have hx1p : 9 ≤ x1 := by rw [abs_of_nonneg hneg] at h9; exact h9
        have hx0p : 0 < x0 := by
          by_contra hc
          push_neg at hc
          have := mul_nonneg (neg_nonneg.mpr hc) hPpos.le
          nlinarith [hfac]
        rw [abs_of_pos hx0p] at hb
        rw [abs_of_pos hx0p, pos_case, hY]
        exact tail x0 hb
    · rw [if_neg hC] at hx4
      rw [hx2] at hC
      push_neg at hC
      have hx4' : x4 = G (2 * |x1|) := by rw [hx4, hx2]
      have hT : (if x1 < 0 then -|x4| else x4) = G (2 * x1) := by
        rw [hx4']
        split_ifs with hneg
        · rw [abs_of_neg hneg, show 2 * -x1 = -(2 * x1) by ring, G_neg, abs_neg,
            abs_of_nonpos (G_nonpos _ (by linarith)), neg_neg]
        · push_neg at hneg
          rw [abs_of_nonneg hneg]
      rw [hT]
      have ha : |x0| ≤ 114/10 := by
        have : (9.010913848876953125 : ℝ) ≤ 902/100 := by norm_num
        linarith
      have hδ : |x1 - Y| ≤ 2/10^6 := by
        have h3 : |x0| * |x0| * |x0| ≤ (114/10) * (114/10) * (114/10) := by
          have := abs_nonneg x0
          gcongr
        linarith
      have hL := G_lip (2 * x1) (2 * Y) (by rw [h2d]; linarith)
      rw [h2d] at hL
      calc |x0| * |G (2 * x1) - G (2 * Y)| ≤ (114/10) * (16/10^6) :=
            mul_le_mul ha (by linarith) (abs_nonneg _) (by norm_num)
        _ ≤ 2/1000 := by norm_num

set_option maxRecDepth 100000 in
set_option maxHeartbeats 10000000 in
theorem c_0 : VoltaChallenge.c_0 := by
  unfold VoltaChallenge.c_0
  iterate 512 intro
  exact key _ _ (by ring)
set_option maxRecDepth 100000 in
set_option maxHeartbeats 10000000 in
theorem c_1 : VoltaChallenge.c_1 := by
  unfold VoltaChallenge.c_1
  iterate 512 intro
  exact key _ _ (by ring)
set_option maxRecDepth 100000 in
set_option maxHeartbeats 10000000 in
theorem c_256 : VoltaChallenge.c_256 := by
  unfold VoltaChallenge.c_256
  iterate 512 intro
  exact key _ _ (by ring)

end VoltaProofs
