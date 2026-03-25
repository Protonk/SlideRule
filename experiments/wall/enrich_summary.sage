"""
enrich_summary.sage — Build the enriched summary table for wall analysis.

Reads all keystone summary CSVs, computes derived columns, and writes a
single enriched table that all downstream wall scripts read from.

Run:  ./sagew experiments/wall/enrich_summary.sage
"""

import csv
import os
import sys
from math import log2

from helpers import pathing


# ── Configuration ────────────────────────────────────────────────────

SUMMARY_SOURCES = [
    pathing('experiments', 'aft', 'keystone', 'results', 'wall_surface_2026-03-18', 'summary.csv'),
    pathing('experiments', 'aft', 'keystone', 'results', 'partition_2026-03-18', 'summary.csv'),
]

OUT_PATH = pathing('experiments', 'wall', 'results', 'enriched_summary.csv')

ENRICHED_COLUMNS = [
    'source_run', 'partition_kind', 'exponent', 'q', 'depth', 'layer_dependent',
    'single_err', 'opt_err', 'free_err', 'improve', 'gap',
    'worst_cell_index', 'worst_cell_bits',
    'worst_cell_x_lo', 'worst_cell_x_hi',
    'worst_cell_x_mid', 'worst_cell_plog_mid',
    'n_cells', 'n_params', 'param_to_cell_ratio',
    'gap_over_free', 'gap_over_opt',
    'time',
]


# ── Load and deduplicate ─────────────────────────────────────────────

def load_summaries(paths):
    """Load summary CSVs, deduplicating by case key."""
    rows = []
    seen = set()
    for path in paths:
        if not os.path.exists(path):
            print("  WARNING: missing %s" % path)
            continue
        with open(path, 'r', newline='') as f:
            for r in csv.DictReader(f):
                key = (r['partition_kind'], r['q'], r['depth'],
                       r['exponent'], r['layer_dependent'])
                if key not in seen:
                    seen.add(key)
                    rows.append(r)
    return rows


# ── Enrich ───────────────────────────────────────────────────────────

def enrich(row):
    """Add derived columns to one summary row."""
    q = int(row['q'])
    depth = int(row['depth'])
    ld = row['layer_dependent'] == 'True'

    n_cells = 2 ** depth
    n_params = (1 + 2 * q * depth) if ld else (1 + 2 * q)
    param_to_cell_ratio = float(n_params) / float(n_cells)

    free_err = float(row['free_err'])
    opt_err = float(row['opt_err'])
    gap = float(row['gap'])

    gap_over_free = gap / free_err if free_err > 1e-15 else ''
    gap_over_opt = gap / opt_err if opt_err > 1e-15 else ''

    # Worst cell midpoints
    x_lo = row.get('worst_cell_x_lo', '')
    x_hi = row.get('worst_cell_x_hi', '')
    if x_lo and x_hi:
        x_lo_f = float(x_lo)
        x_hi_f = float(x_hi)
        x_mid = (x_lo_f + x_hi_f) / 2.0
        plog_mid = log2(x_mid)
    else:
        x_mid = ''
        plog_mid = ''

    out = dict(row)
    out['n_cells'] = n_cells
    out['n_params'] = n_params
    out['param_to_cell_ratio'] = param_to_cell_ratio
    out['gap_over_free'] = gap_over_free
    out['gap_over_opt'] = gap_over_opt
    out['worst_cell_x_mid'] = x_mid
    out['worst_cell_plog_mid'] = plog_mid
    return out


# ── Main ─────────────────────────────────────────────────────────────

print()
print("Enriching summary tables...")

raw = load_summaries(SUMMARY_SOURCES)
print("  Loaded %d rows from %d sources" % (len(raw), len(SUMMARY_SOURCES)))

enriched = [enrich(r) for r in raw]

os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
with open(OUT_PATH, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=ENRICHED_COLUMNS, extrasaction='ignore')
    writer.writeheader()
    writer.writerows(enriched)

print("  Wrote %d rows to %s" % (len(enriched), OUT_PATH))
print("Done.")
