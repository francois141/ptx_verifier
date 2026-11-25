import challenge

open Real MeasureTheory Set

namespace VoltaProofs

noncomputable section

/-! ## The integral part of erf -/

def Ifn (t : ℝ) : ℝ := ∫ s in (0:ℝ)..t, Real.exp (-s ^ 2)

lemma erf_eq (t : ℝ) : VoltaChallenge.erf t = 2 / Real.sqrt Real.pi * Ifn t := rfl

lemma Ifn_hasDerivAt (t : ℝ) : HasDerivAt Ifn (Real.exp (-t ^ 2)) t := by
  have hc : Continuous (fun s : ℝ => Real.exp (-s ^ 2)) := by fun_prop
  exact (hc.integral_hasStrictDerivAt 0 t).hasDerivAt

lemma Ifn_zero : Ifn 0 = 0 := by simp [Ifn]

lemma Ifn_neg (t : ℝ) : Ifn (-t) = -Ifn t := by
  have h : (∫ x in (0:ℝ)..t, (fun x => Real.exp (-x ^ 2)) (-x)) =
      ∫ x in -t..-0, (fun x => Real.exp (-x ^ 2)) x :=
    intervalIntegral.integral_comp_neg (f := fun x => Real.exp (-x ^ 2))
  simp only [neg_sq, neg_zero] at h
  rw [intervalIntegral.integral_symm 0 (-t)] at h
  unfold Ifn
  linarith

lemma mono_helper {f f' : ℝ → ℝ} {a b : ℝ} (hab : a ≤ b) (hd : ∀ x, HasDerivAt f (f' x) x)
    (hpos : ∀ x ∈ Icc a b, 0 ≤ f' x) : f a ≤ f b := by
  have hmono := monotoneOn_of_hasDerivWithinAt_nonneg (convex_Icc a b)
    (fun x _ => (hd x).continuousAt.continuousWithinAt)
    (fun x _ => (hd x).hasDerivWithinAt)
    (fun x hx => hpos x (interior_subset hx))
  exact hmono (left_mem_Icc.mpr hab) (right_mem_Icc.mpr hab) hab

lemma Ifn_lip (a b : ℝ) (hab : a ≤ b) : 0 ≤ Ifn b - Ifn a ∧ Ifn b - Ifn a ≤ b - a := by
  constructor
  · have := mono_helper (f := Ifn) (f' := fun x => Real.exp (-x ^ 2)) hab Ifn_hasDerivAt
      (fun x _ => (Real.exp_pos _).le)
    linarith
  · have := mono_helper (f := fun x => x - Ifn x) (f' := fun x => 1 - Real.exp (-x ^ 2)) hab
      (fun x => (hasDerivAt_id' x).sub (Ifn_hasDerivAt x))
      (fun x _ => by
        have : Real.exp (-x ^ 2) ≤ 1 := by
          rw [Real.exp_le_one_iff]; nlinarith [sq_nonneg x]
        linarith)
    linarith

lemma Ifn_nonneg (t : ℝ) (ht : 0 ≤ t) : 0 ≤ Ifn t := by
  have := (Ifn_lip 0 t ht).1
  rw [Ifn_zero] at this
  linarith

lemma gauss_half : ∫ x in Ioi (0:ℝ), Real.exp (-x ^ 2) = Real.sqrt Real.pi / 2 := by
  have := integral_gaussian_Ioi 1
  simpa using this

lemma gauss_int : Integrable (fun x : ℝ => Real.exp (-x ^ 2)) := by
  simpa using integrable_exp_neg_mul_sq (b := 1) one_pos

lemma tail_eq (Y : ℝ) (hY : 0 ≤ Y) :
    Real.sqrt Real.pi / 2 - Ifn Y = ∫ x in Ioi Y, Real.exp (-x ^ 2) := by
  have hdisj : Disjoint (Ioc 0 Y) (Ioi Y) := by
    rw [Set.disjoint_left]
    intro x hx hx'
    exact absurd hx.2 (not_le.mpr hx')
  rw [← gauss_half, ← Ioc_union_Ioi_eq_Ioi hY,
    setIntegral_union hdisj measurableSet_Ioi gauss_int.integrableOn gauss_int.integrableOn,
    Ifn, intervalIntegral.integral_of_le hY]
  ring

lemma Ifn_le (Y : ℝ) (hY : 0 ≤ Y) : Ifn Y ≤ Real.sqrt Real.pi / 2 := by
  have h := tail_eq Y hY
  have : 0 ≤ ∫ x in Ioi Y, Real.exp (-x ^ 2) :=
    setIntegral_nonneg measurableSet_Ioi (fun x _ => (Real.exp_pos _).le)
  linarith

lemma tail_le (Y : ℝ) (hY : 0 < Y) :
    ∫ x in Ioi Y, Real.exp (-x ^ 2) ≤ Real.exp (-Y ^ 2) / (2 * Y) := by
  have hneg : -(2 * Y) < 0 := by linarith
  have hint2 : IntegrableOn (fun x => Real.exp (Y ^ 2) * Real.exp (-(2 * Y) * x)) (Ioi Y) :=
    Integrable.const_mul (integrableOn_exp_mul_Ioi hneg Y) _
  have hE : Real.exp (Y ^ 2) * Real.exp (-(2 * Y) * Y) = Real.exp (-Y ^ 2) := by
    rw [← Real.exp_add]; ring_nf
  calc ∫ x in Ioi Y, Real.exp (-x ^ 2)
      ≤ ∫ x in Ioi Y, Real.exp (Y ^ 2) * Real.exp (-(2 * Y) * x) := by
        apply setIntegral_mono_on gauss_int.integrableOn hint2 measurableSet_Ioi
        intro x _
        rw [← Real.exp_add]
        apply Real.exp_le_exp.mpr
        nlinarith [sq_nonneg (x - Y)]
    _ = Real.exp (Y ^ 2) * (-Real.exp (-(2 * Y) * Y) / (-(2 * Y))) := by
        rw [integral_const_mul, integral_exp_mul_Ioi hneg]
    _ = Real.exp (-Y ^ 2) / (2 * Y) := by
        rw [neg_div_neg_eq, ← mul_div_assoc, hE]

/-! ## Taylor bounds on [0,1] -/

def Tp (s : ℝ) : ℝ := 1 - s^2 + s^4/2 - s^6/6 + s^8/24 - s^10/120 + s^12/720 - s^14/5040
def Ap (t : ℝ) : ℝ := t - t^3/3 + t^5/10 - t^7/42 + t^9/216 - t^11/1320 + t^13/9360 - t^15/75600

lemma exp_taylor (s : ℝ) (hs : s ^ 2 ≤ 1) : |Real.exp (-s ^ 2) - Tp s| ≤ s ^ 16 / 35840 := by
  have h := Real.exp_bound (x := -s ^ 2) (by rw [abs_neg, abs_of_nonneg (sq_nonneg s)]; exact hs)
    (n := 8) (by norm_num)
  have key : Tp s = ∑ i ∈ Finset.range 8, (-s ^ 2) ^ i / (i.factorial : ℝ) := by
    simp only [Finset.sum_range_succ, Finset.sum_range_zero, Nat.factorial, Tp]
    push_cast
    ring
  rw [key]
  refine le_trans h (le_of_eq ?_)
  rw [abs_neg, abs_of_nonneg (sq_nonneg s)]
  simp only [Nat.factorial, Nat.succ_eq_add_one]
  push_cast
  ring

lemma hd_Ap (x : ℝ) : HasDerivAt Ap (Tp x) x := by
  have h := (((((((hasDerivAt_id' x).sub ((hasDerivAt_pow 3 x).div_const 3)).add
    ((hasDerivAt_pow 5 x).div_const 10)).sub ((hasDerivAt_pow 7 x).div_const 42)).add
    ((hasDerivAt_pow 9 x).div_const 216)).sub ((hasDerivAt_pow 11 x).div_const 1320)).add
    ((hasDerivAt_pow 13 x).div_const 9360)).sub ((hasDerivAt_pow 15 x).div_const 75600)
  refine h.congr_deriv ?_
  simp only [Tp]
  push_cast
  ring

lemma Ap_zero : Ap 0 = 0 := by simp [Ap]

lemma Ifn_bounds (t : ℝ) (h0 : 0 ≤ t) (h1 : t ≤ 1) :
    Ap t - t ^ 17 / 609280 ≤ Ifn t ∧ Ifn t ≤ Ap t + t ^ 17 / 609280 := by
  have hT : ∀ s ∈ Icc 0 t, |Real.exp (-s ^ 2) - Tp s| ≤ s ^ 16 / 35840 := fun s hs =>
    exp_taylor s (by nlinarith [hs.1, hs.2])
  constructor
  · have := mono_helper (f := fun s => Ifn s - (Ap s - s ^ 17 / 609280))
      (f' := fun s => Real.exp (-s ^ 2) - (Tp s - s ^ 16 / 35840)) h0
      (fun s => ((Ifn_hasDerivAt s).sub ((hd_Ap s).sub
        ((hasDerivAt_pow 17 s).div_const 609280))).congr_deriv (by push_cast; ring))
      (fun s hs => by have := hT s hs; rw [abs_le] at this; linarith [this.1])
    linarith [Ifn_zero, Ap_zero]
  · have := mono_helper (f := fun s => (Ap s + s ^ 17 / 609280) - Ifn s)
      (f' := fun s => (Tp s + s ^ 16 / 35840) - Real.exp (-s ^ 2)) h0
      (fun s => (((hd_Ap s).add
        ((hasDerivAt_pow 17 s).div_const 609280)).sub (Ifn_hasDerivAt s)).congr_deriv
          (by push_cast; ring))
      (fun s hs => by have := hT s hs; rw [abs_le] at this; linarith [this.2])
    linarith [Ifn_zero, Ap_zero]

/-! ## constants -/

lemma sqrt_pi_bounds : (17724536/10000000 : ℝ) < Real.sqrt Real.pi ∧
    Real.sqrt Real.pi < 17724541/10000000 := by
  have h1 := Real.pi_gt_d6
  have h2 := Real.pi_lt_d6
  constructor
  · rw [Real.lt_sqrt (by positivity)]; norm_num; linarith
  · rw [Real.sqrt_lt' (by positivity)]; norm_num; linarith

lemma c_bounds : (20000000/17724541 : ℝ) ≤ 2 / Real.sqrt Real.pi ∧
    2 / Real.sqrt Real.pi ≤ 20000000/17724536 := by
  obtain ⟨h1, h2⟩ := sqrt_pi_bounds
  have hpos : 0 < Real.sqrt Real.pi := by linarith
  constructor
  · rw [div_le_div_iff₀ (by norm_num) hpos]; linarith
  · rw [div_le_div_iff₀ hpos (by norm_num)]; linarith

lemma exp7 : Real.exp (-7) ≤ 1/1096 ∧ Real.exp (-(729/100)) ≤ 1/1413 := by
  have hE := Real.exp_one_gt_d9
  have hE' := hE.le
  have h7 : Real.exp 7 = Real.exp 1 ^ 7 := by rw [← Real.exp_nat_mul]; norm_num
  have hE7 : (1096:ℝ) ≤ Real.exp 7 := by
    rw [h7]
    calc (1096:ℝ) ≤ 2.7182818283 ^ 7 := by norm_num
      _ ≤ Real.exp 1 ^ 7 := by gcongr
  have h029 : (1.29:ℝ) ≤ Real.exp 0.29 := by
    have := Real.add_one_le_exp (0.29:ℝ); linarith
  have hE729 : (1413:ℝ) ≤ Real.exp (729/100) := by
    have : Real.exp (729/100) = Real.exp 7 * Real.exp 0.29 := by
      rw [← Real.exp_add]; norm_num
    rw [this]; nlinarith [Real.exp_pos 7, Real.exp_pos 0.29]
  constructor
  · rw [Real.exp_neg, ← one_div]; exact one_div_le_one_div_of_le (by norm_num) hE7
  · rw [Real.exp_neg, ← one_div]; exact one_div_le_one_div_of_le (by norm_num) hE729

lemma K64 : (3330985 / 2 ^ 114 : ℝ) * Real.exp 64 ≤ 1.01 := by
  have hE := Real.exp_one_lt_d9
  have hE' := hE.le
  have h : Real.exp 64 = Real.exp 1 ^ 64 := by rw [← Real.exp_nat_mul]; norm_num
  rw [h]
  calc (3330985 / 2 ^ 114 : ℝ) * Real.exp 1 ^ 64 ≤ 3330985 / 2 ^ 114 * 2.7182818286 ^ 64 := by
        gcongr
    _ ≤ 1.01 := by norm_num

/-! ## kernel pieces -/

def F2 (a : ℝ) : ℝ := (a * ((a * ((a * ((a * ((a * ((a * ((a * (-9345195 / 2 ^ 39 : ℝ)) + (1626409 / 2 ^ 32 : ℝ))) + (-16569193 / 2 ^ 32 : ℝ))) + (6491225 / 2 ^ 28 : ℝ))) + (-3579193 / 2 ^ 25 : ℝ))) + (-10652413 / 2 ^ 24 : ℝ))) + (-1079525 / 2 ^ 23 : ℝ))) + (-a)

def Wf (a : ℝ) : ℝ := if (a ≥ (1 : ℝ)) ∧ ((-87.3365478515625 : ℝ) > F2 a) then (3330985 / 2 ^ 114 : ℝ) * Real.exp (if (a ≥ (1 : ℝ)) ∧ ((-87.3365478515625 : ℝ) > F2 a) then (64 : ℝ) + F2 a else F2 a) else Real.exp (if (a ≥ (1 : ℝ)) ∧ ((-87.3365478515625 : ℝ) > F2 a) then (64 : ℝ) + F2 a else F2 a)

def Pb (a b : ℝ) : ℝ := (a * ((b * ((b * ((b * ((b * ((b * (-9651681 / 2 ^ 34 : ℝ)) + (2638085 / 2 ^ 29 : ℝ))) + (-1792311 / 2 ^ 26 : ℝ))) + (7569887 / 2 ^ 26 : ℝ))) + (-0.376122951507568359375 : ℝ))) + (0.1283791065216064453125 : ℝ))) + a

def F5 (a b : ℝ) : ℝ := |(if a ≥ (1 : ℝ) then (1 : ℝ) - Wf a else Pb a b)|

def pR (t : ℝ) : ℝ := (-9345195 / 2 ^ 39 : ℝ) * t ^ 7 + (1626409 / 2 ^ 32 : ℝ) * t ^ 6 +
  (-16569193 / 2 ^ 32 : ℝ) * t ^ 5 + (6491225 / 2 ^ 28 : ℝ) * t ^ 4 +
  (-3579193 / 2 ^ 25 : ℝ) * t ^ 3 + (-10652413 / 2 ^ 24 : ℝ) * t ^ 2 +
  (-1079525 / 2 ^ 23 - 1 : ℝ) * t

def dpR (t : ℝ) : ℝ := (7 * (-9345195 / 2 ^ 39) : ℝ) * t ^ 6 + (6 * (1626409 / 2 ^ 32) : ℝ) * t ^ 5 +
  (5 * (-16569193 / 2 ^ 32) : ℝ) * t ^ 4 + (4 * (6491225 / 2 ^ 28) : ℝ) * t ^ 3 +
  (3 * (-3579193 / 2 ^ 25) : ℝ) * t ^ 2 + (2 * (-10652413 / 2 ^ 24) : ℝ) * t +
  (-1079525 / 2 ^ 23 - 1 : ℝ)

def ddpR (t : ℝ) : ℝ := (42 * (-9345195 / 2 ^ 39) : ℝ) * t ^ 5 + (30 * (1626409 / 2 ^ 32) : ℝ) * t ^ 4 +
  (20 * (-16569193 / 2 ^ 32) : ℝ) * t ^ 3 + (12 * (6491225 / 2 ^ 28) : ℝ) * t ^ 2 +
  (6 * (-3579193 / 2 ^ 25) : ℝ) * t + (2 * (-10652413 / 2 ^ 24) : ℝ)

def gcR (t : ℝ) : ℝ := ddpR t + dpR t * (2 * t + dpR t)

lemma F2_eq (a : ℝ) : F2 a = pR a := by unfold F2 pR; ring

lemma hd_pR (x : ℝ) : HasDerivAt pR (dpR x) x := by
  have h := (((((((hasDerivAt_pow 7 x).const_mul (-9345195 / 2 ^ 39 : ℝ)).add
    ((hasDerivAt_pow 6 x).const_mul (1626409 / 2 ^ 32 : ℝ))).add
    ((hasDerivAt_pow 5 x).const_mul (-16569193 / 2 ^ 32 : ℝ))).add
    ((hasDerivAt_pow 4 x).const_mul (6491225 / 2 ^ 28 : ℝ))).add
    ((hasDerivAt_pow 3 x).const_mul (-3579193 / 2 ^ 25 : ℝ))).add
    ((hasDerivAt_pow 2 x).const_mul (-10652413 / 2 ^ 24 : ℝ))).add
    ((hasDerivAt_id' x).const_mul (-1079525 / 2 ^ 23 - 1 : ℝ))
  refine h.congr_deriv ?_
  simp only [dpR]
  push_cast
  ring

lemma hd_dpR (x : ℝ) : HasDerivAt dpR (ddpR x) x := by
  have h := (((((((hasDerivAt_pow 6 x).const_mul (7 * (-9345195 / 2 ^ 39) : ℝ)).add
    ((hasDerivAt_pow 5 x).const_mul (6 * (1626409 / 2 ^ 32) : ℝ))).add
    ((hasDerivAt_pow 4 x).const_mul (5 * (-16569193 / 2 ^ 32) : ℝ))).add
    ((hasDerivAt_pow 3 x).const_mul (4 * (6491225 / 2 ^ 28) : ℝ))).add
    ((hasDerivAt_pow 2 x).const_mul (3 * (-3579193 / 2 ^ 25) : ℝ))).add
    ((hasDerivAt_id' x).const_mul (2 * (-10652413 / 2 ^ 24) : ℝ))).add
    (hasDerivAt_const x (-1079525 / 2 ^ 23 - 1 : ℝ))
  refine h.congr_deriv ?_
  simp only [ddpR]
  push_cast
  ring

def Psi (t : ℝ) : ℝ := 2 / Real.sqrt Real.pi + dpR t * Real.exp (t ^ 2 + pR t)
def Dm (t : ℝ) : ℝ := 1 - Real.exp (pR t) - 2 / Real.sqrt Real.pi * Ifn t

lemma Psi_deriv (t : ℝ) : HasDerivAt Psi (gcR t * Real.exp (t ^ 2 + pR t)) t := by
  have h := ((hd_dpR t).mul (((hasDerivAt_pow 2 t).add (hd_pR t)).exp)).const_add
    (2 / Real.sqrt Real.pi)
  refine h.congr_deriv ?_
  simp only [gcR, Pi.add_apply]
  push_cast
  ring

lemma Dm_deriv (t : ℝ) : HasDerivAt Dm (-(Real.exp (-t ^ 2) * Psi t)) t := by
  have h := ((hasDerivAt_const t (1:ℝ)).sub (hd_pR t).exp).sub
    ((Ifn_hasDerivAt t).const_mul (2 / Real.sqrt Real.pi))
  refine h.congr_deriv ?_
  have e : Real.exp (-t ^ 2) * Real.exp (t ^ 2 + pR t) = Real.exp (pR t) := by
    rw [← Real.exp_add]; ring_nf
  simp only [Psi]
  linear_combination (dpR t) * e

/-! ## polynomial pieces on [1, 2.7] -/

lemma mp0 (x : ℝ) (hx1 : 1 ≤ x) (hx2 : x ≤ 117/100) :
    |gcR x| ≤ 1/1000 ∧ x ^ 2 + pR x ≤ 0 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 1 + w := ⟨x - 1, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have h1 : w ≤ 17/100 := by linarith
  have q2 := pow_le_pow_left₀ h0 h1 2; have q3 := pow_le_pow_left₀ h0 h1 3
  have q4 := pow_le_pow_left₀ h0 h1 4; have q5 := pow_le_pow_left₀ h0 h1 5
  have q6 := pow_le_pow_left₀ h0 h1 6; have q7 := pow_le_pow_left₀ h0 h1 7
  have q8 := pow_le_pow_left₀ h0 h1 8; have q9 := pow_le_pow_left₀ h0 h1 9
  have q10 := pow_le_pow_left₀ h0 h1 10; have q11 := pow_le_pow_left₀ h0 h1 11
  have q12 := pow_le_pow_left₀ h0 h1 12
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  have n8 := pow_nonneg h0 8; have n9 := pow_nonneg h0 9; have n10 := pow_nonneg h0 10
  have n11 := pow_nonneg h0 11; have n12 := pow_nonneg h0 12
  simp only [gcR, ddpR, dpR, pR]
  refine ⟨abs_le.mpr ⟨by linarith, by linarith⟩, by linarith⟩

lemma mp1 (x : ℝ) (hx1 : 117/100 ≤ x) (hx2 : x ≤ 134/100) :
    |gcR x| ≤ 1/1000 ∧ x ^ 2 + pR x ≤ 0 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 117/100 + w := ⟨x - 117/100, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have h1 : w ≤ 17/100 := by linarith
  have q2 := pow_le_pow_left₀ h0 h1 2; have q3 := pow_le_pow_left₀ h0 h1 3
  have q4 := pow_le_pow_left₀ h0 h1 4; have q5 := pow_le_pow_left₀ h0 h1 5
  have q6 := pow_le_pow_left₀ h0 h1 6; have q7 := pow_le_pow_left₀ h0 h1 7
  have q8 := pow_le_pow_left₀ h0 h1 8; have q9 := pow_le_pow_left₀ h0 h1 9
  have q10 := pow_le_pow_left₀ h0 h1 10; have q11 := pow_le_pow_left₀ h0 h1 11
  have q12 := pow_le_pow_left₀ h0 h1 12
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  have n8 := pow_nonneg h0 8; have n9 := pow_nonneg h0 9; have n10 := pow_nonneg h0 10
  have n11 := pow_nonneg h0 11; have n12 := pow_nonneg h0 12
  simp only [gcR, ddpR, dpR, pR]
  refine ⟨abs_le.mpr ⟨by linarith, by linarith⟩, by linarith⟩

lemma mp2 (x : ℝ) (hx1 : 134/100 ≤ x) (hx2 : x ≤ 151/100) :
    |gcR x| ≤ 1/1000 ∧ x ^ 2 + pR x ≤ 0 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 134/100 + w := ⟨x - 134/100, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have h1 : w ≤ 17/100 := by linarith
  have q2 := pow_le_pow_left₀ h0 h1 2; have q3 := pow_le_pow_left₀ h0 h1 3
  have q4 := pow_le_pow_left₀ h0 h1 4; have q5 := pow_le_pow_left₀ h0 h1 5
  have q6 := pow_le_pow_left₀ h0 h1 6; have q7 := pow_le_pow_left₀ h0 h1 7
  have q8 := pow_le_pow_left₀ h0 h1 8; have q9 := pow_le_pow_left₀ h0 h1 9
  have q10 := pow_le_pow_left₀ h0 h1 10; have q11 := pow_le_pow_left₀ h0 h1 11
  have q12 := pow_le_pow_left₀ h0 h1 12
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  have n8 := pow_nonneg h0 8; have n9 := pow_nonneg h0 9; have n10 := pow_nonneg h0 10
  have n11 := pow_nonneg h0 11; have n12 := pow_nonneg h0 12
  simp only [gcR, ddpR, dpR, pR]
  refine ⟨abs_le.mpr ⟨by linarith, by linarith⟩, by linarith⟩

lemma mp3 (x : ℝ) (hx1 : 151/100 ≤ x) (hx2 : x ≤ 168/100) :
    |gcR x| ≤ 1/1000 ∧ x ^ 2 + pR x ≤ 0 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 151/100 + w := ⟨x - 151/100, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have h1 : w ≤ 17/100 := by linarith
  have q2 := pow_le_pow_left₀ h0 h1 2; have q3 := pow_le_pow_left₀ h0 h1 3
  have q4 := pow_le_pow_left₀ h0 h1 4; have q5 := pow_le_pow_left₀ h0 h1 5
  have q6 := pow_le_pow_left₀ h0 h1 6; have q7 := pow_le_pow_left₀ h0 h1 7
  have q8 := pow_le_pow_left₀ h0 h1 8; have q9 := pow_le_pow_left₀ h0 h1 9
  have q10 := pow_le_pow_left₀ h0 h1 10; have q11 := pow_le_pow_left₀ h0 h1 11
  have q12 := pow_le_pow_left₀ h0 h1 12
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  have n8 := pow_nonneg h0 8; have n9 := pow_nonneg h0 9; have n10 := pow_nonneg h0 10
  have n11 := pow_nonneg h0 11; have n12 := pow_nonneg h0 12
  simp only [gcR, ddpR, dpR, pR]
  refine ⟨abs_le.mpr ⟨by linarith, by linarith⟩, by linarith⟩

lemma mp4 (x : ℝ) (hx1 : 168/100 ≤ x) (hx2 : x ≤ 185/100) :
    |gcR x| ≤ 1/1000 ∧ x ^ 2 + pR x ≤ 0 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 168/100 + w := ⟨x - 168/100, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have h1 : w ≤ 17/100 := by linarith
  have q2 := pow_le_pow_left₀ h0 h1 2; have q3 := pow_le_pow_left₀ h0 h1 3
  have q4 := pow_le_pow_left₀ h0 h1 4; have q5 := pow_le_pow_left₀ h0 h1 5
  have q6 := pow_le_pow_left₀ h0 h1 6; have q7 := pow_le_pow_left₀ h0 h1 7
  have q8 := pow_le_pow_left₀ h0 h1 8; have q9 := pow_le_pow_left₀ h0 h1 9
  have q10 := pow_le_pow_left₀ h0 h1 10; have q11 := pow_le_pow_left₀ h0 h1 11
  have q12 := pow_le_pow_left₀ h0 h1 12
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  have n8 := pow_nonneg h0 8; have n9 := pow_nonneg h0 9; have n10 := pow_nonneg h0 10
  have n11 := pow_nonneg h0 11; have n12 := pow_nonneg h0 12
  simp only [gcR, ddpR, dpR, pR]
  refine ⟨abs_le.mpr ⟨by linarith, by linarith⟩, by linarith⟩

lemma mp5 (x : ℝ) (hx1 : 185/100 ≤ x) (hx2 : x ≤ 202/100) :
    |gcR x| ≤ 1/1000 ∧ x ^ 2 + pR x ≤ 0 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 185/100 + w := ⟨x - 185/100, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have h1 : w ≤ 17/100 := by linarith
  have q2 := pow_le_pow_left₀ h0 h1 2; have q3 := pow_le_pow_left₀ h0 h1 3
  have q4 := pow_le_pow_left₀ h0 h1 4; have q5 := pow_le_pow_left₀ h0 h1 5
  have q6 := pow_le_pow_left₀ h0 h1 6; have q7 := pow_le_pow_left₀ h0 h1 7
  have q8 := pow_le_pow_left₀ h0 h1 8; have q9 := pow_le_pow_left₀ h0 h1 9
  have q10 := pow_le_pow_left₀ h0 h1 10; have q11 := pow_le_pow_left₀ h0 h1 11
  have q12 := pow_le_pow_left₀ h0 h1 12
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  have n8 := pow_nonneg h0 8; have n9 := pow_nonneg h0 9; have n10 := pow_nonneg h0 10
  have n11 := pow_nonneg h0 11; have n12 := pow_nonneg h0 12
  simp only [gcR, ddpR, dpR, pR]
  refine ⟨abs_le.mpr ⟨by linarith, by linarith⟩, by linarith⟩

lemma mp6 (x : ℝ) (hx1 : 202/100 ≤ x) (hx2 : x ≤ 219/100) :
    |gcR x| ≤ 1/1000 ∧ x ^ 2 + pR x ≤ 0 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 202/100 + w := ⟨x - 202/100, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have h1 : w ≤ 17/100 := by linarith
  have q2 := pow_le_pow_left₀ h0 h1 2; have q3 := pow_le_pow_left₀ h0 h1 3
  have q4 := pow_le_pow_left₀ h0 h1 4; have q5 := pow_le_pow_left₀ h0 h1 5
  have q6 := pow_le_pow_left₀ h0 h1 6; have q7 := pow_le_pow_left₀ h0 h1 7
  have q8 := pow_le_pow_left₀ h0 h1 8; have q9 := pow_le_pow_left₀ h0 h1 9
  have q10 := pow_le_pow_left₀ h0 h1 10; have q11 := pow_le_pow_left₀ h0 h1 11
  have q12 := pow_le_pow_left₀ h0 h1 12
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  have n8 := pow_nonneg h0 8; have n9 := pow_nonneg h0 9; have n10 := pow_nonneg h0 10
  have n11 := pow_nonneg h0 11; have n12 := pow_nonneg h0 12
  simp only [gcR, ddpR, dpR, pR]
  refine ⟨abs_le.mpr ⟨by linarith, by linarith⟩, by linarith⟩

lemma mp7 (x : ℝ) (hx1 : 219/100 ≤ x) (hx2 : x ≤ 236/100) :
    |gcR x| ≤ 1/1000 ∧ x ^ 2 + pR x ≤ 0 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 219/100 + w := ⟨x - 219/100, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have h1 : w ≤ 17/100 := by linarith
  have q2 := pow_le_pow_left₀ h0 h1 2; have q3 := pow_le_pow_left₀ h0 h1 3
  have q4 := pow_le_pow_left₀ h0 h1 4; have q5 := pow_le_pow_left₀ h0 h1 5
  have q6 := pow_le_pow_left₀ h0 h1 6; have q7 := pow_le_pow_left₀ h0 h1 7
  have q8 := pow_le_pow_left₀ h0 h1 8; have q9 := pow_le_pow_left₀ h0 h1 9
  have q10 := pow_le_pow_left₀ h0 h1 10; have q11 := pow_le_pow_left₀ h0 h1 11
  have q12 := pow_le_pow_left₀ h0 h1 12
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  have n8 := pow_nonneg h0 8; have n9 := pow_nonneg h0 9; have n10 := pow_nonneg h0 10
  have n11 := pow_nonneg h0 11; have n12 := pow_nonneg h0 12
  simp only [gcR, ddpR, dpR, pR]
  refine ⟨abs_le.mpr ⟨by linarith, by linarith⟩, by linarith⟩

lemma mp8 (x : ℝ) (hx1 : 236/100 ≤ x) (hx2 : x ≤ 253/100) :
    |gcR x| ≤ 1/1000 ∧ x ^ 2 + pR x ≤ 0 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 236/100 + w := ⟨x - 236/100, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have h1 : w ≤ 17/100 := by linarith
  have q2 := pow_le_pow_left₀ h0 h1 2; have q3 := pow_le_pow_left₀ h0 h1 3
  have q4 := pow_le_pow_left₀ h0 h1 4; have q5 := pow_le_pow_left₀ h0 h1 5
  have q6 := pow_le_pow_left₀ h0 h1 6; have q7 := pow_le_pow_left₀ h0 h1 7
  have q8 := pow_le_pow_left₀ h0 h1 8; have q9 := pow_le_pow_left₀ h0 h1 9
  have q10 := pow_le_pow_left₀ h0 h1 10; have q11 := pow_le_pow_left₀ h0 h1 11
  have q12 := pow_le_pow_left₀ h0 h1 12
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  have n8 := pow_nonneg h0 8; have n9 := pow_nonneg h0 9; have n10 := pow_nonneg h0 10
  have n11 := pow_nonneg h0 11; have n12 := pow_nonneg h0 12
  simp only [gcR, ddpR, dpR, pR]
  refine ⟨abs_le.mpr ⟨by linarith, by linarith⟩, by linarith⟩

lemma mp9 (x : ℝ) (hx1 : 253/100 ≤ x) (hx2 : x ≤ 27/10) :
    |gcR x| ≤ 1/1000 ∧ x ^ 2 + pR x ≤ 0 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 253/100 + w := ⟨x - 253/100, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have h1 : w ≤ 17/100 := by linarith
  have q2 := pow_le_pow_left₀ h0 h1 2; have q3 := pow_le_pow_left₀ h0 h1 3
  have q4 := pow_le_pow_left₀ h0 h1 4; have q5 := pow_le_pow_left₀ h0 h1 5
  have q6 := pow_le_pow_left₀ h0 h1 6; have q7 := pow_le_pow_left₀ h0 h1 7
  have q8 := pow_le_pow_left₀ h0 h1 8; have q9 := pow_le_pow_left₀ h0 h1 9
  have q10 := pow_le_pow_left₀ h0 h1 10; have q11 := pow_le_pow_left₀ h0 h1 11
  have q12 := pow_le_pow_left₀ h0 h1 12
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  have n8 := pow_nonneg h0 8; have n9 := pow_nonneg h0 9; have n10 := pow_nonneg h0 10
  have n11 := pow_nonneg h0 11; have n12 := pow_nonneg h0 12
  simp only [gcR, ddpR, dpR, pR]
  refine ⟨abs_le.mpr ⟨by linarith, by linarith⟩, by linarith⟩

lemma mid_all (y : ℝ) (h1 : 1 ≤ y) (h2 : y ≤ 27/10) :
    |gcR y| ≤ 1/1000 ∧ y ^ 2 + pR y ≤ 0 := by
  rcases le_total y (117/100) with h | h
  · exact mp0 y h1 h
  rcases le_total y (134/100) with h' | h'
  · exact mp1 y h h'
  rcases le_total y (151/100) with h | h
  · exact mp2 y h' h
  rcases le_total y (168/100) with h' | h'
  · exact mp3 y h h'
  rcases le_total y (185/100) with h | h
  · exact mp4 y h' h
  rcases le_total y (202/100) with h' | h'
  · exact mp5 y h h'
  rcases le_total y (219/100) with h | h
  · exact mp6 y h' h
  rcases le_total y (236/100) with h' | h'
  · exact mp7 y h h'
  rcases le_total y (253/100) with h | h
  · exact mp8 y h' h
  · exact mp9 y h h2

lemma pR_lower (x : ℝ) (hx1 : 1 ≤ x) (hx2 : x ≤ 27/10) : -87 ≤ pR x := by
  have h0 : 0 ≤ x := by linarith
  have q2 := pow_le_pow_left₀ h0 hx2 2; have q3 := pow_le_pow_left₀ h0 hx2 3
  have q4 := pow_le_pow_left₀ h0 hx2 4; have q5 := pow_le_pow_left₀ h0 hx2 5
  have q6 := pow_le_pow_left₀ h0 hx2 6; have q7 := pow_le_pow_left₀ h0 hx2 7
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  simp only [pR]
  linarith

/-! ## tail polynomial -/

lemma tq0 (x : ℝ) (hx1 : 27/10 ≤ x) (hx2 : x ≤ 3) : pR x + x - 1 ≤ -7 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 27/10 + w := ⟨x - 27/10, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have h1 : w ≤ 3/10 := by linarith
  have q2 := pow_le_pow_left₀ h0 h1 2; have q3 := pow_le_pow_left₀ h0 h1 3
  have q4 := pow_le_pow_left₀ h0 h1 4; have q5 := pow_le_pow_left₀ h0 h1 5
  have q6 := pow_le_pow_left₀ h0 h1 6; have q7 := pow_le_pow_left₀ h0 h1 7
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  simp only [pR]
  linarith

lemma tq1 (x : ℝ) (hx1 : 3 ≤ x) (hx2 : x ≤ 7/2) : pR x + x - 1 ≤ -7 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 3 + w := ⟨x - 3, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have h1 : w ≤ 1/2 := by linarith
  have q2 := pow_le_pow_left₀ h0 h1 2; have q3 := pow_le_pow_left₀ h0 h1 3
  have q4 := pow_le_pow_left₀ h0 h1 4; have q5 := pow_le_pow_left₀ h0 h1 5
  have q6 := pow_le_pow_left₀ h0 h1 6; have q7 := pow_le_pow_left₀ h0 h1 7
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  simp only [pR]
  linarith

lemma tq2 (x : ℝ) (hx1 : 7/2 ≤ x) (hx2 : x ≤ 4) : pR x + x - 1 ≤ -7 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 7/2 + w := ⟨x - 7/2, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have h1 : w ≤ 1/2 := by linarith
  have q2 := pow_le_pow_left₀ h0 h1 2; have q3 := pow_le_pow_left₀ h0 h1 3
  have q4 := pow_le_pow_left₀ h0 h1 4; have q5 := pow_le_pow_left₀ h0 h1 5
  have q6 := pow_le_pow_left₀ h0 h1 6; have q7 := pow_le_pow_left₀ h0 h1 7
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  simp only [pR]
  linarith

lemma tq3 (x : ℝ) (hx1 : 4 ≤ x) (hx2 : x ≤ 5) : pR x + x - 1 ≤ -7 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 4 + w := ⟨x - 4, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have h1 : w ≤ 1 := by linarith
  have q2 := pow_le_pow_left₀ h0 h1 2; have q3 := pow_le_pow_left₀ h0 h1 3
  have q4 := pow_le_pow_left₀ h0 h1 4; have q5 := pow_le_pow_left₀ h0 h1 5
  have q6 := pow_le_pow_left₀ h0 h1 6; have q7 := pow_le_pow_left₀ h0 h1 7
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  simp only [pR]
  linarith

lemma tq4 (x : ℝ) (hx1 : 5 ≤ x) (hx2 : x ≤ 6) : pR x + x - 1 ≤ -7 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 5 + w := ⟨x - 5, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have h1 : w ≤ 1 := by linarith
  have q2 := pow_le_pow_left₀ h0 h1 2; have q3 := pow_le_pow_left₀ h0 h1 3
  have q4 := pow_le_pow_left₀ h0 h1 4; have q5 := pow_le_pow_left₀ h0 h1 5
  have q6 := pow_le_pow_left₀ h0 h1 6; have q7 := pow_le_pow_left₀ h0 h1 7
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  simp only [pR]
  linarith

lemma tq5 (x : ℝ) (hx1 : 6 ≤ x) : pR x + x - 1 ≤ -7 := by
  obtain ⟨w, rfl⟩ : ∃ w, x = 6 + w := ⟨x - 6, by ring⟩
  have h0 : 0 ≤ w := by linarith
  have n2 := pow_nonneg h0 2; have n3 := pow_nonneg h0 3; have n4 := pow_nonneg h0 4
  have n5 := pow_nonneg h0 5; have n6 := pow_nonneg h0 6; have n7 := pow_nonneg h0 7
  simp only [pR]
  linarith

lemma tail_q (x : ℝ) (hx : 27/10 ≤ x) : pR x + x - 1 ≤ -7 := by
  rcases le_total x 3 with h | h
  · exact tq0 x hx h
  rcases le_total x (7/2) with h' | h'
  · exact tq1 x h h'
  rcases le_total x 4 with h | h
  · exact tq2 x h' h
  rcases le_total x 5 with h' | h'
  · exact tq3 x h h'
  rcases le_total x 6 with h | h
  · exact tq4 x h' h
  · exact tq5 x h

/-! ## [0,1] polynomial comparison -/

lemma P_close (t c : ℝ) (h0 : 0 ≤ t) (h1 : t ≤ 1) (hc1 : (20000000/17724541 : ℝ) ≤ c)
    (hc2 : c ≤ 20000000/17724536) : |Pb t (t * t) - c * Ifn t| ≤ 1/1000 := by
  obtain ⟨hl, hu⟩ := Ifn_bounds t h0 h1
  have hI := Ifn_nonneg t h0
  have m1 : (20000000/17724541 : ℝ) * (Ap t - t ^ 17 / 609280) ≤ c * Ifn t :=
    le_trans (mul_le_mul_of_nonneg_left hl (by norm_num)) (mul_le_mul_of_nonneg_right hc1 hI)
  have m2 : c * Ifn t ≤ (20000000/17724536 : ℝ) * (Ap t + t ^ 17 / 609280) :=
    le_trans (mul_le_mul_of_nonneg_right hc2 hI) (mul_le_mul_of_nonneg_left hu (by norm_num))
  simp only [Ap] at m1 m2
  have e1 : t ^ 1 ≤ 1 := pow_le_one₀ h0 h1
  have e3 : t ^ 3 ≤ 1 := pow_le_one₀ h0 h1
  have e5 : t ^ 5 ≤ 1 := pow_le_one₀ h0 h1
  have e7 : t ^ 7 ≤ 1 := pow_le_one₀ h0 h1
  have e9 : t ^ 9 ≤ 1 := pow_le_one₀ h0 h1
  have e11 : t ^ 11 ≤ 1 := pow_le_one₀ h0 h1
  have e13 : t ^ 13 ≤ 1 := pow_le_one₀ h0 h1
  have e15 : t ^ 15 ≤ 1 := pow_le_one₀ h0 h1
  have e17 : t ^ 17 ≤ 1 := pow_le_one₀ h0 h1
  have f3 := pow_nonneg h0 3; have f5 := pow_nonneg h0 5; have f7 := pow_nonneg h0 7
  have f9 := pow_nonneg h0 9; have f11 := pow_nonneg h0 11; have f13 := pow_nonneg h0 13
  have f15 := pow_nonneg h0 15; have f17 := pow_nonneg h0 17
  simp only [Pb]
  rw [abs_le]
  constructor <;> linarith

/-! ## the middle range -/

lemma Psi_close (x : ℝ) (hx1 : 1 ≤ x) (hx2 : x ≤ 27/10) : |Psi x - Psi 1| ≤ 17/10000 := by
  have hb : ∀ y ∈ Icc 1 x, |gcR y * Real.exp (y ^ 2 + pR y)| ≤ 1/1000 := by
    intro y hy
    obtain ⟨hg, hr⟩ := mid_all y hy.1 (le_trans hy.2 hx2)
    rw [abs_mul, abs_of_pos (Real.exp_pos _)]
    have : Real.exp (y ^ 2 + pR y) ≤ 1 := Real.exp_le_one_iff.mpr hr
    calc |gcR y| * Real.exp (y ^ 2 + pR y) ≤ 1/1000 * 1 :=
          mul_le_mul hg this (Real.exp_pos _).le (by norm_num)
      _ = 1/1000 := by norm_num
  have l1 := mono_helper (f := fun y => Psi y + y / 1000)
    (f' := fun y => gcR y * Real.exp (y ^ 2 + pR y) + 1 / 1000) hx1
    (fun y => (Psi_deriv y).add ((hasDerivAt_id' y).div_const 1000))
    (fun y hy => by have := abs_le.mp (hb y hy); linarith [this.1])
  have l2 := mono_helper (f := fun y => y / 1000 - Psi y)
    (f' := fun y => 1 / 1000 - gcR y * Real.exp (y ^ 2 + pR y)) hx1
    (fun y => ((hasDerivAt_id' y).div_const 1000).sub (Psi_deriv y))
    (fun y hy => by have := abs_le.mp (hb y hy); linarith [this.2])
  rw [abs_le]; constructor <;> linarith

lemma Dm_close (x : ℝ) (hx1 : 1 ≤ x) (M : ℝ) (hM : ∀ y ∈ Icc 1 x, |Psi y| ≤ M) :
    |Dm x - Dm 1| ≤ M * (Ifn x - Ifn 1) := by
  have l1 := mono_helper (f := fun y => Dm y + M * Ifn y)
    (f' := fun y => -(Real.exp (-y ^ 2) * Psi y) + M * Real.exp (-y ^ 2)) hx1
    (fun y => (Dm_deriv y).add ((Ifn_hasDerivAt y).const_mul M))
    (fun y hy => by
      have h := mul_nonneg (Real.exp_pos (-y ^ 2)).le
        (show 0 ≤ M - Psi y by linarith [(abs_le.mp (hM y hy)).2])
      linarith)
  have l2 := mono_helper (f := fun y => M * Ifn y - Dm y)
    (f' := fun y => M * Real.exp (-y ^ 2) - -(Real.exp (-y ^ 2) * Psi y)) hx1
    (fun y => ((Ifn_hasDerivAt y).const_mul M).sub (Dm_deriv y))
    (fun y hy => by
      have h := mul_nonneg (Real.exp_pos (-y ^ 2)).le
        (show 0 ≤ M + Psi y by linarith [(abs_le.mp (hM y hy)).1])
      linarith)
  rw [abs_le]; constructor <;> linarith

lemma point_vals : |Dm 1| ≤ 1/10000 ∧ |Psi 1| ≤ 1/10000 ∧
    Real.sqrt Real.pi / 2 - Ifn 1 ≤ 1395/10000 := by
  have hp1 : pR 1 = -1016831324331/549755813888 := by norm_num [pR]
  have hdp1 : dpR 1 = -1450789099565/549755813888 := by norm_num [dpR]
  obtain ⟨hS1, hS2⟩ := sqrt_pi_bounds
  obtain ⟨hc1, hc2⟩ := c_bounds
  obtain ⟨hIl, hIu⟩ := Ifn_bounds 1 (by norm_num) le_rfl
  have hA1 : Ap 1 = 1 - 1/3 + 1/10 - 1/42 + 1/216 - 1/1320 + 1/9360 - 1/75600 := by
    norm_num [Ap]
  have hE1 := Real.exp_one_gt_d9
  have hE2 := Real.exp_one_lt_d9
  have hE1' := hE1.le
  have hE2' := hE2.le
  have hXb := Real.exp_bound (x := (82680303445/549755813888 : ℝ))
    (by rw [abs_le]; constructor <;> norm_num) (n := 6) (by norm_num)
  have hV : Real.exp (pR 1) * Real.exp 1 ^ 2 = Real.exp (82680303445/549755813888 : ℝ) := by
    rw [hp1, sq, ← Real.exp_add, ← Real.exp_add]; norm_num
  have hW : Real.exp (1 ^ 2 + pR 1) * Real.exp 1 = Real.exp (82680303445/549755813888 : ℝ) := by
    rw [hp1, ← Real.exp_add]; norm_num
  set X := Real.exp (82680303445/549755813888 : ℝ) with hXdef
  simp only [Finset.sum_range_succ, Finset.sum_range_zero, Nat.factorial,
    Nat.succ_eq_add_one] at hXb
  rw [abs_le] at hXb
  norm_num at hXb
  have hX1 : (1.1622927 : ℝ) ≤ X := by linarith [hXb.1]
  have hX2 : X ≤ (1.1622929 : ℝ) := by linarith [hXb.2]
  have hV1 : Real.exp (pR 1) ≤ 1.1622929 / 2.7182818283 ^ 2 := by
    rw [le_div_iff₀ (by norm_num)]
    calc Real.exp (pR 1) * 2.7182818283 ^ 2 ≤ Real.exp (pR 1) * Real.exp 1 ^ 2 := by gcongr
      _ = X := hV
      _ ≤ 1.1622929 := hX2
  have hV2 : 1.1622927 / 2.7182818286 ^ 2 ≤ Real.exp (pR 1) := by
    rw [div_le_iff₀ (by norm_num)]
    calc (1.1622927 : ℝ) ≤ X := hX1
      _ = Real.exp (pR 1) * Real.exp 1 ^ 2 := hV.symm
      _ ≤ Real.exp (pR 1) * 2.7182818286 ^ 2 := by gcongr
  have hW1 : Real.exp (1 ^ 2 + pR 1) ≤ 1.1622929 / 2.7182818283 := by
    rw [le_div_iff₀ (by norm_num)]
    calc Real.exp (1 ^ 2 + pR 1) * 2.7182818283 ≤ Real.exp (1 ^ 2 + pR 1) * Real.exp 1 := by
          gcongr
      _ = X := hW
      _ ≤ 1.1622929 := hX2
  have hW2 : 1.1622927 / 2.7182818286 ≤ Real.exp (1 ^ 2 + pR 1) := by
    rw [div_le_iff₀ (by norm_num)]
    calc (1.1622927 : ℝ) ≤ X := hX1
      _ = Real.exp (1 ^ 2 + pR 1) * Real.exp 1 := hW.symm
      _ ≤ Real.exp (1 ^ 2 + pR 1) * 2.7182818286 := by gcongr
  have hI0 := Ifn_nonneg 1 zero_le_one
  have m1 : (20000000/17724541 : ℝ) * (Ap 1 - 1 ^ 17 / 609280) ≤ 2 / Real.sqrt Real.pi * Ifn 1 :=
    le_trans (mul_le_mul_of_nonneg_left hIl (by norm_num)) (mul_le_mul_of_nonneg_right hc1 hI0)
  have m2 : 2 / Real.sqrt Real.pi * Ifn 1 ≤ (20000000/17724536 : ℝ) * (Ap 1 + 1 ^ 17 / 609280) :=
    le_trans (mul_le_mul_of_nonneg_right hc2 hI0) (mul_le_mul_of_nonneg_left hIu (by norm_num))
  rw [hA1] at m1 m2 hIl
  refine ⟨?_, ?_, ?_⟩
  · unfold Dm; rw [abs_le]; constructor <;> linarith
  · unfold Psi; rw [hdp1, abs_le]; constructor <;> linarith
  · linarith

/-! ## assembling -/

lemma abs_step (A B : ℝ) (hB : 0 ≤ B) : |(|A|) - B| ≤ |A - B| := by
  have := abs_abs_sub_abs_le_abs_sub A B
  rwa [abs_of_nonneg hB] at this

lemma abs_step2 (A c It IY : ℝ) (hc : 0 ≤ c) (h : 0 ≤ IY - It) :
    |A - c * IY| ≤ |A - c * It| + c * (IY - It) := by
  calc |A - c * IY| = |(A - c * It) - c * (IY - It)| := by congr 1; ring
    _ ≤ |A - c * It| + |c * (IY - It)| := abs_sub _ _
    _ = |A - c * It| + c * (IY - It) := by rw [abs_of_nonneg (mul_nonneg hc h)]

theorem core (u : ℝ) (hu : 0 ≤ u) :
    (0.5:ℝ) * u * |F5 ((11863283 / 2 ^ 24 : ℝ) * u)
      (((11863283 / 2 ^ 24 : ℝ) * u) * ((11863283 / 2 ^ 24 : ℝ) * u)) -
      VoltaChallenge.erf (u * (6369051672525773 / 2 ^ 53 : ℝ))| ≤ 0.001 := by
  obtain ⟨hc1, hc2⟩ := c_bounds
  obtain ⟨hS1, hS2⟩ := sqrt_pi_bounds
  have hSpos : 0 < Real.sqrt Real.pi := by linarith
  rw [erf_eq]
  have hcS : 2 / Real.sqrt Real.pi * (Real.sqrt Real.pi / 2) = 1 := by field_simp
  set c := 2 / Real.sqrt Real.pi with hc
  have hc0 : 0 ≤ c := by linarith
  set t := (11863283 / 2 ^ 24 : ℝ) * u with ht
  set Y := u * (6369051672525773 / 2 ^ 53 : ℝ) with hY
  have ht0 : 0 ≤ t := by rw [ht]; positivity
  have hYt : t ≤ Y := by rw [ht, hY]; nlinarith
  have hYt' : Y - t = (6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24 : ℝ) * u := by
    rw [ht, hY]; ring
  have hlip := Ifn_lip t Y hYt
  have hIY0 : 0 ≤ Ifn Y := Ifn_nonneg Y (by linarith)
  have hIY1 : Ifn Y ≤ Real.sqrt Real.pi / 2 := Ifn_le Y (by linarith)
  rcases lt_or_ge t 1 with h1 | h1
  · -- small arguments
    have hn : ¬ (t ≥ 1) := not_le.mpr h1
    rw [F5, if_neg hn]
    have hP := P_close t c ht0 h1.le hc1 hc2
    have hu1 : u ≤ 1.4143 := by linarith
    have hA := abs_step (Pb t (t * t)) (c * Ifn Y) (mul_nonneg hc0 hIY0)
    have hB := abs_step2 (Pb t (t * t)) c (Ifn t) (Ifn Y) hc0 hlip.1
    have hC : c * (Ifn Y - Ifn t) ≤ 20000000/17724536 *
        ((6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24) * 1.4143) := by
      calc c * (Ifn Y - Ifn t) ≤ c * (Y - t) := mul_le_mul_of_nonneg_left hlip.2 hc0
        _ ≤ 20000000/17724536 * ((6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24) * 1.4143) := by
          rw [hYt']
          apply mul_le_mul hc2 _ (by nlinarith) (by norm_num)
          apply mul_le_mul_of_nonneg_left hu1 (by norm_num)
    have hD : |(|Pb t (t * t)|) - c * Ifn Y| ≤ 1/1000 + 20000000/17724536 *
        ((6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24) * 1.4143) := by linarith
    calc (0.5:ℝ) * u * |(|Pb t (t * t)|) - c * Ifn Y|
        ≤ 0.5 * 1.4143 * (1/1000 + 20000000/17724536 *
          ((6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24) * 1.4143)) := by gcongr
      _ ≤ 0.001 := by norm_num
  rcases le_or_gt t (27/10) with h2 | h2
  · -- middle range
    have h1' : t ≥ 1 := h1
    have hpl := pR_lower t h1 h2
    have hcond : ¬ (t ≥ 1 ∧ (-87.3365478515625 : ℝ) > F2 t) := by
      rintro ⟨_, h⟩; rw [F2_eq] at h; linarith
    rw [F5, if_pos h1']
    simp only [Wf, if_neg hcond]
    rw [F2_eq]
    obtain ⟨hD1, hPsi1, hI1⟩ := point_vals
    have hM : ∀ y ∈ Icc 1 t, |Psi y| ≤ 18/10000 := fun y hy => by
      have h := Psi_close y hy.1 (le_trans hy.2 h2)
      rw [abs_le] at h hPsi1 ⊢
      constructor <;> linarith [h.1, h.2, hPsi1.1, hPsi1.2]
    have hDc := Dm_close t h1 (18/10000) hM
    have hI1t := Ifn_lip 1 t h1
    have hIt : Ifn t ≤ Real.sqrt Real.pi / 2 := Ifn_le t (by linarith)
    have hDt : |Dm t| ≤ 1/10000 + 18/10000 * (1395/10000) := by
      have : 18/10000 * (Ifn t - Ifn 1) ≤ 18/10000 * (1395/10000 : ℝ) := by
        apply mul_le_mul_of_nonneg_left _ (by norm_num); linarith
      rw [abs_le] at hDc hD1 ⊢; constructor <;> linarith
    have hDm_eq : Dm t = 1 - Real.exp (pR t) - c * Ifn t := rfl
    have hu1 : u ≤ 3.8184 := by linarith
    have hA := abs_step (1 - Real.exp (pR t)) (c * Ifn Y) (mul_nonneg hc0 hIY0)
    have hB := abs_step2 (1 - Real.exp (pR t)) c (Ifn t) (Ifn Y) hc0 hlip.1
    rw [← hDm_eq] at hB
    have hC : c * (Ifn Y - Ifn t) ≤ 20000000/17724536 *
        ((6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24) * 3.8184) := by
      calc c * (Ifn Y - Ifn t) ≤ c * (Y - t) := mul_le_mul_of_nonneg_left hlip.2 hc0
        _ ≤ 20000000/17724536 * ((6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24) * 3.8184) := by
          rw [hYt']
          apply mul_le_mul hc2 _ (by nlinarith) (by norm_num)
          apply mul_le_mul_of_nonneg_left hu1 (by norm_num)
    have hD : |(|1 - Real.exp (pR t)|) - c * Ifn Y| ≤ (1/10000 + 18/10000 * (1395/10000)) +
        20000000/17724536 * ((6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24) * 3.8184) := by
      linarith
    calc (0.5:ℝ) * u * |(|1 - Real.exp (pR t)|) - c * Ifn Y|
        ≤ 0.5 * 3.8184 * ((1/10000 + 18/10000 * (1395/10000)) +
          20000000/17724536 * ((6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24) * 3.8184)) := by
          gcongr
      _ ≤ 0.001 := by norm_num
  · -- tail
    have h1' : t ≥ 1 := h1
    rw [F5, if_pos h1']
    have hw : 0 ≤ Wf t ∧ Wf t ≤ 1.01 * Real.exp (pR t) := by
      unfold Wf
      rw [F2_eq]
      split_ifs with hcd
      · refine ⟨by positivity, ?_⟩
        rw [Real.exp_add, ← mul_assoc]
        exact mul_le_mul_of_nonneg_right K64 (Real.exp_pos _).le
      · refine ⟨by positivity, ?_⟩
        have := Real.exp_pos (pR t); linarith
    obtain ⟨hw0, hw1⟩ := hw
    have hT1 := tail_q t h2.le
    have hte : t * Real.exp (pR t) ≤ Real.exp (-7) := by
      have h := Real.add_one_le_exp (t - 1)
      calc t * Real.exp (pR t) ≤ Real.exp (t - 1) * Real.exp (pR t) := by
            gcongr; linarith
        _ = Real.exp (pR t + t - 1) := by rw [← Real.exp_add]; ring_nf
        _ ≤ Real.exp (-7) := Real.exp_le_exp.mpr hT1
    obtain ⟨he7, he729⟩ := exp7
    have hYpos : 0 < Y := by linarith
    have hY2 : 729/100 ≤ Y ^ 2 := by nlinarith
    have hey : Real.exp (-Y ^ 2) ≤ 1/1413 :=
      le_trans (Real.exp_le_exp.mpr (by linarith)) he729
    have htail : 1 - c * Ifn Y ≤ c * (Real.exp (-Y ^ 2) / (2 * Y)) := by
      have h := tail_eq Y hYpos.le
      have h' := tail_le Y hYpos
      have : 1 - c * Ifn Y = c * (Real.sqrt Real.pi / 2 - Ifn Y) := by rw [mul_sub, hcS]
      rw [this]
      apply mul_le_mul_of_nonneg_left _ hc0
      linarith
    have h1c : 0 ≤ 1 - c * Ifn Y := by
      have := mul_le_mul_of_nonneg_left hIY1 hc0; linarith
    have hA := abs_step (1 - Wf t) (c * Ifn Y) (mul_nonneg hc0 hIY0)
    have hB : |1 - Wf t - c * Ifn Y| ≤ Wf t + (1 - c * Ifn Y) := by
      rw [abs_le]; constructor <;> linarith
    have hupos : 0 < u := by linarith
    have hu0 : u ≠ 0 := hupos.ne'
    have hX1 : u * Real.exp (pR t) ≤ 1 / (1096 * (11863283 / 2 ^ 24)) := by
      rw [le_div_iff₀ (by norm_num)]
      have : u * Real.exp (pR t) * (1096 * (11863283 / 2 ^ 24)) =
          1096 * (t * Real.exp (pR t)) := by rw [ht]; ring
      rw [this]; linarith [he7]
    have hX2 : u * (c * (Real.exp (-Y ^ 2) / (2 * Y))) ≤
        20000000/17724536 * (1/1413) / (2 * (6369051672525773 / 2 ^ 53)) := by
      have : u * (c * (Real.exp (-Y ^ 2) / (2 * Y))) =
          c * Real.exp (-Y ^ 2) / (2 * (6369051672525773 / 2 ^ 53)) := by
        rw [hY]; field_simp
      rw [this]
      gcongr
    calc (0.5:ℝ) * u * |(|1 - Wf t|) - c * Ifn Y|
        ≤ 0.5 * u * (Wf t + (1 - c * Ifn Y)) := by gcongr; linarith
      _ ≤ 0.5 * u * (1.01 * Real.exp (pR t) + c * (Real.exp (-Y ^ 2) / (2 * Y))) := by
          gcongr
      _ = 0.5 * 1.01 * (u * Real.exp (pR t)) + 0.5 * (u * (c * (Real.exp (-Y ^ 2) / (2 * Y)))) := by
          ring
      _ ≤ 0.5 * 1.01 * (1 / (1096 * (11863283 / 2 ^ 24))) +
          0.5 * (20000000/17724536 * (1/1413) / (2 * (6369051672525773 / 2 ^ 53))) := by
          gcongr
      _ ≤ 0.001 := by norm_num

theorem key (X : ℝ) : |(((0.5 : ℝ) * X) * ((1 : ℝ) + (if (11863283 / 2 ^ 24 : ℝ) * X < (0 : ℝ) then -F5 (|(11863283 / 2 ^ 24 : ℝ) * X|) (((11863283 / 2 ^ 24 : ℝ) * X) * ((11863283 / 2 ^ 24 : ℝ) * X)) else F5 (|(11863283 / 2 ^ 24 : ℝ) * X|) (((11863283 / 2 ^ 24 : ℝ) * X) * ((11863283 / 2 ^ 24 : ℝ) * X))))) - (((0.5 : ℝ) * X) * ((1 : ℝ) + VoltaChallenge.erf (X * (6369051672525773 / 2 ^ 53 : ℝ))))| ≤ (0.001 : ℝ) := by
  rcases le_or_gt 0 X with hX | hX
  · have hk : 0 ≤ (11863283 / 2 ^ 24 : ℝ) * X := by positivity
    rw [if_neg (not_lt.mpr hk), abs_of_nonneg hk]
    have hc := core X hX
    set A := F5 ((11863283 / 2 ^ 24 : ℝ) * X)
      ((11863283 / 2 ^ 24 : ℝ) * X * ((11863283 / 2 ^ 24 : ℝ) * X))
    set B := VoltaChallenge.erf (X * (6369051672525773 / 2 ^ 53 : ℝ))
    calc _ = |0.5 * X * (A - B)| := by congr 1; ring
      _ = 0.5 * X * |A - B| := by rw [abs_mul, abs_of_nonneg (by positivity)]
      _ ≤ 0.001 := hc
  · have hk : (11863283 / 2 ^ 24 : ℝ) * X < 0 := by nlinarith
    rw [if_pos hk, abs_of_neg hk]
    have h1 : -((11863283 / 2 ^ 24 : ℝ) * X) = (11863283 / 2 ^ 24 : ℝ) * (-X) := by ring
    have h2 : (11863283 / 2 ^ 24 : ℝ) * X * ((11863283 / 2 ^ 24 : ℝ) * X) =
        (11863283 / 2 ^ 24 : ℝ) * (-X) * ((11863283 / 2 ^ 24 : ℝ) * (-X)) := by ring
    have h3 : VoltaChallenge.erf (X * (6369051672525773 / 2 ^ 53 : ℝ)) =
        -VoltaChallenge.erf (-X * (6369051672525773 / 2 ^ 53 : ℝ)) := by
      rw [erf_eq, erf_eq, show X * (6369051672525773 / 2 ^ 53 : ℝ) =
        -(-X * (6369051672525773 / 2 ^ 53 : ℝ)) by ring, Ifn_neg]
      ring
    rw [h1, h2, h3]
    have hc := core (-X) (by linarith)
    set A := F5 ((11863283 / 2 ^ 24 : ℝ) * (-X))
      ((11863283 / 2 ^ 24 : ℝ) * (-X) * ((11863283 / 2 ^ 24 : ℝ) * (-X)))
    set B := VoltaChallenge.erf (-X * (6369051672525773 / 2 ^ 53 : ℝ))
    calc _ = |0.5 * (-X) * (A - B)| := by congr 1; ring
      _ = 0.5 * (-X) * |A - B| := by rw [abs_mul, abs_of_nonneg (by linarith)]
      _ ≤ 0.001 := hc

theorem c_0 : VoltaChallenge.c_0 := fun v0 v1 => key (v1 * v0)

end

end VoltaProofs
