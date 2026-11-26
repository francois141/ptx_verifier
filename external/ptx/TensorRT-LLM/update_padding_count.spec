// TensorRT-LLM updatePaddingCountKernel: padding[i] = maxQSeqLength - seqLengths[i].
dim N; dim M;
array seq[N];
array padding[N];
padding[i] = M - seq[i];
