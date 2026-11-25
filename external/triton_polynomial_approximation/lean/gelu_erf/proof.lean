import challenge

namespace VoltaProofs

open Real MeasureTheory intervalIntegral Set Filter Topology

noncomputable def I (y : ℝ) : ℝ := ∫ t in (0:ℝ)..y, Real.exp (-t ^ 2)

noncomputable def kk : ℝ := 2 / Real.sqrt Real.pi

noncomputable def A7 (x : ℝ) : ℝ := 64*x^6+640*x^4+1392*x^2+384
noncomputable def B7 (x : ℝ) : ℝ := 128*x^7+1344*x^5+3360*x^3+1680*x
noncomputable def A8 (x : ℝ) : ℝ := 128*x^7+1728*x^5+5920*x^3+4464*x
noncomputable def B8 (x : ℝ) : ℝ := 256*x^8+3584*x^6+13440*x^4+13440*x^2+1680

noncomputable def cc : ℝ := 8388608 / 12102203

noncomputable def PL (x : ℝ) : ℝ := (((((((((((((((2257551 / 2 ^ 37 : ℝ)) * x) + (-16081081 / 2 ^ 35 : ℝ)) * x) + (11305995 / 2 ^ 31 : ℝ)) * x) + (-4604081 / 2 ^ 27 : ℝ)) * x) + (5143683 / 2 ^ 25 : ℝ)) * x) + (7686591 / 2 ^ 23 : ℝ)) * x) + (5270561 / 2 ^ 23 : ℝ)) * (-x)) + (-x)

noncomputable def Ps (x : ℝ) : ℝ := (((((((((((((((5829813 / 2 ^ 36 : ℝ)) * (x*x)) + (-440937 / 2 ^ 29 : ℝ)) * (x*x)) + (5597941 / 2 ^ 30 : ℝ)) * (x*x)) + (-14425063 / 2 ^ 29 : ℝ)) * (x*x)) + (15145135 / 2 ^ 27 : ℝ)) * (x*x)) + (-3155179 / 2 ^ 23 : ℝ)) * (x*x)) + (8615379 / 2 ^ 26 : ℝ)) * x) + x

noncomputable def WW (x : ℝ) : ℝ := PL x * cc + x ^ 2

lemma Ps_odd (x : ℝ) : Ps (-x) = - Ps x := by unfold Ps; ring

lemma bern {a b : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b) (i j : ℕ) : 0 ≤ a ^ i * b ^ j :=
  mul_nonneg (pow_nonneg ha i) (pow_nonneg hb j)

lemma contg : Continuous (fun t : ℝ => Real.exp (-t ^ 2)) := by fun_prop

lemma I_hasDerivAt (y : ℝ) : HasDerivAt I (Real.exp (-y ^ 2)) y :=
  (contg.integral_hasStrictDerivAt 0 y).hasDerivAt

lemma hasDerivAt_gauss (y : ℝ) :
    HasDerivAt (fun y => Real.exp (-y ^ 2)) (Real.exp (-y ^ 2) * (-(2 * y))) y := by
  have := ((hasDerivAt_pow 2 y).neg).exp
  convert this using 1
  simp only [Pi.neg_apply]
  norm_num

lemma hdm (c : ℝ) (n : ℕ) (x : ℝ) : HasDerivAt (fun x => c * x ^ n) (c * (n * x ^ (n - 1))) x :=
  (hasDerivAt_pow n x).const_mul c

lemma hA7 (x : ℝ) : HasDerivAt A7 (384*x^5+2560*x^3+2784*x) x := by
  show HasDerivAt (fun x => 64*x^6+640*x^4+1392*x^2+384) (384*x^5+2560*x^3+2784*x) x
  have h := ((hdm 64 6 x).add (hdm 640 4 x)).add ((hdm 1392 2 x).add (hasDerivAt_const x (384:ℝ)))
  have e : (fun x : ℝ => 64*x^6+640*x^4+1392*x^2+384) =
      ((fun x => 64 * x ^ 6) + fun x => 640 * x ^ 4) + ((fun x => 1392 * x ^ 2) + fun _ => (384:ℝ)) := by
    funext z; simp only [Pi.add_apply]; ring
  rw [e]
  exact h.congr_deriv (show _ = 384*x^5+2560*x^3+2784*x by norm_num; ring)

lemma hB7 (x : ℝ) : HasDerivAt B7 (896*x^6+6720*x^4+10080*x^2+1680) x := by
  show HasDerivAt (fun x => 128*x^7+1344*x^5+3360*x^3+1680*x) (896*x^6+6720*x^4+10080*x^2+1680) x
  have h := ((hdm 128 7 x).add (hdm 1344 5 x)).add ((hdm 3360 3 x).add (hdm 1680 1 x))
  have e : (fun x : ℝ => 128*x^7+1344*x^5+3360*x^3+1680*x) =
      ((fun x => 128 * x ^ 7) + fun x => 1344 * x ^ 5) + ((fun x => 3360 * x ^ 3) + fun x => 1680 * x ^ 1) := by
    funext z; simp only [Pi.add_apply]; ring
  rw [e]
  exact h.congr_deriv (show _ = 896*x^6+6720*x^4+10080*x^2+1680 by norm_num; ring)

lemma hA8 (x : ℝ) : HasDerivAt A8 (896*x^6+8640*x^4+17760*x^2+4464) x := by
  show HasDerivAt (fun x => 128*x^7+1728*x^5+5920*x^3+4464*x) (896*x^6+8640*x^4+17760*x^2+4464) x
  have h := ((hdm 128 7 x).add (hdm 1728 5 x)).add ((hdm 5920 3 x).add (hdm 4464 1 x))
  have e : (fun x : ℝ => 128*x^7+1728*x^5+5920*x^3+4464*x) =
      ((fun x => 128 * x ^ 7) + fun x => 1728 * x ^ 5) + ((fun x => 5920 * x ^ 3) + fun x => 4464 * x ^ 1) := by
    funext z; simp only [Pi.add_apply]; ring
  rw [e]
  exact h.congr_deriv (show _ = 896*x^6+8640*x^4+17760*x^2+4464 by norm_num; ring)

lemma hB8 (x : ℝ) : HasDerivAt B8 (2048*x^7+21504*x^5+53760*x^3+26880*x) x := by
  show HasDerivAt (fun x => 256*x^8+3584*x^6+13440*x^4+13440*x^2+1680) (2048*x^7+21504*x^5+53760*x^3+26880*x) x
  have h := (((hdm 256 8 x).add (hdm 3584 6 x)).add ((hdm 13440 4 x).add (hdm 13440 2 x))).add
    (hasDerivAt_const x (1680:ℝ))
  have e : (fun x : ℝ => 256*x^8+3584*x^6+13440*x^4+13440*x^2+1680) =
      (((fun x => 256 * x ^ 8) + fun x => 3584 * x ^ 6) + ((fun x => 13440 * x ^ 4) + fun x => 13440 * x ^ 2))
        + fun _ => (1680:ℝ) := by
    funext z; simp only [Pi.add_apply]; ring
  rw [e]
  exact h.congr_deriv (show _ = 2048*x^7+21504*x^5+53760*x^3+26880*x by norm_num; ring)

lemma I_odd (y : ℝ) : I (-y) = - I y := by
  unfold I
  have h := intervalIntegral.integral_comp_neg (a := (0:ℝ)) (b := y) (f := fun t => Real.exp (-t ^ 2))
  simp only [neg_sq, neg_zero] at h
  rw [intervalIntegral.integral_symm, ← h]

lemma I_split (x u : ℝ) : I u = I x + ∫ t in x..u, Real.exp (-t ^ 2) := by
  unfold I
  rw [intervalIntegral.integral_add_adjacent_intervals (contg.intervalIntegrable _ _) (contg.intervalIntegrable _ _)]

lemma I_nonneg (x : ℝ) (hx : 0 ≤ x) : 0 ≤ I x := by
  unfold I
  exact intervalIntegral.integral_nonneg hx (fun t _ => (Real.exp_pos _).le)

lemma I_mono (x u : ℝ) (h : x ≤ u) : I x ≤ I u ∧ I u ≤ I x + (u - x) := by
  rw [I_split x u]
  constructor
  · have : 0 ≤ ∫ t in x..u, Real.exp (-t ^ 2) :=
      intervalIntegral.integral_nonneg h (fun t _ => (Real.exp_pos _).le)
    linarith
  · have : ∫ t in x..u, Real.exp (-t ^ 2) ≤ ∫ t in x..u, (1:ℝ) :=
      intervalIntegral.integral_mono_on h (contg.intervalIntegrable _ _)
        (continuous_const.intervalIntegrable _ _)
        (fun t _ => Real.exp_le_one_iff.mpr (neg_nonpos.mpr (sq_nonneg t)))
    simp at this
    linarith

lemma I_near1 (X : ℝ) (h : 1 ≤ X) :
    I 1 + (X - 1) * Real.exp (-X ^ 2) ≤ I X ∧ I X ≤ I 1 + (X - 1) * Real.exp (-1) := by
  rw [I_split 1 X]
  constructor
  · have : ∫ t in (1:ℝ)..X, Real.exp (-X ^ 2) ≤ ∫ t in (1:ℝ)..X, Real.exp (-t ^ 2) :=
      intervalIntegral.integral_mono_on h (continuous_const.intervalIntegrable _ _)
        (contg.intervalIntegrable _ _)
        (fun t ht => Real.exp_le_exp.mpr (neg_le_neg (pow_le_pow_left₀ (by linarith [ht.1]) ht.2 2)))
    simp at this
    linarith
  · have : ∫ t in (1:ℝ)..X, Real.exp (-t ^ 2) ≤ ∫ t in (1:ℝ)..X, Real.exp (-1) :=
      intervalIntegral.integral_mono_on h (contg.intervalIntegrable _ _)
        (continuous_const.intervalIntegrable _ _)
        (fun t ht => Real.exp_le_exp.mpr (by nlinarith [ht.1]))
    simp at this
    linarith

lemma I_tendsto : Tendsto I atTop (𝓝 (√π / 2)) := by
  have h1 : IntegrableOn (fun t : ℝ => Real.exp (-t ^ 2)) (Ioi 0) := by
    have := (integrable_exp_neg_mul_sq (b := 1) one_pos).integrableOn (s := Ioi (0:ℝ))
    simpa using this
  have h2 := intervalIntegral_tendsto_integral_Ioi (μ := volume) 0 h1 tendsto_id
  have h3 : ∫ t in Ioi (0:ℝ), Real.exp (-t ^ 2) = √π / 2 := by
    have := integral_gaussian_Ioi 1
    simpa using this
  rw [h3] at h2
  exact h2

lemma cf_upper (r r' : ℝ → ℝ) (a : ℝ)
    (hd : ∀ x, a ≤ x → HasDerivAt r (r' x) x)
    (hres : ∀ x, a ≤ x → 1 ≤ 2 * x * r x - r' x)
    (hpos : ∀ x, a ≤ x → 0 ≤ r x) :
    ∀ x, a ≤ x → √π / 2 ≤ I x + Real.exp (-x ^ 2) * r x := by
  intro x hx
  have hGd : ∀ y, a ≤ y → HasDerivAt (fun y => I y + Real.exp (-y ^ 2) * r y)
      (Real.exp (-y ^ 2) * (1 + r' y - 2 * y * r y)) y := by
    intro y hy
    have h := (I_hasDerivAt y).add ((hasDerivAt_gauss y).mul (hd y hy))
    exact h.congr_deriv (by ring)
  have hanti : AntitoneOn (fun y => I y + Real.exp (-y ^ 2) * r y) (Ici a) := by
    refine antitoneOn_of_hasDerivWithinAt_nonpos
      (f' := fun y => Real.exp (-y ^ 2) * (1 + r' y - 2 * y * r y)) (convex_Ici a) ?_ ?_ ?_
    · intro y hy; exact (hGd y hy).continuousAt.continuousWithinAt
    · intro y hy; rw [interior_Ici] at hy; exact (hGd y (le_of_lt hy)).hasDerivWithinAt
    · intro y hy; rw [interior_Ici] at hy
      have h1 := hres y (le_of_lt hy)
      have he := Real.exp_pos (-y ^ 2)
      nlinarith
  have hlim : ∀ᶠ T in atTop, I T ≤ I x + Real.exp (-x ^ 2) * r x := by
    filter_upwards [eventually_ge_atTop x] with T hT
    have h1 := hanti (show x ∈ Ici a from hx) (show T ∈ Ici a from le_trans hx hT) hT
    have h2 : 0 ≤ Real.exp (-T ^ 2) * r T :=
      mul_nonneg (Real.exp_pos _).le (hpos T (le_trans hx hT))
    simp only at h1
    linarith
  exact le_of_tendsto I_tendsto hlim

lemma cf_lower (r r' : ℝ → ℝ) (a : ℝ)
    (hd : ∀ x, a ≤ x → HasDerivAt r (r' x) x)
    (hres : ∀ x, a ≤ x → 2 * x * r x - r' x ≤ 1)
    (hpos : ∀ x, a ≤ x → 0 ≤ r x) (hbd : ∀ x, a ≤ x → r x ≤ x⁻¹) :
    ∀ x, a ≤ x → I x + Real.exp (-x ^ 2) * r x ≤ √π / 2 := by
  intro x hx
  have hGd : ∀ y, a ≤ y → HasDerivAt (fun y => I y + Real.exp (-y ^ 2) * r y)
      (Real.exp (-y ^ 2) * (1 + r' y - 2 * y * r y)) y := by
    intro y hy
    have h := (I_hasDerivAt y).add ((hasDerivAt_gauss y).mul (hd y hy))
    exact h.congr_deriv (by ring)
  have hmono : MonotoneOn (fun y => I y + Real.exp (-y ^ 2) * r y) (Ici a) := by
    refine monotoneOn_of_hasDerivWithinAt_nonneg
      (f' := fun y => Real.exp (-y ^ 2) * (1 + r' y - 2 * y * r y)) (convex_Ici a) ?_ ?_ ?_
    · intro y hy; exact (hGd y hy).continuousAt.continuousWithinAt
    · intro y hy; rw [interior_Ici] at hy; exact (hGd y (le_of_lt hy)).hasDerivWithinAt
    · intro y hy; rw [interior_Ici] at hy
      have h1 := hres y (le_of_lt hy)
      have he := Real.exp_pos (-y ^ 2)
      nlinarith
  have hlim : ∀ᶠ T in atTop, I x + Real.exp (-x ^ 2) * r x ≤ I T + T⁻¹ := by
    filter_upwards [eventually_ge_atTop x] with T hT
    have h1 := hmono (show x ∈ Ici a from hx) (show T ∈ Ici a from le_trans hx hT) hT
    have h2 : Real.exp (-T ^ 2) * r T ≤ T⁻¹ := by
      have h5 := hbd T (le_trans hx hT)
      have h3 : Real.exp (-T ^ 2) ≤ 1 := Real.exp_le_one_iff.mpr (neg_nonpos.mpr (sq_nonneg T))
      have h4 := hpos T (le_trans hx hT)
      calc Real.exp (-T ^ 2) * r T ≤ 1 * r T := mul_le_mul_of_nonneg_right h3 h4
        _ ≤ T⁻¹ := by linarith
    simp only at h1
    linarith
  have ht : Tendsto (fun T => I T + T⁻¹) atTop (𝓝 (√π / 2 + 0)) :=
    I_tendsto.add tendsto_inv_atTop_zero
  rw [add_zero] at ht
  exact ge_of_tendsto ht hlim

lemma taylor_pt (s : ℝ) (h0 : 0 ≤ s) (h : s ≤ 1) :
    1 - s^2 + s^4/2 - s^6/6 + s^8/24 - s^10/120 - 7 * s^12 / 4320 ≤ Real.exp (-s ^ 2) ∧
    Real.exp (-s ^ 2) ≤ 1 - s^2 + s^4/2 - s^6/6 + s^8/24 - s^10/120 + 7 * s^12 / 4320 := by
  have hx : |-s^2| ≤ 1 := by
    rw [abs_neg, abs_of_nonneg (sq_nonneg s)]; nlinarith
  have hb := Real.exp_bound hx (n := 6) (by norm_num)
  rw [abs_neg, abs_of_nonneg (sq_nonneg s)] at hb
  have hb2 := abs_le.mp hb
  simp only [Finset.sum_range_succ, Finset.sum_range_zero] at hb2
  norm_num [Nat.factorial] at hb2
  constructor <;> nlinarith [hb2.1, hb2.2]

lemma I_taylor (X : ℝ) (h0 : 0 ≤ X) (h1 : X ≤ 1) :
    (X - X^3/3 + X^5/10 - X^7/42 + X^9/216 - X^11/1320) - 7 * X^13 / 56160 ≤ I X ∧
    I X ≤ (X - X^3/3 + X^5/10 - X^7/42 + X^9/216 - X^11/1320) + 7 * X^13 / 56160 := by
  have hdL : ∀ x : ℝ, HasDerivAt (fun s : ℝ => 1 * s^1 + (-1/3) * s^3 + (1/10) * s^5 + (-1/42) * s^7 + (1/216) * s^9 + (-1/1320) * s^11 + (-7/56160) * s^13)
      (1 - x^2 + x^4/2 - x^6/6 + x^8/24 - x^10/120 - 7 * x^12 / 4320) x := by
    intro x
    have h := ((((((hdm 1 1 x).add (hdm (-1/3) 3 x)).add (hdm (1/10) 5 x)).add (hdm (-1/42) 7 x)).add
      (hdm (1/216) 9 x)).add (hdm (-1/1320) 11 x)).add (hdm (-7/56160) 13 x)
    exact h.congr_deriv (show _ = 1 - x^2 + x^4/2 - x^6/6 + x^8/24 - x^10/120 - 7 * x^12 / 4320 by norm_num; ring)
  have hdU : ∀ x : ℝ, HasDerivAt (fun s : ℝ => 1 * s^1 + (-1/3) * s^3 + (1/10) * s^5 + (-1/42) * s^7 + (1/216) * s^9 + (-1/1320) * s^11 + (7/56160) * s^13)
      (1 - x^2 + x^4/2 - x^6/6 + x^8/24 - x^10/120 + 7 * x^12 / 4320) x := by
    intro x
    have h := ((((((hdm 1 1 x).add (hdm (-1/3) 3 x)).add (hdm (1/10) 5 x)).add (hdm (-1/42) 7 x)).add
      (hdm (1/216) 9 x)).add (hdm (-1/1320) 11 x)).add (hdm (7/56160) 13 x)
    exact h.congr_deriv (show _ = 1 - x^2 + x^4/2 - x^6/6 + x^8/24 - x^10/120 + 7 * x^12 / 4320 by norm_num; ring)
  have cL : Continuous (fun x : ℝ => 1 - x^2 + x^4/2 - x^6/6 + x^8/24 - x^10/120 - 7 * x^12 / 4320) := by fun_prop
  have cU : Continuous (fun x : ℝ => 1 - x^2 + x^4/2 - x^6/6 + x^8/24 - x^10/120 + 7 * x^12 / 4320) := by fun_prop
  have iL := intervalIntegral.integral_eq_sub_of_hasDerivAt (a := 0) (b := X) (fun x _ => hdL x)
    (cL.intervalIntegrable _ _)
  have iU := intervalIntegral.integral_eq_sub_of_hasDerivAt (a := 0) (b := X) (fun x _ => hdU x)
    (cU.intervalIntegrable _ _)
  constructor
  · have hm := intervalIntegral.integral_mono_on (μ := volume) h0 (cL.intervalIntegrable _ _)
      (contg.intervalIntegrable 0 X)
      (fun s hs => (taylor_pt s hs.1 (le_trans hs.2 h1)).1)
    rw [iL] at hm
    unfold I
    norm_num at hm ⊢
    linarith
  · have hm := intervalIntegral.integral_mono_on (μ := volume) h0
      (contg.intervalIntegrable 0 X) (cU.intervalIntegrable _ _)
      (fun s hs => (taylor_pt s hs.1 (le_trans hs.2 h1)).2)
    rw [iU] at hm
    unfold I
    norm_num at hm ⊢
    linarith

lemma kk_bounds : 1.128379 ≤ kk ∧ kk ≤ 1.12838 := by
  have hs : 0 < Real.sqrt π := Real.sqrt_pos.mpr Real.pi_pos
  have hsq : Real.sqrt π ^ 2 = π := Real.sq_sqrt Real.pi_pos.le
  have p1 := Real.pi_gt_d6
  have p2 := Real.pi_lt_d6
  unfold kk
  constructor
  · rw [le_div_iff₀ hs]; nlinarith
  · rw [div_le_iff₀ hs]; nlinarith

lemma kk_pos : 0 < kk := by linarith [kk_bounds.1]

lemma kk_mul : kk * (√π / 2) = 1 := by
  have hs : 0 < Real.sqrt π := Real.sqrt_pos.mpr Real.pi_pos
  unfold kk; field_simp

lemma B7_pos (x : ℝ) (hx : 1 ≤ x) : 0 < B7 x := by
  unfold B7
  have h0 : 0 < x := by linarith
  have := pow_pos h0 7; have := pow_pos h0 5; have := pow_pos h0 3
  linarith

lemma B8_pos (x : ℝ) : 0 < B8 x := by
  unfold B8; positivity

lemma A7_nonneg (x : ℝ) : 0 ≤ A7 x := by
  unfold A7; positivity

lemma A8_nonneg (x : ℝ) (hx : 1 ≤ x) : 0 ≤ A8 x := by
  unfold A8
  have h0 : 0 < x := by linarith
  have := pow_pos h0 7; have := pow_pos h0 5; have := pow_pos h0 3
  linarith

lemma erf_ge_cf7 (X : ℝ) (hX : 1 ≤ X) : 1 - kk * Real.exp (-X ^ 2) * (A7 X / B7 X) ≤ kk * I X := by
  have h := cf_upper (fun x => A7 x / B7 x)
    (fun x => ((384*x^5+2560*x^3+2784*x) * B7 x - A7 x * (896*x^6+6720*x^4+10080*x^2+1680)) / (B7 x)^2) 1
    (fun x hx => (hA7 x).div (hB7 x) (B7_pos x hx).ne')
    (by
      intro x hx
      have hB := B7_pos x hx
      have key : 2*x*A7 x*B7 x - (384*x^5+2560*x^3+2784*x)*B7 x + A7 x*(896*x^6+6720*x^4+10080*x^2+1680) - B7 x^2 = 645120 := by
        unfold A7 B7; ring
      have e : 2 * x * (A7 x / B7 x) - ((384*x^5+2560*x^3+2784*x) * B7 x - A7 x * (896*x^6+6720*x^4+10080*x^2+1680)) / (B7 x)^2
          = 1 + (2*x*A7 x*B7 x - (384*x^5+2560*x^3+2784*x)*B7 x + A7 x*(896*x^6+6720*x^4+10080*x^2+1680) - B7 x^2) / (B7 x)^2 := by
        field_simp; ring
      rw [e, key]
      have : 0 ≤ 645120 / (B7 x)^2 := by positivity
      linarith)
    (fun x hx => div_nonneg (A7_nonneg x) (B7_pos x hx).le) X hX
  have hk := kk_mul
  have kp := kk_pos
  have := mul_le_mul_of_nonneg_left h kp.le
  nlinarith

lemma erf_le_cf8 (X : ℝ) (hX : 1 ≤ X) : kk * I X ≤ 1 - kk * Real.exp (-X ^ 2) * (A8 X / B8 X) := by
  have h := cf_lower (fun x => A8 x / B8 x)
    (fun x => ((896*x^6+8640*x^4+17760*x^2+4464) * B8 x - A8 x * (2048*x^7+21504*x^5+53760*x^3+26880*x)) / (B8 x)^2) 1
    (fun x _ => (hA8 x).div (hB8 x) (B8_pos x).ne')
    (by
      intro x hx
      have hB := B8_pos x
      have key : 2*x*A8 x*B8 x - (896*x^6+8640*x^4+17760*x^2+4464)*B8 x + A8 x*(2048*x^7+21504*x^5+53760*x^3+26880*x) - B8 x^2 = -10321920 := by
        unfold A8 B8; ring
      have e : 2 * x * (A8 x / B8 x) - ((896*x^6+8640*x^4+17760*x^2+4464) * B8 x - A8 x * (2048*x^7+21504*x^5+53760*x^3+26880*x)) / (B8 x)^2
          = 1 + (2*x*A8 x*B8 x - (896*x^6+8640*x^4+17760*x^2+4464)*B8 x + A8 x*(2048*x^7+21504*x^5+53760*x^3+26880*x) - B8 x^2) / (B8 x)^2 := by
        field_simp; ring
      rw [e, key]
      have : 0 ≤ 10321920 / (B8 x)^2 := by positivity
      have e2 : (-10321920:ℝ) / (B8 x)^2 = -(10321920 / (B8 x)^2) := by ring
      rw [e2]
      linarith)
    (fun x hx => div_nonneg (A8_nonneg x hx) (B8_pos x).le)
    (by
      intro x hx
      have hB := B8_pos x
      have hx0 : 0 < x := by linarith
      show A8 x / B8 x ≤ x⁻¹
      rw [div_le_iff₀ hB, inv_mul_eq_div, le_div_iff₀ hx0]
      unfold A8 B8
      have := pow_pos hx0 8; have := pow_pos hx0 6; have := pow_pos hx0 4; have := pow_pos hx0 2
      nlinarith)
    X hX
  have hk := kk_mul
  have kp := kk_pos
  have := mul_le_mul_of_nonneg_left h kp.le
  nlinarith

/-! exponential helpers -/

lemma exp_tangent (y y0 : ℝ) : Real.exp y0 * (1 + y - y0) ≤ Real.exp y := by
  have h := Real.add_one_le_exp (y - y0)
  have h2 : Real.exp y = Real.exp y0 * Real.exp (y - y0) := by rw [← Real.exp_add]; ring_nf
  rw [h2]
  have := Real.exp_pos y0
  nlinarith

lemma exp_chord (wl wu w : ℝ) (h1 : wl ≤ w) (h2 : w ≤ wu) (h3 : wl < wu) :
    Real.exp w * (wu - wl) ≤ (wu - w) * Real.exp wl + (w - wl) * Real.exp wu := by
  have hne : wu - wl ≠ 0 := by linarith
  have hpos : 0 < wu - wl := by linarith
  have ha : (0:ℝ) ≤ (wu - w) / (wu - wl) := div_nonneg (by linarith) hpos.le
  have hb : (0:ℝ) ≤ (w - wl) / (wu - wl) := div_nonneg (by linarith) hpos.le
  have hab : (wu - w) / (wu - wl) + (w - wl) / (wu - wl) = 1 := by
    rw [← add_div, div_eq_one_iff_eq hne]; ring
  have hc := convexOn_exp.2 (Set.mem_univ wl) (Set.mem_univ wu) ha hb hab
  simp only [smul_eq_mul] at hc
  have e : (wu - w) / (wu - wl) * wl + (w - wl) / (wu - wl) * wu = w := by
    rw [div_mul_eq_mul_div, div_mul_eq_mul_div, ← add_div, div_eq_iff hne]; ring
  rw [e] at hc
  have := mul_le_mul_of_nonneg_right hc hpos.le
  calc Real.exp w * (wu - wl)
      ≤ ((wu - w) / (wu - wl) * Real.exp wl + (w - wl) / (wu - wl) * Real.exp wu) * (wu - wl) := this
    _ = (wu - w) * Real.exp wl + (w - wl) * Real.exp wu := by
      field_simp

lemma exp_neg_le (c B : ℝ) (n : ℕ) (hc : 0 ≤ c)
    (h : 1 ≤ B * ∑ i ∈ Finset.range n, c ^ i / (Nat.factorial i : ℝ)) : Real.exp (-c) ≤ B := by
  have h1 := Real.sum_le_exp_of_nonneg hc n
  have h2 : Real.exp (-c) * Real.exp c = 1 := by rw [← Real.exp_add]; simp
  have h3 := Real.exp_pos (-c)
  have hS : 0 ≤ ∑ i ∈ Finset.range n, c ^ i / (Nat.factorial i : ℝ) :=
    Finset.sum_nonneg (fun i _ => by positivity)
  have hB : 0 ≤ B := by
    by_contra hneg
    have := lt_of_not_ge hneg
    nlinarith
  have h4 : 1 ≤ B * Real.exp c := le_trans h (mul_le_mul_of_nonneg_left h1 hB)
  calc Real.exp (-c) = Real.exp (-c) * 1 := by ring
    _ ≤ Real.exp (-c) * (B * Real.exp c) := mul_le_mul_of_nonneg_left h4 h3.le
    _ = B * (Real.exp (-c) * Real.exp c) := by ring
    _ = B := by rw [h2, mul_one]

lemma exp_neg_ge_of (c U B : ℝ) (hU : Real.exp c ≤ U) (hB : 0 ≤ B) (h : B * U ≤ 1) :
    B ≤ Real.exp (-c) := by
  have h2 : Real.exp (-c) * Real.exp c = 1 := by rw [← Real.exp_add]; simp
  by_contra hc
  have hc' := lt_of_not_ge hc
  have : Real.exp (-c) * Real.exp c < B * U := by
    calc Real.exp (-c) * Real.exp c < B * Real.exp c := mul_lt_mul_of_pos_right hc' (Real.exp_pos c)
      _ ≤ B * U := mul_le_mul_of_nonneg_left hU hB
  linarith

lemma exp_ge_sum (c B : ℝ) (n : ℕ) (hc : 0 ≤ c)
    (h : B ≤ ∑ i ∈ Finset.range n, c ^ i / (Nat.factorial i : ℝ)) : B ≤ Real.exp c :=
  le_trans h (Real.sum_le_exp_of_nonneg hc n)

lemma eA1 : (2.7182818283:ℝ) ≤ Real.exp 1 := Real.exp_one_gt_d9.le
lemma eA2 : (4.22:ℝ) ≤ Real.exp 1.44 :=
  exp_ge_sum 1.44 4.22 14 (by norm_num) (by norm_num [Finset.sum_range_succ, Nat.factorial])
lemma eA3 : (9.48:ℝ) ≤ Real.exp 2.25 :=
  exp_ge_sum 2.25 9.48 16 (by norm_num) (by norm_num [Finset.sum_range_succ, Nat.factorial])
lemma eA4 : (36.9:ℝ) ≤ Real.exp 3.61 :=
  exp_ge_sum 3.61 36.9 20 (by norm_num) (by norm_num [Finset.sum_range_succ, Nat.factorial])
lemma eL1 : (400:ℝ) ≤ Real.exp 6.25 :=
  exp_ge_sum 6.25 400 22 (by norm_num) (by norm_num [Finset.sum_range_succ, Nat.factorial])
lemma eL2 : (1900:ℝ) ≤ Real.exp 7.6 :=
  exp_ge_sum 7.6 1900 26 (by norm_num) (by norm_num [Finset.sum_range_succ, Nat.factorial])

lemma eU1l : Real.exp (-0.975) ≤ 0.3773 :=
  exp_neg_le 0.975 0.3773 12 (by norm_num) (by norm_num [Finset.sum_range_succ, Nat.factorial])
lemma eU1u : Real.exp (-0.845) ≤ 0.4296 :=
  exp_neg_le 0.845 0.4296 12 (by norm_num) (by norm_num [Finset.sum_range_succ, Nat.factorial])
lemma eU2l : Real.exp (-1.14) ≤ 0.3199 :=
  exp_neg_le 1.14 0.3199 12 (by norm_num) (by norm_num [Finset.sum_range_succ, Nat.factorial])
lemma eU2u : Real.exp (-0.965) ≤ 0.3810 :=
  exp_neg_le 0.965 0.3810 12 (by norm_num) (by norm_num [Finset.sum_range_succ, Nat.factorial])
lemma eU3l : Real.exp (-1.33) ≤ 0.2645 :=
  exp_neg_le 1.33 0.2645 12 (by norm_num) (by norm_num [Finset.sum_range_succ, Nat.factorial])
lemma eU3u : Real.exp (-1.13) ≤ 0.3231 :=
  exp_neg_le 1.13 0.3231 12 (by norm_num) (by norm_num [Finset.sum_range_succ, Nat.factorial])
lemma eU4l : Real.exp (-1.56) ≤ 0.2102 :=
  exp_neg_le 1.56 0.2102 12 (by norm_num) (by norm_num [Finset.sum_range_succ, Nat.factorial])
lemma eU4u : Real.exp (-1.315) ≤ 0.2685 :=
  exp_neg_le 1.315 0.2685 12 (by norm_num) (by norm_num [Finset.sum_range_succ, Nat.factorial])

lemma eT1 : (0.4106:ℝ) ≤ Real.exp (-0.89) := by
  have hU : Real.exp 0.89 ≤ 2.43516 := by
    have := Real.exp_bound' (x := (0.89:ℝ)) (by norm_num) (by norm_num) (n := 10) (by norm_num)
    norm_num [Finset.sum_range_succ, Nat.factorial] at this ⊢
    linarith
  exact exp_neg_ge_of 0.89 2.43516 0.4106 hU (by norm_num) (by norm_num)

lemma eT2 : (0.3569:ℝ) ≤ Real.exp (-1.03) := by
  have h3 : Real.exp 0.03 ≤ 1.0304546 := by
    have := Real.exp_bound' (x := (0.03:ℝ)) (by norm_num) (by norm_num) (n := 8) (by norm_num)
    norm_num [Finset.sum_range_succ, Nat.factorial] at this ⊢
    linarith
  have hU : Real.exp 1.03 ≤ 2.8011 := by
    have e : Real.exp 1.03 = Real.exp 0.03 * Real.exp 1 := by rw [← Real.exp_add]; norm_num
    rw [e]
    calc Real.exp 0.03 * Real.exp 1 ≤ 1.0304546 * 2.7182818286 :=
          mul_le_mul h3 Real.exp_one_lt_d9.le (Real.exp_pos _).le (by norm_num)
      _ ≤ 2.8011 := by norm_num
  exact exp_neg_ge_of 1.03 2.8011 0.3569 hU (by norm_num) (by norm_num)

lemma eT3 : (0.2922:ℝ) ≤ Real.exp (-1.23) := by
  have h3 : Real.exp 0.23 ≤ 1.2586001 := by
    have := Real.exp_bound' (x := (0.23:ℝ)) (by norm_num) (by norm_num) (n := 10) (by norm_num)
    norm_num [Finset.sum_range_succ, Nat.factorial] at this ⊢
    linarith
  have hU : Real.exp 1.23 ≤ 3.4213 := by
    have e : Real.exp 1.23 = Real.exp 0.23 * Real.exp 1 := by rw [← Real.exp_add]; norm_num
    rw [e]
    calc Real.exp 0.23 * Real.exp 1 ≤ 1.2586001 * 2.7182818286 :=
          mul_le_mul h3 Real.exp_one_lt_d9.le (Real.exp_pos _).le (by norm_num)
      _ ≤ 3.4213 := by norm_num
  exact exp_neg_ge_of 1.23 3.4213 0.2922 hU (by norm_num) (by norm_num)

lemma eT4 : (0.2369:ℝ) ≤ Real.exp (-1.44) := by
  have h3 : Real.exp 0.44 ≤ 1.5527073 := by
    have := Real.exp_bound' (x := (0.44:ℝ)) (by norm_num) (by norm_num) (n := 12) (by norm_num)
    norm_num [Finset.sum_range_succ, Nat.factorial] at this ⊢
    linarith
  have hU : Real.exp 1.44 ≤ 4.2207 := by
    have e : Real.exp 1.44 = Real.exp 0.44 * Real.exp 1 := by rw [← Real.exp_add]; norm_num
    rw [e]
    calc Real.exp 0.44 * Real.exp 1 ≤ 1.5527073 * 2.7182818286 :=
          mul_le_mul h3 Real.exp_one_lt_d9.le (Real.exp_pos _).le (by norm_num)
      _ ≤ 4.2207 := by norm_num
  exact exp_neg_ge_of 1.44 4.2207 0.2369 hU (by norm_num) (by norm_num)

/-! polynomial certificates -/

lemma pS1a (X : ℝ) (h0 : 0 ≤ X) (h1 : X ≤ 1) :
    X * (Ps X - 1.128379 * ((X - X^3/3 + X^5/10 - X^7/42 + X^9/216 - X^11/1320) - 7 * X^13 / 56160))
      ≤ 2 * (11863283 / 2 ^ 24) * 0.0009999 := by
  have a : 0 ≤ X^2 := by positivity
  have b : 0 ≤ 1 - X^2 := by nlinarith
  unfold Ps
  linarith [bern a b 0 8, bern a b 1 7, bern a b 2 6, bern a b 3 5, bern a b 4 4,
    bern a b 5 3, bern a b 6 2, bern a b 7 1, bern a b 8 0]

lemma pS1b (X : ℝ) (h0 : 0 ≤ X) (h1 : X ≤ 1) :
    X * (1.12838 * ((X - X^3/3 + X^5/10 - X^7/42 + X^9/216 - X^11/1320) + 7 * X^13 / 56160) - Ps X)
      ≤ 2 * (11863283 / 2 ^ 24) * 0.0009999 := by
  have a : 0 ≤ X^2 := by positivity
  have b : 0 ≤ 1 - X^2 := by nlinarith
  unfold Ps
  linarith [bern a b 0 8, bern a b 1 7, bern a b 2 6, bern a b 3 5, bern a b 4 4,
    bern a b 5 3, bern a b 6 2, bern a b 7 1, bern a b 8 0]

lemma pS2a (X : ℝ) (h1 : 1 ≤ X) (h2 : X ≤ 1.0029599666595458984375) :
    X * (Ps X - 1.128379 * (((1 - 1^3/3 + 1^5/10 - 1^7/42 + 1^9/216 - 1^11/1320) - 7 * 1^13 / 56160)
      + (X - 1) * (0.36787944116 * (2 - X^2)))) ≤ 2 * (11863283 / 2 ^ 24) * 0.0009999 := by
  have a : 0 ≤ X - 1 := by linarith
  have b : 0 ≤ 1.0029599666595458984375 - X := by linarith
  unfold Ps
  linarith [bern a b 0 14, bern a b 1 13, bern a b 2 12, bern a b 3 11, bern a b 4 10,
    bern a b 5 9, bern a b 6 8, bern a b 7 7, bern a b 8 6, bern a b 9 5, bern a b 10 4,
    bern a b 11 3, bern a b 12 2, bern a b 13 1, bern a b 14 0]

lemma pS2b (X : ℝ) (h1 : 1 ≤ X) (h2 : X ≤ 1.0029599666595458984375) :
    X * (1.12838 * (((1 - 1^3/3 + 1^5/10 - 1^7/42 + 1^9/216 - 1^11/1320) + 7 * 1^13 / 56160)
      + (X - 1) * 0.3678794412) - Ps X) ≤ 2 * (11863283 / 2 ^ 24) * 0.0009999 := by
  have a : 0 ≤ X - 1 := by linarith
  have b : 0 ≤ 1.0029599666595458984375 - X := by linarith
  unfold Ps
  linarith [bern a b 0 14, bern a b 1 13, bern a b 2 12, bern a b 3 11, bern a b 4 10,
    bern a b 5 9, bern a b 6 8, bern a b 7 7, bern a b 8 6, bern a b 9 5, bern a b 10 4,
    bern a b 11 3, bern a b 12 2, bern a b 13 1, bern a b 14 0]

lemma pW1 (X : ℝ) (h1 : 1 ≤ X) (h2 : X ≤ 1.2) : -0.975 ≤ WW X ∧ WW X ≤ -0.845 := by
  have a : 0 ≤ X - 1 := by linarith
  have b : 0 ≤ 1.2 - X := by linarith
  unfold WW PL cc
  constructor <;> linarith [bern a b 0 8, bern a b 1 7, bern a b 2 6, bern a b 3 5, bern a b 4 4,
    bern a b 5 3, bern a b 6 2, bern a b 7 1, bern a b 8 0]

lemma pW2 (X : ℝ) (h1 : 1.2 ≤ X) (h2 : X ≤ 1.5) : -1.14 ≤ WW X ∧ WW X ≤ -0.965 := by
  have a : 0 ≤ X - 1.2 := by linarith
  have b : 0 ≤ 1.5 - X := by linarith
  unfold WW PL cc
  constructor <;> linarith [bern a b 0 8, bern a b 1 7, bern a b 2 6, bern a b 3 5, bern a b 4 4,
    bern a b 5 3, bern a b 6 2, bern a b 7 1, bern a b 8 0]

lemma pW3 (X : ℝ) (h1 : 1.5 ≤ X) (h2 : X ≤ 1.9) : -1.33 ≤ WW X ∧ WW X ≤ -1.13 := by
  have a : 0 ≤ X - 1.5 := by linarith
  have b : 0 ≤ 1.9 - X := by linarith
  unfold WW PL cc
  constructor <;> linarith [bern a b 0 8, bern a b 1 7, bern a b 2 6, bern a b 3 5, bern a b 4 4,
    bern a b 5 3, bern a b 6 2, bern a b 7 1, bern a b 8 0]

lemma pW4 (X : ℝ) (h1 : 1.9 ≤ X) (h2 : X ≤ 2.5) : -1.56 ≤ WW X ∧ WW X ≤ -1.315 := by
  have a : 0 ≤ X - 1.9 := by linarith
  have b : 0 ≤ 2.5 - X := by linarith
  unfold WW PL cc
  constructor <;> linarith [bern a b 0 8, bern a b 1 7, bern a b 2 6, bern a b 3 5, bern a b 4 4,
    bern a b 5 3, bern a b 6 2, bern a b 7 1, bern a b 8 0]

lemma pM1u (X : ℝ) (h1 : 1 ≤ X) (h2 : X ≤ 1.2) :
    X * (1.12838 * A7 X - 0.4106 * (1 + WW X - -0.89) * B7 X) ≤
      2 * (11863283 / 2 ^ 24) * 0.0009999 * 2.7182818283 * (1 + X ^ 2 - 1) * B7 X := by
  have a : 0 ≤ X - 1 := by linarith
  have b : 0 ≤ 1.2 - X := by linarith
  unfold WW PL cc A7 B7
  linarith [bern a b 0 16, bern a b 1 15, bern a b 2 14, bern a b 3 13, bern a b 4 12,
    bern a b 5 11, bern a b 6 10, bern a b 7 9, bern a b 8 8, bern a b 9 7, bern a b 10 6,
    bern a b 11 5, bern a b 12 4, bern a b 13 3, bern a b 14 2, bern a b 15 1, bern a b 16 0]

lemma pM1l (X : ℝ) (h1 : 1 ≤ X) (h2 : X ≤ 1.2) :
    X * ((0.3773 * (-0.845 - WW X) + 0.4296 * (WW X - -0.975)) * B8 X - 0.13 * 1.128379 * A8 X) ≤
      0.13 * (2 * (11863283 / 2 ^ 24) * 0.0009999 * 2.7182818283 * (1 + X ^ 2 - 1) * B8 X) := by
  have a : 0 ≤ X - 1 := by linarith
  have b : 0 ≤ 1.2 - X := by linarith
  unfold WW PL cc A8 B8
  linarith [bern a b 0 16, bern a b 1 15, bern a b 2 14, bern a b 3 13, bern a b 4 12,
    bern a b 5 11, bern a b 6 10, bern a b 7 9, bern a b 8 8, bern a b 9 7, bern a b 10 6,
    bern a b 11 5, bern a b 12 4, bern a b 13 3, bern a b 14 2, bern a b 15 1, bern a b 16 0]

lemma pM2u (X : ℝ) (h1 : 1.2 ≤ X) (h2 : X ≤ 1.5) :
    X * (1.12838 * A7 X - 0.3569 * (1 + WW X - -1.03) * B7 X) ≤
      2 * (11863283 / 2 ^ 24) * 0.0009999 * 4.22 * (1 + X ^ 2 - 1.44) * B7 X := by
  have a : 0 ≤ X - 1.2 := by linarith
  have b : 0 ≤ 1.5 - X := by linarith
  unfold WW PL cc A7 B7
  linarith [bern a b 0 16, bern a b 1 15, bern a b 2 14, bern a b 3 13, bern a b 4 12,
    bern a b 5 11, bern a b 6 10, bern a b 7 9, bern a b 8 8, bern a b 9 7, bern a b 10 6,
    bern a b 11 5, bern a b 12 4, bern a b 13 3, bern a b 14 2, bern a b 15 1, bern a b 16 0]

lemma pM2l (X : ℝ) (h1 : 1.2 ≤ X) (h2 : X ≤ 1.5) :
    X * ((0.3199 * (-0.965 - WW X) + 0.3810 * (WW X - -1.14)) * B8 X - 0.175 * 1.128379 * A8 X) ≤
      0.175 * (2 * (11863283 / 2 ^ 24) * 0.0009999 * 4.22 * (1 + X ^ 2 - 1.44) * B8 X) := by
  have a : 0 ≤ X - 1.2 := by linarith
  have b : 0 ≤ 1.5 - X := by linarith
  unfold WW PL cc A8 B8
  linarith [bern a b 0 16, bern a b 1 15, bern a b 2 14, bern a b 3 13, bern a b 4 12,
    bern a b 5 11, bern a b 6 10, bern a b 7 9, bern a b 8 8, bern a b 9 7, bern a b 10 6,
    bern a b 11 5, bern a b 12 4, bern a b 13 3, bern a b 14 2, bern a b 15 1, bern a b 16 0]

lemma pM3u (X : ℝ) (h1 : 1.5 ≤ X) (h2 : X ≤ 1.9) :
    X * (1.12838 * A7 X - 0.2922 * (1 + WW X - -1.23) * B7 X) ≤
      2 * (11863283 / 2 ^ 24) * 0.0009999 * 9.48 * (1 + X ^ 2 - 2.25) * B7 X := by
  have a : 0 ≤ X - 1.5 := by linarith
  have b : 0 ≤ 1.9 - X := by linarith
  unfold WW PL cc A7 B7
  linarith [bern a b 0 16, bern a b 1 15, bern a b 2 14, bern a b 3 13, bern a b 4 12,
    bern a b 5 11, bern a b 6 10, bern a b 7 9, bern a b 8 8, bern a b 9 7, bern a b 10 6,
    bern a b 11 5, bern a b 12 4, bern a b 13 3, bern a b 14 2, bern a b 15 1, bern a b 16 0]

lemma pM3l (X : ℝ) (h1 : 1.5 ≤ X) (h2 : X ≤ 1.9) :
    X * ((0.2645 * (-1.13 - WW X) + 0.3231 * (WW X - -1.33)) * B8 X - 0.2 * 1.128379 * A8 X) ≤
      0.2 * (2 * (11863283 / 2 ^ 24) * 0.0009999 * 9.48 * (1 + X ^ 2 - 2.25) * B8 X) := by
  have a : 0 ≤ X - 1.5 := by linarith
  have b : 0 ≤ 1.9 - X := by linarith
  unfold WW PL cc A8 B8
  linarith [bern a b 0 16, bern a b 1 15, bern a b 2 14, bern a b 3 13, bern a b 4 12,
    bern a b 5 11, bern a b 6 10, bern a b 7 9, bern a b 8 8, bern a b 9 7, bern a b 10 6,
    bern a b 11 5, bern a b 12 4, bern a b 13 3, bern a b 14 2, bern a b 15 1, bern a b 16 0]

lemma pM4u (X : ℝ) (h1 : 1.9 ≤ X) (h2 : X ≤ 2.5) :
    X * (1.12838 * A7 X - 0.2369 * (1 + WW X - -1.44) * B7 X) ≤
      2 * (11863283 / 2 ^ 24) * 0.0009999 * 36.9 * (1 + X ^ 2 - 3.61) * B7 X := by
  have a : 0 ≤ X - 1.9 := by linarith
  have b : 0 ≤ 2.5 - X := by linarith
  unfold WW PL cc A7 B7
  linarith [bern a b 0 16, bern a b 1 15, bern a b 2 14, bern a b 3 13, bern a b 4 12,
    bern a b 5 11, bern a b 6 10, bern a b 7 9, bern a b 8 8, bern a b 9 7, bern a b 10 6,
    bern a b 11 5, bern a b 12 4, bern a b 13 3, bern a b 14 2, bern a b 15 1, bern a b 16 0]

lemma pM4l (X : ℝ) (h1 : 1.9 ≤ X) (h2 : X ≤ 2.5) :
    X * ((0.2102 * (-1.315 - WW X) + 0.2685 * (WW X - -1.56)) * B8 X - 0.245 * 1.128379 * A8 X) ≤
      0.245 * (2 * (11863283 / 2 ^ 24) * 0.0009999 * 36.9 * (1 + X ^ 2 - 3.61) * B8 X) := by
  have a : 0 ≤ X - 1.9 := by linarith
  have b : 0 ≤ 2.5 - X := by linarith
  unfold WW PL cc A8 B8
  linarith [bern a b 0 16, bern a b 1 15, bern a b 2 14, bern a b 3 13, bern a b 4 12,
    bern a b 5 11, bern a b 6 10, bern a b 7 9, bern a b 8 8, bern a b 9 7, bern a b 10 6,
    bern a b 11 5, bern a b 12 4, bern a b 13 3, bern a b 14 2, bern a b 15 1, bern a b 16 0]

lemma pL (X : ℝ) (h : 2.5 ≤ X) : X + 5.1 ≤ -(PL X * cc) := by
  obtain ⟨s, hs, rfl⟩ : ∃ s, 0 ≤ s ∧ X = 2.5 + s := ⟨X - 2.5, by linarith, by ring⟩
  unfold PL cc
  nlinarith [pow_nonneg hs 2, pow_nonneg hs 3, pow_nonneg hs 4, pow_nonneg hs 5, pow_nonneg hs 6, pow_nonneg hs 7]

/-! regions -/

lemma fin_bound (X P E lo hi C : ℝ) (hX : 0 ≤ X) (hlo : lo ≤ E) (hhi : E ≤ hi)
    (h1 : X * (P - lo) ≤ C) (h2 : X * (hi - P) ≤ C) : |X * (P - E)| ≤ C := by
  rw [abs_le]
  constructor
  · nlinarith [mul_le_mul_of_nonneg_left hhi hX]
  · nlinarith [mul_le_mul_of_nonneg_left hlo hX]

lemma regS1 (X : ℝ) (h0 : 0 ≤ X) (h1 : X ≤ 1) :
    |X * (Ps X - kk * I X)| ≤ 2 * (11863283 / 2 ^ 24) * 0.0009999 := by
  obtain ⟨t1, t2⟩ := I_taylor X h0 h1
  obtain ⟨kl, ku⟩ := kk_bounds
  have hI := I_nonneg X h0
  refine fin_bound X (Ps X) (kk * I X) _ _ _ h0 ?_ ?_ (pS1a X h0 h1) (pS1b X h0 h1)
  · nlinarith [mul_le_mul_of_nonneg_right kl hI]
  · nlinarith [mul_le_mul_of_nonneg_right ku hI]

lemma regS2 (X : ℝ) (h1 : 1 ≤ X) (h2 : X ≤ 1.0029599666595458984375) :
    |X * (Ps X - kk * I X)| ≤ 2 * (11863283 / 2 ^ 24) * 0.0009999 := by
  obtain ⟨t1, t2⟩ := I_taylor 1 (by norm_num) le_rfl
  obtain ⟨n1, n2⟩ := I_near1 X h1
  obtain ⟨kl, ku⟩ := kk_bounds
  have hI := I_nonneg X (by linarith)
  have hX1 : 0 ≤ X - 1 := by linarith
  have e1 : 0.36787944116 * (2 - X ^ 2) ≤ Real.exp (-X ^ 2) := by
    have t := exp_tangent (-X ^ 2) (-1)
    have h2X : 0 ≤ 2 - X ^ 2 := by nlinarith
    have := mul_le_mul_of_nonneg_right Real.exp_neg_one_gt_d9.le h2X
    linarith
  have e2 := Real.exp_neg_one_lt_d9
  refine fin_bound X (Ps X) (kk * I X) _ _ _ (by linarith) ?_ ?_ (pS2a X h1 h2) (pS2b X h1 h2)
  · have : ((1 - 1^3/3 + 1^5/10 - 1^7/42 + 1^9/216 - 1^11/1320) - 7 * 1^13 / 56160)
        + (X - 1) * (0.36787944116 * (2 - X^2)) ≤ I X := by
      nlinarith [mul_le_mul_of_nonneg_left e1 hX1]
    nlinarith [mul_le_mul_of_nonneg_right kl hI]
  · have : I X ≤ ((1 - 1^3/3 + 1^5/10 - 1^7/42 + 1^9/216 - 1^11/1320) + 7 * 1^13 / 56160)
        + (X - 1) * 0.3678794412 := by
      nlinarith [mul_le_mul_of_nonneg_left e2.le hX1]
    nlinarith [mul_le_mul_of_nonneg_right ku hI]

lemma regM_cell (X a2 Ea w1 Ew1 wl wu El Eu Δ : ℝ) (hX : 1 ≤ X)
    (hEa : Ea ≤ Real.exp a2) (_hEa0 : 0 < Ea) (ha2 : a2 ≤ X ^ 2)
    (hEw1 : Ew1 ≤ Real.exp w1) (_hEw0 : 0 ≤ Ew1) (hEl : Real.exp wl ≤ El) (hEu : Real.exp wu ≤ Eu)
    (hΔ : Δ = wu - wl) (hΔpos : 0 < Δ) (hw1 : 0 ≤ 1 + wl - w1)
    (hWl : wl ≤ WW X) (hWu : WW X ≤ wu)
    (pup : X * (1.12838 * A7 X - Ew1 * (1 + WW X - w1) * B7 X) ≤
      2 * (11863283 / 2 ^ 24) * 0.0009999 * Ea * (1 + X ^ 2 - a2) * B7 X)
    (plo : X * ((El * (wu - WW X) + Eu * (WW X - wl)) * B8 X - Δ * 1.128379 * A8 X) ≤
      Δ * (2 * (11863283 / 2 ^ 24) * 0.0009999 * Ea * (1 + X ^ 2 - a2) * B8 X)) :
    |X * ((1 - Real.exp (PL X * cc)) - kk * I X)| ≤ 2 * (11863283 / 2 ^ 24) * 0.0009999 := by
  have hC0 : (0:ℝ) < 2 * (11863283 / 2 ^ 24) * 0.0009999 := by norm_num
  obtain ⟨kl, ku⟩ := kk_bounds
  have h7 := erf_ge_cf7 X hX
  have h8 := erf_le_cf8 X hX
  have hB7 := B7_pos X hX
  have hB8 := B8_pos X
  have hX0 : 0 ≤ X := by linarith
  have hEp := Real.exp_pos (-X ^ 2)
  have hEX : Real.exp (-X ^ 2) * Real.exp (X ^ 2) = 1 := by rw [← Real.exp_add]; simp
  have hexp : Real.exp (PL X * cc) = Real.exp (WW X) * Real.exp (-X ^ 2) := by
    rw [← Real.exp_add]; congr 1; unfold WW; ring
  obtain ⟨m7, hm7d⟩ : ∃ m, m = A7 X / B7 X := ⟨_, rfl⟩
  obtain ⟨m8, hm8d⟩ : ∃ m, m = A8 X / B8 X := ⟨_, rfl⟩
  have m7nn : 0 ≤ m7 := by rw [hm7d]; exact div_nonneg (A7_nonneg X) hB7.le
  have m8nn : 0 ≤ m8 := by rw [hm8d]; exact div_nonneg (A8_nonneg X hX) hB8.le
  have hm7 : A7 X = m7 * B7 X := by rw [hm7d, div_mul_cancel₀ _ hB7.ne']
  have hm8 : A8 X = m8 * B8 X := by rw [hm8d, div_mul_cancel₀ _ hB8.ne']
  rw [← hm7d] at h7
  rw [← hm8d] at h8
  rw [hm7] at pup
  rw [hm8] at plo
  have tang : Ew1 * (1 + WW X - w1) ≤ Real.exp (WW X) := by
    have t := exp_tangent (WW X) w1
    have h0 : 0 ≤ 1 + WW X - w1 := by linarith
    have := mul_le_mul_of_nonneg_right hEw1 h0
    linarith
  have chord : Real.exp (WW X) * Δ ≤ El * (wu - WW X) + Eu * (WW X - wl) := by
    have cv := exp_chord wl wu (WW X) hWl hWu (by linarith)
    rw [hΔ]
    have c1 := mul_le_mul_of_nonneg_left hEl (show 0 ≤ wu - WW X by linarith)
    have c2 := mul_le_mul_of_nonneg_left hEu (show 0 ≤ WW X - wl by linarith)
    linarith
  have eX2 : Ea * (1 + X ^ 2 - a2) ≤ Real.exp (X ^ 2) := by
    have t := exp_tangent (X ^ 2) a2
    have := mul_le_mul_of_nonneg_right hEa (show 0 ≤ 1 + X ^ 2 - a2 by linarith)
    linarith
  have q1 : X * (1.12838 * m7 - Ew1 * (1 + WW X - w1)) ≤
      2 * (11863283 / 2 ^ 24) * 0.0009999 * Ea * (1 + X ^ 2 - a2) := by
    by_contra hc
    have hc' := lt_of_not_ge hc
    have := mul_lt_mul_of_pos_right hc' hB7
    linarith
  have q2 : X * ((El * (wu - WW X) + Eu * (WW X - wl)) - Δ * 1.128379 * m8) ≤
      Δ * (2 * (11863283 / 2 ^ 24) * 0.0009999 * Ea * (1 + X ^ 2 - a2)) := by
    by_contra hc
    have hc' := lt_of_not_ge hc
    have := mul_lt_mul_of_pos_right hc' hB8
    linarith
  have hCE : 2 * (11863283 / 2 ^ 24) * 0.0009999 * Ea * (1 + X ^ 2 - a2) ≤
      2 * (11863283 / 2 ^ 24) * 0.0009999 * Real.exp (X ^ 2) := by
    have := mul_le_mul_of_nonneg_left eX2 hC0.le
    linarith
  have hEC : Real.exp (-X ^ 2) * (2 * (11863283 / 2 ^ 24) * 0.0009999 * Real.exp (X ^ 2)) =
      2 * (11863283 / 2 ^ 24) * 0.0009999 := by
    linear_combination (2 * (11863283 / 2 ^ 24) * 0.0009999) * hEX
  rw [abs_le]
  constructor
  · have l1 : Real.exp (-X ^ 2) * (kk * m8 - Real.exp (WW X)) ≤
        (1 - Real.exp (PL X * cc)) - kk * I X := by
      rw [hexp]; linarith
    have l0 : Δ * (Real.exp (WW X) - kk * m8) ≤
        (El * (wu - WW X) + Eu * (WW X - wl)) - Δ * 1.128379 * m8 := by
      have := mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_right kl m8nn) hΔpos.le
      linarith
    have l2 : X * (Δ * (Real.exp (WW X) - kk * m8)) ≤
        Δ * (2 * (11863283 / 2 ^ 24) * 0.0009999 * Real.exp (X ^ 2)) := by
      have a1 := mul_le_mul_of_nonneg_left l0 hX0
      have a2 := mul_le_mul_of_nonneg_left hCE hΔpos.le
      linarith
    have l3 : X * (Real.exp (WW X) - kk * m8) ≤
        2 * (11863283 / 2 ^ 24) * 0.0009999 * Real.exp (X ^ 2) := by
      by_contra hc
      have hc' := lt_of_not_ge hc
      have := mul_lt_mul_of_pos_left hc' hΔpos
      linarith
    have l4 : X * (Real.exp (-X ^ 2) * (Real.exp (WW X) - kk * m8)) ≤
        2 * (11863283 / 2 ^ 24) * 0.0009999 := by
      have := mul_le_mul_of_nonneg_left l3 hEp.le
      linarith
    have := mul_le_mul_of_nonneg_left l1 hX0
    linarith
  · have u1 : (1 - Real.exp (PL X * cc)) - kk * I X ≤
        Real.exp (-X ^ 2) * (kk * m7 - Real.exp (WW X)) := by
      rw [hexp]; linarith
    have u0 : kk * m7 - Real.exp (WW X) ≤ 1.12838 * m7 - Ew1 * (1 + WW X - w1) := by
      have := mul_le_mul_of_nonneg_right ku m7nn
      linarith
    have u2 : X * (kk * m7 - Real.exp (WW X)) ≤
        2 * (11863283 / 2 ^ 24) * 0.0009999 * Real.exp (X ^ 2) := by
      have := mul_le_mul_of_nonneg_left u0 hX0
      linarith
    have u3 : X * (Real.exp (-X ^ 2) * (kk * m7 - Real.exp (WW X))) ≤
        2 * (11863283 / 2 ^ 24) * 0.0009999 := by
      have := mul_le_mul_of_nonneg_left u2 hEp.le
      linarith
    have := mul_le_mul_of_nonneg_left u1 hX0
    linarith

lemma regM (X : ℝ) (h1 : 1 ≤ X) (h2 : X ≤ 2.5) :
    |X * ((1 - Real.exp (PL X * cc)) - kk * I X)| ≤ 2 * (11863283 / 2 ^ 24) * 0.0009999 := by
  rcases le_or_gt X 1.2 with ha | ha
  · exact regM_cell X 1 2.7182818283 (-0.89) 0.4106 (-0.975) (-0.845) 0.3773 0.4296 0.13 h1
      eA1 (by norm_num) (by nlinarith) eT1 (by norm_num) eU1l eU1u (by norm_num) (by norm_num)
      (by norm_num) (pW1 X h1 ha).1 (pW1 X h1 ha).2 (pM1u X h1 ha) (pM1l X h1 ha)
  rcases le_or_gt X 1.5 with hb | hb
  · exact regM_cell X 1.44 4.22 (-1.03) 0.3569 (-1.14) (-0.965) 0.3199 0.3810 0.175 h1
      eA2 (by norm_num) (by nlinarith) eT2 (by norm_num) eU2l eU2u (by norm_num) (by norm_num)
      (by norm_num) (pW2 X ha.le hb).1 (pW2 X ha.le hb).2 (pM2u X ha.le hb) (pM2l X ha.le hb)
  rcases le_or_gt X 1.9 with hc | hc
  · exact regM_cell X 2.25 9.48 (-1.23) 0.2922 (-1.33) (-1.13) 0.2645 0.3231 0.2 h1
      eA3 (by norm_num) (by nlinarith) eT3 (by norm_num) eU3l eU3u (by norm_num) (by norm_num)
      (by norm_num) (pW3 X hb.le hc).1 (pW3 X hb.le hc).2 (pM3u X hb.le hc) (pM3l X hb.le hc)
  · exact regM_cell X 3.61 36.9 (-1.44) 0.2369 (-1.56) (-1.315) 0.2102 0.2685 0.245 h1
      eA4 (by norm_num) (by nlinarith) eT4 (by norm_num) eU4l eU4u (by norm_num) (by norm_num)
      (by norm_num) (pW4 X hc.le h2).1 (pW4 X hc.le h2).2 (pM4u X hc.le h2) (pM4l X hc.le h2)

lemma regL (X u : ℝ) (hX : 2.5 ≤ X) (hu : X ≤ u) :
    |X * ((1 - Real.exp (PL X * cc)) - kk * I u)| ≤ 2 * (11863283 / 2 ^ 24) * 0.001 := by
  have hz := pL X hX
  obtain ⟨kl, ku⟩ := kk_bounds
  have kp := kk_pos
  have hX0 : 0 ≤ X := by linarith
  have e1 : kk * I u ≤ 1 := by
    have h := erf_le_cf8 u (by linarith)
    have : 0 ≤ kk * Real.exp (-u ^ 2) * (A8 u / B8 u) :=
      mul_nonneg (mul_nonneg kp.le (Real.exp_pos _).le) (div_nonneg (A8_nonneg u (by linarith)) (B8_pos u).le)
    linarith
  have e2 : 1 - kk * Real.exp (-X ^ 2) * (A7 X / B7 X) ≤ kk * I u := by
    have h := erf_ge_cf7 X (by linarith)
    have := mul_le_mul_of_nonneg_left (I_mono X u hu).1 kp.le
    linarith
  have e3 : X * (kk * Real.exp (-X ^ 2) * (A7 X / B7 X)) ≤ 2 * (11863283 / 2 ^ 24) * 0.001 := by
    have hB := B7_pos X (by linarith)
    have hm : X * (A7 X / B7 X) ≤ 1 / 2 := by
      rw [← mul_div_assoc, div_le_iff₀ hB]
      unfold A7 B7
      have := pow_pos (show (0:ℝ) < X by linarith) 7
      have := pow_pos (show (0:ℝ) < X by linarith) 5
      have := pow_pos (show (0:ℝ) < X by linarith) 3
      nlinarith
    have hm0 : 0 ≤ X * (A7 X / B7 X) := mul_nonneg hX0 (div_nonneg (A7_nonneg X) hB.le)
    have hE0 := Real.exp_pos (-X ^ 2)
    have hE : Real.exp (-X ^ 2) ≤ 1 / 400 := by
      have h1 : (400:ℝ) ≤ Real.exp (X ^ 2) := le_trans eL1 (Real.exp_le_exp.mpr (by nlinarith))
      have h2 : Real.exp (-X ^ 2) * Real.exp (X ^ 2) = 1 := by rw [← Real.exp_add]; simp
      have := mul_le_mul_of_nonneg_left h1 hE0.le
      linarith
    calc X * (kk * Real.exp (-X ^ 2) * (A7 X / B7 X))
        = kk * Real.exp (-X ^ 2) * (X * (A7 X / B7 X)) := by ring
      _ ≤ 1.12838 * (1 / 400) * (1 / 2) :=
        mul_le_mul (mul_le_mul ku hE hE0.le (by norm_num)) hm hm0 (by norm_num)
      _ ≤ 2 * (11863283 / 2 ^ 24) * 0.001 := by norm_num
  have e4 : X * Real.exp (PL X * cc) ≤ 2 * (11863283 / 2 ^ 24) * 0.001 := by
    have hq := Real.exp_pos (PL X * cc)
    have hZ : 1900 * (X - 1.5) ≤ Real.exp (-(PL X * cc)) := by
      have t := exp_tangent (-(PL X * cc)) 7.6
      have hle : X - 1.5 ≤ 1 + -(PL X * cc) - 7.6 := by linarith
      have hx15 : 0 ≤ X - 1.5 := by linarith
      have := mul_le_mul eL2 hle hx15 (Real.exp_pos 7.6).le
      linarith
    have hqZ : Real.exp (PL X * cc) * Real.exp (-(PL X * cc)) = 1 := by
      rw [← Real.exp_add]; simp
    have hXZ : X ≤ 2 * (11863283 / 2 ^ 24) * 0.001 * Real.exp (-(PL X * cc)) := by
      linarith
    have := mul_le_mul_of_nonneg_left hXZ hq.le
    linarith
  have hq0 := (Real.exp_pos (PL X * cc)).le
  rw [abs_le]
  constructor
  · have := mul_le_mul_of_nonneg_left e1 hX0
    linarith
  · have := mul_le_mul_of_nonneg_left e2 hX0
    have := mul_nonneg hX0 hq0
    linarith

lemma mismatch (v F : ℝ) (hv : 0 ≤ v) (hX : v * (11863283 / 2 ^ 24) ≤ 2.5)
    (h : |v * (11863283 / 2 ^ 24) * (F - kk * I (v * (11863283 / 2 ^ 24)))| ≤
      2 * (11863283 / 2 ^ 24) * 0.0009999) :
    |0.5 * v * (F - kk * I (v * (6369051672525773 / 2 ^ 53)))| ≤ 0.001 := by
  have hXu : v * (11863283 / 2 ^ 24) ≤ v * (6369051672525773 / 2 ^ 53) :=
    mul_le_mul_of_nonneg_left (by norm_num) hv
  obtain ⟨m1, m2⟩ := I_mono _ _ hXu
  obtain ⟨kl, ku⟩ := kk_bounds
  have kp := kk_pos
  have hv2 : v ≤ 3.5356 := by linarith
  have hd : v * (6369051672525773 / 2 ^ 53) - v * (11863283 / 2 ^ 24) ≤ v * 1.3e-8 := by
    rw [← mul_sub]; exact mul_le_mul_of_nonneg_left (by norm_num) hv
  have hD : I (v * (6369051672525773 / 2 ^ 53)) - I (v * (11863283 / 2 ^ 24)) ≤ 3.5356 * 1.3e-8 := by
    linarith
  have hD0 : 0 ≤ I (v * (6369051672525773 / 2 ^ 53)) - I (v * (11863283 / 2 ^ 24)) := by linarith
  have key : 0.5 * v * (F - kk * I (v * (6369051672525773 / 2 ^ 53))) =
      (2 ^ 24 / 11863283 / 2) * (v * (11863283 / 2 ^ 24) * (F - kk * I (v * (11863283 / 2 ^ 24))))
      - 0.5 * v * kk * (I (v * (6369051672525773 / 2 ^ 53)) - I (v * (11863283 / 2 ^ 24))) := by
    ring
  rw [key]
  have hG := abs_le.mp h
  have p1 : 0 ≤ 0.5 * v * kk * (I (v * (6369051672525773 / 2 ^ 53)) - I (v * (11863283 / 2 ^ 24))) :=
    mul_nonneg (mul_nonneg (mul_nonneg (by norm_num) hv) kp.le) hD0
  have p2 : 0.5 * v * kk * (I (v * (6369051672525773 / 2 ^ 53)) - I (v * (11863283 / 2 ^ 24))) ≤ 1e-7 := by
    have a1 : 0.5 * v * kk ≤ 0.5 * 3.5356 * 1.12838 := by
      have := mul_le_mul hv2 ku kp.le (by norm_num)
      nlinarith
    calc _ ≤ (0.5 * 3.5356 * 1.12838) * (3.5356 * 1.3e-8) := mul_le_mul a1 hD hD0 (by norm_num)
      _ ≤ 1e-7 := by norm_num
  rw [abs_le]
  constructor <;> nlinarith [hG.1, hG.2]

lemma core_small (v : ℝ) (hv : 0 ≤ v) (h : v * (11863283 / 2 ^ 24) < 1.0029599666595458984375) :
    |0.5 * v * (Ps (v * (11863283 / 2 ^ 24)) - kk * I (v * (6369051672525773 / 2 ^ 53)))| ≤ 0.001 := by
  apply mismatch v _ hv (by linarith)
  rcases le_or_gt (v * (11863283 / 2 ^ 24)) 1 with h1 | h1
  · exact regS1 _ (mul_nonneg hv (by norm_num)) h1
  · exact regS2 _ h1.le h.le

lemma core_large (v : ℝ) (hv : 0 ≤ v) (h : 1.0029599666595458984375 ≤ v * (11863283 / 2 ^ 24)) :
    |0.5 * v * ((1 - Real.exp (PL (v * (11863283 / 2 ^ 24)) * cc)) - kk * I (v * (6369051672525773 / 2 ^ 53)))| ≤ 0.001 := by
  rcases le_or_gt (v * (11863283 / 2 ^ 24)) 2.5 with h1 | h1
  · apply mismatch v _ hv h1
    exact regM _ (by linarith) h1
  · have hu : v * (11863283 / 2 ^ 24) ≤ v * (6369051672525773 / 2 ^ 53) :=
      mul_le_mul_of_nonneg_left (by norm_num) hv
    have := regL _ _ h1.le hu
    have key : 0.5 * v * ((1 - Real.exp (PL (v * (11863283 / 2 ^ 24)) * cc)) - kk * I (v * (6369051672525773 / 2 ^ 53))) =
      (2 ^ 24 / 11863283 / 2) * (v * (11863283 / 2 ^ 24) * ((1 - Real.exp (PL (v * (11863283 / 2 ^ 24)) * cc)) - kk * I (v * (6369051672525773 / 2 ^ 53)))) := by
      ring
    rw [key, abs_mul, abs_of_pos (by norm_num : (0:ℝ) < 2 ^ 24 / 11863283 / 2)]
    calc _ ≤ (2 ^ 24 / 11863283 / 2) * (2 * (11863283 / 2 ^ 24) * 0.001) :=
          mul_le_mul_of_nonneg_left this (by norm_num)
      _ = 0.001 := by norm_num

theorem y_0 : VoltaChallenge.y_0 := by
  intro v0
  dsimp only
  by_cases hs : |v0 * (11863283 / 2 ^ 24 : ℝ)| ≥ 1.0029599666595458984375
  · simp only [hs, not_lt.mpr hs, ↓reduceIte]
    change |v0 * 0.5 * ((if v0 * (11863283 / 2 ^ 24 : ℝ) < 0 then
        -|1 - Real.exp (PL |v0 * (11863283 / 2 ^ 24 : ℝ)| * cc)|
        else 1 - Real.exp (PL |v0 * (11863283 / 2 ^ 24 : ℝ)| * cc)) + 1) -
        0.5 * v0 * (1 + kk * I (v0 * (6369051672525773 / 2 ^ 53 : ℝ)))| ≤ (0.001 : ℝ)
    by_cases hv : 0 ≤ v0
    · have hX0 : 0 ≤ v0 * (11863283 / 2 ^ 24 : ℝ) := mul_nonneg hv (by norm_num)
      rw [abs_of_nonneg hX0] at hs ⊢
      rw [if_neg (not_lt.mpr hX0)]
      have := core_large v0 hv hs
      calc _ = |0.5 * v0 * ((1 - Real.exp (PL (v0 * (11863283 / 2 ^ 24)) * cc)) -
              kk * I (v0 * (6369051672525773 / 2 ^ 53)))| := by
            congr 1; ring
        _ ≤ 0.001 := this
    · have hv' : v0 < 0 := lt_of_not_ge hv
      have hX0 : v0 * (11863283 / 2 ^ 24 : ℝ) < 0 := mul_neg_of_neg_of_pos hv' (by norm_num)
      have habs : |v0 * (11863283 / 2 ^ 24 : ℝ)| = (-v0) * (11863283 / 2 ^ 24) := by
        rw [abs_of_neg hX0]; ring
      rw [habs] at hs ⊢
      rw [if_pos hX0]
      have hI : I (v0 * (6369051672525773 / 2 ^ 53 : ℝ)) = - I ((-v0) * (6369051672525773 / 2 ^ 53)) := by
        rw [← I_odd]; congr 1; ring
      rw [hI]
      have := core_large (-v0) (by linarith) hs
      have hE : 0 ≤ kk * I ((-v0) * (6369051672525773 / 2 ^ 53)) :=
        mul_nonneg kk_pos.le (I_nonneg _ (mul_nonneg (by linarith) (by norm_num)))
      have h2 : |(|1 - Real.exp (PL ((-v0) * (11863283 / 2 ^ 24)) * cc)| - kk * I ((-v0) * (6369051672525773 / 2 ^ 53)))|
          ≤ |(1 - Real.exp (PL ((-v0) * (11863283 / 2 ^ 24)) * cc)) - kk * I ((-v0) * (6369051672525773 / 2 ^ 53))| := by
        have := abs_abs_sub_abs_le_abs_sub (1 - Real.exp (PL ((-v0) * (11863283 / 2 ^ 24)) * cc))
          (kk * I ((-v0) * (6369051672525773 / 2 ^ 53)))
        rwa [abs_of_nonneg hE] at this
      calc _ = |0.5 * (-v0) * (|1 - Real.exp (PL ((-v0) * (11863283 / 2 ^ 24)) * cc)| -
              kk * I ((-v0) * (6369051672525773 / 2 ^ 53)))| := by
            congr 1; ring
        _ = |0.5 * (-v0)| * |(|1 - Real.exp (PL ((-v0) * (11863283 / 2 ^ 24)) * cc)| -
              kk * I ((-v0) * (6369051672525773 / 2 ^ 53)))| := abs_mul _ _
        _ ≤ |0.5 * (-v0)| * |(1 - Real.exp (PL ((-v0) * (11863283 / 2 ^ 24)) * cc)) -
              kk * I ((-v0) * (6369051672525773 / 2 ^ 53))| :=
            mul_le_mul_of_nonneg_left h2 (abs_nonneg _)
        _ = |0.5 * (-v0) * ((1 - Real.exp (PL ((-v0) * (11863283 / 2 ^ 24)) * cc)) -
              kk * I ((-v0) * (6369051672525773 / 2 ^ 53)))| := (abs_mul _ _).symm
        _ ≤ 0.001 := this
  · have hs' : |v0 * (11863283 / 2 ^ 24 : ℝ)| < 1.0029599666595458984375 := lt_of_not_ge hs
    simp only [hs, hs', ↓reduceIte]
    change |v0 * 0.5 * (Ps (v0 * (11863283 / 2 ^ 24 : ℝ)) + 1) -
        0.5 * v0 * (1 + kk * I (v0 * (6369051672525773 / 2 ^ 53 : ℝ)))| ≤ (0.001 : ℝ)
    by_cases hv : 0 ≤ v0
    · have hX0 : 0 ≤ v0 * (11863283 / 2 ^ 24 : ℝ) := mul_nonneg hv (by norm_num)
      rw [abs_of_nonneg hX0] at hs'
      have := core_small v0 hv hs'
      calc _ = |0.5 * v0 * (Ps (v0 * (11863283 / 2 ^ 24)) - kk * I (v0 * (6369051672525773 / 2 ^ 53)))| := by
            congr 1; ring
        _ ≤ 0.001 := this
    · have hv' : v0 < 0 := lt_of_not_ge hv
      have hX0 : v0 * (11863283 / 2 ^ 24 : ℝ) < 0 := mul_neg_of_neg_of_pos hv' (by norm_num)
      have habs : |v0 * (11863283 / 2 ^ 24 : ℝ)| = (-v0) * (11863283 / 2 ^ 24) := by
        rw [abs_of_neg hX0]; ring
      rw [habs] at hs'
      have hP : Ps (v0 * (11863283 / 2 ^ 24 : ℝ)) = - Ps ((-v0) * (11863283 / 2 ^ 24)) := by
        rw [← Ps_odd]; congr 1; ring
      have hI : I (v0 * (6369051672525773 / 2 ^ 53 : ℝ)) = - I ((-v0) * (6369051672525773 / 2 ^ 53)) := by
        rw [← I_odd]; congr 1; ring
      rw [hP, hI]
      have := core_small (-v0) (by linarith) hs'
      calc _ = |0.5 * (-v0) * (Ps ((-v0) * (11863283 / 2 ^ 24)) - kk * I ((-v0) * (6369051672525773 / 2 ^ 53)))| := by
            congr 1; ring
        _ ≤ 0.001 := this

end VoltaProofs
