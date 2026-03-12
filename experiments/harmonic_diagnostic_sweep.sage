"""
Harmonic diagnostic sweep: reciprocal and mirrored-reciprocal controls.

Question:
  1. Does harmonic_x (equal spacing in 1/x, still finer near x=1) also beat
     uniform_x under layer-dependent sharing?
  2. What happens for the actual opposite-end control mirror_harmonic_x, which
     is finer near x=2?

Grid: same as L1c grid — (q=3,d=4), (q=5,d=4), (q=5,d=6), (q=3,d=8)
Alpha: 1/2, both layer-invariant and layer-dependent.

Outputs to: experiments/results/lodestone/harmonic_diagnostic_2026-03-12/
  summary.csv   — one row per case (with source_run column)
  percell.csv   — one row per cell per case
  README.md     — manifest

Run from project root:  ./sagew experiments/harmonic_diagnostic_sweep.sage
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

RUN_SOURCE = 'harmonic_diag_v2'
REUSED_L1C_SOURCE = 'l1c_grid_2026-03-12'
REUSED_HARMONIC_SOURCE = 'harmonic_diag_v1'


# ── Per-case runner ────────────────────────────────────────────────────

def run_case(q, depth, p_num, q_den, partition_kind, layer_dependent=False,
             source_run=RUN_SOURCE):
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
        "source_run": source_run,
    }

    # Per-cell rows
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
            "source_run": source_run,
        })

    return summary, percell_rows


# ── CSV output ─────────────────────────────────────────────────────────

SUMMARY_COLUMNS = [
    "partition_kind", "alpha", "q", "depth", "layer_dependent",
    "single_err", "opt_err", "free_err",
    "improve", "gap",
    "worst_cell_index", "worst_cell_bits",
    "worst_cell_x_lo", "worst_cell_x_hi",
    "time", "source_run",
]

PERCELL_COLUMNS = [
    "partition_kind", "alpha", "q", "depth", "layer_dependent",
    "cell_index", "bits",
    "x_lo", "x_hi", "plog_lo", "plog_hi",
    "x_mid", "plog_mid",
    "cell_worst_err", "cell_log2_ratio",
    "path_intercept", "free_cell_intercept",
    "worst_candidate_type", "worst_candidate_x", "worst_candidate_plog",
    "n_candidates", "source_run",
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


# ── Reuse existing results ─────────────────────────────────────────────

def load_existing_csv(filepath, columns):
    """Load rows from an existing CSV if it exists."""
    if not os.path.exists(filepath):
        return []
    with open(filepath, 'r') as f:
        reader = csv.DictReader(f)
        return [row for row in reader]


def find_reusable_row(existing_rows, partition_kind, q, depth, layer_dependent):
    """Find a matching row from existing results."""
    ld_str = str(layer_dependent)
    for row in existing_rows:
        if (row.get('partition_kind') == partition_kind
            and str(row.get('q')) == str(q)
            and str(row.get('depth')) == str(depth)
            and str(row.get('layer_dependent')) == ld_str):
            return row
    return None


def coerce_summary_row(row, source_run):
    """Coerce a CSV-loaded summary row back to proper types."""
    return {
        "partition_kind": row["partition_kind"],
        "alpha": row["alpha"],
        "q": int(row["q"]),
        "depth": int(row["depth"]),
        "layer_dependent": row["layer_dependent"] == 'True',
        "single_err": float(row["single_err"]),
        "opt_err": float(row["opt_err"]),
        "free_err": float(row["free_err"]),
        "improve": float(row["improve"]),
        "gap": float(row["gap"]),
        "worst_cell_index": row.get("worst_cell_index", ""),
        "worst_cell_bits": row.get("worst_cell_bits", ""),
        "worst_cell_x_lo": row.get("worst_cell_x_lo", ""),
        "worst_cell_x_hi": row.get("worst_cell_x_hi", ""),
        "time": float(row.get("time", 0)),
        "source_run": source_run,
    }


def coerce_percell_rows(existing_percell, partition_kind, q, depth,
                        layer_dependent, source_run):
    """Extract matching per-cell rows from existing results."""
    ld_str = str(layer_dependent)
    out = []
    for row in existing_percell:
        if (row.get('partition_kind') == partition_kind
            and str(row.get('q')) == str(q)
            and str(row.get('depth')) == str(depth)
            and str(row.get('layer_dependent')) == ld_str):
            r = dict(row)
            r['source_run'] = source_run
            out.append(r)
    return out


# ── Table printing ─────────────────────────────────────────────────────

def print_header():
    print(f"  {'kind':>18}  {'LD':>3}  {'q':>3}  {'d':>2}  "
          f"{'opt_err':>10}  {'free_err':>10}  {'gap':>10}  {'time':>6}  {'src':>8}")
    print("  " + "-" * 88)


def print_row(r):
    ld_tag = " Y" if r['layer_dependent'] else " N"
    src = r.get('source_run', '')[:8] or "fresh"
    opt_err = r['opt_err'] if isinstance(r['opt_err'], float) else float(r['opt_err'])
    free_err = r['free_err'] if isinstance(r['free_err'], float) else float(r['free_err'])
    gap = r['gap'] if isinstance(r['gap'], float) else float(r['gap'])
    t = r['time'] if isinstance(r['time'], float) else float(r['time'])
    print(f"  {r['partition_kind']:>18} {ld_tag:>3}  {r['q']:>3}  {r['depth']:>2}  "
          f"{opt_err:>10.6f}  {free_err:>10.6f}  {gap:>10.6f}  "
          f"{t:>5.1f}s  {src:>8}")


# ── Main ───────────────────────────────────────────────────────────────

def main():
    run_dir = os.path.join(
        _root, 'experiments', 'results', 'lodestone',
        'harmonic_diagnostic_2026-03-12')
    l1c_dir = os.path.join(
        _root, 'experiments', 'results', 'lodestone', 'l1c_grid_2026-03-12')
    existing_dir = run_dir

    # Load existing L1c results for reuse
    existing_l1c_summary = load_existing_csv(
        os.path.join(l1c_dir, 'summary.csv'), SUMMARY_COLUMNS)
    existing_l1c_percell = load_existing_csv(
        os.path.join(l1c_dir, 'percell.csv'), PERCELL_COLUMNS)
    existing_diag_summary = load_existing_csv(
        os.path.join(existing_dir, 'summary.csv'), SUMMARY_COLUMNS)
    existing_diag_percell = load_existing_csv(
        os.path.join(existing_dir, 'percell.csv'), PERCELL_COLUMNS)
    print(f"  Loaded {len(existing_l1c_summary)} summary rows from L1c grid")
    print(f"  Loaded {len(existing_diag_summary)} summary rows from prior harmonic diagnostic")

    summary_rows = []
    percell_rows = []
    kinds = ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']
    grid = [(3, 4), (5, 4), (5, 6), (3, 8)]
    p_num, q_den = 1, 2

    print("=" * 80)
    print("Harmonic diagnostic sweep")
    print("  alpha = 1/2")
    print("  partitions: uniform_x, geometric_x, harmonic_x, mirror_harmonic_x")
    print(f"  grid: {grid}")
    print("=" * 80)
    print()
    print_header()

    for q, depth in grid:
        for ld in [False, True]:
            for kind in kinds:
                reused = None
                reused_source = None
                reused_percell = None

                if kind in ('uniform_x', 'geometric_x'):
                    reused = find_reusable_row(
                        existing_l1c_summary, kind, q, depth, ld)
                    if reused is not None:
                        reused_source = REUSED_L1C_SOURCE
                        reused_percell = coerce_percell_rows(
                            existing_l1c_percell, kind, q, depth, ld, reused_source)
                elif kind == 'harmonic_x':
                    reused = find_reusable_row(
                        existing_diag_summary, kind, q, depth, ld)
                    if reused is not None:
                        reused_source = REUSED_HARMONIC_SOURCE
                        reused_percell = coerce_percell_rows(
                            existing_diag_percell, kind, q, depth, ld, reused_source)
                elif kind == 'mirror_harmonic_x':
                    reused = find_reusable_row(
                        existing_diag_summary, kind, q, depth, ld)
                    if reused is not None:
                        reused_source = reused.get('source_run') or RUN_SOURCE
                        reused_percell = coerce_percell_rows(
                            existing_diag_percell, kind, q, depth, ld, reused_source)

                if reused is not None:
                    s = coerce_summary_row(reused, reused_source)
                    pc = reused_percell
                    print_row(s)
                    summary_rows.append(s)
                    percell_rows.extend(pc)
                else:
                    s, pc = run_case(q, depth, p_num, q_den, kind,
                                     layer_dependent=ld, source_run=RUN_SOURCE)
                    print_row(s)
                    summary_rows.append(s)
                    percell_rows.extend(pc)
        print()

    # ── Sanity checks ─────────────────────────────────────────────────

    print()
    print("=" * 80)
    print("Sanity checks")
    print("=" * 80)
    print()

    ok = True
    for r in summary_rows:
        opt_err = float(r['opt_err'])
        free_err = float(r['free_err'])
        single_err = float(r['single_err'])
        if opt_err <= 0:
            print(f"  FAIL: non-positive opt_err at {r['partition_kind']} "
                  f"q={r['q']} d={r['depth']} LD={r['layer_dependent']}")
            ok = False
        if free_err <= 0:
            print(f"  FAIL: non-positive free_err at {r['partition_kind']} "
                  f"q={r['q']} d={r['depth']} LD={r['layer_dependent']}")
            ok = False
        if opt_err > single_err * 1.01:
            print(f"  WARN: opt_err > single_err at {r['partition_kind']} "
                  f"q={r['q']} d={r['depth']} LD={r['layer_dependent']}: "
                  f"opt={opt_err:.6f} single={single_err:.6f}")

    if ok:
        print("  All sanity checks pass.")

    # ── Diagnostic comparison ─────────────────────────────────────────

    print()
    print("=" * 80)
    print("Diagnostic comparison: reciprocal and mirrored-reciprocal controls")
    print("=" * 80)
    print()

    for q, depth in grid:
        for ld in [False, True]:
            ld_tag = "LD" if ld else "LI"
            case_rows = [
                r for r in summary_rows
                if int(r['q']) == q and int(r['depth']) == depth
                and r['layer_dependent'] == ld
            ]

            if len(case_rows) == 4:
                ranking = sorted([
                    (r['partition_kind'], float(r['opt_err'])) for r in case_rows
                ], key=lambda x: x[1])
                rank_str = " < ".join(f"{name}({v:.6f})" for name, v in ranking)
                print(f"  (q={q}, d={depth}, {ld_tag}): {rank_str}")
            else:
                print(f"  (q={q}, d={depth}, {ld_tag}): MISSING DATA")

    # ── Write output ──────────────────────────────────────────────────

    print()
    write_csv(summary_rows, os.path.join(run_dir, 'summary.csv'),
              SUMMARY_COLUMNS)
    write_csv(percell_rows, os.path.join(run_dir, 'percell.csv'),
              PERCELL_COLUMNS)

    # Write README manifest
    readme_path = os.path.join(run_dir, 'README.md')
    with open(readme_path, 'w') as f:
        f.write("# Harmonic diagnostic sweep — 2026-03-12\n\n")
        f.write("## Question\n\n")
        f.write("This sweep corrects the initial harmonic interpretation.\n")
        f.write("`harmonic_x` is reciprocal spacing and is still finer near x=1.\n")
        f.write("The actual opposite-end control is `mirror_harmonic_x`, which is\n")
        f.write("finer near x=2.\n\n")
        f.write("## Parameters\n\n")
        f.write("- alpha = 1/2\n")
        f.write(f"- grid: {grid}\n")
        f.write("- partitions: uniform_x, geometric_x, harmonic_x, mirror_harmonic_x\n")
        f.write("- modes: layer-invariant and layer-dependent\n\n")
        f.write("## Artifacts\n\n")
        f.write("- `summary.csv` — one row per case\n")
        f.write("- `percell.csv` — one row per cell per case\n\n")
        f.write("## Reuse\n\n")
        f.write("- `uniform_x` and `geometric_x` rows reused from l1c_grid_2026-03-12\n")
        f.write(f"  (marked source_run={REUSED_L1C_SOURCE}).\n")
        f.write("- prior `harmonic_x` rows reused from the first harmonic diagnostic\n")
        f.write(f"  (marked source_run={REUSED_HARMONIC_SOURCE}) when present.\n")
        f.write(f"- fresh rows in this rewrite are marked source_run={RUN_SOURCE}.\n")
    print(f"  -> {readme_path}")

    print()
    print("=" * 80)
    print(f"Harmonic diagnostic sweep complete: {len(summary_rows)} summary rows, "
          f"{len(percell_rows)} per-cell rows")
    print("=" * 80)


main()
