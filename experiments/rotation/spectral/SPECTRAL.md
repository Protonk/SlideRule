# Spectral

Purpose: isolate the Walsh structure in the Charybdis residuals
without making Walsh carry the wall experiment's whole burden.

This is a spectral-anatomy experiment, not an adversary experiment.
The question is not "which partitions hurt the FSM most?" It is:

- what controls the residual's interaction-order profile on the address cube;
- whether the observed high-order Walsh mass is driven mainly by `q`,
  by partition geometry, by address placement, or by sharing mode;
- how much of the residual spectrum is inherited from `ε` or `δ*`,
  and how much is created by the shared minimax approximation.

---

## Why Separate It

The rotation sweep already computes Walsh profiles, but there Walsh is
one statistic among several. Here Walsh becomes the primary object.

That changes the design:

- `wall` and `ξ_n` are retained as metadata, not as the main outcome;
- the upstream spectra `P(ε)` and `P(δ*)` are computed alongside the
  residual spectrum `P(r_FSM)`;
- per-draw sidecars are required, because profile-shape questions
  cannot be answered from a summary CSV alone.

---

## Main Questions

### 1. q-dependence

Does the high-order Walsh mass grow with `q`, or is `q = 3` special?

### 2. Geometry versus placement

How much does the spectrum care about:

- smooth partition geometry (`geometric_x`, `uniform_x`, `harmonic_x`);
- spatial reversal with the same width multiset (`reverse_geometric_x`);
- address scrambling with the same width multiset (`bitrev_geometric_x`)?

### 3. Sharing versus capacity

Does the spectrum change mainly because the reader has bounded width,
or because sharing is imposed? This is the `LI` versus `LD` contrast.

### 4. Inherited versus induced spectrum

Is the residual spectrum already visible in `ε` or `δ*`, or does the
shared minimax projection create a qualitatively different Walsh shape?

---

## Chosen Design

### Phase A: Main Walsh sweep

This is the discovery pass.

- Depth: `d = 9`
- q: `2, 3, 4, 5, 6`
- Mode: `LI` only
- Partitions:
  - `geometric_x`
  - `uniform_x`
  - `harmonic_x`
  - `reverse_geometric_x`
  - `bitrev_geometric_x`
  - `stern_brocot_x`

This is `30` configurations.

Five partitions vary interpretable axes without importing the
adversarial story:

- `geometric_x`: multiplicative/log baseline;
- `uniform_x`: additive baseline;
- `harmonic_x`: smooth left-packed baseline;
- `reverse_geometric_x`: same geometric widths, different spatial placement;
- `bitrev_geometric_x`: same geometric widths, different address placement.

`stern_brocot_x` is imported from the adversary sweep, where it
produced an anomalous Walsh profile at d=8 (energy at levels 5 and 7).
It is included to check whether that pattern persists at d=9 and
across q values.

### Phase B: Ensemble tightening

This is the stability pass.

- Depth: `d = 9`
- Draws: `1000` (double Phase A)
- q: `2, 3, 4, 5, 6`
- Mode: `LI` only
- Partitions:
  - `geometric_x`
  - `reverse_geometric_x`
  - `bitrev_geometric_x`

This is `15` configurations.

Its purpose is not discovery. It checks whether the Phase A shape
findings are stable under a larger null sample, focused on the
geometry/placement axis.

### Phase C: Sharing contrast

This is the mechanism pass.

- Depth: `d = 9`
- q: `3, 4`
- Modes: `LI`, `LD`
- Partitions: the same six as Phase A

This is `20` configurations.

Its purpose is to ask whether the interesting Walsh structure is really
about shared-prefix constraint or just about the automaton family.

---

## Primary Objects

For each configuration, compute spectra for:

- `ε`;
- `δ*`;
- `r_FSM`;
- `r_rand` over the Grassmannian ensemble.

The normalized Walsh profile

`P^k = W^k / Σ_j W^j`

is the primary shape object. Raw `W^k` is still recorded, but it is
secondary because it mixes shape with total residual magnitude.

---

## Primary Statistics

### 1. Shape distance

Pick one reference profile `P_bar`, typically the ensemble mean, and
compare the FSM to the matching draw-to-reference null.

Primary choice:

- Jensen-Shannon divergence to a leave-one-out reference.

Secondary check:

- cosine similarity to the same reference.

The key discipline is null matching: do not compare FSM-to-reference
against an unrelated pairwise draw-to-draw distribution.

### 2. Descriptive spectral summaries

Record, at minimum:

- spectral centroid;
- spectral entropy;
- tail mass `Σ_{k≥4} P^k`;
- per-level quantiles.

These summaries make the shape legible even when the single-number
shape statistic is hard to interpret.

### 3. Metadata only

Keep these, but do not let them drive the spectral experiment:

- `wall_fsm`, `wall_quantile`, `wall_zscore`;
- `xi_fsm`, `xi_quantile`, `xi_zscore`;
- fallback counts.

---

## Required Outputs

Each configuration must emit:

- one summary CSV row;
- one sidecar file with per-draw data.

The sidecar should contain at least:

- `P_eps`, `W_eps`;
- `P_delta_star`, `W_delta_star`;
- `P_fsm`, `W_fsm`;
- `ensemble_P_norm`;
- ideally `ensemble_W_raw` as well;
- optional metadata arrays for `wall_rand` and `xi_rand`.

Without the sidecar, the Walsh shape experiment is not reproducible.

---

## What Success Looks Like

The most informative positive outcomes would be:

- `q = 3` remains spectrally unusual at `d = 9` and `d = 10`;
- `reverse_geometric_x` and `bitrev_geometric_x` separate cleanly,
  showing whether the spectrum is more sensitive to spatial placement
  or to address assignment;
- `P(r_FSM)` differs sharply from both `P(ε)` and `P(δ*)`, showing that
  the shared minimax projection is creating structure rather than only
  inheriting it;
- `LI` and `LD` diverge in a way that localizes the effect to sharing.

The most informative negative outcome would be:

- the Walsh shape becomes generic once compared against the correct
  draw-to-reference null, in which case the current per-level findings
  are mostly a magnitude story.

---

## Reading Inward

- [`THE-TEST-OF-CHARYBDIS.md`](../../../reckoning/THE-TEST-OF-CHARYBDIS.md):
  why Walsh entered the project at all.
- [`ROTATION.md`](../ROTATION.md):
  the completed Charybdis sweep that motivates this follow-on.

## Reading Outward

- [`SPECTRAL-PLAN.md`](./SPECTRAL-PLAN.md):
  concrete execution plan.
- [`ADVERSARY-PLAN.md`](../ADVERSARY-PLAN.md):
  the separate partition-adversary program.
