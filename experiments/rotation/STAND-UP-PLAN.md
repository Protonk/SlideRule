# Stand-Up Plan: Rotation Check

Implementation plan for the Test of Charybdis
([`reckoning/THE-TEST-OF-CHARYBDIS.md`](../../reckoning/THE-TEST-OF-CHARYBDIS.md)).

---

## Design decisions

These are settled before implementation begins.

**Subspace dimension.** Use rank(B\_fsm), not raw column count.
Detect rank via SVD with relative cutoff `rank_tol = 1e-10`
against the top singular value. Record rank\_tol and computed p
in every output row.

**Canonical cell ordering.** All vectors (δ\*, B columns, ε values,
Walsh input) are in lexicographic bits order: cell j corresponds
to `index_to_bits(j, depth)`, MSB first. The Walsh-Hadamard
transform uses this same ordering as the Boolean cube coordinate.

**Target identification.** δ\* is the free intercept field c\* from
`free_per_cell_metrics`.

**L∞ tie-breaker.** Among L∞ minimizers, take the one minimizing
‖δ\* − Bα‖₂ (the residual L2 norm, not ‖α‖₂). This is
basis-invariant.

**Walsh: raw and normalized.** Compute and store both raw level
weights W^k and the normalized profile P^k = W^k / Σ\_j W^j. The
normalized profile is the primary shape diagnostic; the raw
weights carry wall-magnitude information and are secondary.

**ξ\_n tie policy.** SciPy's `chatterjeexi` breaks ties in the x
argument arbitrarily. Since ε(m\_mid) can produce ties, add
seeded uniform jitter of magnitude ~1e-12 × max(ε) to ε values
before computing ξ\_n. Generate the jittered ε vector once per
configuration from `xi_tie_seed` and reuse it for the FSM and
every random subspace in that configuration. Record
`xi_tie_seed` in every output row.

**Descriptive, not classificatory.** Report quantiles and z-scores.
No automatic "typical/atypical" labels. Interpretation happens
when a human reads the results.

---

## Step 1. Update the spec

Push the six design decisions into
[`reckoning/THE-TEST-OF-CHARYBDIS.md`](../../reckoning/THE-TEST-OF-CHARYBDIS.md)
so that the reckoning and this plan agree before any code is
written.

1. **§2, statistic 3 (Walsh).** Where W^k is introduced, add: the
   normalized profile P^k = W^k / Σ\_j W^j is the primary shape
   diagnostic. Raw W^k is confounded with wall magnitude.

2. **§2, "Why ξ\_n".** Add: SciPy's `chatterjeexi` breaks ties in x
   arbitrarily. Since ε(m\_mid) can produce ties, add seeded
   uniform jitter of magnitude ~1e-12 × max(ε) before computing
   ξ\_n. Record the jitter seed.

3. **§4, top.** Add a one-line note: the outcome cells are
   interpretive guidance. The experiment reports quantiles and
   z-scores, not automatic labels.

4. **§2, setup.** Change "dim(S) = p (the parameter count)" to
   "dim(S) = p = rank of the parameter-to-correction map,
   detected by SVD with relative cutoff 1e-10 against σ\_max."

5. **§2, L2 tie-breaker.** Make explicit: minimize ‖δ\* − Bα‖₂
   (the residual), not ‖α‖₂. Note that this is basis-invariant.

6. **§2, setup.** Add: δ\* is identified with the free intercept
   field c\* from the per-cell LP.

## Step 2. Build the extraction layer

Write a function that, given (q, depth, partition\_kind,
layer\_mode), returns (delta\_star, Q\_fsm, p) with all vectors in
canonical bits order.

Work:

- Call `build_intercept_matrix` to get B\_fsm.
- Compute orthonormal basis for im(B\_fsm) via SVD with the
  declared rank\_tol. Record p = rank.
- Extract c\* from `free_per_cell_metrics`. This is δ\*.
- Build ε(m\_mid) vector from partition rows, same ordering.
- Verify: all vectors have length 2^d, indexed by
  `index_to_bits(j, depth)`.

## Step 3. Build projection and statistics

Three pieces of computational machinery:

**linf\_project(delta\_star, B).** Solve the LP

    min t  subject to  −t ≤ δ* − Bα ≤ t

for arbitrary B. Then fix t\* and solve the QP/constrained
minimization

    min ‖δ* − Bα‖₂  subject to  ‖δ* − Bα‖_∞ ≤ t*

to get the tie-broken residual. Returns (wall, residual).

**random\_subspace(n, p, rng).** Random n×p orthonormal matrix Q
via QR of a Gaussian matrix. Seed controlled.

**charybdis\_stats(delta\_star, B, eps\_jittered).** Wires together:

1. Wall magnitude from linf\_project.
2. ξ\_n: `chatterjeexi(eps_jittered, abs_residual)`.
3. Walsh: fast Hadamard of residual, normalize by 2^{−d},
   compute W^k and P^k = W^k / Σ W^j.

The jittered ε vector is passed in, not generated internally.
Returns (wall, xi, W\_raw, P\_norm).

## Step 4. Validate

Run before any ensemble. Gate for Step 5.

1. **Rank stability.** Construct B with known redundant columns.
   Recovered p matches expected rank.
2. **Basis invariance.** Compute wall and residual for B and for
   BR where R is a random orthogonal matrix. Same wall, same
   residual up to numerical solver tolerance (the L2 tie-break
   is basis-invariant, so the only discrepancy is solver noise).
3. **Parseval.** Σ\_k W^k equals 2^{−d} Σ\_j r\_j² (mean squared
   residual). Σ\_k P^k = 1.
4. **ξ\_n stability.** Synthetic case with tied ε values. Jittered
   ξ\_n is stable across seeds (variation < 0.01).
5. **LP correctness.** Synthetic instance with known L∞ projection
   (e.g., 1-d subspace). Wall and residual match hand computation.

All five pass → proceed to Step 5. Any failure → stop and debug.

## Step 5. Run the experiment

**Ensemble driver.** `charybdis_ensemble(delta_star, Q_fsm,
partition, n_draws, seed, xi_tie_seed)`:

1. Generate the jittered ε vector once from xi\_tie\_seed.
2. Compute FSM statistics via charybdis\_stats(delta\_star,
   Q\_fsm, eps\_jittered).
3. For each of n\_draws random subspaces: compute statistics
   with the same eps\_jittered.
4. Return FSM statistics and ensemble arrays.

Default n\_draws = 300.

**Reporting.** `charybdis_report(fsm_stats, ensemble_stats)`:

- Wall: quantile, z-score (NaN if ensemble std = 0).
- ξ\_n: quantile, z-score (NaN if ensemble std = 0).
- Walsh: per-level quantile for both W^k\_raw and P^k\_norm.
- No labels. Numbers only.
- Output: printed summary + CSV row.

**Sweep.** Run the ensemble across configurations:

- Depths: 5, 6, 7
- q: 2, 3, 4
- Partition kinds: geometric\_x, uniform\_x, harmonic\_x
- Layer modes: LI, LD

54 configurations. Output: `results/charybdis_sweep.csv`.

**CSV schema:**

```
depth, q, kind, layer_mode,
rank_tol, p, rng_seed, xi_tie_policy, xi_tie_seed,
wall_fsm, wall_quantile, wall_zscore,
xi_fsm, xi_quantile, xi_zscore,
W0_raw, W1_raw, ..., Wd_raw,
P0_norm, P1_norm, ..., Pd_norm,
W0_quantile, ..., Wd_quantile,
P0_quantile, ..., Pd_quantile
```

## Step 6. Document and clean up

- Create `experiments/rotation/ROTATION.md`: purpose, reading
  inward (THE-TEST-OF-CHARYBDIS, ABYSSAL-DOUBT §4), design
  decisions, scripts table, results layout, key findings (empty
  until results exist), reading outward.
- Update `README.md` layout tree if needed.
- Delete this plan.

---

## Script layout

```
experiments/rotation/
  ROTATION.md               Experiment documentation
  charybdis_check.sage      Single-configuration check (Steps 2–4)
  charybdis_sweep.sage      Multi-configuration sweep (Step 5)
  results/
    charybdis_sweep.csv      Sweep output
```

## Dependencies

- `lib/paths.sage` (residue\_paths)
- `lib/partitions.sage` (build\_partition, partition\_row\_map,
  index\_to\_bits)
- `lib/optimize.sage` (build\_intercept\_matrix, free\_per\_cell\_metrics)
- `lib/displacement.sage` (`eps_val`)
- `scipy.stats.chatterjeexi`
- `scipy.optimize.linprog` (L∞ stage)
- `scipy.optimize.minimize` with bounds (L2 tie-break stage)
- `numpy` (SVD/QR, RNG)

## What this plan does NOT cover

- Structured null families (Charybdis §6).
- Analytical power analysis (Charybdis §3).
- Walsh spectrum of δ\* itself.
