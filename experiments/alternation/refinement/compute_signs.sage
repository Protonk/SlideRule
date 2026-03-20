"""
compute_signs.sage — Dedicated sign-sequence computation with caching.

Computes the sign of (path_intercept - free_cell_intercept) for every cell
by calling optimize_minimax directly, reusing its internal cell_free_intercepts
map. Skips best_single_intercept and free_per_cell_metrics entirely.

Caches results to disk for incremental extension.

Not intended to be run directly.
"""

import json
import os
import time

from helpers import pathing
load(pathing('lib', 'paths.sage'))
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))
load(pathing('lib', 'policies.sage'))
load(pathing('lib', 'optimize.sage'))
load(pathing('experiments', 'alternation', 'sign_sequences.sage'))


# ── Constants ────────────────────────────────────────────────────────

SOLVER_VERSION = 'minimax-v1'
CACHE_DIR = pathing('experiments', 'alternation', 'refinement', 'results')


# ── Cache ────────────────────────────────────────────────────────────

def _cache_path(kind, q, depth, p_num, q_den, layer_dependent,
                tol, dyadic_bits):
    """Return the path to the cache file for this case."""
    ld_tag = 'LD' if layer_dependent else 'LI'
    subdir = '%s_q%d_%s' % (kind, q, ld_tag)
    fname = 'signs_d%d_tol%.0e_db%d.json' % (depth, tol, dyadic_bits)
    return os.path.join(CACHE_DIR, subdir, fname)


def _load_cache(path):
    """Load cached sign data if it exists and matches solver version."""
    if not os.path.exists(path):
        return None
    with open(path, 'r') as f:
        data = json.load(f)
    if data.get('solver_version') != SOLVER_VERSION:
        return None
    return data


def _save_cache(path, data):
    """Write sign data to cache."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        json.dump(data, f, indent=2)


def _serialize_policy(c0_rat, delta_rat):
    """Serialize the snapped policy for the cache."""
    return {
        'c0': str(c0_rat),
        'delta': {str(k): str(v) for k, v in delta_rat.items()},
    }


# ── Core computation ─────────────────────────────────────────────────

def compute_signs(q, depth, p_num, q_den, kind='uniform_x',
                  layer_dependent=False, tol=1e-10, dyadic_bits=20,
                  use_cache=True):
    """Compute the sign sequence for one case.

    Returns a dict with:
      - signs: list of +1/-1/0, one per cell, sorted by x_lo
      - n_runs: number of runs in the RLE
      - elapsed: wall-clock seconds (0 if loaded from cache)
      - cached: True if loaded from cache
      - c0: snapped c0 (as string)
      - delta: snapped delta dict (as string keys/values)
      - tau_continuous, tau_snapped: solver metadata
    """
    cpath = _cache_path(kind, q, depth, p_num, q_den, layer_dependent,
                        tol, dyadic_bits)

    if use_cache:
        cached = _load_cache(cpath)
        if cached is not None:
            cached['cached'] = True
            cached['elapsed'] = 0.0
            return cached

    t0 = time.time()

    # Call optimize_minimax directly — no best_single_intercept,
    # no free_per_cell_metrics.
    opt = optimize_minimax(q, depth, p_num, q_den,
                           tol=tol, dyadic_bits=dyadic_bits,
                           layer_dependent=layer_dependent,
                           partition_kind=kind)

    c0_rat = opt['c0_rat']
    delta_rat = opt['delta_rat']
    free_intercepts = opt['cell_free_intercepts']

    # Build partition for cell geometry (x_lo ordering)
    partition = build_partition(depth, kind=kind)
    row_map = partition_row_map(partition)
    _, paths, _ = residue_paths(q, depth)

    # Compute signs directly
    sign_entries = []
    for P in paths:
        bits = P['bits']
        shared_c = float(path_intercept(bits, c0_rat, delta_rat, q))
        free_c = free_intercepts[bits]
        delta = shared_c - free_c

        if delta > EPS_SIGN:
            s = 1
        elif delta < -EPS_SIGN:
            s = -1
        else:
            s = 0

        prow = row_map[bits]
        sign_entries.append((float(prow['x_lo']), s))

    sign_entries.sort()
    signs = [e[1] for e in sign_entries]

    elapsed = time.time() - t0
    rle = sign_rle(signs)

    result = {
        'kind': str(kind),
        'q': int(q),
        'depth': int(depth),
        'p_num': int(p_num),
        'q_den': int(q_den),
        'layer_dependent': bool(layer_dependent),
        'tol': float(tol),
        'dyadic_bits': int(dyadic_bits),
        'eps_sign': float(EPS_SIGN),
        'solver_version': SOLVER_VERSION,
        'signs': [int(s) for s in signs],
        'n_runs': int(len(rle)),
        'elapsed': float(elapsed),
        'cached': False,
        'tau_continuous': float(opt.get('tau_continuous', 0)),
        'tau_snapped': float(opt.get('tau_snapped', 0)),
    }
    result.update(_serialize_policy(c0_rat, delta_rat))

    if use_cache:
        _save_cache(cpath, result)

    return result
