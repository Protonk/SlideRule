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


def test_harmonic_x_partition():
    depth = 4
    part = build_partition(depth, kind='harmonic_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)

    # Contiguity
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"harmonic_x contiguity gap at j={j}",
        )

    # Covers [1, 2)
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "harmonic_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "harmonic_x should end at 2")

    # Reciprocal spacing is finer near x=1 and wider near x=2.
    assert_true(
        part[-1]['width_x'] > part[0]['width_x'],
        "harmonic_x cells should be wider near x=2 than near x=1",
    )

    # Descriptive alias should resolve to the same geometry.
    alias_part = build_partition(depth, kind='reciprocal_x')
    for j in range(N):
        assert_true(
            abs(part[j]['x_lo'] - alias_part[j]['x_lo']) < tol
            and abs(part[j]['x_hi'] - alias_part[j]['x_hi']) < tol,
            f"reciprocal_x alias mismatch at j={j}",
        )

    # bits match index
    for row in part:
        assert_true(
            bits_to_index(row['bits']) == row['index'],
            f"harmonic_x cell {row['index']} bits mismatch",
        )


def test_mirror_harmonic_x_partition():
    depth = 4
    part = build_partition(depth, kind='mirror_harmonic_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)

    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"mirror_harmonic_x contiguity gap at j={j}",
        )

    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "mirror_harmonic_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "mirror_harmonic_x should end at 2")

    # Mirrored reciprocal spacing is wider near x=1 and finer near x=2.
    assert_true(
        part[0]['width_x'] > part[-1]['width_x'],
        "mirror_harmonic_x cells should be wider near x=1 than near x=2",
    )

    alias_part = build_partition(depth, kind='mirror_reciprocal_x')
    for j in range(N):
        assert_true(
            abs(part[j]['x_lo'] - alias_part[j]['x_lo']) < tol
            and abs(part[j]['x_hi'] - alias_part[j]['x_hi']) < tol,
            f"mirror_reciprocal_x alias mismatch at j={j}",
        )


def test_minimax_harmonic_x_smoke():
    """Minimax with harmonic_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='harmonic_x')

    assert_true(opt["converged"], "harmonic_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "harmonic_x worst_err should be positive")
    assert_true(opt.get("partition_kind") == 'harmonic_x', "result should report harmonic_x")
    assert_true("worst_cell_bits" in opt, "result should have worst_cell metadata")
    assert_true("worst_cell_index" in opt, "result should have worst_cell_index")


def test_minimax_mirror_harmonic_x_smoke():
    """Minimax with mirror_harmonic_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='mirror_harmonic_x')

    assert_true(opt["converged"], "mirror_harmonic_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "mirror_harmonic_x worst_err should be positive")
    assert_true(
        opt.get("partition_kind") == 'mirror_harmonic_x',
        "result should report mirror_harmonic_x",
    )
    assert_true("worst_cell_bits" in opt, "result should have worst_cell metadata")
    assert_true("worst_cell_index" in opt, "result should have worst_cell_index")


def test_ruler_x_partition():
    """Ruler partition: contiguity, covers [1,2), widths follow 2-adic valuation."""
    depth = 4
    part = build_partition(depth, kind='ruler_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"ruler_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "ruler_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "ruler_x should end at 2")

    # Cell 0 (j+1=1, v2=0) should be widest; cell N-1 (j+1=N, v2=depth) narrowest.
    widths = [float(r['width_x']) for r in part]
    assert_true(widths[0] == max(widths), "ruler_x cell 0 should be widest")
    assert_true(widths[-1] == min(widths), "ruler_x cell N-1 should be narrowest")

    # Width ratios should be powers of 2.
    w0 = widths[0]
    for j in range(N):
        ratio = w0 / widths[j]
        log_ratio = round(float(log(ratio, 2)))
        assert_true(
            abs(ratio - 2**log_ratio) < 1e-10,
            f"ruler_x width ratio at j={j} is not a power of 2: {ratio}",
        )


def test_sinusoidal_x_partition():
    """Sinusoidal partition: contiguity, covers [1,2), widths oscillate."""
    depth = 4
    part = build_partition(depth, kind='sinusoidal_x', sin_k=3, sin_alpha=0.6)
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-10)   # bisection gives ~18 digits, not exact arithmetic
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"sinusoidal_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "sinusoidal_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "sinusoidal_x should end at 2")

    # Widths should NOT be monotone (oscillating density).
    widths = [float(r['width_x']) for r in part]
    diffs = [widths[j+1] - widths[j] for j in range(len(widths) - 1)]
    has_increase = any(d > 0 for d in diffs)
    has_decrease = any(d < 0 for d in diffs)
    assert_true(has_increase and has_decrease,
                "sinusoidal_x widths should oscillate (not monotone)")

    # alpha=0 should recover geometric (uniform in log-space).
    part0 = build_partition(depth, kind='sinusoidal_x', sin_k=3, sin_alpha=0.0)
    geo = build_partition(depth, kind='geometric_x')
    for j in range(N):
        assert_true(
            abs(float(part0[j]['width_x']) - float(geo[j]['width_x'])) < 1e-10,
            f"sinusoidal_x with alpha=0 should match geometric at j={j}",
        )


def test_minimax_ruler_x_smoke():
    """Minimax with ruler_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='ruler_x')
    assert_true(opt["converged"], "ruler_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "ruler_x worst_err should be positive")


def test_minimax_sinusoidal_x_smoke():
    """Minimax with sinusoidal_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='sinusoidal_x')
    assert_true(opt["converged"], "sinusoidal_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "sinusoidal_x worst_err should be positive")


def test_chebyshev_x_partition():
    """Chebyshev partition: contiguity, covers [1,2), dense at both endpoints."""
    depth = 4
    part = build_partition(depth, kind='chebyshev_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"chebyshev_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "chebyshev_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "chebyshev_x should end at 2")

    # Cells at endpoints should be narrower than cells in the middle.
    mid = N // 2
    assert_true(
        part[0]['width_x'] < part[mid]['width_x'],
        "chebyshev_x: first cell should be narrower than middle cell",
    )
    assert_true(
        part[-1]['width_x'] < part[mid]['width_x'],
        "chebyshev_x: last cell should be narrower than middle cell",
    )


def test_minimax_chebyshev_x_smoke():
    """Minimax with chebyshev_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='chebyshev_x')
    assert_true(opt["converged"], "chebyshev_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "chebyshev_x worst_err should be positive")


def test_thuemorse_x_partition():
    """Thue-Morse partition: contiguity, covers [1,2), exactly two distinct widths."""
    depth = 4
    part = build_partition(depth, kind='thuemorse_x', tm_ratio=2)
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"thuemorse_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "thuemorse_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "thuemorse_x should end at 2")

    # Exactly two distinct widths with ratio tm_ratio.
    widths = sorted(set(float(r['width_x']) for r in part))
    assert_true(len(widths) == 2, f"thuemorse_x should have 2 distinct widths, got {len(widths)}")
    ratio = widths[1] / widths[0]
    assert_true(
        abs(ratio - 2.0) < 1e-10,
        f"thuemorse_x width ratio should be 2:1, got {ratio}",
    )


def test_minimax_thuemorse_x_smoke():
    """Minimax with thuemorse_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='thuemorse_x')
    assert_true(opt["converged"], "thuemorse_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "thuemorse_x worst_err should be positive")


def test_bitrev_geometric_x_partition():
    """Bitrev-geometric partition: contiguity, covers [1,2), same width multiset as geometric."""
    depth = 4
    part = build_partition(depth, kind='bitrev_geometric_x')
    geo = build_partition(depth, kind='geometric_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"bitrev_geometric_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "bitrev_geometric_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "bitrev_geometric_x should end at 2")

    # Same multiset of widths as geometric (sorted widths should match).
    br_widths = sorted(float(r['width_x']) for r in part)
    geo_widths = sorted(float(r['width_x']) for r in geo)
    for j in range(N):
        assert_true(
            abs(br_widths[j] - geo_widths[j]) < 1e-12,
            f"bitrev_geometric_x sorted width mismatch at j={j}",
        )

    # But the order should differ (not identical to geometric).
    order_differs = any(
        abs(float(part[j]['width_x']) - float(geo[j]['width_x'])) > 1e-12
        for j in range(N)
    )
    assert_true(order_differs, "bitrev_geometric_x should differ in cell order from geometric")


def test_minimax_bitrev_geometric_x_smoke():
    """Minimax with bitrev_geometric_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='bitrev_geometric_x')
    assert_true(opt["converged"], "bitrev_geometric_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "bitrev_geometric_x worst_err should be positive")


def test_stern_brocot_x_partition():
    """Stern-Brocot partition: contiguity, covers [1,2), known depth-2 boundaries."""
    depth = 4
    part = build_partition(depth, kind='stern_brocot_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"stern_brocot_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "stern_brocot_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "stern_brocot_x should end at 2")

    # All boundaries should be rationals.
    for row in part:
        # HiR values from QQ should be exact rationals.
        x_lo_f = float(row['x_lo'])
        assert_true(x_lo_f > 0, f"stern_brocot_x cell {row['index']} has non-positive x_lo")

    # Known depth-2 boundaries: [1, 4/3, 3/2, 5/3, 2].
    part2 = build_partition(2, kind='stern_brocot_x')
    expected = [QQ(1), QQ(4)/QQ(3), QQ(3)/QQ(2), QQ(5)/QQ(3), QQ(2)]
    boundaries = [part2[0]['x_lo']] + [r['x_hi'] for r in part2]
    for j in range(5):
        assert_true(
            abs(boundaries[j] - HiR(expected[j])) < tol,
            f"stern_brocot_x depth-2 boundary {j}: expected {expected[j]}, "
            f"got {float(boundaries[j])}",
        )


def test_minimax_stern_brocot_x_smoke():
    """Minimax with stern_brocot_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='stern_brocot_x')
    assert_true(opt["converged"], "stern_brocot_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "stern_brocot_x worst_err should be positive")


def test_reverse_geometric_x_partition():
    """Reverse geometric: contiguity, covers [1,2), widths increase left to right."""
    depth = 4
    part = build_partition(depth, kind='reverse_geometric_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"reverse_geometric_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "reverse_geometric_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "reverse_geometric_x should end at 2")

    # Widths should decrease (opposite of geometric, which increases).
    widths = [float(r['width_x']) for r in part]
    for j in range(N - 1):
        assert_true(widths[j] > widths[j + 1],
                    f"reverse_geometric_x widths should decrease at j={j}")


def test_minimax_reverse_geometric_x_smoke():
    """Minimax with reverse_geometric_x converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='reverse_geometric_x')
    assert_true(opt["converged"], "reverse_geometric_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "reverse_geometric_x worst_err should be positive")


def test_random_x_partition():
    """Random partition: contiguity, covers [1,2), deterministic with fixed seed."""
    depth = 4
    part = build_partition(depth, kind='random_x', random_seed=42)
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-10)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"random_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "random_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "random_x should end at 2")

    # Deterministic: same seed gives same partition.
    part2 = build_partition(depth, kind='random_x', random_seed=42)
    for j in range(N):
        assert_true(
            abs(float(part[j]['width_x']) - float(part2[j]['width_x'])) < 1e-14,
            f"random_x should be deterministic at j={j}",
        )


def test_minimax_random_x_smoke():
    """Minimax with random_x converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='random_x')
    assert_true(opt["converged"], "random_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "random_x worst_err should be positive")


def test_dyadic_x_partition():
    """Dyadic partition: contiguity, covers [1,2), all boundaries are dyadic rationals."""
    depth = 4
    part = build_partition(depth, kind='dyadic_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-10)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"dyadic_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "dyadic_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "dyadic_x should end at 2")

    # All interior boundaries should be dyadic rationals (denominator is power of 2).
    R = depth + 4
    scale = 2**R
    for j in range(1, N):
        val = float(part[j]['x_lo'])
        snapped = round(val * scale) / scale
        assert_true(
            abs(val - snapped) < 1e-12,
            f"dyadic_x boundary at j={j} is not dyadic: {val}",
        )


def test_minimax_dyadic_x_smoke():
    """Minimax with dyadic_x converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='dyadic_x')
    assert_true(opt["converged"], "dyadic_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "dyadic_x worst_err should be positive")


def test_powerlaw_x_partition():
    """Power-law partition: contiguity, covers [1,2), first cell narrower than last."""
    depth = 4
    part = build_partition(depth, kind='powerlaw_x', pl_exponent=3)
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-10)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"powerlaw_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "powerlaw_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "powerlaw_x should end at 2")

    # Aggressive left-packing: first cell much narrower than last.
    assert_true(
        float(part[0]['width_x']) < float(part[-1]['width_x']),
        "powerlaw_x: first cell should be narrower than last cell",
    )
    # Check ratio is substantial (p=3 should give big difference).
    ratio = float(part[-1]['width_x']) / float(part[0]['width_x'])
    assert_true(ratio > 5, f"powerlaw_x width ratio should be large, got {ratio:.1f}")


def test_minimax_powerlaw_x_smoke():
    """Minimax with powerlaw_x converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='powerlaw_x')
    assert_true(opt["converged"], "powerlaw_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "powerlaw_x worst_err should be positive")


def test_golden_x_partition():
    """Golden-ratio partition: contiguity, covers [1,2), N-1 distinct interior points."""
    depth = 4
    part = build_partition(depth, kind='golden_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-10)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"golden_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "golden_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "golden_x should end at 2")

    # Widths should be non-uniform (multiple distinct values).
    widths = [round(float(r['width_x']), 12) for r in part]
    assert_true(
        len(set(widths)) > 1,
        "golden_x should have non-uniform widths",
    )

    # Widths should be non-monotone (quasi-random scattering).
    raw_widths = [float(r['width_x']) for r in part]
    diffs = [raw_widths[j+1] - raw_widths[j] for j in range(len(raw_widths) - 1)]
    has_inc = any(d > 1e-15 for d in diffs)
    has_dec = any(d < -1e-15 for d in diffs)
    assert_true(has_inc and has_dec,
                "golden_x widths should be non-monotone")


def test_minimax_golden_x_smoke():
    """Minimax with golden_x converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='golden_x')
    assert_true(opt["converged"], "golden_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "golden_x worst_err should be positive")


def test_cantor_x_partition():
    """Cantor dust partition: contiguity, covers [1,2), non-monotone widths."""
    depth = 4
    part = build_partition(depth, kind='cantor_x', cantor_levels=3)
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-10)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"cantor_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "cantor_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "cantor_x should end at 2")

    # Widths should be non-monotone (clustered structure with gaps).
    widths = [float(r['width_x']) for r in part]
    diffs = [widths[j+1] - widths[j] for j in range(len(widths) - 1)]
    has_increase = any(d > 1e-15 for d in diffs)
    has_decrease = any(d < -1e-15 for d in diffs)
    assert_true(has_increase and has_decrease,
                "cantor_x widths should be non-monotone")


def test_minimax_cantor_x_smoke():
    """Minimax with cantor_x converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='cantor_x')
    assert_true(opt["converged"], "cantor_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "cantor_x worst_err should be positive")


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


def test_nondefault_domain_partition():
    """Partition on [2, 4) — all sixteen kinds cover the domain contiguously."""
    depth = 3
    N = 2^depth
    tol = HiR(10)^(-10)  # relaxed for float-based partitions
    xs, xw = 2, 2  # domain [2, 4)

    for kind in PARTITION_KINDS:
        part = build_partition(depth, kind=kind, x_start=xs, x_width=xw)
        assert_true(len(part) == N, f"{kind} [2,4): expected {N} cells")
        assert_true(
            abs(part[0]['x_lo'] - HiR(xs)) < tol,
            f"{kind} [2,4): should start at {xs}",
        )
        assert_true(
            abs(part[-1]['x_hi'] - HiR(xs + xw)) < tol,
            f"{kind} [2,4): should end at {xs + xw}",
        )
        for j in range(N - 1):
            assert_true(
                abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
                f"{kind} [2,4): contiguity gap at j={j}",
            )
        # x_start and x_width stored in rows
        assert_true(
            abs(part[0]['x_start'] - HiR(xs)) < tol,
            f"{kind}: x_start not stored",
        )
        assert_true(
            abs(part[0]['x_width'] - HiR(xw)) < tol,
            f"{kind}: x_width not stored",
        )


def test_nondefault_domain_evaluator():
    """D-candidate and evaluator work on [2, 4) with uniform_x."""
    depth = 3
    xs, xw = 2, 2
    p_num, q_den = 1, 2
    alpha_q = QQ(p_num) / QQ(q_den)
    c0 = default_c0(alpha_q, xw)

    part = build_partition(depth, kind='uniform_x', x_start=xs, x_width=xw)
    for row in part:
        zmin, zmax, worst, ratio, meta = cell_logerr_arb(
            row['plog_lo'], row['plog_hi'], p_num, q_den, c0,
            x_start=xs)
        assert_true(worst >= 0, f"cell {row['index']}: negative worst error")
        assert_true(
            meta['worst_x'] >= xs and meta['worst_x'] <= xs + xw,
            f"cell {row['index']}: worst_x outside domain",
        )


def test_nondefault_domain_minimax():
    """Minimax optimizer converges on [2, 4) with geometric_x."""
    q, depth = 3, 3
    p_num, q_den = 1, 2
    xs, xw = 2, 2

    result = optimize_minimax(
        q, depth, p_num, q_den,
        partition_kind='geometric_x',
        x_start=xs, x_width=xw,
    )
    assert_true(result['converged'], "minimax on [2,4) should converge")
    assert_true(result['worst_err'] > 0, "minimax on [2,4) should have positive error")

    # Free-per-cell bound should also work
    free_worst, _ = free_per_cell_optimum(
        depth, p_num, q_den,
        partition_kind='geometric_x',
        x_start=xs, x_width=xw,
    )
    assert_true(free_worst > 0, "free-per-cell on [2,4) should have positive error")
    assert_true(
        result['worst_err'] >= free_worst - 1e-8,
        "minimax should be >= free-per-cell bound on [2,4)",
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
        ("harmonic_x_partition", test_harmonic_x_partition),
        ("mirror_harmonic_x_partition", test_mirror_harmonic_x_partition),
        ("minimax_harmonic_x_smoke", test_minimax_harmonic_x_smoke),
        ("minimax_mirror_harmonic_x_smoke", test_minimax_mirror_harmonic_x_smoke),
        ("ruler_x_partition", test_ruler_x_partition),
        ("sinusoidal_x_partition", test_sinusoidal_x_partition),
        ("minimax_ruler_x_smoke", test_minimax_ruler_x_smoke),
        ("minimax_sinusoidal_x_smoke", test_minimax_sinusoidal_x_smoke),
        ("chebyshev_x_partition", test_chebyshev_x_partition),
        ("minimax_chebyshev_x_smoke", test_minimax_chebyshev_x_smoke),
        ("thuemorse_x_partition", test_thuemorse_x_partition),
        ("minimax_thuemorse_x_smoke", test_minimax_thuemorse_x_smoke),
        ("bitrev_geometric_x_partition", test_bitrev_geometric_x_partition),
        ("minimax_bitrev_geometric_x_smoke", test_minimax_bitrev_geometric_x_smoke),
        ("stern_brocot_x_partition", test_stern_brocot_x_partition),
        ("minimax_stern_brocot_x_smoke", test_minimax_stern_brocot_x_smoke),
        ("reverse_geometric_x_partition", test_reverse_geometric_x_partition),
        ("minimax_reverse_geometric_x_smoke", test_minimax_reverse_geometric_x_smoke),
        ("random_x_partition", test_random_x_partition),
        ("minimax_random_x_smoke", test_minimax_random_x_smoke),
        ("dyadic_x_partition", test_dyadic_x_partition),
        ("minimax_dyadic_x_smoke", test_minimax_dyadic_x_smoke),
        ("powerlaw_x_partition", test_powerlaw_x_partition),
        ("minimax_powerlaw_x_smoke", test_minimax_powerlaw_x_smoke),
        ("golden_x_partition", test_golden_x_partition),
        ("minimax_golden_x_smoke", test_minimax_golden_x_smoke),
        ("cantor_x_partition", test_cantor_x_partition),
        ("minimax_cantor_x_smoke", test_minimax_cantor_x_smoke),
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
        ("nondefault_domain_partition", test_nondefault_domain_partition),
        ("nondefault_domain_evaluator", test_nondefault_domain_evaluator),
        ("nondefault_domain_minimax", test_nondefault_domain_minimax),
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
