"""
keystone_runner.sage — Shared per-case computation and CSV row builders.

Provides compute_case() for running one (q, depth, partition_kind) case
through the three-metric pipeline (single, opt, free), plus row builders
for the canonical summary and percell CSV schemas.

Not intended to be run directly.
"""

import os
import time

from helpers import pathing
load(pathing('experiments', 'sweep_driver.sage'))
load(pathing('lib', 'paths.sage'))
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))
load(pathing('lib', 'policies.sage'))
load(pathing('lib', 'jukna.sage'))
load(pathing('lib', 'optimize.sage'))


# ── Core computation ─────────────────────────────────────────────────

def compute_case(q, depth, p_num, q_den, partition_kind='uniform_x',
                 layer_dependent=False):
    """Run one case and return the raw result bundle.

    Returns a dict with:
      - config: q, depth, p_num, q_den, partition_kind, layer_dependent
      - primitives: edges, paths, edge_index, partition, row_map
      - solver outputs: single_pol, opt_pol, free_metrics
      - derived scalars: single_err, opt_err, free_err, improve, gap,
        single_u, opt_u, free_u, n_params, n_paths, elapsed
    """
    t0 = time.time()

    if layer_dependent:
        n_params = 1 + 2 * q * depth
    else:
        n_params = 1 + 2 * q

    edges, paths, edge_index = residue_paths(q, depth)
    partition = build_partition(depth, kind=partition_kind)
    row_map = partition_row_map(partition)

    single_pol = best_single_intercept(
        paths, p_num, q_den, partition_kind=partition_kind, depth=depth)
    single_err = single_pol["worst_abs"]
    single_u = single_pol["union_log2_ratio"]

    opt_pol = optimize_shared_delta(
        q, depth, p_num, q_den, partition_kind=partition_kind,
        layer_dependent=layer_dependent)
    opt_err = opt_pol["worst_err"]
    opt_u = opt_pol["union_log2_ratio"]

    free_metrics = free_per_cell_metrics(
        depth, p_num, q_den, partition_kind=partition_kind)
    free_err = free_metrics["worst_abs"]
    free_u = free_metrics["union_log2_ratio"]

    improve = single_err - opt_err
    gap = opt_err - free_err
    elapsed = time.time() - t0

    return {
        "q": q,
        "depth": depth,
        "p_num": p_num,
        "q_den": q_den,
        "partition_kind": partition_kind,
        "layer_dependent": layer_dependent,
        "edges": edges,
        "paths": paths,
        "edge_index": edge_index,
        "partition": partition,
        "row_map": row_map,
        "single_pol": single_pol,
        "opt_pol": opt_pol,
        "free_metrics": free_metrics,
        "single_err": single_err,
        "opt_err": opt_err,
        "free_err": free_err,
        "improve": improve,
        "gap": gap,
        "single_u": single_u,
        "opt_u": opt_u,
        "free_u": free_u,
        "n_params": n_params,
        "n_paths": 2**depth,
        "elapsed": elapsed,
    }


# ── CSV row builders ─────────────────────────────────────────────────

SUMMARY_COLUMNS = [
    "source_run",
    "partition_kind", "exponent", "q", "depth", "layer_dependent",
    "single_err", "opt_err", "free_err",
    "improve", "gap",
    "worst_cell_index", "worst_cell_bits",
    "worst_cell_x_lo", "worst_cell_x_hi",
    "time",
]

PERCELL_COLUMNS = [
    "source_run",
    "partition_kind", "exponent", "q", "depth", "layer_dependent",
    "cell_index", "bits",
    "x_lo", "x_hi", "plog_lo", "plog_hi",
    "x_mid", "plog_mid",
    "cell_worst_err", "cell_log2_ratio",
    "path_intercept", "free_cell_intercept",
    "worst_candidate_type", "worst_candidate_x", "worst_candidate_plog",
    "n_candidates",
]


def build_summary_row(case, source_run):
    """Build the canonical summary CSV row from a compute_case result."""
    opt = case["opt_pol"]
    return {
        "source_run": source_run,
        "partition_kind": case["partition_kind"],
        "exponent": f"{case['p_num']}/{case['q_den']}",
        "q": case["q"],
        "depth": case["depth"],
        "layer_dependent": case["layer_dependent"],
        "single_err": case["single_err"],
        "opt_err": case["opt_err"],
        "free_err": case["free_err"],
        "improve": case["improve"],
        "gap": case["gap"],
        "worst_cell_index": opt.get("worst_cell_index", ""),
        "worst_cell_bits": str(opt.get("worst_cell_bits", "")),
        "worst_cell_x_lo": opt.get("worst_cell_x_lo", ""),
        "worst_cell_x_hi": opt.get("worst_cell_x_hi", ""),
        "time": case["elapsed"],
    }


def build_percell_rows(case, source_run):
    """Build the canonical per-cell CSV rows from a compute_case result."""
    opt = case["opt_pol"]
    row_map = case["row_map"]
    free_metrics = case["free_metrics"]
    q = case["q"]
    exponent_str = f"{case['p_num']}/{case['q_den']}"

    c0_rat = opt["c0_rat"]
    delta_rat = opt["delta_rat"]
    opt_metrics = opt["metrics"]

    rows = []
    for entry in opt_metrics["cell_data"]:
        bits = entry[0]
        cell_worst_err = entry[3]
        cell_log2_ratio = entry[4]
        meta = entry[5] if len(entry) > 5 else {}

        prow = row_map[bits]
        cell_c = path_intercept(bits, c0_rat, delta_rat, q)

        free_cell_c = None
        for fr in free_metrics["rows"]:
            if fr["bits"] == bits:
                free_cell_c = fr["c_opt"]
                break

        x_mid = float((prow['x_lo'] + prow['x_hi']) / 2)
        plog_mid = float((prow['plog_lo'] + prow['plog_hi']) / 2)

        rows.append({
            "source_run": source_run,
            "partition_kind": case["partition_kind"],
            "exponent": exponent_str,
            "q": case["q"],
            "depth": case["depth"],
            "layer_dependent": case["layer_dependent"],
            "cell_index": prow['index'],
            "bits": str(bits),
            "x_lo": float(prow['x_lo']),
            "x_hi": float(prow['x_hi']),
            "plog_lo": float(prow['plog_lo']),
            "plog_hi": float(prow['plog_hi']),
            "x_mid": x_mid,
            "plog_mid": plog_mid,
            "cell_worst_err": cell_worst_err,
            "cell_log2_ratio": cell_log2_ratio,
            "path_intercept": float(cell_c),
            "free_cell_intercept": float(free_cell_c) if free_cell_c is not None else "",
            "worst_candidate_type": meta.get('worst_type', '') if isinstance(meta, dict) else '',
            "worst_candidate_x": meta.get('worst_x', '') if isinstance(meta, dict) else '',
            "worst_candidate_plog": meta.get('worst_plog', '') if isinstance(meta, dict) else '',
            "n_candidates": meta.get('n_candidates', '') if isinstance(meta, dict) else '',
        })

    return rows
