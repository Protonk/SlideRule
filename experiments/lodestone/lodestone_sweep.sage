"""
Lodestone partition-comparison sweep.

Compares uniform_x and geometric_x partitions under the same optimizer,
FSM parameterization, and objective.  Tests L1-L3 hypotheses from
LODESTONE.md.

Sweep 1: fixed q=5, alpha=1/2, varying depth on both partition kinds.
Sweep 2: fixed depth=4, alpha=1/2, varying q on both partition kinds.
Sweep 3: layer-invariant vs layer-dependent at (q=3,d=6) on both kinds.
Sweep 4: secondary alpha checkpoint (alpha=1/3) at q=3, depth=4.

Outputs:
  experiments/lodestone/results/lodestone_summary.csv   — one row per case
  experiments/lodestone/results/lodestone_percell.csv   — one row per cell per case

Run from project root:  ./sagew experiments/lodestone/lodestone_sweep.sage
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


# ── Per-case runner ────────────────────────────────────────────────────

def run_lodestone_case(q, depth, p_num, q_den, partition_kind,
                       layer_dependent=False):
    """
    Run one (q, depth, partition_kind) case.

    Returns (summary_row, percell_rows).
    """
    t0 = time.time()
    alpha_str = f"{p_num}/{q_den}"

    _, paths, _ = residue_paths(q, depth)
    partition = build_partition(depth, kind=partition_kind)
    row_map = partition_row_map(partition)

    # Single intercept baseline
    single = best_single_intercept(
        paths, p_num, q_den, partition_kind=partition_kind, depth=depth)
    single_err = single["worst_abs"]

    # Shared-delta minimax
    opt = optimize_shared_delta(
        q, depth, p_num, q_den, partition_kind=partition_kind,
        layer_dependent=layer_dependent)
    opt_err = opt["worst_err"]
    m_opt = opt["m_opt"]

    # Free-per-cell bound
    free_metrics = free_per_cell_metrics(
        depth, p_num, q_den, partition_kind=partition_kind)
    free_err = free_metrics["worst_abs"]

    improve = single_err - opt_err
    gap = opt_err - free_err

    elapsed = time.time() - t0

    # Build summary row
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
    }

    # Build per-cell rows
    percell_rows = []

    # Per-cell data from the optimized policy
    opt_metrics = opt["metrics"]
    c0_rat = opt["c0_rat"]
    delta_rat = opt["delta_rat"]

    for entry in opt_metrics["cell_data"]:
        bits = entry[0]
        cell_zmin = entry[1]
        cell_zmax = entry[2]
        cell_worst_err = entry[3]
        cell_log2_ratio = entry[4]
        meta = entry[5] if len(entry) > 5 else {}

        prow = row_map[bits]
        cell_c = path_intercept(bits, c0_rat, delta_rat, q)

        # Free-per-cell intercept for this cell
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
        })

    return summary, percell_rows


# ── CSV output ─────────────────────────────────────────────────────────

SUMMARY_COLUMNS = [
    "partition_kind", "alpha", "q", "depth", "layer_dependent",
    "single_err", "opt_err", "free_err",
    "improve", "gap",
    "worst_cell_index", "worst_cell_bits",
    "worst_cell_x_lo", "worst_cell_x_hi",
    "time",
]

PERCELL_COLUMNS = [
    "partition_kind", "alpha", "q", "depth", "layer_dependent",
    "cell_index", "bits",
    "x_lo", "x_hi", "plog_lo", "plog_hi",
    "x_mid", "plog_mid",
    "cell_worst_err", "cell_log2_ratio",
    "path_intercept", "free_cell_intercept",
    "worst_candidate_type", "worst_candidate_x", "worst_candidate_plog",
    "n_candidates",
]


# ── Table printing ─────────────────────────────────────────────────────

def print_comparison_header():
    print(f"  {'kind':>12}  {'q':>3}  {'d':>2}  "
          f"{'single_err':>10}  {'opt_err':>10}  {'free_err':>10}  "
          f"{'improve':>9}  {'gap':>10}  {'time':>6}")
    print("  " + "-" * 90)


def print_comparison_row(r):
    ld_tag = " [LD]" if r['layer_dependent'] else ""
    print(f"  {r['partition_kind']:>12}{ld_tag}  {r['q']:>3}  {r['depth']:>2}  "
          f"{r['single_err']:>10.6f}  {r['opt_err']:>10.6f}  {r['free_err']:>10.6f}  "
          f"{r['improve']:>9.6f}  {r['gap']:>10.6f}  {r['time']:>5.1f}s")


# ── Main ───────────────────────────────────────────────────────────────

def main():
    results_dir = pathing('experiments', 'lodestone', 'results')
    summary_rows = []
    percell_rows = []
    kinds = ['uniform_x', 'geometric_x']

    def run_pair(q, depth, p_num, q_den, layer_dependent=False):
        for kind in kinds:
            s, pc = run_lodestone_case(q, depth, p_num, q_den, kind,
                                       layer_dependent=layer_dependent)
            print_comparison_row(s)
            summary_rows.append(s)
            percell_rows.extend(pc)

    # ── Sweep 1: depth scaling at fixed q=5, alpha=1/2 ──────────────

    p_num, q_den = 1, 2

    print("=" * 100)
    print("Sweep 1: depth scaling at fixed q=5, alpha=1/2")
    print("=" * 100)
    print()
    print_comparison_header()

    for depth in [3, 4, 5, 6]:
        run_pair(5, depth, p_num, q_den)
        print()

    # ── Sweep 2: q scaling at fixed depth=4, alpha=1/2 ──────────────

    print()
    print("=" * 100)
    print("Sweep 2: q scaling at fixed depth=4, alpha=1/2")
    print("=" * 100)
    print()
    print_comparison_header()

    for q in [1, 2, 3, 5, 7]:
        run_pair(q, 4, p_num, q_den)
        print()

    # ── Sweep 3: layer-dependent vs invariant at (q=3,d=6) ──────────

    print()
    print("=" * 100)
    print("Sweep 3: layer-dependent vs layer-invariant at (q=3, d=6)")
    print("=" * 100)
    print()
    print_comparison_header()

    for ld in [False, True]:
        run_pair(3, 6, p_num, q_den, layer_dependent=ld)
    print()

    # ── Sweep 4: secondary alpha checkpoint (alpha=1/3) ─────────────

    print()
    print("=" * 100)
    print("Sweep 4: secondary alpha checkpoint (alpha=1/3, q=3, d=4)")
    print("=" * 100)
    print()
    print_comparison_header()

    run_pair(3, 4, 1, 3)
    print()

    # ── Write CSVs ──────────────────────────────────────────────────

    print()
    write_csv(summary_rows, os.path.join(results_dir, 'lodestone_summary.csv'),
              SUMMARY_COLUMNS)
    write_csv(percell_rows, os.path.join(results_dir, 'lodestone_percell.csv'),
              PERCELL_COLUMNS)

    print()
    print("=" * 100)
    print(f"Lodestone sweep complete: {len(summary_rows)} summary rows, "
          f"{len(percell_rows)} per-cell rows")
    print("=" * 100)


main()
