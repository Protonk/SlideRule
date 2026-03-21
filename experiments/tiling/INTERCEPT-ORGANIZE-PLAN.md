# Intercept Organisation Claim

## The observation

The three adversary partitions (Group H) all failed to break the
Stage A residual correlation. This rules out a simple width-distribution
explanation for T1, but it does not rule out partition geometry as a
whole. Width histogram, boundary placement, and sampling density
against the ε profile are still entangled.

What the adversary failure does point toward: the within-half variation
of c* is not controlled by cell widths alone. Something positional is
organising c*, and that something correlates with ε.

## The distinction worth opening up

K1a says: on a geometric partition, all cells have the same worst-case
error. This is about the *value* of the minimax at each cell's optimum.

The new observation says: even on a geometric partition, the *location
of the optimum* (the intercept c* that achieves that minimax) varies
across cells. c* is not flat on geometric partitions. This is confirmed
by direct inspection.

These are different objects:
- Error = the height of the minimax landscape at the optimum
- Intercept = the position of the optimum in parameter space

K1a controls the first. The question is what controls the second.

## What we can say carefully

The within-half variation of c* is not explained by cell-width
distribution alone, and is primarily organised by position in ε.

We cannot yet say "determined by ε's curvature." The evidence says
"organised by position in ε" or "by a local functional of ε." It
does not isolate curvature specifically against value, slope, or
width effects. Those are entangled and need separating.

We also cannot say "no cell-width manipulation can eliminate the
shape." What we have ruled out is three specific width-distribution
attacks. A stronger adversary — one that preserves width statistics
but moves those widths to different positions relative to the ε
peak — would test the actual claim more directly.

## Execution priority

The immediate job is **not** to find better prose for "position in ε."
The immediate job is to replace that phrase with an explicit
model-selection problem.

This basis-identification work is now the primary branch of the plan.
The stronger adversaries and the local asymptotic model are both
important, but they should be driven by what the basis test does or
does not identify.

## Canonical comparison pipeline

T3 should be tested on a fixed observable, not on raw `c*`.

### Fitting surface (native coordinates)

For each cell j in a given partition/depth case:

1. Record midpoint mantissa `m_mid_j = (x_lo + x_hi)/2 − 1`.
2. Compute the free intercept field `c*`.
3. Remove the coarse within-half component:

       g_j = R0(c*)_j = c*_j − Π0(c*)_j

   where `Π0` is the same leading-bit projection used in Stage A.

The basis families are fitted to `(m_mid_j, g_j)` pairs in native
cell coordinates. No interpolation, no transport. Each partition's
cells contribute data points at their own midpoints. The basis
functions are evaluated at those same midpoints.

This is the primary claim surface. All scoring, training/holdout
splits, and coefficient comparisons happen here.

### Overlay visualisation (transported, separate file)

For visual comparison across partitions, a separate script
transports each partition's `g_j` to a common regular grid in `m`
via linear interpolation. This produces overlay plots showing
whether the transported residual shapes collapse onto a shared
template.

Transport is for visualisation only. It is never used as a fitting
surface, because interpolation artifacts on coarse partitions
(d=4: only 8 cells per half) would contaminate the fit.

Output: `basis_template_overlays.png` (separate from the fitting
results).

### Named diagnostic: affine-detrended geometric

On geometric partitions, c* should vary as an affine ramp (scaling
symmetry maps cells by affine shift in log-coordinate). The nonlinear
residual after removing that ramp is the cleanest isolate of what the
basis families are competing to explain.

Add `geometric_x` with affine detrending as a named row in the basis
observable table (column `detrend = affine`, alongside the standard
`detrend = Π0` rows). This is not a secondary robustness check — it
is a primary diagnostic that strips out the most structure and
exposes the purest signal.

### Other robustness checks

- Transport in `x` instead of `m`

These are diagnostics, not the primary claim surface.

## Basis-identification program (primary)

The phrase "position in ε" should be unpacked as a competition among
candidate basis families. The goal is to identify which family best
predicts the transported residual field `g`.

### Fit target

For each partition/depth case and each cell `j`, record:

- `m_mid_j`
- `width_x_j`
- `width_log_j`
- `g_j = R0(c*)_j`
- `ε(m_mid_j)`
- `ε'(m_mid_j)`
- `ε''(m_mid_j)`
- `mean_cell_eps_j`: cell-average of ε over [a, b]
- cell-moment summaries of `ε` (centered first and second moments)
- `contains_mstar_j`: boolean, whether m* = 1/ln2 − 1 falls inside
  the cell. This is a discrete variable that could drive a
  discontinuity in c* behavior. Record it as a column rather than
  discovering it post hoc.
- `dist_to_mstar_j`: signed distance from cell midpoint to m*

Primary fit target:

    g_j

Primary generalisation test:

- fit on a training set of baseline partitions/depths
- score on held-out adversaries and held-out depths

This is the important point: the winning basis should not just fit the
current cases; it should predict shape on partitions it did not see.

### Candidate basis families

| Label | Basis family | Exact observables | If it wins |
|---|---|---|---|
| `H_width` | width-only control | `width_x`, `width_log`, `width_x^2`, `width_log^2`, half label | The positional story is weak; current correlations may be width-mediated |
| `H_value` | local ε value | `ε(m_mid)` or cell-average `mean_cell ε` | The template is mostly a pointwise or cell-averaged ε profile |
| `H_peak` | distance to hard region | `m_mid - m*`, `|m_mid - m*|`, `(m_mid - m*)^2` where `m* = 1/ln 2 - 1` | The right language is proximity to the ε peak, not ε itself |
| `H_jet` | low-order local jet of ε | `ε(m_mid)`, `width · ε'(m_mid)`, `width^2 · ε''(m_mid)` | `c*` is organised by a local expansion in position and width |
| `H_moment` | cell functional of ε | `mean_cell ε`, centered first moment, centered second moment | The right object is not pointwise ε but how ε sits over the whole cell |
| `H_balance` | endpoint / candidate-balance geometry | `ε(a)`, `ε(b)`, `ε(a)-ε(b)`, `contains_mstar`, `dist_to_mstar` | The minimax optimizer is responding mainly to extremal-balance geometry |
| `H_jet_mc` | moment-corrected jet | `mean_cell_eps`, `width · ε'(m_mid)`, `width² · ε''(m_mid)` | Interpolates between H_jet and H_moment; shows whether the distinction matters |
| `H_template` | latent shared template | first PC of transported residuals across baseline partitions at each depth | There is a stable positional template, but its analytic basis is not yet identified |

Notes:

- `H_width` must be included as a real competitor, not just a strawman.
- `H_template` is extracted via first principal component of the
  transported residuals across all baseline partitions at each depth.
  One PC per depth, then check whether the PC shape is stable across
  depths. This is cheap and gives the template without committing to
  a parametric form.
- `H_jet` and `H_moment` are the bridges from the empirical template
  to the local asymptotic model. `H_jet_mc` interpolates between them
  to show whether the pointwise-vs-cell-average distinction matters
  or whether they are empirically indistinguishable on this data.
- `H_balance` uses the `contains_mstar` and `dist_to_mstar` columns
  to test whether the ε peak's relationship to cell boundaries drives
  a discrete discontinuity in c* behavior.

### Scoring

For each basis family, report:

- in-sample correlation and NRMSE after best scale fit
- held-out correlation and NRMSE (adversary holdout)
- held-out correlation and NRMSE (depth holdout)
- **depth-stratified scores**: report all metrics separately for
  d=4-5 vs d=6+ to avoid conflating basis quality with
  discretisation effects. At d=4 (8 cells per half), H_moment will
  outperform H_jet simply by being better-conditioned, not by being
  more correct.
- stability of fitted coefficients across depths
- whether one set of coefficients can be shared across partitions

Primary ranking criterion:

1. held-out NRMSE **at depths 6+** (primary)
2. held-out correlation at depths 6+
3. coefficient stability across depths
4. aggregate held-out NRMSE (secondary, reported but not ranking)

The ranking should prefer a slightly less accurate model with stable,
portable coefficients over a fragile high-variance fit. Depth-4
results are reported for completeness but do not drive model
selection.

### Pass / fail interpretations

- If `H_width` wins:
  the current positional story should be downgraded sharply.

- If `H_value` or `H_moment` wins:
  "position in ε" can be sharpened to a local scalar or cell-functional
  claim.

- If `H_peak` wins:
  the real organiser is the hard region near `m*`, not the whole ε
  profile.

- If `H_jet` wins:
  the next move should be Path 2, because the data is already pointing
  toward a local expansion `c*(m, w)`.

- If `H_balance` wins:
  the right language is not "basis function" but "candidate-balance
  geometry." The Day structure is then even more central than expected.

- If `H_template` wins while analytic bases lose:
  T3 survives as a stable-template claim, but the analytic organiser is
  still unknown.

- If no family generalises:
  the transported-template framing is probably wrong or incomplete.

### First experimental matrix

Run the basis comparison on:

- baseline kinds: `uniform_x`, `geometric_x`, `harmonic_x`,
  `mirror_harmonic_x`
- adversaries: `half_geometric_x`, `eps_density_x`, `midpoint_dense_x`
- depths: `4, 5, 6, 7, 8`
- target exponent: `1/2`

Training / holdout split:

- train on the four baseline kinds at depths `5, 6, 7`
- hold out the three adversaries entirely (partition holdout)
- secondary holdout: train on depths `5, 6`, test on `7, 8`
  (depth holdout)

Depth 4 is excluded from training because at 8 cells per half, the
basis functions are evaluated on very different effective support
than depths 6–8. Training on 4 and testing on 8 conflates "does the
basis generalise across depth?" with "does the basis tolerate
8-point-per-half discretisation?" Depth 4 results are still computed
and reported but do not enter the training set.

This turns the vague phrase "position in ε" into a concrete question:

> which candidate basis predicts the shared transported residual shape
> on partitions it has not seen?

## Structural follow-ups

### Path 1: Stronger adversaries (position-scrambled)

Build partitions that have the same width histogram as (say) uniform,
but place those widths at different positions relative to the ε
profile. This attacks position directly rather than width.

If c*'s within-half shape changes when widths move to different
positions, the organisation is a coupling between width and position,
not pure position. If the shape is stable under width-repositioning,
the organisation is genuinely positional.

This path should be informed by the basis results. In particular:

- if `H_peak` looks strong, build scrambles that move narrow cells
  toward and away from `m*`
- if `H_moment` looks strong, build scrambles that preserve width
  histograms but change cell-wise ε moments
- if `H_width` looks stronger than expected, build scrambles to test
  whether the apparent width effect survives transport

### Path 2: Local asymptotic model

Express c* for a small cell [a, b] as a function of midpoint m and
width w. The Day candidate structure gives the minimax error in
closed form for a cell. The optimal intercept is the c that
equalises the extremal candidates. For narrow cells, this should
admit a Taylor expansion:

    c*(m, w) ≈ c₀(m) + c₁(m) · w + c₂(m) · w² + ...

The leading term c₀(m) is the zero-width limit — the intercept for
an infinitesimally narrow cell at position m. If c₀(m) tracks ε(m)
(or some local functional of ε), that would be the structural
explanation. The width corrections c₁, c₂ would explain how
partition geometry modulates the shape without eliminating it.

This path is most urgent if `H_jet`, `H_moment`, or `H_balance` wins.
Those outcomes would mean the empirical basis test has already pointed
to a local structural law for `c*(m, w)`.

## Design choice status

T3 should not be stated about raw `c*`. Raw `c*` includes an affine
trend (overall slope from the function's global structure) that
would produce a spurious correlation with ε, recreating the mistake
the original naive test made.

Current choice:

- primary observable = transported `R0(c*)`
- secondary robustness checks = affine-detrended `c*` and transported
  raw `c*`

Rationale: the primary observable keeps continuity with Stage A and
removes only the coarse leading-bit component we already know is
degenerate.

Alternative choices still matter as robustness checks:

- **Affine detrending**: removes the global slope, tests whether the
  *curvature* of c* tracks ε. Clean, but may throw away real
  structure if c*'s trend is itself ε-organised.
- **Π₀ projection** (leading-bit step removal): removes only a
  piecewise-constant fit, preserving more structure. This is what
  Stage A already does, and is the natural continuation.
- **Position-transported comparison**: map all partitions' c* fields
  to a common midpoint coordinate (e.g., plog), then compare shapes
  directly. This preserves spatial arrangement, which CV-based
  comparisons throw away.

The third option is the most principled. It keeps position
information and allows cross-partition comparison on equal footing.

## Candidate hypothesis (draft, not yet registered)

**T3. After transport to a common position coordinate and removal of
the same coarse within-half component, the free intercept field c*
exhibits a stable positional template across partitions that is not
explained by cell-width distribution alone**

Question: After transporting each partition's c* field to a common
position coordinate and applying the same within-half detrending,
do the resulting shapes remain similar across partitions with very
different cell-width distributions, and can that shared template be
identified with a local functional of ε?

First gate: choose and fix a canonical comparison pipeline
(preferably position transport plus a common within-half projection),
then test whether geometric_x, half_geometric_x, uniform_x, and the
adversaries collapse onto the same template or not. The "is c* flat
on geometric?" check is only a sanity check, not the real
discriminator.

## Execution order

1. Fix the canonical observable and transport pipeline.
2. Build the basis-observable table for baseline kinds and adversaries.
3. Run the first basis-family comparison with held-out adversaries.
4. Use the winner to design stronger position-scrambled adversaries.
5. Only then decide whether the next step is more adversaries or the
   local asymptotic model.

This order matters. The basis test should drive the rest of the
program, not sit beside it.

## Expected outputs

### From `basis_identification.sage` (fitting, native coordinates)

- `basis_observables.csv`
  per-cell table with `m_mid`, widths, `g = R0(c*)`, and ε-derived
  features for all cases
- `basis_fit_summary.csv`
  per-model fit metrics: in-sample and held-out correlation, NRMSE,
  coefficient stability
- `basis_holdout_summary.md`
  short writeup of which basis families survived and what that means

### From `basis_overlay.sage` (visualisation, transported)

- `basis_template_overlays.png`
  transported residual fields on a common grid, with winning basis
  template overlaid

These outputs should be treated as core tiling artifacts, on the same
level as the Stage A/B/C/D result tables.

## Verified dependencies

The total integral ∫₀¹ ε(m) dm = 3/2 − 1/ln2 ≈ 0.05730 used in
`eps_density_x`'s CDF normalisation was verified both analytically
(boundary term algebra) and numerically (trapezoidal quadrature,
N=100000, agreement to 6e-12). The partition boundaries are correctly
specified.

## What this plan does NOT attempt

- A proof. The local asymptotic model (path 2) might yield one, but
  that is a later step.
- A claim about the shared intercept c_shared. This is about c* only.
- Hypothesis registration. T3 needs the first gate to pass before
  it earns a number in EXPERIMENTS.md.
