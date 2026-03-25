# Spectral Plan

Implementation plan for the standalone Walsh experiment described in
[`SPECTRAL.md`](./SPECTRAL.md).

This plan assumes the existing Charybdis infrastructure is available:

- extraction layer from [`../charybdis_check.sage`](../charybdis_check.sage);
- ensemble driver pattern from [`../charybdis_sweep.sage`](../charybdis_sweep.sage).

What changes here is the center of gravity: Walsh is primary, so the
outputs and saved artifacts must support spectral analysis directly.

---

## Feasibility

Benchmarked on this machine (2026-03-24):

| Depth | n | Extract (s) | Per draw (s) | Est 500 draws (s) |
|-------|------|-------------|-------------|-------------------|
| 9 | 512 | 2.7 | 0.012 | 9 |
| 10 | 1024 | 5.5 | 0.019 | 15 |

All five Phase A partitions extract successfully at d=9.
Estimated Phase A runtime: 25 configs × ~9s = ~4 minutes.
Estimated Phase B runtime: 15 configs × ~18s (1000 draws) = ~5 minutes.
Estimated Phase C runtime: 10 new LD configs × ~9s = ~2 minutes.

No infrastructure changes are needed.

---

## Phase Table

### Phase A: Main Walsh sweep

- Depth: `9`
- q: `2, 3, 4, 5, 6`
- Mode: `LI`
- Partitions:
  - `geometric_x`
  - `uniform_x`
  - `harmonic_x`
  - `reverse_geometric_x`
  - `bitrev_geometric_x`

`25` configurations.

### Phase B: Ensemble tightening

- Depth: `9`
- q: `2, 3, 4, 5, 6`
- Mode: `LI`
- Draws: `1000` (double Phase A)
- Partitions:
  - `geometric_x`
  - `reverse_geometric_x`
  - `bitrev_geometric_x`

`15` configurations. Same depth as Phase A but with a tighter
ensemble, focused on the geometry/placement axis.  This tests whether
the Phase A shape findings are stable under a larger null sample
rather than at a deeper depth.

### Phase C: Sharing contrast

- Depth: `9`
- q: `3, 4`
- Modes: `LI`, `LD`
- Partitions: same five as Phase A

`20` configurations. Of these, 10 (the LI half) overlap with Phase A.
If Phase A has already run, Phase C adds only the 10 LD configurations.

q=3 is the anomalous case; q=4 is the comparison because the d=8
sweep showed it has intermediate tail mass (between q=2's zero and
q=3's maximum).

Total unique configurations if all phases run: `50` (`60` minus `10`
Phase A/C overlap).

---

## Draw Count

Use:

- `500` draws for Phase A;
- `400` draws for Phases B and C unless runtime forces a reduction.

For this experiment, spend budget on the ensemble rather than on a
larger partition zoo.

---

## Step 0. Feasibility gate

Before writing any new code, verify:

1. `extract_charybdis_config` succeeds for all 5 Phase A partitions
   at d=9 and the 3 Phase B partitions at d=10.
2. `walsh_spectrum` produces the correct number of levels (d+1) at
   d=9 and d=10.
3. Parseval holds at the new depths.

Run the existing `charybdis_check.sage` self-test, then spot-check
one d=9 and one d=10 config.  Do not proceed to Step 1 until this
passes.

---

## Step 1. Extend the spectral objects

Add helpers that compute Walsh spectra for:

- `ε`;
- `δ*`;
- `r_FSM`;
- each `r_rand`.

For each object, compute both:

- `W_raw`;
- `P_norm`.

Also compute three derived shape summaries from `P_norm`:

- spectral centroid: `c = Σ_k k · P^k`.  Measures the average
  interaction order.  A centroid of 1.5 means energy is concentrated at
  low-order bit interactions; a centroid near d/2 means energy is
  diffuse across all orders.
- spectral entropy: `H = −Σ_k P^k log₂ P^k` (with 0 log 0 = 0).
  Measures how spread the profile is.  Low entropy means energy is
  concentrated at a few levels; high entropy means it is distributed.
- tail mass: `T = Σ_{k≥4} P^k`.  The fraction of Walsh energy at
  interaction order 4 or higher.  This is the quantity that was
  strikingly nonzero for q=3 in the Charybdis sweep.

These should be computed in one place so the same definitions are used
for FSM, target, and ensemble objects.

Note: `P(ε)` and `P(δ*)` are Walsh transforms of the raw vectors ε
and δ\*, not of any L∞ residual.  They measure the bit-interaction
content of the forcing field and target field themselves.  The residual
spectrum `P(r)` is the Walsh transform of `δ* − proj`, which is
the L∞ projection residual as in the Charybdis sweep.

---

## Step 2. Define the shape statistic cleanly

Choose one primary shape statistic and one secondary check.

Primary:

- Jensen-Shannon divergence to a leave-one-out reference profile.

Secondary:

- cosine similarity to the same reference profile.

The null must be matched to the statistic:

- if `d_FSM = JSD(P_FSM, P_bar)`,
- then the ensemble null should be `d_i = JSD(P_rand_i, P_bar^{(-i)})`.

Do not compare FSM-to-reference against a pairwise draw-to-draw
distribution.

Implementation note: with 500 draws, the leave-one-out correction
`P_bar^{(-i)}` differs from the full `P_bar` by O(1/500) at each
level.  It is worth implementing correctly (the cost is negligible:
`P_bar^{(-i)} = (n * P_bar − P_rand_i) / (n − 1)`), but if the
FSM's JSD is far from the ensemble, the correction will not matter.

JSD requires positive entries.  If any `P^k = 0` for a draw, add
a floor of `1e-15` and renormalize before computing JSD.  Record
the floor value in the CSV metadata.

---

## Step 3. Build a dedicated spectral sweep

Create a new script, for example:

`experiments/rotation/spectral/spectral_sweep.sage`

For each configuration:

1. extract `δ*`, `Q_fsm`, `eps_vec`, and metadata;
2. compute `P_eps` and `P_delta_star`;
3. generate the shared jittered `ε` vector once;
4. compute FSM residual statistics and spectrum;
5. compute the ensemble residual spectra;
6. build the shape-statistic null;
7. write summary row plus per-config sidecar.

The summary row should include wall and `ξ_n` metadata, but the
spectral fields are the main payload.

---

## Step 4. Emit the right artifacts

### Summary CSV

One row per configuration with:

- configuration metadata:
  `depth, q, kind, layer_mode, n_draws, rank_tol, rng_seed, xi_tie_seed`;
- metadata diagnostics:
  `wall_fsm, wall_quantile, wall_zscore, xi_fsm, xi_quantile, xi_zscore,
   n_fallbacks_fsm, n_fallbacks_ensemble`;
- FSM spectral summaries:
  `centroid_fsm, entropy_fsm, tailmass_fsm`;
- ensemble spectral quantiles/z-scores for those same summaries;
- shape statistic summary:
  `shape_stat_name, shape_fsm, shape_quantile, shape_zscore`.

### Sidecar per configuration

Use `.npz`.  Filename: `spectral_<depth>_<q>_<kind>_<mode>.npz`.
Must include:

- `P_eps` (d+1,), `W_eps` (d+1,) — Walsh spectrum of ε vector;
- `P_delta_star` (d+1,), `W_delta_star` (d+1,) — Walsh spectrum of δ\*;
- `P_fsm` (d+1,), `W_fsm` (d+1,) — Walsh spectrum of FSM residual;
- `ensemble_P_norm` (n\_draws, d+1) — normalised profiles for all draws;
- `ensemble_W_raw` (n\_draws, d+1) — raw level weights for all draws;
- `shape_null` (n\_draws,) — leave-one-out shape statistic for each draw;
- `wall_rand` (n\_draws,), `xi_rand` (n\_draws,) — wall and ξ\_n arrays.

The sidecar is required, not optional.  Without it, the shape plots
and inherited-vs-induced comparison cannot be reproduced.

---

## Step 5. Build the first plots

### Plot A: q-scan stacked bars

For Phase A and Phase B:

- x-axis: `q`;
- stacked fractions: `P^k_FSM`.

Do not overlay ensemble lines on the same stacked bars. Put the
ensemble median profile in a companion panel or adjacent table.

### Plot B: geometry versus placement

At fixed `d = 9`, compare:

- `geometric_x`;
- `reverse_geometric_x`;
- `bitrev_geometric_x`.

This should be the cleanest placement/address plot.

### Plot C: inherited versus induced spectrum

For selected configurations, show:

- `P(ε)`;
- `P(δ*)`;
- `P(r_FSM)`;
- ensemble median `P(r_rand)`.

This is the plot that answers whether the residual spectrum is being
inherited or created.

### Plot D: shape-statistic null

Histogram or density plot of the draw-to-reference null with the FSM
score marked.

---

## Step 6. Sequence of execution

Recommended order:

1. Phase A first.
2. Inspect q-dependence and geometry/placement separation.
3. If Phase A is informative, run Phase B.
4. Run Phase C only after the main picture is stable enough that `LI`
   versus `LD` is worth interpreting.

Do not run all phases blindly before checking whether the Phase A
design is actually answering the intended question.

After Phase A, check:

1. Does q=3 still show anomalous tail mass at d=9?  If not, the
   depth-8 finding may be a finite-depth artifact and Phase B is
   essential.
2. Do `reverse_geometric_x` and `bitrev_geometric_x` separate?
   If their profiles are indistinguishable, geometry-vs-placement
   is not the right axis and Phase B's partition choice may need
   revision.
3. Is the shape statistic (JSD or cosine) discriminating?  If the
   FSM's JSD is within the bulk of the null, per-level quantiles
   may be telling the whole story and the shape machinery adds
   nothing.
4. Is `P(r_FSM)` visually different from `P(ε)` and `P(δ*)`?  If
   the residual spectrum looks like a scaled copy of the target
   spectrum, the "induced" hypothesis is dead and Plot C will be
   boring.

---

## What This Plan Does Not Cover

- adversarial partitions such as `farey_rank_x`, `stern_brocot_x`,
  `cantor_x`, or `random_x`;
- the broader Charybdis question of wall typicality;
- structured null families beyond the Grassmannian ensemble;
- Haar/prefix-tree replacements for Walsh.

Those belong elsewhere.
