# Refinement split sequence: efficiency

## The problem

The split sequence `1.AAAAAAAAAA` encodes the number of new sign boundaries
introduced at each depth transition d → d+1. Computing one digit requires the
sign sequence at depth d and d+1. The sign sequence at depth d requires:

1. The **canonical snapped policy** from `optimize_minimax` — a bisection
   search over target error τ with LP feasibility checks at each step,
   followed by a stage-2 regularization LP, dyadic snap, and possible repair.
2. The **free-cell intercepts** — the per-cell optimal intercept each cell
   would choose independently.

The sign of cell j is `sgn(path_intercept_j - free_cell_intercept_j)`.

## Invariants and baseline

The authoritative configuration for this project is:

- `tol=1e-10`
- `dyadic_bits=20`
- `compute_signs` calling `optimize_minimax` directly

The optimization target is the per-depth sign list at those fixed solver
parameters. The split sequence is derived from the sign lists via
`refinement_splits`, so preserving the signs preserves the digits.

In practice, correctness means preserving the canonical snapped policy
produced by `optimize_minimax`, not merely landing on a policy with similar
error. Different bisection/bracketing mechanics are acceptable only if the
final snapped policy is identical, because sensitive cells can flip sign when
the snap lands differently.

### Where the time goes

`optimize_minimax` (in `lib/optimize.sage:424`) runs ~32 bisection steps at
default tol=1e-10. Each step rebuilds per-cell feasible intervals
(`_build_feasible_intervals_arb`) and solves an LP feasibility check
(`_lp_feasibility`). Profiling at q=3, d=3 shows the interval-building pass
dominates per-step cost, not the LP solve itself.

The number of cells N = 2^d, and the per-depth cost scales roughly as O(2^d).
Each additional digit of the split sequence costs about as much as all
previous digits combined.

---

## What we did

### Dedicated compute_signs with reused cell optima

**What:** Wrote `compute_signs.sage`, a function that calls `optimize_minimax`
directly and extracts signs without any redundant work.

**How:** Three changes:

1. Added `cell_free_intercepts` to `optimize_minimax`'s return dict
   (`lib/optimize.sage`). This is a `bits → c_opt` map built from the
   `cell_optima_arb` table that `optimize_minimax` already computes at its
   step 1 (`lib/optimize.sage:456`). Eight lines of code, no change to
   existing callers. 88 tests pass.

2. `compute_signs` calls `optimize_minimax` directly instead of going through
   `compute_case` → `optimize_shared_delta`. This skips two expensive passes:
   - `best_single_intercept`: O(2^d) per-cell scalar optimizations, not
     needed for signs at all.
   - `free_per_cell_metrics`: O(2^d) per-cell scalar optimizations, redundant
     because `optimize_minimax` already computes the identical per-cell optima
     internally.

3. Signs are computed by direct subtraction of `path_intercept(bits, c0,
   delta, q) - free_intercepts[bits]` per cell. The old path went through
   `build_percell_rows` (`keystone_runner.sage:145`), which linearly scans
   all free rows for each cell — O(N²) total. The new path is O(N).

**Why we chose this:** It is the largest zero-risk win. Every eliminated call
is provably redundant for the sign task. The `cell_free_intercepts` addition
to `optimize_minimax` is additive — no existing code path changes.

**Where we gained speed:** The gain is from eliminating two full O(2^d)
per-cell optimization passes and the O(N²) row scan. The gain fraction
increases with depth because the eliminated passes are O(2^d) while the
bisection loop (which we did not change) is also O(2^d) — so eliminating
the passes saves a constant fraction of total work.

### Disk caching

**What:** After computing signs at depth d, write the full result (signs,
solver metadata, policy) to a JSON file. Before computing, check if the cache
exists and load it.

**How:** Cache files are stored at
`results/<kind>_q<q>_<ld>/signs_d<d>_tol<tol>_db<dyadic_bits>.json`.
The cache key includes mathematical parameters (kind, q, depth, p_num, q_den,
layer_dependent) and solver parameters (tol, dyadic_bits, solver_version).
Different solver settings never collide.

**Why we chose this:** The sign sequence at each depth is deterministic for
fixed solver parameters. Computing it is expensive; storing it is trivial
(8 KB at depth 13). Incremental extension — computing digits 11 and 12 after
already having 1-10 — should not re-pay the cost of depths 3-10.

**Where we gained speed:** Re-runs and extensions. A full 10-digit run that
was previously cached completes in <1 second. Extending from 10 to 12 digits
pays only the cost of depths 11 and 12.

---

## Measured results

All times below are for `uniform_x`, `q=3`, LI, exponent `1/2`.

The authoritative baseline to optimize against is the fresh per-depth cost of
the current `compute_signs` path at `tol=1e-10`, `dyadic_bits=20`.

The historical "before" column is included only as context for the Strategy 1
win. It came from the older path through `compute_case` +
`build_percell_rows` (via `optimize_shared_delta`, default `dyadic_bits=12`)
and should not be treated as the current semantic baseline.

| depth | N     | before   | after    | speedup |
|-------|-------|----------|----------|---------|
| 3     | 8     | 5s       | 5s       | 1.0x    |
| 4     | 16    | 10s      | 10s      | 1.0x    |
| 5     | 32    | 20s      | 19s      | 1.1x    |
| 6     | 64    | 40s      | 39s      | 1.0x    |
| 7     | 128   | 80s      | 78s      | 1.0x    |
| 8     | 256   | 160s     | 159s     | 1.0x    |
| 9     | 512   | 324s     | 321s     | 1.0x    |
| 10    | 1024  | 642s     | 547s     | 1.17x   |
| 11    | 2048  | 1277s    | 783s     | 1.63x   |
| 12    | 4096  | 2572s    | 1577s    | 1.63x   |
| 13    | 8192  | 5457s    | 3208s    | 1.70x   |

**Fresh per-depth total (d=3..13):** `10587s → 6746s` (~1.57x overall).

**Mixed cached/fresh run:** `6595s` in a run where depths 3-7 were cache hits.
This is not a comparable full-fresh total and should not be used as the
baseline for the next optimization pass.

**Cached re-run:** `<1 second` for any previously computed depth range.

### Where the speedup came from

At low depths (3-9), the eliminated passes are cheap relative to the bisection
loop, so the speedup is negligible. At high depths (10-13), the eliminated
passes become a larger fraction of total time:

- `best_single_intercept`: O(2^d) scalar minimizations via golden-section
  search. At d=13, this is 8192 minimizations eliminated.
- `free_per_cell_metrics`: Same O(2^d) cost, fully redundant with
  `optimize_minimax`'s step 1.
- `build_percell_rows` O(N²) scan: at d=13, 8192 × 8192 = 67M iterations
  eliminated.

The 1.7x at depth 13 is consistent with eliminating two O(N) passes and one
O(N²) scan from a pipeline where the bisection loop is also O(N).

### Note on dyadic_bits

The "before" path went through `optimize_shared_delta`, which defaults to
`dyadic_bits=12`. The "after" path calls `optimize_minimax` directly with
`dyadic_bits=20`. This changes the canonical snapped policy at some depths,
which can change the sign sequence. The sequences agree through depth 9 and
diverge at depth 10. The speed difference between db=12 and db=20 is
negligible — `dyadic_bits` only affects the snap/repair phase at the end,
not the bisection loop.

---

## New Strategy: Warm-start interval construction inside `optimize_minimax`

This is the next attempt.

The objective is to speed up `_build_feasible_intervals_arb` and
`_bisect_feasible_interval` without changing the solver contract:

- same bisection over `tau`
- same LP feasibility test
- same stage-2 regularization
- same dyadic snap and repair
- same final snapped policy

The current implementation recomputes each cell's feasible interval from
scratch at every bisection step and each boundary search restarts from
`c_star ± 0.01`. That throws away structure the solver already learned on the
previous step.

The working hypothesis is that, for a fixed cell, the feasible set in
intercept-space is a nested interval around `c_star`: as `tau` increases the
interval expands, and as `tau` decreases it contracts. If that holds on the
actual arb path, previously computed boundaries are valid warm starts for
nearby `tau` values.

This should not be treated as an unverified theorem of the implementation.
Before building on it, verify empirically at `d=3` using the actual
`_cell_feasible_interval_arb` / `_bisect_feasible_interval` path that:

- `lo(tau)` is nonincreasing as `tau` grows
- `hi(tau)` is nondecreasing as `tau` grows
- the cold-path feasible set behaves like a single interval around `c_star`

The post-bisection snap/repair logic in `optimize_minimax` is downstream of
interval construction and does not affect these per-cell interval checks, but
the candidate structure inside `cell_logerr_arb` still makes the empirical
gate worthwhile.

**Expected implementation:**

1. Keep interval state inside `optimize_minimax` for previously evaluated
   `tau` values.
2. Verify the nesting/monotonicity assumptions empirically at `d=3` before
   enabling warm starts.
3. Extend `_build_feasible_intervals_arb` to accept optional warm-start
   boundary state.
4. Extend `_bisect_feasible_interval` to reuse a prior bracket instead of
   always restarting from `c_star ± 0.01`.
5. When `tau` decreases, shrink from the previously known feasible interval.
6. When `tau` increases, expand outward from the prior boundary rather than
   from `c_star`.
7. Preserve a cold-path fallback whenever a warm bracket fails a validity
   check.
8. Add lightweight counters or timing hooks so the reduction in scalar
   boundary evaluations can be measured directly.

**Why this:** It attacks the profiled hot path directly, preserves
the solver semantics we now consider load-bearing, and compounds with any
later parallelism.

**Validation standard:** Compare old vs new serialized snapped policy and sign
lists before trusting any timing result. Matching error summaries alone are
not enough. The `d=3` interval-nesting check is a gate before implementing
warm-start logic.

**Iteration budget:** Use cheap and moderate depths to iterate.

- Exactness first on small depths, then one moderate depth.
- First confirm the interval-nesting assumption empirically at `d=3`.
- Timing first at `d=7`, then `d=8` if the result is clean.
- Use `d=9` as a confirmation point only if `d=7/8` already show a real win.
- Avoid spending depth-13 budget until the implementation already looks
  credible.

## Other future options

### Within-depth parallelism

Per-cell work (computing cell optima, building feasible intervals) is
embarrassingly parallel. At depth 13, there are 8192 independent cells.

Across-depth parallelism is limited: depth 13 alone is 3208s out of the
6746s fresh per-depth total (~48%), so even with unlimited cores,
across-depth parallelism gives at most ~2x. Within-depth parallelism attacks
the actual bottleneck.

**Expected gain:** Linear in cores for the parallelizable fraction.

**Caveat:** Sage global state may require subprocess isolation.

**Position in queue:** Acceptable and orthogonal, but second to the warm-start
solver work. If warm-starting preserves exactness yet the wall-clock gain is
modest, subprocess parallelism becomes the natural next layer.
