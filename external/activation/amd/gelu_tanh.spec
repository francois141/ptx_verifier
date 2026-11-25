// PyTorch's tanh GELU: 0.5 * x * (1 + tanh(sqrt(2/pi) * (x + 0.044715 * x^3))).
dim N;
array input[N];
array out[N];
out[i] = 0.5 * input[i] * (1 + tanh(0.7978845608028654 * (input[i] + 0.044715 * input[i] * input[i] * input[i])));
