// PyTorch's tanh GELU: 0.5 * x * (1 + tanh(sqrt(2/pi) * (x + 0.044715 * x^3))).
dim N;
array x[N];
array y[N];
y[i] = 0.5 * x[i] * (1 + tanh(0.7978845608028654 * (x[i] + 0.044715 * x[i] * x[i] * x[i])));
