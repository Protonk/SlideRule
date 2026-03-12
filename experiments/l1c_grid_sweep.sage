"""
L1c grid sweep: layer-dependent comparison across (q, depth).

Question: Does the geometric advantage under layer-dependent sharing hold
broadly, or is (q=3, d=6) a local win?

Stage 1: (q=3, d=4), (q=5, d=4), (q=5, d=6)
Stage 2: (q=3, d=8) — only if Stage 1 is coherent

For each grid point, runs both layer-invariant and layer-dependent on both
partition kinds.  Layer-invariant reference rows that already exist in the
first lodestone sweep are rerun here for output self-containment (they are
cheap relative to the layer-dependent runs).

Outputs to: experiments/results/lodestone/l1c_grid_2026-03-12/
  summary.csv   — one row per case
  percell.csv   — one row per cell per case

Run from project root:  ./sagew experiments/l1c_grid_sweep.sage
"""

import os
import csv
import time

_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
load(os.path.join(_root, 'lib', 'paths.sage'))
load(os.path.join(_root, 'lib', 'day.sage'))
load(os.path.join(_root, 'lib', 'partitions.sage'))
load(os.path.join(_root, 'lib', 'policies.sage'))
load(os.path.join(_root, 'lib', 'jukna.sage'))
load(os.path.join(_root, 'lib', 'optimize.sage'))

# ── Per-case runner ────────────────────────────────────────────────────

def run_case(q, depth, p_num, q_den, partition_kind, layer_dependent=False):
    """Run one (q, depth, partition_kind, layer_dependent) case."""
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

    # Per-cell rows
    percell_rows = []
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


def write_csv(rows, filepath, columns):
    results_dir = os.path.dirname(filepath)
    if not os.path.exists(results_dir):
        os.makedirs(results_dir)
    with open(filepath, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=columns, extrasaction='ignore')
        writer.writeheader()
        for r in rows:
            writer.writerow(r)
    print(f"  -> {filepath}  ({len(rows)} rows)")


# ── Table printing ─────────────────────────────────────────────────────

def print_header():
    print(f"  {'kind':>12}  {'LD':>3}  {'q':>3}  {'d':>2}  "
          f"{'opt_err':>10}  {'free_err':>10}  {'gap':>10}  {'time':>6}")
    print("  " + "-" * 72)


def print_row(r):
    ld_tag = " Y" if r['layer_dependent'] else " N"
    print(f"  {r['partition_kind']:>12} {ld_tag:>3}  {r['q']:>3}  {r['depth']:>2}  "
          f"{r['opt_err']:>10.6f}  {r['free_err']:>10.6f}  {r['gap']:>10.6f}  "
          f"{r['time']:>5.1f}s")


# ── Main ───────────────────────────────────────────────────────────────

def main():
    run_dir = os.path.join(
        _root, 'experiments', 'results', 'lodestone', 'l1c_grid_2026-03-12')
    summary_rows = []
    percell_rows = []
    kinds = ['uniform_x', 'geometric_x']
    p_num, q_den = 1, 2

    def run_point(q, depth):
        """Run both partition kinds, both layer modes, for one (q, depth)."""
        for ld in [False, True]:
            for kind in kinds:
                s, pc = run_case(q, depth, p_num, q_den, kind,
                                 layer_dependent=ld)
                print_row(s)
                summary_rows.append(s)
                percell_rows.extend(pc)
        print()

    # ── Stage 1 ──────────────────────────────────────────────────────

    print("=" * 80)
    print("Stage 1: L1c grid — layer-dependent comparison")
    print("  alpha = 1/2")
    print("  grid: (q=3, d=4), (q=5, d=4), (q=5, d=6)")
    print("=" * 80)
    print()
    print_header()

    for q, d in [(3, 4), (5, 4), (5, 6)]:
        run_point(q, d)

    # ── Stage 1 sanity check ─────────────────────────────────────────

    print()
    print("=" * 80)
    print("Stage 1 sanity check")
    print("=" * 80)
    print()

    # Check: for each (q, d) point, does geometric layer-dependent opt_err
    # beat uniform layer-dependent opt_err?
    stage1_pass = True
    stage1_results = []

    for q_val, d_val in [(3, 4), (5, 4), (5, 6)]:
        geo_ld = [r for r in summary_rows
                  if r['q'] == q_val and r['depth'] == d_val
                  and r['partition_kind'] == 'geometric_x'
                  and r['layer_dependent']]
        uni_ld = [r for r in summary_rows
                  if r['q'] == q_val and r['depth'] == d_val
                  and r['partition_kind'] == 'uniform_x'
                  and r['layer_dependent']]
        if geo_ld and uni_ld:
            geo_err = geo_ld[0]['opt_err']
            uni_err = uni_ld[0]['opt_err']
            geo_wins = geo_err < uni_err
            stage1_results.append((q_val, d_val, geo_err, uni_err, geo_wins))
            tag = "geo wins" if geo_wins else "uni wins"
            print(f"  (q={q_val}, d={d_val}): geo_ld={geo_err:.6f}  "
                  f"uni_ld={uni_err:.6f}  -> {tag}")
        else:
            print(f"  (q={q_val}, d={d_val}): MISSING DATA")
            stage1_pass = False

    n_geo_wins = sum(1 for _, _, _, _, gw in stage1_results if gw)
    print()
    print(f"  Geometric wins: {n_geo_wins}/{len(stage1_results)}")

    # Sanity: are all opt_err values positive and below single_err?
    for r in summary_rows:
        if r['opt_err'] <= 0 or r['opt_err'] > r['single_err'] * 1.01:
            print(f"  WARNING: suspicious opt_err at {r['partition_kind']} "
                  f"q={r['q']} d={r['depth']} LD={r['layer_dependent']}: "
                  f"opt_err={r['opt_err']:.6f} single_err={r['single_err']:.6f}")
            stage1_pass = False

    if not stage1_pass:
        print()
        print("  Stage 1 FAILED sanity check. Skipping Stage 2.")
        print()
    else:
        print()
        print("  Stage 1 passes basic sanity check. Proceeding to Stage 2.")
        print()

        # ── Stage 2 ──────────────────────────────────────────────────

        print("=" * 80)
        print("Stage 2: L1c grid — (q=3, d=8)")
        print("=" * 80)
        print()
        print_header()

        run_point(3, 8)

    # ── Write CSVs ───────────────────────────────────────────────────

    print()
    write_csv(summary_rows, os.path.join(run_dir, 'summary.csv'),
              SUMMARY_COLUMNS)
    write_csv(percell_rows, os.path.join(run_dir, 'percell.csv'),
              PERCELL_COLUMNS)

    print()
    print("=" * 80)
    print(f"L1c grid sweep complete: {len(summary_rows)} summary rows, "
          f"{len(percell_rows)} per-cell rows")
    print("=" * 80)


main()
