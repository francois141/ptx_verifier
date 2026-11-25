import challenge

set_option maxRecDepth 16384
set_option maxHeartbeats 0

namespace VoltaProofs

noncomputable def P (x3 : ℝ) : ℝ := (((x3 * (((((((((((((((((-8736807 / 2 ^ 26 : ℝ) * x3) + (4726011 / 2 ^ 25 : ℝ)) * x3) + (-4076403 / 2 ^ 25 : ℝ)) * x3) + (9382229 / 2 ^ 26 : ℝ)) * x3) + (-11196601 / 2 ^ 26 : ℝ)) * x3) + (13430027 / 2 ^ 26 : ℝ)) * x3) + (-8388497 / 2 ^ 25 : ℝ)) * x3) + (0.3333318233489990234375 : ℝ)) * x3) + (-0.5 : ℝ))) * x3) + x3)

theorem tb (c t C B : ℝ) (k : ℕ) (hc : |c| ≤ C) (ht : |t| ≤ 0.34) (hB : C * 0.34 ^ k ≤ B) :
    |c * t ^ k| ≤ B := by
  rw [abs_mul, abs_pow]
  calc |c| * |t| ^ k ≤ C * 0.34 ^ k :=
        mul_le_mul hc (pow_le_pow_left₀ (abs_nonneg t) ht k) (by positivity) (le_trans (abs_nonneg c) hc)
    _ ≤ B := hB

theorem poly_bound (t : ℝ) (ht : |t| ≤ 0.34) : |P t - Real.log (1 + t)| ≤ 0.0005 := by
  have hx : |(-t)| < 1 := by rw [abs_neg]; linarith
  have hR := Real.abs_log_sub_add_sum_range_le hx 8
  rw [sub_neg_eq_add, abs_neg] at hR
  have hat := abs_nonneg t
  have hRb : |t| ^ (8 + 1) / (1 - |t|) ≤ 0.0002 := by
    rw [div_le_iff₀ (by linarith)]
    have h9 : |t| ^ (8 + 1) ≤ 0.34 ^ (8 + 1) := pow_le_pow_left₀ hat ht _
    have h34 : (0.34 : ℝ) ^ (8 + 1) ≤ 0.0001 := by norm_num
    linarith
  have hsum : (∑ i ∈ Finset.range 8, (-t) ^ (i + 1) / ((i : ℝ) + 1)) =
      -t + t^2/2 - t^3/3 + t^4/4 - t^5/5 + t^6/6 - t^7/7 + t^8/8 := by
    simp only [Finset.sum_range_succ, Finset.sum_range_zero]
    push_cast
    ring
  rw [hsum] at hR
  have hE : P t + (-t + t^2/2 - t^3/3 + t^4/4 - t^5/5 + t^6/6 - t^7/7 + t^8/8) =
      ((0.3333318233489990234375 : ℝ) - 1/3) * t^3 + ((-8388497 / 2 ^ 25 : ℝ) + 1/4) * t^4
      + ((13430027 / 2 ^ 26 : ℝ) - 1/5) * t^5 + ((-11196601 / 2 ^ 26 : ℝ) + 1/6) * t^6
      + ((9382229 / 2 ^ 26 : ℝ) - 1/7) * t^7 + ((-4076403 / 2 ^ 25 : ℝ) + 1/8) * t^8
      + (4726011 / 2 ^ 25 : ℝ) * t^9 + (-8736807 / 2 ^ 26 : ℝ) * t^10 := by
    unfold P; ring
  have h3 := tb ((0.3333318233489990234375 : ℝ) - 1/3) t 0.004 0.00016 3
    (by rw [abs_le]; constructor <;> norm_num) ht (by norm_num)
  have h4 := tb ((-8388497 / 2 ^ 25 : ℝ) + 1/4) t 0.004 0.000054 4
    (by rw [abs_le]; constructor <;> norm_num) ht (by norm_num)
  have h5 := tb ((13430027 / 2 ^ 26 : ℝ) - 1/5) t 0.004 0.000019 5
    (by rw [abs_le]; constructor <;> norm_num) ht (by norm_num)
  have h6 := tb ((-11196601 / 2 ^ 26 : ℝ) + 1/6) t 0.004 0.000007 6
    (by rw [abs_le]; constructor <;> norm_num) ht (by norm_num)
  have h7 := tb ((9382229 / 2 ^ 26 : ℝ) - 1/7) t 0.004 0.000003 7
    (by rw [abs_le]; constructor <;> norm_num) ht (by norm_num)
  have h8 := tb ((-4076403 / 2 ^ 25 : ℝ) + 1/8) t 0.004 0.000001 8
    (by rw [abs_le]; constructor <;> norm_num) ht (by norm_num)
  have h9 := tb (4726011 / 2 ^ 25 : ℝ) t 0.15 0.00001 9
    (by rw [abs_le]; constructor <;> norm_num) ht (by norm_num)
  have h10 := tb (-8736807 / 2 ^ 26 : ℝ) t 0.14 0.000003 10
    (by rw [abs_le]; constructor <;> norm_num) ht (by norm_num)
  have hRR := hR.trans hRb
  rw [abs_le] at hRR h3 h4 h5 h6 h7 h8 h9 h10
  rw [abs_le]
  constructor <;> linarith [hRR.1, hRR.2, h3.1, h3.2, h4.1, h4.2, h5.1, h5.2, h6.1, h6.2,
    h7.1, h7.2, h8.1, h8.2, h9.1, h9.2, h10.1, h10.2]

theorem key (S T v512 v513 : ℝ) (hST : S = T) (hS : |S| ≤ 64) :
    let x0 := Real.exp S + (1 : ℝ)
    let x1 := if x0 < (1 / 2 ^ 126 : ℝ) then x0 * (8388608 : ℝ) else x0
    let x2 := (⌊(Real.log (x1 / (11184811 / 2 ^ 24 : ℝ)) / Real.log (2 : ℝ))⌋ : ℝ)
    let x3 := (x1 * Real.exp ((-x2) * Real.log (2 : ℝ))) + (-1 : ℝ)
    |(if x1 = (0 : ℝ) then v513 else if x1 ≥ (0 : ℝ) then (((((8388608 : ℝ) * x2) * (1 / 2 ^ 23 : ℝ)) + (if x0 < (1 / 2 ^ 126 : ℝ) then (-23 : ℝ) else (0 : ℝ))) * (0.693147182464599609375 : ℝ)) + (((x3 * (((((((((((((((((-8736807 / 2 ^ 26 : ℝ) * x3) + (4726011 / 2 ^ 25 : ℝ)) * x3) + (-4076403 / 2 ^ 25 : ℝ)) * x3) + (9382229 / 2 ^ 26 : ℝ)) * x3) + (-11196601 / 2 ^ 26 : ℝ)) * x3) + (13430027 / 2 ^ 26 : ℝ)) * x3) + (-8388497 / 2 ^ 25 : ℝ)) * x3) + (0.3333318233489990234375 : ℝ)) * x3) + (-0.5 : ℝ))) * x3) + x3) else v512) - Real.log ((1 : ℝ) + Real.exp T)| ≤ (0.001 : ℝ) := by
  subst hST
  intro x0 x1 x2 x3
  have hx0 : x0 = Real.exp S + 1 := rfl
  have hsmall : ¬ (x0 < (1 / 2 ^ 126 : ℝ)) := by
    rw [hx0]
    have h1 : (1 / 2 ^ 126 : ℝ) ≤ 1 := by norm_num
    have h2 := Real.exp_pos S
    exact not_lt.mpr (by linarith)
  have hx1 : x1 = x0 := if_neg hsmall
  have hx2 : x2 = (⌊(Real.log (x1 / (11184811 / 2 ^ 24 : ℝ)) / Real.log (2 : ℝ))⌋ : ℝ) := rfl
  have hx3 : x3 = (x1 * Real.exp ((-x2) * Real.log (2 : ℝ))) + (-1 : ℝ) := rfl
  clear_value x3 x2 x1 x0
  have hS64 : S ≤ 64 := le_trans (le_abs_self S) hS
  have hy : x1 = Real.exp S + 1 := by rw [hx1, hx0]
  have hexpS := Real.exp_pos S
  have hy1 : 1 < x1 := by rw [hy]; linarith
  have hypos : 0 < x1 := by linarith
  rw [if_neg hsmall, if_neg (show ¬ (x1 = 0) from ne_of_gt hypos),
    if_pos (show x1 ≥ 0 from le_of_lt hypos)]
  rw [show (1:ℝ) + Real.exp S = x1 by rw [hy]; ring]
  have hl2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hl2a := Real.log_two_gt_d9
  have hl2b := Real.log_two_lt_d9
  have hcpos : (0:ℝ) < 11184811 / 2 ^ 24 := by norm_num
  have hcb1 : (0.66:ℝ) ≤ 11184811 / 2 ^ 24 := by norm_num
  have hcb2 : (11184811 / 2 ^ 24 : ℝ) ≤ 0.67 := by norm_num
  have hcb3 : (11184811 / 2 ^ 24 : ℝ) < 1 := by norm_num
  have hfl1 := Int.floor_le (Real.log (x1 / (11184811 / 2 ^ 24 : ℝ)) / Real.log 2)
  have hfl2 := Int.lt_floor_add_one (Real.log (x1 / (11184811 / 2 ^ 24 : ℝ)) / Real.log 2)
  rw [← hx2] at hfl1 hfl2
  have hq : 0 < x1 / (11184811 / 2 ^ 24 : ℝ) := div_pos hypos hcpos
  have hq1 : 1 ≤ x1 / (11184811 / 2 ^ 24 : ℝ) := by
    rw [le_div_iff₀ hcpos]; linarith
  have hn0 : 0 ≤ x2 := by
    rw [hx2]
    have : 0 ≤ Real.log (x1 / (11184811 / 2 ^ 24 : ℝ)) / Real.log 2 :=
      div_nonneg (Real.log_nonneg hq1) hl2.le
    exact_mod_cast Int.floor_nonneg.mpr this
  rw [le_div_iff₀ hl2] at hfl1
  rw [div_lt_iff₀ hl2] at hfl2
  have hlog66 : Real.log (x1 / (11184811 / 2 ^ 24 : ℝ)) ≤ 66 := by
    rw [Real.log_le_iff_le_exp hq, div_le_iff₀ hcpos, show (66:ℝ) = 64 + 2 by norm_num,
      Real.exp_add]
    have hA := Real.add_one_le_exp (64:ℝ)
    have hB := Real.add_one_le_exp (2:ℝ)
    have hSA := Real.exp_le_exp.mpr hS64
    have hApos := Real.exp_pos (64:ℝ)
    have h1 : Real.exp 64 * 3 ≤ Real.exp 64 * Real.exp 2 :=
      mul_le_mul_of_nonneg_left (by linarith) hApos.le
    have h2 : Real.exp 64 * Real.exp 2 * 0.66 ≤ Real.exp 64 * Real.exp 2 * (11184811 / 2 ^ 24) :=
      mul_le_mul_of_nonneg_left hcb1 (by positivity)
    rw [hy]; linarith
  have hn100 : x2 ≤ 100 := by
    have : x2 * 0.6931471803 ≤ x2 * Real.log 2 := mul_le_mul_of_nonneg_left hl2a.le hn0
    linarith
  have hEpos := Real.exp_pos (x2 * Real.log 2)
  have hE1 : Real.exp (x2 * Real.log 2) ≤ x1 / (11184811 / 2 ^ 24 : ℝ) :=
    (Real.exp_le_exp.mpr hfl1).trans_eq (Real.exp_log hq)
  have hE2 : x1 / (11184811 / 2 ^ 24 : ℝ) < Real.exp (x2 * Real.log 2) * 2 := by
    have h := Real.exp_lt_exp.mpr hfl2
    rw [Real.exp_log hq, add_mul, one_mul, Real.exp_add, Real.exp_log two_pos] at h
    exact h
  have hx3' : x3 = x1 / Real.exp (x2 * Real.log 2) - 1 := by
    rw [hx3, neg_mul, Real.exp_neg, div_eq_mul_inv]; ring
  have hlogE : Real.log (Real.exp (x2 * Real.log 2)) = x2 * Real.log 2 := Real.log_exp _
  generalize Real.exp (x2 * Real.log 2) = E at hEpos hE1 hE2 hx3' hlogE
  rw [le_div_iff₀ hcpos] at hE1
  rw [div_lt_iff₀ hcpos] at hE2
  have hr1 : 0.66 ≤ x1 / E := by
    rw [le_div_iff₀ hEpos]
    have : E * 0.66 ≤ E * (11184811 / 2 ^ 24) := mul_le_mul_of_nonneg_left hcb1 hEpos.le
    linarith
  have hr2 : x1 / E ≤ 2 * 0.67 := by
    rw [div_le_iff₀ hEpos]
    have : E * 2 * (11184811 / 2 ^ 24) ≤ E * 2 * 0.67 :=
      mul_le_mul_of_nonneg_left hcb2 (by linarith)
    linarith
  have ht : |x3| ≤ 0.34 := by
    rw [abs_le, hx3']; constructor <;> linarith
  have hlogx1 : Real.log x1 = Real.log (1 + x3) + x2 * Real.log 2 := by
    have hEne : E ≠ 0 := ne_of_gt hEpos
    have hmul : x1 / E * E = x1 := by field_simp
    rw [← hlogE, hx3', show (1:ℝ) + (x1 / E - 1) = x1 / E by ring,
      ← Real.log_mul (ne_of_gt (div_pos hypos hEpos)) hEne, hmul]
  show |(((8388608 : ℝ) * x2) * (1 / 2 ^ 23 : ℝ) + (0 : ℝ)) * (0.693147182464599609375 : ℝ)
      + P x3 - Real.log x1| ≤ (0.001 : ℝ)
  have hfin : (((8388608 : ℝ) * x2) * (1 / 2 ^ 23 : ℝ) + (0 : ℝ)) * (0.693147182464599609375 : ℝ)
      + P x3 - Real.log x1
      = x2 * ((0.693147182464599609375 : ℝ) - Real.log 2) + (P x3 - Real.log (1 + x3)) := by
    rw [hlogx1]; ring
  rw [hfin]
  have hpb := poly_bound x3 ht
  have hd1 : 0 ≤ (0.693147182464599609375 : ℝ) - Real.log 2 := by linarith
  have hd2 : (0.693147182464599609375 : ℝ) - Real.log 2 ≤ 0.000000003 := by linarith
  have hm1 : 0 ≤ x2 * ((0.693147182464599609375 : ℝ) - Real.log 2) := mul_nonneg hn0 hd1
  have hm2 : x2 * ((0.693147182464599609375 : ℝ) - Real.log 2) ≤ 100 * 0.000000003 :=
    mul_le_mul hn100 hd2 hd1 (by norm_num)
  rw [abs_le] at hpb ⊢
  constructor <;> linarith [hpb.1, hpb.2]

theorem bprod {a b : ℝ} (ha : |a| ≤ (0.5:ℝ)) (hb : |b| ≤ (0.5:ℝ)) : |a * b| ≤ 0.25 := by
  rw [abs_mul]
  calc |a| * |b| ≤ 0.5 * 0.5 := mul_le_mul ha hb (abs_nonneg b) (by norm_num)
    _ = 0.25 := by norm_num

theorem bstep {a b c k : ℝ} (ha : |a| ≤ (0.5:ℝ)) (hb : |b| ≤ (0.5:ℝ)) (hc : |c| ≤ k - 0.25) :
    |a * b + c| ≤ k := by
  have h := bprod ha hb
  rw [abs_le] at h hc ⊢
  constructor <;> linarith [h.1, h.2, hc.1, hc.2]

theorem bbase {a b k : ℝ} (ha : |a| ≤ (0.5:ℝ)) (hb : |b| ≤ (0.5:ℝ)) (hk : 0.25 ≤ k) :
    |a * b| ≤ k :=
  (bprod ha hb).trans hk

theorem c_0 : VoltaChallenge.c_0 := by
  unfold VoltaChallenge.c_0
  iterate 1026 intro
  refine key _ _ _ _ (by ring) ?_
  repeat (first | exact bbase (by assumption) (by assumption) (by norm_num) | refine bstep (by assumption) (by assumption) ?_)
theorem c_1 : VoltaChallenge.c_1 := by
  unfold VoltaChallenge.c_1
  iterate 1026 intro
  refine key _ _ _ _ (by ring) ?_
  repeat (first | exact bbase (by assumption) (by assumption) (by norm_num) | refine bstep (by assumption) (by assumption) ?_)
theorem c_256 : VoltaChallenge.c_256 := by
  unfold VoltaChallenge.c_256
  iterate 1026 intro
  refine key _ _ _ _ (by ring) ?_
  repeat (first | exact bbase (by assumption) (by assumption) (by norm_num) | refine bstep (by assumption) (by assumption) ?_)

end VoltaProofs
