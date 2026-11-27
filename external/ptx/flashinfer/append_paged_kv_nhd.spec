// As append_paged_kv_hnd.spec with NHD pages [NP, PS, H, D].
dim NP; dim H; dim PS; dim D; dim NT; dim HS; dim I; dim PAGE; dim ENTRY;
array key[NT, HS, D];
array value[NT, HS, D];
array k_data[NP, PS, H, D];
array v_data[NP, PS, H, D];
k_data[p, e, h, d] = where(p != PAGE, unwritten, where(e != ENTRY, unwritten, key[I, h, d]));
v_data[p, e, h, d] = where(p != PAGE, unwritten, where(e != ENTRY, unwritten, value[I, h, d]));
