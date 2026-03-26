# Architecture dependence of the wall

The wall depends on automaton topology, not just parameter count.

---

## The observation

The depth-indexed absorption staircase (`depth_staircase.sage`) sweeps
q ∈ {1, 3, 5, 7, 9, 11} at depths 4–8 on geometric_x with LI. At
d ≤ 6, the gap decreases monotonically with q: more states, smaller
wall. At d = 7–8, the gap is non-monotone:

| depth | q=5     | q=7     | q=9     | q=11    |
|-------|---------|---------|---------|---------|
| 6     | 0.03596 | 0.02827 | 0.02771 | 0.02576 |
| 7     | 0.04157 | 0.03598 | 0.03644 | 0.03631 |
| 8     | 0.04445 | 0.04001 | 0.04109 | 0.04202 |

At d = 8, the mod-7 automaton outperforms mod-9 and mod-11 despite
having fewer parameters (15 vs 19 vs 23).

## Ruling out solver artifacts

The non-monotonicity survives:

- **Tightened LP tolerances.** HiGHS primal/dual feasibility set to
  1e-9 (default was ~1e-7).
- **Finer dyadic snapping.** 26 bits (1.5e-8 granularity) instead of
  20 bits (1e-6).
- **Direct continuous-tau check.** The pre-snap continuous minimax
  error is non-monotone: tau_continuous at d=8 is 0.04049 (q=7),
  0.04157 (q=9), 0.04251 (q=11). Snap loss is ~1e-8 — negligible.

The non-monotonicity is a property of the optimisation problem, not
the solver.

## Why it happens

The FSM uses the modular automaton: state transitions are
`next_state = (2 * state + bit) mod q`. Different q values produce
different automata with different path algebras. The achievable
subspace S_q is the image of the linear map from the (1 + 2q)
parameters to the 2^d-dimensional correction vector. Because the
map's structure changes with q, S_q is not a subset of S_{q+1}.

More parameters in a differently oriented subspace can produce a
larger wall. The mod-9 automaton at d = 8 has 19 parameters spanning
a 19-dimensional subspace of R^256, but that subspace is oriented
worse relative to δ\* than the 15-dimensional subspace of the mod-7
automaton.

This is not a degenerate case. The mod-q automaton is the natural
family for this project: it is the canonical width-q sequential reader
of binary digits with full state reachability. But canonical does not
mean nested.

## What this establishes

The wall is not a function of parameter count alone. Equal parameter
budgets under different automaton topologies yield different walls.
This is a concrete instance of the architecture dependence described
in [ABYSSAL-DOUBT](../../reckoning/ABYSSAL-DOUBT.md) §4a: the wall
depends on which directions S spans, not just its dimension.

Specifically:

1. **The subspace orientation matters more than its size** at depths
   where the parameter-to-cell ratio is small. At d = 4 (16 cells),
   q = 9 gives a ratio of 19/16 ≈ 1.2 and the wall closes completely.
   At d = 8 (256 cells), q = 11 gives a ratio of 23/256 ≈ 0.09 and
   the wall depends on how those 23 directions sit in R^256.

2. **The depth at which non-monotonicity appears marks a regime
   transition.** Below d = 6, parameter budget dominates: adding
   parameters always helps because the subspace can grow toward δ\*.
   Above d = 6, the subspace geometry dominates: the mod-q path
   algebra determines whether the new directions point toward δ\*
   or away from it.

3. **The wall decomposition (2a–2b) is not affected.** Layer sharing
   remains the dominant source; early-layer fan-out remains the
   mechanism. What changes is that the cost of that mechanism depends
   on how the specific automaton's sharing pattern interacts with the
   fan-out geometry. The decomposition is architecture-independent;
   the magnitudes are not.

## What this does not establish

- Whether a different automaton family (not mod-q) would show the
  same non-monotonicity. The finding is about the mod-q family.
- Whether a second architecture (e.g. De Caro) sees the same wall
  magnitudes. That is the subject of TRAVERSE Steps 5–6.
- Whether there exists a q > 11 where the mod-q automaton recovers
  at d = 8. The sweep does not extend far enough to test this.

## Implications for the staircase prediction

The staircase prediction (TILING.md §3) says stair locations are set
by Δ^L. This remains plausible for stair locations — which cells bind
the minimax — but the prediction that the staircase descends
monotonically with parameter budget is falsified for the mod-q family
at d ≥ 7. The staircase is real, but its steps are not ordered by q
alone. The automaton topology is a second variable.

---

## Data

Results: `results/depth_staircase.csv` (30 rows, 5 depths × 6 q values).
Plot: `results/depth_staircase.png`.
Script: `depth_staircase.sage`.

Solver settings: HiGHS with primal/dual feasibility tolerance 1e-9,
dyadic snapping at 26 bits. See `lib/optimize.sage` constants.

## Reading outward

- [ABYSSAL-DOUBT](../../reckoning/ABYSSAL-DOUBT.md) §4a: the
  architecture question this finding instantiates.
- [TRAVERSE](../../reckoning/TRAVERSE.md) Step 2d: the scaling
  characterisation this experiment targets.
- [WALL](WALL.md): the wall decomposition (unaffected by this finding).
- [CHARYBDIS](../../reckoning/CHARYBDIS.md) §5: the non-genericity
  result (complementary — Charybdis shows the FSM is special vs random
  subspaces; this shows different FSMs are special in different ways).
