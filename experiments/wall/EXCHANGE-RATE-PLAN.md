# Exchange Rate Plan

Connect the damage analysis (chord sharing counterfactuals) to the
wall decomposition (realized sharing cost under optimization). The
goal is to measure how much of the wall the optimizer mitigates vs
how much is the raw cost of intercept displacement.

## Motivation

Damage gives us `E[j][k]` — the absolute error on cell k when using
cell j's chord. The wall gives us `wall_excess_j` — the excess error
on cell j under the optimizer's shared solution vs its free-per-cell
optimum. These are not directly comparable: one is absolute, the other
is an excess over a baseline. To connect them, we need both sides
measured as excesses over the same baseline.

The instrument: a **foreign-intercept excess matrix** `F[j][k]` that
measures how much worse cell k gets when forced to use cell j's
free-optimal intercept instead of its own. Both F and wall_excess are
then excesses over the free-per-cell optimum, making the comparison
meaningful.

## Key concept: foreign-intercept excess matrix

For each pair of cells (j, k), define:

    F[j][k] = err_on_cell_k(c_free_j) - err_on_cell_k(c_free_k)

where `err_on_cell_k(c)` is the worst-case error on cell k using
intercept c, computed via `cell_logerr_arb`. The diagonal is zero:
`F[k][k] = 0`.

This replaces the existing `E[j][k]` from `_foreign_error.sage` for
this experiment. The existing matrix uses donor-cell chords (whose
behavior depends on donor geometry/slope, not just intercept), making
intercept-proximity matching unreliable. `F` isolates intercept
displacement as the only degree of freedom.

## Key concept: best-donor baseline

For each cell j in a solved case, the **best donor** is:

    best_donor_j = argmin_{k != j} err_on_cell_j(c_free_k)

This is the cell (other than j itself) whose free intercept causes
the least damage to cell j — selected by minimizing the actual error,
not by intercept proximity. Self-donation is excluded because
`F[j][j] = 0` by construction, which would make the comparison
degenerate. Ties are broken by lowest cell index.

The best-donor excess is `F[best_donor_j][j]`.

The **optimizer value-add** for cell j is:

    value_j = F[best_donor_j][j] - wall_excess_j

If positive: the optimizer's compromise intercept beats the best
available single-donor intercept (the optimizer is finding solutions
that no single-cell intercept reuse could achieve).

If negative: the global minimax constraint forces cell j to accept
more damage than the best available donor would cause (this cell is
subsidizing the global optimum).

Both sides are excesses over cell j's free error. Commensurate.

## Execution order

### 1. `foreign_intercept_matrix.sage`

Build the `F[j][k]` matrix for a given partition and exponent. This
is a helper loaded by the analysis scripts, analogous to
`_foreign_error.sage`.

Inputs: cell boundaries from `build_partition`, free-per-cell
intercepts from `free_per_cell_metrics`.

Implementation: for each (j, k), evaluate `cell_logerr_arb` on
cell k's domain using cell j's `c_free` intercept, subtract cell k's
own free error. Use the Day candidate set for exact worst-case
evaluation (no sampling).

### 2. `damage_vs_wall.sage`

For the anchor case (geometric, q=3, d=6, exp=1/2, both LI and LD),
compute per cell:

- `c_shared_j` from the solved `opt_pol` via `path_intercept`
- `c_free_j` from `free_metrics`
- `wall_excess_j = cell_worst_err_j(shared) - cell_worst_err_j(free)`
- `best_donor_j = argmin_{k != j} err_on_cell_j(c_free_k)`
- `best_donor_excess_j = F[best_donor_j][j]`
- `value_j = best_donor_excess_j - wall_excess_j`

Output: per-cell CSV. Ribbon plot with three layers per cell:
free error (baseline), free error + best-donor excess (damage
prediction), free error + wall excess (realized). The gap between
the damage and wall-excess curves shows the optimizer's value-add.

### 3. `value_add_summary.sage`

Aggregate across the case grid. For each case:
- `mitigation_fraction`: fraction of cells where `value_j > 0`
  (optimizer beats best donor — prevalence measure)
- `normalized_total_value`: `sum(value_j) / sum(best_donor_excess_j)`
  (what fraction of the total best-donor damage does the optimizer
  recover, net of cells it subsidizes — magnitude measure)
- `worst_cell_value`: value-add at the globally worst cell

Both prevalence and magnitude are needed: a case with many small wins
on easy cells looks good on mitigation_fraction but may have small
normalized_total_value, while concentrated mitigation on a few hard
cells shows the opposite pattern.

Key questions:
- Do both measures increase from LI to LD?
- Does normalized_total_value scale with parameter-to-cell ratio?
  (This is the exchange rate.)
- Do the measures differ across partition kinds?

### 4. `exchange_rate_curve.sage`

Two scatter plots, same axes: x = `n_params / 2^depth`, color =
partition kind, marker = LI vs LD.

- Panel A: y = `normalized_total_value` (magnitude).
- Panel B: y = `mitigation_fraction` (prevalence).

If panel A traces a curve, that is the exchange rate: the return on
structural investment in terms of damage mitigation. A plateau is
the automaton-coupling residual. A curve that differs by kind means
the exchange rate is geometry-dependent. Panel B shows whether the
mitigation is broad or concentrated.

This is the most direct empirical path to TRAVERSE Step 5.

### 5. Register hypotheses

Add to `experiments/EXPERIMENTS.md` in a new W-series, and add W1/W2
to the wall area's `Tests:` line:

**W1. The optimizer mitigates a measurable fraction of sharing damage**

Status: open. Tested in: `wall/damage_vs_wall`.
Question: Is the normalized total value-add positive — does the
optimizer recover a measurable fraction of best-donor damage in
aggregate?
Claim: The optimizer finds compromise intercepts that, in total,
beat single-cell intercept reuse. Some cells may be subsidized
(negative value-add), but the net effect is positive.

**W2. Optimizer value-add scales with parameterization budget**

Status: open. Tested in: `wall/exchange_rate_curve`.
Question: Does the fraction of cells where the optimizer beats the
best donor increase with the parameter-to-cell ratio?
Claim: More parameters buy more damage mitigation, with diminishing
returns that plateau at the automaton-coupling residual.

### 6. Pivot: fan-out scaling

Steps 1–2 revealed that the damage-vs-wall comparison is the wrong
frame. The wall is not pairwise chord displacement — it is systematic
positional displacement driven by early-layer fan-out. W1 is answered
(negative result). W2 as originally stated is moot.

The new direction: measure how the layer-0 fan-out scales with depth
and q. Specifically:

- `fan_out_scaling.sage`: for a grid of (kind, q, depth, exponent,
  LI/LD), compute the displacement range, per-layer contribution
  statistics, and displacement-position correlation. The key question
  is whether the displacement range grows with 2^d (making the wall
  fundamentally unsolvable by adding states) or stabilizes (making it
  an allocation problem that more states could solve).

- If the displacement range stabilizes, the exchange rate from
  TRAVERSE Step 5 is the cost of buying enough states to match
  the stable displacement budget. If it grows, the exchange rate
  diverges and the wall is a hard structural limit of the FSM family.

## Findings so far

### W1 result: wall is not chord displacement (2026-03-21)

Best-donor excess is 10–17x smaller than wall excess. Adjacent cells'
free intercepts are nearly interchangeable. The wall is a fan-out
problem, not a chord-borrowing problem.

### Displacement structure (2026-03-21)

- LI displacement correlates with position (r=0.57 geometric, 0.39
  uniform). LD breaks this correlation (r≈0).
- Final residue state does NOT explain displacement.
- Layer 0 dominates: its delta serves all cells, creating systematic
  displacement. LD middle layers pull back, cutting the range ~50%.
- The per-layer delta magnitudes are uniform under LI (same ±range
  at every layer). Under LD, early layers have large range, the final
  layer has tiny range — the optimizer front-loads corrections.

## Data dependencies

- `lib/day.sage`: `cell_logerr_arb`, `path_intercept`
- `lib/partitions.sage`: `build_partition`
- `lib/optimize.sage`: `free_per_cell_metrics`
- `keystone_runner.sage`: `compute_case`

## Success condition

The plan has paid off when:
- W1 is resolved: the wall is not chord displacement (done)
- We know how the fan-out displacement scales with depth and q
- That scaling behavior connects to TRAVERSE Step 5: either as
  a finite exchange rate (displacement stabilizes) or a hard limit
  (displacement grows with cell count)
