import challenge

namespace VoltaProofs

lemma aux2 (P E L2 U2 δ : ℝ) (hE0 : 0 ≤ E) (hL : L2 ≤ E) (hU : E ≤ U2) (hP1 : P ≤ 1 - δ)
    (hd : 0 ≤ δ)
    (hg : P + 1 - δ ≤ L2 * (1 + δ - P)) (hh : U2 * (1 - δ - P) ≤ 1 + P + δ) :
    |P - (E - 1) / (E + 1)| ≤ δ := by
  have hE1 : 0 < E + 1 := by linarith
  have k1 : L2 * (1 + δ - P) ≤ E * (1 + δ - P) := mul_le_mul_of_nonneg_right hL (by linarith)
  have k2 : E * (1 - δ - P) ≤ U2 * (1 - δ - P) := mul_le_mul_of_nonneg_right hU (by linarith)
  have e : P - (E - 1) / (E + 1) = (P * (E + 1) - (E - 1)) / (E + 1) := by
    rw [eq_div_iff hE1.ne', sub_mul, div_mul_cancel₀ _ hE1.ne']
  rw [e, abs_div, abs_of_pos hE1, div_le_iff₀ hE1, abs_le]
  constructor <;> nlinarith

lemma tsym (y : ℝ) : (Real.exp (2 * (-y)) - 1) / (Real.exp (2 * (-y)) + 1)
    = -((Real.exp (2 * y) - 1) / (Real.exp (2 * y) + 1)) := by
  have h1 : Real.exp (2 * (-y)) = (Real.exp (2 * y))⁻¹ := by
    rw [← Real.exp_neg]; ring_nf
  rw [h1]
  have hp := Real.exp_pos (2 * y)
  have hne : Real.exp (2 * y) ≠ 0 := hp.ne'
  have hi : 0 < (Real.exp (2 * y))⁻¹ := inv_pos.mpr hp
  rw [neg_div', div_eq_div_iff (by linarith) (by linarith)]
  have := mul_inv_cancel₀ hne
  linear_combination (2:ℝ) * this

lemma bigc (E : ℝ) (hE : 0 < E) : 1 / (1 + E) * (-2) + 1 - (E - 1) / (E + 1) = 0 := by
  have hne : (1:ℝ) + E ≠ 0 := by linarith
  have hne' : E + 1 ≠ 0 := by linarith
  rw [sub_eq_zero, eq_div_iff hne']
  have hinv : (1 + E) * (1 / (1 + E)) = 1 := mul_one_div_cancel hne
  linear_combination (-2:ℝ) * hinv

lemma signk (x Y : ℝ)
    (hY : |Y - (Real.exp (2 * |x|) - 1) / (Real.exp (2 * |x|) + 1)| ≤ 1 / 1000) :
    |(if x < 0 then -|Y| else |Y|) - (Real.exp (2 * x) - 1) / (Real.exp (2 * x) + 1)|
      ≤ (0.001 : ℝ) := by
  have hd : (0.001 : ℝ) = 1 / 1000 := by norm_num
  rw [hd]
  set T := (Real.exp (2 * |x|) - 1) / (Real.exp (2 * |x|) + 1) with hTdef
  have hT0 : 0 ≤ T := by
    have h1 : 1 ≤ Real.exp (2 * |x|) := Real.one_le_exp (by positivity)
    apply div_nonneg <;> linarith
  have h' : |(|Y|) - T| ≤ 1 / 1000 := by
    have := abs_abs_sub_abs_le_abs_sub Y T
    rw [abs_of_nonneg hT0] at this
    linarith
  by_cases hx : x < 0
  · rw [if_pos hx]
    have e : (Real.exp (2 * x) - 1) / (Real.exp (2 * x) + 1) = -T := by
      rw [hTdef, abs_of_neg hx, ← tsym (-x), neg_neg]
    rw [e, show -|Y| - -T = -(|Y| - T) by ring, abs_neg]
    exact h'
  · rw [if_neg hx]
    have e : (Real.exp (2 * x) - 1) / (Real.exp (2 * x) + 1) = T := by
      rw [hTdef, abs_of_nonneg (not_lt.mp hx)]
    rw [e]; exact h'

lemma small (t P : ℝ) (ht0 : 0 ≤ t) (htc : t < 0.625)
    (hP : P = t + t ^ 3 * ((-11184793 / 2 ^ 25 : ℝ) + t ^ 2 * ((4473281 / 2 ^ 25 : ℝ)
      + t ^ 2 * ((-7212583 / 2 ^ 27 : ℝ) + t ^ 2 * ((11077833 / 2 ^ 29 : ℝ)
      + t ^ 2 * (-12240701 / 2 ^ 31 : ℝ)))))) :
    |P - (Real.exp (2 * t) - 1) / (Real.exp (2 * t) + 1)| ≤ 1 / 1000 := by
  subst hP
  have htc' : t ≤ 5 / 8 := by norm_num at htc; linarith
  have hb := Real.exp_bound (x := t) (n := 7) (by rw [abs_of_nonneg ht0]; linarith) (by norm_num)
  rw [abs_of_nonneg ht0] at hb
  obtain ⟨hb3, hb4⟩ := abs_le.mp hb
  simp only [Finset.sum_range_succ, Finset.sum_range_zero, Nat.factorial] at hb3 hb4
  norm_num at hb3 hb4
  have hp : ∀ k : ℕ, t ^ k ≤ (5 / 8 : ℝ) ^ k := fun k => pow_le_pow_left₀ ht0 htc' k
  have hn : ∀ k : ℕ, 0 ≤ t ^ k := fun k => pow_nonneg ht0 k
  have b1 := hp 1
  have b2 := hp 2
  have b3 := hp 3
  have b4 := hp 4
  have b5 := hp 5
  have b6 := hp 6
  have b7 := hp 7
  have b8 := hp 8
  have b9 := hp 9
  have b10 := hp 10
  have b11 := hp 11
  have b12 := hp 12
  have b13 := hp 13
  have b14 := hp 14
  have b15 := hp 15
  have b16 := hp 16
  have b17 := hp 17
  have b18 := hp 18
  have b19 := hp 19
  have b20 := hp 20
  have b21 := hp 21
  have b22 := hp 22
  have b23 := hp 23
  have b24 := hp 24
  have b25 := hp 25
  norm_num at b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16 b17 b18 b19 b20 b21 b22 b23 b24 b25
  have n2 := hn 2
  have n3 := hn 3
  have n4 := hn 4
  have n5 := hn 5
  have n6 := hn 6
  have n7 := hn 7
  have n8 := hn 8
  have n9 := hn 9
  have n10 := hn 10
  have n11 := hn 11
  have n12 := hn 12
  have n13 := hn 13
  have n14 := hn 14
  have n15 := hn 15
  have n16 := hn 16
  have n17 := hn 17
  have n18 := hn 18
  have n19 := hn 19
  have n20 := hn 20
  have n21 := hn 21
  have n22 := hn 22
  have n23 := hn 23
  have n24 := hn 24
  have n25 := hn 25
  have hyL : 1 + t + t^2/2 + t^3/6 + t^4/24 + t^5/120 + t^6/720 - t^7/4410 ≤ Real.exp t := by
    linarith
  have hyU : Real.exp t ≤ 1 + t + t^2/2 + t^3/6 + t^4/24 + t^5/120 + t^6/720 + t^7/4410 := by
    linarith
  have hL0 : 0 ≤ 1 + t + t^2/2 + t^3/6 + t^4/24 + t^5/120 + t^6/720 - t^7/4410 := by
    linarith
  have hE : Real.exp (2 * t) = Real.exp t ^ 2 := by rw [sq, ← Real.exp_add, two_mul]
  refine aux2 _ _ ((1 + t + t^2/2 + t^3/6 + t^4/24 + t^5/120 + t^6/720 - t^7/4410) ^ 2)
    ((1 + t + t^2/2 + t^3/6 + t^4/24 + t^5/120 + t^6/720 + t^7/4410) ^ 2) (1 / 1000)
    (Real.exp_pos _).le ?_ ?_ ?_ (by norm_num) ?_ ?_
  · rw [hE]; exact pow_le_pow_left₀ hL0 hyL 2
  · rw [hE]; exact pow_le_pow_left₀ (Real.exp_pos _).le hyU 2
  · linarith
  · linarith
  · linarith

theorem c_0 : VoltaChallenge.c_0 := by
  unfold VoltaChallenge.c_0
  intro v0 v1
  dsimp only
  generalize v1 * v0 = x
  have hAB : ¬ (|x| ≥ (0.625 : ℝ) ∧ (-87.3365478515625 : ℝ) > |x| + |x|) := by
    rintro ⟨_, h⟩
    linarith [abs_nonneg x]
  rw [if_neg hAB, if_neg hAB]
  apply signk
  split_ifs with h
  · rw [show |x| + |x| = 2 * |x| by ring]
    rw [bigc _ (Real.exp_pos _)]
    norm_num
  · rw [← abs_mul_abs_self x]
    refine small |x| _ (abs_nonneg x) (not_le.mp h) ?_
    ring

end VoltaProofs
