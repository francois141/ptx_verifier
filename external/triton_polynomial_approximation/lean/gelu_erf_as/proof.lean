import challenge

namespace VoltaProofs

open Real MeasureTheory intervalIntegral Set Filter

noncomputable def kk : ℝ := 2 / Real.sqrt Real.pi

lemma erf_eq (x : ℝ) : VoltaChallenge.erf x = kk * ∫ t in (0:ℝ)..x, Real.exp (-t ^ 2) := rfl

lemma gauss_cont : Continuous (fun t : ℝ => Real.exp (-t ^ 2)) := by fun_prop

lemma kk_pos : 0 < kk := div_pos two_pos (Real.sqrt_pos.2 Real.pi_pos)

lemma kk_lo : (1.128378 : ℝ) ≤ kk := by
  have h1 : Real.sqrt Real.pi ≤ Real.sqrt (1.7724545 ^ 2) :=
    Real.sqrt_le_sqrt (by nlinarith [Real.pi_lt_d6])
  rw [Real.sqrt_sq (by norm_num)] at h1
  have h2 := Real.sqrt_pos.2 Real.pi_pos
  unfold kk
  rw [le_div_iff₀ h2]
  nlinarith

lemma kk_hi : kk ≤ (1.12838 : ℝ) := by
  have h1 : Real.sqrt (1.7724535 ^ 2) ≤ Real.sqrt Real.pi :=
    Real.sqrt_le_sqrt (by nlinarith [Real.pi_gt_d6])
  rw [Real.sqrt_sq (by norm_num)] at h1
  have h2 := Real.sqrt_pos.2 Real.pi_pos
  unfold kk
  rw [div_le_iff₀ h2]
  nlinarith

lemma erf_hasDerivAt (x : ℝ) : HasDerivAt VoltaChallenge.erf (kk * Real.exp (-x ^ 2)) x := by
  have h := (gauss_cont.integral_hasStrictDerivAt 0 x).hasDerivAt
  exact h.const_mul kk

lemma erf_zero : VoltaChallenge.erf 0 = 0 := by
  rw [erf_eq, intervalIntegral.integral_same, mul_zero]

lemma erf_neg (x : ℝ) : VoltaChallenge.erf (-x) = - VoltaChallenge.erf x := by
  rw [erf_eq, erf_eq]
  have : ∫ t in (0:ℝ)..(-x), Real.exp (-t ^ 2) = - ∫ t in (0:ℝ)..x, Real.exp (-t ^ 2) := by
    have h := intervalIntegral.integral_comp_neg (a := 0) (b := x) (fun t => Real.exp (-t ^ 2))
    simp only [neg_sq, neg_zero] at h
    rw [intervalIntegral.integral_symm, ← h]
  rw [this]; ring

lemma erf_lip (a b : ℝ) : |VoltaChallenge.erf a - VoltaChallenge.erf b| ≤ kk * |a - b| := by
  rw [erf_eq, erf_eq, ← mul_sub, intervalIntegral.integral_interval_sub_left
    (gauss_cont.intervalIntegrable _ _) (gauss_cont.intervalIntegrable _ _), abs_mul,
    abs_of_pos kk_pos]
  apply mul_le_mul_of_nonneg_left _ kk_pos.le
  have h := intervalIntegral.norm_integral_le_of_norm_le_const (a := b) (b := a) (C := 1)
    (f := fun t : ℝ => Real.exp (-t ^ 2)) (fun t _ => by
      rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
      calc Real.exp (-t ^ 2) ≤ Real.exp 0 := Real.exp_le_exp.2 (by nlinarith [sq_nonneg t])
        _ = 1 := Real.exp_zero)
  rw [Real.norm_eq_abs, one_mul] at h
  exact h

lemma erf_sub_tail {x b : ℝ} (hx : 0 < x) (hxb : x ≤ b) :
    VoltaChallenge.erf b - VoltaChallenge.erf x ≤ kk * (Real.exp (-x ^ 2) / (2 * x)) := by
  rw [erf_eq, erf_eq, ← mul_sub, intervalIntegral.integral_interval_sub_left
    (gauss_cont.intervalIntegrable _ _) (gauss_cont.intervalIntegrable _ _)]
  apply mul_le_mul_of_nonneg_left _ kk_pos.le
  have hc2 : Continuous (fun t : ℝ => t / x * Real.exp (-t ^ 2)) := by fun_prop
  have h1 : ∫ t in x..b, Real.exp (-t ^ 2) ≤ ∫ t in x..b, t / x * Real.exp (-t ^ 2) := by
    apply intervalIntegral.integral_mono_on hxb (gauss_cont.intervalIntegrable _ _)
      (hc2.intervalIntegrable _ _)
    intro t ht
    have h1 : 1 ≤ t / x := by rw [le_div_iff₀ hx]; linarith [ht.1]
    have h2 := Real.exp_pos (-t ^ 2)
    nlinarith
  have hx' : x ≠ 0 := hx.ne'
  have h2 : ∫ t in x..b, t / x * Real.exp (-t ^ 2)
      = (-Real.exp (-b ^ 2) / (2 * x)) - (-Real.exp (-x ^ 2) / (2 * x)) := by
    apply intervalIntegral.integral_eq_sub_of_hasDerivAt
      (f := fun t => -Real.exp (-t ^ 2) / (2 * x))
    · intro t _
      have hq : HasDerivAt (fun t : ℝ => -t ^ 2) (-(2 * t)) t :=
        ((hasDerivAt_pow 2 t).neg).congr_deriv (by norm_num)
      have := (hq.exp.neg).div_const (2 * x)
      refine this.congr_deriv ?_
      try simp only [Pi.neg_apply]
      field_simp
      try ring
    · exact hc2.intervalIntegrable _ _
  rw [h2] at h1
  have h3 : 0 < Real.exp (-b ^ 2) / (2 * x) := by positivity
  have h4 : (-Real.exp (-b ^ 2) / (2 * x)) - (-Real.exp (-x ^ 2) / (2 * x))
      = Real.exp (-x ^ 2) / (2 * x) - Real.exp (-b ^ 2) / (2 * x) := by ring
  linarith

lemma erf_tendsto : Tendsto VoltaChallenge.erf atTop (nhds 1) := by
  have hint : IntegrableOn (fun t : ℝ => Real.exp (-t ^ 2)) (Ioi 0) := by
    have := (integrable_exp_neg_mul_sq (b := 1) one_pos).integrableOn (s := Ioi (0:ℝ))
    simpa using this
  have h := MeasureTheory.intervalIntegral_tendsto_integral_Ioi 0 hint tendsto_id
  have hv : ∫ t in Ioi (0:ℝ), Real.exp (-t ^ 2) = Real.sqrt Real.pi / 2 := by
    have := integral_gaussian_Ioi 1
    simpa using this
  rw [hv] at h
  have h2 := h.const_mul kk
  have h3 : kk * (Real.sqrt Real.pi / 2) = 1 := by
    unfold kk
    have := Real.sqrt_pos.2 Real.pi_pos
    field_simp
  rw [h3] at h2
  exact h2

lemma erf_mono {x b : ℝ} (h : x ≤ b) : VoltaChallenge.erf x ≤ VoltaChallenge.erf b := by
  have : 0 ≤ VoltaChallenge.erf b - VoltaChallenge.erf x := by
    rw [erf_eq, erf_eq, ← mul_sub, intervalIntegral.integral_interval_sub_left
      (gauss_cont.intervalIntegrable _ _) (gauss_cont.intervalIntegrable _ _)]
    exact mul_nonneg kk_pos.le (intervalIntegral.integral_nonneg h (fun t _ => (Real.exp_pos _).le))
  linarith

lemma erf_le_one (x : ℝ) : VoltaChallenge.erf x ≤ 1 :=
  ge_of_tendsto erf_tendsto (by
    filter_upwards [eventually_ge_atTop x] with b hb
    exact erf_mono hb)

lemma one_sub_erf_le {x : ℝ} (hx : 0 < x) :
    1 - VoltaChallenge.erf x ≤ kk * (Real.exp (-x ^ 2) / (2 * x)) :=
  le_of_tendsto (erf_tendsto.sub_const _) (by
    filter_upwards [eventually_ge_atTop x] with b hb
    exact erf_sub_tail hx hb)

/-! The approximation and its derivative. -/

noncomputable def Qp (p a1 a2 a3 a4 a5 t : ℝ) : ℝ :=
  2 / p * a1 + 2 / p * (a2 - a1) * t + (2 / p * (a3 - a2) + p * a1) * t ^ 2
  + (2 / p * (a4 - a3) + 2 * p * a2) * t ^ 3 + (2 / p * (a5 - a4) + 3 * p * a3) * t ^ 4
  + (-(2 / p) * a5 + 4 * p * a4) * t ^ 5 + 5 * p * a5 * t ^ 6

lemma hasDerivAt_A (p a1 a2 a3 a4 a5 y : ℝ) (hp : 0 < p) (hy : 0 ≤ y) :
    HasDerivAt (fun y => (-Real.exp (y * ((0:ℝ) - y))) * ((1 / (y * p + 1)) * (((1 / (y * p + 1)) *
      (((1 / (y * p + 1)) * (((1 / (y * p + 1)) * (((1 / (y * p + 1)) * a5) + a4)) + a3)) + a2)) + a1))
      + 1)
      (Real.exp (-y ^ 2) * Qp p a1 a2 a3 a4 a5 (1 / (y * p + 1))) y := by
  have hd : y * p + 1 ≠ 0 := by positivity
  have hp' : p ≠ 0 := hp.ne'
  have hT : HasDerivAt (fun y => 1 / (y * p + 1)) (-p / (y * p + 1) ^ 2) y := by
    have h1 : HasDerivAt (fun y => y * p + 1) p y := by
      simpa using ((hasDerivAt_id' y).mul_const p).add_const 1
    have h2 := h1.inv hd
    simp only [one_div]
    exact h2
  have e5 := ((hasDerivAt_id' (1 / (y * p + 1))).mul_const a5).add_const a4
  have e4 := ((hasDerivAt_id' (1 / (y * p + 1))).mul e5).add_const a3
  have e3 := ((hasDerivAt_id' (1 / (y * p + 1))).mul e4).add_const a2
  have e2 := ((hasDerivAt_id' (1 / (y * p + 1))).mul e3).add_const a1
  have e1 := (hasDerivAt_id' (1 / (y * p + 1))).mul e2
  have hR := e1.comp y hT
  have hE := ((hasDerivAt_id' y).mul ((hasDerivAt_const y (0:ℝ)).sub (hasDerivAt_id' y))).exp.neg
  have H := (hE.mul hR).add_const 1
  refine H.congr_deriv ?_
  have hx : Real.exp (y * (0 - y)) = Real.exp (-y ^ 2) := by congr 1; ring
  simp only [Pi.neg_apply, Pi.mul_apply, Pi.sub_apply, Function.comp_apply, hx]
  unfold Qp
  field_simp
  ring

noncomputable def Rf (t : ℝ) : ℝ := t * ((t * ((t * ((t * ((t * (1.0614054203033447265625 : ℝ)) + (-12189923 / 2 ^ 23 : ℝ))) + (11923683 / 2 ^ 23 : ℝ))) + (-4773063 / 2 ^ 24 : ℝ))) + (4275331 / 2 ^ 24 : ℝ))

noncomputable def Af (y : ℝ) : ℝ :=
  (-Real.exp (y * ((0 : ℝ) - y))) * Rf ((1 : ℝ) / ((y * (10992133 / 2 ^ 25 : ℝ)) + (1 : ℝ))) + (1 : ℝ)

noncomputable def Cn0 : ℝ := 2 / (10992133 / 2 ^ 25) * (4275331 / 2 ^ 24)
noncomputable def Cn1 : ℝ := 2 / (10992133 / 2 ^ 25) * ((-4773063 / 2 ^ 24) - (4275331 / 2 ^ 24))
noncomputable def Cn2 : ℝ := 2 / (10992133 / 2 ^ 25) * ((11923683 / 2 ^ 23) - (-4773063 / 2 ^ 24))
  + (10992133 / 2 ^ 25) * (4275331 / 2 ^ 24)
noncomputable def Cn3 : ℝ := 2 / (10992133 / 2 ^ 25) * ((-12189923 / 2 ^ 23) - (11923683 / 2 ^ 23))
  + 2 * (10992133 / 2 ^ 25) * (-4773063 / 2 ^ 24)
noncomputable def Cn4 : ℝ := 2 / (10992133 / 2 ^ 25) * (1.0614054203033447265625 - (-12189923 / 2 ^ 23))
  + 3 * (10992133 / 2 ^ 25) * (11923683 / 2 ^ 23)
noncomputable def Cn5 : ℝ := -(2 / (10992133 / 2 ^ 25)) * 1.0614054203033447265625
  + 4 * (10992133 / 2 ^ 25) * (-12189923 / 2 ^ 23)
noncomputable def Cn6 : ℝ := 5 * (10992133 / 2 ^ 25) * 1.0614054203033447265625

noncomputable def Qn (t : ℝ) : ℝ :=
  Cn0 + Cn1 * t + Cn2 * t ^ 2 + Cn3 * t ^ 3 + Cn4 * t ^ 4 + Cn5 * t ^ 5 + Cn6 * t ^ 6

lemma Qn_eq (t : ℝ) : Qn t = Qp (10992133 / 2 ^ 25) (4275331 / 2 ^ 24) (-4773063 / 2 ^ 24)
    (11923683 / 2 ^ 23) (-12189923 / 2 ^ 23) 1.0614054203033447265625 t := by
  unfold Qn Qp Cn0 Cn1 Cn2 Cn3 Cn4 Cn5 Cn6
  ring

lemma Af_deriv (y : ℝ) (hy : 0 ≤ y) :
    HasDerivAt Af (Real.exp (-y ^ 2) * Qn (1 / (y * (10992133 / 2 ^ 25) + 1))) y := by
  rw [Qn_eq]
  exact hasDerivAt_A _ _ _ _ _ _ y (by norm_num) hy

/-! Polynomial bounds. -/

lemma tbound (B1 B2 B3 B4 B5 B6 s r : ℝ) (hs : |s| ≤ r) :
    |B1 * s + B2 * s ^ 2 + B3 * s ^ 3 + B4 * s ^ 4 + B5 * s ^ 5 + B6 * s ^ 6| ≤
      |B1| * r + |B2| * r ^ 2 + |B3| * r ^ 3 + |B4| * r ^ 4 + |B5| * r ^ 5 + |B6| * r ^ 6 := by
  have e : ∀ (B : ℝ) (n : ℕ), |B * s ^ n| ≤ |B| * r ^ n := fun B n => by
    rw [abs_mul, abs_pow]
    exact mul_le_mul_of_nonneg_left (pow_le_pow_left₀ (abs_nonneg _) hs n) (abs_nonneg _)
  have h1 := abs_le.1 (e B1 1)
  have h2 := abs_le.1 (e B2 2)
  have h3 := abs_le.1 (e B3 3)
  have h4 := abs_le.1 (e B4 4)
  have h5 := abs_le.1 (e B5 5)
  have h6 := abs_le.1 (e B6 6)
  simp only [pow_one] at h1
  rw [abs_le]
  constructor <;> linarith [h1.1, h1.2, h2.1, h2.2, h3.1, h3.2, h4.1, h4.2, h5.1, h5.2, h6.1, h6.2]

lemma piece_core (B0 S Sb k klo khi M : ℝ) (hS : |S| ≤ Sb) (hk1 : klo ≤ k) (hk2 : k ≤ khi)
    (h1 : B0 - klo + Sb ≤ M) (h2 : khi - B0 + Sb ≤ M) : |B0 + S - k| ≤ M := by
  have := abs_le.1 hS
  rw [abs_le]; constructor <;> linarith [this.1, this.2]

lemma piece (C0 C1 C2 C3 C4 C5 C6 c r t k klo khi M : ℝ)
    (ht : |t - c| ≤ r) (hk1 : klo ≤ k) (hk2 : k ≤ khi)
    (h1 : (C0 + C1 * c + C2 * c ^ 2 + C3 * c ^ 3 + C4 * c ^ 4 + C5 * c ^ 5 + C6 * c ^ 6) - klo
      + (|C1 + 2 * C2 * c + 3 * C3 * c ^ 2 + 4 * C4 * c ^ 3 + 5 * C5 * c ^ 4 + 6 * C6 * c ^ 5| * r
      + |C2 + 3 * C3 * c + 6 * C4 * c ^ 2 + 10 * C5 * c ^ 3 + 15 * C6 * c ^ 4| * r ^ 2
      + |C3 + 4 * C4 * c + 10 * C5 * c ^ 2 + 20 * C6 * c ^ 3| * r ^ 3
      + |C4 + 5 * C5 * c + 15 * C6 * c ^ 2| * r ^ 4
      + |C5 + 6 * C6 * c| * r ^ 5 + |C6| * r ^ 6) ≤ M)
    (h2 : khi - (C0 + C1 * c + C2 * c ^ 2 + C3 * c ^ 3 + C4 * c ^ 4 + C5 * c ^ 5 + C6 * c ^ 6)
      + (|C1 + 2 * C2 * c + 3 * C3 * c ^ 2 + 4 * C4 * c ^ 3 + 5 * C5 * c ^ 4 + 6 * C6 * c ^ 5| * r
      + |C2 + 3 * C3 * c + 6 * C4 * c ^ 2 + 10 * C5 * c ^ 3 + 15 * C6 * c ^ 4| * r ^ 2
      + |C3 + 4 * C4 * c + 10 * C5 * c ^ 2 + 20 * C6 * c ^ 3| * r ^ 3
      + |C4 + 5 * C5 * c + 15 * C6 * c ^ 2| * r ^ 4
      + |C5 + 6 * C6 * c| * r ^ 5 + |C6| * r ^ 6) ≤ M) :
    |C0 + C1 * t + C2 * t ^ 2 + C3 * t ^ 3 + C4 * t ^ 4 + C5 * t ^ 5 + C6 * t ^ 6 - k| ≤ M := by
  have hb := tbound (C1 + 2 * C2 * c + 3 * C3 * c ^ 2 + 4 * C4 * c ^ 3 + 5 * C5 * c ^ 4 + 6 * C6 * c ^ 5)
    (C2 + 3 * C3 * c + 6 * C4 * c ^ 2 + 10 * C5 * c ^ 3 + 15 * C6 * c ^ 4)
    (C3 + 4 * C4 * c + 10 * C5 * c ^ 2 + 20 * C6 * c ^ 3)
    (C4 + 5 * C5 * c + 15 * C6 * c ^ 2) (C5 + 6 * C6 * c) C6 (t - c) r ht
  have key : C0 + C1 * t + C2 * t ^ 2 + C3 * t ^ 3 + C4 * t ^ 4 + C5 * t ^ 5 + C6 * t ^ 6 =
      (C0 + C1 * c + C2 * c ^ 2 + C3 * c ^ 3 + C4 * c ^ 4 + C5 * c ^ 5 + C6 * c ^ 6) +
      ((C1 + 2 * C2 * c + 3 * C3 * c ^ 2 + 4 * C4 * c ^ 3 + 5 * C5 * c ^ 4 + 6 * C6 * c ^ 5) * (t - c)
      + (C2 + 3 * C3 * c + 6 * C4 * c ^ 2 + 10 * C5 * c ^ 3 + 15 * C6 * c ^ 4) * (t - c) ^ 2
      + (C3 + 4 * C4 * c + 10 * C5 * c ^ 2 + 20 * C6 * c ^ 3) * (t - c) ^ 3
      + (C4 + 5 * C5 * c + 15 * C6 * c ^ 2) * (t - c) ^ 4
      + (C5 + 6 * C6 * c) * (t - c) ^ 5 + C6 * (t - c) ^ 6) := by ring
  rw [key]
  exact piece_core _ _ _ _ _ _ _ hb hk1 hk2 h1 h2

lemma exp_lower (s σ : ℝ) (hσ0 : 0 ≤ σ) (hs : σ ≤ s) :
    (1 + σ ^ 2 / 2 + (σ ^ 2) ^ 2 / 8) ^ 2 ≤ Real.exp (s ^ 2) := by
  have h1 : σ ^ 2 ≤ s ^ 2 := by nlinarith
  have h1' : (σ ^ 2) ^ 2 ≤ (s ^ 2) ^ 2 := by nlinarith [sq_nonneg σ]
  have h2 := Real.quadratic_le_exp_of_nonneg (x := s ^ 2 / 2) (by positivity)
  have h3 : Real.exp (s ^ 2) = Real.exp (s ^ 2 / 2) ^ 2 := by
    rw [sq (Real.exp _), ← Real.exp_add]; congr 1; ring
  rw [h3]
  have h4 : 1 + σ ^ 2 / 2 + (σ ^ 2) ^ 2 / 8 ≤ Real.exp (s ^ 2 / 2) := by nlinarith
  exact pow_le_pow_left₀ (by positivity) h4 2

lemma step (s t lo hi c r σ : ℝ) (hs0 : 0 ≤ s) (ht : t = 1 / (s * (10992133 / 2 ^ 25) + 1))
    (hlo : lo ≤ t) (hhi : t ≤ hi) (hc : c = (lo + hi) / 2) (hr : r = (hi - lo) / 2)
    (_hhi0 : 0 < hi) (hσ : σ * hi * (10992133 / 2 ^ 25) ≤ 1 - hi) (hσ0 : 0 ≤ σ)
    (h1 : (Cn0 + Cn1 * c + Cn2 * c ^ 2 + Cn3 * c ^ 3 + Cn4 * c ^ 4 + Cn5 * c ^ 5 + Cn6 * c ^ 6) - 1.128378
      + (|Cn1 + 2 * Cn2 * c + 3 * Cn3 * c ^ 2 + 4 * Cn4 * c ^ 3 + 5 * Cn5 * c ^ 4 + 6 * Cn6 * c ^ 5| * r
      + |Cn2 + 3 * Cn3 * c + 6 * Cn4 * c ^ 2 + 10 * Cn5 * c ^ 3 + 15 * Cn6 * c ^ 4| * r ^ 2
      + |Cn3 + 4 * Cn4 * c + 10 * Cn5 * c ^ 2 + 20 * Cn6 * c ^ 3| * r ^ 3
      + |Cn4 + 5 * Cn5 * c + 15 * Cn6 * c ^ 2| * r ^ 4
      + |Cn5 + 6 * Cn6 * c| * r ^ 5 + |Cn6| * r ^ 6)
        ≤ 0.00015 * (1 + σ ^ 2 / 2 + (σ ^ 2) ^ 2 / 8) ^ 2)
    (h2 : 1.12838 - (Cn0 + Cn1 * c + Cn2 * c ^ 2 + Cn3 * c ^ 3 + Cn4 * c ^ 4 + Cn5 * c ^ 5 + Cn6 * c ^ 6)
      + (|Cn1 + 2 * Cn2 * c + 3 * Cn3 * c ^ 2 + 4 * Cn4 * c ^ 3 + 5 * Cn5 * c ^ 4 + 6 * Cn6 * c ^ 5| * r
      + |Cn2 + 3 * Cn3 * c + 6 * Cn4 * c ^ 2 + 10 * Cn5 * c ^ 3 + 15 * Cn6 * c ^ 4| * r ^ 2
      + |Cn3 + 4 * Cn4 * c + 10 * Cn5 * c ^ 2 + 20 * Cn6 * c ^ 3| * r ^ 3
      + |Cn4 + 5 * Cn5 * c + 15 * Cn6 * c ^ 2| * r ^ 4
      + |Cn5 + 6 * Cn6 * c| * r ^ 5 + |Cn6| * r ^ 6)
        ≤ 0.00015 * (1 + σ ^ 2 / 2 + (σ ^ 2) ^ 2 / 8) ^ 2) :
    |Real.exp (-s ^ 2) * (Qn t - kk)| ≤ 0.00015 := by
  have hQ : |Qn t - kk| ≤ 0.00015 * (1 + σ ^ 2 / 2 + (σ ^ 2) ^ 2 / 8) ^ 2 :=
    piece Cn0 Cn1 Cn2 Cn3 Cn4 Cn5 Cn6 c r t kk 1.128378 1.12838 _
      (abs_le.2 ⟨by rw [hr, hc]; linarith, by rw [hr, hc]; linarith⟩) kk_lo kk_hi h1 h2
  have hd : 0 < s * (10992133 / 2 ^ 25 : ℝ) + 1 := by positivity
  have hsσ : σ ≤ s := by
    rw [ht, div_le_iff₀ hd] at hhi
    nlinarith
  have hW := exp_lower s σ hσ0 hsσ
  rw [abs_mul, abs_of_pos (Real.exp_pos _), Real.exp_neg]
  have hE := Real.exp_pos (s ^ 2)
  rw [inv_mul_le_iff₀ hE]
  nlinarith

lemma pointwise (s : ℝ) (hs0 : 0 ≤ s) (hs : s ≤ 2.8) :
    |Real.exp (-s ^ 2) * (Qn (1 / (s * (10992133 / 2 ^ 25) + 1)) - kk)| ≤ 0.00015 := by
  have hd : 0 < s * (10992133 / 2 ^ 25 : ℝ) + 1 := by positivity
  set t := 1 / (s * (10992133 / 2 ^ 25 : ℝ) + 1) with ht
  have ht1 : (0.52 : ℝ) ≤ t := by rw [ht, le_div_iff₀ hd]; nlinarith
  have ht2 : t ≤ 1 := by rw [ht, div_le_iff₀ hd]; nlinarith
  rcases le_total t 0.55 with h1 | h1
  · exact step s t 0.52 0.55 0.535 0.015 2.49 hs0 ht ht1 h1 (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num)
      (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6]) (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6])
  rcases le_total t 0.6 with h2 | h2
  · exact step s t 0.55 0.6 0.575 0.025 2.03 hs0 ht h1 h2 (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num)
      (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6]) (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6])
  rcases le_total t 0.65 with h3 | h3
  · exact step s t 0.6 0.65 0.625 0.025 1.64 hs0 ht h2 h3 (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num)
      (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6]) (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6])
  rcases le_total t 0.7 with h4 | h4
  · exact step s t 0.65 0.7 0.675 0.025 1.30 hs0 ht h3 h4 (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num)
      (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6]) (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6])
  rcases le_total t 0.75 with h5 | h5
  · exact step s t 0.7 0.75 0.725 0.025 1.01 hs0 ht h4 h5 (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num)
      (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6]) (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6])
  rcases le_total t 0.8 with h6 | h6
  · exact step s t 0.75 0.8 0.775 0.025 0.76 hs0 ht h5 h6 (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num)
      (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6]) (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6])
  rcases le_total t 0.85 with h7 | h7
  · exact step s t 0.8 0.85 0.825 0.025 0.53 hs0 ht h6 h7 (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num)
      (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6]) (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6])
  rcases le_total t 0.9 with h8 | h8
  · exact step s t 0.85 0.9 0.875 0.025 0.33 hs0 ht h7 h8 (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num)
      (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6]) (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6])
  rcases le_total t 0.95 with h9 | h9
  · exact step s t 0.9 0.95 0.925 0.025 0.16 hs0 ht h8 h9 (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num)
      (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6]) (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6])
  · exact step s t 0.95 1 0.975 0.025 0 hs0 ht h9 ht2 (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num)
      (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6]) (by norm_num [Cn0, Cn1, Cn2, Cn3, Cn4, Cn5, Cn6])

lemma D_bound (Y : ℝ) (hY0 : 0 ≤ Y) (hY : Y ≤ 2.8) :
    |(Af Y - VoltaChallenge.erf Y) - (Af 0 - VoltaChallenge.erf 0)| ≤ 0.00015 * Y := by
  have := norm_image_sub_le_of_norm_deriv_le_segment' (f := fun y => Af y - VoltaChallenge.erf y)
    (f' := fun y => Real.exp (-y ^ 2) * Qn (1 / (y * (10992133 / 2 ^ 25) + 1)) - kk * Real.exp (-y ^ 2))
    (a := 0) (b := Y) (C := 0.00015) ?_ ?_ Y ⟨hY0, le_rfl⟩
  · simp only [Real.norm_eq_abs, sub_zero] at this
    exact this
  · intro x hx
    exact ((Af_deriv x hx.1).sub (erf_hasDerivAt x)).hasDerivWithinAt
  · intro x hx
    rw [Real.norm_eq_abs]
    have : Real.exp (-x ^ 2) * Qn (1 / (x * (10992133 / 2 ^ 25) + 1)) - kk * Real.exp (-x ^ 2)
        = Real.exp (-x ^ 2) * (Qn (1 / (x * (10992133 / 2 ^ 25) + 1)) - kk) := by ring
    rw [this]
    exact pointwise x hx.1 (by linarith [hx.2])

lemma compact (w : ℝ) (hw : 0 ≤ w) (hy : w * (11863283 / 2 ^ 24) ≤ 2.8) :
    w * |Af (w * (11863283 / 2 ^ 24)) - VoltaChallenge.erf (w * (6369051672525773 / 2 ^ 53))|
      ≤ 0.002 := by
  have hy0 : 0 ≤ w * (11863283 / 2 ^ 24 : ℝ) := by positivity
  have hD := D_bound _ hy0 hy
  rw [erf_zero] at hD
  have hA0 : |Af 0| ≤ 0.000001 := by unfold Af Rf; norm_num
  have hL := erf_lip (w * (11863283 / 2 ^ 24)) (w * (6369051672525773 / 2 ^ 53))
  have hyx : |w * (11863283 / 2 ^ 24 : ℝ) - w * (6369051672525773 / 2 ^ 53)|
      = w * (6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24) := by
    rw [abs_sub_comm, abs_of_nonneg (by nlinarith)]; ring
  rw [hyx] at hL
  have hw4 : w ≤ 4 := by nlinarith
  have hkw : kk * w ≤ 1.12838 * 4 := mul_le_mul kk_hi hw4 hw (by norm_num)
  have hsum : |Af (w * (11863283 / 2 ^ 24)) - VoltaChallenge.erf (w * (6369051672525773 / 2 ^ 53))|
      ≤ 0.00015 * 2.8 + 0.000001 + 1.12838 * 4 * (6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24) := by
    have a1 := abs_le.1 hD
    have a2 := abs_le.1 hA0
    have a3 := abs_le.1 hL
    have hdc : (0:ℝ) ≤ 6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24 := by norm_num
    have a4 : kk * (w * (6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24))
        ≤ 1.12838 * 4 * (6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24) := by
      rw [← mul_assoc]; exact mul_le_mul_of_nonneg_right hkw hdc
    rw [abs_le]; constructor <;> nlinarith
  calc w * |Af (w * (11863283 / 2 ^ 24)) - VoltaChallenge.erf (w * (6369051672525773 / 2 ^ 53))|
      ≤ 4 * (0.00015 * 2.8 + 0.000001 + 1.12838 * 4 * (6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24)) :=
        mul_le_mul hw4 hsum (abs_nonneg _) (by norm_num)
    _ ≤ 0.002 := by norm_num

lemma R_bounds (t : ℝ) (h0 : 0 ≤ t) (h1 : t ≤ 0.53) : 0 ≤ Rf t ∧ Rf t ≤ 0.28 := by
  unfold Rf
  obtain ⟨u4, hu4⟩ : ∃ u, u = t * (1.0614054203033447265625 : ℝ) + (-12189923 / 2 ^ 23 : ℝ) := ⟨_, rfl⟩
  rw [← hu4]
  have u4l : (-12189923 / 2 ^ 23 : ℝ) ≤ u4 := by rw [hu4]; nlinarith
  have u4h : u4 ≤ -0.89 := by rw [hu4]; nlinarith
  obtain ⟨u3, hu3⟩ : ∃ u, u = t * u4 + (11923683 / 2 ^ 23 : ℝ) := ⟨_, rfl⟩
  rw [← hu3]
  have u3l : 0.65 ≤ u3 := by rw [hu3]; nlinarith
  have u3h : u3 ≤ 1.43 := by rw [hu3]; nlinarith
  obtain ⟨u2, hu2⟩ : ∃ u, u = t * u3 + (-4773063 / 2 ^ 24 : ℝ) := ⟨_, rfl⟩
  rw [← hu2]
  have u2l : -0.29 ≤ u2 := by rw [hu2]; nlinarith
  have u2h : u2 ≤ 0.48 := by rw [hu2]; nlinarith
  obtain ⟨u1, hu1⟩ : ∃ u, u = t * u2 + (4275331 / 2 ^ 24 : ℝ) := ⟨_, rfl⟩
  rw [← hu1]
  have u1l : 0.1 ≤ u1 := by rw [hu1]; nlinarith
  have u1h : u1 ≤ 0.51 := by rw [hu1]; nlinarith
  constructor <;> nlinarith

lemma tail (w : ℝ) (hw : 0 ≤ w) (hy : 2.8 ≤ w * (11863283 / 2 ^ 24)) :
    w * |Af (w * (11863283 / 2 ^ 24)) - VoltaChallenge.erf (w * (6369051672525773 / 2 ^ 53))|
      ≤ 0.002 := by
  have hwy : w ≤ 1.4143 * (w * (11863283 / 2 ^ 24)) := by nlinarith
  have hxy : w * (11863283 / 2 ^ 24 : ℝ) ≤ w * (6369051672525773 / 2 ^ 53) := by nlinarith
  generalize w * (11863283 / 2 ^ 24 : ℝ) = y at hy hwy hxy ⊢
  generalize w * (6369051672525773 / 2 ^ 53 : ℝ) = x at hxy ⊢
  have hx0 : 0 < x := by linarith
  have hd : 0 < y * (10992133 / 2 ^ 25 : ℝ) + 1 := by nlinarith
  have ht0 : 0 ≤ 1 / (y * (10992133 / 2 ^ 25 : ℝ) + 1) := by positivity
  have ht1 : 1 / (y * (10992133 / 2 ^ 25 : ℝ) + 1) ≤ 0.53 := by
    rw [div_le_iff₀ hd]; nlinarith
  obtain ⟨hR0, hR1⟩ := R_bounds _ ht0 ht1
  have hA : Af y = 1 - Real.exp (-y ^ 2) * Rf (1 / (y * (10992133 / 2 ^ 25) + 1)) := by
    unfold Af; rw [show y * (0 - y) = -y ^ 2 by ring]; ring
  have hE1 : 0 < Real.exp (-y ^ 2) := Real.exp_pos _
  have hEx : Real.exp (-x ^ 2) ≤ Real.exp (-y ^ 2) := Real.exp_le_exp.2 (by nlinarith)
  have hupper := one_sub_erf_le hx0
  have hle1 := erf_le_one x
  have hq : Real.exp (-x ^ 2) / (2 * x) ≤ Real.exp (-y ^ 2) * 0.18 := by
    rw [div_le_iff₀ (by linarith)]
    nlinarith [mul_le_mul_of_nonneg_left hxy hE1.le]
  have hkx : kk * (Real.exp (-x ^ 2) / (2 * x)) ≤ 0.28 * Real.exp (-y ^ 2) := by
    have := mul_le_mul kk_hi hq (by positivity) (by norm_num)
    nlinarith
  have hp1 := mul_nonneg hE1.le hR0
  have hp2 := mul_le_mul_of_nonneg_left hR1 hE1.le
  have habs : |Af y - VoltaChallenge.erf x| ≤ 0.28 * Real.exp (-y ^ 2) := by
    rw [hA, abs_le]; constructor <;> linarith
  have he7 : (1096 : ℝ) ≤ Real.exp 7 := by
    have := Real.exp_one_gt_d9
    have h : Real.exp 7 = Real.exp 1 ^ 7 := by rw [← Real.exp_nat_mul]; norm_num
    rw [h]
    calc (1096:ℝ) ≤ 2.7182818283 ^ 7 := by norm_num
      _ ≤ Real.exp 1 ^ 7 := pow_le_pow_left₀ (by norm_num) this.le 7
  have hey : 1096 * (y ^ 2 - 6) ≤ Real.exp (y ^ 2) := by
    have h1 : Real.exp (y ^ 2) = Real.exp 7 * Real.exp (y ^ 2 - 7) := by
      rw [← Real.exp_add]; congr 1; ring
    have h2 := Real.add_one_le_exp (y ^ 2 - 7)
    have h3 : 0 ≤ y ^ 2 - 7 + 1 := by nlinarith
    rw [h1]; nlinarith [Real.exp_pos (y ^ 2 - 7)]
  have hexpinv : Real.exp (-y ^ 2) * Real.exp (y ^ 2) = 1 := by
    rw [← Real.exp_add]; simp
  have hlin : 0.28 * w ≤ 0.002 * Real.exp (y ^ 2) := by
    nlinarith [mul_nonneg (sub_nonneg.2 hy) (by linarith : (0:ℝ) ≤ y)]
  have hfin := mul_le_mul_of_nonneg_right hlin hE1.le
  calc w * |Af y - VoltaChallenge.erf x| ≤ w * (0.28 * Real.exp (-y ^ 2)) :=
        mul_le_mul_of_nonneg_left habs hw
    _ ≤ 0.002 := by nlinarith

lemma key (w : ℝ) (hw : 0 ≤ w) :
    w * |Af (w * (11863283 / 2 ^ 24)) - VoltaChallenge.erf (w * (6369051672525773 / 2 ^ 53))|
      ≤ 0.002 := by
  rcases le_total (w * (11863283 / 2 ^ 24 : ℝ)) 2.8 with h | h
  · exact compact w hw h
  · exact tail w hw h

theorem y_0 : VoltaChallenge.y_0 := by
  intro v0
  show |((v0 * (0.5 : ℝ)) * ((if v0 * (11863283 / 2 ^ 24 : ℝ) ≥ (0 : ℝ) then Af |v0 * (11863283 / 2 ^ 24 : ℝ)| else (0 : ℝ) - Af |v0 * (11863283 / 2 ^ 24 : ℝ)|) + (1 : ℝ))) - (((0.5 : ℝ) * v0) * ((1 : ℝ) + VoltaChallenge.erf (v0 * (6369051672525773 / 2 ^ 53 : ℝ))))| ≤ (0.001 : ℝ)
  rcases le_or_gt 0 v0 with hv | hv
  · have hx : v0 * (11863283 / 2 ^ 24 : ℝ) ≥ 0 := by positivity
    rw [if_pos hx, abs_of_nonneg hx]
    have hk := key v0 hv
    have e : (v0 * (0.5:ℝ)) * (Af (v0 * (11863283 / 2 ^ 24)) + 1)
        - ((0.5:ℝ) * v0) * (1 + VoltaChallenge.erf (v0 * (6369051672525773 / 2 ^ 53)))
        = 0.5 * (v0 * (Af (v0 * (11863283 / 2 ^ 24))
          - VoltaChallenge.erf (v0 * (6369051672525773 / 2 ^ 53)))) := by ring
    rw [e, abs_mul, abs_mul, abs_of_nonneg hv, abs_of_pos (by norm_num : (0:ℝ) < 0.5)]
    linarith
  · have hx' : v0 * (11863283 / 2 ^ 24 : ℝ) < 0 := by nlinarith
    have hx : ¬ (v0 * (11863283 / 2 ^ 24 : ℝ) ≥ 0) := not_le.2 hx'
    rw [if_neg hx, abs_of_neg hx']
    have hk := key (-v0) (by linarith)
    have e1 : -(v0 * (11863283 / 2 ^ 24 : ℝ)) = (-v0) * (11863283 / 2 ^ 24) := by ring
    have e2 : v0 * (6369051672525773 / 2 ^ 53 : ℝ) = -((-v0) * (6369051672525773 / 2 ^ 53)) := by ring
    rw [e1, e2, erf_neg]
    have e : (v0 * (0.5:ℝ)) * ((0 - Af ((-v0) * (11863283 / 2 ^ 24))) + 1)
        - ((0.5:ℝ) * v0) * (1 + -VoltaChallenge.erf ((-v0) * (6369051672525773 / 2 ^ 53)))
        = 0.5 * ((-v0) * (Af ((-v0) * (11863283 / 2 ^ 24))
          - VoltaChallenge.erf ((-v0) * (6369051672525773 / 2 ^ 53)))) := by ring
    rw [e, abs_mul, abs_mul, abs_of_nonneg (by linarith : (0:ℝ) ≤ -v0),
      abs_of_pos (by norm_num : (0:ℝ) < 0.5)]
    linarith

end VoltaProofs
