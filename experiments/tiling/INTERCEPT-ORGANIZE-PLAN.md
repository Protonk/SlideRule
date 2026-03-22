# Intercept Organisation Claim

## The distinction

K1a: on geometric, all cells have the same worst-case error (minimax
value). But the intercept c* that achieves that minimax varies across
cells. Error = height of the landscape at the optimum. Intercept =
position of the optimum in parameter space. K1a controls the first.
The question is what controls the second.

## What we established (steps 1–3)

Steps 1–3 of the basis-identification program are complete.
See `results/basis_identification/basis_holdout_summary.md` for
detailed results. Summary:

- **H_width eliminated.** Adversary holdout NRMSE 1.57. Width does
  not explain the residual.
- **ε(m) is the first-order organiser.** H_value (1 feature) gets
  adversary holdout corr 0.86, NRMSE 0.45.
- **H_balance wins the ranking** (d6+ NRMSE 0.46), but the margin
  over H_value is only 0.026 NRMSE. The extra signal is
  endpoint-balance geometry from the Day candidate structure.
- **Affine-detrended geometric: corr > 0.999, NRMSE < 0.03.** The
  nonlinear part of c* on geometric is almost perfectly ε.
- **PC template stable across depths** (corr > 0.995, ~67% variance).
- **H_jet = H_jet_mc.** Pointwise vs cell-average does not matter.

## Step 4: position-scrambled adversaries

### Design

Full construction, test design, and interpretation matrix are in
[`SCRAMBLE-PLAN.md`](SCRAMBLE-PLAN.md). Summary:

Source widths from **geometric_x** (not uniform — uniform has equal
widths, nothing to permute). Two scrambles hold the width histogram
constant and permute the width-to-position assignment:

- **`peak_swap`**: narrowest widths at positions nearest m*, widest
  at boundaries. Inverts geometric's natural coupling. Mandatory
  re-ranking iteration to handle midpoint drift from narrow cells.
- **`peak_avoid`**: widest widths at positions nearest m*, narrowest
  at boundaries. Maximises width-ε coupling.

Implemented as `scramble_x` with `scramble_mode` parameter. Uniform-
sourced scramble as a free sanity control (should reproduce
uniform_x exactly).

### What the scramble tests

Not "position vs width" in full generality — position and ε are the
same thing. The scramble tests: "does the specific width that lands
at position m matter, or only the position itself?"

### Key predictions

- **peak_swap + H_value holds**: clean finish for T3. Width is
  irrelevant to the template despite inverting the natural coupling.
- **H_value breaks on peak_avoid, holds on peak_swap**: the forcing
  is positional, but expressing it requires adequate resolution
  where ε is large. Second-order coupling, not refutation.
- **H_value breaks, H_balance holds**: the 0.026 NRMSE margin is
  load-bearing. ε(m_mid) was proxying for balance geometry.
  Surprising.

## Step 5: Path 2 or more adversaries?

The basis results point toward Path 2 (local asymptotic model).
H_balance winning means the Day candidate structure is already
visible in the data. The term structure of a Taylor expansion
c*(m, w) ≈ c₀(m) + c₁(m)·w + ... is anticipated by the basis
competition: c₀ tracks ε (H_value), the corrections track balance
features (H_balance margin).

Decision depends on step 4:
- If scrambles confirm position dominance → Path 2 is the clear
  next move.
- If scrambles reveal strong width × position coupling → more
  adversaries first, to map the coupling before modelling it.

## T3 registration (ready)

The first gate has passed. c* is not flat on geometric, the
affine-detrended residual tracks ε at corr > 0.999, and the basis
comparison confirms ε as first-order organiser across 7 partitions.

**T3. The within-half variation of c* is primarily organised by
pointwise ε, not by cell-width distribution**

Status: supported.
Tested in: `tiling/basis_identification` (steps 1–3).
Question: After Π₀ projection, is the residual of c* predicted by
ε(m_mid) across partitions with different cell-width distributions?
Current answer: Yes. H_value (single feature ε(m_mid)) achieves
adversary holdout corr 0.86. H_width is eliminated. Endpoint-balance
geometry (H_balance) adds a correction of 0.026 NRMSE. On
affine-detrended geometric, corr > 0.999.
