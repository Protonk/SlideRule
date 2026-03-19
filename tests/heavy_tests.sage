"""
Heavy tests — expensive checks kept out of the fast test suite.

Run from project root:  ./sagew tests/heavy_tests.sage
"""

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))

from math import log, log2 as math_log2
from scipy import integrate


# ── Reference (quad-based) implementation ────────────────────────────

def _quad_cell_area(a, b):
    """Coastline area for one cell via adaptive quadrature."""
    sigma = (math_log2(b) - math_log2(a)) / (b - a)
    area, _ = integrate.quad(
        lambda m: abs(1.0 / (m * log(2.0)) - sigma), a, b)
    return area


def _quad_coastline_area(depth, kind):
    """Coastline area via adaptive quadrature (reference implementation)."""
    cells = float_cells(depth, kind)
    return sum(_quad_cell_area(a, b) for a, b in cells)


# ── Load the production implementation ───────────────────────────────

load(pathing('experiments', 'ripple', 'coastline.sage'))


# ── Test helpers ─────────────────────────────────────────────────────

def assert_true(condition, message):
    if not condition:
        raise AssertionError(message)


def assert_close(lhs, rhs, tol, message):
    if abs(lhs - rhs) > tol:
        raise AssertionError(f"{message}: lhs={lhs}, rhs={rhs}, diff={abs(lhs-rhs):.2e}, tol={tol}")


# ── Tests ────────────────────────────────────────────────────────────

def test_coastline_area_vs_quad_all_kinds_depth4():
    """Compare production coastline_area against quad reference at depth 4."""
    tol = 5e-8
    for name, _, kind in PARTITION_ZOO:
        prod = coastline_area(4, kind)
        ref = _quad_coastline_area(4, kind)
        assert_close(prod, ref, tol,
                     f"coastline_area mismatch at depth=4, kind={kind}")


def test_coastline_area_vs_quad_all_kinds_depth7():
    """Compare production coastline_area against quad reference at depth 7."""
    tol = 5e-8
    for name, _, kind in PARTITION_ZOO:
        prod = coastline_area(7, kind)
        ref = _quad_coastline_area(7, kind)
        assert_close(prod, ref, tol,
                     f"coastline_area mismatch at depth=7, kind={kind}")


def test_coastline_area_vs_quad_depth_sweep():
    """Compare production vs quad across depths 1-8 for a representative subset."""
    tol = 5e-8
    subset = ['uniform_x', 'geometric_x', 'stern_brocot_x', 'ruler_x',
              'minimax_chord_x', 'cantor_x', 'random_x']
    for depth in range(1, 9):
        for kind in subset:
            prod = coastline_area(depth, kind)
            ref = _quad_coastline_area(depth, kind)
            assert_close(prod, ref, tol,
                         f"coastline_area mismatch at depth={depth}, kind={kind}")


def test_coastline_area_positivity():
    """Coastline area should be strictly positive for all kinds and depths."""
    for depth in range(1, 9):
        for _, _, kind in PARTITION_ZOO:
            area = coastline_area(depth, kind)
            assert_true(area > 0,
                        f"non-positive area at depth={depth}, kind={kind}: {area}")


def test_coastline_area_geometric_decreases():
    """For geometric_x, area should decrease with depth (cells get better)."""
    prev = coastline_area(1, 'geometric_x')
    for depth in range(2, 9):
        curr = coastline_area(depth, 'geometric_x')
        assert_true(curr < prev,
                    f"geometric area not decreasing: depth {depth-1}={prev}, depth {depth}={curr}")
        prev = curr


# ── Runner ───────────────────────────────────────────────────────────

def main():
    tests = [
        ("coastline_vs_quad_all_kinds_d4", test_coastline_area_vs_quad_all_kinds_depth4),
        ("coastline_vs_quad_all_kinds_d7", test_coastline_area_vs_quad_all_kinds_depth7),
        ("coastline_vs_quad_depth_sweep", test_coastline_area_vs_quad_depth_sweep),
        ("coastline_positivity", test_coastline_area_positivity),
        ("coastline_geometric_decreases", test_coastline_area_geometric_decreases),
    ]

    print("=" * 80)
    print("heavy tests")
    print("=" * 80)

    passed = 0
    for name, fn in tests:
        try:
            fn()
            print(f"[ok] {name}")
            passed += 1
        except Exception as exc:
            print(f"[FAIL] {name}: {exc}")

    print("=" * 80)
    print(f"passed {passed}/{len(tests)} tests")
    print("=" * 80)


main()
