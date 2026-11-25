import challenge

namespace VoltaProofs

open VoltaChallenge

lemma rint_bounds (x : ℝ) : x - 1/2 ≤ rint x ∧ rint x ≤ x + 1/2 := by
  unfold rint
  split_ifs with h1 h2
  · constructor <;> linarith
  · constructor <;> linarith
  · have := abs_sub_round x
    rw [abs_le] at this
    constructor <;> linarith

lemma exp_one_le : Real.exp 1 ≤ 272 / 100 := by
  have := Real.exp_one_lt_d9
  norm_num at this ⊢
  linarith

lemma sum_bound (a b c d e f : ℝ) (ha : |a| ≤ 1/100000) (hb : |b| ≤ 1/100000)
    (hc : |c| ≤ 1/100000) (hd : |d| ≤ 1/100000) (he : |e| ≤ 1/100000)
    (hf : |f| ≤ 3/100000) : |a + b + c + d + e + f| ≤ 1/10000 := by
  rw [abs_le] at *
  constructor <;> linarith

lemma poly_bound (y : ℝ) (hy1 : |y| ≤ 1) :
    |(y * (((y * ((y * ((y * ((y * ((y * (13710257 / 2 ^ 36 : ℝ)) + (46743 / 2 ^ 25 : ℝ))) + (8947705 / 2 ^ 30 : ℝ))) + (11184769 / 2 ^ 28 : ℝ))) + (11184811 / 2 ^ 26 : ℝ))) + (0.5 : ℝ)) * y)) + y + 1 - Real.exp y| ≤ 1/10000 := by
  have hT := Real.exp_bound hy1 (n := 8) (by norm_num)
  have hS : (∑ i ∈ Finset.range 8, y ^ i / (Nat.factorial i : ℝ)) = 1 + y + y^2/2 + y^3/6 + y^4/24 + y^5/120 + y^6/720 + y^7/5040 := by
    simp [Finset.sum_range_succ, Nat.factorial]
  rw [hS] at hT
  have h8 : |y|^8 ≤ 1 := pow_le_one₀ (abs_nonneg y) hy1
  have hT' : |(1 + y + y^2/2 + y^3/6 + y^4/24 + y^5/120 + y^6/720 + y^7/5040) - Real.exp y| ≤ 3/100000 := by
    rw [abs_sub_comm]
    refine le_trans hT (le_trans (mul_le_mul_of_nonneg_right h8 (by positivity)) ?_)
    norm_num [Nat.factorial]
  have hpow : ∀ k : ℕ, |y ^ k| ≤ 1 := fun k => by
    rw [abs_pow]; exact pow_le_one₀ (abs_nonneg y) hy1
  have b : ∀ (c : ℝ) (k : ℕ), |c| ≤ 1/100000 → |c * y^k| ≤ 1/100000 := fun c k hc => by
    rw [abs_mul]
    calc |c| * |y^k| ≤ |c| * 1 := mul_le_mul_of_nonneg_left (hpow k) (abs_nonneg c)
      _ ≤ _ := by linarith
  have b3 := b (11184811 / 2 ^ 26 - 1/6 : ℝ) 3 (by rw [abs_le]; constructor <;> norm_num)
  have b4 := b (11184769 / 2 ^ 28 - 1/24 : ℝ) 4 (by rw [abs_le]; constructor <;> norm_num)
  have b5 := b (8947705 / 2 ^ 30 - 1/120 : ℝ) 5 (by rw [abs_le]; constructor <;> norm_num)
  have b6 := b (46743 / 2 ^ 25 - 1/720 : ℝ) 6 (by rw [abs_le]; constructor <;> norm_num)
  have b7 := b (13710257 / 2 ^ 36 - 1/5040 : ℝ) 7 (by rw [abs_le]; constructor <;> norm_num)
  have key : (y * (((y * ((y * ((y * ((y * ((y * (13710257 / 2 ^ 36 : ℝ)) + (46743 / 2 ^ 25 : ℝ))) + (8947705 / 2 ^ 30 : ℝ))) + (11184769 / 2 ^ 28 : ℝ))) + (11184811 / 2 ^ 26 : ℝ))) + (0.5 : ℝ)) * y)) + y + 1 - Real.exp y
      = (11184811 / 2 ^ 26 - 1/6 : ℝ) * y^3 + (11184769 / 2 ^ 28 - 1/24 : ℝ) * y^4
        + (8947705 / 2 ^ 30 - 1/120 : ℝ) * y^5 + (46743 / 2 ^ 25 - 1/720 : ℝ) * y^6
        + (13710257 / 2 ^ 36 - 1/5040 : ℝ) * y^7
        + ((1 + y + y^2/2 + y^3/6 + y^4/24 + y^5/120 + y^6/720 + y^7/5040) - Real.exp y) := by
    ring
  rw [key]
  exact sum_bound _ _ _ _ _ _ b3 b4 b5 b6 b7 hT'

lemma final (E P ey eq : ℝ) (hE0 : 0 < E) (hE : E ≤ 272/100) (hey0 : 0 < ey)
    (hey : ey ≤ 272/100) (hp : |P + 1 - ey| ≤ 1/10000) (hq : |eq - 1| ≤ 6/10000000) :
    |E * P + (-1 + E) - (0 + (E * (ey * eq) - 1))| ≤ (0.001 : ℝ) := by
  rw [show E * P + (-1 + E) - (0 + (E * (ey * eq) - 1))
      = E * (P + 1 - ey) + E * ey * (-(eq - 1)) by ring]
  calc |E * (P + 1 - ey) + E * ey * (-(eq - 1))|
      ≤ |E * (P + 1 - ey)| + |E * ey * (-(eq - 1))| := abs_add_le _ _
    _ = E * |P + 1 - ey| + E * ey * |eq - 1| := by
        rw [abs_mul, abs_mul, abs_mul, abs_neg, abs_of_pos hE0, abs_of_pos hey0]
    _ ≤ 272/100 * (1/10000) + 272/100 * (272/100) * (6/10000000) := by
        gcongr
    _ ≤ (0.001 : ℝ) := by norm_num

theorem c_0 : VoltaChallenge.c_0 := by
  intro v0 v1
  dsimp only
  generalize hx : v1 * v0 = x
  have hr := rint_bounds ((12102203 / 2 ^ 23 : ℝ) * x)
  generalize ht : rint ((12102203 / 2 ^ 23 : ℝ) * x) = t at hr ⊢
  obtain ⟨ht1, ht2⟩ := hr
  norm_num at ht1 ht2
  by_cases h0 : (0:ℝ) ≥ x
  · have h128 : ¬ ((0:ℝ) ≥ x ∧ (128:ℝ) = t) := by
      rintro ⟨_, h⟩; linarith
    rw [max_eq_right h0, min_eq_left h0]
    by_cases h17 : (-17:ℝ) ≤ x
    · simp only [if_pos h0, if_pos (And.intro h0 h17), if_neg h128]
      generalize hy : (1072225 / 2 ^ 49 : ℝ) * t + (t * (-0.693147182464599609375 : ℝ) + x) = y
      generalize hE : Real.exp (t * (8388608 / 12102203 : ℝ)) = E
      norm_num at hy
      have htl : -26 ≤ t := by linarith
      have htu : t ≤ 1/2 := by linarith
      have hE1 : E ≤ 272/100 := by
        rw [← hE]
        exact le_trans (Real.exp_le_exp.mpr (by linarith)) exp_one_le
      have hEpos : 0 < E := by rw [← hE]; exact Real.exp_pos _
      have hyb : |y| ≤ 1 := by rw [abs_le]; constructor <;> linarith
      have hey : Real.exp y ≤ 272/100 := le_trans (Real.exp_le_exp.mpr (abs_le.mp hyb).2) exp_one_le
      have hdy : |x - (8388608 / 12102203 : ℝ) * t - y| ≤ 3/10000000 := by
        rw [abs_le]; constructor <;> linarith
      have hq : |Real.exp (x - (8388608 / 12102203 : ℝ) * t - y) - 1| ≤ 6/10000000 := by
        have := Real.abs_exp_sub_one_le (le_trans hdy (by norm_num))
        linarith
      have hxe : Real.exp x = E * (Real.exp y * Real.exp (x - (8388608 / 12102203 : ℝ) * t - y)) := by
        rw [← hE, ← Real.exp_add, ← Real.exp_add]
        congr 1
        ring
      rw [hxe]
      exact final E _ (Real.exp y) _ hEpos hE1 (Real.exp_pos y) hey (poly_bound y hyb) hq
    · simp only [if_pos h0, if_neg (fun h : (0:ℝ) ≥ x ∧ (-17:ℝ) ≤ x => h17 h.2)]
      have he : Real.exp 17 = Real.exp 1 ^ 17 := by rw [← Real.exp_nat_mul]; norm_num
      have h2 : (2:ℝ) ≤ Real.exp 1 := by have := Real.add_one_le_exp (1:ℝ); linarith
      have h3 : (2:ℝ)^17 ≤ Real.exp 1 ^ 17 := pow_le_pow_left₀ (by norm_num) h2 17
      have h4 : Real.exp x * Real.exp (-x) = 1 := by rw [← Real.exp_add]; simp
      have h5 : Real.exp 17 ≤ Real.exp (-x) := Real.exp_le_exp.mpr (by linarith)
      have h6 : 0 < Real.exp x := Real.exp_pos x
      have h7 : (131072:ℝ) ≤ Real.exp (-x) := by norm_num at h3; linarith
      have h8 := mul_le_mul_of_nonneg_left h7 h6.le
      rw [abs_le]; constructor <;> norm_num <;> nlinarith
  · rw [if_neg h0]
    have h0' : 0 ≤ x := le_of_lt (not_le.mp h0)
    rw [max_eq_left h0', min_eq_right h0']
    norm_num

end VoltaProofs
