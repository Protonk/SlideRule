"""
sign_sequences.sage — Shared computation for alternation visualizations.

Loads a percell CSV and extracts sign sequences, RLE, transition positions,
and depth-to-depth refinement data. Not a visualization script; a helper
that all alternation visuals load.

Not intended to be run directly.
"""

import csv

from helpers import pathing


# ── Constants ────────────────────────────────────────────────────────

EPS_SIGN = 1e-12

# Data source
WALL_SURFACE_TAG = 'wall_surface_2026-03-18'
PERCELL_PATH = pathing('experiments', 'lodestone', 'results',
                       WALL_SURFACE_TAG, 'percell.csv')


# ── Load ─────────────────────────────────────────────────────────────

def load_percell(filepath=None):
    """Load percell CSV and return list of row dicts."""
    if filepath is None:
        filepath = PERCELL_PATH
    with open(filepath, 'r', newline='') as f:
        return list(csv.DictReader(f))


# ── Sign extraction ──────────────────────────────────────────────────

def extract_signs(rows, kind, q, depth, exponent, layer_dependent):
    """Return sorted list of (x_lo, x_hi, x_mid, sign) tuples.

    sign is +1, -1, or 0 (neutral) based on displacement
    = path_intercept - free_cell_intercept.
    """
    ld_str = str(layer_dependent)
    cells = []
    for r in rows:
        if (r['partition_kind'] == kind
                and r['q'] == str(q) and r['depth'] == str(depth)
                and r['exponent'] == exponent
                and r['layer_dependent'] == ld_str
                and r['free_cell_intercept'] != ''):
            delta = float(r['path_intercept']) - float(r['free_cell_intercept'])
            if delta > EPS_SIGN:
                s = 1
            elif delta < -EPS_SIGN:
                s = -1
            else:
                s = 0
            cells.append((float(r['x_lo']), float(r['x_hi']),
                          float(r['x_mid']), s))
    cells.sort()
    return cells


def signs_only(sign_entries):
    """Extract just the sign values from sign_entries."""
    return [e[3] for e in sign_entries]


# ── RLE ──────────────────────────────────────────────────────────────

def sign_rle(signs):
    """Return list of (sign, run_length) pairs."""
    if not signs:
        return []
    runs = []
    cur_sign = signs[0]
    cur_len = 1
    for s in signs[1:]:
        if s == cur_sign:
            cur_len += 1
        else:
            runs.append((cur_sign, cur_len))
            cur_sign = s
            cur_len = 1
    runs.append((cur_sign, cur_len))
    return runs


# ── Transitions ──────────────────────────────────────────────────────

def transition_positions(sign_entries):
    """Return x_mid values where the sign changes between adjacent cells."""
    transitions = []
    for i in range(len(sign_entries) - 1):
        if sign_entries[i][3] != sign_entries[i + 1][3]:
            # Transition is between these cells; use midpoint of boundary
            boundary = (sign_entries[i][1] + sign_entries[i + 1][0]) / 2.0
            transitions.append(boundary)
    return transitions


# ── Refinement ───────────────────────────────────────────────────────

def refinement_splits(signs_d, signs_d1):
    """Return list of parent indices where the two children disagree in sign.

    signs_d has 2^d entries, signs_d1 has 2^(d+1) entries.
    Parent i maps to children 2i and 2i+1.
    """
    splits = []
    for i in range(len(signs_d)):
        child_left = signs_d1[2 * i]
        child_right = signs_d1[2 * i + 1]
        if child_left != child_right:
            splits.append(i)
    return splits
