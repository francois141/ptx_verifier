"""nkilib's ssd (Mamba-2) without the D skip, returning `y` or `final_state`."""

import importlib

ssd = importlib.import_module("nkilib.experimental.scan.ssd").ssd


def kernel(x, dt, A, B, C, initial_state, causal_mask, chunk_size, final=False):
    y, final_state = ssd(
        x,
        dt,
        A,
        B,
        C,
        chunk_size=chunk_size,
        initial_state=initial_state,
        causal_mask=causal_mask,
    )
    if final:
        return final_state
    return y
