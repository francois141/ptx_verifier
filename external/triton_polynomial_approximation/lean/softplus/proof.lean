import challenge

namespace VoltaProofs

lemma hstep {t q a Q A : ℝ} (ht : |t| ≤ 7/20) (hq : |q| ≤ Q) (ha : |a| ≤ A) :
    |q + t * a| ≤ Q + 7/20 * A := by
  have h1 := abs_add_le q (t * a)
  rw [abs_mul] at h1
  have h2 := mul_le_mul ht ha (abs_nonneg a) (by norm_num : (0:ℝ) ≤ 7/20)
  linarith

lemma Qb (t : ℝ) (ht : |t| ≤ 7/20) :
    |((0.3333318233489990234375:ℝ) - 1/3) + t * (((-8388497:ℝ)/2^25 + 1/4) + t * (((13430027:ℝ)/2^26 - 1/5) + t * (((-11196601:ℝ)/2^26 + 1/6) + t * (((9382229:ℝ)/2^26 - 1/7) + t * (((-4076403:ℝ)/2^25 + 1/8) + t * (((4726011:ℝ)/2^25 - 1/9) + t * ((-8736807:ℝ)/2^26 + 1/10)))))))| ≤ 1/4000 := by
  have b10 : |((-8736807:ℝ)/2^26 + 1/10)| ≤ 31/1000 := by
    rw [abs_le]; constructor <;> norm_num
  have b9 := hstep ht (show |((4726011:ℝ)/2^25 - 1/9)| ≤ 3/100 by
    rw [abs_le]; constructor <;> norm_num) b10
  have b8 := hstep ht (show |((-4076403:ℝ)/2^25 + 1/8)| ≤ 1/250 by
    rw [abs_le]; constructor <;> norm_num) b9
  have b7 := hstep ht (show |((9382229:ℝ)/2^26 - 1/7)| ≤ 1/250 by
    rw [abs_le]; constructor <;> norm_num) b8
  have b6 := hstep ht (show |((-11196601:ℝ)/2^26 + 1/6)| ≤ 1/5000 by
    rw [abs_le]; constructor <;> norm_num) b7
  have b5 := hstep ht (show |((13430027:ℝ)/2^26 - 1/5)| ≤ 1/5000 by
    rw [abs_le]; constructor <;> norm_num) b6
  have b4 := hstep ht (show |((-8388497:ℝ)/2^25 + 1/4)| ≤ 1/250000 by
    rw [abs_le]; constructor <;> norm_num) b5
  have b3 := hstep ht (show |((0.3333318233489990234375:ℝ) - 1/3)| ≤ 1/500000 by
    rw [abs_le]; constructor <;> norm_num) b4
  exact b3.trans (by norm_num)

set_option maxHeartbeats 4000000 in
theorem y_0 : VoltaChallenge.y_0 := by
  intro v0 v1 v2 hv x0 x1 x2 x3
  have hx0 : x0 = Real.exp v0 + 1 := rfl
  have hx0ge : (1:ℝ) ≤ x0 := by rw [hx0]; linarith [Real.exp_pos v0]
  have hnlt : ¬ (x0 < (1 / 2 ^ 126 : ℝ)) := by
    rw [not_lt]; linarith [show (1 / 2 ^ 126 : ℝ) ≤ 1 by norm_num]
  have hx1 : x1 = x0 := if_neg hnlt
  have hx2 : x2 = (⌊(Real.log (x1 / (11184811 / 2 ^ 24 : ℝ)) / Real.log (2 : ℝ))⌋ : ℝ) := rfl
  have hx3 : x3 = (x1 * Real.exp ((-x2) * Real.log (2 : ℝ))) + (-1 : ℝ) := rfl
  clear_value x3 x2 x1 x0
  rw [if_neg hnlt]
  have hx1pos : 0 < x1 := by rw [hx1]; linarith
  rw [if_neg hx1pos.ne', if_pos hx1pos.le]
  have hfl1 : x2 ≤ Real.log (x1 / (11184811 / 2 ^ 24 : ℝ)) / Real.log 2 := by
    rw [hx2]; exact Int.floor_le _
  have hfl2 : Real.log (x1 / (11184811 / 2 ^ 24 : ℝ)) / Real.log 2 < x2 + 1 := by
    rw [hx2]; exact Int.lt_floor_add_one _
  have hl2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hc1 : 0 < x1 / (11184811 / 2 ^ 24 : ℝ) := by positivity
  have hA : x2 * Real.log 2 ≤ Real.log (x1 / (11184811 / 2 ^ 24 : ℝ)) := by
    rw [le_div_iff₀ hl2] at hfl1; exact hfl1
  have hB : Real.log (x1 / (11184811 / 2 ^ 24 : ℝ)) < (x2 + 1) * Real.log 2 := by
    rw [div_lt_iff₀ hl2] at hfl2; exact hfl2
  obtain ⟨E, hE⟩ : ∃ E, E = Real.exp (x2 * Real.log 2) := ⟨_, rfl⟩
  have hEpos : 0 < E := by rw [hE]; exact Real.exp_pos _
  have hE1 : E ≤ x1 / (11184811 / 2 ^ 24 : ℝ) := by
    rw [hE, ← Real.exp_log hc1]; exact Real.exp_le_exp.mpr hA
  have hE2 : x1 / (11184811 / 2 ^ 24 : ℝ) < 2 * E := by
    have h2E : Real.exp ((x2 + 1) * Real.log 2) = 2 * E := by
      rw [add_mul, one_mul, Real.exp_add, Real.exp_log (by norm_num : (0:ℝ) < 2), hE]; ring
    rw [← h2E, ← Real.exp_log hc1]
    exact Real.exp_lt_exp.mpr hB
  rw [le_div_iff₀ (by norm_num)] at hE1
  rw [div_lt_iff₀ (by norm_num)] at hE2
  have ht : x3 = x1 / E - 1 := by
    rw [hx3, neg_mul, Real.exp_neg, ← hE]; ring
  have htlo : -(7/20) ≤ x3 := by
    have : (11184811 / 2 ^ 24 : ℝ) ≤ x1 / E := by rw [le_div_iff₀ hEpos]; linarith
    rw [ht]; norm_num at this ⊢; linarith
  have hthi : x3 ≤ 7/20 := by
    have : x1 / E < 2 * (11184811 / 2 ^ 24 : ℝ) := by rw [div_lt_iff₀ hEpos]; linarith
    rw [ht]; norm_num at this ⊢; linarith
  have hT : |x3| ≤ 7/20 := abs_le.mpr ⟨htlo, hthi⟩
  have hx1e : 1 + Real.exp v0 = x1 := by rw [hx1, hx0]; ring
  have hlog : Real.log (1 + Real.exp v0) = x2 * Real.log 2 + Real.log (1 + x3) := by
    have h1 : 1 + x3 = x1 / E := by rw [ht]; ring
    rw [h1, Real.log_div hx1pos.ne' hEpos.ne', hE, Real.log_exp, hx1e]; ring
  have hy0 : 0 ≤ Real.log (x1 / (11184811 / 2 ^ 24 : ℝ)) :=
    Real.log_nonneg (by rw [le_div_iff₀ (by norm_num)]; rw [hx1]; norm_num; linarith)
  have hn_lo : -1 ≤ x2 := by
    by_contra h
    push_neg at h
    nlinarith [mul_neg_of_neg_of_pos (by linarith : x2 + 1 < 0) hl2]
  have hup : Real.log (x1 / (11184811 / 2 ^ 24 : ℝ)) ≤ 90 := by
    have hexp88 : Real.exp v0 ≤ Real.exp 88 := Real.exp_le_exp.mpr (abs_le.mp hv).2
    have h3 : 3 ≤ Real.exp 2 := by linarith [Real.add_one_le_exp (2:ℝ)]
    have h89 : 89 ≤ Real.exp 88 := by linarith [Real.add_one_le_exp (88:ℝ)]
    have h90 : Real.exp 90 = Real.exp 88 * Real.exp 2 := by rw [← Real.exp_add]; norm_num
    have hm := mul_le_mul_of_nonneg_left h3 (Real.exp_pos 88).le
    have : x1 / (11184811 / 2 ^ 24 : ℝ) ≤ Real.exp 90 := by
      rw [div_le_iff₀ (by norm_num), h90, hx1, hx0]; norm_num; nlinarith
    calc Real.log (x1 / (11184811 / 2 ^ 24 : ℝ)) ≤ Real.log (Real.exp 90) :=
          Real.log_le_log hc1 this
      _ = 90 := Real.log_exp 90
  have hn_hi : x2 ≤ 131 := by
    by_contra h
    push_neg at h
    have := mul_lt_mul_of_pos_right h hl2
    linarith [Real.log_two_gt_d9]
  have hlt : |-x3| < 1 := by rw [abs_neg]; linarith
  have hTay := Real.abs_log_sub_add_sum_range_le hlt 10
  rw [sub_neg_eq_add, abs_neg] at hTay
  have hrem : |x3| ^ (10 + 1) / (1 - |x3|) ≤ 1/10000 := by
    rw [div_le_iff₀ (by linarith)]
    have : |x3| ^ (10 + 1) ≤ (7/20 : ℝ) ^ (10 + 1) := pow_le_pow_left₀ (abs_nonneg _) hT _
    norm_num at this ⊢; linarith
  have hD : (x3 * ((((((((((((((((((-8736807 / 2 ^ 26 : ℝ) * x3) + (4726011 / 2 ^ 25 : ℝ)) * x3) + (-4076403 / 2 ^ 25 : ℝ)) * x3) + (9382229 / 2 ^ 26 : ℝ)) * x3) + (-11196601 / 2 ^ 26 : ℝ)) * x3) + (13430027 / 2 ^ 26 : ℝ)) * x3) + (-8388497 / 2 ^ 25 : ℝ)) * x3) + (0.3333318233489990234375 : ℝ)) * x3) + (-0.5 : ℝ)))) * x3 + x3
      + (∑ i ∈ Finset.range 10, (-x3) ^ (i + 1) / (i + 1))
      = x3 ^ 3 * (((0.3333318233489990234375:ℝ) - 1/3) + x3 * (((-8388497:ℝ)/2^25 + 1/4) + x3 * (((13430027:ℝ)/2^26 - 1/5) + x3 * (((-11196601:ℝ)/2^26 + 1/6) + x3 * (((9382229:ℝ)/2^26 - 1/7) + x3 * (((-4076403:ℝ)/2^25 + 1/8) + x3 * (((4726011:ℝ)/2^25 - 1/9) + x3 * ((-8736807:ℝ)/2^26 + 1/10)))))))) := by
    simp only [Finset.sum_range_succ, Finset.sum_range_zero]
    push_cast
    ring
  have hQ := Qb x3 hT
  have hDb : |x3 ^ 3 * (((0.3333318233489990234375:ℝ) - 1/3) + x3 * (((-8388497:ℝ)/2^25 + 1/4) + x3 * (((13430027:ℝ)/2^26 - 1/5) + x3 * (((-11196601:ℝ)/2^26 + 1/6) + x3 * (((9382229:ℝ)/2^26 - 1/7) + x3 * (((-4076403:ℝ)/2^25 + 1/8) + x3 * (((4726011:ℝ)/2^25 - 1/9) + x3 * ((-8736807:ℝ)/2^26 + 1/10))))))))| ≤ 1/10000 := by
    rw [abs_mul, abs_pow]
    have h1 : |x3| ^ 3 ≤ (7/20 : ℝ) ^ 3 := pow_le_pow_left₀ (abs_nonneg _) hT _
    have h2 := mul_le_mul h1 hQ (abs_nonneg _) (by positivity)
    refine h2.trans ?_
    norm_num
  rw [← hD] at hDb
  have hδ1 : 0 < (0.693147182464599609375 : ℝ) - Real.log 2 := by
    linarith [Real.log_two_lt_d9]
  have hδ2 : (0.693147182464599609375 : ℝ) - Real.log 2 < 3/10^9 := by
    linarith [Real.log_two_gt_d9]
  have he1 : -(3/10^9) ≤ x2 * ((0.693147182464599609375 : ℝ) - Real.log 2) := by
    have := mul_nonneg (by linarith : 0 ≤ x2 + 1) hδ1.le
    linarith
  have he2 : x2 * ((0.693147182464599609375 : ℝ) - Real.log 2) ≤ 131 * (3/10^9) := by
    have := mul_nonneg (by linarith : 0 ≤ 131 - x2) hδ1.le
    linarith
  rw [hlog]
  have hT1 := abs_le.mp (hTay.trans hrem)
  have hD1 := abs_le.mp hDb
  rw [abs_le]
  constructor <;> linarith [hT1.1, hT1.2, hD1.1, hD1.2, he1, he2]

end VoltaProofs
