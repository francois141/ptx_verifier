import challenge

set_option maxRecDepth 16384

noncomputable section

namespace VoltaProofs

open Real MeasureTheory intervalIntegral Filter Topology Set

local notation "kR" => (8388608 / 12102203 : ℝ)
local notation "T0" => (1.0029599666595458984375 : ℝ)
local notation "cA" => (11863283 / 2 ^ 24 : ℝ)
local notation "cB" => (6369051672525773 / 2 ^ 53 : ℝ)

/-! ## Polynomials as coefficient lists -/

def addL : List ℚ → List ℚ → List ℚ
  | [], l => l
  | a :: l1, [] => a :: l1
  | a :: l1, b :: l2 => (a + b) :: addL l1 l2

def scaleL (c : ℚ) : List ℚ → List ℚ
  | [] => []
  | a :: l => (c * a) :: scaleL c l

def mulL : List ℚ → List ℚ → List ℚ
  | [], _ => []
  | a :: l1, l2 => addL (scaleL a l2) (0 :: mulL l1 l2)

def derivL : List ℚ → List ℚ
  | [] => []
  | _ :: l => addL l (0 :: derivL l)

def compL (q : List ℚ) : List ℚ → List ℚ
  | [] => []
  | a :: l => addL [a] (mulL q (compL q l))

def shiftL (m : ℚ) : List ℚ → List ℚ
  | [] => []
  | a :: l => addL [a] (mulL [m, 1] (shiftL m l))

def integAux : ℕ → List ℚ → List ℚ
  | _, [] => []
  | n, a :: l => (a / (n + 1)) :: integAux (n + 1) l

def integL (l : List ℚ) : List ℚ := 0 :: integAux 0 l

def bnd (w : ℚ) : List ℚ → ℚ
  | [] => 0
  | a :: l => |a| + w * bnd w l

def ubQ (w : ℚ) : List ℚ → ℚ
  | [] => 0
  | a :: l => a + w * bnd w l

def lbQ (w : ℚ) : List ℚ → ℚ
  | [] => 0
  | a :: l => a - w * bnd w l

def evalL (x : ℝ) : List ℚ → ℝ
  | [] => 0
  | a :: l => (a : ℝ) + x * evalL x l

@[simp] lemma evalL_nil (x : ℝ) : evalL x [] = 0 := rfl
@[simp] lemma evalL_cons (x : ℝ) (a : ℚ) (l : List ℚ) : evalL x (a :: l) = a + x * evalL x l := rfl

lemma evalL_addL (x : ℝ) : ∀ l1 l2 : List ℚ, evalL x (addL l1 l2) = evalL x l1 + evalL x l2
  | [], l => by simp [addL]
  | a :: l1, [] => by simp [addL]
  | a :: l1, b :: l2 => by
    simp only [addL, evalL_cons, evalL_addL x l1 l2]; push_cast; ring

lemma evalL_scaleL (x : ℝ) (c : ℚ) : ∀ l : List ℚ, evalL x (scaleL c l) = c * evalL x l
  | [] => by simp [scaleL]
  | a :: l => by simp only [scaleL, evalL_cons, evalL_scaleL x c l]; push_cast; ring

lemma evalL_mulL (x : ℝ) : ∀ l1 l2 : List ℚ, evalL x (mulL l1 l2) = evalL x l1 * evalL x l2
  | [], l => by simp [mulL]
  | a :: l1, l2 => by
    simp only [mulL, evalL_addL, evalL_scaleL, evalL_cons, evalL_mulL x l1 l2]; push_cast; ring

lemma evalL_compL (x : ℝ) (q : List ℚ) : ∀ l : List ℚ, evalL x (compL q l) = evalL (evalL x q) l
  | [] => by simp [compL]
  | a :: l => by
    simp only [compL, evalL_addL, evalL_mulL, evalL_cons, evalL_nil, evalL_compL x q l]; ring

lemma evalL_shiftL (m : ℚ) (u : ℝ) : ∀ l : List ℚ, evalL u (shiftL m l) = evalL ((m : ℝ) + u) l
  | [] => by simp [shiftL]
  | a :: l => by
    simp only [shiftL, evalL_addL, evalL_mulL, evalL_cons, evalL_nil, evalL_shiftL m u l]
    push_cast; ring

lemma hasDerivAt_evalL (x : ℝ) : ∀ l : List ℚ, HasDerivAt (fun y => evalL y l) (evalL x (derivL l)) x
  | [] => hasDerivAt_const x (0 : ℝ)
  | a :: l => by
    have h : HasDerivAt (fun y => (a:ℝ) + y * evalL y l) (1 * evalL x l + x * evalL x (derivL l)) x :=
      ((hasDerivAt_id' x).mul (hasDerivAt_evalL x l)).const_add (a : ℝ)
    have e : evalL x (derivL (a :: l)) = 1 * evalL x l + x * evalL x (derivL l) := by
      simp only [derivL, evalL_addL, evalL_cons]; push_cast; ring
    rw [e]; exact h

lemma continuous_evalL (l : List ℚ) : Continuous (fun y => evalL y l) :=
  continuous_iff_continuousAt.2 fun x => (hasDerivAt_evalL x l).continuousAt

lemma hasDerivAt_integAux (x : ℝ) : ∀ (l : List ℚ) (n : ℕ),
    HasDerivAt (fun y => y ^ (n + 1) * evalL y (integAux n l)) (x ^ n * evalL x l) x
  | [], n => by
    have e : (fun y : ℝ => y ^ (n + 1) * evalL y (integAux n [])) = fun _ => 0 := by
      funext y; simp [integAux]
    rw [e]; simpa using hasDerivAt_const x (0 : ℝ)
  | a :: l, n => by
    have h1 := (hasDerivAt_pow (n + 1) x).const_mul ((a : ℝ) / (n + 1))
    have h2 := hasDerivAt_integAux x l (n + 1)
    have h : HasDerivAt (fun y => (a : ℝ) / (n + 1) * y ^ (n + 1) + y ^ (n + 1 + 1) * evalL y (integAux (n + 1) l))
        ((a : ℝ) / (n + 1) * (↑(n + 1) * x ^ (n + 1 - 1)) + x ^ (n + 1) * evalL x l) x := h1.add h2
    have e1 : (fun y : ℝ => y ^ (n + 1) * evalL y (integAux n (a :: l))) =
        (fun y => (a : ℝ) / (n + 1) * y ^ (n + 1) + y ^ (n + 1 + 1) * evalL y (integAux (n + 1) l)) := by
      funext y; simp only [integAux, evalL_cons]; push_cast; ring
    have e2 : x ^ n * evalL x (a :: l) = (a : ℝ) / (n + 1) * (↑(n + 1) * x ^ (n + 1 - 1)) + x ^ (n + 1) * evalL x l := by
      rw [Nat.add_sub_cancel]; simp only [evalL_cons]; push_cast; field_simp; ring
    rw [e1, e2]; exact h

lemma hasDerivAt_integL (x : ℝ) (l : List ℚ) :
    HasDerivAt (fun y => evalL y (integL l)) (evalL x l) x := by
  have h := hasDerivAt_integAux x l 0
  have e1 : (fun y : ℝ => evalL y (integL l)) = fun y => y ^ (0 + 1) * evalL y (integAux 0 l) := by
    funext y; simp [integL]
  rw [e1]; simpa using h

lemma integral_evalL (a b : ℝ) (l : List ℚ) :
    ∫ s in a..b, evalL s l = evalL b (integL l) - evalL a (integL l) :=
  integral_eq_sub_of_hasDerivAt (fun x _ => hasDerivAt_integL x l)
    ((continuous_evalL l).intervalIntegrable a b)

lemma bnd_nonneg (w : ℚ) (hw : 0 ≤ w) : ∀ l : List ℚ, 0 ≤ bnd w l
  | [] => le_refl _
  | a :: l => by
    simp only [bnd]; have := bnd_nonneg w hw l; positivity

lemma abs_evalL_le (w : ℚ) (hw : 0 ≤ w) (u : ℝ) (hu : |u| ≤ w) :
    ∀ l : List ℚ, |evalL u l| ≤ (bnd w l : ℝ)
  | [] => by simp [bnd]
  | a :: l => by
    have ih := abs_evalL_le w hw u hu l
    simp only [evalL_cons, bnd]; push_cast
    calc |(a : ℝ) + u * evalL u l| ≤ |(a : ℝ)| + |u * evalL u l| := abs_add_le _ _
      _ = |(a:ℝ)| + |u| * |evalL u l| := by rw [abs_mul]
      _ ≤ |(a:ℝ)| + (w:ℝ) * (bnd w l : ℝ) := by
        have := mul_le_mul hu ih (abs_nonneg _) (by exact_mod_cast hw)
        linarith

lemma evalL_le_ub (w : ℚ) (hw : 0 ≤ w) (u : ℝ) (hu : |u| ≤ w) (l : List ℚ) :
    evalL u l ≤ (ubQ w l : ℝ) := by
  cases l with
  | nil => simp [ubQ]
  | cons a l =>
    have h1 := abs_evalL_le w hw u hu l
    simp only [evalL_cons, ubQ]; push_cast
    have h2 : u * evalL u l ≤ (w:ℝ) * (bnd w l : ℝ) := by
      calc u * evalL u l ≤ |u * evalL u l| := le_abs_self _
        _ = |u| * |evalL u l| := abs_mul _ _
        _ ≤ _ := mul_le_mul hu h1 (abs_nonneg _) (by exact_mod_cast hw)
    linarith

lemma lb_le_evalL (w : ℚ) (hw : 0 ≤ w) (u : ℝ) (hu : |u| ≤ w) (l : List ℚ) :
    (lbQ w l : ℝ) ≤ evalL u l := by
  cases l with
  | nil => simp [lbQ]
  | cons a l =>
    have h1 := abs_evalL_le w hw u hu l
    simp only [evalL_cons, lbQ]; push_cast
    have h2 : -((w:ℝ) * (bnd w l : ℝ)) ≤ u * evalL u l := by
      have : |u * evalL u l| ≤ (w:ℝ) * (bnd w l : ℝ) := by
        rw [abs_mul]; exact mul_le_mul hu h1 (abs_nonneg _) (by exact_mod_cast hw)
      linarith [neg_abs_le (u * evalL u l)]
    linarith

lemma cell_ub (m w : ℚ) (l : List ℚ) (hw : 0 ≤ w) (hc : ubQ w (shiftL m l) ≤ 0)
    (s : ℝ) (hs : |s - m| ≤ w) : evalL s l ≤ 0 := by
  have h := evalL_le_ub w hw (s - m) hs (shiftL m l)
  rw [evalL_shiftL, add_sub_cancel] at h
  exact h.trans (by exact_mod_cast hc)

lemma cell_lb (m w : ℚ) (l : List ℚ) (hw : 0 ≤ w) (hc : 0 ≤ lbQ w (shiftL m l))
    (s : ℝ) (hs : |s - m| ≤ w) : 0 ≤ evalL s l := by
  have h := lb_le_evalL w hw (s - m) hs (shiftL m l)
  rw [evalL_shiftL, add_sub_cancel] at h
  exact le_trans (by exact_mod_cast hc) h

/-! ## The concrete polynomials -/

def gl : List ℚ := [0, 1 + 5270561 / 2^23, 7686591 / 2^23, 5143683 / 2^25, -4604081 / 2^27,
  11305995 / 2^31, -16081081 / 2^35, 2257551 / 2^37]
def Al : List ℚ := [0, 1 + 8615379 / 2^26, 0, -3155179 / 2^23, 0, 15145135 / 2^27, 0,
  -14425063 / 2^29, 0, 5597941 / 2^30, 0, -440937 / 2^29, 0, 5829813 / 2^36]
def G1l : List ℚ := derivL gl
def G2l : List ℚ := derivL G1l
def PpL : List ℚ := addL G2l (addL (mulL [-1/5000, 2] G1l) (scaleL (-(8388608/12102203)) (mulL G1l G1l)))
def PmL : List ℚ := addL G2l (addL (mulL [1/5000, 2] G1l) (scaleL (-(8388608/12102203)) (mulL G1l G1l)))
def expL : List ℚ := [1, 1, 1/2, 1/6, 1/24, 1/120, 1/720, 1/5040, 1/40320, 1/362880, 1/3628800,
  1/39916800, 1/479001600, 1/6227020800]
def Cl : List ℚ := compL [1, 0, -1] expL
def Jl : List ℚ := integL Cl
def Dl : List ℚ := addL Al (scaleL (-(4151075 / 10^7)) Jl)

lemma num_Pp1 : ubQ (1/2) (shiftL (3/2) PpL) ≤ 0 := by
  norm_num [ubQ, bnd, shiftL, PpL, G2l, G1l, gl, addL, scaleL, mulL, derivL]
lemma num_Pp2 : ubQ (1/4) (shiftL (9/4) PpL) ≤ 0 := by
  norm_num [ubQ, bnd, shiftL, PpL, G2l, G1l, gl, addL, scaleL, mulL, derivL]
lemma num_Pp3 : ubQ (1/4) (shiftL (11/4) PpL) ≤ 0 := by
  norm_num [ubQ, bnd, shiftL, PpL, G2l, G1l, gl, addL, scaleL, mulL, derivL]
lemma num_Pm1 : 0 ≤ lbQ (1/2) (shiftL (3/2) PmL) := by
  norm_num [lbQ, bnd, shiftL, PmL, G2l, G1l, gl, addL, scaleL, mulL, derivL]
lemma num_Pm2 : 0 ≤ lbQ (1/4) (shiftL (9/4) PmL) := by
  norm_num [lbQ, bnd, shiftL, PmL, G2l, G1l, gl, addL, scaleL, mulL, derivL]
lemma num_Pm3 : 0 ≤ lbQ (1/4) (shiftL (11/4) PmL) := by
  norm_num [lbQ, bnd, shiftL, PmL, G2l, G1l, gl, addL, scaleL, mulL, derivL]
lemma num_D : bnd 1.0029599666595458984375 Dl ≤ 11 / 100000 := by
  norm_num [bnd, Dl, Jl, integL, integAux, Cl, compL, expL, Al, addL, scaleL, mulL]
lemma num_J : bnd 1.0029599666595458984375 Jl ≤ 5 := by
  norm_num [bnd, Jl, integL, integAux, Cl, compL, expL, addL, scaleL, mulL]

lemma sum_exp14 (x : ℝ) : ∑ m ∈ Finset.range 14, x ^ m / (m.factorial : ℝ) = evalL x expL := by
  simp only [Finset.sum_range_succ, Finset.sum_range_zero, Nat.factorial, expL, evalL_cons, evalL_nil]
  push_cast; ring

/-! ## erf -/

def kap : ℝ := 2 / Real.sqrt Real.pi

lemma erf_def (x : ℝ) : VoltaChallenge.erf x = kap * ∫ t in (0:ℝ)..x, Real.exp (-t ^ 2) := rfl

lemma gcont : Continuous (fun t : ℝ => Real.exp (-t ^ 2)) := by fun_prop

lemma gii (a b : ℝ) : IntervalIntegrable (fun t : ℝ => Real.exp (-t ^ 2)) volume a b :=
  gcont.intervalIntegrable a b

lemma erf_sub (a b : ℝ) :
    VoltaChallenge.erf b - VoltaChallenge.erf a = kap * ∫ t in a..b, Real.exp (-t ^ 2) := by
  rw [erf_def, erf_def, ← mul_sub, integral_interval_sub_left (gii 0 b) (gii 0 a)]

lemma kap_pos : 0 < kap := div_pos two_pos (Real.sqrt_pos.mpr Real.pi_pos)

lemma sqrtpi_bounds : 1.7724536 < Real.sqrt Real.pi ∧ Real.sqrt Real.pi < 1.7724541 := by
  have h1 := Real.pi_gt_d6
  have h2 := Real.pi_lt_d6
  constructor
  · rw [Real.lt_sqrt (by norm_num)]; norm_num; linarith
  · rw [Real.sqrt_lt' (by norm_num)]; norm_num; linarith

lemma kap_bounds : 1.1283788 < kap ∧ kap < 1.1283795 := by
  obtain ⟨h1, h2⟩ := sqrtpi_bounds
  have hs : 0 < Real.sqrt Real.pi := by linarith
  unfold kap
  constructor
  · rw [lt_div_iff₀ hs]; nlinarith
  · rw [div_lt_iff₀ hs]; nlinarith

lemma kap_mul_sqrt : kap * (Real.sqrt Real.pi / 2) = 1 := by
  unfold kap; have : 0 < Real.sqrt Real.pi := Real.sqrt_pos.mpr Real.pi_pos; field_simp

lemma gauss_Ioi : ∫ x in Ioi (0:ℝ), Real.exp (-x ^ 2) = Real.sqrt Real.pi / 2 := by
  have h := integral_gaussian_Ioi 1
  simp only [neg_mul, one_mul, div_one] at h
  exact h

lemma gauss_integrableOn : IntegrableOn (fun x : ℝ => Real.exp (-x ^ 2)) (Ioi 0) := by
  have h := integrable_exp_neg_mul_sq (b := 1) one_pos
  simp only [neg_mul, one_mul] at h
  exact h.integrableOn

lemma erf_tendsto : Tendsto VoltaChallenge.erf atTop (𝓝 1) := by
  have h := intervalIntegral_tendsto_integral_Ioi (0:ℝ) gauss_integrableOn tendsto_id
  rw [gauss_Ioi] at h
  have h2 := h.const_mul kap
  rw [kap_mul_sqrt] at h2
  exact h2

lemma erf_mono {a b : ℝ} (hab : a ≤ b) : VoltaChallenge.erf a ≤ VoltaChallenge.erf b := by
  have h := erf_sub a b
  have h1 : 0 ≤ ∫ t in a..b, Real.exp (-t ^ 2) := integral_nonneg hab (fun t _ => (Real.exp_pos _).le)
  have := mul_nonneg kap_pos.le h1
  linarith

lemma erf_le_one (y : ℝ) : VoltaChallenge.erf y ≤ 1 :=
  ge_of_tendsto erf_tendsto (eventually_atTop.2 ⟨y, fun _ hY => erf_mono hY⟩)

lemma erf_zero : VoltaChallenge.erf 0 = 0 := by simp [erf_def]

lemma erf_nonneg {y : ℝ} (hy : 0 ≤ y) : 0 ≤ VoltaChallenge.erf y := by
  have := erf_mono hy; rwa [erf_zero] at this

lemma erf_neg (y : ℝ) : VoltaChallenge.erf (-y) = -VoltaChallenge.erf y := by
  rw [erf_def, erf_def]
  have h := intervalIntegral.integral_comp_neg (a := (0:ℝ)) (b := y) (fun t => Real.exp (-t ^ 2))
  simp only [neg_sq, neg_zero] at h
  rw [intervalIntegral.integral_symm (-y) 0, ← h]
  ring

lemma erf_lip (a b : ℝ) : |VoltaChallenge.erf a - VoltaChallenge.erf b| ≤ kap * |a - b| := by
  rw [erf_sub b a, abs_mul, abs_of_pos kap_pos]
  apply mul_le_mul_of_nonneg_left _ kap_pos.le
  have h := intervalIntegral.norm_integral_le_of_norm_le_const (a := b) (b := a) (C := 1)
    (f := fun t : ℝ => Real.exp (-t ^ 2)) (fun x _ => by
      rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
      exact Real.exp_le_one_iff.mpr (neg_nonpos.mpr (sq_nonneg x)))
  simpa using h

lemma one_sub_erf_le {y : ℝ} (hy : 0 < y) :
    1 - VoltaChallenge.erf y ≤ kap * Real.exp (-y ^ 2) / (2 * y) := by
  have hy0 : y ≠ 0 := hy.ne'
  have key : ∀ Y, y ≤ Y → VoltaChallenge.erf Y ≤ VoltaChallenge.erf y + kap * Real.exp (-y ^ 2) / (2 * y) := by
    intro Y hY
    have h1 := erf_sub y Y
    have hF : ∀ x ∈ uIcc y Y, HasDerivAt (fun s => -Real.exp (-s ^ 2) / (2 * y)) (x / y * Real.exp (-x ^ 2)) x := by
      intro x _
      have h0 : HasDerivAt (fun s : ℝ => -s ^ 2) (-(((2:ℕ):ℝ) * x ^ (2 - 1))) x :=
        (hasDerivAt_pow 2 x).neg
      have h1' : HasDerivAt (fun s : ℝ => Real.exp (-s ^ 2))
          (Real.exp (-x ^ 2) * (-(((2:ℕ):ℝ) * x ^ (2 - 1)))) x := h0.exp
      have h2' : HasDerivAt (fun s : ℝ => -Real.exp (-s ^ 2) / (2 * y))
          (-(Real.exp (-x ^ 2) * (-(((2:ℕ):ℝ) * x ^ (2 - 1)))) / (2 * y)) x := h1'.neg.div_const (2 * y)
      refine h2'.congr_deriv ?_
      rw [show (2:ℕ) - 1 = 1 from rfl, pow_one]; push_cast
      field_simp
    have hint : ∫ s in y..Y, s / y * Real.exp (-s ^ 2) = -Real.exp (-Y ^ 2) / (2 * y) - -Real.exp (-y ^ 2) / (2 * y) :=
      integral_eq_sub_of_hasDerivAt hF (by apply Continuous.intervalIntegrable; fun_prop)
    have hmono : ∫ s in y..Y, Real.exp (-s ^ 2) ≤ ∫ s in y..Y, s / y * Real.exp (-s ^ 2) := by
      apply integral_mono_on hY (gii y Y) (by apply Continuous.intervalIntegrable; fun_prop)
      intro s hs
      have : 1 ≤ s / y := by rw [le_div_iff₀ hy]; linarith [hs.1]
      have he := Real.exp_pos (-s ^ 2)
      nlinarith
    have hpos : 0 ≤ Real.exp (-Y ^ 2) / (2 * y) := by positivity
    have h3 : kap * ∫ s in y..Y, Real.exp (-s ^ 2) ≤ kap * (Real.exp (-y ^ 2) / (2 * y)) := by
      apply mul_le_mul_of_nonneg_left _ kap_pos.le
      rw [hint] at hmono
      have : -Real.exp (-Y ^ 2) / (2 * y) - -Real.exp (-y ^ 2) / (2 * y) = Real.exp (-y ^ 2) / (2 * y) - Real.exp (-Y ^ 2) / (2 * y) := by ring
      linarith
    rw [mul_div_assoc]; linarith
  have := le_of_tendsto erf_tendsto (eventually_atTop.2 ⟨y, key⟩)
  linarith

/-! ## Small arguments -/

lemma exp_taylor_bound (x : ℝ) (hx : |x| ≤ 1) : |Real.exp x - evalL x expL| ≤ 1 / 10^10 := by
  have h := Real.exp_bound hx (n := 14) (by norm_num)
  rw [sum_exp14] at h
  have hc : |x| ^ 14 ≤ 1 := pow_le_one₀ (abs_nonneg x) hx
  norm_num [Nat.factorial] at h
  linarith

lemma ebounds : 0.36787944116 < Real.exp (-1) ∧ Real.exp (-1) < 0.3678794412 :=
  ⟨Real.exp_neg_one_gt_d9, Real.exp_neg_one_lt_d9⟩

lemma erf_small_bound {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ T0) :
    |evalL t Al - VoltaChallenge.erf t| ≤ 2 / 10^4 := by
  have hJ : ∫ s in (0:ℝ)..t, evalL s Cl = evalL t Jl := by
    rw [integral_evalL]; simp [Jl, integL]
  have hpt : ∀ s ∈ Set.uIoc (0:ℝ) t, ‖Real.exp (1 - s^2) - evalL s Cl‖ ≤ 1 / 10^10 := by
    intro s hs
    rw [uIoc_of_le ht0] at hs
    have hC : evalL s Cl = evalL (1 - s^2) expL := by
      simp only [Cl, evalL_compL]; congr 1; simp; ring
    rw [hC, Real.norm_eq_abs]
    apply exp_taylor_bound
    rw [abs_le]; constructor <;> nlinarith [hs.1, hs.2]
  have hdiff := intervalIntegral.norm_integral_le_of_norm_le_const
    (f := fun s => Real.exp (1 - s^2) - evalL s Cl) hpt
  have i1 : IntervalIntegrable (fun s : ℝ => Real.exp (1 - s^2)) volume 0 t := by
    apply Continuous.intervalIntegrable; fun_prop
  have i2 : IntervalIntegrable (fun s : ℝ => evalL s Cl) volume 0 t :=
    (continuous_evalL Cl).intervalIntegrable _ _
  rw [intervalIntegral.integral_sub i1 i2, hJ, Real.norm_eq_abs, sub_zero,
    abs_of_nonneg ht0] at hdiff
  have herf : VoltaChallenge.erf t = kap * (Real.exp (-1) * ∫ s in (0:ℝ)..t, Real.exp (1 - s^2)) := by
    rw [erf_def]
    congr 1
    rw [← intervalIntegral.integral_const_mul]
    refine intervalIntegral.integral_congr (fun s _ => ?_)
    show Real.exp (-s ^ 2) = Real.exp (-1) * Real.exp (1 - s ^ 2)
    rw [← Real.exp_add]; ring_nf
  set I := ∫ s in (0:ℝ)..t, Real.exp (1 - s^2) with hI
  set J := evalL t Jl with hJdef
  have hD : evalL t Dl = evalL t Al - 4151075 / 10^7 * J := by
    simp only [Dl, evalL_addL, evalL_scaleL, hJdef]; push_cast; ring
  have htabs : |t| ≤ ((1.0029599666595458984375 : ℚ) : ℝ) := by
    rw [abs_of_nonneg ht0]; push_cast; linarith
  have hDb : |evalL t Dl| ≤ 11 / 100000 := by
    have := abs_evalL_le _ (by norm_num) t htabs Dl
    have h2 : ((bnd 1.0029599666595458984375 Dl : ℚ) : ℝ) ≤ ((11 / 100000 : ℚ) : ℝ) :=
      Rat.cast_le.mpr num_D
    have h3 : ((11 / 100000 : ℚ) : ℝ) = 11 / 100000 := by norm_num
    linarith
  have hJb : |J| ≤ 5 := by
    have := abs_evalL_le _ (by norm_num) t htabs Jl
    have h2 : ((bnd 1.0029599666595458984375 Jl : ℚ) : ℝ) ≤ ((5 : ℚ) : ℝ) := Rat.cast_le.mpr num_J
    have h3 : ((5 : ℚ) : ℝ) = 5 := by norm_num
    linarith
  obtain ⟨hk1, hk2⟩ := kap_bounds
  obtain ⟨he1, he2⟩ := ebounds
  have hμ1 : 1.1283788 * 0.36787944116 < kap * Real.exp (-1) :=
    mul_lt_mul'' hk1 he1 (by norm_num) (by norm_num)
  have hμ2 : kap * Real.exp (-1) < 1.1283795 * 0.3678794412 :=
    mul_lt_mul'' hk2 he2 (by positivity) (by positivity)
  have hμ0 : |4151075 / 10^7 - kap * Real.exp (-1)| ≤ 3 / 10^7 := by
    rw [abs_le]; constructor <;> norm_num at hμ1 hμ2 ⊢ <;> linarith
  have e1 : |(4151075 / 10^7 - kap * Real.exp (-1)) * J| ≤ 3 / 10^7 * 5 := by
    rw [abs_mul]; exact mul_le_mul hμ0 hJb (abs_nonneg _) (by norm_num)
  have e2 : |kap * Real.exp (-1) * (I - J)| ≤ 1 * (2 / 10^10) := by
    rw [abs_mul]
    apply mul_le_mul _ _ (abs_nonneg _) (by norm_num)
    · rw [abs_of_pos (by positivity)]; norm_num at hμ2; linarith
    · linarith
  have hsplit : evalL t Al - VoltaChallenge.erf t =
      evalL t Dl + (4151075 / 10^7 - kap * Real.exp (-1)) * J - kap * Real.exp (-1) * (I - J) := by
    rw [hD, herf]; ring
  rw [hsplit]
  calc |evalL t Dl + (4151075 / 10^7 - kap * Real.exp (-1)) * J - kap * Real.exp (-1) * (I - J)|
      ≤ |evalL t Dl| + |(4151075 / 10^7 - kap * Real.exp (-1)) * J| + |kap * Real.exp (-1) * (I - J)| := by
        have := abs_sub (evalL t Dl + (4151075 / 10^7 - kap * Real.exp (-1)) * J) (kap * Real.exp (-1) * (I - J))
        have := abs_add_le (evalL t Dl) ((4151075 / 10^7 - kap * Real.exp (-1)) * J)
        linarith
    _ ≤ 2 / 10^4 := by norm_num at e1 e2 ⊢; linarith

/-! ## The exponential branch -/

def Gf (t : ℝ) : ℝ := evalL t gl
def G1f (t : ℝ) : ℝ := evalL t G1l
def G2f (t : ℝ) : ℝ := evalL t G2l
def Hf (s : ℝ) : ℝ := kR * G1f s * Real.exp (s ^ 2 - kR * Gf s)

lemma hasDerivAt_Gf (s : ℝ) : HasDerivAt Gf (G1f s) s := hasDerivAt_evalL s gl
lemma hasDerivAt_G1f (s : ℝ) : HasDerivAt G1f (G2f s) s := hasDerivAt_evalL s G1l

lemma hasDerivAt_Hf (s : ℝ) :
    HasDerivAt Hf (kR * G2f s * Real.exp (s ^ 2 - kR * Gf s) +
      kR * G1f s * (Real.exp (s ^ 2 - kR * Gf s) * (2 * s - kR * G1f s))) s := by
  have hphi0 : HasDerivAt (fun x => x ^ 2 - kR * Gf x) (((2:ℕ):ℝ) * s ^ (2 - 1) - kR * G1f s) s :=
    (hasDerivAt_pow 2 s).sub ((hasDerivAt_Gf s).const_mul kR)
  have hphi : HasDerivAt (fun x => x ^ 2 - kR * Gf x) (2 * s - kR * G1f s) s :=
    hphi0.congr_deriv (by norm_num)
  exact ((hasDerivAt_G1f s).const_mul kR).mul hphi.exp

lemma P_upper (s : ℝ) (hs1 : 1 ≤ s) (hs2 : s ≤ 3) :
    G2f s + G1f s * (2 * s - kR * G1f s) - 1 / 5000 * G1f s ≤ 0 := by
  have e : G2f s + G1f s * (2 * s - kR * G1f s) - 1 / 5000 * G1f s = evalL s PpL := by
    simp only [PpL, G1f, G2f, evalL_addL, evalL_mulL, evalL_scaleL, evalL_cons, evalL_nil]
    push_cast; ring
  rw [e]
  rcases le_or_gt s 2 with h | h
  · exact cell_ub (3/2) (1/2) PpL (by norm_num) num_Pp1 s
      (by rw [abs_le]; push_cast; constructor <;> linarith)
  · rcases le_or_gt s (5/2) with h' | h'
    · exact cell_ub (9/4) (1/4) PpL (by norm_num) num_Pp2 s
        (by rw [abs_le]; push_cast; constructor <;> linarith)
    · exact cell_ub (11/4) (1/4) PpL (by norm_num) num_Pp3 s
        (by rw [abs_le]; push_cast; constructor <;> linarith)

lemma P_lower (s : ℝ) (hs1 : 1 ≤ s) (hs2 : s ≤ 3) :
    0 ≤ G2f s + G1f s * (2 * s - kR * G1f s) + 1 / 5000 * G1f s := by
  have e : G2f s + G1f s * (2 * s - kR * G1f s) + 1 / 5000 * G1f s = evalL s PmL := by
    simp only [PmL, G1f, G2f, evalL_addL, evalL_mulL, evalL_scaleL, evalL_cons, evalL_nil]
    push_cast; ring
  rw [e]
  rcases le_or_gt s 2 with h | h
  · exact cell_lb (3/2) (1/2) PmL (by norm_num) num_Pm1 s
      (by rw [abs_le]; push_cast; constructor <;> linarith)
  · rcases le_or_gt s (5/2) with h' | h'
    · exact cell_lb (9/4) (1/4) PmL (by norm_num) num_Pm2 s
        (by rw [abs_le]; push_cast; constructor <;> linarith)
    · exact cell_lb (11/4) (1/4) PmL (by norm_num) num_Pm3 s
        (by rw [abs_le]; push_cast; constructor <;> linarith)

lemma Hf_upper {s : ℝ} (hs1 : T0 ≤ s) (hs2 : s ≤ 3) :
    Hf s ≤ Hf T0 * Real.exp ((s - T0) / 5000) := by
  have hFd : ∀ x, HasDerivAt (fun x => Hf x * Real.exp (-x / 5000))
      ((kR * G2f x * Real.exp (x ^ 2 - kR * Gf x) +
      kR * G1f x * (Real.exp (x ^ 2 - kR * Gf x) * (2 * x - kR * G1f x))) * Real.exp (-x / 5000) +
        Hf x * (Real.exp (-x / 5000) * (-1 / 5000))) x := by
    intro x
    have h2 : HasDerivAt (fun x : ℝ => -x / 5000) (-1 / 5000) x :=
      (hasDerivAt_id' x).neg.div_const 5000
    exact (hasDerivAt_Hf x).mul h2.exp
  have hanti : AntitoneOn (fun x => Hf x * Real.exp (-x / 5000)) (Icc T0 3) := by
    apply antitoneOn_of_deriv_nonpos (convex_Icc _ _)
    · intro x _; exact (hFd x).continuousAt.continuousWithinAt
    · intro x _; exact (hFd x).differentiableAt.differentiableWithinAt
    · intro x hx
      rw [interior_Icc] at hx
      rw [(hFd x).deriv]
      have hP := P_upper x (by linarith [hx.1]) hx.2.le
      have hpos : 0 < kR * Real.exp (x ^ 2 - kR * Gf x) * Real.exp (-x / 5000) := by positivity
      have : (kR * G2f x * Real.exp (x ^ 2 - kR * Gf x) +
          kR * G1f x * (Real.exp (x ^ 2 - kR * Gf x) * (2 * x - kR * G1f x))) * Real.exp (-x / 5000) +
          Hf x * (Real.exp (-x / 5000) * (-1 / 5000)) =
          (kR * Real.exp (x ^ 2 - kR * Gf x) * Real.exp (-x / 5000)) *
          (G2f x + G1f x * (2 * x - kR * G1f x) - 1 / 5000 * G1f x) := by
        unfold Hf; ring
      rw [this]
      exact mul_nonpos_of_nonneg_of_nonpos hpos.le hP
  have hT : T0 ∈ Icc T0 3 := ⟨le_refl _, by norm_num⟩
  have h := hanti hT ⟨hs1, hs2⟩ hs1
  simp only at h
  have e : Real.exp ((s - T0) / 5000) = Real.exp (-T0 / 5000) / Real.exp (-s / 5000) := by
    rw [← Real.exp_sub]; congr 1; ring
  rw [e, ← mul_div_assoc, le_div_iff₀ (Real.exp_pos _)]
  exact h

lemma Hf_lower {s : ℝ} (hs1 : T0 ≤ s) (hs2 : s ≤ 3) :
    Hf T0 * Real.exp (-((s - T0) / 5000)) ≤ Hf s := by
  have hFd : ∀ x, HasDerivAt (fun x => Hf x * Real.exp (x / 5000))
      ((kR * G2f x * Real.exp (x ^ 2 - kR * Gf x) +
      kR * G1f x * (Real.exp (x ^ 2 - kR * Gf x) * (2 * x - kR * G1f x))) * Real.exp (x / 5000) +
        Hf x * (Real.exp (x / 5000) * (1 / 5000))) x := by
    intro x
    have h2 : HasDerivAt (fun x : ℝ => x / 5000) (1 / 5000) x :=
      (hasDerivAt_id' x).div_const 5000
    exact (hasDerivAt_Hf x).mul h2.exp
  have hmono : MonotoneOn (fun x => Hf x * Real.exp (x / 5000)) (Icc T0 3) := by
    apply monotoneOn_of_deriv_nonneg (convex_Icc _ _)
    · intro x _; exact (hFd x).continuousAt.continuousWithinAt
    · intro x _; exact (hFd x).differentiableAt.differentiableWithinAt
    · intro x hx
      rw [interior_Icc] at hx
      rw [(hFd x).deriv]
      have hP := P_lower x (by linarith [hx.1]) hx.2.le
      have hpos : 0 < kR * Real.exp (x ^ 2 - kR * Gf x) * Real.exp (x / 5000) := by positivity
      have : (kR * G2f x * Real.exp (x ^ 2 - kR * Gf x) +
          kR * G1f x * (Real.exp (x ^ 2 - kR * Gf x) * (2 * x - kR * G1f x))) * Real.exp (x / 5000) +
          Hf x * (Real.exp (x / 5000) * (1 / 5000)) =
          (kR * Real.exp (x ^ 2 - kR * Gf x) * Real.exp (x / 5000)) *
          (G2f x + G1f x * (2 * x - kR * G1f x) + 1 / 5000 * G1f x) := by
        unfold Hf; ring
      rw [this]
      exact mul_nonneg hpos.le hP
  have hT : T0 ∈ Icc T0 3 := ⟨le_refl _, by norm_num⟩
  have h := hmono hT ⟨hs1, hs2⟩ hs1
  simp only at h
  have e : Real.exp (-((s - T0) / 5000)) = Real.exp (T0 / 5000) / Real.exp (s / 5000) := by
    rw [← Real.exp_sub]; congr 1; ring
  rw [e, ← mul_div_assoc, div_le_iff₀ (Real.exp_pos _)]
  exact h

lemma mul3_le {a b c a' b' c' : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c)
    (h1 : a ≤ a') (h2 : b ≤ b') (h3 : c ≤ c') : a * (b * c) ≤ a' * (b' * c') :=
  mul_le_mul h1 (mul_le_mul h2 h3 hc (hb.trans h2)) (mul_nonneg hb hc) (ha.trans h1)

lemma G1T0 : 3.8144276 ≤ G1f T0 ∧ G1f T0 ≤ 3.8144277 := by
  constructor <;> norm_num [G1f, G1l, gl, derivL, addL]

lemma phiT0 : -0.8514955 ≤ T0 ^ 2 - kR * Gf T0 ∧ T0 ^ 2 - kR * Gf T0 ≤ -0.8514954 := by
  constructor <;> norm_num [Gf, gl]

lemma HT0_bounds : 1.128379 ≤ Hf T0 ∧ Hf T0 ≤ 1.1283794 := by
  obtain ⟨g1, g2⟩ := G1T0
  obtain ⟨p1, p2⟩ := phiT0
  obtain ⟨e1, e2⟩ := ebounds
  have hx1 := exp_taylor_bound 0.1485046 (by rw [abs_le]; norm_num)
  have hx2 := exp_taylor_bound 0.1485045 (by rw [abs_le]; norm_num)
  rw [abs_le] at hx1 hx2
  have hH : Hf T0 = kR * G1f T0 * (Real.exp (-1) * Real.exp (T0 ^ 2 - kR * Gf T0 + 1)) := by
    unfold Hf; rw [← Real.exp_add]; ring_nf
  have m1 : Real.exp (T0 ^ 2 - kR * Gf T0 + 1) ≤ Real.exp 0.1485046 := Real.exp_le_exp.mpr (by linarith)
  have m2 : Real.exp 0.1485045 ≤ Real.exp (T0 ^ 2 - kR * Gf T0 + 1) := Real.exp_le_exp.mpr (by linarith)
  have v2 : 0 ≤ evalL 0.1485045 expL - 1 / 10^10 := by norm_num [expL]
  rw [hH]
  constructor
  · calc (1.128379 : ℝ) ≤ (kR * 3.8144276) * (0.36787944116 * (evalL 0.1485045 expL - 1 / 10^10)) := by
          norm_num [expL]
      _ ≤ _ := mul3_le (by norm_num) (by norm_num) v2 (mul_le_mul_of_nonneg_left g1 (by norm_num))
          e1.le (by linarith)
  · calc kR * G1f T0 * (Real.exp (-1) * Real.exp (T0 ^ 2 - kR * Gf T0 + 1))
          ≤ (kR * 3.8144277) * (0.3678794412 * (evalL 0.1485046 expL + 1 / 10^10)) :=
          mul3_le (by linarith) (Real.exp_pos _).le (Real.exp_pos _).le
            (mul_le_mul_of_nonneg_left g2 (by norm_num)) e2.le (by linarith)
      _ ≤ 1.1283794 := by norm_num [expL]

lemma H_close {s : ℝ} (hs1 : T0 ≤ s) (hs2 : s ≤ 3) : |Hf s - kap| ≤ 46 / 100000 := by
  obtain ⟨h1, h2⟩ := HT0_bounds
  obtain ⟨k1, k2⟩ := kap_bounds
  have u := Hf_upper hs1 hs2
  have l := Hf_lower hs1 hs2
  have hx1 : (s - T0) / 5000 ≤ 4 / 10000 := by
    rw [div_le_iff₀ (by norm_num)]; norm_num at hs2 ⊢; linarith
  have eu : Real.exp ((s - T0) / 5000) ≤ 1 / (1 - 4 / 10000) := by
    calc Real.exp ((s - T0) / 5000) ≤ Real.exp (4 / 10000) := Real.exp_le_exp.mpr hx1
      _ ≤ 1 / (1 - 4 / 10000) := (Real.exp_bound_div_one_sub_of_interval' (by norm_num) (by norm_num)).le
  have el : 1 - 4 / 10000 ≤ Real.exp (-((s - T0) / 5000)) := by
    have := Real.add_one_le_exp (-((s - T0) / 5000)); linarith
  have hHpos : 0 ≤ Hf T0 := by linarith
  have u2 : Hf s ≤ 1.1283794 * (1 / (1 - 4 / 10000)) := by
    calc Hf s ≤ Hf T0 * Real.exp ((s - T0) / 5000) := u
      _ ≤ 1.1283794 * (1 / (1 - 4 / 10000)) :=
        mul_le_mul h2 eu (Real.exp_pos _).le (by norm_num)
  have l2 : 1.128379 * (1 - 4 / 10000) ≤ Hf s := by
    calc (1.128379 : ℝ) * (1 - 4 / 10000) ≤ Hf T0 * Real.exp (-((s - T0) / 5000)) :=
        mul_le_mul h1 el (by norm_num) hHpos
      _ ≤ Hf s := l
  rw [abs_le]; constructor <;> norm_num at u2 l2 k1 k2 ⊢ <;> linarith

lemma exp_neg_nat (n : ℕ) : Real.exp (-(n : ℝ)) ≤ 0.3678794412 ^ n := by
  have : Real.exp (-(n : ℝ)) = Real.exp (-1) ^ n := by
    rw [← Real.exp_nat_mul]; ring_nf
  rw [this]
  exact pow_le_pow_left₀ (Real.exp_pos _).le ebounds.2.le n

lemma exp_neg9 : Real.exp (-9) ≤ 0.3678794412 ^ 9 := by
  have := exp_neg_nat 9; norm_num at this ⊢; exact this

lemma kG3 : 10 ≤ Gf 3 * kR := by norm_num [Gf, gl]

lemma E3_bound : |(1 - Real.exp (-Gf 3 * kR)) - VoltaChallenge.erf 3| ≤ 46 / 1000000 := by
  have h1 := one_sub_erf_le (y := 3) (by norm_num)
  have h2 := erf_le_one 3
  have h3 : Real.exp (-(3:ℝ) ^ 2) ≤ 0.3678794412 ^ 9 := by
    have : (-(3:ℝ) ^ 2) = -9 := by norm_num
    rw [this]; exact exp_neg9
  have h4 : Real.exp (-Gf 3 * kR) ≤ 0.3678794412 ^ 10 := by
    have := exp_neg_nat 10
    calc Real.exp (-Gf 3 * kR) ≤ Real.exp (-((10:ℕ):ℝ)) := Real.exp_le_exp.mpr (by push_cast; linarith [kG3])
      _ ≤ _ := this
  have h5 := Real.exp_pos (-Gf 3 * kR)
  obtain ⟨k1, k2⟩ := kap_bounds
  have h6 : kap * Real.exp (-(3:ℝ) ^ 2) / (2 * 3) ≤ 1.1283795 * 0.3678794412 ^ 9 / (2 * 3) :=
    div_le_div_of_nonneg_right (mul_le_mul k2.le h3 (Real.exp_pos _).le (by norm_num)) (by norm_num)
  have h7 : (1.1283795 : ℝ) * 0.3678794412 ^ 9 / (2 * 3) ≤ 24 / 1000000 := by norm_num
  have h8 : (0.3678794412 : ℝ) ^ 10 ≤ 46 / 1000000 := by norm_num
  set a := 1 - VoltaChallenge.erf 3 with ha
  set b := Real.exp (-Gf 3 * kR) with hb
  have e : (1 - b) - VoltaChallenge.erf 3 = a - b := by rw [ha]; ring
  rw [e, abs_le]
  constructor <;> linarith

lemma mid_bound {t : ℝ} (ht1 : T0 ≤ t) (ht2 : t ≤ 3) :
    |(1 - Real.exp (-Gf t * kR)) - VoltaChallenge.erf t| ≤ 385 / 1000000 := by
  have hcont1 : Continuous (fun s => Real.exp (-Gf s * kR) * (-G1f s * kR)) := by
    have a1 := continuous_evalL gl
    have a2 := continuous_evalL G1l
    unfold Gf G1f; fun_prop
  have hd : ∀ x, HasDerivAt (fun s => Real.exp (-Gf s * kR)) (Real.exp (-Gf x * kR) * (-G1f x * kR)) x :=
    fun x => (((hasDerivAt_Gf x).neg).mul_const kR).exp
  have hFTC : ∫ s in t..3, Real.exp (-Gf s * kR) * (-G1f s * kR) =
      Real.exp (-Gf 3 * kR) - Real.exp (-Gf t * kR) :=
    integral_eq_sub_of_hasDerivAt (f := fun s => Real.exp (-Gf s * kR)) (fun x _ => hd x)
      (hcont1.intervalIntegrable _ _)
  have herf := erf_sub t 3
  have i1 : IntervalIntegrable (fun s => -(Real.exp (-Gf s * kR) * (-G1f s * kR))) volume t 3 :=
    hcont1.neg.intervalIntegrable _ _
  have i2 : IntervalIntegrable (fun s : ℝ => kap * Real.exp (-s ^ 2)) volume t 3 :=
    (continuous_const.mul gcont).intervalIntegrable _ _
  have hint : ∫ s in t..3, Real.exp (-s ^ 2) * (Hf s - kap) =
      -(∫ s in t..3, Real.exp (-Gf s * kR) * (-G1f s * kR)) - kap * ∫ s in t..3, Real.exp (-s ^ 2) := by
    have hc : ∫ s in t..3, Real.exp (-s ^ 2) * (Hf s - kap) =
        ∫ s in t..3, (-(Real.exp (-Gf s * kR) * (-G1f s * kR)) - kap * Real.exp (-s ^ 2)) := by
      refine intervalIntegral.integral_congr (fun s _ => ?_)
      show Real.exp (-s ^ 2) * (Hf s - kap) = -(Real.exp (-Gf s * kR) * (-G1f s * kR)) - kap * Real.exp (-s ^ 2)
      have : Real.exp (-s ^ 2) * Real.exp (s ^ 2 - kR * Gf s) = Real.exp (-Gf s * kR) := by
        rw [← Real.exp_add]; ring_nf
      unfold Hf
      linear_combination (kR * G1f s) * this
    rw [hc, intervalIntegral.integral_sub i1 i2, intervalIntegral.integral_neg,
      intervalIntegral.integral_const_mul]
  have hbound : ∀ x ∈ Set.uIoc t 3, ‖Real.exp (-x ^ 2) * (Hf x - kap)‖ ≤ 0.3678794412 * (46 / 100000) := by
    intro x hx
    rw [uIoc_of_le ht2] at hx
    rw [Real.norm_eq_abs, abs_mul, abs_of_pos (Real.exp_pos _)]
    have hc := H_close (s := x) (by linarith [hx.1]) hx.2
    have he : Real.exp (-x ^ 2) ≤ 0.3678794412 := by
      calc Real.exp (-x ^ 2) ≤ Real.exp (-1) := Real.exp_le_exp.mpr (by nlinarith [hx.1])
        _ ≤ _ := ebounds.2.le
    exact mul_le_mul he hc (abs_nonneg _) (by norm_num)
  have hI := intervalIntegral.norm_integral_le_of_norm_le_const
    (f := fun x => Real.exp (-x ^ 2) * (Hf x - kap)) hbound
  rw [Real.norm_eq_abs, abs_of_nonneg (by linarith : (0:ℝ) ≤ 3 - t)] at hI
  have hE3 := E3_bound
  have key : (1 - Real.exp (-Gf t * kR)) - VoltaChallenge.erf t =
      ((1 - Real.exp (-Gf 3 * kR)) - VoltaChallenge.erf 3) - ∫ s in t..3, Real.exp (-s ^ 2) * (Hf s - kap) := by
    rw [hint, hFTC]; linear_combination herf
  rw [key]
  have h3t : 3 - t ≤ 2 := by norm_num at ht1 ⊢; linarith
  have hIb : |∫ s in t..3, Real.exp (-s ^ 2) * (Hf s - kap)| ≤ 0.3678794412 * (46 / 100000) * 2 :=
    hI.trans (mul_le_mul_of_nonneg_left h3t (by norm_num))
  calc |((1 - Real.exp (-Gf 3 * kR)) - VoltaChallenge.erf 3) - ∫ s in t..3, Real.exp (-s ^ 2) * (Hf s - kap)|
      ≤ |((1 - Real.exp (-Gf 3 * kR)) - VoltaChallenge.erf 3)| + |∫ s in t..3, Real.exp (-s ^ 2) * (Hf s - kap)| :=
        abs_sub _ _
    _ ≤ 385 / 1000000 := by norm_num at hIb hE3 ⊢; linarith

/-! ## Tails -/

lemma Gf_ge {t : ℝ} (ht : 3 ≤ t) : 4.5 * t ≤ Gf t := by
  obtain ⟨u, hu, rfl⟩ : ∃ u, 0 ≤ u ∧ t = u + 3 := ⟨t - 3, by linarith, by ring⟩
  have hG : Gf (u + 3) = (u + 3) * (1 + 5270561/2^23 + (u+3) * (7686591/2^23 + (u+3) * (5143683/2^25 +
      (u+3) * (-4604081/2^27 + (u+3) * (11305995/2^31 + (u+3) * (-16081081/2^35 + (u+3) * (2257551/2^37))))))) := by
    simp only [Gf, gl, evalL_cons, evalL_nil]; push_cast; ring
  have hp : (4.5 : ℝ) ≤ 1 + 5270561/2^23 + (u+3) * (7686591/2^23 + (u+3) * (5143683/2^25 +
      (u+3) * (-4604081/2^27 + (u+3) * (11305995/2^31 + (u+3) * (-16081081/2^35 + (u+3) * (2257551/2^37)))))) := by
    have hA : 0 ≤ u^2 * (u - 10)^2 := by positivity
    have hB : 0 ≤ u^2 := by positivity
    have hC : 0 ≤ u^4 * (u - 21/4)^2 := by positivity
    have hF : 0 ≤ u^5 := pow_nonneg hu 5
    have hG3 : 0 ≤ u^3 := pow_nonneg hu 3
    have hH : 0 ≤ u^4 := pow_nonneg hu 4
    rcases le_or_gt u 10 with h10 | h10
    · have hu3 : u^3 ≤ 1000 := by
        have := pow_le_pow_left₀ hu h10 3; norm_num at this; linarith
      have hD : 0 ≤ u * (1000 - u^3) := mul_nonneg hu (by linarith)
      nlinarith [hA, hB, hC, hD, hu, hF, hG3, hH]
    · have hK : 0 ≤ u^4 * (u - 10) * (u - 1/2) :=
        mul_nonneg (mul_nonneg hH (by linarith)) (by linarith)
      nlinarith [hA, hB, hu, hF, hG3, hH, hK]
  rw [hG]
  have := mul_le_mul_of_nonneg_left hp (by linarith : (0:ℝ) ≤ u + 3)
  linarith

lemma tail_exp {t : ℝ} (ht : 3 ≤ t) : t * Real.exp (-Gf t * kR) ≤ 3 * 0.3678794412 ^ 9 := by
  have hG := Gf_ge ht
  have h1 : Real.exp (-Gf t * kR) ≤ Real.exp (-3 * t) := Real.exp_le_exp.mpr (by linarith)
  have h2 : Real.exp (-3 * t) * Real.exp (3 * (t - 3)) = Real.exp (-9) := by
    rw [← Real.exp_add]; ring_nf
  have h3 : 1 + 3 * (t - 3) ≤ Real.exp (3 * (t - 3)) := by
    have := Real.add_one_le_exp (3 * (t - 3)); linarith
  have h5 := Real.exp_pos (-3 * t)
  calc t * Real.exp (-Gf t * kR) ≤ t * Real.exp (-3 * t) := mul_le_mul_of_nonneg_left h1 (by linarith)
    _ ≤ 3 * ((1 + 3 * (t - 3)) * Real.exp (-3 * t)) := by
        nlinarith [mul_nonneg (by linarith : (0:ℝ) ≤ 8 * t - 24) h5.le]
    _ ≤ 3 * (Real.exp (3 * (t - 3)) * Real.exp (-3 * t)) := by
        nlinarith [mul_le_mul_of_nonneg_right h3 h5.le]
    _ = 3 * Real.exp (-9) := by rw [mul_comm (Real.exp (3 * (t - 3))), h2]
    _ ≤ 3 * 0.3678794412 ^ 9 := by linarith [exp_neg9]

lemma big_tail {S : ℝ} (hS : 0 ≤ S) (h : 3 < S * cA) :
    0.5 * S * |(1 - Real.exp (-Gf (S * cA) * kR)) - VoltaChallenge.erf (S * cB)| ≤ 0.001 := by
  have hSpos : 0 < S := by norm_num at h; linarith
  have hy : 3 ≤ S * cB := by norm_num at h ⊢; linarith
  have hy0 : 0 < S * cB := by linarith
  have ha := one_sub_erf_le hy0
  have ha0 : 0 ≤ 1 - VoltaChallenge.erf (S * cB) := by linarith [erf_le_one (S * cB)]
  have hb := tail_exp (t := S * cA) h.le
  have hb0 := Real.exp_pos (-Gf (S * cA) * kR)
  obtain ⟨k1, k2⟩ := kap_bounds
  have e2 : Real.exp (-(S * cB) ^ 2) ≤ 0.3678794412 ^ 9 :=
    (Real.exp_le_exp.mpr (by nlinarith)).trans exp_neg9
  have e1 : 0.5 * S * (kap * Real.exp (-(S * cB) ^ 2) / (2 * (S * cB))) =
      kap * Real.exp (-(S * cB) ^ 2) / (4 * cB) := by
    field_simp; ring
  have e3 : kap * Real.exp (-(S * cB) ^ 2) / (4 * cB) ≤ 1.1283795 * 0.3678794412 ^ 9 / (4 * cB) :=
    div_le_div_of_nonneg_right (mul_le_mul k2.le e2 (Real.exp_pos _).le (by norm_num)) (by norm_num)
  have e4 : 0.5 * S * Real.exp (-Gf (S * cA) * kR) =
      0.5 * (S * cA * Real.exp (-Gf (S * cA) * kR)) / cA := by
    field_simp
  have e5 : 0.5 * (S * cA * Real.exp (-Gf (S * cA) * kR)) / cA ≤ 0.5 * (3 * 0.3678794412 ^ 9) / cA :=
    div_le_div_of_nonneg_right (by linarith) (by norm_num)
  have e6 : (1.1283795 : ℝ) * 0.3678794412 ^ 9 / (4 * cB) + 0.5 * (3 * 0.3678794412 ^ 9) / cA ≤ 0.001 := by
    norm_num
  have habs : |(1 - Real.exp (-Gf (S * cA) * kR)) - VoltaChallenge.erf (S * cB)| ≤
      (1 - VoltaChallenge.erf (S * cB)) + Real.exp (-Gf (S * cA) * kR) := by
    rw [abs_le]; constructor <;> linarith
  have h05 : 0 ≤ 0.5 * S := by linarith
  calc 0.5 * S * |(1 - Real.exp (-Gf (S * cA) * kR)) - VoltaChallenge.erf (S * cB)|
      ≤ 0.5 * S * ((1 - VoltaChallenge.erf (S * cB)) + Real.exp (-Gf (S * cA) * kR)) :=
        mul_le_mul_of_nonneg_left habs h05
    _ = 0.5 * S * (1 - VoltaChallenge.erf (S * cB)) + 0.5 * S * Real.exp (-Gf (S * cA) * kR) := by ring
    _ ≤ 0.5 * S * (kap * Real.exp (-(S * cB) ^ 2) / (2 * (S * cB))) +
        0.5 * (S * cA * Real.exp (-Gf (S * cA) * kR)) / cA := by
        rw [e4]; linarith [mul_le_mul_of_nonneg_left ha h05]
    _ ≤ 0.001 := by rw [e1]; linarith

lemma big_mid {S : ℝ} (hS : 0 ≤ S) (h1 : T0 ≤ S * cA) (h2 : S * cA ≤ 3) :
    0.5 * S * |(1 - Real.exp (-Gf (S * cA) * kR)) - VoltaChallenge.erf (S * cB)| ≤ 0.001 := by
  have hm := mid_bound h1 h2
  have hl := erf_lip (S * cA) (S * cB)
  have hS2 : S ≤ 4.2427 := by norm_num at h2 ⊢; linarith
  have hd : |S * cA - S * cB| ≤ 4.2427 * (2 / 10^8) := by
    rw [show S * cA - S * cB = -(S * (cB - cA)) by ring, abs_neg,
      abs_of_nonneg (mul_nonneg hS (by norm_num))]
    exact mul_le_mul hS2 (by norm_num) (by norm_num) (by norm_num)
  obtain ⟨k1, k2⟩ := kap_bounds
  have hl2 : |VoltaChallenge.erf (S * cA) - VoltaChallenge.erf (S * cB)| ≤ 1.1283795 * (4.2427 * (2 / 10^8)) :=
    hl.trans (mul_le_mul k2.le hd (abs_nonneg _) (by norm_num))
  have hsum : |(1 - Real.exp (-Gf (S * cA) * kR)) - VoltaChallenge.erf (S * cB)| ≤
      385 / 1000000 + 1.1283795 * (4.2427 * (2 / 10^8)) :=
    (abs_sub_le _ (VoltaChallenge.erf (S * cA)) _).trans (add_le_add hm hl2)
  calc 0.5 * S * |(1 - Real.exp (-Gf (S * cA) * kR)) - VoltaChallenge.erf (S * cB)|
      ≤ 0.5 * 4.2427 * (385 / 1000000 + 1.1283795 * (4.2427 * (2 / 10^8))) :=
        mul_le_mul (by linarith) hsum (abs_nonneg _) (by norm_num)
    _ ≤ 0.001 := by norm_num

lemma small_pos {S : ℝ} (hS : 0 ≤ S) (h : S * cA < T0) :
    0.5 * S * |evalL (S * cA) Al - VoltaChallenge.erf (S * cB)| ≤ 0.001 := by
  have h0 : 0 ≤ S * cA := mul_nonneg hS (by norm_num)
  have hb := erf_small_bound h0 h.le
  have hl := erf_lip (S * cA) (S * cB)
  have hS2 : S ≤ 1.42 := by norm_num at h ⊢; linarith
  have hd : |S * cA - S * cB| ≤ 1.42 * (2 / 10^8) := by
    rw [show S * cA - S * cB = -(S * (cB - cA)) by ring, abs_neg,
      abs_of_nonneg (mul_nonneg hS (by norm_num))]
    exact mul_le_mul hS2 (by norm_num) (by norm_num) (by norm_num)
  obtain ⟨k1, k2⟩ := kap_bounds
  have hl2 : |VoltaChallenge.erf (S * cA) - VoltaChallenge.erf (S * cB)| ≤ 1.1283795 * (1.42 * (2 / 10^8)) :=
    hl.trans (mul_le_mul k2.le hd (abs_nonneg _) (by norm_num))
  have hsum : |evalL (S * cA) Al - VoltaChallenge.erf (S * cB)| ≤
      2 / 10^4 + 1.1283795 * (1.42 * (2 / 10^8)) :=
    (abs_sub_le _ (VoltaChallenge.erf (S * cA)) _).trans (add_le_add hb hl2)
  calc 0.5 * S * |evalL (S * cA) Al - VoltaChallenge.erf (S * cB)|
      ≤ 0.5 * 1.42 * (2 / 10^4 + 1.1283795 * (1.42 * (2 / 10^8))) :=
        mul_le_mul (by linarith) hsum (abs_nonneg _) (by norm_num)
    _ ≤ 0.001 := by norm_num

lemma Al_odd (x : ℝ) : evalL (-x) Al = -evalL x Al := by
  simp only [Al, evalL_cons, evalL_nil]; push_cast; ring

lemma small_case (S : ℝ) (h : |S * cA| < T0) :
    |S * 0.5 * (evalL (S * cA) Al + 1) - 0.5 * S * (1 + VoltaChallenge.erf (S * cB))| ≤ 0.001 := by
  have e : S * 0.5 * (evalL (S * cA) Al + 1) - 0.5 * S * (1 + VoltaChallenge.erf (S * cB)) =
      0.5 * S * (evalL (S * cA) Al - VoltaChallenge.erf (S * cB)) := by ring
  rw [e]
  rcases le_or_gt 0 S with hS | hS
  · rw [abs_mul, abs_of_nonneg (by linarith : (0:ℝ) ≤ 0.5 * S)]
    exact small_pos hS (by rwa [abs_of_nonneg (mul_nonneg hS (by norm_num))] at h)
  · have hS' : 0 ≤ -S := by linarith
    have hodd : evalL (S * cA) Al = -evalL (-S * cA) Al := by
      have := Al_odd (-S * cA); rw [show -(-S * cA) = S * cA by ring] at this; exact this
    have herf : VoltaChallenge.erf (S * cB) = -VoltaChallenge.erf (-S * cB) := by
      have := erf_neg (-S * cB); rw [show -(-S * cB) = S * cB by ring] at this; exact this
    have e2 : 0.5 * S * (evalL (S * cA) Al - VoltaChallenge.erf (S * cB)) =
        0.5 * (-S) * (evalL (-S * cA) Al - VoltaChallenge.erf (-S * cB)) := by
      rw [hodd, herf]; ring
    rw [e2, abs_mul, abs_of_nonneg (by linarith : (0:ℝ) ≤ 0.5 * (-S))]
    apply small_pos hS'
    rw [abs_lt] at h
    linarith [h.1]

lemma big_pos {S : ℝ} (hS : 0 ≤ S) (h : T0 ≤ S * cA) :
    0.5 * S * |(1 - Real.exp (-Gf (S * cA) * kR)) - VoltaChallenge.erf (S * cB)| ≤ 0.001 := by
  rcases le_or_gt (S * cA) 3 with h3 | h3
  · exact big_mid hS h h3
  · exact big_tail hS h3

lemma big_case (S : ℝ) (h : |S * cA| ≥ T0) :
    |S * 0.5 * ((if S * cA < 0 then -|1 - Real.exp (-Gf |S * cA| * kR)| else
      1 - Real.exp (-Gf |S * cA| * kR)) + 1) - 0.5 * S * (1 + VoltaChallenge.erf (S * cB))| ≤ 0.001 := by
  rcases le_or_gt 0 S with hS | hS
  · have hpos : 0 ≤ S * cA := mul_nonneg hS (by norm_num)
    rw [if_neg (not_lt.mpr hpos), abs_of_nonneg hpos]
    rw [abs_of_nonneg hpos] at h
    have e : S * 0.5 * ((1 - Real.exp (-Gf (S * cA) * kR)) + 1) - 0.5 * S * (1 + VoltaChallenge.erf (S * cB)) =
        0.5 * S * ((1 - Real.exp (-Gf (S * cA) * kR)) - VoltaChallenge.erf (S * cB)) := by ring
    rw [e, abs_mul, abs_of_nonneg (by linarith : (0:ℝ) ≤ 0.5 * S)]
    exact big_pos hS h
  · have hneg : S * cA < 0 := mul_neg_of_neg_of_pos hS (by norm_num)
    have hS' : 0 ≤ -S := by linarith
    have habs : |S * cA| = -S * cA := by rw [abs_of_neg hneg]; ring
    rw [if_pos hneg, habs]
    rw [habs] at h
    have herf : VoltaChallenge.erf (S * cB) = -VoltaChallenge.erf (-S * cB) := by
      have := erf_neg (-S * cB); rw [show -(-S * cB) = S * cB by ring] at this; exact this
    set x6 := 1 - Real.exp (-Gf (-S * cA) * kR) with hx6
    have e : S * 0.5 * (-|x6| + 1) - 0.5 * S * (1 + VoltaChallenge.erf (S * cB)) =
        0.5 * (-S) * (|x6| - VoltaChallenge.erf (-S * cB)) := by rw [herf]; ring
    rw [e, abs_mul, abs_of_nonneg (by linarith : (0:ℝ) ≤ 0.5 * (-S))]
    have hE0 : 0 ≤ VoltaChallenge.erf (-S * cB) := erf_nonneg (mul_nonneg hS' (by norm_num))
    have h1 : abs (|x6| - VoltaChallenge.erf (-S * cB)) ≤ |x6 - VoltaChallenge.erf (-S * cB)| := by
      have := abs_abs_sub_abs_le_abs_sub x6 (VoltaChallenge.erf (-S * cB))
      rwa [abs_of_nonneg hE0] at this
    calc 0.5 * (-S) * abs (|x6| - VoltaChallenge.erf (-S * cB))
        ≤ 0.5 * (-S) * |x6 - VoltaChallenge.erf (-S * cB)| :=
          mul_le_mul_of_nonneg_left h1 (by linarith)
      _ ≤ 0.001 := big_pos hS' h

theorem key (S T : ℝ) (hST : T = S) :
    let x0 := S
    let x1 := x0 * (11863283 / 2 ^ 24 : ℝ)
    let x2 := |x1|
    let x3 := if x2 ≥ (1.0029599666595458984375 : ℝ) then x2 else x1 * x1
    let x4 := if x2 ≥ (1.0029599666595458984375 : ℝ) then -x3 else x1
    let x5 := ((((((((((((((if x2 ≥ (1.0029599666595458984375 : ℝ) then (2257551 / 2 ^ 37 : ℝ) else (5829813 / 2 ^ 36 : ℝ)) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (-16081081 / 2 ^ 35 : ℝ) else (-440937 / 2 ^ 29 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (11305995 / 2 ^ 31 : ℝ) else (5597941 / 2 ^ 30 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (-4604081 / 2 ^ 27 : ℝ) else (-14425063 / 2 ^ 29 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (5143683 / 2 ^ 25 : ℝ) else (15145135 / 2 ^ 27 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (7686591 / 2 ^ 23 : ℝ) else (-3155179 / 2 ^ 23 : ℝ))) * x3) + (if x2 ≥ (1.0029599666595458984375 : ℝ) then (5270561 / 2 ^ 23 : ℝ) else (8615379 / 2 ^ 26 : ℝ))) * x4) + x4
    let x6 := (1 : ℝ) - Real.exp (x5 * (8388608 / 12102203 : ℝ))
    let x7 := T
    |((x0 * (0.5 : ℝ)) * ((if x2 < (1.0029599666595458984375 : ℝ) then x5 else if x1 < (0 : ℝ) then -(|x6|) else x6) + (1 : ℝ))) - (((0.5 : ℝ) * x7) * ((1 : ℝ) + VoltaChallenge.erf (x7 * (6369051672525773 / 2 ^ 53 : ℝ))))| ≤ (0.001 : ℝ) := by
  intro x0 x1 x2 x3 x4 x5 x6 x7
  have h7 : x7 = x0 := hST
  rw [h7]
  by_cases hs : x2 < (1.0029599666595458984375 : ℝ)
  · have e3 : ¬ (x2 ≥ (1.0029599666595458984375 : ℝ)) := not_le.mpr hs
    have h5 : x5 = evalL x1 Al := by
      simp only [x5, x4, x3, if_neg e3]
      simp only [Al, evalL_cons, evalL_nil]; push_cast; ring
    rw [if_pos hs, h5]
    exact small_case S hs
  · have e3 : x2 ≥ (1.0029599666595458984375 : ℝ) := not_lt.mp hs
    have h5 : x5 = -Gf x2 := by
      simp only [x5, x4, x3, if_pos e3]
      simp only [Gf, gl, evalL_cons, evalL_nil]; push_cast; ring
    have h6 : x6 = 1 - Real.exp (-Gf x2 * (8388608 / 12102203 : ℝ)) := by
      simp only [x6, h5]
    rw [if_neg hs, h6]
    exact big_case S e3

end VoltaProofs

namespace VoltaProofs

set_option maxHeartbeats 4000000 in
theorem c_0 : VoltaChallenge.c_0 := by
  unfold VoltaChallenge.c_0
  iterate 512 intro
  exact key _ _ (by ring)

set_option maxHeartbeats 4000000 in
theorem c_1 : VoltaChallenge.c_1 := by
  unfold VoltaChallenge.c_1
  iterate 512 intro
  exact key _ _ (by ring)

set_option maxHeartbeats 4000000 in
theorem c_256 : VoltaChallenge.c_256 := by
  unfold VoltaChallenge.c_256
  iterate 512 intro
  exact key _ _ (by ring)

end VoltaProofs
