import challenge

namespace VoltaProofs

noncomputable section

open Real

def Pp (x : ℝ) : ℝ := 135135 + 135135*x + 62370*x^2 + 17325*x^3 + 3150*x^4 + 378*x^5 + 28*x^6 + 1*x^7
def Qq (x : ℝ) : ℝ := 135135 + (-135135)*x + 62370*x^2 + (-17325)*x^3 + 3150*x^4 + (-378)*x^5 + 28*x^6 + (-1)*x^7
def G (x : ℝ) : ℝ := Qq x * Real.exp (2 * x) / Pp x

def X (v : ℝ) : ℝ := ((9577081 / 2 ^ 28 : ℝ) * ((v * v) * v)) + ((6693141 / 2 ^ 23 : ℝ) * v)
def Y (v : ℝ) : ℝ := (7186705221432913 / 2 ^ 53 : ℝ) * (v + ((((6444110634811895 / 2 ^ 57 : ℝ) * v) * v) * v))
def R (x : ℝ) : ℝ := ((1 : ℝ) / ((x*x * ((x*x * ((x*x * (28 : ℝ)) + (3150 : ℝ))) + (62370 : ℝ))) + (135135 : ℝ))) * (((x*x * ((x*x * ((x * x) + (378 : ℝ))) + (17325 : ℝ))) + (135135 : ℝ)) * x)
def T (x : ℝ) : ℝ := if (|x|) ≥ (3.7999999523162841796875 : ℝ) then if x < (0 : ℝ) then (-1 : ℝ) else (1 : ℝ) else min (max (R x) (-1 : ℝ)) (1 : ℝ)
def th (y : ℝ) : ℝ := (Real.exp ((2 : ℝ) * y) - (1 : ℝ)) / (Real.exp ((2 : ℝ) * y) + (1 : ℝ))
def Df (x : ℝ) : ℝ := x*x * ((x*x * ((x*x * (28 : ℝ)) + (3150 : ℝ))) + (62370 : ℝ)) + (135135 : ℝ)
def Nf (x : ℝ) : ℝ := ((x*x * ((x*x * ((x * x) + (378 : ℝ))) + (17325 : ℝ))) + (135135 : ℝ)) * x

lemma poly7_hasDerivAt (a0 a1 a2 a3 a4 a5 a6 a7 x : ℝ) :
    HasDerivAt (fun x => a0 + a1*x + a2*x^2 + a3*x^3 + a4*x^4 + a5*x^5 + a6*x^6 + a7*x^7)
      (a1 + 2*a2*x + 3*a3*x^2 + 4*a4*x^3 + 5*a5*x^4 + 6*a6*x^5 + 7*a7*x^6) x := by
  have h := ((((((((hasDerivAt_const x a0).add ((hasDerivAt_id x).const_mul a1)).add
    ((hasDerivAt_pow 2 x).const_mul a2)).add ((hasDerivAt_pow 3 x).const_mul a3)).add
    ((hasDerivAt_pow 4 x).const_mul a4)).add ((hasDerivAt_pow 5 x).const_mul a5)).add
    ((hasDerivAt_pow 6 x).const_mul a6)).add ((hasDerivAt_pow 7 x).const_mul a7))
  refine h.congr_deriv ?_
  norm_num
  ring

lemma Pp_pos (x : ℝ) (hx : 0 ≤ x) : 0 < Pp x := by unfold Pp; positivity

lemma G_hasDeriv (x : ℝ) (hx : 0 ≤ x) :
    HasDerivAt G (Real.exp (2*x) * (-2 * x^14) / Pp x ^ 2) x := by
  have hP : HasDerivAt Pp _ x := poly7_hasDerivAt 135135 135135 62370 17325 3150 378 28 1 x
  have hQ : HasDerivAt Qq _ x :=
    poly7_hasDerivAt 135135 (-135135) 62370 (-17325) 3150 (-378) 28 (-1) x
  have hE : HasDerivAt (fun x => Real.exp (2*x)) (Real.exp (2*x) * 2) x := by
    have := ((hasDerivAt_id x).const_mul (2:ℝ)).exp
    simpa using this
  have h := (hQ.mul hE).div hP (Pp_pos x hx).ne'
  refine h.congr_deriv ?_
  congr 1
  simp only [Pi.mul_apply]
  unfold Pp Qq
  ring

lemma G_anti : AntitoneOn G (Set.Ici 0) := by
  apply antitoneOn_of_deriv_nonpos (convex_Ici 0)
  · intro x hx
    exact (G_hasDeriv x hx).continuousAt.continuousWithinAt
  · intro x hx
    rw [interior_Ici] at hx
    exact (G_hasDeriv x (le_of_lt hx)).differentiableAt.differentiableWithinAt
  · intro x hx
    rw [interior_Ici] at hx
    rw [(G_hasDeriv x (le_of_lt hx)).deriv]
    have hP := Pp_pos x (le_of_lt hx)
    have : 0 ≤ Real.exp (2*x) * (2*x^14) / Pp x ^ 2 := by positivity
    have e : Real.exp (2*x) * (-2 * x^14) / Pp x ^ 2 = -(Real.exp (2*x) * (2*x^14) / Pp x ^ 2) := by ring
    linarith

lemma G_zero : G 0 = 1 := by
  unfold G Qq Pp; norm_num

lemma e6 : (403.4 : ℝ) ≤ Real.exp 6 := by
  have h : Real.exp 1 ^ 6 = Real.exp 6 := by rw [← Real.exp_nat_mul]; norm_num
  rw [← h]
  have := pow_le_pow_left₀ (by norm_num) (le_of_lt Real.exp_one_gt_d9) 6
  have h2 : (403.4:ℝ) ≤ 2.7182818283^6 := by norm_num
  linarith

lemma e7 : (1096.6 : ℝ) ≤ Real.exp 7 := by
  have h : Real.exp 1 ^ 7 = Real.exp 7 := by rw [← Real.exp_nat_mul]; norm_num
  rw [← h]
  have := pow_le_pow_left₀ (by norm_num) (le_of_lt Real.exp_one_gt_d9) 7
  have h2 : (1096.6:ℝ) ≤ 2.7182818283^7 := by norm_num
  linarith

lemma e76 : (1890 : ℝ) ≤ Real.exp 7.6 := by
  have h1 : Real.exp 7.6 = Real.exp 7 * Real.exp 0.2 ^ 3 := by
    rw [← Real.exp_nat_mul, ← Real.exp_add]; norm_num
  have h2 : (1.2:ℝ) ≤ Real.exp 0.2 := by have := Real.add_one_le_exp 0.2; linarith
  have h3 : (1.2:ℝ)^3 ≤ Real.exp 0.2 ^ 3 := pow_le_pow_left₀ (by norm_num) h2 3
  have h4 := mul_le_mul e7 h3 (by norm_num) (Real.exp_pos 7).le
  rw [h1]; norm_num at h4 ⊢; linarith

lemma G3 : (0.999 : ℝ) ≤ G 3 := by
  unfold G
  rw [show (2:ℝ)*3 = 6 by norm_num, le_div_iff₀ (Pp_pos 3 (by norm_num))]
  have := e6
  norm_num [Qq, Pp]
  linarith

lemma G38 : (0.9 : ℝ) ≤ G 3.8 := by
  unfold G
  rw [show (2:ℝ)*3.8 = 7.6 by norm_num, le_div_iff₀ (Pp_pos 3.8 (by norm_num))]
  have := e76
  norm_num [Qq, Pp]
  linarith

lemma R_eq (x : ℝ) : R x = Nf x / Df x := by unfold R Nf Df; ring
lemma P_eq (x : ℝ) : Pp x = Df x + Nf x := by unfold Pp Df Nf; ring
lemma Q_eq (x : ℝ) : Qq x = Df x - Nf x := by unfold Qq Df Nf; ring

lemma core (v D N E E0 κ η : ℝ) (hv : 0 ≤ v) (hD : 0 < D) (hE0 : 1 ≤ E0)
    (F1 : (D - N) * E0 ≤ D + N) (F2 : κ * (D + N) ≤ (D - N) * E0) (hκ0 : 0 ≤ κ) (hκ1 : κ ≤ 1)
    (hη : 0 ≤ η) (hη1 : η ≤ 1) (hEu : E ≤ E0 * (1 + η)) (hEl : E0 * (1 - η) ≤ E) (hE : 1 ≤ E)
    (h1 : 2 * v * (1 - κ * (1 - η)) ≤ 0.004 * (E + 1)) (h2 : 2 * v * η ≤ 0.004 * (E + 1)) :
    v * |N / D - (E - 1) / (E + 1)| ≤ 0.004 := by
  have hDN : 0 ≤ D - N := by
    by_contra h
    push_neg at h
    have a : (D - N) * E0 < 0 := mul_neg_of_neg_of_pos h (by linarith)
    have b : 0 ≤ κ * (D + N) := by
      have : 0 ≤ D + N := by nlinarith
      exact mul_nonneg hκ0 this
    linarith
  have hE1 : 0 < E + 1 := by linarith
  rw [div_sub_div _ _ hD.ne' hE1.ne', abs_div, abs_of_pos (mul_pos hD hE1), ← mul_div_assoc,
    div_le_iff₀ (mul_pos hD hE1)]
  have hk : κ * (1 - η) ≤ 1 := by
    have := mul_le_mul hκ1 (show 1 - η ≤ 1 by linarith) (by linarith) (by norm_num)
    linarith
  have hU : N*(E+1) - D*(E-1) ≤ (1 - κ*(1-η)) * (2*D) := by
    have a1 : E0*(1-η)*(D-N) ≤ E*(D-N) := mul_le_mul_of_nonneg_right hEl hDN
    have a2 : κ*(D+N)*(1-η) ≤ (D-N)*E0*(1-η) := mul_le_mul_of_nonneg_right F2 (by linarith)
    have a3 : (1 - κ*(1-η)) * (D+N) ≤ (1 - κ*(1-η)) * (2*D) :=
      mul_le_mul_of_nonneg_left (by linarith) (by linarith)
    nlinarith
  have hL : D*(E-1) - N*(E+1) ≤ η * (2*D) := by
    have a1 : E*(D-N) ≤ E0*(1+η)*(D-N) := mul_le_mul_of_nonneg_right hEu hDN
    have a2 : (D-N)*E0*(1+η) ≤ (D+N)*(1+η) := mul_le_mul_of_nonneg_right F1 (by linarith)
    have a3 : η*(D+N) ≤ η*(2*D) := mul_le_mul_of_nonneg_left (by linarith) hη
    nlinarith
  rcases abs_cases (N*(E+1) - D*(E-1)) with ⟨h, _⟩ | ⟨h, _⟩ <;> rw [h]
  · have b1 : v * (N*(E+1) - D*(E-1)) ≤ v * ((1 - κ*(1-η)) * (2*D)) :=
      mul_le_mul_of_nonneg_left hU hv
    have b2 : D * (2*v*(1-κ*(1-η))) ≤ D * (0.004*(E+1)) := mul_le_mul_of_nonneg_left h1 hD.le
    nlinarith
  · have b1 : v * (-(N*(E+1) - D*(E-1))) ≤ v * (η*(2*D)) :=
      mul_le_mul_of_nonneg_left (by linarith) hv
    have b2 : D * (2*v*η) ≤ D * (0.004*(E+1)) := mul_le_mul_of_nonneg_left h2 hD.le
    nlinarith

lemma clamp_le (r t : ℝ) (ht0 : -1 ≤ t) (ht1 : t ≤ 1) :
    |min (max r (-1)) 1 - t| ≤ |r - t| := by
  rcases le_total r (-1) with h1 | h1
  · have hm : min (max r (-1)) 1 = -1 := by rw [max_eq_right h1]; norm_num
    rw [hm, abs_of_nonpos (by linarith), abs_of_nonpos (by linarith)]; linarith
  rcases le_total r 1 with h2 | h2
  · have hm : min (max r (-1)) 1 = r := by rw [max_eq_left h1, min_eq_left h2]
    rw [hm]
  · have hm : min (max r (-1)) 1 = 1 := by rw [max_eq_left h1, min_eq_right h2]
    rw [hm, abs_of_nonneg (by linarith), abs_of_nonneg (by linarith)]; linarith

lemma key (v : ℝ) (hv : 0 ≤ v) : v * |T (X v) - th (Y v)| ≤ 0.004 := by
  have hX : 0 ≤ X v := by unfold X; positivity
  have hY : 0 ≤ Y v := by unfold Y; positivity
  have hv3 : 0 ≤ v*v*v := by positivity
  have hE1 : 1 ≤ Real.exp (2 * Y v) := Real.one_le_exp (by linarith)
  have hth : th (Y v) = (Real.exp (2 * Y v) - 1) / (Real.exp (2 * Y v) + 1) := rfl
  by_cases hB : (3.7999999523162841796875:ℝ) ≤ X v
  · have hT : T (X v) = 1 := by
      unfold T
      rw [if_pos (by rw [abs_of_nonneg hX]; exact hB), if_neg (not_lt.mpr hX)]
    rw [hT, hth]
    have hvB : 3.23 ≤ v := by
      by_contra h
      push_neg at h
      have h0 : v*v ≤ 3.23*3.23 := by nlinarith
      have h1 : v*v*v ≤ 3.23*3.23*3.23 := by nlinarith
      unfold X at hB
      norm_num at hB h1
      nlinarith
    have hY2 : 2.34 * v ≤ 2 * Y v := by
      have h1 : 10.4329 * v ≤ v*v*v := by
        have : 10.4329 ≤ v*v := by nlinarith
        nlinarith
      unfold Y
      norm_num
      nlinarith
    have hEb : Real.exp 7 * (2 * Y v - 6) ≤ Real.exp (2 * Y v) := by
      have h1 := Real.add_one_le_exp (2 * Y v - 7)
      have h2 : Real.exp (2 * Y v) = Real.exp 7 * Real.exp (2 * Y v - 7) := by
        rw [← Real.exp_add]; congr 1; ring
      rw [h2]
      apply mul_le_mul_of_nonneg_left _ (Real.exp_pos 7).le
      linarith
    have he7 := e7
    have hE2 : 500 * v ≤ Real.exp (2 * Y v) + 1 := by
      have : 1096.6 * (2 * Y v - 6) ≤ Real.exp 7 * (2 * Y v - 6) :=
        mul_le_mul_of_nonneg_right he7 (by linarith)
      nlinarith
    have : 1 - (Real.exp (2 * Y v) - 1) / (Real.exp (2 * Y v) + 1)
        = 2 / (Real.exp (2 * Y v) + 1) := by
      field_simp; ring
    rw [this, abs_of_pos (by positivity), ← mul_div_assoc, div_le_iff₀ (by positivity)]
    linarith
  · push_neg at hB
    have hT : T (X v) = min (max (R (X v)) (-1)) 1 := by
      unfold T
      rw [if_neg (by rw [abs_of_nonneg hX]; exact not_le.mpr hB)]
    rw [hT]
    have hvA : v ≤ 3.25 := by
      by_contra h
      push_neg at h
      have h0 : 3.25*3.25 ≤ v*v := by nlinarith
      have h1 : 3.25*3.25*3.25 ≤ v*v*v := by nlinarith
      unfold X at hB
      norm_num at hB h1
      nlinarith
    have hv3u : v*v*v ≤ 34.33 := by
      have h0 : v*v ≤ 3.25*3.25 := by nlinarith
      nlinarith
    have hdiff : |2 * Y v - 2 * X v| ≤ 1e-5 := by
      rw [abs_le]
      unfold X Y
      constructor
      · norm_num; nlinarith
      · norm_num; nlinarith
    have hw := Real.abs_exp_sub_one_le (x := 2 * Y v - 2 * X v) (le_trans hdiff (by norm_num))
    rw [abs_le] at hw
    have hu1 : Real.exp (2 * Y v - 2 * X v) ≤ 1 + 2e-5 := by linarith [hw.2]
    have hu2 : 1 - 2e-5 ≤ Real.exp (2 * Y v - 2 * X v) := by linarith [hw.1]
    have hEE : Real.exp (2 * Y v) = Real.exp (2 * X v) * Real.exp (2 * Y v - 2 * X v) := by
      rw [← Real.exp_add]; congr 1; ring
    have hE0p := Real.exp_pos (2 * X v)
    have hEu : Real.exp (2 * Y v) ≤ Real.exp (2 * X v) * (1 + 2e-5) := by
      rw [hEE]; exact mul_le_mul_of_nonneg_left hu1 hE0p.le
    have hEl : Real.exp (2 * X v) * (1 - 2e-5) ≤ Real.exp (2 * Y v) := by
      rw [hEE]; exact mul_le_mul_of_nonneg_left hu2 hE0p.le
    have hE01 : 1 ≤ Real.exp (2 * X v) := Real.one_le_exp (by linarith)
    have hPp := Pp_pos (X v) hX
    have hG1 : G (X v) ≤ 1 := by
      have := G_anti (Set.self_mem_Ici) (show X v ∈ Set.Ici (0:ℝ) from hX) hX
      rw [G_zero] at this; exact this
    unfold G at hG1
    rw [div_le_one hPp, Q_eq, P_eq] at hG1
    have hDf : 0 < Df (X v) := by unfold Df; positivity
    have hthb0 : -1 ≤ th (Y v) := by
      rw [hth, le_div_iff₀ (by positivity)]; linarith
    have hthb1 : th (Y v) ≤ 1 := by
      rw [hth, div_le_one (by positivity)]; linarith
    have hcl := clamp_le (R (X v)) (th (Y v)) hthb0 hthb1
    have hmul := mul_le_mul_of_nonneg_left hcl hv
    refine le_trans hmul ?_
    rw [R_eq, hth]
    rcases le_or_gt (X v) 3 with hx3 | hx3
    · have hv28 : v ≤ 2.8 := by
        by_contra h
        push_neg at h
        have h0 : 2.8*2.8 ≤ v*v := by nlinarith
        have h1 : 2.8*2.8*2.8 ≤ v*v*v := by nlinarith
        unfold X at hx3
        norm_num at hx3 h1
        nlinarith
      have hG2 : 0.999 ≤ G (X v) :=
        le_trans G3 (G_anti (show X v ∈ Set.Ici (0:ℝ) from hX)
          (show (3:ℝ) ∈ Set.Ici (0:ℝ) by norm_num [Set.mem_Ici]) hx3)
      unfold G at hG2
      rw [le_div_iff₀ hPp, Q_eq, P_eq] at hG2
      apply core v (Df (X v)) (Nf (X v)) (Real.exp (2 * Y v)) (Real.exp (2 * X v)) 0.999 2e-5
        hv hDf hE01 hG1 hG2 (by norm_num) (by norm_num) (by norm_num) (by norm_num)
        hEu hEl hE1
      · linarith
      · linarith
    · have hG2 : 0.9 ≤ G (X v) :=
        le_trans G38 (G_anti (show X v ∈ Set.Ici (0:ℝ) from hX)
          (show (3.8:ℝ) ∈ Set.Ici (0:ℝ) by norm_num [Set.mem_Ici]) (by linarith))
      unfold G at hG2
      rw [le_div_iff₀ hPp, Q_eq, P_eq] at hG2
      have h6 : Real.exp 6 ≤ Real.exp (2 * X v) := Real.exp_le_exp.mpr (by linarith)
      have h6' := e6
      have hbig : 400 ≤ Real.exp (2 * Y v) := by linarith
      apply core v (Df (X v)) (Nf (X v)) (Real.exp (2 * Y v)) (Real.exp (2 * X v)) 0.9 2e-5
        hv hDf hE01 hG1 hG2 (by norm_num) (by norm_num) (by norm_num) (by norm_num)
        hEu hEl hE1
      · linarith
      · linarith

lemma X_neg (v : ℝ) : X (-v) = -X v := by unfold X; ring
lemma Y_neg (v : ℝ) : Y (-v) = -Y v := by unfold Y; ring
lemma R_neg (x : ℝ) : R (-x) = -R x := by
  unfold R; rw [show (-x)*(-x) = x*x by ring]; ring

lemma clamp_neg (r : ℝ) : min (max (-r) (-1)) 1 = -(min (max r (-1)) 1) := by
  simp only [min_def, max_def]
  split_ifs <;> linarith

lemma T_neg (x : ℝ) : T (-x) = -T x := by
  unfold T
  rw [abs_neg]
  by_cases h : |x| ≥ (3.7999999523162841796875 : ℝ)
  · rw [if_pos h, if_pos h]
    have hx0 : x ≠ 0 := by
      intro h0; rw [h0, abs_zero] at h; norm_num at h
    rcases lt_or_gt_of_ne hx0 with hl | hl
    · rw [if_neg (by linarith : ¬ (-x < 0)), if_pos hl]; norm_num
    · rw [if_pos (by linarith : -x < 0), if_neg (by linarith : ¬ x < 0)]
  · rw [if_neg h, if_neg h, R_neg]; exact clamp_neg _

lemma th_neg (y : ℝ) : th (-y) = -th y := by
  unfold th
  rw [show (2:ℝ) * -y = -(2*y) by ring, Real.exp_neg]
  have he := Real.exp_pos (2*y)
  field_simp
  ring

lemma full (v : ℝ) : |v| * |T (X v) - th (Y v)| ≤ 0.004 := by
  rcases le_total 0 v with h | h
  · rw [abs_of_nonneg h]; exact key v h
  · rw [abs_of_nonpos h]
    have := key (-v) (by linarith)
    rw [X_neg, Y_neg, T_neg, th_neg] at this
    rwa [show -T (X v) - -th (Y v) = -(T (X v) - th (Y v)) by ring, abs_neg] at this

theorem out_0 : VoltaChallenge.out_0 := by
  intro v0
  show |(0.5 : ℝ) * ((v0 * T (X v0)) + v0) - (((0.5 : ℝ) * v0) * ((1 : ℝ) + th (Y v0)))| ≤ (0.002 : ℝ)
  have e : (0.5 : ℝ) * ((v0 * T (X v0)) + v0) - (((0.5 : ℝ) * v0) * ((1 : ℝ) + th (Y v0)))
      = 0.5 * (v0 * (T (X v0) - th (Y v0))) := by ring
  rw [e, abs_mul, abs_mul, abs_of_pos (by norm_num : (0:ℝ) < 0.5)]
  have := full v0
  linarith

end

end VoltaProofs
