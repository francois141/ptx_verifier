// As ptg_quant_scales.spec, scales column-major: x_s is the [GP, ST] buffer whose
// transpose's first M columns are the [M, GP] scales (ST >= M, a TMA-aligned stride).
dim M; dim H; dim GP; dim S; dim ST; dim G0; dim G1;
array x[M, H];
array x_s[GP, ST];
x_s[g, t] = where(t >= M, unwritten, where(t * GP + g < G0, unwritten, where(t * GP + g < G1,
    max(0.000000000100000001335143196001808973960578441619873046875,
        max(i in 0..S, abs(x[t, g * S + i]))) / 448,
    unwritten)));
