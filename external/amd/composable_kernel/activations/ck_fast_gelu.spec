// CK's FastGelu, y = x / (1 + exp(x * (c1 * x * x + c2))), with the fp32 constants FastGelu and
// FastGeluAsm share as exact reals: c1 = -2 * 0.035677f (0xbd92220c), c2 = -2 * 0.797885f (0xbfcc4231).
dim N;
array x[N];
array y[N];

y[i] = x[i] / (1 + exp(x[i] * (-0.07135400176048279 * x[i] * x[i] + -1.595770001411438)));
