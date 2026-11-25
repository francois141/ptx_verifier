import challenge

set_option maxRecDepth 16384
set_option maxHeartbeats 0

namespace VoltaProofs

theorem key (x0 x1 : ℝ) (h : x0 = x1) :
    |((if (0 : ℝ) > x0 then (5368709 / 2 ^ 29 : ℝ) else (1 : ℝ)) * x0) -
      (max x1 (0 : ℝ) + ((5368709 / 2 ^ 29 : ℝ) * min x1 (0 : ℝ)))| ≤ (0.001 : ℝ) := by
  subst h
  split_ifs with hx
  · rw [max_eq_right hx.le, min_eq_left hx.le]
    norm_num
  · push_neg at hx
    rw [max_eq_left hx, min_eq_right hx]
    norm_num

theorem c_0 : VoltaChallenge.c_0 := by
  unfold VoltaChallenge.c_0
  dsimp only
  intros
  refine key _ _ ?_
  ring
theorem c_64 : VoltaChallenge.c_64 := by
  unfold VoltaChallenge.c_64
  dsimp only
  intros
  refine key _ _ ?_
  ring
theorem c_4096 : VoltaChallenge.c_4096 := by
  unfold VoltaChallenge.c_4096
  dsimp only
  intros
  refine key _ _ ?_
  ring

end VoltaProofs
