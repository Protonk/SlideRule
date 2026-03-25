"""
inspect_case.sage — Single-case diagnostic workbench.

Runs one (q, depth, exponent, kind) case and prints everything worth knowing:
three-metric computation, induced pattern family, delta table, cell-level
breakpoint analysis, and exact-vs-sampled validation.

Edit the configuration block below, then run.

Run:  ./sagew experiments/aft/keystone/inspect_case.sage
"""

from helpers import pathing
load(pathing('experiments', 'aft', 'keystone', 'keystone_runner.sage'))

from collections import defaultdict


# ── Configuration ────────────────────────────────────────────────────

Q = 3
DEPTH = 6
P_NUM, Q_DEN = 1, 2
KIND = 'uniform_x'
LAYER_DEPENDENT = False
RUN_VALIDATION = True      # run exact-vs-sampled check
CELL_REPORT_BITS = None    # e.g. (0,0,0,0,0,0) or None to skip
VALIDATION_NSAMP = 2048
VALIDATION_MAX_CELLS = 16


# ── Pattern-family diagnostics ───────────────────────────────────────

def cell_active_pattern_arb(plog_lo, plog_hi, p_num, q_den, c_rat, x_start=1):
    """Partition-aware active-pattern signature for one cell."""
    exponent_q = QQ(p_num) / QQ(q_den)
    c = QQ(c_rat)
    xs = QQ(x_start)
    breakpoints = cell_breakpoints_arb(plog_lo, plog_hi, p_num, q_den, c_rat)

    breakpoint_coords = []
    segment_coords = []
    segment_data = []

    for idx, bp in enumerate(breakpoints):
        breakpoint_coords.append(('BP', idx, breakpoint_label(
            bp, plog_lo, plog_hi, p_num, q_den, c_rat
        )))

    for idx in range(len(breakpoints) - 1):
        seg_lo = breakpoints[idx]
        seg_hi = breakpoints[idx + 1]
        seg_mid_hi = (HiR(seg_lo) + HiR(seg_hi)) / 2

        left_label = breakpoint_label(seg_lo, plog_lo, plog_hi, p_num, q_den, c_rat)
        right_label = breakpoint_label(seg_hi, plog_lo, plog_hi, p_num, q_den, c_rat)

        values = [
            (left_label, float(log2_z_at(seg_lo, p_num, q_den, c_rat, x_start=x_start))),
            (right_label, float(log2_z_at(seg_hi, p_num, q_den, c_rat, x_start=x_start))),
        ]

        u_mid = HiR(c) - HiR(exponent_q) * seg_mid_hi
        k = Integer(floor(u_mid))
        xp_D = (QQ(1) - xs + c - QQ(k)) / (1 + exponent_q)
        if (HiR(seg_lo) < HiR(xp_D) < HiR(seg_hi)
                and _d_candidate_valid(xp_D, k, p_num, q_den, c_rat)):
            d_label = ('D', Integer(k))
            values.append(
                (d_label, float(log2_z_at(xp_D, p_num, q_den, c_rat,
                                          x_start=x_start)))
            )

        min_label, min_value = min(values, key=lambda item: (item[1], _token_key(item[0])))
        max_label, max_value = max(values, key=lambda item: (item[1], _token_key(item[0])))

        segment_token = ('SEG', idx, min_label, max_label)
        segment_coords.append(segment_token)
        segment_data.append({
            "index": idx,
            "segment": (seg_lo, seg_hi),
            "min_label": min_label,
            "max_label": max_label,
            "min_value": min_value,
            "max_value": max_value,
        })

    coords = tuple(breakpoint_coords + segment_coords)

    return {
        "breakpoints": tuple(breakpoints),
        "breakpoint_coords": tuple(breakpoint_coords),
        "segment_coords": tuple(segment_coords),
        "coords": coords,
        "segments": tuple(segment_data),
    }


def active_pattern_vector_arb(plog_lo, plog_hi, p_num, q_den, c_rat,
                              coordinate_index, x_start=1):
    """Encode the partition-aware active-pattern signature as a 0-1 vector."""
    pattern = cell_active_pattern_arb(
        plog_lo, plog_hi, p_num, q_den, c_rat, x_start=x_start)
    vec = [0] * len(coordinate_index)
    for coord in pattern["coords"]:
        vec[coordinate_index[coord]] = 1
    return vector(ZZ, vec)


def build_active_pattern_family_case(case):
    """Build the active-pattern family for the optimized policy of this case."""
    paths = case["paths"]
    row_map = case["row_map"]
    q = case["q"]
    p_num = case["p_num"]
    q_den = case["q_den"]
    opt_pol = case["opt_pol"]

    pattern_rows = []
    all_coords = []

    for P in paths:
        bits = P["bits"]
        c = path_intercept(bits, opt_pol["c0_rat"], opt_pol["delta_rat"], q)
        row = row_map[bits]
        pattern = cell_active_pattern_arb(
            row["plog_lo"], row["plog_hi"], p_num, q_den, c)
        pattern_rows.append({
            "bits": bits,
            "intercept": c,
            "pattern": pattern,
        })
        all_coords.extend(pattern["coords"])

    coordinate_keys = sorted(set(all_coords), key=repr)
    coordinate_index = {coord: idx for idx, coord in enumerate(coordinate_keys)}

    unique_vectors = []
    unique_index = {}
    unique_rows = []
    multiplicities = []

    for row in pattern_rows:
        bounds = case["row_map"][row["bits"]]
        vec = active_pattern_vector_arb(
            bounds["plog_lo"], bounds["plog_hi"], p_num, q_den, row["intercept"],
            coordinate_index)
        key = tuple(vec)
        if key in unique_index:
            multiplicities[unique_index[key]] += 1
            continue
        unique_index[key] = len(unique_vectors)
        unique_vectors.append(vec)
        multiplicities.append(1)
        unique_rows.append({
            "bits": row["bits"],
            "intercept": row["intercept"],
            "pattern": row["pattern"],
            "vector": vec,
        })

    return {
        "coordinate_keys": tuple(coordinate_keys),
        "coordinate_index": coordinate_index,
        "rows": tuple(pattern_rows),
        "unique_rows": tuple(unique_rows),
        "unique_vectors": tuple(unique_vectors),
        "multiplicities": tuple(multiplicities),
    }


def run_pattern_diagnostics(case):
    """Build combinatorial diagnostics for the optimized policy of this case."""
    q = case["q"]
    opt_pol = case["opt_pol"]
    intercepts = [
        path_intercept(P["bits"], opt_pol["c0_rat"], opt_pol["delta_rat"], q)
        for P in case["paths"]
    ]
    active_family = build_active_pattern_family_case(case)
    family_summary = summarize_vector_family(list(active_family["unique_vectors"]))

    terminal_counts = defaultdict(int)
    for P in case["paths"]:
        terminal_counts[P["terminal"]] += 1

    return {
        "intercepts": intercepts,
        "active_family": active_family,
        "family_summary": family_summary,
        "terminal_counts": dict(terminal_counts),
    }


def print_pattern_summary(case, diag):
    """Print the active-pattern summary for the optimized case."""
    fs = diag["family_summary"]
    af = diag["active_family"]
    intercepts = diag["intercepts"]

    sidon_str = subset_size_str(
        fs["greedy_sidon_subset_size"], fs["exact_sidon_subset_size"])
    cf_str = subset_size_str(
        fs["greedy_cover_free_subset_size"], fs["exact_cover_free_subset_size"])

    span = float(max(intercepts) - min(intercepts))

    print(f"  partition_kind = {case['partition_kind']}")
    print(f"  layer_dep      = {case['layer_dependent']}")
    print(f"  paths          = {case['n_paths']}")
    print(f"  patterns       = {len(af['unique_vectors'])}  (dim={len(af['coordinate_keys'])})")
    print(f"  intercepts     = {len(set(intercepts))} unique, span={span:.6f}")
    print(f"  sumset         = {fs['sumset_size']}")
    print(f"  collisions     = {fs['pair_collision_count']}")
    print(f"  energy         = {fs['additive_energy']}")
    print(f"  sidon          = {'Y' if fs['full_sidon'] else 'N'}  subset={sidon_str}")
    print(f"  cover-free     = {cf_str}")
    print(f"  best_single    = {case['single_err']:.6f}")
    print(f"  opt_err        = {case['opt_err']:.6f}")
    print(f"  union_ratio    = {case['opt_u']:.6f}")


# ── Validation ───────────────────────────────────────────────────────

def cell_logerr_sampled_arb(plog_lo, plog_hi, p_num, q_den, c_rat,
                            nsamp=2048, x_start=1):
    """Dense plog-grid sampler for an arbitrary cell."""
    if nsamp < 2:
        nsamp = 2

    lo = HiR(plog_lo)
    hi = HiR(plog_hi)
    step = (hi - lo) / QQ(nsamp - 1)

    worst = 0.0
    for idx in range(nsamp):
        xp = lo + HiR(idx) * step
        val = float(log2_z_at(xp, p_num, q_den, c_rat, x_start=x_start))
        worst = max(worst, abs(val))
    return worst


def validate_exact_vs_sampled(case, nsamp=2048, max_cells=16):
    """Compare the partition-aware exact evaluator against dense sampling."""
    q = case["q"]
    p_num = case["p_num"]
    q_den = case["q_den"]
    opt_pol = case["opt_pol"]

    max_disc = 0.0
    checked = 0
    for P in case["paths"][:max_cells]:
        bits = P["bits"]
        row = case["row_map"][bits]
        c_rat = path_intercept(bits, opt_pol["c0_rat"], opt_pol["delta_rat"], q)
        _, _, exact_worst, _, _ = cell_logerr_arb(
            row["plog_lo"], row["plog_hi"], p_num, q_den, c_rat)
        sampled_worst = cell_logerr_sampled_arb(
            row["plog_lo"], row["plog_hi"], p_num, q_den, c_rat, nsamp=nsamp)
        disc = abs(exact_worst - sampled_worst)
        if disc > max_disc:
            max_disc = disc
        checked += 1

    return max_disc, checked


# ── Cell report ──────────────────────────────────────────────────────

def cell_report(case, bits):
    """Print detailed breakpoint analysis for a single cell in the case."""
    q = case["q"]
    p_num = case["p_num"]
    q_den = case["q_den"]
    exponent_q = QQ(p_num) / QQ(q_den)
    row = case["row_map"][bits]
    c_rat = path_intercept(bits, case["opt_pol"]["c0_rat"],
                           case["opt_pol"]["delta_rat"], q)
    c = QQ(c_rat)
    bps = cell_breakpoints_arb(row["plog_lo"], row["plog_hi"], p_num, q_den, c_rat)

    print(f"  cell bits={bits}  x=[{float(row['x_lo']):.6f}, {float(row['x_hi']):.6f})  "
          f"plog=[{float(row['plog_lo']):.6f}, {float(row['plog_hi']):.6f})")
    print(f"  c={float(c_rat):.6f}  exponent={float(exponent_q):.6f}")
    print(f"  breakpoints ({len(bps)}): {[float(HiR(x)) for x in bps]}")

    for i in range(len(bps) - 1):
        seg_lo = bps[i]
        seg_hi = bps[i + 1]
        seg_mid_hi = (HiR(seg_lo) + HiR(seg_hi)) / 2
        u_mid = HiR(c) - HiR(exponent_q) * seg_mid_hi
        k = Integer(floor(u_mid))
        xp_D = (c - QQ(k)) / (1 + exponent_q)
        has_D = (HiR(seg_lo) < HiR(xp_D) < HiR(seg_hi)
                 and _d_candidate_valid(xp_D, k, p_num, q_den, c_rat))

        val_lo = float(log2_z_at(seg_lo, p_num, q_den, c_rat))
        val_hi = float(log2_z_at(seg_hi, p_num, q_den, c_rat))

        D_str = ""
        if has_D:
            val_D = float(log2_z_at(xp_D, p_num, q_den, c_rat))
            D_str = f"  D@{float(xp_D):.6f}={val_D:.8f}"

        print(f"    seg[{i}] floor(u)={k}  "
              f"log2z=[{val_lo:.8f}, {val_hi:.8f}]{D_str}")

    zmin, zmax, worst, ratio, _ = cell_logerr_arb(
        row["plog_lo"], row["plog_hi"], p_num, q_den, c_rat)
    print(f"  => zmin={zmin:.8f}  zmax={zmax:.8f}  worst={worst:.8f}  ratio={ratio:.8f}")
    print()


# ── Delta table ──────────────────────────────────────────────────────

def print_delta_table(case):
    """Print the per-(state, bit) delta values from the optimized policy."""
    opt_pol = case["opt_pol"]
    q = case["q"]

    print(f"  c0         = {float(opt_pol['c0_rat']):>16.12f}")
    print(f"  worst_err  = {opt_pol['worst_err']:.8f}  "
          f"(single: {case['single_err']:.8f}, free: {case['free_err']:.8f})")
    print(f"  union_ratio= {opt_pol['union_log2_ratio']:.8f}")
    print(f"  M_opt      = {opt_pol['m_opt']:.8f}  "
          f"(snapped max|delta|: {opt_pol['max_delta_abs']:.8f})")
    print(f"  converged  = {opt_pol['converged']}")
    print(f"  tau_cont   = {opt_pol['tau_continuous']:.8f}")
    print(f"  tau_snap   = {opt_pol['tau_snapped']:.8f}")
    print(f"  dloss      = {opt_pol['dyadic_loss']:.8f}")
    print(f"  unique c's = {opt_pol['unique_intercepts']}")
    print()
    print(f"  {'(r, b)':>8}  {'delta':>16}")
    print(f"  {'─'*8}  {'─'*16}")

    delta_rat = opt_pol['delta_rat']
    keys = sorted(delta_rat.keys())
    for key in keys:
        d = float(delta_rat[key])
        print(f"  {str(key)+':':<9}  {d:>16.12f}")
    print()


# ── Main ─────────────────────────────────────────────────────────────

def main():
    print("=" * 80)
    print(f"Inspect case: q={Q}, depth={DEPTH}, exponent={P_NUM}/{Q_DEN}, "
          f"kind={KIND}, LD={LAYER_DEPENDENT}")
    print("=" * 80)

    # Three-metric computation
    print()
    print("--- Three-metric computation ---")
    print()
    case = compute_case(Q, DEPTH, P_NUM, Q_DEN, partition_kind=KIND,
                        layer_dependent=LAYER_DEPENDENT)
    print(f"  partition_kind = {KIND}")
    print(f"  layer_dep      = {LAYER_DEPENDENT}")
    print(f"  n_params       = {case['n_params']}")
    print(f"  n_paths        = {case['n_paths']}")
    print(f"  single_err     = {case['single_err']:.8f}")
    print(f"  opt_err        = {case['opt_err']:.8f}")
    print(f"  free_err       = {case['free_err']:.8f}")
    print(f"  improve        = {case['improve']:.8f}")
    print(f"  gap            = {case['gap']:.8f}")
    print(f"  elapsed        = {case['elapsed']:.1f}s")

    # Delta table
    print()
    print("--- Optimized delta table ---")
    print()
    print_delta_table(case)

    # Pattern-family diagnostics
    print()
    print("--- Pattern-family diagnostics ---")
    print()
    diag = run_pattern_diagnostics(case)
    print_pattern_summary(case, diag)

    # Validation
    if RUN_VALIDATION:
        print()
        print("--- Exact vs sampled validation ---")
        print()
        disc, checked = validate_exact_vs_sampled(
            case, nsamp=VALIDATION_NSAMP, max_cells=VALIDATION_MAX_CELLS)
        print(f"  max discrepancy = {disc:.2e}  (checked {checked} cells)")

    # Cell report
    if CELL_REPORT_BITS is not None:
        print()
        print(f"--- Cell report: bits={CELL_REPORT_BITS} ---")
        print()
        cell_report(case, CELL_REPORT_BITS)

    print()
    print("=" * 80)
    print("Done.")
    print("=" * 80)


main()
