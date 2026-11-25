import challenge

namespace VoltaProofs

noncomputable def th (w : ℝ) : ℝ := (Real.exp (2*w) - 1) / (Real.exp (2*w) + 1)
noncomputable def z1 (x : ℝ) : ℝ := x * (((x * (9577081 / 2 ^ 28 : ℝ)) * x) + (6693141 / 2 ^ 23 : ℝ))
noncomputable def z2 (x : ℝ) : ℝ := (7186705221432913 / 2 ^ 53 : ℝ) * (x + ((((6444110634811895 / 2 ^ 57 : ℝ) * x) * x) * x))

lemma th_neg (w : ℝ) : th (-w) = - th w := by
  unfold th
  rw [show (2:ℝ) * -w = -(2*w) by ring, Real.exp_neg]
  have hE : Real.exp (2*w) ≠ 0 := (Real.exp_pos _).ne'
  rw [show (Real.exp (2*w))⁻¹ - 1 = (1 - Real.exp (2*w)) * (Real.exp (2*w))⁻¹ by
        rw [sub_mul, one_mul, mul_inv_cancel₀ hE],
      show (Real.exp (2*w))⁻¹ + 1 = (1 + Real.exp (2*w)) * (Real.exp (2*w))⁻¹ by
        rw [add_mul, one_mul, mul_inv_cancel₀ hE],
      mul_div_mul_right _ _ (inv_ne_zero hE), neg_div', neg_sub, add_comm (1:ℝ)]

lemma one_sub_th (w : ℝ) : 1 - th w = 2 / (Real.exp (2*w) + 1) := by
  unfold th
  have h1 : Real.exp (2*w) + 1 ≠ 0 := by positivity
  rw [eq_div_iff h1, sub_mul, div_mul_cancel₀ _ h1]
  ring

lemma th_sub (u v : ℝ) : th u - th v = 2 * (Real.exp (2*u) - Real.exp (2*v)) / ((Real.exp (2*u) + 1) * (Real.exp (2*v) + 1)) := by
  unfold th
  have h1 : Real.exp (2*u) + 1 ≠ 0 := by positivity
  have h2 : Real.exp (2*v) + 1 ≠ 0 := by positivity
  rw [div_sub_div _ _ h1 h2]
  congr 1; ring

lemma th_lip (u v : ℝ) (h : |u - v| ≤ 1/2) : |th u - th v| ≤ 8 * |u - v| := by
  have hEu := Real.exp_pos (2*u)
  have hEv := Real.exp_pos (2*v)
  have he : Real.exp (2*u) = Real.exp (2*v) * Real.exp (2*(u-v)) := by
    rw [← Real.exp_add]; congr 1; ring
  have hb : |Real.exp (2*(u-v)) - 1| ≤ 2 * |2*(u-v)| :=
    Real.abs_exp_sub_one_le (by rw [abs_mul, abs_of_pos (by norm_num : (0:ℝ) < 2)]; linarith)
  rw [abs_mul, abs_of_pos (by norm_num : (0:ℝ) < 2)] at hb
  rw [th_sub, abs_div, div_le_iff₀ (by positivity)]
  rw [abs_of_pos (by positivity : (0:ℝ) < (Real.exp (2*u) + 1) * (Real.exp (2*v) + 1))]
  have : 2 * (Real.exp (2*u) - Real.exp (2*v)) = 2 * Real.exp (2*v) * (Real.exp (2*(u-v)) - 1) := by
    rw [he]; ring
  rw [this, abs_mul, abs_of_pos (by positivity : (0:ℝ) < 2 * Real.exp (2*v))]
  calc 2 * Real.exp (2*v) * |Real.exp (2*(u-v)) - 1| ≤ 2 * Real.exp (2*v) * (2 * (2 * |u-v|)) :=
        mul_le_mul_of_nonneg_left hb (by positivity)
    _ = 8 * |u-v| * Real.exp (2*v) := by ring
    _ ≤ 8 * |u-v| * ((Real.exp (2*u) + 1) * (Real.exp (2*v) + 1)) :=
        mul_le_mul_of_nonneg_left (by nlinarith [mul_pos hEu hEv]) (by positivity)

lemma aux (B A x : ℝ) (hB : |B| ≤ 3/100000000) (hA : |A| ≤ 5/1000000000) (hx : |x| ≤ 10) :
    |x * (B + A * x^2)| ≤ 1/100000 := by
  have hx2 : x^2 ≤ 100 := by rw [← sq_abs]; nlinarith [abs_nonneg x]
  rw [abs_mul]
  have h1 : |B + A * x^2| ≤ 3/100000000 + 5/1000000000 * 100 := by
    calc |B + A*x^2| ≤ |B| + |A*x^2| := abs_add_le _ _
      _ = |B| + |A| * x^2 := by rw [abs_mul, abs_of_nonneg (sq_nonneg x)]
      _ ≤ _ := by
        have := mul_le_mul hA hx2 (sq_nonneg x) (by norm_num)
        linarith
  calc |x| * |B + A*x^2| ≤ 10 * (3/100000000 + 5/1000000000 * 100) :=
        mul_le_mul hx h1 (abs_nonneg _) (by norm_num)
    _ ≤ 1/100000 := by norm_num

lemma dbound (x : ℝ) (hx : |x| ≤ 10) : |z1 x - z2 x| ≤ 1/100000 := by
  have e : z1 x - z2 x = x * ((6693141 / 2 ^ 23 - 7186705221432913 / 2 ^ 53) +
      (9577081 / 2 ^ 28 - 7186705221432913 / 2 ^ 53 * (6444110634811895 / 2 ^ 57)) * x^2) := by
    unfold z1 z2; ring
  rw [e]
  apply aux _ _ _ _ _ hx
  · rw [abs_le]; constructor <;> norm_num
  · rw [abs_le]; constructor <;> norm_num

lemma small (x : ℝ) (hx : |x| ≤ 10) : |x * (th (z1 x) - th (z2 x))| ≤ 1/500 := by
  have hd := dbound x hx
  have hl := th_lip (z1 x) (z2 x) (by linarith)
  rw [abs_mul]
  calc |x| * |th (z1 x) - th (z2 x)| ≤ 10 * (8 * (1/100000)) :=
        mul_le_mul hx (by linarith) (abs_nonneg _) (by norm_num)
    _ ≤ 1/500 := by norm_num

lemma ebound (x z : ℝ) (hx : 10 ≤ x) (hz : 356/10000 * x^3 ≤ z) : 1000 * x ≤ Real.exp (2*z) := by
  have h4 : Real.exp (2*z) = Real.exp (z/2) ^ 4 := by
    rw [← Real.exp_nat_mul]; congr 1; push_cast; ring
  have h1 := Real.add_one_le_exp (z/2)
  have hx2 : 100 ≤ x^2 := by nlinarith
  have hx3 : 100 * x ≤ x^3 := by
    nlinarith [mul_le_mul_of_nonneg_left hx2 (by linarith : (0:ℝ) ≤ x)]
  have hw : 178/100 * x ≤ z/2 := by linarith
  have hw17 : 178/10 ≤ z/2 := by linarith
  have hw3 : (178/10:ℝ)^3 ≤ (z/2)^3 := pow_le_pow_left₀ (by norm_num) hw17 3
  have hw3' : (5639:ℝ) ≤ (z/2)^3 := le_trans (by norm_num) hw3
  have hw4 : 1000 * x ≤ (z/2)^4 := by
    have e : (z/2)^4 = (z/2)^3 * (z/2) := by ring
    rw [e]
    have := mul_le_mul hw3' hw (by linarith) (pow_nonneg (by linarith) 3)
    linarith
  rw [h4]
  calc 1000 * x ≤ (z/2)^4 := hw4
    _ ≤ (z/2 + 1)^4 := pow_le_pow_left₀ (by linarith) (by linarith) 4
    _ ≤ Real.exp (z/2) ^ 4 := pow_le_pow_left₀ (by linarith) h1 4

lemma tail (x z : ℝ) (hx : 10 ≤ x) (hz : 356/10000 * x^3 ≤ z) :
    0 ≤ x * (1 - th z) ∧ x * (1 - th z) ≤ 1/500 := by
  rw [one_sub_th]
  have hE := ebound x z hx hz
  have hpos : 0 < Real.exp (2*z) + 1 := by positivity
  constructor
  · exact mul_nonneg (by linarith) (by positivity)
  · rw [← mul_div_assoc, div_le_iff₀ hpos]; linarith

lemma large (x : ℝ) (hx : 10 ≤ x) : |x * (th (z1 x) - th (z2 x))| ≤ 1/500 := by
  have hx3 : 0 ≤ x^3 := pow_nonneg (by linarith) 3
  have h1 : 356/10000 * x^3 ≤ z1 x := by
    have e : z1 x - 356/10000 * x^3 = (9577081 / 2 ^ 28 - 356/10000) * x^3 + 6693141 / 2 ^ 23 * x := by
      unfold z1; ring
    have : 0 ≤ (9577081 / 2 ^ 28 - 356/10000 : ℝ) * x^3 + 6693141 / 2 ^ 23 * x :=
      add_nonneg (mul_nonneg (by norm_num) hx3) (mul_nonneg (by norm_num) (by linarith))
    linarith
  have h2 : 356/10000 * x^3 ≤ z2 x := by
    have e : z2 x - 356/10000 * x^3 = (7186705221432913 / 2 ^ 53 * (6444110634811895 / 2 ^ 57) - 356/10000) * x^3
        + 7186705221432913 / 2 ^ 53 * x := by
      unfold z2; ring
    have : 0 ≤ (7186705221432913 / 2 ^ 53 * (6444110634811895 / 2 ^ 57) - 356/10000 : ℝ) * x^3
        + 7186705221432913 / 2 ^ 53 * x :=
      add_nonneg (mul_nonneg (by norm_num) hx3) (mul_nonneg (by norm_num) (by linarith))
    linarith
  obtain ⟨a1, b1⟩ := tail x _ hx h1
  obtain ⟨a2, b2⟩ := tail x _ hx h2
  have e : x * (th (z1 x) - th (z2 x)) = x * (1 - th (z2 x)) - x * (1 - th (z1 x)) := by ring
  rw [e, abs_le]; constructor <;> linarith

lemma key (x : ℝ) : |x * (th (z1 x) - th (z2 x))| ≤ 1/500 := by
  rcases le_or_gt (|x|) 10 with h | h
  · exact small x h
  · rcases le_or_gt 0 x with hx | hx
    · rw [abs_of_nonneg hx] at h; exact large x h.le
    · rw [abs_of_neg hx] at h
      have := large (-x) h.le
      rw [show z1 x = -z1 (-x) by unfold z1; ring, show z2 x = -z2 (-x) by unfold z2; ring,
        th_neg, th_neg]
      have e : x * (-th (z1 (-x)) - -th (z2 (-x))) = (-x) * (th (z1 (-x)) - th (z2 (-x))) := by ring
      rw [e]; exact this

lemma core (x y : ℝ) (h : x = y) :
    |(((x * ((Real.exp ((x * (((x * (9577081 / 2 ^ 28 : ℝ)) * x) + (6693141 / 2 ^ 23 : ℝ))) * (2 : ℝ)) - (1 : ℝ)) / (Real.exp ((x * (((x * (9577081 / 2 ^ 28 : ℝ)) * x) + (6693141 / 2 ^ 23 : ℝ))) * (2 : ℝ)) + (1 : ℝ)))) + x) * (0.5 : ℝ)) - (((0.5 : ℝ) * y) * ((1 : ℝ) + ((Real.exp ((2 : ℝ) * ((7186705221432913 / 2 ^ 53 : ℝ) * (y + ((((6444110634811895 / 2 ^ 57 : ℝ) * y) * y) * y)))) - (1 : ℝ)) / (Real.exp ((2 : ℝ) * ((7186705221432913 / 2 ^ 53 : ℝ) * (y + ((((6444110634811895 / 2 ^ 57 : ℝ) * y) * y) * y)))) + (1 : ℝ)))))| ≤ (0.001 : ℝ) := by
  subst h
  have h1 : (Real.exp ((x * (((x * (9577081 / 2 ^ 28 : ℝ)) * x) + (6693141 / 2 ^ 23 : ℝ))) * (2 : ℝ)) - (1 : ℝ)) / (Real.exp ((x * (((x * (9577081 / 2 ^ 28 : ℝ)) * x) + (6693141 / 2 ^ 23 : ℝ))) * (2 : ℝ)) + (1 : ℝ)) = th (z1 x) := by
    unfold th z1; rw [mul_comm _ (2:ℝ)]
  have h2 : (Real.exp ((2 : ℝ) * ((7186705221432913 / 2 ^ 53 : ℝ) * (x + ((((6444110634811895 / 2 ^ 57 : ℝ) * x) * x) * x)))) - (1 : ℝ)) / (Real.exp ((2 : ℝ) * ((7186705221432913 / 2 ^ 53 : ℝ) * (x + ((((6444110634811895 / 2 ^ 57 : ℝ) * x) * x) * x)))) + (1 : ℝ)) = th (z2 x) := rfl
  rw [h1, h2, show (0.5:ℝ) = 1/2 by norm_num, show (0.001:ℝ) = 1/1000 by norm_num]
  have e : ((x * th (z1 x)) + x) * (1/2:ℝ) - ((1/2:ℝ) * x) * (1 + th (z2 x)) = (x * (th (z1 x) - th (z2 x))) / 2 := by ring
  rw [e, abs_div, abs_of_pos (by norm_num : (0:ℝ) < 2), div_le_iff₀ (by norm_num)]
  have := key x
  linarith

theorem c_0 : VoltaChallenge.c_0 := by
  dsimp only [VoltaChallenge.c_0]
  intros
  refine core _ _ ?_
  ring
theorem c_1 : VoltaChallenge.c_1 := by
  dsimp only [VoltaChallenge.c_1]
  intros
  refine core _ _ ?_
  ring
theorem c_16 : VoltaChallenge.c_16 := by
  dsimp only [VoltaChallenge.c_16]
  intros
  refine core _ _ ?_
  ring
theorem c_256 : VoltaChallenge.c_256 := by
  dsimp only [VoltaChallenge.c_256]
  intros
  refine core _ _ ?_
  ring
theorem c_272 : VoltaChallenge.c_272 := by
  dsimp only [VoltaChallenge.c_272]
  intros
  refine core _ _ ?_
  ring
theorem c_1024 : VoltaChallenge.c_1024 := by
  dsimp only [VoltaChallenge.c_1024]
  intros
  refine core _ _ ?_
  ring
theorem c_1025 : VoltaChallenge.c_1025 := by
  dsimp only [VoltaChallenge.c_1025]
  intros
  refine core _ _ ?_
  ring
theorem c_3104 : VoltaChallenge.c_3104 := by
  dsimp only [VoltaChallenge.c_3104]
  intros
  refine core _ _ ?_
  ring

end VoltaProofs
