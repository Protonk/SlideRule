# Basis Identification: Holdout Summary

For experimental design: see `experiments/tiling/SCRAMBLE-PLAN.md`.
For the broader framework: see `experiments/tiling/TILING.md`.

## Ranking (d6+ NRMSE, partition holdout)

| Rank | Basis | d6+ NRMSE | Test corr | Test NRMSE | n features |
|------|-------|-----------|-----------|------------|------------|
| 1 | H_balance | 0.460 | 0.881 | 0.428 | 5 |
| 2 | H_jet | 0.474 | 0.866 | 0.450 | 3 |
| 3 | H_jet_mc | 0.474 | 0.866 | 0.450 | 3 |
| 4 | H_moment | 0.485 | 0.828 | 0.507 | 3 |
| 5 | H_value | 0.487 | 0.864 | 0.454 | 1 |
| 6 | H_peak | 0.498 | 0.858 | 0.463 | 3 |
| 7 | H_width | 0.883 | 0.169 | 1.569 | 5 |

## Three headline results

### 1. The affine-detrended geometric result is close to a theorem

On geometric partitions with affine trend removed, all ε-based
families score corr > 0.999, NRMSE < 0.03. H_width scores corr 0.08.

On a partition where KEYSTONE §1 guarantees equal error across cells,
the *nonlinear* part of c* is almost perfectly predicted by ε. This
is no longer a correlation — it is a functional relationship. The
scaling symmetry determines c* up to an affine ramp, and ε determines
the rest. This is close to a theorem-shaped claim for the geometric
case, even though the current evidence is numerical.

### 2. H_value tells the tiling story; H_balance tells the Day story

H_balance wins the ranking, but the interesting fact is that a single
scalar — ε(m_mid) — captures most of the signal. Going from 1 feature
to 5 buys 0.026 NRMSE. For the tiling argument, H_value is what
matters: the displacement field Δ^L = −ε is the first-order organiser
of c*.

The H_balance margin is interesting for a different reason: the extra
0.026 NRMSE comes from endpoint-balance geometry — whether m* falls
inside the cell, how ε differs at the two boundaries. This is the
correction architecture seeing the finite Day candidate set, not just
the smooth ε background. For Path 2 (local asymptotic model), this
gap is the signal. The leading term c₀(m) will track ε(m); the
correction terms will track balance features. The basis competition
has already given the term structure of the expansion before it is
derived.

### 3. The 33% unexplained PC variance is structured, not noise

PC1 captures ~67% of baseline variance, stable across depths
(cross-depth corr > 0.995). The remaining 33% is not noise — it is
partition-dependent modulation of the template. The overlay plots
show it: harmonic and mirror-harmonic have visibly different scales,
and the right half (m > 0.5) shows more partition-to-partition spread
than the left half.

This 33% is where the width × position interaction lives. It is
subdominant, which is why H_width lost, but it is not zero, which is
why H_balance beats H_value. A complete model of c* needs both the
ε-driven positional template and the partition-dependent modulation.

## What is decisively established

- **Width alone does not explain the residual.** H_width fails on
  adversary holdout (NRMSE 1.57, corr 0.17). Eliminated.
- **ε(m) is the first-order organiser of c*.** H_value with one
  feature captures corr 0.86 on adversary holdout.
- **The template is stable.** PC1 shape correlations > 0.995 across
  depths 6-8. Depth holdout confirms all ε-based families generalise
  (test corr > 0.83).
- **H_jet and H_jet_mc are identical.** The pointwise-vs-cell-average
  distinction is empirically zero on this data.

## What remains open

- The affine-detrended geometric result invites an analytic proof
  that c*'s nonlinear residual equals (a functional of) ε. This
  may be tractable through the Day candidate structure.
- The 33% unexplained PC variance needs a model. It is structured
  and partition-dependent, not random.
- No second binary architecture has been tested. The forcing is
  architecture-free (it is a property of c*, not of any corrector),
  but whether different architectures absorb it with similar
  efficiency is still untested.

## Implications for DISTANT-SHORES

**Step 5:** There is now a concrete, empirically validated forcing
function. The exchange rate question becomes: how does the FSM's wall
respond to this known forcing as structural cost increases? The
staircase prediction from TILING.md — that the exchange rate is
non-smooth because cells near the ε peak cluster at similar
displacement values — is directly testable.

**Step 6:** The forcing is architecture-free (a property of c*
organised by ε, not of any particular corrector). Any binary-
representation architecture targets the same c* field. The question
is whether different architectures absorb this forcing with similar
efficiency — a much more precise question than "is the cost measure
architecture-invariant?"
