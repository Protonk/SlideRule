# Library Guide

The `lib/` directory is the project core. It builds the automaton path family,
evaluates Day-style coarse approximations exactly on dyadic cells, derives the
policy-induced pattern family, computes additive diagnostics on that family,
and searches for shared-delta policies.

## Load Order

The Sage modules are meant to be loaded in this order:

```sage
load('lib/paths.sage')
load('lib/day.sage')
load('lib/policies.sage')
load('lib/jukna.sage')
load('lib/optimize.sage')
```

`trajectory.py` is standalone Python and does not participate in that load
chain.

## Modules

### `paths.sage`

Layer 1: residue-automaton path generation.

Primary entry point:

- `residue_paths(q, depth)`: builds the layered residue automaton with
  transitions `r -> (2r + b) mod q` and enumerates every depth-`depth` binary
  path from the root.

Returned path rows have this shape:

- `bits`: binary prefix tuple.
- `states`: visited states, including the source state.
- `vec`: 0-1 edge-incidence vector over the layered graph.
- `terminal`: terminal residue after reading the prefix.

### `policies.sage`

Layer 1.5: named intercept policies.

Primary entry points:

- `build_intercept_policy(name, q, depth, alpha_q, **kwargs)`
- `zero_policy(...)`
- `state_bit_policy(...)`
- `terminal_bias_policy(...)`
- `hand_tuned_policy(...)`

A policy returns:

- `c0_rat`: base intercept.
- `delta_rat`: rational correction table keyed by `(state, bit)` or
  `(layer, state, bit)`.

### `day.sage`

Layer 2: Day-style exact evaluator and induced-family builder.

Core evaluator pieces:

- `path_intercept(bits, c0, delta, q)`: accumulates the intercept along one
  automaton path.
- `cell_exact_logerr(bits, p_num, q_den, c_rat)`: exact per-cell extrema using
  Day's breakpoint/stationary-point candidate set.
- `global_exact_metrics(paths, p_num, q_den, c0_rat, delta_rat, q)`: global
  metrics across all leaves.
- `best_single_intercept(paths, p_num, q_den, ...)`: best baseline with
  `delta = 0`.

Induced-family pieces:

- `cell_active_pattern(bits, p_num, q_den, c_rat)`: exact breakpoint and
  segment-extremum signature for one leaf cell.
- `active_pattern_vector(bits, p_num, q_den, c_rat, coordinate_index)`: 0-1
  encoding of one active-pattern signature.
- `build_active_pattern_family(paths, p_num, q_den, c0_rat, delta_rat, q)`:
  deduplicates the induced Day-pattern vectors and records multiplicities.

Important metric names:

- `worst_abs`: `sup |log2(z)|` over the union of leaves.
- `max_cell_log2_ratio`: largest cellwise `log2(zmax/zmin)`.
- `union_log2_ratio`: true global `log2(zmax/zmin)` over the union of leaves.

### `jukna.sage`

Layer 3: additive diagnostics on 0-1 vector families.

Primary entry points:

- `additive_summary(vectors)`: returns sumset size, pair-collision count, and
  additive energy.
- `summarize_vector_family(vectors, ...)`: one-stop summary with additive
  statistics plus Sidon and cover-free diagnostics.
- `exact_sidon_subset(...)`
- `exact_cover_free_subset(...)`

Greedy and exact subset sizes are both reported. The exact routines are
branch-and-bound searches with explicit size cutoffs.

### `optimize.sage`

Shared-delta optimization and lower bounds.

Primary entry points:

- `free_per_cell_metrics(depth, p_num, q_den)`: unconstrained per-cell lower
  bound.
- `build_intercept_matrix(paths, q)`: linear map from policy parameters to
  per-path intercepts.
- `optimize_minimax(q, depth, p_num, q_den, ...)`: minimax shared-delta search
  by bisection on target error, then a second-stage LP minimizing `max |delta|`.
- `optimize_shared_delta(...)`: dispatcher exposing the minimax solver by
  default and the legacy Nelder-Mead path on request.

### `trajectory.py`

Standalone pilot for the earlier fixed-intercept question. It samples
intercepts for `(a, b)` pseudolog lines, counts empirical min/max trajectory
families, and is useful for quick exploratory work without Sage.

## Numerical Caveats

- The exact evaluator in `day.sage` uses exact rational breakpoint structure
  and high-precision reals for transcendental values.
- The shared-delta minimax path in `optimize.sage` is not a fully symbolic
  rational proof. It uses float bisection, SciPy LPs, dyadic snapping of the
  returned solution, and a post-snap repair step when the dyadic policy drifts
  above the continuous target.
- Exact Sidon and cover-free routines are exact only up to their configured
  family-size limits. Larger families fall back to greedy summaries only.
- Induced families are currently deduplicated before additive diagnostics are
  computed. Path multiplicities are still returned by `build_active_pattern_family`.

## Extension Notes

- New policy families belong in `policies.sage`.
- New per-cell or global Day metrics belong in `day.sage`.
- New additive invariants or certified subset routines belong in `jukna.sage`.
- New optimizers or optimizer diagnostics belong in `optimize.sage`.
