// The offsets of simdjson's structural indexer on R rows of W 32-character blocks: a block's
// structural positions go to the tape after those of the row's earlier blocks.
dim R; dim W;
array start[R, W];
array offset[R, W];
array total[R];
offset[r, w] = sum(v in 0..w, popc(start[r, v]));
total[r] = sum(v in 0..W, popc(start[r, v]));
