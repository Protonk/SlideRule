# PLAN

Activity:
Add partition support that can compare the current equal-width-in-`x` cell
geometry against log-uniform / geometric cells without changing the residue
automaton or the shared-delta parameterization.

Question: How do we design and implement geometric aware partitioning?

Design:
- Terminology / vocabulary discipline:
  - Separate geometry from addressing.
  - Geometry names:
    - `uniform_x` = equal additive width on `[1,2)`
    - `geometric_x` = equal width in `log x` on `[1,2)`
  - Addressing names:
    - `bits` / `binary_prefix` = binary address of the cell index
    - `index` = integer cell id `0 .. 2^depth - 1`
  - Do not use `dyadic` to name geometry in the new API.
  - If a compatibility alias is needed, keep `dyadic_x` only as a temporary
    alias for `uniform_x`, not as the canonical name.
- Scientific target:
  - Make `L1`-`L3` in `LODESTONE.md` directly testable by running the same
    optimizer on two partition geometries with the same `depth` and the same
    number of cells.
- Current baseline, stated plainly:
  - The repo currently hard-codes equal-width additive cells on `[1,2)`.
  - The `bits` path labels currently do double duty: they identify both the FSM
    path and the cell boundaries.
  - That coupling is what needs to be broken.
- Scope of the first milestone:
  - Stay inside one octave `[1,2)`.
  - Keep `residue_paths(q, depth)` and the FSM parameterization unchanged.
  - Compare two partition kinds with `2^depth` cells:
    - `uniform_x`: `x_j = 1 + j / 2^depth`
    - `geometric_x`: `x_j = 2^(j / 2^depth)`
  - Treat `uniform_x` as the compatibility default so existing callers keep the
    current behavior unless they opt in.
- Partition model:
  - Introduce a partition layer that maps cell index `j` to geometry.
  - Keep `bits` as the binary address of the cell index `j`; `bits` no longer
    imply the cell bounds.
  - A partition row should carry at least:
    - `index`
    - `bits`
    - `x_lo`, `x_hi`
    - `plog_lo`, `plog_hi`
    - optional convenience widths such as `width_x` and `width_log`
- Numerical strategy:
  - The current Day evaluator is exact in breakpoint structure because the
    current cell endpoints are rational in plog-space.
  - `geometric_x` introduces irrational endpoints (`2^(j/N)`), so the current
    exact-QQ endpoint machinery cannot be reused unchanged.
  - The finite-candidate structure itself survives arbitrary compact
    subintervals of `[1,2)`.
    - Candidates are still just:
      - the interval endpoints
      - `H` points where `u(x) = c - alpha(x - 1)` crosses an integer
      - `D` points inside fixed-`floor(u)` segments
    - In `x` coordinates:
      - `x_H,m = 1 + (c - m) / alpha`
      - `x_D,k = 1 + (c - k) / (1 + alpha)`
    - In plog coordinates:
      - `plog(x_H,m) = (c - m) / alpha`
      - `plog(x_D,k) = (c - k) / (1 + alpha)`
    - The implementation must be explicit about `x_D` versus `plog(x_D)` to
      avoid an off-by-one bug in the stationary-point formula.
    - Each `D` candidate must pass both feasibility checks:
      - `x_D,k` lies strictly inside the cell
      - the assumed segment label is actually valid there, i.e.
        `floor(u(x_D,k)) = k`
    - The second check is mandatory, not implicit.
  - The comparison-quality implementation is:
    - build a high-precision arbitrary-cell evaluator first
    - validate it on `uniform_x` against the current exact path
    - use that same arbitrary-cell evaluator for both `uniform_x` and
      `geometric_x` in the lodestone comparison sweeps
    - keep the current exact `uniform_x` evaluator as a regression oracle, not
      as one arm of the actual comparison
  - The arbitrary-cell evaluator should therefore be candidate-based rather than
    sampled as a primary method: same H/D logic, arbitrary endpoints, evaluated
    in high precision rather than exact QQ.
  - Positivity / well-definedness:
    - `log2 z(x)` must be defined at every candidate actually evaluated.
    - Under the current `pexp`, this should hold automatically on each
      fixed-`floor(u)` segment.
    - Still add an explicit positivity assertion at candidate evaluation time
      so future `pexp` variants or refactors cannot silently invalidate the
      evaluator.
  - Concavity-based consistency checks:
    - For `alpha > 0`, `f(x) = log2 z(x)` is strictly concave on each
      fixed-`k` segment.
    - Therefore:
      - a valid `D` point can only be the segment maximizer of `f`
      - the segment minimum must occur at a boundary / endpoint / `H` point
    - This does not change the candidate set, but it should be used as an
      internal consistency check while validating the new evaluator.
  - Cells with no internal `H` points need no special algorithm.
    - They are just one smooth concave segment.
    - The natural candidate set is then endpoints plus an optional valid
      `D` point.
- Comparison contract:
  - Hold fixed: `q`, `depth`, optimizer, objective, and parameterization.
  - Vary only partition geometry.
  - Main comparison runs should use one evaluator path for both partition kinds.
  - Emit both:
    - summary artifacts with `single_err`, `opt_err`, `free_err`, `gap`, and
      worst-cell metadata
    - per-cell artifacts so concentration and qualitative shape can be
      inspected directly
- Artifact contract:
  - Summary CSV should include at least:
    - `partition_kind`
    - `alpha`, `q`, `depth`, `layer_dependent`
    - `single_err`, `opt_err`, `free_err`
    - `improve`, `gap`
    - `worst_cell_index`, `worst_cell_bits`
    - `worst_cell_x_lo`, `worst_cell_x_hi`
  - Per-cell CSV should include at least:
    - `partition_kind`
    - `alpha`, `q`, `depth`, `layer_dependent`
    - `cell_index`, `bits`
    - `x_lo`, `x_hi`
    - `plog_lo`, `plog_hi`
    - one midpoint/location field in `x`
    - one midpoint/location field in log-related coordinates
    - `cell_worst_err`
    - `cell_log2_ratio`
    - `path_intercept`
    - `free_cell_intercept`
    - `worst_candidate_type`
    - `worst_candidate_x`
    - `n_candidates`
- Non-goals for the first milestone:
  - Do not generalize the active-pattern / Jukna diagnostics yet.
  - Do not reinterpret the whole repo as a global partition of `R_{>0}` yet.
  - Do not rename existing drivers until the comparison driver actually exists.

Next actions:
- Stage a terminology cleanup pass after the implementation design is stable.
  - Current docs still describe the present baseline as “dyadic/geometric” in
    a few places.
  - The code reality is currently `uniform_x`, so either the docs need to be
    corrected or clearly marked as ahead of code reality.
- Implement a partition module, likely `lib/partitions.sage`, with helpers such
  as:
  - `bits_to_index(bits)`
  - `index_to_bits(index, depth)`
  - `build_partition(depth, kind='uniform_x')`
  - `partition_row_map(partition)` keyed by `bits`
- Refactor evaluation in `lib/day.sage` so cell geometry comes from a partition
  row rather than from `bits` alone.
  - Keep a backward-compatible wrapper for the current equal-width case.
  - Add a general arbitrary-cell evaluator that accepts `plog_lo` / `plog_hi`.
  - Implement arbitrary-cell candidate generation from those bounds directly.
  - Make `D`-point validity an explicit helper so the stationary formula and the
    `floor(u)=k` verification cannot drift apart.
  - Emit candidate metadata from the evaluator, not just the final extrema.
  - Keep any sampled evaluator only as a validation/debugging tool.
  - Preserve the existing exact `uniform_x` evaluator as a regression oracle.
  - Add an explicit validation helper comparing:
    - exact `uniform_x`
    - arbitrary-cell `uniform_x`
  - Use explicit regression gates:
    - target agreement on representative `uniform_x` cells: `<= 1e-12`
    - hard failure threshold: any discrepancy `> 1e-8`
- Thread partition support through `lib/optimize.sage`.
  - `optimal_cell_intercept(...)`
  - `free_per_cell_metrics(...)`
  - `free_per_cell_optimum(...)`
  - `_cell_feasible_interval(...)`
  - `optimize_minimax(...)`
  - `optimize_shared_delta(...)`
  - `best_single_intercept(...)` in `lib/day.sage`
- Extend result payloads and metric summaries.
  - Add `partition_kind`.
  - Add worst-cell metadata such as `worst_cell_bits`, `worst_cell_index`,
    `worst_cell_x_lo`, and `worst_cell_x_hi`.
  - Add per-cell result rows suitable for CSV export.
- Add tests before large sweeps.
  - Partition construction tests:
    - `uniform_x` covers `[1,2)` contiguously with equal additive widths.
    - `geometric_x` covers `[1,2)` contiguously with equal log widths.
  - Regression tests:
    - `uniform_x` reproduces current smoke-case results to tight tolerance.
    - arbitrary-cell `uniform_x` matches the exact `uniform_x` evaluator to
      `<= 1e-12` on representative cells, with hard failure at `> 1e-8`.
    - valid `D` candidates satisfy `floor(u(x_D)) = k`; invalid ones are
      rejected.
    - on representative fixed-`k` segments, the worst negative excursion is
      achieved at a boundary rather than at a `D` point.
  - New smoke tests:
    - `geometric_x` minimax converges.
    - `geometric_x` stays above the free-per-cell lower bound.
    - `geometric_x` cells with no internal `H` points are handled by the same
      candidate pipeline without a special branch.
- Add the first comparison driver as `experiments/lodestone_sweep.sage`.
  - Keep `experiments/h1_sweep.sage` semantically stable as the existing
    baseline-characterization driver.
  - Accept a small amount of duplicated driver code in the first pass if that
    keeps the baseline and lodestone experiments conceptually separate.
  - Refactor shared sweep helpers downward only after the first comparison run
    exists and the lodestone output contract is stable.
  - First outputs should cover:
    - fixed `q`, varying depth on both partition kinds
    - fixed depth, varying `q` on both partition kinds
    - layer-invariant vs layer-dependent on both partition kinds
  - Add one small secondary checkpoint away from `alpha = 1/2` early, even if
    the main first pass is still centered on `alpha = 1/2`.
- Update docs only after the first run exists.
  - `lib/README.md`
  - `experiments/README.md`
  - `HYPOTHESES.md`
  - `SWEEP-REPORTS.md`

Open decisions:
- Secondary robustness point:
  - Which small non-`1/2` `alpha` checkpoint should be the first add-on case?
- Scope of first implementation:
  - Should `experiments/optimize_delta.sage` remain dyadic-only for now, or be
    made partition-aware at the same time as the main sweep driver?
- Pattern-family diagnostics:
  - Leave them dyadic-only for the first milestone, or stub out a
    "not supported for this partition" path immediately?

Kill when done:
- A partition module exists and `uniform_x` is the canonical default geometry.
- The evaluator and minimax optimizer accept partition choice without changing
  the FSM/path layer, and the main lodestone comparisons use one evaluator path
  for both partition kinds.
- Tests cover partition construction, `uniform_x` regression, and
  `geometric_x` smoke cases.
- Exact `uniform_x` and arbitrary-cell `uniform_x` agree to the chosen
  validation tolerance on representative cells and smoke cases.
- A first lodestone summary CSV and per-cell CSV exist and report both global
  errors and error localization / concentration fields.
- The first `geometric_x` runs pass a plausibility check:
  - `single_err` and `free_err` behave monotonically with depth on the initial
    sweep grid
  - their scale is qualitatively comparable to the corresponding `uniform_x`
    runs rather than obviously corrupted by an integration bug.
