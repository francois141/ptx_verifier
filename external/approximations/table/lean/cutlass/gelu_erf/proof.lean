import challenge

namespace VoltaProofs
open Real Filter Topology Set MeasureTheory

noncomputable def kk : ℝ := 2 / Real.sqrt Real.pi
noncomputable def cc : ℝ := 11863283 / 2 ^ 24
noncomputable def cp : ℝ := 6369051672525773 / 2 ^ 53

theorem sqrtpi_lo : (1.772453 : ℝ) < Real.sqrt Real.pi := by
  rw [Real.lt_sqrt (by norm_num)]
  have := Real.pi_gt_d6
  norm_num at this ⊢
  linarith

theorem sqrtpi_hi : Real.sqrt Real.pi < 1.772454 := by
  rw [Real.sqrt_lt' (by norm_num)]
  have := Real.pi_lt_d6
  norm_num at this ⊢
  linarith

theorem kk_lo : (1.128379 : ℝ) < kk := by
  unfold kk
  have h1 := sqrtpi_hi
  have h0 : 0 < Real.sqrt Real.pi := Real.sqrt_pos.mpr Real.pi_pos
  rw [lt_div_iff₀ h0]
  nlinarith

theorem kk_hi : kk < 1.12838 := by
  unfold kk
  have h1 := sqrtpi_lo
  have h0 : 0 < Real.sqrt Real.pi := Real.sqrt_pos.mpr Real.pi_pos
  rw [div_lt_iff₀ h0]
  nlinarith

theorem kk_pos : 0 < kk := lt_trans (by norm_num) kk_lo

theorem mono_of_deriv {f f' : ℝ → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hd : ∀ x ∈ Icc a b, HasDerivAt f (f' x) x) (hpos : ∀ x ∈ Icc a b, 0 ≤ f' x) :
    f a ≤ f b := by
  have hm : MonotoneOn f (Icc a b) := by
    apply monotoneOn_of_hasDerivWithinAt_nonneg (f' := f') (convex_Icc a b)
    · intro x hx; exact (hd x hx).continuousAt.continuousWithinAt
    · intro x hx; exact (hd x (interior_subset hx)).hasDerivWithinAt
    · intro x hx; exact hpos x (interior_subset hx)
  exact hm ⟨le_refl a, hab⟩ ⟨hab, le_refl b⟩ hab

theorem erf_hasDerivAt (z : ℝ) : HasDerivAt VoltaChallenge.erf (kk * Real.exp (-z^2)) z := by
  have hc : Continuous (fun t : ℝ => Real.exp (-t^2)) := by fun_prop
  exact ((hc.integral_hasStrictDerivAt 0 z).hasDerivAt).const_mul (2 / Real.sqrt Real.pi)

theorem erf_zero : VoltaChallenge.erf 0 = 0 := by
  simp [VoltaChallenge.erf]

theorem erf_mono {a b : ℝ} (hab : a ≤ b) : VoltaChallenge.erf a ≤ VoltaChallenge.erf b :=
  mono_of_deriv hab (fun x _ => erf_hasDerivAt x)
    (fun _ _ => mul_nonneg kk_pos.le (Real.exp_pos _).le)

theorem erf_nonneg {u : ℝ} (hu : 0 ≤ u) : 0 ≤ VoltaChallenge.erf u := by
  have := erf_mono hu; rwa [erf_zero] at this

theorem exp_neg_sq_le_one (x : ℝ) : Real.exp (-x^2) ≤ 1 := by
  rw [← Real.exp_zero]; exact Real.exp_le_exp.mpr (by nlinarith [sq_nonneg x])

theorem erf_lip {a b : ℝ} (hab : a ≤ b) :
    VoltaChallenge.erf b - VoltaChallenge.erf a ≤ kk * (b - a) := by
  have h := mono_of_deriv (f := fun x => kk * x - VoltaChallenge.erf x)
    (f' := fun x => kk * 1 - kk * Real.exp (-x^2)) hab
    (fun x _ => ((hasDerivAt_id' x).const_mul kk).sub (erf_hasDerivAt x))
    (fun x _ => by
      have h1 := exp_neg_sq_le_one x
      have h2 := kk_pos
      nlinarith)
  linarith

theorem erf_odd_aux (z : ℝ) (hz : 0 ≤ z) : VoltaChallenge.erf (-z) = -VoltaChallenge.erf z := by
  have hd : ∀ x ∈ Icc 0 z, HasDerivAt (fun v => VoltaChallenge.erf v + VoltaChallenge.erf (-v))
      (kk * Real.exp (-x^2) + kk * Real.exp (-(-x)^2) * (-1)) x := by
    intro x _
    exact (erf_hasDerivAt x).add ((erf_hasDerivAt (-x)).comp x (hasDerivAt_neg x))
  have h1 := mono_of_deriv hz hd (fun x _ => le_of_eq (by rw [neg_sq]; ring))
  have h2 := mono_of_deriv (f := fun v => -(VoltaChallenge.erf v + VoltaChallenge.erf (-v))) hz
    (fun x hx => (hd x hx).neg) (fun x _ => le_of_eq (by rw [neg_sq]; ring))
  simp only [neg_zero, erf_zero, add_zero] at h1 h2
  linarith

theorem erf_neg (z : ℝ) : VoltaChallenge.erf (-z) = -VoltaChallenge.erf z := by
  rcases le_total 0 z with hz | hz
  · exact erf_odd_aux z hz
  · have := erf_odd_aux (-z) (by linarith)
    rw [neg_neg] at this
    linarith

theorem erf_tendsto : Tendsto VoltaChallenge.erf atTop (𝓝 1) := by
  have hint : IntegrableOn (fun t : ℝ => Real.exp (-t^2)) (Ioi 0) := by
    have := (integrable_exp_neg_mul_sq (b := 1) one_pos).integrableOn (s := Ioi (0:ℝ))
    simpa using this
  have h := intervalIntegral_tendsto_integral_Ioi 0 hint tendsto_id
  have hval : ∫ x in Ioi (0:ℝ), Real.exp (-x^2) = Real.sqrt Real.pi / 2 := by
    have := integral_gaussian_Ioi 1
    simpa using this
  rw [hval] at h
  have h2 := h.const_mul (2 / Real.sqrt Real.pi)
  have hpi : 0 < Real.sqrt Real.pi := Real.sqrt_pos.mpr Real.pi_pos
  have e : 2 / Real.sqrt Real.pi * (Real.sqrt Real.pi / 2) = 1 := by field_simp
  rw [e] at h2
  exact h2

theorem erf_le_one (z : ℝ) : VoltaChallenge.erf z ≤ 1 :=
  ge_of_tendsto erf_tendsto (Filter.eventually_atTop.mpr ⟨z, fun _ hv => erf_mono hv⟩)

theorem hd_gauss (x : ℝ) :
    HasDerivAt (fun t : ℝ => Real.exp (-t^2)) (-2 * x * Real.exp (-x^2)) x := by
  have h1 : HasDerivAt (fun t : ℝ => -t^2) (-(2 * x)) x := by
    have h0 := (hasDerivAt_pow 2 x).neg
    have e : -(((2:ℕ):ℝ) * x ^ (2 - 1)) = -(2 * x) := by norm_num
    rw [e] at h0
    exact h0
  have h := h1.exp
  exact h.congr_deriv (by ring)

theorem erf_tail_aux (z v : ℝ) (hz : 0 < z) (hzv : z ≤ v) :
    VoltaChallenge.erf v ≤ VoltaChallenge.erf z + kk * Real.exp (-z^2) / (2*z) := by
  have key := mono_of_deriv
    (f := fun x => -(VoltaChallenge.erf x + kk * Real.exp (-x^2) / (2*z)))
    (f' := fun x => -(kk * Real.exp (-x^2) + kk * (-2 * x * Real.exp (-x^2)) / (2*z))) hzv
    (fun x _ => ((erf_hasDerivAt x).add (((hd_gauss x).const_mul kk).div_const (2*z))).neg)
    (fun x hx => by
      have hx1 : z ≤ x := hx.1
      show 0 ≤ -(kk * Real.exp (-x^2) + kk * (-2 * x * Real.exp (-x^2)) / (2*z))
      have e : -(kk * Real.exp (-x^2) + kk * (-2 * x * Real.exp (-x^2)) / (2*z))
          = kk * Real.exp (-x^2) * ((x - z) / z) := by
        field_simp
        ring
      rw [e]
      have : 0 ≤ (x - z) / z := div_nonneg (by linarith) hz.le
      exact mul_nonneg (mul_nonneg kk_pos.le (Real.exp_pos _).le) this)
  have : 0 ≤ kk * Real.exp (-v^2) / (2*z) := by
    have := kk_pos; have := Real.exp_pos (-v^2); positivity
  linarith

theorem erf_tail (z : ℝ) (hz : 0 < z) :
    1 ≤ VoltaChallenge.erf z + kk * Real.exp (-z^2) / (2*z) :=
  le_of_tendsto erf_tendsto (Filter.eventually_atTop.mpr ⟨z, fun v hv => erf_tail_aux z v hz hv⟩)

/-! Taylor bounds for exp(-v) -/

noncomputable def gexp (n : ℕ) (v : ℝ) : ℝ :=
  ∑ i ∈ Finset.range (n+1), (-v)^i / (Nat.factorial i : ℝ)

theorem gexp_deriv (n : ℕ) (v : ℝ) : HasDerivAt (gexp (n+1)) (-gexp n v) v := by
  have h : ∀ i ∈ Finset.range (n+1+1), HasDerivAt (fun w : ℝ => (-w)^i / (Nat.factorial i : ℝ))
      ((i:ℝ) * (-v)^(i-1) * (-1) / (Nat.factorial i : ℝ)) v := by
    intro i _
    exact (((hasDerivAt_neg v).pow i).div_const _)
  have hs := HasDerivAt.fun_sum h
  have e : (∑ i ∈ Finset.range (n+1+1), (i:ℝ) * (-v)^(i-1) * (-1) / (Nat.factorial i : ℝ))
      = -gexp n v := by
    unfold gexp
    rw [Finset.sum_range_succ' _ (n+1)]
    simp only [Nat.cast_zero, zero_mul, zero_div, add_zero]
    rw [← Finset.sum_neg_distrib]
    apply Finset.sum_congr rfl
    intro i _
    rw [Nat.factorial_succ, Nat.add_sub_cancel]
    have hf : (0:ℝ) < Nat.factorial i := by exact_mod_cast Nat.factorial_pos i
    push_cast
    field_simp
  rw [e] at hs
  exact hs

theorem gexp_at_zero (n : ℕ) : gexp n 0 = 1 := by
  unfold gexp
  rw [Finset.sum_range_succ']
  simp

theorem gexp_alt (n : ℕ) : ∀ v : ℝ, 0 ≤ v → 0 ≤ (-1:ℝ)^n * (gexp n v - Real.exp (-v)) := by
  induction n with
  | zero =>
    intro v hv
    have : Real.exp (-v) ≤ 1 := by
      rw [← Real.exp_zero]; exact Real.exp_le_exp.mpr (by linarith)
    simp [gexp] <;> linarith
  | succ n ih =>
    intro v hv
    have key := mono_of_deriv (f := fun w => (-1:ℝ)^(n+1) * (gexp (n+1) w - Real.exp (-w)))
      (f' := fun w => (-1:ℝ)^(n+1) * (-gexp n w - Real.exp (-w) * (-1))) hv
      (fun w _ => ((gexp_deriv n w).sub ((hasDerivAt_neg w).exp)).const_mul _)
      (fun w hw => by
        have := ih w hw.1
        show 0 ≤ (-1:ℝ)^(n+1) * (-gexp n w - Real.exp (-w) * (-1))
        have e : (-1:ℝ)^(n+1) * (-gexp n w - Real.exp (-w) * (-1))
            = (-1)^n * (gexp n w - Real.exp (-w)) := by ring
        rw [e]; exact this)
    rw [gexp_at_zero, neg_zero, Real.exp_zero, sub_self, mul_zero] at key
    exact key

theorem exp_neg_le_gexp (m : ℕ) (v : ℝ) (hv : 0 ≤ v) : Real.exp (-v) ≤ gexp (2*m) v := by
  have := gexp_alt (2*m) v hv
  rw [pow_mul] at this
  norm_num at this
  linarith

theorem gexp_le_exp_neg (m : ℕ) (v : ℝ) (hv : 0 ≤ v) : gexp (2*m+1) v ≤ Real.exp (-v) := by
  have := gexp_alt (2*m+1) v hv
  rw [pow_succ, pow_mul] at this
  norm_num at this
  linarith

/-! Taylor bounds for erf -/

noncomputable def Gi (n : ℕ) (t : ℝ) : ℝ :=
  ∑ i ∈ Finset.range (n+1), (-1:ℝ)^i * t^(2*i+1) / ((Nat.factorial i : ℝ) * (2*(i:ℝ)+1))

theorem Gi_deriv (n : ℕ) (t : ℝ) : HasDerivAt (Gi n) (gexp n (t^2)) t := by
  have h : ∀ i ∈ Finset.range (n+1), HasDerivAt
      (fun w : ℝ => (-1:ℝ)^i * w^(2*i+1) / ((Nat.factorial i : ℝ) * (2*(i:ℝ)+1)))
      ((-1:ℝ)^i * ((↑(2*i+1) : ℝ) * t^(2*i+1-1)) / ((Nat.factorial i : ℝ) * (2*(i:ℝ)+1))) t := by
    intro i _
    exact ((hasDerivAt_pow (2*i+1) t).const_mul _).div_const _
  have hs := HasDerivAt.fun_sum h
  have e : (∑ i ∈ Finset.range (n+1),
      (-1:ℝ)^i * ((↑(2*i+1) : ℝ) * t^(2*i+1-1)) / ((Nat.factorial i : ℝ) * (2*(i:ℝ)+1)))
      = gexp n (t^2) := by
    unfold gexp
    apply Finset.sum_congr rfl
    intro i _
    have hf : (0:ℝ) < Nat.factorial i := by exact_mod_cast Nat.factorial_pos i
    have h2 : (0:ℝ) < 2*(i:ℝ)+1 := by positivity
    rw [Nat.add_sub_cancel, neg_pow (t^2) i, ← pow_mul t 2 i]
    push_cast
    rw [div_eq_div_iff (by positivity) hf.ne']
    ring
  rw [e] at hs
  exact hs

theorem Gi_zero (n : ℕ) : Gi n 0 = 0 := by
  simp [Gi]

theorem erf_ge_Gi (m : ℕ) (u : ℝ) (hu : 0 ≤ u) : kk * Gi (2*m+1) u ≤ VoltaChallenge.erf u := by
  have h := mono_of_deriv (f := fun v => VoltaChallenge.erf v - kk * Gi (2*m+1) v)
    (f' := fun v => kk * Real.exp (-v^2) - kk * gexp (2*m+1) (v^2)) hu
    (fun x _ => (erf_hasDerivAt x).sub ((Gi_deriv (2*m+1) x).const_mul kk))
    (fun x _ => by
      have h1 := gexp_le_exp_neg m (x^2) (sq_nonneg x)
      have h2 := kk_pos
      show 0 ≤ kk * Real.exp (-x^2) - kk * gexp (2*m+1) (x^2)
      nlinarith)
  simp only [erf_zero, Gi_zero, mul_zero, sub_zero] at h
  linarith

theorem erf_le_Gi (m : ℕ) (u : ℝ) (hu : 0 ≤ u) : VoltaChallenge.erf u ≤ kk * Gi (2*m) u := by
  have h := mono_of_deriv (f := fun v => kk * Gi (2*m) v - VoltaChallenge.erf v)
    (f' := fun v => kk * gexp (2*m) (v^2) - kk * Real.exp (-v^2)) hu
    (fun x _ => ((Gi_deriv (2*m) x).const_mul kk).sub (erf_hasDerivAt x))
    (fun x _ => by
      have h1 := exp_neg_le_gexp m (x^2) (sq_nonneg x)
      have h2 := kk_pos
      show 0 ≤ kk * gexp (2*m) (x^2) - kk * Real.exp (-x^2)
      nlinarith)
  simp only [erf_zero, Gi_zero, mul_zero, sub_zero] at h
  linarith

theorem pwu (s h : ℝ) (hs : |s| ≤ h) (j : ℕ) : s^j ≤ h^j := by
  have h1 : |s|^j ≤ h^j := pow_le_pow_left₀ (abs_nonneg s) hs j
  have h2 : s^j ≤ |s^j| := le_abs_self _
  rw [abs_pow] at h2
  linarith

theorem pwl (s h : ℝ) (hs : |s| ≤ h) (j : ℕ) : -(h^j) ≤ s^j := by
  have h1 : |s|^j ≤ h^j := pow_le_pow_left₀ (abs_nonneg s) hs j
  have h2 : -|s^j| ≤ s^j := neg_abs_le _
  rw [abs_pow] at h2
  linarith

theorem pu1 (r : ℝ) (hr : |r| ≤ 1) (j : ℕ) : r^j ≤ 1 := by
  have := pwu r 1 hr j; rwa [one_pow] at this

theorem pl1 (r : ℝ) (hr : |r| ≤ 1) (j : ℕ) : -1 ≤ r^j := by
  have := pwl r 1 hr j; rwa [one_pow] at this

/-! small branch -/

noncomputable def Asm (t : ℝ) : ℝ :=
  (((((((5829813 / 2 ^ 36 : ℝ) * (t * t) + (-440937 / 2 ^ 29 : ℝ)) * (t * t)
    + (5597941 / 2 ^ 30 : ℝ)) * (t * t) + (-14425063 / 2 ^ 29 : ℝ)) * (t * t)
    + (15145135 / 2 ^ 27 : ℝ)) * (t * t) + (-3155179 / 2 ^ 23 : ℝ)) * (t * t)
    + (8615379 / 2 ^ 26 : ℝ)) * t + t

set_option maxHeartbeats 2000000 in
theorem small_poly (u : ℝ) (h0 : 0 ≤ u) (h1 : u ≤ 1.003) :
    |Asm u - VoltaChallenge.erf u| ≤ 0.001 := by
  have hA : kk * Gi 9 u ≤ VoltaChallenge.erf u := erf_ge_Gi 4 u h0
  have hB : VoltaChallenge.erf u ≤ kk * Gi 8 u := erf_le_Gi 4 u h0
  have hE := erf_nonneg h0
  have hk1 := kk_lo
  have hk2 := kk_hi
  have hk0 := kk_pos
  have hG8 : 0 ≤ Gi 8 u := by
    by_contra hc
    have hc' : Gi 8 u < 0 := lt_of_not_ge hc
    have : kk * Gi 8 u < 0 := mul_neg_of_pos_of_neg hk0 hc'
    linarith
  have hB' : VoltaChallenge.erf u ≤ 1.12838 * Gi 8 u :=
    le_trans hB (mul_le_mul_of_nonneg_right hk2.le hG8)
  have hA' : 1.128379 * Gi 9 u ≤ VoltaChallenge.erf u ∨
      1.12838 * Gi 9 u ≤ VoltaChallenge.erf u := by
    rcases le_or_gt 0 (Gi 9 u) with hg | hg
    · exact Or.inl (le_trans (mul_le_mul_of_nonneg_right hk1.le hg) hA)
    · exact Or.inr (le_trans (mul_le_mul_of_nonpos_right hk2.le hg.le) hA)
  have e9 : Gi 9 u = u - u^3/3 + u^5/10 - u^7/42 + u^9/216 - u^11/1320 + u^13/9360
      - u^15/75600 + u^17/685440 - u^19/6894720 := by
    simp only [Gi, Finset.sum_range_succ, Finset.sum_range_zero]
    norm_num [Nat.factorial] <;> ring
  have e8 : Gi 8 u = u - u^3/3 + u^5/10 - u^7/42 + u^9/216 - u^11/1320 + u^13/9360
      - u^15/75600 + u^17/685440 := by
    simp only [Gi, Finset.sum_range_succ, Finset.sum_range_zero]
    norm_num [Nat.factorial] <;> ring
  rw [e9] at hA'
  rw [e8] at hB'
  have p1 := pow_le_pow_left₀ h0 h1 1
  have p3 := pow_le_pow_left₀ h0 h1 3
  have p5 := pow_le_pow_left₀ h0 h1 5
  have p7 := pow_le_pow_left₀ h0 h1 7
  have p9 := pow_le_pow_left₀ h0 h1 9
  have p11 := pow_le_pow_left₀ h0 h1 11
  have p13 := pow_le_pow_left₀ h0 h1 13
  have p15 := pow_le_pow_left₀ h0 h1 15
  have p17 := pow_le_pow_left₀ h0 h1 17
  have p19 := pow_le_pow_left₀ h0 h1 19
  have q1 := pow_nonneg h0 1
  have q3 := pow_nonneg h0 3
  have q5 := pow_nonneg h0 5
  have q7 := pow_nonneg h0 7
  have q9 := pow_nonneg h0 9
  have q11 := pow_nonneg h0 11
  have q13 := pow_nonneg h0 13
  have q15 := pow_nonneg h0 15
  have q17 := pow_nonneg h0 17
  have q19 := pow_nonneg h0 19
  norm_num at p1 p3 p5 p7 p9 p11 p13 p15 p17 p19
  unfold Asm
  rw [abs_le]
  constructor
  · linarith
  · rcases hA' with h | h <;> linarith

/-! large branch -/

noncomputable def rr : ℝ := (8388608 / 12102203 : ℝ)

noncomputable def Pl (u : ℝ) : ℝ :=
  ((((((7710237 / 2 ^ 36 : ℝ) * u + (-11403355 / 2 ^ 33 : ℝ)) * u + (9015711 / 2 ^ 30 : ℝ)) * u
    + (-5401805 / 2 ^ 27 : ℝ)) * u + (10704153 / 2 ^ 26 : ℝ)) * u + (15316217 / 2 ^ 24 : ℝ)) * u
    + (0.6290600299835205078125 : ℝ)

noncomputable def Pd (u : ℝ) : ℝ :=
  ((((6 * (7710237 / 2 ^ 36 : ℝ) * u + 5 * (-11403355 / 2 ^ 33 : ℝ)) * u
    + 4 * (9015711 / 2 ^ 30 : ℝ)) * u + 3 * (-5401805 / 2 ^ 27 : ℝ)) * u
    + 2 * (10704153 / 2 ^ 26 : ℝ)) * u + (15316217 / 2 ^ 24 : ℝ)

noncomputable def Xl (u : ℝ) : ℝ := Pl u * (-u) + (-u)
noncomputable def Xd (u : ℝ) : ℝ := -(u * Pd u + Pl u + 1)
noncomputable def Wf (t : ℝ) : ℝ := t^2 + Xl t * rr
noncomputable def Qf (t : ℝ) : ℝ := -(Xd t * rr)
noncomputable def Fl (u : ℝ) : ℝ := 1 - Real.exp (Xl u * rr)
noncomputable def Fd (u : ℝ) : ℝ := -(Real.exp (Xl u * rr) * (Xd u * rr))

theorem Pl_deriv (t : ℝ) : HasDerivAt Pl (Pd t) t := by
  have i := hasDerivAt_id' t
  have h1 := (i.const_mul (7710237 / 2 ^ 36 : ℝ)).add_const (-11403355 / 2 ^ 33 : ℝ)
  have h2 := (h1.mul i).add_const (9015711 / 2 ^ 30 : ℝ)
  have h3 := (h2.mul i).add_const (-5401805 / 2 ^ 27 : ℝ)
  have h4 := (h3.mul i).add_const (10704153 / 2 ^ 26 : ℝ)
  have h5 := (h4.mul i).add_const (15316217 / 2 ^ 24 : ℝ)
  have h6 := (h5.mul i).add_const (0.6290600299835205078125 : ℝ)
  exact h6.congr_deriv (by
    (try simp only [Pi.mul_apply])
    unfold Pd
    ring)

theorem Xl_deriv (t : ℝ) : HasDerivAt Xl (Xd t) t := by
  have i := hasDerivAt_neg t
  have h := ((Pl_deriv t).mul i).add i
  exact h.congr_deriv (by
    unfold Xd
    ring)

theorem Fl_deriv (t : ℝ) : HasDerivAt Fl (Fd t) t :=
  (((Xl_deriv t).mul_const rr).exp).const_sub 1

theorem Fd_eq (t : ℝ) : Fd t = Qf t * Real.exp (Wf t) * Real.exp (-t^2) := by
  have h : Xl t * rr = Wf t + (-t^2) := by unfold Wf; ring
  unfold Fd Qf
  rw [h, Real.exp_add]
  ring

theorem exp_quad_le (d : ℝ) (hd : 0 ≤ d) : 1 + d + d^2/2 ≤ Real.exp d := by
  have := Real.sum_le_exp_of_nonneg hd 3
  norm_num [Finset.sum_range_succ, Nat.factorial] at this
  linarith

theorem cell_up (q w w0 E K : ℝ) (hE : Real.exp w0 ≤ E) (hv : w ≤ w0) (hK : 0 ≤ K)
    (hp : q * E ≤ K * (1 + (w0 - w) + (w0 - w)^2/2)) : q * Real.exp w ≤ K := by
  have hv0 : 0 ≤ w0 - w := by linarith
  have h3 := exp_quad_le (w0 - w) hv0
  have hw : Real.exp w0 = Real.exp w * Real.exp (w0 - w) := by
    rw [← Real.exp_add]; congr 1; ring
  have he := Real.exp_pos w
  have he2 := Real.exp_pos (w0 - w)
  rcases le_or_gt q 0 with hq | hq
  · nlinarith
  · have h1 : q * Real.exp w0 ≤ q * E := mul_le_mul_of_nonneg_left hE hq.le
    have h2 : K * (1 + (w0 - w) + (w0 - w)^2/2) ≤ K * Real.exp (w0 - w) :=
      mul_le_mul_of_nonneg_left h3 hK
    rw [hw] at h1
    by_contra hc
    have hc' : K < q * Real.exp w := lt_of_not_ge hc
    have : K * Real.exp (w0 - w) < q * Real.exp w * Real.exp (w0 - w) :=
      mul_lt_mul_of_pos_right hc' he2
    linarith

theorem cell_lo (q w w1 E K : ℝ) (hE : E ≤ Real.exp w1) (hE0 : 0 < E) (hd : w1 ≤ w) (hK : 0 < K)
    (hp : K ≤ q * E * (1 + (w - w1) + (w - w1)^2/2)) : K ≤ q * Real.exp w := by
  have hd0 : 0 ≤ w - w1 := by linarith
  have h3 := exp_quad_le (w - w1) hd0
  have hpos : 0 < 1 + (w - w1) + (w - w1)^2/2 := by nlinarith [sq_nonneg (w - w1)]
  have hw : Real.exp w = Real.exp w1 * Real.exp (w - w1) := by
    rw [← Real.exp_add]; congr 1; ring
  have hq : 0 < q := by
    by_contra hc
    have hc' : q ≤ 0 := le_of_not_gt hc
    have hm := mul_pos hE0 hpos
    have : q * E * (1 + (w - w1) + (w - w1)^2/2) ≤ 0 := by nlinarith
    linarith
  rw [hw]
  have h1 : q * E ≤ q * Real.exp w1 := mul_le_mul_of_nonneg_left hE hq.le
  have h2 : q * E * (1 + (w - w1) + (w - w1)^2/2) ≤ q * Real.exp w1 * Real.exp (w - w1) :=
    mul_le_mul h1 h3 hpos.le (mul_nonneg hq.le (Real.exp_pos _).le)
  linarith

theorem cell_bound (t w0 w1 Eh El : ℝ) (hEh : Real.exp w0 ≤ Eh) (hEl : El ≤ Real.exp w1)
    (hEl0 : 0 < El) (h1 : Wf t ≤ w0) (h2 : w1 ≤ Wf t)
    (h3 : Qf t * Eh ≤ (1.128379 * 1.005) * (1 + (w0 - Wf t) + (w0 - Wf t)^2/2))
    (h4 : 1.12838 * 0.995 ≤ Qf t * El * (1 + (Wf t - w1) + (Wf t - w1)^2/2)) :
    kk * 0.995 ≤ Qf t * Real.exp (Wf t) ∧ Qf t * Real.exp (Wf t) ≤ kk * 1.005 := by
  constructor
  · have := cell_lo (Qf t) (Wf t) w1 El _ hEl hEl0 h2 (by norm_num) h4
    have := kk_hi
    linarith
  · have := cell_up (Qf t) (Wf t) w0 Eh _ hEh h1 (by norm_num) h3
    have := kk_lo
    linarith

/-! exp constants -/

theorem E1h : Real.exp (-0.84) ≤ 0.43172 :=
  le_trans (exp_neg_le_gexp 8 0.84 (by norm_num))
    (by norm_num [gexp, Finset.sum_range_succ, Nat.factorial])
theorem E1l : (0.33958 : ℝ) ≤ Real.exp (-1.08) :=
  le_trans (by norm_num [gexp, Finset.sum_range_succ, Nat.factorial])
    (gexp_le_exp_neg 8 1.08 (by norm_num))
theorem E2h : Real.exp (-1.06) ≤ 0.34647 :=
  le_trans (exp_neg_le_gexp 8 1.06 (by norm_num))
    (by norm_num [gexp, Finset.sum_range_succ, Nat.factorial])
theorem E2l : (0.28082 : ℝ) ≤ Real.exp (-1.27) :=
  le_trans (by norm_num [gexp, Finset.sum_range_succ, Nat.factorial])
    (gexp_le_exp_neg 8 1.27 (by norm_num))
theorem E3h : Real.exp (-1.24) ≤ 0.28940 :=
  le_trans (exp_neg_le_gexp 8 1.24 (by norm_num))
    (by norm_num [gexp, Finset.sum_range_succ, Nat.factorial])
theorem E3l : (0.22762 : ℝ) ≤ Real.exp (-1.48) :=
  le_trans (by norm_num [gexp, Finset.sum_range_succ, Nat.factorial])
    (gexp_le_exp_neg 8 1.48 (by norm_num))
theorem E4h : Real.exp (-1.45) ≤ 0.23458 :=
  le_trans (exp_neg_le_gexp 8 1.45 (by norm_num))
    (by norm_num [gexp, Finset.sum_range_succ, Nat.factorial])
theorem E4l : (0.19789 : ℝ) ≤ Real.exp (-1.62) :=
  le_trans (by norm_num [gexp, Finset.sum_range_succ, Nat.factorial])
    (gexp_le_exp_neg 8 1.62 (by norm_num))
theorem E5h : Real.exp (-1.59) ≤ 0.20393 :=
  le_trans (exp_neg_le_gexp 8 1.59 (by norm_num))
    (by norm_num [gexp, Finset.sum_range_succ, Nat.factorial])
theorem E5l : (0.17727 : ℝ) ≤ Real.exp (-1.73) :=
  le_trans (by norm_num [gexp, Finset.sum_range_succ, Nat.factorial])
    (gexp_le_exp_neg 8 1.73 (by norm_num))

theorem exp_neg_le_of (a M : ℝ) (hM : 0 < M) (h : M ≤ Real.exp a) : Real.exp (-a) ≤ 1 / M := by
  have h1 : Real.exp (-a) * Real.exp a = 1 := by rw [← Real.exp_add]; simp
  have h2 := Real.exp_pos (-a)
  rw [le_div_iff₀ hM]
  nlinarith

theorem E9 : Real.exp (-9) ≤ 1.24e-4 := by
  have h : (8065:ℝ) ≤ Real.exp 9 := by
    have := Real.sum_le_exp_of_nonneg (show (0:ℝ) ≤ 9 by norm_num) 30
    norm_num [Finset.sum_range_succ, Nat.factorial] at this
    linarith
  have := exp_neg_le_of 9 8065 (by norm_num) h
  have h2 : (1:ℝ) / 8065 ≤ 1.24e-4 := by norm_num
  linarith

theorem E107 : Real.exp (-10.7) ≤ 2.5e-5 := by
  have h : (40000:ℝ) ≤ Real.exp 10.7 := by
    have := Real.sum_le_exp_of_nonneg (show (0:ℝ) ≤ 10.7 by norm_num) 30
    norm_num [Finset.sum_range_succ, Nat.factorial] at this
    linarith
  have := exp_neg_le_of 10.7 40000 (by norm_num) h
  have h2 : (1:ℝ) / 40000 ≤ 2.5e-5 := by norm_num
  linarith

/-! cells -/

theorem c1a (r : ℝ) (hr : |r| ≤ 1) : Wf (19/16 + 3/16 * r) ≤ -0.84 := by
  simp only [Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7]

theorem c1b (r : ℝ) (hr : |r| ≤ 1) : -1.08 ≤ Wf (19/16 + 3/16 * r) := by
  simp only [Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7]

theorem c1c (r : ℝ) (hr : |r| ≤ 1) : Qf (19/16 + 3/16 * r) * 0.43172 ≤ (1.128379 * 1.005) *
    (1 + (-0.84 - Wf (19/16 + 3/16 * r)) + (-0.84 - Wf (19/16 + 3/16 * r))^2/2) := by
  simp only [Qf, Xd, Pd, Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7,
    pu1 r hr 8, pl1 r hr 8, pu1 r hr 9, pl1 r hr 9, pu1 r hr 10, pl1 r hr 10,
    pu1 r hr 11, pl1 r hr 11, pu1 r hr 12, pl1 r hr 12, pu1 r hr 13, pl1 r hr 13,
    pu1 r hr 14, pl1 r hr 14]

theorem c1d (r : ℝ) (hr : |r| ≤ 1) : 1.12838 * 0.995 ≤ Qf (19/16 + 3/16 * r) * 0.33958 *
    (1 + (Wf (19/16 + 3/16 * r) - -1.08) + (Wf (19/16 + 3/16 * r) - -1.08)^2/2) := by
  simp only [Qf, Xd, Pd, Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7,
    pu1 r hr 8, pl1 r hr 8, pu1 r hr 9, pl1 r hr 9, pu1 r hr 10, pl1 r hr 10,
    pu1 r hr 11, pl1 r hr 11, pu1 r hr 12, pl1 r hr 12, pu1 r hr 13, pl1 r hr 13,
    pu1 r hr 14, pl1 r hr 14, pu1 r hr 15, pl1 r hr 15, pu1 r hr 16, pl1 r hr 16,
    pu1 r hr 17, pl1 r hr 17, pu1 r hr 18, pl1 r hr 18, pu1 r hr 19, pl1 r hr 19,
    pu1 r hr 20, pl1 r hr 20]

theorem c2a (r : ℝ) (hr : |r| ≤ 1) : Wf (25/16 + 3/16 * r) ≤ -1.06 := by
  simp only [Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7]

theorem c2b (r : ℝ) (hr : |r| ≤ 1) : -1.27 ≤ Wf (25/16 + 3/16 * r) := by
  simp only [Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7]

theorem c2c (r : ℝ) (hr : |r| ≤ 1) : Qf (25/16 + 3/16 * r) * 0.34647 ≤ (1.128379 * 1.005) *
    (1 + (-1.06 - Wf (25/16 + 3/16 * r)) + (-1.06 - Wf (25/16 + 3/16 * r))^2/2) := by
  simp only [Qf, Xd, Pd, Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7,
    pu1 r hr 8, pl1 r hr 8, pu1 r hr 9, pl1 r hr 9, pu1 r hr 10, pl1 r hr 10,
    pu1 r hr 11, pl1 r hr 11, pu1 r hr 12, pl1 r hr 12, pu1 r hr 13, pl1 r hr 13,
    pu1 r hr 14, pl1 r hr 14]

theorem c2d (r : ℝ) (hr : |r| ≤ 1) : 1.12838 * 0.995 ≤ Qf (25/16 + 3/16 * r) * 0.28082 *
    (1 + (Wf (25/16 + 3/16 * r) - -1.27) + (Wf (25/16 + 3/16 * r) - -1.27)^2/2) := by
  simp only [Qf, Xd, Pd, Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7,
    pu1 r hr 8, pl1 r hr 8, pu1 r hr 9, pl1 r hr 9, pu1 r hr 10, pl1 r hr 10,
    pu1 r hr 11, pl1 r hr 11, pu1 r hr 12, pl1 r hr 12, pu1 r hr 13, pl1 r hr 13,
    pu1 r hr 14, pl1 r hr 14, pu1 r hr 15, pl1 r hr 15, pu1 r hr 16, pl1 r hr 16,
    pu1 r hr 17, pl1 r hr 17, pu1 r hr 18, pl1 r hr 18, pu1 r hr 19, pl1 r hr 19,
    pu1 r hr 20, pl1 r hr 20]

theorem c3a (r : ℝ) (hr : |r| ≤ 1) : Wf (2 + 1/4 * r) ≤ -1.24 := by
  simp only [Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7]

theorem c3b (r : ℝ) (hr : |r| ≤ 1) : -1.48 ≤ Wf (2 + 1/4 * r) := by
  simp only [Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7]

theorem c3c (r : ℝ) (hr : |r| ≤ 1) : Qf (2 + 1/4 * r) * 0.28940 ≤ (1.128379 * 1.005) *
    (1 + (-1.24 - Wf (2 + 1/4 * r)) + (-1.24 - Wf (2 + 1/4 * r))^2/2) := by
  simp only [Qf, Xd, Pd, Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7,
    pu1 r hr 8, pl1 r hr 8, pu1 r hr 9, pl1 r hr 9, pu1 r hr 10, pl1 r hr 10,
    pu1 r hr 11, pl1 r hr 11, pu1 r hr 12, pl1 r hr 12, pu1 r hr 13, pl1 r hr 13,
    pu1 r hr 14, pl1 r hr 14]

theorem c3d (r : ℝ) (hr : |r| ≤ 1) : 1.12838 * 0.995 ≤ Qf (2 + 1/4 * r) * 0.22762 *
    (1 + (Wf (2 + 1/4 * r) - -1.48) + (Wf (2 + 1/4 * r) - -1.48)^2/2) := by
  simp only [Qf, Xd, Pd, Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7,
    pu1 r hr 8, pl1 r hr 8, pu1 r hr 9, pl1 r hr 9, pu1 r hr 10, pl1 r hr 10,
    pu1 r hr 11, pl1 r hr 11, pu1 r hr 12, pl1 r hr 12, pu1 r hr 13, pl1 r hr 13,
    pu1 r hr 14, pl1 r hr 14, pu1 r hr 15, pl1 r hr 15, pu1 r hr 16, pl1 r hr 16,
    pu1 r hr 17, pl1 r hr 17, pu1 r hr 18, pl1 r hr 18, pu1 r hr 19, pl1 r hr 19,
    pu1 r hr 20, pl1 r hr 20]

theorem c4a (r : ℝ) (hr : |r| ≤ 1) : Wf (39/16 + 3/16 * r) ≤ -1.45 := by
  simp only [Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7]

theorem c4b (r : ℝ) (hr : |r| ≤ 1) : -1.62 ≤ Wf (39/16 + 3/16 * r) := by
  simp only [Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7]

theorem c4c (r : ℝ) (hr : |r| ≤ 1) : Qf (39/16 + 3/16 * r) * 0.23458 ≤ (1.128379 * 1.005) *
    (1 + (-1.45 - Wf (39/16 + 3/16 * r)) + (-1.45 - Wf (39/16 + 3/16 * r))^2/2) := by
  simp only [Qf, Xd, Pd, Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7,
    pu1 r hr 8, pl1 r hr 8, pu1 r hr 9, pl1 r hr 9, pu1 r hr 10, pl1 r hr 10,
    pu1 r hr 11, pl1 r hr 11, pu1 r hr 12, pl1 r hr 12, pu1 r hr 13, pl1 r hr 13,
    pu1 r hr 14, pl1 r hr 14]

theorem c4d (r : ℝ) (hr : |r| ≤ 1) : 1.12838 * 0.995 ≤ Qf (39/16 + 3/16 * r) * 0.19789 *
    (1 + (Wf (39/16 + 3/16 * r) - -1.62) + (Wf (39/16 + 3/16 * r) - -1.62)^2/2) := by
  simp only [Qf, Xd, Pd, Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7,
    pu1 r hr 8, pl1 r hr 8, pu1 r hr 9, pl1 r hr 9, pu1 r hr 10, pl1 r hr 10,
    pu1 r hr 11, pl1 r hr 11, pu1 r hr 12, pl1 r hr 12, pu1 r hr 13, pl1 r hr 13,
    pu1 r hr 14, pl1 r hr 14, pu1 r hr 15, pl1 r hr 15, pu1 r hr 16, pl1 r hr 16,
    pu1 r hr 17, pl1 r hr 17, pu1 r hr 18, pl1 r hr 18, pu1 r hr 19, pl1 r hr 19,
    pu1 r hr 20, pl1 r hr 20]

theorem c5a (r : ℝ) (hr : |r| ≤ 1) : Wf (45/16 + 3/16 * r) ≤ -1.59 := by
  simp only [Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7]

theorem c5b (r : ℝ) (hr : |r| ≤ 1) : -1.73 ≤ Wf (45/16 + 3/16 * r) := by
  simp only [Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7]

theorem c5c (r : ℝ) (hr : |r| ≤ 1) : Qf (45/16 + 3/16 * r) * 0.20393 ≤ (1.128379 * 1.005) *
    (1 + (-1.59 - Wf (45/16 + 3/16 * r)) + (-1.59 - Wf (45/16 + 3/16 * r))^2/2) := by
  simp only [Qf, Xd, Pd, Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7,
    pu1 r hr 8, pl1 r hr 8, pu1 r hr 9, pl1 r hr 9, pu1 r hr 10, pl1 r hr 10,
    pu1 r hr 11, pl1 r hr 11, pu1 r hr 12, pl1 r hr 12, pu1 r hr 13, pl1 r hr 13,
    pu1 r hr 14, pl1 r hr 14]

theorem c5d (r : ℝ) (hr : |r| ≤ 1) : 1.12838 * 0.995 ≤ Qf (45/16 + 3/16 * r) * 0.17727 *
    (1 + (Wf (45/16 + 3/16 * r) - -1.73) + (Wf (45/16 + 3/16 * r) - -1.73)^2/2) := by
  simp only [Qf, Xd, Pd, Wf, Xl, Pl, rr]
  linarith [pu1 r hr 1, pl1 r hr 1, pu1 r hr 2, pl1 r hr 2, pu1 r hr 3, pl1 r hr 3,
    pu1 r hr 4, pl1 r hr 4, pu1 r hr 5, pl1 r hr 5, pu1 r hr 6, pl1 r hr 6, pu1 r hr 7, pl1 r hr 7,
    pu1 r hr 8, pl1 r hr 8, pu1 r hr 9, pl1 r hr 9, pu1 r hr 10, pl1 r hr 10,
    pu1 r hr 11, pl1 r hr 11, pu1 r hr 12, pl1 r hr 12, pu1 r hr 13, pl1 r hr 13,
    pu1 r hr 14, pl1 r hr 14, pu1 r hr 15, pl1 r hr 15, pu1 r hr 16, pl1 r hr 16,
    pu1 r hr 17, pl1 r hr 17, pu1 r hr 18, pl1 r hr 18, pu1 r hr 19, pl1 r hr 19,
    pu1 r hr 20, pl1 r hr 20]

theorem cell1 (t : ℝ) (ha : 1 ≤ t) (hb : t ≤ 1.375) :
    kk * 0.995 ≤ Qf t * Real.exp (Wf t) ∧ Qf t * Real.exp (Wf t) ≤ kk * 1.005 ∧ Wf t < 0 := by
  obtain ⟨r, hr, rfl⟩ : ∃ r, |r| ≤ 1 ∧ t = 19/16 + 3/16 * r :=
    ⟨(t - 19/16) * (16/3), abs_le.mpr ⟨by linarith, by linarith⟩, by ring⟩
  have hc := cell_bound (19/16 + 3/16 * r) (-0.84) (-1.08) 0.43172 0.33958 E1h E1l (by norm_num)
    (c1a r hr) (c1b r hr) (c1c r hr) (c1d r hr)
  exact ⟨hc.1, hc.2, by linarith [c1a r hr]⟩

theorem cell2 (t : ℝ) (ha : 1.375 ≤ t) (hb : t ≤ 1.75) :
    kk * 0.995 ≤ Qf t * Real.exp (Wf t) ∧ Qf t * Real.exp (Wf t) ≤ kk * 1.005 ∧ Wf t < 0 := by
  obtain ⟨r, hr, rfl⟩ : ∃ r, |r| ≤ 1 ∧ t = 25/16 + 3/16 * r :=
    ⟨(t - 25/16) * (16/3), abs_le.mpr ⟨by linarith, by linarith⟩, by ring⟩
  have hc := cell_bound (25/16 + 3/16 * r) (-1.06) (-1.27) 0.34647 0.28082 E2h E2l (by norm_num)
    (c2a r hr) (c2b r hr) (c2c r hr) (c2d r hr)
  exact ⟨hc.1, hc.2, by linarith [c2a r hr]⟩

theorem cell3 (t : ℝ) (ha : 1.75 ≤ t) (hb : t ≤ 2.25) :
    kk * 0.995 ≤ Qf t * Real.exp (Wf t) ∧ Qf t * Real.exp (Wf t) ≤ kk * 1.005 ∧ Wf t < 0 := by
  obtain ⟨r, hr, rfl⟩ : ∃ r, |r| ≤ 1 ∧ t = 2 + 1/4 * r :=
    ⟨(t - 2) * 4, abs_le.mpr ⟨by linarith, by linarith⟩, by ring⟩
  have hc := cell_bound (2 + 1/4 * r) (-1.24) (-1.48) 0.28940 0.22762 E3h E3l (by norm_num)
    (c3a r hr) (c3b r hr) (c3c r hr) (c3d r hr)
  exact ⟨hc.1, hc.2, by linarith [c3a r hr]⟩

theorem cell4 (t : ℝ) (ha : 2.25 ≤ t) (hb : t ≤ 2.625) :
    kk * 0.995 ≤ Qf t * Real.exp (Wf t) ∧ Qf t * Real.exp (Wf t) ≤ kk * 1.005 ∧ Wf t < 0 := by
  obtain ⟨r, hr, rfl⟩ : ∃ r, |r| ≤ 1 ∧ t = 39/16 + 3/16 * r :=
    ⟨(t - 39/16) * (16/3), abs_le.mpr ⟨by linarith, by linarith⟩, by ring⟩
  have hc := cell_bound (39/16 + 3/16 * r) (-1.45) (-1.62) 0.23458 0.19789 E4h E4l (by norm_num)
    (c4a r hr) (c4b r hr) (c4c r hr) (c4d r hr)
  exact ⟨hc.1, hc.2, by linarith [c4a r hr]⟩

theorem cell5 (t : ℝ) (ha : 2.625 ≤ t) (hb : t ≤ 3) :
    kk * 0.995 ≤ Qf t * Real.exp (Wf t) ∧ Qf t * Real.exp (Wf t) ≤ kk * 1.005 ∧ Wf t < 0 := by
  obtain ⟨r, hr, rfl⟩ : ∃ r, |r| ≤ 1 ∧ t = 45/16 + 3/16 * r :=
    ⟨(t - 45/16) * (16/3), abs_le.mpr ⟨by linarith, by linarith⟩, by ring⟩
  have hc := cell_bound (45/16 + 3/16 * r) (-1.59) (-1.73) 0.20393 0.17727 E5h E5l (by norm_num)
    (c5a r hr) (c5b r hr) (c5c r hr) (c5d r hr)
  exact ⟨hc.1, hc.2, by linarith [c5a r hr]⟩

theorem pw_bound (v : ℝ) (h1 : 1 ≤ v) (h3 : v ≤ 3) :
    |Fd v - kk * Real.exp (-v^2)| ≤ 0.005 * kk * Real.exp (-v^2) ∧ Wf v < 0 := by
  have key : kk * 0.995 ≤ Qf v * Real.exp (Wf v) ∧ Qf v * Real.exp (Wf v) ≤ kk * 1.005
      ∧ Wf v < 0 := by
    rcases le_or_gt v 1.375 with ha | ha
    · exact cell1 v h1 ha
    rcases le_or_gt v 1.75 with hb | hb
    · exact cell2 v ha.le hb
    rcases le_or_gt v 2.25 with hc | hc
    · exact cell3 v hb.le hc
    rcases le_or_gt v 2.625 with hd | hd
    · exact cell4 v hc.le hd
    · exact cell5 v hd.le h3
  obtain ⟨p, q, r⟩ := key
  refine ⟨?_, r⟩
  rw [Fd_eq]
  have he := Real.exp_pos (-v^2)
  have a1 := mul_le_mul_of_nonneg_right p he.le
  have a2 := mul_le_mul_of_nonneg_right q he.le
  rw [abs_le]
  constructor <;> linarith

theorem D3_bound : |Fl 3 - VoltaChallenge.erf 3| ≤ 2.5e-5 := by
  have hX : Xl 3 * rr ≤ -10.7 := by simp only [Xl, Pl, rr]; norm_num
  have hα : Real.exp (Xl 3 * rr) ≤ 2.5e-5 := le_trans (Real.exp_le_exp.mpr hX) E107
  have hF1 : Fl 3 ≤ 1 := by unfold Fl; linarith [Real.exp_pos (Xl 3 * rr)]
  have hF2 : 1 - 2.5e-5 ≤ Fl 3 := by unfold Fl; linarith
  have hE1 := erf_le_one 3
  have hE2 := erf_tail 3 (by norm_num)
  have h9 : Real.exp (-(3:ℝ)^2) ≤ 1.24e-4 := by
    have : Real.exp (-(3:ℝ)^2) = Real.exp (-9) := by norm_num
    rw [this]; exact E9
  have hk := kk_hi
  have hk0 := kk_pos
  have hb : kk * Real.exp (-(3:ℝ)^2) / (2*3) ≤ 2.4e-5 := by
    rw [div_le_iff₀ (by norm_num)]
    have := mul_le_mul hk.le h9 (Real.exp_pos _).le (by norm_num)
    nlinarith
  rw [abs_le]; constructor <;> linarith

set_option maxHeartbeats 2000000 in
theorem mid_core (u : ℝ) (hu1 : 1 ≤ u) (hu3 : u ≤ 3) :
    |Fl u - VoltaChallenge.erf u| ≤ 2.5e-5 + 0.005 * kk / (2*u) * Real.exp (-u^2) := by
  have hu0 : 0 < u := by linarith
  have hD3 := D3_bound
  have hk0 := kk_pos
  have hc : 0 ≤ 0.005 * kk / (2*u) := by positivity
  have hψ := mono_of_deriv
    (f := fun v => Fl v - VoltaChallenge.erf v - 0.005 * kk / (2*u) * Real.exp (-v^2))
    (f' := fun v => Fd v - kk * Real.exp (-v^2)
      - 0.005 * kk / (2*u) * (-2 * v * Real.exp (-v^2))) hu3
    (fun v _ => ((Fl_deriv v).sub (erf_hasDerivAt v)).sub ((hd_gauss v).const_mul _))
    (fun v hv => by
      obtain ⟨hb, -⟩ := pw_bound v (by linarith [hv.1]) hv.2
      have he := Real.exp_pos (-v^2)
      have hvu : u ≤ v := hv.1
      show 0 ≤ Fd v - kk * Real.exp (-v^2) - 0.005 * kk / (2*u) * (-2 * v * Real.exp (-v^2))
      have e1 : 0.005 * kk / (2*u) * (-2 * v * Real.exp (-v^2))
          = -(0.005 * kk * Real.exp (-v^2) * (v / u)) := by
        field_simp
      have e2 : 0.005 * kk * Real.exp (-v^2) ≤ 0.005 * kk * Real.exp (-v^2) * (v / u) := by
        have h1 : 1 ≤ v / u := by rw [le_div_iff₀ hu0]; linarith
        exact le_mul_of_one_le_right (by positivity) h1
      rw [e1]
      have := (abs_le.mp hb).1
      linarith)
  have hφ := mono_of_deriv
    (f := fun v => -(Fl v - VoltaChallenge.erf v + 0.005 * kk / (2*u) * Real.exp (-v^2)))
    (f' := fun v => -(Fd v - kk * Real.exp (-v^2)
      + 0.005 * kk / (2*u) * (-2 * v * Real.exp (-v^2)))) hu3
    (fun v _ => (((Fl_deriv v).sub (erf_hasDerivAt v)).add ((hd_gauss v).const_mul _)).neg)
    (fun v hv => by
      obtain ⟨hb, -⟩ := pw_bound v (by linarith [hv.1]) hv.2
      have he := Real.exp_pos (-v^2)
      have hvu : u ≤ v := hv.1
      show 0 ≤ -(Fd v - kk * Real.exp (-v^2) + 0.005 * kk / (2*u) * (-2 * v * Real.exp (-v^2)))
      have e1 : 0.005 * kk / (2*u) * (-2 * v * Real.exp (-v^2))
          = -(0.005 * kk * Real.exp (-v^2) * (v / u)) := by
        field_simp
      have e2 : 0.005 * kk * Real.exp (-v^2) ≤ 0.005 * kk * Real.exp (-v^2) * (v / u) := by
        have h1 : 1 ≤ v / u := by rw [le_div_iff₀ hu0]; linarith
        exact le_mul_of_one_le_right (by positivity) h1
      rw [e1]
      have := (abs_le.mp hb).2
      linarith)
  have he9 : 0 ≤ 0.005 * kk / (2*u) * Real.exp (-(3:ℝ)^2) := mul_nonneg hc (Real.exp_pos _).le
  rw [abs_le] at hD3 ⊢
  constructor <;> linarith [hD3.1, hD3.2]

theorem tail_poly (u : ℝ) (hu : 3 ≤ u) : Xl u * rr ≤ -3.5 * u := by
  obtain ⟨s, hs, rfl⟩ : ∃ s, 0 ≤ s ∧ u = 3 + s := ⟨u - 3, by linarith, by ring⟩
  simp only [Xl, Pl, rr]
  linarith [pow_nonneg hs 2, pow_nonneg hs 3, pow_nonneg hs 4, pow_nonneg hs 5,
    pow_nonneg hs 6, pow_nonneg hs 7]

theorem absmul_le (a y c : ℝ) (hy : 0 ≤ y) (h1 : a * y ≤ c) (h2 : -c ≤ a * y) : |a| * y ≤ c := by
  calc |a| * y = |a * y| := by rw [abs_mul, abs_of_nonneg hy]
    _ ≤ c := abs_le.mpr ⟨h2, h1⟩

theorem small_core (y : ℝ) (hy : 0 ≤ y) (hs : y * cc < 1.0029599666595458984375) :
    |Asm (y * cc) - VoltaChallenge.erf (y * cp)| * y ≤ 0.002 := by
  have hc1 : (0.707106 : ℝ) ≤ cc := by unfold cc; norm_num
  have hd : cp - cc ≤ 1.3e-8 := by unfold cc cp; norm_num
  have hd0 : 0 ≤ cp - cc := by unfold cc cp; norm_num
  have hu0 : 0 ≤ y * cc := mul_nonneg hy (by linarith)
  have hu1 : y * cc ≤ 1.003 := by linarith
  have hyb : y ≤ 1.4185 := by nlinarith [mul_le_mul_of_nonneg_left hc1 hy]
  have hp := small_poly (y * cc) hu0 hu1
  have hz : y * cc ≤ y * cp := mul_le_mul_of_nonneg_left (by linarith) hy
  have hl := erf_lip hz
  have hm := erf_mono hz
  have hk := kk_hi
  have hzu : y * cp - y * cc ≤ 1.4185 * 1.3e-8 := by
    have := mul_le_mul hyb hd hd0 (by norm_num : (0:ℝ) ≤ 1.4185)
    linarith
  have hkz : kk * (y * cp - y * cc) ≤ 1.12838 * (1.4185 * 1.3e-8) :=
    mul_le_mul hk.le hzu (by linarith) (by norm_num)
  have habs : |Asm (y * cc) - VoltaChallenge.erf (y * cp)|
      ≤ 0.001 + 1.12838 * (1.4185 * 1.3e-8) := by
    rw [abs_le] at hp ⊢; constructor <;> linarith [hp.1, hp.2]
  calc |Asm (y * cc) - VoltaChallenge.erf (y * cp)| * y
      ≤ (0.001 + 1.12838 * (1.4185 * 1.3e-8)) * 1.4185 :=
        mul_le_mul habs hyb hy (by norm_num)
    _ ≤ 0.002 := by norm_num

set_option maxHeartbeats 4000000 in
theorem large_core (y : ℝ) (hy : 0 ≤ y) (hl : (1.0029599666595458984375 : ℝ) ≤ y * cc) :
    0 ≤ Fl (y * cc) ∧ |Fl (y * cc) - VoltaChallenge.erf (y * cp)| * y ≤ 0.002 := by
  have hc1 : (0.707106 : ℝ) ≤ cc := by unfold cc; norm_num
  have hc2 : cc ≤ (0.707107 : ℝ) := by unfold cc; norm_num
  have hd : cp - cc ≤ 1.3e-8 := by unfold cc cp; norm_num
  have hd0 : 0 ≤ cp - cc := by unfold cc cp; norm_num
  have hcp : (0.707106 : ℝ) ≤ cp := by linarith
  obtain ⟨u, hu⟩ : ∃ u, u = y * cc := ⟨_, rfl⟩
  obtain ⟨z, hz⟩ : ∃ z, z = y * cp := ⟨_, rfl⟩
  rw [← hu, ← hz]
  have hu1 : 1 ≤ u := by rw [hu]; linarith
  have hy0 : 0 < y := by
    rcases eq_or_lt_of_le hy with h | h
    · rw [hu, ← h] at hu1; norm_num at hu1
    · exact h
  have huz : u ≤ z := by rw [hu, hz]; exact mul_le_mul_of_nonneg_left (by linarith) hy
  have hyu : y ≤ 1.41422 * u := by rw [hu]; nlinarith [mul_le_mul_of_nonneg_left hc1 hy]
  have hk1 := kk_lo
  have hk2 := kk_hi
  have hk0 := kk_pos
  rcases le_or_gt u 3 with h3 | h3
  · obtain ⟨-, hW⟩ := pw_bound u hu1 h3
    have hX : Xl u * rr < 0 := by unfold Wf at hW; nlinarith [sq_nonneg u]
    have hF0 : 0 ≤ Fl u := by
      unfold Fl
      have := Real.exp_lt_exp.mpr hX
      rw [Real.exp_zero] at this
      linarith
    refine ⟨hF0, ?_⟩
    have hm := mid_core u hu1 h3
    have hyb : y ≤ 4.2427 := by linarith
    have hzu : z - u ≤ 4.2427 * 1.3e-8 := by
      rw [hz, hu]
      have := mul_le_mul hyb hd hd0 (by norm_num : (0:ℝ) ≤ 4.2427)
      linarith
    have hzu0 : 0 ≤ z - u := by linarith
    have hl1 := erf_lip huz
    have hl2 := erf_mono huz
    have hkz : kk * (z - u) ≤ 1.12838 * (4.2427 * 1.3e-8) :=
      mul_le_mul hk2.le hzu hzu0 (by norm_num)
    have hu2 : 1 * 1 ≤ u * u := mul_le_mul hu1 hu1 (by norm_num) (by linarith)
    have hexp : Real.exp (-u^2) ≤ 0.3678794412 := by
      have : Real.exp (-u^2) ≤ Real.exp (-1) := Real.exp_le_exp.mpr (by linarith)
      linarith [Real.exp_neg_one_lt_d9]
    have hA : |Fl u - VoltaChallenge.erf z|
        ≤ 2.5e-5 + 1.12838 * (4.2427 * 1.3e-8) + 0.005 * kk / (2*u) * Real.exp (-u^2) := by
      rw [abs_le] at hm ⊢
      constructor <;> linarith [hm.1, hm.2]
    have hcc0 : cc ≠ 0 := by linarith
    have hy0' : y ≠ 0 := hy0.ne'
    have key : 0.005 * kk / (2*u) * Real.exp (-u^2) * y
        = 0.005 * kk * Real.exp (-u^2) / (2 * cc) := by
      rw [hu]; field_simp
    have h2 : 0.005 * kk * Real.exp (-u^2) / (2 * cc)
        ≤ 0.005 * 1.12838 * 0.3678794412 / (2 * 0.707106) := by
      rw [div_le_div_iff₀ (by linarith) (by norm_num)]
      have he := Real.exp_pos (-u^2)
      have := mul_le_mul hk2.le hexp he.le (by norm_num)
      nlinarith
    calc |Fl u - VoltaChallenge.erf z| * y
        ≤ (2.5e-5 + 1.12838 * (4.2427 * 1.3e-8)
            + 0.005 * kk / (2*u) * Real.exp (-u^2)) * y :=
          mul_le_mul_of_nonneg_right hA hy
      _ = (2.5e-5 + 1.12838 * (4.2427 * 1.3e-8)) * y
            + 0.005 * kk / (2*u) * Real.exp (-u^2) * y := by ring
      _ ≤ (2.5e-5 + 1.12838 * (4.2427 * 1.3e-8)) * 4.2427
            + 0.005 * 1.12838 * 0.3678794412 / (2 * 0.707106) := by
          rw [key]
          have := mul_le_mul_of_nonneg_left hyb
            (by norm_num : (0:ℝ) ≤ 2.5e-5 + 1.12838 * (4.2427 * 1.3e-8))
          linarith
      _ ≤ 0.002 := by norm_num
  · have hX : Xl u * rr ≤ -3.5 * u := tail_poly u h3.le
    have hα : Real.exp (Xl u * rr) ≤ Real.exp (-3.5 * u) := Real.exp_le_exp.mpr hX
    have hE8 := Real.pow_div_factorial_le_exp (x := 3.5 * u) (by linarith) 8
    have h7 : (3:ℝ)^7 ≤ u^7 := pow_le_pow_left₀ (by norm_num) h3.le 7
    have hEu : 1221 * u ≤ Real.exp (3.5 * u) := by
      have e : (3.5 * u)^8 / (Nat.factorial 8 : ℝ) = (3.5^8 / 40320) * u^7 * u := by
        norm_num [Nat.factorial] <;> ring
      rw [e] at hE8
      have := mul_le_mul_of_nonneg_right h7 (by linarith : (0:ℝ) ≤ u)
      nlinarith
    have hprod : Real.exp (-3.5 * u) * Real.exp (3.5 * u) = 1 := by
      rw [← Real.exp_add]; simp
    have hep := Real.exp_pos (-3.5 * u)
    have e1 : Real.exp (-3.5 * u) * y ≤ Real.exp (-3.5 * u) * (1.41422 * u) :=
      mul_le_mul_of_nonneg_left hyu hep.le
    have e2 : Real.exp (-3.5 * u) * (1221 * u) ≤ Real.exp (-3.5 * u) * Real.exp (3.5 * u) :=
      mul_le_mul_of_nonneg_left hEu hep.le
    have e3 : Real.exp (Xl u * rr) * y ≤ Real.exp (-3.5 * u) * y :=
      mul_le_mul_of_nonneg_right hα hy
    have hαy : Real.exp (Xl u * rr) * y ≤ 0.0012 := by linarith
    have hα1 : Real.exp (Xl u * rr) < 1 := by
      have : Xl u * rr < 0 := by linarith
      have := Real.exp_lt_exp.mpr this
      rwa [Real.exp_zero] at this
    have hF0 : 0 ≤ Fl u := by unfold Fl; linarith
    refine ⟨hF0, ?_⟩
    have hz3 : 3 < z := by linarith
    have hz0 : 0 < z := by linarith
    have hT := erf_tail z hz0
    have hE1 := erf_le_one z
    have hz9 : 3 * 3 ≤ z * z := mul_le_mul hz3.le hz3.le (by norm_num) (by linarith)
    have hez : Real.exp (-z^2) ≤ Real.exp (-9) := Real.exp_le_exp.mpr (by linarith)
    have he9 := E9
    have hcp0 : cp ≠ 0 := by linarith
    have hy0' : y ≠ 0 := hy0.ne'
    have keyz : kk * Real.exp (-z^2) / (2*z) * y = kk * Real.exp (-z^2) / (2 * cp) := by
      rw [hz]; field_simp
    have hβ : kk * Real.exp (-z^2) / (2 * cp) ≤ 1.12838 * 1.24e-4 / (2 * 0.707106) := by
      rw [div_le_div_iff₀ (by linarith) (by norm_num)]
      have := mul_le_mul hk2.le (le_trans hez he9) (Real.exp_pos _).le (by norm_num)
      nlinarith
    have hβy : kk * Real.exp (-z^2) / (2*z) * y ≤ 1.12838 * 1.24e-4 / (2 * 0.707106) := by
      rw [keyz]; exact hβ
    have hFl : Fl u ≤ 1 := by unfold Fl; linarith [Real.exp_pos (Xl u * rr)]
    have hFl2 : 1 - Real.exp (Xl u * rr) ≤ Fl u := by unfold Fl; linarith
    apply absmul_le _ _ _ hy
    · have h1 : Fl u - VoltaChallenge.erf z ≤ kk * Real.exp (-z^2) / (2*z) := by linarith
      have := mul_le_mul_of_nonneg_right h1 hy
      have h2 : (1.12838 : ℝ) * 1.24e-4 / (2 * 0.707106) ≤ 0.002 := by norm_num
      linarith
    · have h1 : -(Fl u - VoltaChallenge.erf z) ≤ Real.exp (Xl u * rr) := by linarith
      have := mul_le_mul_of_nonneg_right h1 hy
      linarith

theorem half_abs (x A E : ℝ) :
    |(x * (0.5:ℝ)) * (A + (1:ℝ)) - ((0.5:ℝ) * x) * ((1:ℝ) + E)| = |A - E| * |x| * 0.5 := by
  rw [show (x * (0.5:ℝ)) * (A + (1:ℝ)) - ((0.5:ℝ) * x) * ((1:ℝ) + E) = (A - E) * x * 0.5 by ring,
    abs_mul, abs_mul, abs_of_pos (by norm_num : (0:ℝ) < 0.5)]

theorem Asm_neg (t : ℝ) : Asm (-t) = -Asm t := by unfold Asm; ring

theorem key_small (x0 x1 x2 : ℝ) (h1 : x1 = x0 * cc) (h2 : x2 = |x1|)
    (hs : x2 < (1.0029599666595458984375 : ℝ)) :
    |(x0 * (0.5 : ℝ)) * (Asm x1 + (1 : ℝ)) - ((0.5 : ℝ) * x0) *
      ((1 : ℝ) + VoltaChallenge.erf (x0 * cp))| ≤ (0.001 : ℝ) := by
  subst h1 h2
  rw [half_abs]
  have hcc : 0 < cc := by unfold cc; norm_num
  rcases le_total 0 x0 with hx | hx
  · have hu : 0 ≤ x0 * cc := mul_nonneg hx hcc.le
    rw [abs_of_nonneg hu] at hs
    have := small_core x0 hx hs
    rw [abs_of_nonneg hx]
    linarith
  · have hy : 0 ≤ -x0 := by linarith
    have e1 : x0 * cc = -((-x0) * cc) := by ring
    have e2 : x0 * cp = -((-x0) * cp) := by ring
    rw [e1, abs_neg, abs_of_nonneg (mul_nonneg hy hcc.le)] at hs
    have := small_core (-x0) hy hs
    rw [e1, e2, Asm_neg, erf_neg, abs_of_nonpos hx, neg_sub_neg, abs_sub_comm]
    linarith

theorem key_large (x0 x1 x2 : ℝ) (h1 : x1 = x0 * cc) (h2 : x2 = |x1|)
    (hl : (1.0029599666595458984375 : ℝ) ≤ x2) :
    |(x0 * (0.5 : ℝ)) * ((if x1 < (0 : ℝ) then -(|Fl x2|) else Fl x2) + (1 : ℝ)) -
      ((0.5 : ℝ) * x0) * ((1 : ℝ) + VoltaChallenge.erf (x0 * cp))| ≤ (0.001 : ℝ) := by
  subst h1 h2
  have hcc : 0 < cc := by unfold cc; norm_num
  rcases le_or_gt 0 x0 with hx | hx
  · have hu : 0 ≤ x0 * cc := mul_nonneg hx hcc.le
    rw [if_neg (not_lt.mpr hu), half_abs]
    rw [abs_of_nonneg hu] at hl ⊢
    obtain ⟨-, hb⟩ := large_core x0 hx hl
    rw [abs_of_nonneg hx]
    linarith
  · have hu : x0 * cc < 0 := mul_neg_of_neg_of_pos hx hcc
    rw [if_pos hu, half_abs]
    have hy : 0 ≤ -x0 := by linarith
    have e1 : x0 * cc = -((-x0) * cc) := by ring
    have e2 : x0 * cp = -((-x0) * cp) := by ring
    rw [e1, abs_neg, abs_of_nonneg (mul_nonneg hy hcc.le)] at hl ⊢
    obtain ⟨hF, hb⟩ := large_core (-x0) hy hl
    rw [abs_of_nonneg hF, e2, erf_neg, abs_of_neg hx, neg_sub_neg, abs_sub_comm]
    linarith

theorem x5_small (x1 x2 x3 x4 : ℝ)
    (h3 : x3 = if x2 ≥ (1.0029599666595458984375 : ℝ) then x2 else x1 * x1)
    (h4 : x4 = if x2 ≥ (1.0029599666595458984375 : ℝ) then -x2 else x1)
    (hs : ¬ (x2 ≥ (1.0029599666595458984375 : ℝ))) :
    ((((((((((((((if x2 ≥ (1.0029599666595458984375 : ℝ) then (7710237 / 2 ^ 36 : ℝ) else (5829813 / 2 ^ 36 : ℝ)) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (-11403355 / 2 ^ 33 : ℝ) else (-440937 / 2 ^ 29 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (9015711 / 2 ^ 30 : ℝ) else (5597941 / 2 ^ 30 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (-5401805 / 2 ^ 27 : ℝ) else (-14425063 / 2 ^ 29 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (10704153 / 2 ^ 26 : ℝ) else (15145135 / 2 ^ 27 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (15316217 / 2 ^ 24 : ℝ) else (-3155179 / 2 ^ 23 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (0.6290600299835205078125 : ℝ) else (8615379 / 2 ^ 26 : ℝ))) * x4) + x4 = Asm x1 := by
  subst h3 h4
  repeat rw [if_neg hs]
  unfold Asm
  ring

theorem x5_large (x1 x2 x3 x4 : ℝ)
    (h3 : x3 = if x2 ≥ (1.0029599666595458984375 : ℝ) then x2 else x1 * x1)
    (h4 : x4 = if x2 ≥ (1.0029599666595458984375 : ℝ) then -x2 else x1)
    (hl : x2 ≥ (1.0029599666595458984375 : ℝ)) :
    ((((((((((((((if x2 ≥ (1.0029599666595458984375 : ℝ) then (7710237 / 2 ^ 36 : ℝ) else (5829813 / 2 ^ 36 : ℝ)) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (-11403355 / 2 ^ 33 : ℝ) else (-440937 / 2 ^ 29 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (9015711 / 2 ^ 30 : ℝ) else (5597941 / 2 ^ 30 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (-5401805 / 2 ^ 27 : ℝ) else (-14425063 / 2 ^ 29 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (10704153 / 2 ^ 26 : ℝ) else (15145135 / 2 ^ 27 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (15316217 / 2 ^ 24 : ℝ) else (-3155179 / 2 ^ 23 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (0.6290600299835205078125 : ℝ) else (8615379 / 2 ^ 26 : ℝ))) * x4) + x4 = Xl x2 := by
  subst h3 h4
  repeat rw [if_pos hl]
  unfold Xl Pl
  ring

set_option maxHeartbeats 2000000 in
theorem main (x0 x7 : ℝ) (h : x0 = x7) :
    let x1 := x0 * (11863283 / 2 ^ 24 : ℝ)
    let x2 := |x1|
    let x3 := if x2 ≥ (1.0029599666595458984375 : ℝ) then x2 else x1 * x1
    let x4 := if x2 ≥ (1.0029599666595458984375 : ℝ) then -x2 else x1
    let x5 := ((((((((((((((if x2 ≥ (1.0029599666595458984375 : ℝ) then (7710237 / 2 ^ 36 : ℝ) else (5829813 / 2 ^ 36 : ℝ)) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (-11403355 / 2 ^ 33 : ℝ) else (-440937 / 2 ^ 29 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (9015711 / 2 ^ 30 : ℝ) else (5597941 / 2 ^ 30 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (-5401805 / 2 ^ 27 : ℝ) else (-14425063 / 2 ^ 29 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (10704153 / 2 ^ 26 : ℝ) else (15145135 / 2 ^ 27 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (15316217 / 2 ^ 24 : ℝ) else (-3155179 / 2 ^ 23 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (0.6290600299835205078125 : ℝ) else (8615379 / 2 ^ 26 : ℝ))) * x4) + x4
    let x6 := (1 : ℝ) - Real.exp (x5 * (8388608 / 12102203 : ℝ))
    |((x0 * (0.5 : ℝ)) * ((if x2 < (1.0029599666595458984375 : ℝ) then x5 else if x1 < (0 : ℝ) then -(|x6|) else x6) + (1 : ℝ))) - (((0.5 : ℝ) * x7) * ((1 : ℝ) + VoltaChallenge.erf (x7 * (6369051672525773 / 2 ^ 53 : ℝ))))| ≤ (0.001 : ℝ) := by
  subst h
  intro x1 x2 x3 x4 x5 x6
  by_cases hs : x2 < (1.0029599666595458984375 : ℝ)
  · have hs' : ¬ (x2 ≥ (1.0029599666595458984375 : ℝ)) := not_le.mpr hs
    have e5 : x5 = Asm x1 := x5_small x1 x2 x3 x4 rfl rfl hs'
    rw [if_pos hs, e5]
    exact key_small x0 x1 x2 rfl rfl hs
  · have hl : (1.0029599666595458984375 : ℝ) ≤ x2 := not_lt.mp hs
    have e5 : x5 = Xl x2 := x5_large x1 x2 x3 x4 rfl rfl hl
    have e6 : x6 = Fl x2 := by
      show (1 : ℝ) - Real.exp (x5 * (8388608 / 12102203 : ℝ)) = Fl x2
      rw [e5]
      rfl
    rw [if_neg hs, e6]
    exact key_large x0 x1 x2 rfl rfl hl

set_option maxRecDepth 100000 in
set_option maxHeartbeats 4000000 in
theorem c_0 : VoltaChallenge.c_0 := by
  unfold VoltaChallenge.c_0
  intro v0 v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46 v47 v48 v49 v50 v51 v52 v53 v54 v55 v56 v57 v58 v59 v60 v61 v62 v63 v64 v65 v66 v67 v68 v69 v70 v71 v72 v73 v74 v75 v76 v77 v78 v79 v80 v81 v82 v83 v84 v85 v86 v87 v88 v89 v90 v91 v92 v93 v94 v95 v96 v97 v98 v99 v100 v101 v102 v103 v104 v105 v106 v107 v108 v109 v110 v111 v112 v113 v114 v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 v133 v134 v135 v136 v137 v138 v139 v140 v141 v142 v143 v144 v145 v146 v147 v148 v149 v150 v151 v152 v153 v154 v155 v156 v157 v158 v159 v160 v161 v162 v163 v164 v165 v166 v167 v168 v169 v170 v171 v172 v173 v174 v175 v176 v177 v178 v179 v180 v181 v182 v183 v184 v185 v186 v187 v188 v189 v190 v191 v192 v193 v194 v195 v196 v197 v198 v199 v200 v201 v202 v203 v204 v205 v206 v207 v208 v209 v210 v211 v212 v213 v214 v215 v216 v217 v218 v219 v220 v221 v222 v223 v224 v225 v226 v227 v228 v229 v230 v231 v232 v233 v234 v235 v236 v237 v238 v239 v240 v241 v242 v243 v244 v245 v246 v247 v248 v249 v250 v251 v252 v253 v254 v255 v256 v257 v258 v259 v260 v261 v262 v263 v264 v265 v266 v267 v268 v269 v270 v271 v272 v273 v274 v275 v276 v277 v278 v279 v280 v281 v282 v283 v284 v285 v286 v287 v288 v289 v290 v291 v292 v293 v294 v295 v296 v297 v298 v299 v300 v301 v302 v303 v304 v305 v306 v307 v308 v309 v310 v311 v312 v313 v314 v315 v316 v317 v318 v319 v320 v321 v322 v323 v324 v325 v326 v327 v328 v329 v330 v331 v332 v333 v334 v335 v336 v337 v338 v339 v340 v341 v342 v343 v344 v345 v346 v347 v348 v349 v350 v351 v352 v353 v354 v355 v356 v357 v358 v359 v360 v361 v362 v363 v364 v365 v366 v367 v368 v369 v370 v371 v372 v373 v374 v375 v376 v377 v378 v379 v380 v381 v382 v383 v384 v385 v386 v387 v388 v389 v390 v391 v392 v393 v394 v395 v396 v397 v398 v399 v400 v401 v402 v403 v404 v405 v406 v407 v408 v409 v410 v411 v412 v413 v414 v415 v416 v417 v418 v419 v420 v421 v422 v423 v424 v425 v426 v427 v428 v429 v430 v431 v432 v433 v434 v435 v436 v437 v438 v439 v440 v441 v442 v443 v444 v445 v446 v447 v448 v449 v450 v451 v452 v453 v454 v455 v456 v457 v458 v459 v460 v461 v462 v463 v464 v465 v466 v467 v468 v469 v470 v471 v472 v473 v474 v475 v476 v477 v478 v479 v480 v481 v482 v483 v484 v485 v486 v487 v488 v489 v490 v491 v492 v493 v494 v495 v496 v497 v498 v499 v500 v501 v502 v503 v504 v505 v506 v507 v508 v509 v510 v511
  exact main _ _ (by ring)
set_option maxRecDepth 100000 in
set_option maxHeartbeats 4000000 in
theorem c_1 : VoltaChallenge.c_1 := by
  unfold VoltaChallenge.c_1
  intro v0 v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46 v47 v48 v49 v50 v51 v52 v53 v54 v55 v56 v57 v58 v59 v60 v61 v62 v63 v64 v65 v66 v67 v68 v69 v70 v71 v72 v73 v74 v75 v76 v77 v78 v79 v80 v81 v82 v83 v84 v85 v86 v87 v88 v89 v90 v91 v92 v93 v94 v95 v96 v97 v98 v99 v100 v101 v102 v103 v104 v105 v106 v107 v108 v109 v110 v111 v112 v113 v114 v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 v133 v134 v135 v136 v137 v138 v139 v140 v141 v142 v143 v144 v145 v146 v147 v148 v149 v150 v151 v152 v153 v154 v155 v156 v157 v158 v159 v160 v161 v162 v163 v164 v165 v166 v167 v168 v169 v170 v171 v172 v173 v174 v175 v176 v177 v178 v179 v180 v181 v182 v183 v184 v185 v186 v187 v188 v189 v190 v191 v192 v193 v194 v195 v196 v197 v198 v199 v200 v201 v202 v203 v204 v205 v206 v207 v208 v209 v210 v211 v212 v213 v214 v215 v216 v217 v218 v219 v220 v221 v222 v223 v224 v225 v226 v227 v228 v229 v230 v231 v232 v233 v234 v235 v236 v237 v238 v239 v240 v241 v242 v243 v244 v245 v246 v247 v248 v249 v250 v251 v252 v253 v254 v255 v256 v257 v258 v259 v260 v261 v262 v263 v264 v265 v266 v267 v268 v269 v270 v271 v272 v273 v274 v275 v276 v277 v278 v279 v280 v281 v282 v283 v284 v285 v286 v287 v288 v289 v290 v291 v292 v293 v294 v295 v296 v297 v298 v299 v300 v301 v302 v303 v304 v305 v306 v307 v308 v309 v310 v311 v312 v313 v314 v315 v316 v317 v318 v319 v320 v321 v322 v323 v324 v325 v326 v327 v328 v329 v330 v331 v332 v333 v334 v335 v336 v337 v338 v339 v340 v341 v342 v343 v344 v345 v346 v347 v348 v349 v350 v351 v352 v353 v354 v355 v356 v357 v358 v359 v360 v361 v362 v363 v364 v365 v366 v367 v368 v369 v370 v371 v372 v373 v374 v375 v376 v377 v378 v379 v380 v381 v382 v383 v384 v385 v386 v387 v388 v389 v390 v391 v392 v393 v394 v395 v396 v397 v398 v399 v400 v401 v402 v403 v404 v405 v406 v407 v408 v409 v410 v411 v412 v413 v414 v415 v416 v417 v418 v419 v420 v421 v422 v423 v424 v425 v426 v427 v428 v429 v430 v431 v432 v433 v434 v435 v436 v437 v438 v439 v440 v441 v442 v443 v444 v445 v446 v447 v448 v449 v450 v451 v452 v453 v454 v455 v456 v457 v458 v459 v460 v461 v462 v463 v464 v465 v466 v467 v468 v469 v470 v471 v472 v473 v474 v475 v476 v477 v478 v479 v480 v481 v482 v483 v484 v485 v486 v487 v488 v489 v490 v491 v492 v493 v494 v495 v496 v497 v498 v499 v500 v501 v502 v503 v504 v505 v506 v507 v508 v509 v510 v511
  exact main _ _ (by ring)
set_option maxRecDepth 100000 in
set_option maxHeartbeats 4000000 in
theorem c_16 : VoltaChallenge.c_16 := by
  unfold VoltaChallenge.c_16
  intro v0 v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46 v47 v48 v49 v50 v51 v52 v53 v54 v55 v56 v57 v58 v59 v60 v61 v62 v63 v64 v65 v66 v67 v68 v69 v70 v71 v72 v73 v74 v75 v76 v77 v78 v79 v80 v81 v82 v83 v84 v85 v86 v87 v88 v89 v90 v91 v92 v93 v94 v95 v96 v97 v98 v99 v100 v101 v102 v103 v104 v105 v106 v107 v108 v109 v110 v111 v112 v113 v114 v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 v133 v134 v135 v136 v137 v138 v139 v140 v141 v142 v143 v144 v145 v146 v147 v148 v149 v150 v151 v152 v153 v154 v155 v156 v157 v158 v159 v160 v161 v162 v163 v164 v165 v166 v167 v168 v169 v170 v171 v172 v173 v174 v175 v176 v177 v178 v179 v180 v181 v182 v183 v184 v185 v186 v187 v188 v189 v190 v191 v192 v193 v194 v195 v196 v197 v198 v199 v200 v201 v202 v203 v204 v205 v206 v207 v208 v209 v210 v211 v212 v213 v214 v215 v216 v217 v218 v219 v220 v221 v222 v223 v224 v225 v226 v227 v228 v229 v230 v231 v232 v233 v234 v235 v236 v237 v238 v239 v240 v241 v242 v243 v244 v245 v246 v247 v248 v249 v250 v251 v252 v253 v254 v255 v256 v257 v258 v259 v260 v261 v262 v263 v264 v265 v266 v267 v268 v269 v270 v271 v272 v273 v274 v275 v276 v277 v278 v279 v280 v281 v282 v283 v284 v285 v286 v287 v288 v289 v290 v291 v292 v293 v294 v295 v296 v297 v298 v299 v300 v301 v302 v303 v304 v305 v306 v307 v308 v309 v310 v311 v312 v313 v314 v315 v316 v317 v318 v319 v320 v321 v322 v323 v324 v325 v326 v327 v328 v329 v330 v331 v332 v333 v334 v335 v336 v337 v338 v339 v340 v341 v342 v343 v344 v345 v346 v347 v348 v349 v350 v351 v352 v353 v354 v355 v356 v357 v358 v359 v360 v361 v362 v363 v364 v365 v366 v367 v368 v369 v370 v371 v372 v373 v374 v375 v376 v377 v378 v379 v380 v381 v382 v383 v384 v385 v386 v387 v388 v389 v390 v391 v392 v393 v394 v395 v396 v397 v398 v399 v400 v401 v402 v403 v404 v405 v406 v407 v408 v409 v410 v411 v412 v413 v414 v415 v416 v417 v418 v419 v420 v421 v422 v423 v424 v425 v426 v427 v428 v429 v430 v431 v432 v433 v434 v435 v436 v437 v438 v439 v440 v441 v442 v443 v444 v445 v446 v447 v448 v449 v450 v451 v452 v453 v454 v455 v456 v457 v458 v459 v460 v461 v462 v463 v464 v465 v466 v467 v468 v469 v470 v471 v472 v473 v474 v475 v476 v477 v478 v479 v480 v481 v482 v483 v484 v485 v486 v487 v488 v489 v490 v491 v492 v493 v494 v495 v496 v497 v498 v499 v500 v501 v502 v503 v504 v505 v506 v507 v508 v509 v510 v511
  exact main _ _ (by ring)
set_option maxRecDepth 100000 in
set_option maxHeartbeats 4000000 in
theorem c_256 : VoltaChallenge.c_256 := by
  unfold VoltaChallenge.c_256
  intro v0 v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46 v47 v48 v49 v50 v51 v52 v53 v54 v55 v56 v57 v58 v59 v60 v61 v62 v63 v64 v65 v66 v67 v68 v69 v70 v71 v72 v73 v74 v75 v76 v77 v78 v79 v80 v81 v82 v83 v84 v85 v86 v87 v88 v89 v90 v91 v92 v93 v94 v95 v96 v97 v98 v99 v100 v101 v102 v103 v104 v105 v106 v107 v108 v109 v110 v111 v112 v113 v114 v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 v133 v134 v135 v136 v137 v138 v139 v140 v141 v142 v143 v144 v145 v146 v147 v148 v149 v150 v151 v152 v153 v154 v155 v156 v157 v158 v159 v160 v161 v162 v163 v164 v165 v166 v167 v168 v169 v170 v171 v172 v173 v174 v175 v176 v177 v178 v179 v180 v181 v182 v183 v184 v185 v186 v187 v188 v189 v190 v191 v192 v193 v194 v195 v196 v197 v198 v199 v200 v201 v202 v203 v204 v205 v206 v207 v208 v209 v210 v211 v212 v213 v214 v215 v216 v217 v218 v219 v220 v221 v222 v223 v224 v225 v226 v227 v228 v229 v230 v231 v232 v233 v234 v235 v236 v237 v238 v239 v240 v241 v242 v243 v244 v245 v246 v247 v248 v249 v250 v251 v252 v253 v254 v255 v256 v257 v258 v259 v260 v261 v262 v263 v264 v265 v266 v267 v268 v269 v270 v271 v272 v273 v274 v275 v276 v277 v278 v279 v280 v281 v282 v283 v284 v285 v286 v287 v288 v289 v290 v291 v292 v293 v294 v295 v296 v297 v298 v299 v300 v301 v302 v303 v304 v305 v306 v307 v308 v309 v310 v311 v312 v313 v314 v315 v316 v317 v318 v319 v320 v321 v322 v323 v324 v325 v326 v327 v328 v329 v330 v331 v332 v333 v334 v335 v336 v337 v338 v339 v340 v341 v342 v343 v344 v345 v346 v347 v348 v349 v350 v351 v352 v353 v354 v355 v356 v357 v358 v359 v360 v361 v362 v363 v364 v365 v366 v367 v368 v369 v370 v371 v372 v373 v374 v375 v376 v377 v378 v379 v380 v381 v382 v383 v384 v385 v386 v387 v388 v389 v390 v391 v392 v393 v394 v395 v396 v397 v398 v399 v400 v401 v402 v403 v404 v405 v406 v407 v408 v409 v410 v411 v412 v413 v414 v415 v416 v417 v418 v419 v420 v421 v422 v423 v424 v425 v426 v427 v428 v429 v430 v431 v432 v433 v434 v435 v436 v437 v438 v439 v440 v441 v442 v443 v444 v445 v446 v447 v448 v449 v450 v451 v452 v453 v454 v455 v456 v457 v458 v459 v460 v461 v462 v463 v464 v465 v466 v467 v468 v469 v470 v471 v472 v473 v474 v475 v476 v477 v478 v479 v480 v481 v482 v483 v484 v485 v486 v487 v488 v489 v490 v491 v492 v493 v494 v495 v496 v497 v498 v499 v500 v501 v502 v503 v504 v505 v506 v507 v508 v509 v510 v511
  exact main _ _ (by ring)
set_option maxRecDepth 100000 in
set_option maxHeartbeats 4000000 in
theorem c_272 : VoltaChallenge.c_272 := by
  unfold VoltaChallenge.c_272
  intro v0 v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46 v47 v48 v49 v50 v51 v52 v53 v54 v55 v56 v57 v58 v59 v60 v61 v62 v63 v64 v65 v66 v67 v68 v69 v70 v71 v72 v73 v74 v75 v76 v77 v78 v79 v80 v81 v82 v83 v84 v85 v86 v87 v88 v89 v90 v91 v92 v93 v94 v95 v96 v97 v98 v99 v100 v101 v102 v103 v104 v105 v106 v107 v108 v109 v110 v111 v112 v113 v114 v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 v133 v134 v135 v136 v137 v138 v139 v140 v141 v142 v143 v144 v145 v146 v147 v148 v149 v150 v151 v152 v153 v154 v155 v156 v157 v158 v159 v160 v161 v162 v163 v164 v165 v166 v167 v168 v169 v170 v171 v172 v173 v174 v175 v176 v177 v178 v179 v180 v181 v182 v183 v184 v185 v186 v187 v188 v189 v190 v191 v192 v193 v194 v195 v196 v197 v198 v199 v200 v201 v202 v203 v204 v205 v206 v207 v208 v209 v210 v211 v212 v213 v214 v215 v216 v217 v218 v219 v220 v221 v222 v223 v224 v225 v226 v227 v228 v229 v230 v231 v232 v233 v234 v235 v236 v237 v238 v239 v240 v241 v242 v243 v244 v245 v246 v247 v248 v249 v250 v251 v252 v253 v254 v255 v256 v257 v258 v259 v260 v261 v262 v263 v264 v265 v266 v267 v268 v269 v270 v271 v272 v273 v274 v275 v276 v277 v278 v279 v280 v281 v282 v283 v284 v285 v286 v287 v288 v289 v290 v291 v292 v293 v294 v295 v296 v297 v298 v299 v300 v301 v302 v303 v304 v305 v306 v307 v308 v309 v310 v311 v312 v313 v314 v315 v316 v317 v318 v319 v320 v321 v322 v323 v324 v325 v326 v327 v328 v329 v330 v331 v332 v333 v334 v335 v336 v337 v338 v339 v340 v341 v342 v343 v344 v345 v346 v347 v348 v349 v350 v351 v352 v353 v354 v355 v356 v357 v358 v359 v360 v361 v362 v363 v364 v365 v366 v367 v368 v369 v370 v371 v372 v373 v374 v375 v376 v377 v378 v379 v380 v381 v382 v383 v384 v385 v386 v387 v388 v389 v390 v391 v392 v393 v394 v395 v396 v397 v398 v399 v400 v401 v402 v403 v404 v405 v406 v407 v408 v409 v410 v411 v412 v413 v414 v415 v416 v417 v418 v419 v420 v421 v422 v423 v424 v425 v426 v427 v428 v429 v430 v431 v432 v433 v434 v435 v436 v437 v438 v439 v440 v441 v442 v443 v444 v445 v446 v447 v448 v449 v450 v451 v452 v453 v454 v455 v456 v457 v458 v459 v460 v461 v462 v463 v464 v465 v466 v467 v468 v469 v470 v471 v472 v473 v474 v475 v476 v477 v478 v479 v480 v481 v482 v483 v484 v485 v486 v487 v488 v489 v490 v491 v492 v493 v494 v495 v496 v497 v498 v499 v500 v501 v502 v503 v504 v505 v506 v507 v508 v509 v510 v511
  exact main _ _ (by ring)
set_option maxRecDepth 100000 in
set_option maxHeartbeats 4000000 in
theorem c_1024 : VoltaChallenge.c_1024 := by
  unfold VoltaChallenge.c_1024
  intro v0 v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46 v47 v48 v49 v50 v51 v52 v53 v54 v55 v56 v57 v58 v59 v60 v61 v62 v63 v64 v65 v66 v67 v68 v69 v70 v71 v72 v73 v74 v75 v76 v77 v78 v79 v80 v81 v82 v83 v84 v85 v86 v87 v88 v89 v90 v91 v92 v93 v94 v95 v96 v97 v98 v99 v100 v101 v102 v103 v104 v105 v106 v107 v108 v109 v110 v111 v112 v113 v114 v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 v133 v134 v135 v136 v137 v138 v139 v140 v141 v142 v143 v144 v145 v146 v147 v148 v149 v150 v151 v152 v153 v154 v155 v156 v157 v158 v159 v160 v161 v162 v163 v164 v165 v166 v167 v168 v169 v170 v171 v172 v173 v174 v175 v176 v177 v178 v179 v180 v181 v182 v183 v184 v185 v186 v187 v188 v189 v190 v191 v192 v193 v194 v195 v196 v197 v198 v199 v200 v201 v202 v203 v204 v205 v206 v207 v208 v209 v210 v211 v212 v213 v214 v215 v216 v217 v218 v219 v220 v221 v222 v223 v224 v225 v226 v227 v228 v229 v230 v231 v232 v233 v234 v235 v236 v237 v238 v239 v240 v241 v242 v243 v244 v245 v246 v247 v248 v249 v250 v251 v252 v253 v254 v255 v256 v257 v258 v259 v260 v261 v262 v263 v264 v265 v266 v267 v268 v269 v270 v271 v272 v273 v274 v275 v276 v277 v278 v279 v280 v281 v282 v283 v284 v285 v286 v287 v288 v289 v290 v291 v292 v293 v294 v295 v296 v297 v298 v299 v300 v301 v302 v303 v304 v305 v306 v307 v308 v309 v310 v311 v312 v313 v314 v315 v316 v317 v318 v319 v320 v321 v322 v323 v324 v325 v326 v327 v328 v329 v330 v331 v332 v333 v334 v335 v336 v337 v338 v339 v340 v341 v342 v343 v344 v345 v346 v347 v348 v349 v350 v351 v352 v353 v354 v355 v356 v357 v358 v359 v360 v361 v362 v363 v364 v365 v366 v367 v368 v369 v370 v371 v372 v373 v374 v375 v376 v377 v378 v379 v380 v381 v382 v383 v384 v385 v386 v387 v388 v389 v390 v391 v392 v393 v394 v395 v396 v397 v398 v399 v400 v401 v402 v403 v404 v405 v406 v407 v408 v409 v410 v411 v412 v413 v414 v415 v416 v417 v418 v419 v420 v421 v422 v423 v424 v425 v426 v427 v428 v429 v430 v431 v432 v433 v434 v435 v436 v437 v438 v439 v440 v441 v442 v443 v444 v445 v446 v447 v448 v449 v450 v451 v452 v453 v454 v455 v456 v457 v458 v459 v460 v461 v462 v463 v464 v465 v466 v467 v468 v469 v470 v471 v472 v473 v474 v475 v476 v477 v478 v479 v480 v481 v482 v483 v484 v485 v486 v487 v488 v489 v490 v491 v492 v493 v494 v495 v496 v497 v498 v499 v500 v501 v502 v503 v504 v505 v506 v507 v508 v509 v510 v511
  exact main _ _ (by ring)
set_option maxRecDepth 100000 in
set_option maxHeartbeats 4000000 in
theorem c_1025 : VoltaChallenge.c_1025 := by
  unfold VoltaChallenge.c_1025
  intro v0 v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46 v47 v48 v49 v50 v51 v52 v53 v54 v55 v56 v57 v58 v59 v60 v61 v62 v63 v64 v65 v66 v67 v68 v69 v70 v71 v72 v73 v74 v75 v76 v77 v78 v79 v80 v81 v82 v83 v84 v85 v86 v87 v88 v89 v90 v91 v92 v93 v94 v95 v96 v97 v98 v99 v100 v101 v102 v103 v104 v105 v106 v107 v108 v109 v110 v111 v112 v113 v114 v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 v133 v134 v135 v136 v137 v138 v139 v140 v141 v142 v143 v144 v145 v146 v147 v148 v149 v150 v151 v152 v153 v154 v155 v156 v157 v158 v159 v160 v161 v162 v163 v164 v165 v166 v167 v168 v169 v170 v171 v172 v173 v174 v175 v176 v177 v178 v179 v180 v181 v182 v183 v184 v185 v186 v187 v188 v189 v190 v191 v192 v193 v194 v195 v196 v197 v198 v199 v200 v201 v202 v203 v204 v205 v206 v207 v208 v209 v210 v211 v212 v213 v214 v215 v216 v217 v218 v219 v220 v221 v222 v223 v224 v225 v226 v227 v228 v229 v230 v231 v232 v233 v234 v235 v236 v237 v238 v239 v240 v241 v242 v243 v244 v245 v246 v247 v248 v249 v250 v251 v252 v253 v254 v255 v256 v257 v258 v259 v260 v261 v262 v263 v264 v265 v266 v267 v268 v269 v270 v271 v272 v273 v274 v275 v276 v277 v278 v279 v280 v281 v282 v283 v284 v285 v286 v287 v288 v289 v290 v291 v292 v293 v294 v295 v296 v297 v298 v299 v300 v301 v302 v303 v304 v305 v306 v307 v308 v309 v310 v311 v312 v313 v314 v315 v316 v317 v318 v319 v320 v321 v322 v323 v324 v325 v326 v327 v328 v329 v330 v331 v332 v333 v334 v335 v336 v337 v338 v339 v340 v341 v342 v343 v344 v345 v346 v347 v348 v349 v350 v351 v352 v353 v354 v355 v356 v357 v358 v359 v360 v361 v362 v363 v364 v365 v366 v367 v368 v369 v370 v371 v372 v373 v374 v375 v376 v377 v378 v379 v380 v381 v382 v383 v384 v385 v386 v387 v388 v389 v390 v391 v392 v393 v394 v395 v396 v397 v398 v399 v400 v401 v402 v403 v404 v405 v406 v407 v408 v409 v410 v411 v412 v413 v414 v415 v416 v417 v418 v419 v420 v421 v422 v423 v424 v425 v426 v427 v428 v429 v430 v431 v432 v433 v434 v435 v436 v437 v438 v439 v440 v441 v442 v443 v444 v445 v446 v447 v448 v449 v450 v451 v452 v453 v454 v455 v456 v457 v458 v459 v460 v461 v462 v463 v464 v465 v466 v467 v468 v469 v470 v471 v472 v473 v474 v475 v476 v477 v478 v479 v480 v481 v482 v483 v484 v485 v486 v487 v488 v489 v490 v491 v492 v493 v494 v495 v496 v497 v498 v499 v500 v501 v502 v503 v504 v505 v506 v507 v508 v509 v510 v511
  exact main _ _ (by ring)
set_option maxRecDepth 100000 in
set_option maxHeartbeats 4000000 in
theorem c_3104 : VoltaChallenge.c_3104 := by
  unfold VoltaChallenge.c_3104
  intro v0 v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46 v47 v48 v49 v50 v51 v52 v53 v54 v55 v56 v57 v58 v59 v60 v61 v62 v63 v64 v65 v66 v67 v68 v69 v70 v71 v72 v73 v74 v75 v76 v77 v78 v79 v80 v81 v82 v83 v84 v85 v86 v87 v88 v89 v90 v91 v92 v93 v94 v95 v96 v97 v98 v99 v100 v101 v102 v103 v104 v105 v106 v107 v108 v109 v110 v111 v112 v113 v114 v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 v133 v134 v135 v136 v137 v138 v139 v140 v141 v142 v143 v144 v145 v146 v147 v148 v149 v150 v151 v152 v153 v154 v155 v156 v157 v158 v159 v160 v161 v162 v163 v164 v165 v166 v167 v168 v169 v170 v171 v172 v173 v174 v175 v176 v177 v178 v179 v180 v181 v182 v183 v184 v185 v186 v187 v188 v189 v190 v191 v192 v193 v194 v195 v196 v197 v198 v199 v200 v201 v202 v203 v204 v205 v206 v207 v208 v209 v210 v211 v212 v213 v214 v215 v216 v217 v218 v219 v220 v221 v222 v223 v224 v225 v226 v227 v228 v229 v230 v231 v232 v233 v234 v235 v236 v237 v238 v239 v240 v241 v242 v243 v244 v245 v246 v247 v248 v249 v250 v251 v252 v253 v254 v255 v256 v257 v258 v259 v260 v261 v262 v263 v264 v265 v266 v267 v268 v269 v270 v271 v272 v273 v274 v275 v276 v277 v278 v279 v280 v281 v282 v283 v284 v285 v286 v287 v288 v289 v290 v291 v292 v293 v294 v295 v296 v297 v298 v299 v300 v301 v302 v303 v304 v305 v306 v307 v308 v309 v310 v311 v312 v313 v314 v315 v316 v317 v318 v319 v320 v321 v322 v323 v324 v325 v326 v327 v328 v329 v330 v331 v332 v333 v334 v335 v336 v337 v338 v339 v340 v341 v342 v343 v344 v345 v346 v347 v348 v349 v350 v351 v352 v353 v354 v355 v356 v357 v358 v359 v360 v361 v362 v363 v364 v365 v366 v367 v368 v369 v370 v371 v372 v373 v374 v375 v376 v377 v378 v379 v380 v381 v382 v383 v384 v385 v386 v387 v388 v389 v390 v391 v392 v393 v394 v395 v396 v397 v398 v399 v400 v401 v402 v403 v404 v405 v406 v407 v408 v409 v410 v411 v412 v413 v414 v415 v416 v417 v418 v419 v420 v421 v422 v423 v424 v425 v426 v427 v428 v429 v430 v431 v432 v433 v434 v435 v436 v437 v438 v439 v440 v441 v442 v443 v444 v445 v446 v447 v448 v449 v450 v451 v452 v453 v454 v455 v456 v457 v458 v459 v460 v461 v462 v463 v464 v465 v466 v467 v468 v469 v470 v471 v472 v473 v474 v475 v476 v477 v478 v479 v480 v481 v482 v483 v484 v485 v486 v487 v488 v489 v490 v491 v492 v493 v494 v495 v496 v497 v498 v499 v500 v501 v502 v503 v504 v505 v506 v507 v508 v509 v510 v511
  exact main _ _ (by ring)

end VoltaProofs
