// The tensor indirection tutorial's reference, `data_tensor[:, index_tensor[0]]`:
// each output column is the data column the index tensor's offset names.
dim DATA_P; dim DATA_F; dim INDEX_F; dim ONE;
array data_tensor[DATA_P, DATA_F];
array index_tensor[ONE, INDEX_F] index;
array out_tensor[DATA_P, INDEX_F];
out_tensor[p, i] = data_tensor[p, index_tensor[0, i]];
