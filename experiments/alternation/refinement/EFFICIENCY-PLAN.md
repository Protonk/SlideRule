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

## What we did (Strategies 1 and 2)

### Strategy 1: Dedicated compute_signs with reused cell optima

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

### Strategy 2: Disk caching

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

All times: uniform_x, q=3, LI, exponent=1/2. "Before" is the original path
through `compute_case` + `build_percell_rows` (via `optimize_shared_delta`
with dyadic_bits=12). "After" is `compute_signs` calling `optimize_minimax`
directly (dyadic_bits=20).

| depth | N     | before   | after    | speedup | cumul before | cumul after |
|-------|-------|----------|----------|---------|--------------|-------------|
| 3     | 8     | 5s       | 5s       | 1.0x    | 5s           | 5s          |
| 4     | 16    | 10s      | 10s      | 1.0x    | 15s          | 15s         |
| 5     | 32    | 20s      | 19s      | 1.1x    | 35s          | 34s         |
| 6     | 64    | 40s      | 39s      | 1.0x    | 75s          | 73s         |
| 7     | 128   | 80s      | 78s      | 1.0x    | 155s         | 151s        |
| 8     | 256   | 160s     | 159s     | 1.0x    | 315s         | 310s        |
| 9     | 512   | 324s     | 321s     | 1.0x    | 639s         | 631s        |
| 10    | 1024  | 642s     | 547s     | 1.17x   | 1281s        | 1178s       |
| 11    | 2048  | 1277s    | 783s     | 1.63x   | 2558s        | 1961s       |
| 12    | 4096  | 2572s    | 1577s    | 1.63x   | 5130s        | 3538s       |
| 13    | 8192  | 5457s    | 3208s    | 1.70x   | 10587s       | 6746s       |

**Fresh 10-digit total:** 10587s → 6595s (1.6x overall, 1.7x at depth 13).

**Cached re-run:** <1 second for any previously computed depth range.

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

## Remaining attack surface

These are strategies we identified but did not implement. They are ordered
by expected value (payoff × feasibility).

### Interval-bound reuse across bisection steps

The profiled hot path is `_build_feasible_intervals_arb`, which rebuilds
every cell's feasible intercept interval from scratch at each bisection step.
`_bisect_feasible_interval` restarts its boundary search from a fixed
`step=0.01` every time.

The feasible interval for each cell is monotone in τ: as τ increases, the
interval expands; as τ decreases, it contracts. Previously computed interval
endpoints are valid warm starts for nearby τ values during bisection.

**Expected gain:** Potentially large — directly attacks the profiled hot path
rather than reducing the number of times it is invoked.

**Key files:** `lib/optimize.sage`, functions `_build_feasible_intervals_arb`
and `_bisect_feasible_interval`.

### Reduce bisection tolerance

Default tol=1e-10 produces ~32 bisection steps. At tol=1e-6, observed ~19
steps at q=3, d=3 — a ~1.7x reduction in iterations.

The sign sequence only needs `sgn(displacement)`. Most displacements are
much larger than the tolerance gap, so a coarser tolerance often produces
the same sign sequence.

**Risk:** Different tolerance → different τ target → different stage-2 LP
→ different snap → potentially different signs. The correct validation is
to compare sign sequences directly across tolerance levels, not to compare
displacement magnitudes to tol (dimensionally wrong — tol is in error space,
not intercept space).

**Expected gain:** ~1.7x reduction in bisection steps. Actual wall-clock gain
depends on how much of per-step cost is interval-building vs LP. Needs
empirical profiling at high depth.

### Safe bracket reuse from previous depth

The depth-d and depth-(d+1) problems have different optima, but the depth-d
solution provides information. Two safe options:

1. Evaluate the depth-d policy at depth d+1 to get a valid tau_hi candidate.
2. Test LP feasibility at τ = τ*_d to determine which side of the bracket
   it belongs to.

Using τ*_d directly as tau_lo is **not safe** — the depth-(d+1) optimum can
be above or below τ*_d.

**Expected gain:** Modest — saves a few bisection steps per depth.

### Within-depth parallelism

Per-cell work (computing cell optima, building feasible intervals) is
embarrassingly parallel. At depth 13, there are 8192 independent cells.

Across-depth parallelism is limited: depth 13 alone is 3208s out of 6595s
total (49%), so even with unlimited cores, across-depth parallelism gives
at most ~2x. Within-depth parallelism attacks the actual bottleneck.

**Expected gain:** Linear in cores for the parallelizable fraction.

**Caveat:** Sage global state may require subprocess isolation.

### Withdrawn: sign-only LP

Proposed solving a single coarse LP and certifying signs by checking all
displacements are far from zero. Not sound: the canonical sign sequence is
defined by the full lexicographic solve (bisection + stage-2 + snap + repair).
A rough LP produces a different policy with potentially different signs.
Certifying the rough policy's signs does not certify the canonical policy's.
