import challenge

set_option maxRecDepth 16384

namespace VoltaProofs
open Real Set Finset Filter Topology MeasureTheory

noncomputable def S (N : ℕ) (x : ℝ) : ℝ := ∑ i ∈ range (N+1), (-x)^i / (i.factorial : ℝ)

lemma S_succ (N : ℕ) (x : ℝ) : S (N+1) x = S N x + (-x)^(N+1) / ((N+1).factorial : ℝ) := by
  unfold S; rw [Finset.sum_range_succ]

lemma S_zero (N : ℕ) : S N 0 = 1 := by
  unfold S; rw [Finset.sum_range_succ']; simp

lemma hasDerivAt_S (N : ℕ) (x : ℝ) : HasDerivAt (S (N+1)) (-S N x) x := by
  induction N with
  | zero =>
    have : S 1 = fun x => 1 - x := by
      funext y; simp [S, Finset.sum_range_succ]; ring
    rw [this]
    have : S 0 x = 1 := by simp [S]
    rw [this]
    exact (hasDerivAt_id' x).const_sub 1
  | succ n ih =>
    have h2 : HasDerivAt (fun y => (-y)^(n+2) / ((n+2).factorial : ℝ))
        (-((-x)^(n+1) / ((n+1).factorial : ℝ))) x := by
      have := (((hasDerivAt_id' x).neg).pow (n+2)).div_const ((n+2).factorial : ℝ)
      refine this.congr_deriv ?_
      rw [Nat.factorial_succ]; push_cast
      simp only [Pi.neg_apply]
      have : ((n+1).factorial : ℝ) ≠ 0 := by positivity
      field_simp
      ring
    have : S (n+2) = fun y => S (n+1) y + (-y)^(n+2) / ((n+2).factorial : ℝ) := by
      funext y; exact S_succ (n+1) y
    rw [this]
    refine (ih.add h2).congr_deriv ?_
    rw [S_succ]; ring

lemma nonneg_of_deriv {R R' : ℝ → ℝ} (hd : ∀ y, HasDerivAt R (R' y) y) (h0 : R 0 = 0)
    (hpos : ∀ y, 0 ≤ y → 0 ≤ R' y) : ∀ x, 0 ≤ x → 0 ≤ R x := by
  intro x hx
  have hmono : MonotoneOn R (Ici 0) :=
    monotoneOn_of_hasDerivWithinAt_nonneg (convex_Ici 0)
      (fun y _ => (hd y).continuousAt.continuousWithinAt)
      (fun y _ => (hd y).hasDerivWithinAt)
      (fun y hy => hpos y (by rw [interior_Ici] at hy; exact le_of_lt hy))
  have := hmono self_mem_Ici (mem_Ici.mpr hx) hx
  rw [h0] at this; exact this

lemma lowerStep (m : ℕ) (hA : ∀ x : ℝ, 0 ≤ x → Real.exp (-x) ≤ S (2*m) x) :
    ∀ x : ℝ, 0 ≤ x → S (2*m+1) x ≤ Real.exp (-x) := by
  have hd : ∀ y, HasDerivAt (fun y => Real.exp (-y) - S (2*m+1) y)
      (-Real.exp (-y) + S (2*m) y) y := by
    intro y
    have h1 := (hasDerivAt_id' y).neg.exp
    have h2 := hasDerivAt_S (2*m) y
    exact (h1.sub h2).congr_deriv (by simp)
  have key := nonneg_of_deriv hd (by simp [S_zero]) (fun y hy => by have := hA y hy; linarith)
  intro x hx; have := key x hx; linarith

lemma upperStep (m : ℕ) (hB : ∀ x : ℝ, 0 ≤ x → S (2*m+1) x ≤ Real.exp (-x)) :
    ∀ x : ℝ, 0 ≤ x → Real.exp (-x) ≤ S (2*(m+1)) x := by
  have hd : ∀ y, HasDerivAt (fun y => S (2*m+2) y - Real.exp (-y))
      (-S (2*m+1) y + Real.exp (-y)) y := by
    intro y
    have h1 := (hasDerivAt_id' y).neg.exp
    have h2 := hasDerivAt_S (2*m+1) y
    exact (h2.sub h1).congr_deriv (by simp)
  have key := nonneg_of_deriv hd (by simp [S_zero]) (fun y hy => by have := hB y hy; linarith)
  intro x hx; have := key x hx
  have e : 2*(m+1) = 2*m+2 := by ring
  rw [e]; linarith

lemma S_bounds (m : ℕ) : (∀ x : ℝ, 0 ≤ x → Real.exp (-x) ≤ S (2*m) x) ∧
    (∀ x : ℝ, 0 ≤ x → S (2*m+1) x ≤ Real.exp (-x)) := by
  induction m with
  | zero =>
    have hA : ∀ x : ℝ, 0 ≤ x → Real.exp (-x) ≤ S (2*0) x := by
      intro x hx; simp [S]; linarith
    exact ⟨hA, lowerStep 0 hA⟩
  | succ m ih =>
    have hA := upperStep m ih.2
    exact ⟨hA, lowerStep (m+1) hA⟩

noncomputable def I (N : ℕ) (a : ℝ) : ℝ :=
  ∑ i ∈ range (N+1), (-1:ℝ)^i * a^(2*i+1) / ((i.factorial : ℝ) * (2*i+1))

lemma S_cont (N : ℕ) : Continuous (S N) := by
  unfold S
  exact continuous_finsetSum _ (fun i _ => by fun_prop)

lemma integral_S (N : ℕ) (a : ℝ) : ∫ t in (0:ℝ)..a, S N (t^2) = I N a := by
  unfold S I
  rw [intervalIntegral.integral_finsetSum (fun i _ => by apply Continuous.intervalIntegrable; fun_prop)]
  apply Finset.sum_congr rfl
  intro i _
  have h : (fun t : ℝ => (-(t^2))^i / (i.factorial : ℝ)) =
      fun t => ((-1)^i / (i.factorial:ℝ)) * t^(2*i) := by
    funext t; rw [neg_pow, ← pow_mul]; ring
  rw [h, intervalIntegral.integral_const_mul, integral_pow]
  have : ((i.factorial : ℝ)) ≠ 0 := by positivity
  have : (2 * (i:ℝ) + 1) ≠ 0 := by positivity
  push_cast
  field_simp
  ring

noncomputable def Phi (a : ℝ) : ℝ := ∫ t in (0:ℝ)..a, Real.exp (-t^2)

lemma Phi_bounds (m : ℕ) (a : ℝ) (ha : 0 ≤ a) : I (2*m+1) a ≤ Phi a ∧ Phi a ≤ I (2*m) a := by
  have hc1 : Continuous (fun t : ℝ => S (2*m+1) (t^2)) := (S_cont _).comp (by fun_prop)
  have hc2 : Continuous (fun t : ℝ => S (2*m) (t^2)) := (S_cont _).comp (by fun_prop)
  have hc3 : Continuous (fun t : ℝ => Real.exp (-t^2)) := by fun_prop
  constructor
  · rw [← integral_S]; unfold Phi
    apply intervalIntegral.integral_mono_on ha (hc1.intervalIntegrable _ _) (hc3.intervalIntegrable _ _)
    intro t _; exact (S_bounds m).2 _ (sq_nonneg t)
  · rw [← integral_S]; unfold Phi
    apply intervalIntegral.integral_mono_on ha (hc3.intervalIntegrable _ _) (hc2.intervalIntegrable _ _)
    intro t _; exact (S_bounds m).1 _ (sq_nonneg t)

/-! Part 2: erf basics -/

noncomputable def Mc : ℝ := 2 / Real.sqrt Real.pi

lemma erf_eq (x : ℝ) : VoltaChallenge.erf x = Mc * Phi x := rfl

lemma Mc_pos : 0 < Mc := by unfold Mc; have := Real.pi_pos; positivity

lemma M_bounds : (1.128378:ℝ) ≤ Mc ∧ Mc ≤ 1.128381 := by
  have hp := Real.pi_pos
  have h1 : Real.sqrt Real.pi ≤ 1.7724541 := by
    rw [show (1.7724541:ℝ) = Real.sqrt (1.7724541^2) from (Real.sqrt_sq (by norm_num)).symm]
    exact Real.sqrt_le_sqrt (by have := pi_lt_d6; norm_num; linarith)
  have h2 : 1.7724536 ≤ Real.sqrt Real.pi := by
    rw [show (1.7724536:ℝ) = Real.sqrt (1.7724536^2) from (Real.sqrt_sq (by norm_num)).symm]
    exact Real.sqrt_le_sqrt (by have := pi_gt_d6; norm_num; linarith)
  have hs : 0 < Real.sqrt Real.pi := Real.sqrt_pos.2 hp
  unfold Mc
  constructor
  · rw [le_div_iff₀ hs]; nlinarith
  · rw [div_le_iff₀ hs]; nlinarith

lemma Phi_nonneg (a : ℝ) (ha : 0 ≤ a) : 0 ≤ Phi a :=
  intervalIntegral.integral_nonneg ha (fun t _ => (Real.exp_pos _).le)

lemma Phi_hasDeriv (x : ℝ) : HasDerivAt Phi (Real.exp (-x^2)) x :=
  (Continuous.integral_hasStrictDerivAt (f := fun t : ℝ => Real.exp (-t^2)) (by fun_prop) 0 x).hasDerivAt

lemma erf_hasDeriv (x : ℝ) : HasDerivAt VoltaChallenge.erf (Mc * Real.exp (-x^2)) x := by
  have : VoltaChallenge.erf = fun x => Mc * Phi x := by funext x; rfl
  rw [this]; exact (Phi_hasDeriv x).const_mul Mc

lemma erf_d_anti (x z : ℝ) (hx : 0 ≤ x) (hxz : x ≤ z) :
    Mc * Real.exp (-z^2) ≤ Mc * Real.exp (-x^2) := by
  apply mul_le_mul_of_nonneg_left _ Mc_pos.le
  apply Real.exp_le_exp.2
  have : x^2 ≤ z^2 := by nlinarith
  linarith

lemma erf_node (m : ℕ) (a : ℝ) (ha : 0 ≤ a) :
    1.128378 * I (2*m+1) a ≤ VoltaChallenge.erf a ∧ VoltaChallenge.erf a ≤ 1.128381 * I (2*m) a := by
  rw [erf_eq]
  obtain ⟨h1, h2⟩ := M_bounds
  obtain ⟨p1, p2⟩ := Phi_bounds m a ha
  have p0 := Phi_nonneg a ha
  constructor <;> nlinarith

lemma erfd_node (m : ℕ) (a : ℝ) :
    1.128378 * S (2*m+1) (a^2) ≤ Mc * Real.exp (-a^2) ∧
    Mc * Real.exp (-a^2) ≤ 1.128381 * S (2*m) (a^2) := by
  obtain ⟨h1, h2⟩ := M_bounds
  have e1 := (S_bounds m).2 (a^2) (sq_nonneg a)
  have e2 := (S_bounds m).1 (a^2) (sq_nonneg a)
  have e0 := Real.exp_pos (-a^2)
  constructor <;> nlinarith

lemma Phi_neg (x : ℝ) : Phi (-x) = -Phi x := by
  unfold Phi
  have h := intervalIntegral.integral_comp_neg (a := 0) (b := x) (f := fun t : ℝ => Real.exp (-t^2))
  simp only [neg_sq, neg_zero] at h
  rw [h, intervalIntegral.integral_symm 0 (-x), neg_neg]

lemma erf_neg (x : ℝ) : VoltaChallenge.erf (-x) = -VoltaChallenge.erf x := by
  rw [erf_eq, erf_eq, Phi_neg]; ring

lemma erf_lip (x z : ℝ) (hx : 0 ≤ x) (hxz : x ≤ z) :
    0 ≤ VoltaChallenge.erf z - VoltaChallenge.erf x ∧
    VoltaChallenge.erf z - VoltaChallenge.erf x ≤ 1.128381 * (z - x) := by
  have hc : Continuous (fun t : ℝ => Real.exp (-t^2)) := by fun_prop
  have hD : Phi z - Phi x = ∫ t in x..z, Real.exp (-t^2) :=
    intervalIntegral.integral_interval_sub_left (hc.intervalIntegrable _ _) (hc.intervalIntegrable _ _)
  have hD0 : 0 ≤ ∫ t in x..z, Real.exp (-t^2) :=
    intervalIntegral.integral_nonneg hxz (fun t _ => (Real.exp_pos _).le)
  have hD1 : ∫ t in x..z, Real.exp (-t^2) ≤ z - x := by
    have h1i : IntervalIntegrable (fun _ : ℝ => (1:ℝ)) volume x z := continuous_const.intervalIntegrable x z
    have := intervalIntegral.integral_mono_on hxz (hc.intervalIntegrable x z) h1i
      (fun t _ => (Real.exp_le_one_iff.2 (by nlinarith [sq_nonneg t]) : Real.exp (-t^2) ≤ (1:ℝ)))
    simpa using this
  rw [erf_eq, erf_eq]
  obtain ⟨h1, h2⟩ := M_bounds
  have e : Mc * Phi z - Mc * Phi x = Mc * (Phi z - Phi x) := by ring
  rw [e, hD]
  constructor
  · exact mul_nonneg Mc_pos.le hD0
  · nlinarith

/-! Part 3: tangent / chord -/

lemma mono_on_Icc {ψ ψ' : ℝ → ℝ} {a b : ℝ} (hd : ∀ x ∈ Icc a b, HasDerivAt ψ (ψ' x) x)
    (hpos : ∀ x ∈ Icc a b, 0 ≤ ψ' x) : MonotoneOn ψ (Icc a b) :=
  monotoneOn_of_hasDerivWithinAt_nonneg (convex_Icc a b)
    (fun x hx => (hd x hx).continuousAt.continuousWithinAt)
    (fun x hx => (hd x (interior_subset hx)).hasDerivWithinAt)
    (fun x hx => hpos x (interior_subset hx))

lemma anti_on_Icc {ψ ψ' : ℝ → ℝ} {a b : ℝ} (hd : ∀ x ∈ Icc a b, HasDerivAt ψ (ψ' x) x)
    (hneg : ∀ x ∈ Icc a b, ψ' x ≤ 0) : AntitoneOn ψ (Icc a b) :=
  antitoneOn_of_hasDerivWithinAt_nonpos (convex_Icc a b)
    (fun x hx => (hd x hx).continuousAt.continuousWithinAt)
    (fun x hx => (hd x (interior_subset hx)).hasDerivWithinAt)
    (fun x hx => hneg x (interior_subset hx))

lemma tc {φ φ' : ℝ → ℝ} {a b : ℝ} (hab : a < b) (hd : ∀ x ∈ Icc a b, HasDerivAt φ (φ' x) x)
    (hanti : ∀ x ∈ Icc a b, ∀ z ∈ Icc a b, x ≤ z → φ' z ≤ φ' x) {y : ℝ} (hy : y ∈ Icc a b) :
    φ y ≤ φ a + φ' a * (y - a) ∧ φ y ≤ φ b + φ' b * (y - b) ∧
    φ a + (φ b - φ a) / (b - a) * (y - a) ≤ φ y := by
  have haI : a ∈ Icc a b := ⟨le_refl a, hab.le⟩
  have hbI : b ∈ Icc a b := ⟨hab.le, le_refl b⟩
  refine ⟨?_, ?_, ?_⟩
  · have hm : MonotoneOn (fun x => φ a + φ' a * (x - a) - φ x) (Icc a b) := by
      apply mono_on_Icc (ψ' := fun x => φ' a - φ' x)
      · intro x hx
        have := ((((hasDerivAt_id' x).sub_const a).const_mul (φ' a)).const_add (φ a)).sub (hd x hx)
        exact this.congr_deriv (by ring)
      · intro x hx; have := hanti a haI x hx hx.1; linarith
    have := hm haI hy hy.1
    simp only [sub_self, mul_zero, add_zero] at this; linarith
  · have hm : AntitoneOn (fun x => φ b + φ' b * (x - b) - φ x) (Icc a b) := by
      apply anti_on_Icc (ψ' := fun x => φ' b - φ' x)
      · intro x hx
        have := ((((hasDerivAt_id' x).sub_const b).const_mul (φ' b)).const_add (φ b)).sub (hd x hx)
        exact this.congr_deriv (by ring)
      · intro x hx; have := hanti x hx b hbI hx.2; linarith
    have := hm hy hbI hy.2
    simp only [sub_self, mul_zero, add_zero] at this; linarith
  · obtain ⟨ξ, hξ, hξe⟩ := exists_hasDerivAt_eq_slope φ φ' hab
      (fun x hx => (hd x hx).continuousAt.continuousWithinAt)
      (fun x hx => hd x (Ioo_subset_Icc_self hx))
    set s := (φ b - φ a) / (b - a) with hs
    have hψ : ∀ x ∈ Icc a b, HasDerivAt (fun x => φ x - (φ a + s * (x - a))) (φ' x - s) x := by
      intro x hx
      have := (hd x hx).sub ((((hasDerivAt_id' x).sub_const a).const_mul s).const_add (φ a))
      exact this.congr_deriv (by ring)
    rcases le_total y ξ with hyξ | hyξ
    · have hm : MonotoneOn (fun x => φ x - (φ a + s * (x - a))) (Icc a ξ) := by
        apply mono_on_Icc (ψ' := fun x => φ' x - s)
        · intro x hx; exact hψ x ⟨hx.1, hx.2.trans hξ.2.le⟩
        · intro x hx
          have := hanti x ⟨hx.1, hx.2.trans hξ.2.le⟩ ξ ⟨hξ.1.le, hξ.2.le⟩ hx.2
          rw [hξe] at this; linarith
      have := hm ⟨le_refl a, hξ.1.le⟩ ⟨hy.1, hyξ⟩ hy.1
      simp only [sub_self, mul_zero, add_zero] at this; linarith
    · have hm : AntitoneOn (fun x => φ x - (φ a + s * (x - a))) (Icc ξ b) := by
        apply anti_on_Icc (ψ' := fun x => φ' x - s)
        · intro x hx; exact hψ x ⟨hξ.1.le.trans hx.1, hx.2⟩
        · intro x hx
          have := hanti ξ ⟨hξ.1.le, hξ.2.le⟩ x ⟨hξ.1.le.trans hx.1, hx.2⟩ hx.1
          rw [hξe] at this; linarith
      have := hm ⟨hyξ, hy.2⟩ ⟨hξ.2.le, le_refl b⟩ hy.2
      have hne : b - a ≠ 0 := ne_of_gt (sub_pos.2 hab)
      have hb : φ b - (φ a + s * (b - a)) = 0 := by
        rw [hs]; field_simp; ring
      simp only at this; linarith

lemma combine {a b y B fa fb fa' fb' fy ga gb ga' gb' gy : ℝ}
    {fal fah fbl fbh fa'h fb'l gal gah gbl gbh ga'h gb'l : ℝ}
    (hab : a < b) (hy1 : a ≤ y) (hy2 : y ≤ b)
    (g1 : gy ≤ ga + ga' * (y - a)) (g2 : gy ≤ gb + gb' * (y - b))
    (g3 : ga + (gb - ga) / (b - a) * (y - a) ≤ gy)
    (f1 : fy ≤ fa + fa' * (y - a)) (f2 : fy ≤ fb + fb' * (y - b))
    (f3 : fa + (fb - fa) / (b - a) * (y - a) ≤ fy)
    (hfa : fal ≤ fa ∧ fa ≤ fah) (hfb : fbl ≤ fb ∧ fb ≤ fbh) (hfa' : fa' ≤ fa'h) (hfb' : fb'l ≤ fb')
    (hga : gal ≤ ga ∧ ga ≤ gah) (hgb : gbl ≤ gb ∧ gb ≤ gbh) (hga' : ga' ≤ ga'h) (hgb' : gb'l ≤ gb')
    (U1 : gah - fal ≤ B) (U2 : gbh - fbl ≤ B)
    (U3 : gah + ga'h * ((b - a) / 2) - (fal + fbl) / 2 ≤ B)
    (U4 : gbh - gb'l * ((b - a) / 2) - (fal + fbl) / 2 ≤ B)
    (L1 : -B ≤ gal - fah) (L2 : -B ≤ gbl - fbh)
    (L3 : -B ≤ (gal + gbl) / 2 - fah - fa'h * ((b - a) / 2))
    (L4 : -B ≤ (gal + gbl) / 2 - fbh + fb'l * ((b - a) / 2)) :
    |gy - fy| ≤ B := by
  have hh : 0 < b - a := sub_pos.2 hab
  have hne : b - a ≠ 0 := ne_of_gt hh
  obtain ⟨θ, hθ⟩ : ∃ θ, y - a = θ * (b - a) := ⟨(y - a) / (b - a), by field_simp⟩
  have hθ0 : 0 ≤ θ := by
    by_contra hc; push_neg at hc
    have := mul_neg_of_neg_of_pos hc hh; linarith
  have hθ1 : θ ≤ 1 := by
    by_contra hc; push_neg at hc
    have := mul_lt_mul_of_pos_right hc hh; linarith
  have f3' : fa + (fb - fa) * θ ≤ fy := by
    have : (fb - fa) / (b - a) * (y - a) = (fb - fa) * θ := by rw [hθ]; field_simp
    linarith
  have g3' : ga + (gb - ga) * θ ≤ gy := by
    have : (gb - ga) / (b - a) * (y - a) = (gb - ga) * θ := by rw [hθ]; field_simp
    linarith
  have hyb : y - b = (θ - 1) * (b - a) := by linarith
  have f1' : fy ≤ fa + fa' * (θ * (b - a)) := by rw [← hθ]; exact f1
  have g1' : gy ≤ ga + ga' * (θ * (b - a)) := by rw [← hθ]; exact g1
  have f2' : fy ≤ fb + fb' * ((θ - 1) * (b - a)) := by rw [← hyb]; exact f2
  have g2' : gy ≤ gb + gb' * ((θ - 1) * (b - a)) := by rw [← hyb]; exact g2
  have pa : fa' * ((b - a) / 2) ≤ fa'h * ((b - a) / 2) := mul_le_mul_of_nonneg_right hfa' (by linarith)
  have pb : fb'l * ((b - a) / 2) ≤ fb' * ((b - a) / 2) := mul_le_mul_of_nonneg_right hfb' (by linarith)
  have qa : ga' * ((b - a) / 2) ≤ ga'h * ((b - a) / 2) := mul_le_mul_of_nonneg_right hga' (by linarith)
  have qb : gb'l * ((b - a) / 2) ≤ gb' * ((b - a) / 2) := mul_le_mul_of_nonneg_right hgb' (by linarith)
  rw [abs_le]
  constructor
  · rcases le_total θ (1/2) with ht | ht
    · have e1 : (1 - 2*θ) * (-B) ≤ (1 - 2*θ) * (ga - fa) :=
        mul_le_mul_of_nonneg_left (by linarith [hga.1, hfa.2]) (by linarith)
      have e2 : (2*θ) * (-B) ≤ (2*θ) * ((ga + gb)/2 - fa - fa' * ((b - a)/2)) :=
        mul_le_mul_of_nonneg_left (by linarith [hga.1, hgb.1, hfa.2]) (by linarith)
      linarith [e1, e2, g3', f1']
    · have e1 : (2*θ - 1) * (-B) ≤ (2*θ - 1) * (gb - fb) :=
        mul_le_mul_of_nonneg_left (by linarith [hgb.1, hfb.2]) (by linarith)
      have e2 : (2 - 2*θ) * (-B) ≤ (2 - 2*θ) * ((ga + gb)/2 - fb + fb' * ((b - a)/2)) :=
        mul_le_mul_of_nonneg_left (by linarith [hga.1, hgb.1, hfb.2]) (by linarith)
      linarith [e1, e2, g3', f2']
  · rcases le_total θ (1/2) with ht | ht
    · have e1 : (1 - 2*θ) * (ga - fa) ≤ (1 - 2*θ) * B :=
        mul_le_mul_of_nonneg_left (by linarith [hga.2, hfa.1]) (by linarith)
      have e2 : (2*θ) * (ga + ga' * ((b - a)/2) - (fa + fb)/2) ≤ (2*θ) * B :=
        mul_le_mul_of_nonneg_left (by linarith [hga.2, hfa.1, hfb.1]) (by linarith)
      linarith [e1, e2, g1', f3']
    · have e1 : (2*θ - 1) * (gb - fb) ≤ (2*θ - 1) * B :=
        mul_le_mul_of_nonneg_left (by linarith [hgb.2, hfb.1]) (by linarith)
      have e2 : (2 - 2*θ) * (gb - gb' * ((b - a)/2) - (fa + fb)/2) ≤ (2 - 2*θ) * B :=
        mul_le_mul_of_nonneg_left (by linarith [hgb.2, hfa.1, hfb.1]) (by linarith)
      linarith [e1, e2, g2', f3']

/-! Part 4: region A (kernel polynomial branch) -/

noncomputable def gA (u : ℝ) : ℝ := u * (u^2 * (u^2 * (u^2 * (u^2 * ((-9651681 / 2 ^ 34 : ℝ) * u^2
  + 2638085 / 2 ^ 29) + -1792311 / 2 ^ 26) + 7569887 / 2 ^ 26) + -0.376122951507568359375)
  + 0.1283791065216064453125) + u

noncomputable def gA' (u : ℝ) : ℝ := (1 + 0.1283791065216064453125) + 3 * (-0.376122951507568359375) * u^2
  + 5 * (7569887 / 2 ^ 26) * u^4 + 7 * (-1792311 / 2 ^ 26) * u^6 + 9 * (2638085 / 2 ^ 29) * u^8
  + 11 * (-9651681 / 2 ^ 34) * u^10

noncomputable def gA'' (u : ℝ) : ℝ := 6 * (-0.376122951507568359375) * u + 20 * (7569887 / 2 ^ 26) * u^3
  + 42 * (-1792311 / 2 ^ 26) * u^5 + 72 * (2638085 / 2 ^ 29) * u^7 + 110 * (-9651681 / 2 ^ 34) * u^9

lemma hdm (c : ℝ) (n : ℕ) (u : ℝ) :
    HasDerivAt (fun u : ℝ => c * u^(n+1)) (c * ((n:ℝ)+1) * u^n) u := by
  have := (hasDerivAt_pow (n+1) u).const_mul c
  refine this.congr_deriv ?_; push_cast; ring

lemma gA_hasDeriv (u : ℝ) : HasDerivAt gA (gA' u) u := by
  have e : gA = fun u => (1 + 0.1283791065216064453125) * u^(0+1) + (-0.376122951507568359375) * u^(2+1)
      + (7569887 / 2 ^ 26) * u^(4+1) + (-1792311 / 2 ^ 26) * u^(6+1) + (2638085 / 2 ^ 29) * u^(8+1)
      + (-9651681 / 2 ^ 34) * u^(10+1) := by
    funext u; unfold gA; ring
  rw [e]
  have := (((((hdm (1 + 0.1283791065216064453125) 0 u).add (hdm (-0.376122951507568359375) 2 u)).add
    (hdm (7569887 / 2 ^ 26) 4 u)).add (hdm (-1792311 / 2 ^ 26) 6 u)).add
    (hdm (2638085 / 2 ^ 29) 8 u)).add (hdm (-9651681 / 2 ^ 34) 10 u)
  refine this.congr_deriv ?_
  unfold gA'; push_cast; ring

lemma gA'_hasDeriv (u : ℝ) : HasDerivAt gA' (gA'' u) u := by
  have e : gA' = fun u => (1 + 0.1283791065216064453125) + 3 * (-0.376122951507568359375) * u^(1+1)
      + 5 * (7569887 / 2 ^ 26) * u^(3+1) + 7 * (-1792311 / 2 ^ 26) * u^(5+1)
      + 9 * (2638085 / 2 ^ 29) * u^(7+1) + 11 * (-9651681 / 2 ^ 34) * u^(9+1) := by
    funext u; unfold gA'; ring
  rw [e]
  have := (((((hasDerivAt_const u (1 + 0.1283791065216064453125 : ℝ)).add
    (hdm (3 * (-0.376122951507568359375)) 1 u)).add
    (hdm (5 * (7569887 / 2 ^ 26)) 3 u)).add (hdm (7 * (-1792311 / 2 ^ 26)) 5 u)).add
    (hdm (9 * (2638085 / 2 ^ 29)) 7 u)).add (hdm (11 * (-9651681 / 2 ^ 34)) 9 u)
  refine this.congr_deriv ?_
  unfold gA''; push_cast; ring

lemma gA''_nonpos (u : ℝ) (h0 : 0 ≤ u) (h1 : u ≤ 1) : gA'' u ≤ 0 := by
  unfold gA''
  have u3 : u^3 ≤ u^1 := pow_le_pow_of_le_one h0 h1 (by norm_num)
  have u7 : u^7 ≤ u^5 := pow_le_pow_of_le_one h0 h1 (by norm_num)
  have u5 : 0 ≤ u^5 := by positivity
  have u9 : 0 ≤ u^9 := by positivity
  rw [pow_one] at u3
  norm_num
  linarith

lemma gA'_anti : AntitoneOn gA' (Icc 0 1) :=
  anti_on_Icc (fun x _ => gA'_hasDeriv x) (fun x hx => gA''_nonpos x hx.1 hx.2)

lemma checkA (a b B : ℝ) (m : ℕ) (ha : 0 ≤ a) (hab : a < b) (hb : b ≤ 1)
    (U1 : gA a - 1.128378 * I (2*m+1) a ≤ B) (U2 : gA b - 1.128378 * I (2*m+1) b ≤ B)
    (U3 : gA a + gA' a * ((b - a) / 2) - (1.128378 * I (2*m+1) a + 1.128378 * I (2*m+1) b) / 2 ≤ B)
    (U4 : gA b - gA' b * ((b - a) / 2) - (1.128378 * I (2*m+1) a + 1.128378 * I (2*m+1) b) / 2 ≤ B)
    (L1 : -B ≤ gA a - 1.128381 * I (2*m) a) (L2 : -B ≤ gA b - 1.128381 * I (2*m) b)
    (L3 : -B ≤ (gA a + gA b) / 2 - 1.128381 * I (2*m) a - 1.128381 * S (2*m) (a^2) * ((b - a) / 2))
    (L4 : -B ≤ (gA a + gA b) / 2 - 1.128381 * I (2*m) b + 1.128378 * S (2*m+1) (b^2) * ((b - a) / 2)) :
    ∀ y ∈ Icc a b, |gA y - VoltaChallenge.erf y| ≤ B := by
  intro y hy
  have hsub : Icc a b ⊆ Icc 0 1 := Icc_subset_Icc ha hb
  obtain ⟨g1, g2, g3⟩ := tc (φ := gA) (φ' := gA') hab (fun x _ => gA_hasDeriv x)
    (fun x hx z hz hxz => gA'_anti (hsub hx) (hsub hz) hxz) hy
  obtain ⟨f1, f2, f3⟩ := tc (φ := VoltaChallenge.erf) (φ' := fun x => Mc * Real.exp (-x^2)) hab
    (fun x _ => erf_hasDeriv x) (fun x hx z _ hxz => erf_d_anti x z (ha.trans hx.1) hxz) hy
  exact combine hab hy.1 hy.2 g1 g2 g3 f1 f2 f3 (erf_node m a ha) (erf_node m b (by linarith))
    (erfd_node m a).2 (erfd_node m b).1 ⟨le_refl _, le_refl _⟩ ⟨le_refl _, le_refl _⟩ (le_refl _) (le_refl _)
    U1 U2 U3 U4 L1 L2 L3 L4

set_option maxHeartbeats 40000000 in
lemma regA (p : ℕ) (hp : p < 16) : ∀ y ∈ Icc ((p:ℝ)/16) (((p:ℝ)+1)/16),
    |gA y - VoltaChallenge.erf y| ≤ 0.0014 / (((p:ℝ)+1)/16) := by
  interval_cases p <;>
  · apply checkA _ _ _ 5 <;> norm_num [gA, gA', I, S, Finset.sum_range_succ, Nat.factorial]

/-! Part 5: region B (exp branch) -/

noncomputable def P (u : ℝ) : ℝ := u * (u * (u * (u * (u * (u * (u * (-9345195 / 2 ^ 39 : ℝ)
  + 1626409 / 2 ^ 32) + -16569193 / 2 ^ 32) + 6491225 / 2 ^ 28) + -3579193 / 2 ^ 25)
  + -10652413 / 2 ^ 24) + -1079525 / 2 ^ 23) + -u

noncomputable def P' (u : ℝ) : ℝ := 7 * (-9345195 / 2 ^ 39) * u^6 + 6 * (1626409 / 2 ^ 32) * u^5
  + 5 * (-16569193 / 2 ^ 32) * u^4 + 4 * (6491225 / 2 ^ 28) * u^3 + 3 * (-3579193 / 2 ^ 25) * u^2
  + 2 * (-10652413 / 2 ^ 24) * u + (-1079525 / 2 ^ 23 - 1)

noncomputable def P'' (u : ℝ) : ℝ := 42 * (-9345195 / 2 ^ 39) * u^5 + 30 * (1626409 / 2 ^ 32) * u^4
  + 20 * (-16569193 / 2 ^ 32) * u^3 + 12 * (6491225 / 2 ^ 28) * u^2 + 6 * (-3579193 / 2 ^ 25) * u
  + 2 * (-10652413 / 2 ^ 24)

lemma P_hasDeriv (u : ℝ) : HasDerivAt P (P' u) u := by
  have e : P = fun u => (-9345195 / 2 ^ 39 : ℝ) * u^(6+1) + (1626409 / 2 ^ 32) * u^(5+1)
      + (-16569193 / 2 ^ 32) * u^(4+1) + (6491225 / 2 ^ 28) * u^(3+1) + (-3579193 / 2 ^ 25) * u^(2+1)
      + (-10652413 / 2 ^ 24) * u^(1+1) + (-1079525 / 2 ^ 23 - 1) * u^(0+1) := by
    funext u; unfold P; ring
  rw [e]
  have := ((((((hdm (-9345195 / 2 ^ 39) 6 u).add (hdm (1626409 / 2 ^ 32) 5 u)).add
    (hdm (-16569193 / 2 ^ 32) 4 u)).add (hdm (6491225 / 2 ^ 28) 3 u)).add
    (hdm (-3579193 / 2 ^ 25) 2 u)).add (hdm (-10652413 / 2 ^ 24) 1 u)).add
    (hdm (-1079525 / 2 ^ 23 - 1) 0 u)
  refine this.congr_deriv ?_
  unfold P'; push_cast; ring

lemma P'_hasDeriv (u : ℝ) : HasDerivAt P' (P'' u) u := by
  have e : P' = fun u => 7 * (-9345195 / 2 ^ 39 : ℝ) * u^(5+1) + 6 * (1626409 / 2 ^ 32) * u^(4+1)
      + 5 * (-16569193 / 2 ^ 32) * u^(3+1) + 4 * (6491225 / 2 ^ 28) * u^(2+1)
      + 3 * (-3579193 / 2 ^ 25) * u^(1+1) + 2 * (-10652413 / 2 ^ 24) * u^(0+1)
      + (-1079525 / 2 ^ 23 - 1) := by
    funext u; unfold P'; ring
  rw [e]
  have := ((((((hdm (7 * (-9345195 / 2 ^ 39)) 5 u).add (hdm (6 * (1626409 / 2 ^ 32)) 4 u)).add
    (hdm (5 * (-16569193 / 2 ^ 32)) 3 u)).add (hdm (4 * (6491225 / 2 ^ 28)) 2 u)).add
    (hdm (3 * (-3579193 / 2 ^ 25)) 1 u)).add (hdm (2 * (-10652413 / 2 ^ 24)) 0 u)).add
    (hasDerivAt_const u (-1079525 / 2 ^ 23 - 1 : ℝ))
  refine this.congr_deriv ?_
  unfold P''; push_cast; ring

noncomputable def G (u : ℝ) : ℝ := 1 - Real.exp (P u)
noncomputable def G' (u : ℝ) : ℝ := -P' u * Real.exp (P u)
noncomputable def G'' (u : ℝ) : ℝ := -(P'' u + P' u ^ 2) * Real.exp (P u)

lemma G_hasDeriv (u : ℝ) : HasDerivAt G (G' u) u := by
  have := ((P_hasDeriv u).exp).const_sub 1
  exact this.congr_deriv (by unfold G'; ring)

lemma G'_hasDeriv (u : ℝ) : HasDerivAt G' (G'' u) u := by
  have := ((P'_hasDeriv u).neg).mul ((P_hasDeriv u).exp)
  exact this.congr_deriv (by unfold G''; simp only [Pi.neg_apply]; ring)

lemma powb (u lo hi : ℝ) (h0 : 0 ≤ lo) (h1 : lo ≤ u) (h2 : u ≤ hi) (k : ℕ) :
    lo^k ≤ u^k ∧ u^k ≤ hi^k :=
  ⟨pow_le_pow_left₀ h0 h1 k, pow_le_pow_left₀ (h0.trans h1) h2 k⟩

lemma P'_le_aux (u lo hi : ℝ) (h0 : 0 ≤ lo) (h1 : lo ≤ u) (h2 : u ≤ hi)
    (hc : 7 * (-9345195 / 2 ^ 39) * lo^6 + 6 * (1626409 / 2 ^ 32) * hi^5
      + 5 * (-16569193 / 2 ^ 32) * lo^4 + 4 * (6491225 / 2 ^ 28) * hi^3 + 3 * (-3579193 / 2 ^ 25) * lo^2
      + 2 * (-10652413 / 2 ^ 24) * lo + (-1079525 / 2 ^ 23 - 1) ≤ (-2:ℝ)) : P' u ≤ -2 := by
  unfold P'
  have := powb u lo hi h0 h1 h2 6
  have := powb u lo hi h0 h1 h2 5
  have := powb u lo hi h0 h1 h2 4
  have := powb u lo hi h0 h1 h2 3
  have := powb u lo hi h0 h1 h2 2
  nlinarith

lemma P'_le (u : ℝ) (h1 : 1 ≤ u) (h2 : u ≤ 2.75) : P' u ≤ -2 := by
  rcases le_total u 1.5 with h | h
  · exact P'_le_aux u 1 1.5 (by norm_num) h1 h (by norm_num)
  rcases le_total u 2 with h' | h'
  · exact P'_le_aux u 1.5 2 (by norm_num) h h' (by norm_num)
  · exact P'_le_aux u 2 2.75 (by norm_num) h' h2 (by norm_num)

lemma P''_ge_aux (u lo hi : ℝ) (h0 : 0 ≤ lo) (h1 : lo ≤ u) (h2 : u ≤ hi)
    (hc : (-4:ℝ) ≤ 42 * (-9345195 / 2 ^ 39) * hi^5 + 30 * (1626409 / 2 ^ 32) * lo^4
      + 20 * (-16569193 / 2 ^ 32) * hi^3 + 12 * (6491225 / 2 ^ 28) * lo^2 + 6 * (-3579193 / 2 ^ 25) * hi
      + 2 * (-10652413 / 2 ^ 24)) : -4 ≤ P'' u := by
  unfold P''
  have := powb u lo hi h0 h1 h2 5
  have := powb u lo hi h0 h1 h2 4
  have := powb u lo hi h0 h1 h2 3
  have := powb u lo hi h0 h1 h2 2
  nlinarith

lemma P''_ge (u : ℝ) (h1 : 1 ≤ u) (h2 : u ≤ 2.75) : -4 ≤ P'' u := by
  rcases le_total u 2 with h | h
  · exact P''_ge_aux u 1 2 (by norm_num) h1 h (by norm_num)
  · exact P''_ge_aux u 2 2.75 (by norm_num) h h2 (by norm_num)

lemma P_ge (u : ℝ) (h1 : 1 ≤ u) (h2 : u ≤ 2.75) : -87.3365478515625 ≤ P u := by
  unfold P
  have := powb u 1 2.75 (by norm_num) h1 h2 7
  have := powb u 1 2.75 (by norm_num) h1 h2 6
  have := powb u 1 2.75 (by norm_num) h1 h2 5
  have := powb u 1 2.75 (by norm_num) h1 h2 4
  have := powb u 1 2.75 (by norm_num) h1 h2 3
  have := powb u 1 2.75 (by norm_num) h1 h2 2
  nlinarith

lemma G''_nonpos (u : ℝ) (h1 : 1 ≤ u) (h2 : u ≤ 2.75) : G'' u ≤ 0 := by
  unfold G''
  have a := P'_le u h1 h2
  have b := P''_ge u h1 h2
  have : 0 ≤ P'' u + P' u ^ 2 := by nlinarith
  have := Real.exp_pos (P u)
  nlinarith

lemma G'_anti : AntitoneOn G' (Icc 1 2.75) :=
  anti_on_Icc (fun x _ => G'_hasDeriv x) (fun x hx => G''_nonpos x hx.1 hx.2)

lemma G_node (m : ℕ) (a : ℝ) (hP : P a ≤ 0) :
    1 - S (2*m) (-P a) ≤ G a ∧ G a ≤ 1 - S (2*m+1) (-P a) := by
  have h1 := (S_bounds m).1 (-P a) (by linarith)
  have h2 := (S_bounds m).2 (-P a) (by linarith)
  rw [neg_neg] at h1 h2
  unfold G; constructor <;> linarith

lemma G'_hi (m : ℕ) (a : ℝ) (hP : P a ≤ 0) (hP' : P' a ≤ 0) : G' a ≤ -P' a * S (2*m) (-P a) := by
  have h1 := (S_bounds m).1 (-P a) (by linarith)
  rw [neg_neg] at h1
  unfold G'
  exact mul_le_mul_of_nonneg_left h1 (by linarith)

lemma G'_lo (m : ℕ) (a : ℝ) (hP : P a ≤ 0) (hP' : P' a ≤ 0) : -P' a * S (2*m+1) (-P a) ≤ G' a := by
  have h1 := (S_bounds m).2 (-P a) (by linarith)
  rw [neg_neg] at h1
  unfold G'
  exact mul_le_mul_of_nonneg_left h1 (by linarith)

lemma checkB (a b B : ℝ) (m1 m2 : ℕ) (ha : 1 ≤ a) (hab : a < b) (hb : b ≤ 2.75)
    (hPa : P a ≤ 0) (hPb : P b ≤ 0)
    (U1 : (1 - S (2*m2+1) (-P a)) - 1.128378 * I (2*m1+1) a ≤ B)
    (U2 : (1 - S (2*m2+1) (-P b)) - 1.128378 * I (2*m1+1) b ≤ B)
    (U3 : (1 - S (2*m2+1) (-P a)) + (-P' a * S (2*m2) (-P a)) * ((b - a) / 2)
      - (1.128378 * I (2*m1+1) a + 1.128378 * I (2*m1+1) b) / 2 ≤ B)
    (U4 : (1 - S (2*m2+1) (-P b)) - (-P' b * S (2*m2+1) (-P b)) * ((b - a) / 2)
      - (1.128378 * I (2*m1+1) a + 1.128378 * I (2*m1+1) b) / 2 ≤ B)
    (L1 : -B ≤ (1 - S (2*m2) (-P a)) - 1.128381 * I (2*m1) a)
    (L2 : -B ≤ (1 - S (2*m2) (-P b)) - 1.128381 * I (2*m1) b)
    (L3 : -B ≤ ((1 - S (2*m2) (-P a)) + (1 - S (2*m2) (-P b))) / 2 - 1.128381 * I (2*m1) a
      - 1.128381 * S (2*m1) (a^2) * ((b - a) / 2))
    (L4 : -B ≤ ((1 - S (2*m2) (-P a)) + (1 - S (2*m2) (-P b))) / 2 - 1.128381 * I (2*m1) b
      + 1.128378 * S (2*m1+1) (b^2) * ((b - a) / 2)) :
    ∀ y ∈ Icc a b, |G y - VoltaChallenge.erf y| ≤ B := by
  intro y hy
  have hsub : Icc a b ⊆ Icc 1 2.75 := Icc_subset_Icc ha hb
  have ha0 : 0 ≤ a := by linarith
  obtain ⟨g1, g2, g3⟩ := tc (φ := G) (φ' := G') hab (fun x _ => G_hasDeriv x)
    (fun x hx z hz hxz => G'_anti (hsub hx) (hsub hz) hxz) hy
  obtain ⟨f1, f2, f3⟩ := tc (φ := VoltaChallenge.erf) (φ' := fun x => Mc * Real.exp (-x^2)) hab
    (fun x _ => erf_hasDeriv x) (fun x hx z _ hxz => erf_d_anti x z (ha0.trans hx.1) hxz) hy
  have hP'a : P' a ≤ 0 := by have := P'_le a ha (by linarith); linarith
  have hP'b : P' b ≤ 0 := by have := P'_le b (by linarith) hb; linarith
  exact combine hab hy.1 hy.2 g1 g2 g3 f1 f2 f3 (erf_node m1 a ha0) (erf_node m1 b (by linarith))
    (erfd_node m1 a).2 (erfd_node m1 b).1 (G_node m2 a hPa) (G_node m2 b hPb)
    (G'_hi m2 a hPa hP'a) (G'_lo m2 b hPb hP'b)
    U1 U2 U3 U4 L1 L2 L3 L4

set_option maxHeartbeats 80000000 in
lemma regB1 (p : ℕ) (hp1 : 16 ≤ p) (hp2 : p < 32) : ∀ y ∈ Icc ((p:ℝ)/16) (((p:ℝ)+1)/16),
    |G y - VoltaChallenge.erf y| ≤ 0.0014 / (((p:ℝ)+1)/16) := by
  interval_cases p <;>
  · apply checkB _ _ _ 9 13 <;> norm_num [P, P', I, S, Finset.sum_range_succ, Nat.factorial]

set_option maxHeartbeats 80000000 in
lemma regB2 (p : ℕ) (hp1 : 16 ≤ p) (hp2 : p < 20) : ∀ y ∈ Icc ((p:ℝ)/8) (((p:ℝ)+1)/8),
    |G y - VoltaChallenge.erf y| ≤ 0.0014 / (((p:ℝ)+1)/8) := by
  interval_cases p <;>
  · apply checkB _ _ _ 12 16 <;> norm_num [P, P', I, S, Finset.sum_range_succ, Nat.factorial]

set_option maxHeartbeats 80000000 in
lemma regB3 : ∀ y ∈ Icc (5/2 : ℝ) (11/4), |G y - VoltaChallenge.erf y| ≤ 0.0014 / (11/4) := by
  apply checkB _ _ _ 14 19 <;> norm_num [P, P', I, S, Finset.sum_range_succ, Nat.factorial]

/-! Part 6: kernel structure -/

noncomputable def kin (u v : ℝ) : ℝ :=
  if u ≥ (1 : ℝ) then (1 : ℝ) - (if (u ≥ (1 : ℝ)) ∧ ((-87.3365478515625 : ℝ) > P u) then
    (3330985 / 2 ^ 114 : ℝ) * Real.exp (if (u ≥ (1 : ℝ)) ∧ ((-87.3365478515625 : ℝ) > P u) then
      (64 : ℝ) + P u else P u)
    else Real.exp (if (u ≥ (1 : ℝ)) ∧ ((-87.3365478515625 : ℝ) > P u) then (64 : ℝ) + P u else P u))
  else (u * ((v * ((v * ((v * ((v * (((-9651681 / 2 ^ 34 : ℝ) * v) + (2638085 / 2 ^ 29 : ℝ)))
    + (-1792311 / 2 ^ 26 : ℝ))) + (7569887 / 2 ^ 26 : ℝ))) + (-0.376122951507568359375 : ℝ)))
    + (0.1283791065216064453125 : ℝ))) + u

noncomputable def x6f (x1 : ℝ) : ℝ := |kin |x1| (x1 * x1)|

lemma inner_lt (u v : ℝ) (h : u < 1) : kin u v = (u * ((v * ((v * ((v * ((v *
    (((-9651681 / 2 ^ 34 : ℝ) * v) + (2638085 / 2 ^ 29 : ℝ))) + (-1792311 / 2 ^ 26 : ℝ)))
    + (7569887 / 2 ^ 26 : ℝ))) + (-0.376122951507568359375 : ℝ))) + (0.1283791065216064453125 : ℝ)))
    + u := by
  unfold kin; rw [if_neg (show ¬ (u ≥ 1) from not_le.2 h)]

lemma inner_ge_nb (u v : ℝ) (h1 : u ≥ 1) (hnb : ¬ ((-87.3365478515625 : ℝ) > P u)) :
    kin u v = 1 - Real.exp (P u) := by
  have hc : ¬ (u ≥ 1 ∧ (-87.3365478515625 : ℝ) > P u) := fun h => hnb h.2
  unfold kin; simp only [if_pos h1, if_neg hc]

lemma C_exp64 : (3330985 / 2 ^ 114 : ℝ) * Real.exp 64 ≤ 1.00001 := by
  have h1 : Real.exp 64 = Real.exp 1 ^ 64 := by rw [← Real.exp_nat_mul]; norm_num
  have h2 : Real.exp 1 ^ 64 ≤ 2.7182818286 ^ 64 :=
    pow_le_pow_left₀ (Real.exp_pos 1).le Real.exp_one_lt_d9.le 64
  rw [h1]
  calc (3330985 / 2 ^ 114 : ℝ) * Real.exp 1 ^ 64 ≤ (3330985 / 2 ^ 114 : ℝ) * 2.7182818286 ^ 64 :=
        mul_le_mul_of_nonneg_left h2 (by norm_num)
    _ ≤ 1.00001 := by norm_num

lemma inner_ge (u v : ℝ) (h1 : u ≥ 1) :
    ∃ X, kin u v = 1 - X ∧ 0 ≤ X ∧ X ≤ 1.00001 * Real.exp (P u) := by
  by_cases hc : (-87.3365478515625 : ℝ) > P u
  · have hc2 : (u ≥ 1 ∧ (-87.3365478515625 : ℝ) > P u) := ⟨h1, hc⟩
    refine ⟨(3330985 / 2 ^ 114 : ℝ) * Real.exp (64 + P u), ?_, by positivity, ?_⟩
    · unfold kin; simp only [if_pos h1, if_pos hc2]
    · rw [Real.exp_add]
      have := C_exp64
      have := Real.exp_pos (P u)
      nlinarith
  · have hc2 : ¬ (u ≥ 1 ∧ (-87.3365478515625 : ℝ) > P u) := fun h => hc h.2
    refine ⟨Real.exp (P u), ?_, (Real.exp_pos _).le, ?_⟩
    · unfold kin; simp only [if_pos h1, if_neg hc2]
    · nlinarith [Real.exp_pos (P u)]

lemma fin_helper {u b g : ℝ} (hu0 : 0 ≤ u) (hub : u ≤ b) (hb : 0 < b) (h : g ≤ 0.0014 / b)
    (hg : 0 ≤ g) : u * g ≤ 0.0014 := by
  calc u * g ≤ b * g := mul_le_mul_of_nonneg_right hub hg
    _ ≤ b * (0.0014 / b) := mul_le_mul_of_nonneg_left h hb.le
    _ = 0.0014 := by field_simp

lemma regAB (u : ℝ) (h0 : 0 ≤ u) (h1 : u ≤ 2.75) : u * |x6f u - VoltaChallenge.erf u| ≤ 0.0014 := by
  have hx : x6f u = |kin u (u*u)| := by unfold x6f; rw [abs_of_nonneg h0]
  have herf0 : 0 ≤ VoltaChallenge.erf u := by rw [erf_eq]; exact mul_nonneg Mc_pos.le (Phi_nonneg u h0)
  have key : ∀ g : ℝ, x6f u = |g| → u * |g - VoltaChallenge.erf u| ≤ 0.0014 →
      u * |x6f u - VoltaChallenge.erf u| ≤ 0.0014 := by
    intro g hg hb
    have := abs_abs_sub_abs_le_abs_sub g (VoltaChallenge.erf u)
    rw [abs_of_nonneg herf0, ← hg] at this
    exact (mul_le_mul_of_nonneg_left this h0).trans hb
  rcases lt_or_ge u 1 with hlt | hge
  · apply key (gA u)
    · rw [hx, inner_lt u (u*u) hlt]; congr 1; unfold gA; ring
    · have h16 : (0:ℝ) ≤ 16 * u := by linarith
      have hp1 : ((⌊16 * u⌋₊ : ℕ) : ℝ) ≤ 16 * u := Nat.floor_le h16
      have hp2 : 16 * u < ((⌊16 * u⌋₊ : ℕ) : ℝ) + 1 := Nat.lt_floor_add_one _
      have hp3 : ⌊16 * u⌋₊ < 16 := by
        have : ((⌊16 * u⌋₊ : ℕ) : ℝ) < 16 := by linarith
        exact_mod_cast this
      have hb := regA _ hp3 u ⟨by linarith, by linarith⟩
      exact fin_helper h0 (by linarith) (by positivity) hb (abs_nonneg _)
  · have hnb : ¬ ((-87.3365478515625:ℝ) > P u) := not_lt.2 (P_ge u hge h1)
    apply key (G u)
    · rw [hx, inner_ge_nb u (u*u) hge hnb]; rfl
    · rcases lt_or_ge u 2 with hu2 | hu2
      · have h16 : (0:ℝ) ≤ 16 * u := by linarith
        have hp1 : ((⌊16 * u⌋₊ : ℕ) : ℝ) ≤ 16 * u := Nat.floor_le h16
        have hp2 : 16 * u < ((⌊16 * u⌋₊ : ℕ) : ℝ) + 1 := Nat.lt_floor_add_one _
        have hp3 : ⌊16 * u⌋₊ < 32 := by
          have : ((⌊16 * u⌋₊ : ℕ) : ℝ) < 32 := by linarith
          exact_mod_cast this
        have hp4 : 16 ≤ ⌊16 * u⌋₊ := Nat.le_floor (by push_cast; linarith)
        have hb := regB1 _ hp4 hp3 u ⟨by linarith, by linarith⟩
        exact fin_helper h0 (by linarith) (by positivity) hb (abs_nonneg _)
      · rcases lt_or_ge u 2.5 with h25 | h25
        · have h8 : (0:ℝ) ≤ 8 * u := by linarith
          have hp1 : ((⌊8 * u⌋₊ : ℕ) : ℝ) ≤ 8 * u := Nat.floor_le h8
          have hp2 : 8 * u < ((⌊8 * u⌋₊ : ℕ) : ℝ) + 1 := Nat.lt_floor_add_one _
          have hp3 : ⌊8 * u⌋₊ < 20 := by
            have : ((⌊8 * u⌋₊ : ℕ) : ℝ) < 20 := by linarith
            exact_mod_cast this
          have hp4 : 16 ≤ ⌊8 * u⌋₊ := Nat.le_floor (by push_cast; linarith)
          have hb := regB2 _ hp4 hp3 u ⟨by linarith, by linarith⟩
          exact fin_helper h0 (by linarith) (by positivity) hb (abs_nonneg _)
        · have hb := regB3 u ⟨by linarith, by linarith⟩
          exact fin_helper h0 (by linarith : u ≤ 11/4) (by norm_num) hb (abs_nonneg _)

/-! Part 7: region C (large arguments) -/

lemma tail (y : ℝ) (hy : 0 < y) :
    0 ≤ 1 - VoltaChallenge.erf y ∧ 1 - VoltaChallenge.erf y ≤ Mc * (Real.exp (-y^2) / (2*y)) := by
  have hint : Integrable (fun s : ℝ => Real.exp (-s^2)) := by
    have := integrable_exp_neg_mul_sq (b := 1) one_pos
    simpa using this
  have hG : ∫ s in Ioi (0:ℝ), Real.exp (-s^2) = Real.sqrt Real.pi / 2 := by
    have := integral_gaussian_Ioi 1
    simpa using this
  have hdisj : Disjoint (Ioc (0:ℝ) y) (Ioi y) := by
    rw [Set.disjoint_left]; intro x hx hx'; exact absurd hx.2 (not_le.2 hx')
  have hsplit : ∫ s in Ioi (0:ℝ), Real.exp (-s^2) =
      (∫ s in Ioc (0:ℝ) y, Real.exp (-s^2)) + ∫ s in Ioi y, Real.exp (-s^2) := by
    rw [← Ioc_union_Ioi_eq_Ioi hy.le]
    exact setIntegral_union hdisj measurableSet_Ioi hint.integrableOn hint.integrableOn
  have hPhi : Phi y = ∫ s in Ioc (0:ℝ) y, Real.exp (-s^2) := intervalIntegral.integral_of_le hy.le
  have hint2 : Integrable (fun s : ℝ => s * Real.exp (-s^2)) := by
    have := integrable_mul_exp_neg_mul_sq (b := 1) one_pos
    simpa using this
  have htail_eq : ∫ s in Ioi y, s * Real.exp (-s^2) = Real.exp (-y^2) / 2 := by
    have hderiv : ∀ x ∈ Ici y, HasDerivAt (fun s : ℝ => -Real.exp (-s^2) / 2)
        (x * Real.exp (-x^2)) x := by
      intro x _
      have h1 : HasDerivAt (fun s : ℝ => s^2) (2 * x) x := by simpa using hasDerivAt_pow 2 x
      have := ((h1.neg).exp.neg).div_const 2
      exact this.congr_deriv (by simp only [Pi.neg_apply]; ring)
    have htend : Tendsto (fun s : ℝ => -Real.exp (-s^2) / 2) atTop (𝓝 0) := by
      have h1 : Tendsto (fun s : ℝ => Real.exp (-s^2)) atTop (𝓝 0) :=
        Real.tendsto_exp_atBot.comp (tendsto_neg_atTop_atBot.comp (tendsto_pow_atTop two_ne_zero))
      have := (h1.neg).div_const 2
      simpa using this
    have := integral_Ioi_of_hasDerivAt_of_tendsto' hderiv hint2.integrableOn htend
    rw [this]; ring
  have hle : ∫ s in Ioi y, Real.exp (-s^2) ≤ ∫ s in Ioi y, (1/y) * (s * Real.exp (-s^2)) := by
    apply setIntegral_mono_on hint.integrableOn (hint2.const_mul (1/y)).integrableOn measurableSet_Ioi
    intro s hs
    have hs' : y < s := hs
    have he := Real.exp_pos (-s^2)
    have h1 : 1 ≤ 1/y * s := by rw [div_mul_eq_mul_div, one_mul, le_div_iff₀ hy]; linarith
    nlinarith
  rw [integral_const_mul, htail_eq] at hle
  have hnn : 0 ≤ ∫ s in Ioi y, Real.exp (-s^2) :=
    setIntegral_nonneg measurableSet_Ioi (fun s _ => (Real.exp_pos _).le)
  have hM : Mc * (Real.sqrt Real.pi / 2) = 1 := by
    unfold Mc; have : Real.sqrt Real.pi ≠ 0 := (Real.sqrt_pos.2 Real.pi_pos).ne'; field_simp
  have key : 1 - VoltaChallenge.erf y = Mc * ∫ s in Ioi y, Real.exp (-s^2) := by
    have h2 := hsplit
    rw [hG] at h2
    rw [erf_eq, hPhi]
    linear_combination (-1 : ℝ) * hM + Mc * h2
  rw [key]
  constructor
  · exact mul_nonneg Mc_pos.le hnn
  · apply mul_le_mul_of_nonneg_left _ Mc_pos.le
    calc _ ≤ 1 / y * (Real.exp (-y^2) / 2) := hle
      _ = Real.exp (-y^2) / (2*y) := by field_simp

noncomputable def bpoly (u : ℝ) : ℝ := (-9345195 / 2 ^ 39) * u^5 + (1626409 / 2 ^ 32) * u^4
  + (-16569193 / 2 ^ 32) * u^3 + (6491225 / 2 ^ 28) * u^2 + (-3579193 / 2 ^ 25) * u + (-10652413 / 2 ^ 24)

lemma bpoly_le (u : ℝ) (hu : 2.75 ≤ u) : bpoly u ≤ -0.69 := by
  unfold bpoly
  have h0 : 0 ≤ u := by linarith
  have H1 : 0 ≤ u^3 * (u - 11.14)^2 := by positivity
  have H2 : 0 ≤ u * (u - 6.92)^2 := by positivity
  have H4 : 0 ≤ u^4 := by positivity
  have H5 : 0 ≤ u^2 := by positivity
  nlinarith [H1, H2, H4, H5, hu]

lemma P_tail (u : ℝ) (hu : 2.75 ≤ u) : P u + 0.37 * u ≤ -7.2 := by
  have hP : P u = u^2 * bpoly u + (-1079525 / 2 ^ 23 - 1) * u := by unfold P bpoly; ring
  have hb := bpoly_le u hu
  have h1 : u^2 * bpoly u ≤ u^2 * (-0.69) := mul_le_mul_of_nonneg_left hb (sq_nonneg u)
  have h2 : 0 ≤ (u - 2.75) * (u + 2.75) := mul_nonneg (by linarith) (by linarith)
  rw [hP]; nlinarith [h1, h2]

lemma u_le_exp (u : ℝ) (hu : 0 ≤ u) : u ≤ Real.exp (0.37 * u) := by
  have h1 := Real.add_one_le_exp (0.37 * u - 1)
  have h2 : Real.exp (0.37 * u) = Real.exp (0.37 * u - 1) * Real.exp 1 := by
    rw [← Real.exp_add]; ring_nf
  have h3 := Real.exp_one_gt_d9
  have h4 := Real.exp_pos (0.37 * u - 1)
  rw [h2]; nlinarith

lemma regC (t : ℝ) (ht : 0 ≤ t) (hu : 2.75 ≤ (11863283 / 2 ^ 24 : ℝ) * t) :
    t * |x6f ((11863283 / 2 ^ 24 : ℝ) * t) - VoltaChallenge.erf (t * (6369051672525773 / 2 ^ 53 : ℝ))|
      ≤ 0.002 := by
  set u := (11863283 / 2 ^ 24 : ℝ) * t with hu_def
  set y := t * (6369051672525773 / 2 ^ 53 : ℝ) with hy_def
  have hu0 : 0 ≤ u := by linarith
  have htpos : 0 < t := by
    rcases lt_or_eq_of_le ht with h | h
    · exact h
    · rw [hu_def, ← h] at hu; norm_num at hu
  have hyu : u ≤ y := by rw [hu_def, hy_def]; nlinarith
  have hy0 : 0 < y := by linarith
  have hx6 : x6f u = |kin u (u*u)| := by unfold x6f; rw [abs_of_nonneg hu0]
  obtain ⟨X, hX, hX0, hX1⟩ := inner_ge u (u*u) (by linarith)
  obtain ⟨ht1, ht2⟩ := tail y hy0
  have herf0 : 0 ≤ VoltaChallenge.erf y := by
    rw [erf_eq]; exact mul_nonneg Mc_pos.le (Phi_nonneg y hy0.le)
  have h1 : |x6f u - VoltaChallenge.erf y| ≤ (1 - VoltaChallenge.erf y) + X := by
    rw [hx6, hX]
    have := abs_abs_sub_abs_le_abs_sub (1 - X) (VoltaChallenge.erf y)
    rw [abs_of_nonneg herf0] at this
    refine this.trans ?_
    rw [abs_le]; constructor <;> linarith
  have h2 : t * (1 - VoltaChallenge.erf y) ≤ 1.128381 * 0.000554 / (2 * (6369051672525773 / 2 ^ 53)) := by
    have e1 : t * (Mc * (Real.exp (-y^2) / (2*y))) =
        Mc * Real.exp (-y^2) / (2 * (6369051672525773 / 2 ^ 53)) := by
      rw [hy_def]; field_simp
    have e2 : Real.exp (-y^2) ≤ Real.exp (-7.5) := Real.exp_le_exp.2 (by nlinarith)
    have e3 : Real.exp (-7.5) ≤ S (2*15) 7.5 := (S_bounds 15).1 7.5 (by norm_num)
    have e4 : S (2*15) 7.5 ≤ (0.000554:ℝ) := by norm_num [S, Finset.sum_range_succ, Nat.factorial]
    have hM := M_bounds
    have hE := Real.exp_pos (-y^2)
    calc t * (1 - VoltaChallenge.erf y) ≤ t * (Mc * (Real.exp (-y^2) / (2*y))) :=
          mul_le_mul_of_nonneg_left ht2 ht
      _ = Mc * Real.exp (-y^2) / (2 * (6369051672525773 / 2 ^ 53)) := e1
      _ ≤ 1.128381 * 0.000554 / (2 * (6369051672525773 / 2 ^ 53)) := by
        apply div_le_div_of_nonneg_right _ (by norm_num)
        exact mul_le_mul hM.2 (by linarith) hE.le (by norm_num)
  have h3 : t * X ≤ 1.00001 / (11863283 / 2 ^ 24) * 0.000747 := by
    have e1 : t * (1.00001 * Real.exp (P u)) = 1.00001 / (11863283 / 2 ^ 24) * (u * Real.exp (P u)) := by
      rw [hu_def]; field_simp
    have e2 : u * Real.exp (P u) ≤ Real.exp (-7.2) := by
      calc u * Real.exp (P u) ≤ Real.exp (0.37 * u) * Real.exp (P u) :=
            mul_le_mul_of_nonneg_right (u_le_exp u hu0) (Real.exp_pos _).le
        _ = Real.exp (0.37 * u + P u) := by rw [Real.exp_add]
        _ ≤ Real.exp (-7.2) := Real.exp_le_exp.2 (by have := P_tail u hu; linarith)
    have e3 : Real.exp (-7.2) ≤ S (2*15) 7.2 := (S_bounds 15).1 7.2 (by norm_num)
    have e4 : S (2*15) 7.2 ≤ (0.000747:ℝ) := by norm_num [S, Finset.sum_range_succ, Nat.factorial]
    calc t * X ≤ t * (1.00001 * Real.exp (P u)) := mul_le_mul_of_nonneg_left hX1 ht
      _ = 1.00001 / (11863283 / 2 ^ 24) * (u * Real.exp (P u)) := e1
      _ ≤ 1.00001 / (11863283 / 2 ^ 24) * 0.000747 := by
        apply mul_le_mul_of_nonneg_left _ (by norm_num); linarith
  calc t * |x6f u - VoltaChallenge.erf y| ≤ t * ((1 - VoltaChallenge.erf y) + X) :=
        mul_le_mul_of_nonneg_left h1 ht
    _ = t * (1 - VoltaChallenge.erf y) + t * X := by ring
    _ ≤ 1.128381 * 0.000554 / (2 * (6369051672525773 / 2 ^ 53)) + 1.00001 / (11863283 / 2 ^ 24) * 0.000747 :=
        add_le_add h2 h3
    _ ≤ 0.002 := by norm_num

/-! Part 8: assembly -/

lemma main_t (t : ℝ) (ht : 0 ≤ t) :
    t * |x6f ((11863283 / 2 ^ 24 : ℝ) * t) - VoltaChallenge.erf (t * (6369051672525773 / 2 ^ 53 : ℝ))|
      ≤ 0.002 := by
  rcases le_or_gt ((11863283 / 2 ^ 24 : ℝ) * t) 2.75 with h | h
  · set u := (11863283 / 2 ^ 24 : ℝ) * t with hu_def
    set y := t * (6369051672525773 / 2 ^ 53 : ℝ) with hy_def
    have hu0 : 0 ≤ u := by positivity
    have hyu : u ≤ y := by rw [hu_def, hy_def]; nlinarith
    have h1 := regAB u hu0 h
    have h2 := erf_lip u y hu0 hyu
    have h3 : |x6f u - VoltaChallenge.erf y| ≤
        |x6f u - VoltaChallenge.erf u| + (VoltaChallenge.erf y - VoltaChallenge.erf u) := by
      have := abs_sub_le (x6f u) (VoltaChallenge.erf u) (VoltaChallenge.erf y)
      rwa [abs_sub_comm (VoltaChallenge.erf u), abs_of_nonneg h2.1] at this
    have ht' : t ≤ 2.75 / (11863283 / 2 ^ 24) := by rw [le_div_iff₀ (by norm_num)]; linarith
    have e1 : t * |x6f u - VoltaChallenge.erf u| =
        (u * |x6f u - VoltaChallenge.erf u|) / (11863283 / 2 ^ 24) := by rw [hu_def]; field_simp
    have e2 : y - u = (6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24) * t := by
      rw [hu_def, hy_def]; ring
    have hA : t * |x6f u - VoltaChallenge.erf u| ≤ 0.0014 / (11863283 / 2 ^ 24) := by
      rw [e1]; exact div_le_div_of_nonneg_right h1 (by norm_num)
    have hB : t * (VoltaChallenge.erf y - VoltaChallenge.erf u) ≤
        1.128381 * (6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24) * (2.75 / (11863283 / 2 ^ 24))^2 := by
      have h22 := h2.2; rw [e2] at h22
      have htt : t * t ≤ (2.75 / (11863283 / 2 ^ 24))^2 := by nlinarith
      calc t * (VoltaChallenge.erf y - VoltaChallenge.erf u)
          ≤ t * (1.128381 * ((6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24) * t)) :=
            mul_le_mul_of_nonneg_left h22 ht
        _ = 1.128381 * (6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24) * (t * t) := by ring
        _ ≤ _ := by apply mul_le_mul_of_nonneg_left htt; norm_num
    calc t * |x6f u - VoltaChallenge.erf y|
        ≤ t * (|x6f u - VoltaChallenge.erf u| + (VoltaChallenge.erf y - VoltaChallenge.erf u)) :=
          mul_le_mul_of_nonneg_left h3 ht
      _ = t * |x6f u - VoltaChallenge.erf u| + t * (VoltaChallenge.erf y - VoltaChallenge.erf u) := by
          ring
      _ ≤ 0.0014 / (11863283 / 2 ^ 24) + 1.128381 * (6369051672525773 / 2 ^ 53 - 11863283 / 2 ^ 24)
            * (2.75 / (11863283 / 2 ^ 24))^2 := add_le_add hA hB
      _ ≤ 0.002 := by norm_num
  · exact regC t ht h.le

lemma main_s (s : ℝ) :
    |(((if (11863283 / 2 ^ 24 : ℝ) * s < (0 : ℝ) then -x6f ((11863283 / 2 ^ 24 : ℝ) * s)
      else x6f ((11863283 / 2 ^ 24 : ℝ) * s)) * (s * (0.5 : ℝ))) + (s * (0.5 : ℝ)))
      - (((0.5 : ℝ) * s) * ((1 : ℝ) + VoltaChallenge.erf (s * (6369051672525773 / 2 ^ 53 : ℝ))))|
      ≤ (0.001 : ℝ) := by
  have hsym : ∀ x, x6f x = x6f |x| := by
    intro x; unfold x6f; rw [abs_abs, abs_mul_abs_self]
  rcases le_or_gt 0 s with hs | hs
  · have h1 : ¬ ((11863283 / 2 ^ 24 : ℝ) * s < 0) := not_lt.2 (by positivity)
    rw [if_neg h1]
    have hm := main_t s hs
    have e : x6f ((11863283 / 2 ^ 24 : ℝ) * s) * (s * 0.5) + s * 0.5
        - 0.5 * s * (1 + VoltaChallenge.erf (s * (6369051672525773 / 2 ^ 53 : ℝ)))
        = (s * 0.5) * (x6f ((11863283 / 2 ^ 24 : ℝ) * s)
          - VoltaChallenge.erf (s * (6369051672525773 / 2 ^ 53 : ℝ))) := by ring
    rw [e, abs_mul, abs_of_nonneg (by positivity : (0:ℝ) ≤ s * 0.5)]
    linarith
  · have h1 : (11863283 / 2 ^ 24 : ℝ) * s < 0 := by linarith
    rw [if_pos h1]
    have hm := main_t (-s) (by linarith)
    have habs : |(11863283 / 2 ^ 24 : ℝ) * s| = (11863283 / 2 ^ 24 : ℝ) * (-s) := by
      rw [abs_of_neg h1]; ring
    have hx : x6f ((11863283 / 2 ^ 24 : ℝ) * s) = x6f ((11863283 / 2 ^ 24 : ℝ) * (-s)) := by
      rw [hsym, habs]
    have herf : VoltaChallenge.erf (s * (6369051672525773 / 2 ^ 53 : ℝ)) =
        -VoltaChallenge.erf ((-s) * (6369051672525773 / 2 ^ 53 : ℝ)) := by
      rw [show (-s) * (6369051672525773 / 2 ^ 53 : ℝ) = -(s * (6369051672525773 / 2 ^ 53 : ℝ)) by ring,
        erf_neg, neg_neg]
    have e : -x6f ((11863283 / 2 ^ 24 : ℝ) * s) * (s * 0.5) + s * 0.5
        - 0.5 * s * (1 + VoltaChallenge.erf (s * (6369051672525773 / 2 ^ 53 : ℝ)))
        = (-s * 0.5) * (x6f ((11863283 / 2 ^ 24 : ℝ) * (-s))
          - VoltaChallenge.erf ((-s) * (6369051672525773 / 2 ^ 53 : ℝ))) := by
      rw [hx, herf]; ring
    rw [e, abs_mul, abs_of_nonneg (by linarith : (0:ℝ) ≤ -s * 0.5)]
    linarith

theorem key (x0 x7 : ℝ) (h : x0 = x7) :
    |(((if (11863283 / 2 ^ 24 : ℝ) * x0 < (0 : ℝ) then -x6f ((11863283 / 2 ^ 24 : ℝ) * x0)
      else x6f ((11863283 / 2 ^ 24 : ℝ) * x0)) * (x0 * (0.5 : ℝ))) + (x0 * (0.5 : ℝ)))
      - (((0.5 : ℝ) * x7) * ((1 : ℝ) + VoltaChallenge.erf (x7 * (6369051672525773 / 2 ^ 53 : ℝ))))|
      ≤ (0.001 : ℝ) := by
  subst h; exact main_s x0

theorem c_0 : VoltaChallenge.c_0 := by
  unfold VoltaChallenge.c_0
  intros
  refine key _ _ ?_
  try simp (config := { zetaDelta := true }) only []
  ring
theorem c_64 : VoltaChallenge.c_64 := by
  unfold VoltaChallenge.c_64
  intros
  refine key _ _ ?_
  try simp (config := { zetaDelta := true }) only []
  ring
theorem c_256 : VoltaChallenge.c_256 := by
  unfold VoltaChallenge.c_256
  intros
  refine key _ _ ?_
  try simp (config := { zetaDelta := true }) only []
  ring
theorem c_320 : VoltaChallenge.c_320 := by
  unfold VoltaChallenge.c_320
  intros
  refine key _ _ ?_
  try simp (config := { zetaDelta := true }) only []
  ring
theorem c_4096 : VoltaChallenge.c_4096 := by
  unfold VoltaChallenge.c_4096
  intros
  refine key _ _ ?_
  try simp (config := { zetaDelta := true }) only []
  ring
theorem c_4352 : VoltaChallenge.c_4352 := by
  unfold VoltaChallenge.c_4352
  intros
  refine key _ _ ?_
  try simp (config := { zetaDelta := true }) only []
  ring

end VoltaProofs
