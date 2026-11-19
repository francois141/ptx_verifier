"""nkilib's pad as released (ad2f1b9). `mode` indexes `MODES`; constant mode pads with 0."""

import importlib

module = importlib.import_module("nkilib.experimental.pad.pad")
MODES = ("constant", "replicate", "reflect", "circular")


def kernel(x_ref, padding, mode):
    out = module.pad(x_ref, tuple(padding), mode=MODES[mode], value=0)
    return out
