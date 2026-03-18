"""
L1c stability sweep: q=3 depth fill and small alpha robustness check.

Question:
  1. Is the q=3 layer-dependent geometric opt_err showing a real depth floor?
  2. Does the current L1c advantage survive a small move away from alpha=1/2?

Design:
  - Reuse existing artifact rows when exact matches already exist.
  - Run only the missing cases:
      * alpha=1/2, q=3, d=5 and d=7, both modes, both partition kinds
      * alpha=1/3, q=3, d=4, layer-dependent only
      * alpha=1/3, q=5, d=6, both modes, both partition kinds
  - Write a self-contained artifact set with explicit per-row provenance.

Outputs to: experiments/lodestone/results/l1c_stability_2026-03-12/
  summary.csv
  percell.csv

Run from project root:  ./sagew experiments/lodestone/l1c_stability_sweep.sage
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


RUN_SLUG = 'l1c_stability_2026-03-12'
RUN_DIR = pathing('experiments', 'lodestone', 'results', RUN_SLUG)
RUN_SOURCE = RUN_SLUG

OLD_SOURCES = [
    (
        'l1c_grid_2026-03-12',
        pathing('experiments', 'lodestone', 'results',
                'l1c_grid_2026-03-12', 'summary.csv'),
        pathing('experiments', 'lodestone', 'results',
                'l1c_grid_2026-03-12', 'percell.csv'),
    ),
    (
        'lodestone_2026-03-11',
        pathing('experiments', 'lodestone', 'results', 'lodestone_summary.csv'),
        pathing('experiments', 'lodestone', 'results', 'lodestone_percell.csv'),
    ),
]


def load_csv_rows(path):
    with open(path, 'r', newline='') as f:
        return list(csv.DictReader(f))


def same_case(row, q, depth, p_num, q_den, partition_kind, layer_dependent):
    return (
        row['partition_kind'] == partition_kind
        and row['alpha'] == f"{p_num}/{q_den}"
        and row['q'] == str(q)
        and row['depth'] == str(depth)
        and row['layer_dependent'] == str(layer_dependent)
    )


def reuse_case(summary_pool, percell_pool, source_name, summary_rows, percell_rows,
               q, depth, p_num, q_den, partition_kind, layer_dependent):
    matches = [r.copy() for r in summary_pool
               if same_case(r, q, depth, p_num, q_den, partition_kind, layer_dependent)]
    if len(matches) != 1:
        raise ValueError(
            f"expected 1 summary row for source={source_name}, q={q}, d={depth}, "
            f"alpha={p_num}/{q_den}, kind={partition_kind}, LD={layer_dependent}; "
            f"found {len(matches)}"
        )

    srow = matches[0]
    srow['source_run'] = source_name
    summary_rows.append(srow)

    pcmatches = [r.copy() for r in percell_pool
                 if same_case(r, q, depth, p_num, q_den, partition_kind, layer_dependent)]
    if not pcmatches:
        raise ValueError(
            f"missing percell rows for source={source_name}, q={q}, d={depth}, "
            f"alpha={p_num}/{q_den}, kind={partition_kind}, LD={layer_dependent}"
        )

    for prow in pcmatches:
        prow['source_run'] = source_name
    percell_rows.extend(pcmatches)

    print(f"  reuse  {partition_kind:>12}  LD={str(layer_dependent):<5}  "
          f"alpha={p_num}/{q_den:>3}  q={q:>2}  d={depth:>2}  from {source_name}")


def run_case(q, depth, p_num, q_den, partition_kind, layer_dependent=False):
    """Run one (q, depth, partition_kind, layer_dependent) case."""
    t0 = time.time()
    alpha_str = f"{p_num}/{q_den}"

    _, paths, _ = residue_paths(q, depth)
    partition = build_partition(depth, kind=partition_kind)
    row_map = partition_row_map(partition)

    single = best_single_intercept(
        paths, p_num, q_den, partition_kind=partition_kind, depth=depth)
    single_err = single["worst_abs"]

    opt = optimize_shared_delta(
        q, depth, p_num, q_den, partition_kind=partition_kind,
        layer_dependent=layer_dependent)
    opt_err = opt["worst_err"]

    free_metrics = free_per_cell_metrics(
        depth, p_num, q_den, partition_kind=partition_kind)
    free_err = free_metrics["worst_abs"]

    improve = single_err - opt_err
    gap = opt_err - free_err
    elapsed = time.time() - t0

    summary = {
        "partition_kind": partition_kind,
        "alpha": alpha_str,
        "q": q,
        "depth": depth,
        "layer_dependent": layer_dependent,
        "single_err": single_err,
        "opt_err": opt_err,
        "free_err": free_err,
        "improve": improve,
        "gap": gap,
        "worst_cell_index": opt.get("worst_cell_index", ""),
        "worst_cell_bits": str(opt.get("worst_cell_bits", "")),
        "worst_cell_x_lo": opt.get("worst_cell_x_lo", ""),
        "worst_cell_x_hi": opt.get("worst_cell_x_hi", ""),
        "time": elapsed,
        "source_run": RUN_SOURCE,
    }

    percell_rows = []
    opt_metrics = opt["metrics"]
    c0_rat = opt["c0_rat"]
    delta_rat = opt["delta_rat"]

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

        percell_rows.append({
            "partition_kind": partition_kind,
            "alpha": alpha_str,
            "q": q,
            "depth": depth,
            "layer_dependent": layer_dependent,
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
            "source_run": RUN_SOURCE,
        })

    print(f"  run    {partition_kind:>12}  LD={str(layer_dependent):<5}  "
          f"alpha={alpha_str:>3}  q={q:>2}  d={depth:>2}  "
          f"opt={opt_err:.6f}  gap={gap:.6f}  {elapsed:.1f}s")
    return summary, percell_rows


SUMMARY_COLUMNS = [
    "source_run",
    "partition_kind", "alpha", "q", "depth", "layer_dependent",
    "single_err", "opt_err", "free_err",
    "improve", "gap",
    "worst_cell_index", "worst_cell_bits",
    "worst_cell_x_lo", "worst_cell_x_hi",
    "time",
]

PERCELL_COLUMNS = [
    "source_run",
    "partition_kind", "alpha", "q", "depth", "layer_dependent",
    "cell_index", "bits",
    "x_lo", "x_hi", "plog_lo", "plog_hi",
    "x_mid", "plog_mid",
    "cell_worst_err", "cell_log2_ratio",
    "path_intercept", "free_cell_intercept",
    "worst_candidate_type", "worst_candidate_x", "worst_candidate_plog",
    "n_candidates",
]


def print_header():
    print(f"  {'source':>18}  {'kind':>12}  {'LD':>3}  {'alpha':>5}  {'q':>3}  {'d':>2}  "
          f"{'opt_err':>10}  {'gap':>10}")
    print("  " + "-" * 92)


def main():
    summary_rows = []
    percell_rows = []
    kinds = ['uniform_x', 'geometric_x']
    source_pools = {}

    for source_name, sum_path, per_path in OLD_SOURCES:
        source_pools[source_name] = (load_csv_rows(sum_path), load_csv_rows(per_path))

    def reuse_point(source_name, q, depth, p_num, q_den, modes):
        summary_pool, percell_pool = source_pools[source_name]
        for ld in modes:
            for kind in kinds:
                reuse_case(summary_pool, percell_pool, source_name,
                           summary_rows, percell_rows,
                           q, depth, p_num, q_den, kind, ld)
        print()

    def run_point(q, depth, p_num, q_den, modes):
        for ld in modes:
            for kind in kinds:
                srow, prows = run_case(q, depth, p_num, q_den, kind, layer_dependent=ld)
                summary_rows.append(srow)
                percell_rows.extend(prows)
        print()

    print("=" * 100)
    print("L1c stability sweep")
    print("=" * 100)
    print()
    print_header()

    # Stage 1: q=3 depth fill at alpha=1/2.
    print()
    print("Stage 1: q=3 depth fill at alpha=1/2")
    print()
    reuse_point('l1c_grid_2026-03-12', 3, 4, 1, 2, [False, True])
    run_point(3, 5, 1, 2, [False, True])
    reuse_point('lodestone_2026-03-11', 3, 6, 1, 2, [False, True])
    run_point(3, 7, 1, 2, [False, True])
    reuse_point('l1c_grid_2026-03-12', 3, 8, 1, 2, [False, True])

    # Stage 2: small alpha robustness check.
    print()
    print("Stage 2: alpha=1/3 robustness")
    print()
    reuse_point('lodestone_2026-03-11', 3, 4, 1, 3, [False])
    run_point(3, 4, 1, 3, [True])
    run_point(5, 6, 1, 3, [False, True])

    write_csv(summary_rows, os.path.join(RUN_DIR, 'summary.csv'), SUMMARY_COLUMNS)
    write_csv(percell_rows, os.path.join(RUN_DIR, 'percell.csv'), PERCELL_COLUMNS)

    print()
    print("=" * 100)
    print(f"L1c stability sweep complete: {len(summary_rows)} summary rows, "
          f"{len(percell_rows)} per-cell rows")
    print("=" * 100)


main()
