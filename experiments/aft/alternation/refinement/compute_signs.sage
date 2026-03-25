"""
compute_signs.sage — Dedicated sign-sequence computation with caching.

Computes the sign of (path_intercept - free_cell_intercept) for every cell
by calling optimize_minimax directly, reusing its internal cell_free_intercepts
map. Skips best_single_intercept and free_per_cell_metrics entirely.

Cache layout:
    results/<kind>/q<q>_<ld>_tol<tol>_db<db>.jsonl

Each line in the JSONL file is one depth's sign data. To extend to a deeper
depth, append a line. To read a specific depth, scan for it.

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
load(pathing('experiments', 'aft', 'alternation', 'sign_sequences.sage'))


# ── Constants ────────────────────────────────────────────────────────

SOLVER_VERSION = 'minimax-v1'
CACHE_DIR = pathing('experiments', 'aft', 'alternation', 'refinement', 'results')


# ── Cache ────────────────────────────────────────────────────────────

def _cache_path(kind, q, layer_dependent, tol, dyadic_bits):
    """Return the JSONL cache file path for this (kind, q, ld, solver) combo."""
    ld_tag = 'LD' if layer_dependent else 'LI'
    fname = 'q%d_%s_tol%.0e_db%d.jsonl' % (q, ld_tag, tol, dyadic_bits)
    return os.path.join(CACHE_DIR, kind, fname)


def _load_cache_index(path):
    """Load all cached entries from a JSONL file, indexed by depth.

    Returns a dict {depth: record} or empty dict if file doesn't exist.
    Skips lines with mismatched solver_version.
    """
    index = {}
    if not os.path.exists(path):
        return index
    with open(path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                record = json.loads(line)
            except json.JSONDecodeError:
                continue
            if record.get('solver_version') != SOLVER_VERSION:
                continue
            index[record['depth']] = record
    return index


def _append_cache(path, record):
    """Append one depth's record to the JSONL cache file."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'a') as f:
        f.write(json.dumps(record, separators=(',', ':')) + '\n')


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
    cpath = _cache_path(kind, q, layer_dependent, tol, dyadic_bits)

    if use_cache:
        index = _load_cache_index(cpath)
        if depth in index:
            record = index[depth]
            record['cached'] = True
            record['elapsed'] = 0.0
            return record

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
        _append_cache(cpath, result)

    return result
