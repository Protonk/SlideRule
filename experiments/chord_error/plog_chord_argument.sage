"""
plog_chord_argument.sage — A pseudo-log chord error argument in three stages.

An exact symbolic argument establishing three facts about the approximation
error of plog(m) = m - 1 on the octave [1, 2]:

  1. The error eps(m) = log_2(m) - (m - 1) has a completely analyzable
     shape: concave, zero at both endpoints, unique peak at m* = 1/ln 2.

  2. The curvature |eps''(m)| = 1/(m^2 ln 2) is front-loaded: exactly 2/3
     of the total curvature integral lives in the left half [1, 3/2].

  3. When we subdivide [1, 2] into cells and use per-cell chords of log_2,
     the error object changes.  The per-cell chord error shares the same
     second derivative as the global error (it is a property of log_2, not
     of the chord), but has a different slope, a different peak location,
     and a different peak value on every cell.

Run from :  ./sagew experiments/chord_error/plog_chord_argument.sage
"""


# ══════════════════════════════════════════════════════════════════════
#  Stage 1.  The global pseudo-log error on [1, 2]
# ══════════════════════════════════════════════════════════════════════

def stage_1():
    print("=" * 72)
    print("Stage 1.  The global pseudo-log error on [1, 2]")
    print("=" * 72)
    print()

    var('m')

    log2_m = log(m) / log(2)
    plog_m = m - 1

    # The pseudo-log is the chord of log_2 at the octave endpoints.
    # Verify: plog(1) = log_2(1) = 0,  plog(2) = log_2(2) = 1.

    print("plog(m) = m - 1 is the chord of log_2(m) on [1, 2].")
    print()
    print("Verification:")
    print(f"  plog(1) = {plog_m.subs(m=1)},  log_2(1) = {log2_m.subs(m=1)}")
    print(f"  plog(2) = {plog_m.subs(m=2)},  log_2(2) = {log2_m.subs(m=2)}")
    print()

    # The error function.
    eps = log2_m - plog_m

    # It vanishes at both endpoints because plog IS the chord.
    eps_at_1 = eps.subs(m=1).simplify_full()
    eps_at_2 = eps.subs(m=2).simplify_full()
    assert eps_at_1 == 0, f"eps(1) = {eps_at_1}, expected 0"
    assert eps_at_2 == 0, f"eps(2) = {eps_at_2}, expected 0"

    print("The error is")
    print(f"  eps(m) = log_2(m) - (m - 1)")
    print(f"  eps(1) = {eps_at_1}")
    print(f"  eps(2) = {eps_at_2}")
    print()

    # Derivatives.
    eps1 = diff(eps, m).simplify_full()
    eps2 = diff(eps, m, 2).simplify_full()

    print("Derivatives:")
    print(f"  eps'(m)  = {eps1}")
    print(f"  eps''(m) = {eps2}")
    print()

    # eps'' < 0 on (0, inf), hence on [1, 2].
    # Check at endpoints to make the claim concrete.
    eps2_at_1 = eps2.subs(m=1).simplify_full()
    eps2_at_2 = eps2.subs(m=2).simplify_full()

    print(f"  eps''(1) = {eps2_at_1}")
    print(f"  eps''(2) = {eps2_at_2}")
    print()
    print("eps''(m) = -1/(m^2 log(2)) < 0 for all m > 0.")
    print("So eps is strictly concave on [1, 2], and its stationary")
    print("point is the unique interior maximum.")
    print()

    # Find the peak: eps'(m) = 0.
    m_star = solve(eps1 == 0, m)
    assert len(m_star) == 1, f"expected unique solution, got {m_star}"
    m_star = m_star[0].rhs()

    eps_peak = eps.subs(m=m_star).simplify_full()

    print(f"  m*      = {m_star}")
    print(f"  eps(m*) = {eps_peak}")
    print()

    # Verify m* is in (1, 2).
    assert bool(m_star > 1), "m* should be > 1"
    assert bool(m_star < 2), "m* should be < 2"
    print(f"  1 < m* < 2: verified (m* = 1/log(2) and log(2) in (0, 1)).")
    print()

    return eps, eps1, eps2, m_star, eps_peak


# ══════════════════════════════════════════════════════════════════════
#  Stage 2.  Curvature is front-loaded
# ══════════════════════════════════════════════════════════════════════

def stage_2(eps2):
    print()
    print("=" * 72)
    print("Stage 2.  Curvature is front-loaded")
    print("=" * 72)
    print()

    var('m')

    abs_eps2 = -eps2  # eps'' < 0, so |eps''| = -eps''

    print("|eps''(m)| = 1/(m^2 log(2))")
    print()

    # Endpoint ratio.
    ratio = (abs_eps2.subs(m=1) / abs_eps2.subs(m=2)).simplify_full()
    print(f"Endpoint ratio: |eps''(1)| / |eps''(2)| = {ratio}")
    print()

    # Curvature integrals, split at the midpoint m = 3/2.
    curv_left = integrate(abs_eps2, m, 1, QQ(3)/QQ(2)).simplify_full()
    curv_right = integrate(abs_eps2, m, QQ(3)/QQ(2), 2).simplify_full()
    curv_total = (curv_left + curv_right).simplify_full()

    print("Curvature integrals (split at m = 3/2):")
    print(f"  integral_[1, 3/2] |eps''| dm   = {curv_left}")
    print(f"  integral_[3/2, 2] |eps''| dm   = {curv_right}")
    print(f"  integral_[1, 2]   |eps''| dm   = {curv_total}")
    print()

    share_left = (curv_left / curv_total).simplify_full()
    share_right = (curv_right / curv_total).simplify_full()

    print(f"Shares:")
    print(f"  left  [1, 3/2] = {share_left}")
    print(f"  right [3/2, 2] = {share_right}")
    print()

    assert share_left == QQ(2)/QQ(3), f"expected 2/3, got {share_left}"
    assert share_right == QQ(1)/QQ(3), f"expected 1/3, got {share_right}"

    print("Exactly 2/3 of the total curvature lives in the left half.")
    print()
    print("Consequence for uniform subdivision:")
    print("  For a chord interpolant on a cell of width h, the standard")
    print("  bound on the peak error is")
    print("      peak error <= (h^2 / 8) * max_cell |f''|.")
    print("  With equal h, the cells near m = 1 see 4x the curvature of")
    print("  those near m = 2, so the left cells dominate the global")
    print("  worst case while the right cells are over-resolved.")
    print()

    return abs_eps2, curv_total


# ══════════════════════════════════════════════════════════════════════
#  Stage 3.  The object changes: global error -> per-cell chord error
# ══════════════════════════════════════════════════════════════════════

def stage_3(eps2):
    print()
    print("=" * 72)
    print("Stage 3.  From global error to per-cell chord error")
    print("=" * 72)
    print()

    var('m a b')
    assume(a > 0)
    assume(b > a)

    log2_m = log(m) / log(2)

    # ── 3a. Define the per-cell chord ─────────────────────────────────

    print("Up to now we studied one object:")
    print("  eps(m) = log_2(m) - (m - 1)")
    print("the error of the global chord on the full octave [1, 2].")
    print()
    print("Now consider a cell [a, b] inside [1, 2].  The chord of")
    print("log_2 on this cell is a different linear function:")
    print()

    log2_a = log(a) / log(2)
    log2_b = log(b) / log(2)
    sigma = ((log2_b - log2_a) / (b - a)).simplify_full()

    print(f"  slope sigma(a, b) = (log_2(b) - log_2(a)) / (b - a)")
    print(f"                    = {sigma}")
    print()
    print(f"  chord_[a,b](m)    = log_2(a) + sigma * (m - a)")
    print()

    chord = log2_a + sigma * (m - a)

    # ── 3b. The per-cell error ────────────────────────────────────────

    E = (log2_m - chord).simplify_full()

    print("The per-cell chord error is")
    print(f"  E_[a,b](m) = log_2(m) - chord_[a,b](m)")
    print()

    # Verify it vanishes at both endpoints.
    E_at_a = E.subs(m=a).simplify_full()
    E_at_b = E.subs(m=b).simplify_full()

    print(f"  E_[a,b](a) = {E_at_a}")
    print(f"  E_[a,b](b) = {E_at_b}")
    assert E_at_a == 0, f"expected 0, got {E_at_a}"
    assert E_at_b == 0, f"expected 0, got {E_at_b}"
    print()

    # ── 3c. What is preserved: the second derivative ──────────────────

    E2 = diff(E, m, 2).simplify_full()

    print("What is preserved in the transition:")
    print()
    print(f"  E''_[a,b](m) = {E2}")
    print()
    print("This is the same as eps''(m).  The chord is affine, so it")
    print("vanishes under the second derivative.  The curvature of the")
    print("per-cell error is a property of log_2 alone, not of which")
    print("chord we subtract.")
    print()

    # Verify symbolically.
    global_eps2 = eps2
    assert bool(E2 == global_eps2), "E'' should equal eps''"

    print("  Verified: E''_[a,b](m) == eps''(m) for all a, b.")
    print()

    # ── 3d. What changes: the slope, the peak location, the peak value ─

    E1 = diff(E, m).simplify_full()

    print("What changes in the transition:")
    print()
    print(f"  E'_[a,b](m) = {E1}")
    print()
    print("The first derivative depends on sigma(a, b), which varies")
    print("from cell to cell.  On the full octave, sigma = 1 (the slope")
    print("of m - 1).  On a proper sub-interval, sigma != 1.")
    print()

    # Global chord slope is 1.
    sigma_global = sigma.subs({a: 1, b: 2}).simplify_full()
    print(f"  sigma(1, 2) = {sigma_global}")
    assert sigma_global == 1, f"expected 1, got {sigma_global}"
    print("  (This confirms that the global chord m - 1 has slope 1.)")
    print()

    # Peak location: E' = 0.
    peak_solutions = solve(E1 == 0, m)
    assert len(peak_solutions) == 1, f"expected unique solution, got {peak_solutions}"
    m_peak = peak_solutions[0].rhs().simplify_full()

    print("The peak of E_[a,b] is where E' = 0:")
    print(f"  m_peak = {m_peak}")
    print()
    print("Compare the global peak:")
    print(f"  m*     = 1/log(2)   (from Stage 1)")
    print(f"  m_peak = 1/(sigma * log(2))")
    print()
    print("These coincide only when sigma = 1, i.e., on the full octave.")
    print("On any proper sub-interval, the chord is steeper or shallower,")
    print("and the peak shifts accordingly.")
    print()

    # ── 3e. The peak error as a function of (a, b) ───────────────────

    E_at_peak = E.subs(m=m_peak).simplify_full()

    print("The peak error on [a, b] is:")
    print(f"  E_[a,b](m_peak) = {E_at_peak}")
    print()
    print("This depends on both a and b (through sigma).  The question")
    print("that Stage 4 answers numerically is: how does the distribution")
    print("of these per-cell peak errors depend on cell placement?")
    print()

    # ── 3f. Summary of the transition ─────────────────────────────────

    print("-" * 72)
    print("Summary of the transition")
    print("-" * 72)
    print()
    print("  Preserved:   E''_[a,b](m) = eps''(m) = -1/(m^2 log 2).")
    print("               The curvature distribution from Stage 2 still")
    print("               governs per-cell errors.")
    print()
    print("  Changed:     The chord slope sigma depends on [a, b].")
    print("               The peak location m_peak = 1/(sigma log 2)")
    print("               depends on [a, b].")
    print("               The peak error E(m_peak) depends on [a, b].")
    print()
    print("  Consequence: The curvature argument from Stage 2 correctly")
    print("               predicts *which cells are harder* (those near")
    print("               m = 1, where |eps''| is largest).  But the")
    print("               *quantitative* peak error on each cell depends")
    print("               on the chord slope, which is set by the cell")
    print("               endpoints.  Uniform and geometric placements")
    print("               produce different slopes and therefore different")
    print("               peak-error distributions.")
    print()

    forget()  # clear assumptions on a, b


# ══════════════════════════════════════════════════════════════════════
#  Main
# ══════════════════════════════════════════════════════════════════════

def main():
    print()
    print("Pseudo-log chord error argument (stages 1-3)")
    print("=============================================")
    print()

    eps, eps1, eps2, m_star, eps_peak = stage_1()
    abs_eps2, curv_total = stage_2(eps2)
    stage_3(eps2)

    print("=" * 72)
    print("All assertions passed.")
    print("=" * 72)


main()
