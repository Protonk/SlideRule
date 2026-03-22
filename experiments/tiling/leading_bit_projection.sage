"""
leading_bit_projection.sage — Backward-compatible shim for displacement helpers.

The reusable implementation now lives in `lib/displacement.sage`. This file
continues to expose those helpers for older experiment scripts and keeps the
FSM-specific `cumulative_intercept()` helper in place.
"""

from helpers import pathing
load(pathing('lib', 'displacement.sage'))


def cumulative_intercept(bits, c0_rat, delta_rat, q, up_to_layer):
    """Intercept using only layers 0..up_to_layer."""
    r = 0
    c = float(c0_rat)
    for t in range(up_to_layer + 1):
        b = bits[t]
        # Try layer-dependent key first
        ld_key = (t, r, b)
        li_key = (r, b)
        if ld_key in delta_rat:
            c += float(delta_rat[ld_key])
        elif li_key in delta_rat:
            c += float(delta_rat[li_key])
        r = (2 * r + b) % q
    return c
