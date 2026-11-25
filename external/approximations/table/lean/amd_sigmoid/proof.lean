import challenge

set_option maxRecDepth 16384
set_option maxHeartbeats 0

namespace VoltaProofs

theorem key (x0 s : ℝ) (h : x0 = s) :
    |((1 : ℝ) / ((if (87.3365478515625 : ℝ) < x0 then (3330985 / 2 ^ 114 : ℝ) *
        Real.exp (if (87.3365478515625 : ℝ) < x0 then (64 : ℝ) - x0 else -x0)
        else Real.exp (if (87.3365478515625 : ℝ) < x0 then (64 : ℝ) - x0 else -x0)) + (1 : ℝ)))
      - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-s)))| ≤ (0.001 : ℝ) := by
  subst h
  split_ifs with hc
  · have he : Real.exp (64 - x0) ≤ 1 := Real.exp_le_one_iff.mpr (by norm_num at hc ⊢; linarith)
    have hep : 0 < Real.exp (64 - x0) := Real.exp_pos _
    have ht1 : 0 ≤ (3330985 / 2 ^ 114 : ℝ) * Real.exp (64 - x0) := by positivity
    have ht1' : (3330985 / 2 ^ 114 : ℝ) * Real.exp (64 - x0) ≤ 0.001 := by
      have hK : (3330985 / 2 ^ 114 : ℝ) ≤ 0.001 := by norm_num
      have hK0 : (0:ℝ) ≤ (3330985 / 2 ^ 114 : ℝ) := by norm_num
      nlinarith
    have ht2p : 0 < Real.exp (-x0) := Real.exp_pos _
    have ht2 : Real.exp (-x0) ≤ 0.001 := by
      have h1 : x0 / 2 + 1 ≤ Real.exp (x0 / 2) := Real.add_one_le_exp _
      have h2 : Real.exp x0 = Real.exp (x0 / 2) * Real.exp (x0 / 2) := by
        rw [← Real.exp_add]; ring_nf
      have hx : (87:ℝ) < x0 := by norm_num at hc; linarith
      have h3 : (1000:ℝ) ≤ Real.exp x0 := by rw [h2]; nlinarith
      have hm : Real.exp (-x0) * Real.exp x0 = 1 := by rw [← Real.exp_add]; simp
      nlinarith
    set t1 := (3330985 / 2 ^ 114 : ℝ) * Real.exp (64 - x0)
    set t2 := Real.exp (-x0)
    have hA : 1 - t1 ≤ 1 / (t1 + 1) := by
      rw [le_div_iff₀ (by linarith)]; nlinarith
    have hA' : 1 / (t1 + 1) ≤ 1 := by rw [div_le_one (by linarith)]; linarith
    have hB : 1 - t2 ≤ 1 / (1 + t2) := by
      rw [le_div_iff₀ (by linarith)]; nlinarith
    have hB' : 1 / (1 + t2) ≤ 1 := by rw [div_le_one (by linarith)]; linarith
    rw [abs_le]; constructor <;> linarith
  · rw [add_comm (Real.exp (-x0)) 1, sub_self, abs_zero]; norm_num

theorem c_0 : VoltaChallenge.c_0 := by
  iterate 512 intro
  exact key _ _ (by ring)
theorem c_64 : VoltaChallenge.c_64 := by
  iterate 512 intro
  exact key _ _ (by ring)
theorem c_4096 : VoltaChallenge.c_4096 := by
  iterate 512 intro
  exact key _ _ (by ring)

end VoltaProofs
