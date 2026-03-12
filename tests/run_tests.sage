"""
Project test runner.

Run from project root:  ./sagew tests/run_tests.sage
"""

import os
_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
load(os.path.join(_root, 'lib', 'paths.sage'))
load(os.path.join(_root, 'lib', 'day.sage'))
load(os.path.join(_root, 'lib', 'partitions.sage'))
load(os.path.join(_root, 'lib', 'policies.sage'))
load(os.path.join(_root, 'lib', 'jukna.sage'))
load(os.path.join(_root, 'lib', 'optimize.sage'))


def assert_true(condition, message):
    if not condition:
        raise AssertionError(message)


def assert_close(lhs, rhs, tol, message):
    if abs(lhs - rhs) > tol:
        raise AssertionError(f"{message}: lhs={lhs}, rhs={rhs}, tol={tol}")


def test_residue_paths():
    edges, paths, edge_index = residue_paths(2, 3)
    assert_true(len(edges) == 12, "unexpected edge count")
    assert_true(len(paths) == 8, "unexpected path count")
    assert_true(len(edge_index) == len(edges), "edge index mismatch")
    for row in paths:
        assert_true(sum(row["vec"]) == 3, "path incidence vector should have depth weight")
        assert_true(len(row["states"]) == 4, "state trace should include source plus depth states")


def test_global_metrics_and_best_single():
    _, paths, _ = residue_paths(1, 3)
    alpha_q = QQ(1) / QQ(2)
    zero = zero_policy(1, 3, alpha_q)
    metrics = global_exact_metrics(paths, 1, 2, zero["c0_rat"], zero["delta_rat"], 1)
    best = best_single_intercept(paths, 1, 2)

    assert_true(
        metrics["union_log2_ratio"] >= metrics["max_cell_log2_ratio"],
        "union ratio should dominate max cell ratio",
    )
    assert_true(
        best["worst_abs"] <= metrics["worst_abs"] + 1e-12,
        "best single intercept should not be worse than centered baseline",
    )


def test_active_pattern_family():
    _, paths, _ = residue_paths(1, 3)
    alpha_q = QQ(1) / QQ(2)
    zero = zero_policy(1, 3, alpha_q)
    family = build_active_pattern_family(paths, 1, 2, zero["c0_rat"], zero["delta_rat"], 1)

    assert_true(len(family["coordinate_keys"]) > 0, "pattern family should expose coordinates")
    assert_true(0 < len(family["unique_vectors"]) <= len(paths), "unexpected unique vector count")
    for vec in family["unique_vectors"]:
        assert_true(all(entry in (0, 1) for entry in vec), "pattern vectors must be 0-1")


def test_exact_combinatorics():
    vectors = [
        vector(ZZ, [1, 0, 0]),
        vector(ZZ, [0, 1, 0]),
        vector(ZZ, [0, 0, 1]),
        vector(ZZ, [1, 1, 0]),
    ]
    summary = summarize_vector_family(vectors)

    assert_true(summary["exact_sidon_subset"] is not None, "exact Sidon search should run")
    assert_true(summary["exact_cover_free_subset"] is not None, "exact cover-free search should run")
    assert_true(
        summary["exact_sidon_subset_size"] >= summary["greedy_sidon_subset_size"],
        "exact Sidon optimum should dominate greedy result",
    )
    assert_true(
        summary["exact_cover_free_subset_size"] >= summary["greedy_cover_free_subset_size"],
        "exact cover-free optimum should dominate greedy result",
    )
    assert_true(
        is_sidon(vectors, subset=summary["exact_sidon_subset"]),
        "exact Sidon subset must satisfy Sidon property",
    )
    assert_true(
        is_cover_free(vectors, subset=summary["exact_cover_free_subset"])[0],
        "exact cover-free subset must satisfy cover-free property",
    )


def test_optimizer_smoke():
    _, paths, _ = residue_paths(1, 2)
    best = best_single_intercept(paths, 1, 2)
    opt = optimize_shared_delta(1, 2, 1, 2, maxiter=40, n_restarts=1, dyadic_bits=8,
                                method='nelder-mead')

    assert_true(opt["unique_intercepts"] >= 1, "optimized policy should expose at least one intercept")
    assert_true(
        opt["worst_err"] <= best["worst_abs"] + 1e-8,
        "shared-delta optimizer should not regress against best single intercept on the smoke case",
    )


def test_minimax_smoke():
    opt = optimize_shared_delta(1, 2, 1, 2)  # defaults to method='minimax'

    assert_true(opt["unique_intercepts"] >= 1, "minimax should expose at least one intercept")
    assert_true(opt["converged"], "minimax should report converged")
    assert_true(opt["worst_err"] > 0, "minimax worst_err should be positive")
    assert_true(opt["m_opt"] >= 0, "minimax should expose nonnegative m_opt")
    assert_true(opt["max_delta_abs"] >= 0, "minimax should expose snapped max |delta|")
    assert_true("matches_continuous_tau" in opt, "minimax result should expose continuous-tau match status")
    assert_true("within_target" in opt, "minimax result should expose within_target")
    assert_true("fallback_used" in opt, "minimax result should expose fallback_used")
    assert_true("repair_used" in opt, "minimax result should expose repair_used")
    assert_true("tau_continuous" in opt, "minimax result should expose tau_continuous")
    assert_true("tau_snapped" in opt, "minimax result should expose tau_snapped")
    assert_true(opt["within_target"], "minimax smoke case should satisfy its final target")


def test_minimax_beats_nelder_mead():
    q, depth = 2, 4
    mm = optimize_shared_delta(q, depth, 1, 2, method='minimax')
    nm = optimize_shared_delta(q, depth, 1, 2, method='nelder-mead',
                               maxiter=2000, n_restarts=2, dyadic_bits=12)
    assert_true(
        mm["worst_err"] <= nm["worst_err"] + 1e-8,
        f"minimax ({mm['worst_err']:.8f}) should be no worse than "
        f"nelder-mead ({nm['worst_err']:.8f})",
    )


def test_minimax_above_free_bound():
    q, depth = 2, 4
    mm = optimize_shared_delta(q, depth, 1, 2, method='minimax')
    free_worst, _ = free_per_cell_optimum(depth, 1, 2)
    assert_true(
        mm["worst_err"] >= free_worst - 1e-8,
        f"minimax ({mm['worst_err']:.8f}) should be >= "
        f"free-per-cell bound ({free_worst:.8f})",
    )


def test_layer_dependent_smoke():
    q, depth = 2, 3
    opt = optimize_shared_delta(q, depth, 1, 2, layer_dependent=True)

    assert_true(opt["unique_intercepts"] >= 1,
                "layer-dependent minimax should expose at least one intercept")
    assert_true(opt["converged"],
                "layer-dependent minimax should converge")
    assert_true(opt["worst_err"] > 0,
                "layer-dependent worst_err should be positive")
    assert_true(opt.get("layer_dependent") == True,
                "result should report layer_dependent=True")


def test_layer_dependent_beats_invariant():
    q, depth = 2, 3
    ld = optimize_shared_delta(q, depth, 1, 2, layer_dependent=True)
    li = optimize_shared_delta(q, depth, 1, 2, layer_dependent=False)
    assert_true(
        ld["worst_err"] <= li["worst_err"] + 1e-8,
        f"layer-dependent ({ld['worst_err']:.8f}) should not be worse than "
        f"layer-invariant ({li['worst_err']:.8f})",
    )


def test_layer_dependent_above_free_bound():
    q, depth = 2, 3
    opt = optimize_shared_delta(q, depth, 1, 2, layer_dependent=True)
    free_worst, _ = free_per_cell_optimum(depth, 1, 2)
    assert_true(
        opt["worst_err"] >= free_worst - 1e-8,
        f"layer-dependent ({opt['worst_err']:.8f}) should be >= "
        f"free-per-cell bound ({free_worst:.8f})",
    )


def test_bits_index_roundtrip():
    for depth in (1, 2, 3, 5):
        N = 2^depth
        for j in range(N):
            bits = index_to_bits(j, depth)
            assert_true(len(bits) == depth, f"bits length mismatch for j={j}, depth={depth}")
            assert_true(bits_to_index(bits) == j, f"roundtrip failed for j={j}, depth={depth}")


def test_uniform_x_partition():
    depth = 4
    part = build_partition(depth, kind='uniform_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)

    # Contiguity: x_hi of cell j == x_lo of cell j+1
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"uniform_x contiguity gap at j={j}",
        )

    # Covers [1, 2)
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "uniform_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "uniform_x should end at 2")

    # Equal additive widths
    expected_width = HiR(1) / HiR(N)
    for row in part:
        assert_true(
            abs(row['width_x'] - expected_width) < tol,
            f"uniform_x cell {row['index']} has wrong additive width",
        )

    # bits match index
    for row in part:
        assert_true(
            bits_to_index(row['bits']) == row['index'],
            f"uniform_x cell {row['index']} bits mismatch",
        )


def test_geometric_x_partition():
    depth = 4
    part = build_partition(depth, kind='geometric_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)

    # Contiguity
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"geometric_x contiguity gap at j={j}",
        )

    # Covers [1, 2)
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "geometric_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "geometric_x should end at 2")

    # Equal log widths
    expected_log_width = HiR(1) / HiR(N)
    for row in part:
        assert_true(
            abs(row['width_log'] - expected_log_width) < tol,
            f"geometric_x cell {row['index']} has wrong log width: "
            f"{float(row['width_log'])} vs {float(expected_log_width)}",
        )

    # bits match index
    for row in part:
        assert_true(
            bits_to_index(row['bits']) == row['index'],
            f"geometric_x cell {row['index']} bits mismatch",
        )


def test_partition_row_map():
    depth = 3
    part = build_partition(depth, kind='uniform_x')
    rmap = partition_row_map(part)
    assert_true(len(rmap) == 2^depth, "row map should have 2^depth entries")
    for row in part:
        assert_true(row['bits'] in rmap, f"row map missing bits {row['bits']}")
        assert_true(rmap[row['bits']]['index'] == row['index'], "row map index mismatch")


def test_uniform_x_matches_dyadic():
    """Verify that uniform_x partition agrees with the legacy dyadic_cell_* helpers."""
    depth = 4
    part = build_partition(depth, kind='uniform_x')
    tol = HiR(10)^(-50)

    for row in part:
        dy_lo, dy_hi = dyadic_cell_bounds(row['bits'])
        assert_true(
            abs(row['x_lo'] - dy_lo) < tol,
            f"uniform_x x_lo disagrees with dyadic at cell {row['index']}",
        )
        assert_true(
            abs(row['x_hi'] - dy_hi) < tol,
            f"uniform_x x_hi disagrees with dyadic at cell {row['index']}",
        )

        dy_plo, dy_phi = dyadic_cell_plog(row['bits'])
        assert_true(
            abs(row['plog_lo'] - HiR(dy_plo)) < tol,
            f"uniform_x plog_lo disagrees with dyadic at cell {row['index']}",
        )
        assert_true(
            abs(row['plog_hi'] - HiR(dy_phi)) < tol,
            f"uniform_x plog_hi disagrees with dyadic at cell {row['index']}",
        )


def test_arb_evaluator_oracle_d3():
    """Arbitrary-cell evaluator matches exact evaluator on uniform_x depth=3."""
    c_rat = QQ(1) / QQ(4)  # alpha=1/2 => c = (1-1/2)/2 = 1/4
    max_disc, n_cells, _ = validate_arb_against_exact(3, 1, 2, c_rat, tol=1e-12, hard_tol=1e-8)
    assert_true(n_cells == 8, f"expected 8 cells, got {n_cells}")
    assert_true(
        max_disc <= 1e-12,
        f"arb evaluator oracle discrepancy {max_disc:.2e} exceeds 1e-12 at depth=3",
    )


def test_arb_evaluator_oracle_d5():
    """Arbitrary-cell evaluator matches exact evaluator on uniform_x depth=5."""
    c_rat = QQ(1) / QQ(4)
    max_disc, n_cells, _ = validate_arb_against_exact(5, 1, 2, c_rat, tol=1e-12, hard_tol=1e-8)
    assert_true(n_cells == 32, f"expected 32 cells, got {n_cells}")
    assert_true(
        max_disc <= 1e-12,
        f"arb evaluator oracle discrepancy {max_disc:.2e} exceeds 1e-12 at depth=5",
    )


def test_arb_evaluator_oracle_varied_c():
    """Oracle validation with an optimized intercept, not just the centered default."""
    _, paths, _ = residue_paths(1, 3)
    best = best_single_intercept(paths, 1, 2)
    c_rat = best["c0_rat"]
    max_disc, n_cells, _ = validate_arb_against_exact(3, 1, 2, c_rat, tol=1e-12, hard_tol=1e-8)
    assert_true(
        max_disc <= 1e-12,
        f"arb evaluator oracle discrepancy {max_disc:.2e} with optimized c at depth=3",
    )


def test_d_candidate_validity():
    """D-candidates that pass containment also pass floor(u)=k."""
    alpha_q = QQ(1) / QQ(2)
    c = QQ(1) / QQ(4)
    depth = 4
    partition = build_partition(depth, kind='uniform_x')

    for row in partition:
        breakpoints = cell_breakpoints_arb(row['plog_lo'], row['plog_hi'], 1, 2, c)
        for i in range(len(breakpoints) - 1):
            seg_lo = breakpoints[i]
            seg_hi = breakpoints[i + 1]
            seg_mid_hi = (HiR(seg_lo) + HiR(seg_hi)) / 2
            u_mid = HiR(c) - HiR(alpha_q) * seg_mid_hi
            k = Integer(floor(u_mid))
            xp_D = (c - QQ(k)) / (1 + alpha_q)
            if HiR(seg_lo) < HiR(xp_D) < HiR(seg_hi):
                assert_true(
                    _d_candidate_valid(xp_D, k, 1, 2, c),
                    f"D-candidate at plog={float(xp_D)} failed floor(u)=k "
                    f"on cell {row['index']} segment {i}",
                )


def test_arb_evaluator_geometric_smoke():
    """Arbitrary-cell evaluator runs on geometric_x cells without error."""
    c_rat = QQ(1) / QQ(4)
    depth = 4
    partition = build_partition(depth, kind='geometric_x')

    for row in partition:
        zmin, zmax, worst, ratio, meta = cell_logerr_arb(
            row['plog_lo'], row['plog_hi'], 1, 2, c_rat
        )
        assert_true(worst >= 0, f"negative worst on geometric_x cell {row['index']}")
        assert_true(ratio >= 0, f"negative ratio on geometric_x cell {row['index']}")
        assert_true(meta['n_candidates'] >= 2, f"too few candidates on cell {row['index']}")


def test_arb_concavity_boundary_min():
    """On representative segments, worst negative excursion is at boundary, not D."""
    c_rat = QQ(1) / QQ(4)
    depth = 4
    partition = build_partition(depth, kind='uniform_x')

    for row in partition:
        _, _, _, _, meta = cell_logerr_arb(
            row['plog_lo'], row['plog_hi'], 1, 2, c_rat
        )
        d_vals = [v for _, v, t in meta['candidates'] if t == 'D']
        non_d_vals = [v for _, v, t in meta['candidates'] if t != 'D']

        if not d_vals:
            continue

        min_d = min(d_vals)
        min_non_d = min(non_d_vals)
        assert_true(
            min_d > min_non_d + 1e-12,
            f"D-candidate realizes the worst negative excursion on cell {row['index']}: "
            f"min_d={min_d:.15e}, min_non_d={min_non_d:.15e}",
        )


def test_arb_meta_reports_x_and_plog():
    """Arbitrary-cell metadata should report worst candidate in both x and plog."""
    c_rat = QQ(1) / QQ(4)
    row = build_partition(4, kind='geometric_x')[5]
    _, _, _, _, meta = cell_logerr_arb(row['plog_lo'], row['plog_hi'], 1, 2, c_rat)

    assert_true('worst_x' in meta, "meta should expose worst_x")
    assert_true('worst_plog' in meta, "meta should expose worst_plog")
    assert_true(
        abs(meta['worst_x'] - (1.0 + meta['worst_plog'])) < 1e-12,
        "worst_x and worst_plog should satisfy x = 1 + plog on [1,2)",
    )
    assert_true(
        float(row['x_lo']) - 1e-12 <= meta['worst_x'] <= float(row['x_hi']) + 1e-12,
        "worst_x should lie inside the cell bounds",
    )


def test_minimax_uniform_x_partition():
    """Minimax with explicit uniform_x partition converges and has partition metadata."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='uniform_x')

    assert_true(opt["converged"], "uniform_x partition minimax should converge")
    assert_true(opt["worst_err"] > 0, "worst_err should be positive")
    assert_true(opt.get("partition_kind") == 'uniform_x', "result should report partition_kind")
    assert_true("worst_cell_bits" in opt, "result should have worst_cell_bits")


def test_minimax_geometric_x_smoke():
    """Minimax with geometric_x partition converges."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='geometric_x')

    assert_true(opt["converged"], "geometric_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "geometric_x worst_err should be positive")
    assert_true(opt.get("partition_kind") == 'geometric_x', "result should report geometric_x")
    assert_true("worst_cell_bits" in opt, "result should have worst_cell metadata")
    assert_true("worst_cell_index" in opt, "result should have worst_cell_index")
    assert_true("worst_cell_x_lo" in opt, "result should have worst_cell_x_lo")


def test_geometric_x_above_free_bound():
    """Geometric_x minimax stays above the free-per-cell bound."""
    q, depth = 1, 3
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='geometric_x')
    free_worst, _ = free_per_cell_optimum(depth, 1, 2, partition_kind='geometric_x')
    assert_true(
        opt["worst_err"] >= free_worst - 1e-8,
        f"geometric_x minimax ({opt['worst_err']:.8f}) should be >= "
        f"free-per-cell bound ({free_worst:.8f})",
    )


def test_partition_aware_best_single():
    """best_single_intercept works with partition_kind."""
    _, paths, _ = residue_paths(1, 3)
    best_legacy = best_single_intercept(paths, 1, 2)
    best_uniform = best_single_intercept(paths, 1, 2, partition_kind='uniform_x')
    best_geometric = best_single_intercept(paths, 1, 2, partition_kind='geometric_x')

    # uniform_x should agree closely with legacy
    assert_true(
        abs(best_legacy["worst_abs"] - best_uniform["worst_abs"]) < 1e-10,
        "partition-aware uniform_x best_single should match legacy",
    )
    # geometric should produce a finite positive result
    assert_true(
        best_geometric["worst_abs"] > 0,
        "geometric_x best_single should have positive error",
    )
    assert_true(
        best_geometric.get("partition_kind") == 'geometric_x',
        "result should report partition_kind",
    )


def main():
    tests = [
        ("bits_index_roundtrip", test_bits_index_roundtrip),
        ("uniform_x_partition", test_uniform_x_partition),
        ("geometric_x_partition", test_geometric_x_partition),
        ("partition_row_map", test_partition_row_map),
        ("uniform_x_matches_dyadic", test_uniform_x_matches_dyadic),
        ("arb_evaluator_oracle_d3", test_arb_evaluator_oracle_d3),
        ("arb_evaluator_oracle_d5", test_arb_evaluator_oracle_d5),
        ("arb_evaluator_oracle_varied_c", test_arb_evaluator_oracle_varied_c),
        ("d_candidate_validity", test_d_candidate_validity),
        ("arb_evaluator_geometric_smoke", test_arb_evaluator_geometric_smoke),
        ("arb_concavity_boundary_min", test_arb_concavity_boundary_min),
        ("arb_meta_reports_x_and_plog", test_arb_meta_reports_x_and_plog),
        ("minimax_uniform_x_partition", test_minimax_uniform_x_partition),
        ("minimax_geometric_x_smoke", test_minimax_geometric_x_smoke),
        ("geometric_x_above_free_bound", test_geometric_x_above_free_bound),
        ("partition_aware_best_single", test_partition_aware_best_single),
        ("residue_paths", test_residue_paths),
        ("global_metrics_and_best_single", test_global_metrics_and_best_single),
        ("active_pattern_family", test_active_pattern_family),
        ("exact_combinatorics", test_exact_combinatorics),
        ("optimizer_smoke", test_optimizer_smoke),
        ("minimax_smoke", test_minimax_smoke),
        ("minimax_beats_nelder_mead", test_minimax_beats_nelder_mead),
        ("minimax_above_free_bound", test_minimax_above_free_bound),
        ("layer_dependent_smoke", test_layer_dependent_smoke),
        ("layer_dependent_beats_invariant", test_layer_dependent_beats_invariant),
        ("layer_dependent_above_free_bound", test_layer_dependent_above_free_bound),
    ]

    print("=" * 80)
    print("smale test suite")
    print("=" * 80)

    for name, fn in tests:
        fn()
        print(f"[ok] {name}")

    print("=" * 80)
    print(f"passed {len(tests)} tests")
    print("=" * 80)


main()
