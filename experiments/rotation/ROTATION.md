# Rotation

Purpose: test whether the FSM's wall is special relative to random
subspaces of the same dimension — the Test of Charybdis.

Reading inward: depends on
[`CHARYBDIS.md`](../../reckoning/CHARYBDIS.md)
for the experimental design and
[`ABYSSAL-DOUBT.md`](../../reckoning/ABYSSAL-DOUBT.md) §4 for the doubt
this experiment responds to.

---

## Design decisions

**Subspace dimension.** Use rank(B\_fsm) via SVD with relative cutoff
`rank_tol = 1e-10` against the top singular value.

**Canonical cell ordering.** All vectors are in lexicographic bits order:
cell j corresponds to `index_to_bits(j, depth)`, MSB first.

**Target identification.** δ\* is the free intercept field c\* from
`free_per_cell_metrics`.

**L∞ projection.** The LP returns a vertex solution. If the
unconstrained least-squares solution happens to satisfy the L∞
constraint, it is used instead (L2 tie-break). In practice, the LS
solution never satisfies the constraint: the LP solution was used for
all 72 FSM projections and all 21,600 ensemble draws. The
`used_fallback` flag records this. Wall magnitude is unaffected (both
paths achieve the same t\*); ξ\_n and Walsh profiles are computed from
the LP vertex residual.

**Walsh: raw and normalized.** Both raw level weights W^k and the
normalized profile P^k = W^k / Σ W^j are computed. The normalized
profile is the primary shape diagnostic.

**ξ\_n tie policy.** Add seeded uniform jitter of magnitude ~1e-12 ×
max(ε) to ε values before computing ξ\_n. The same jittered ε vector is
generated once per configuration and reused for the FSM and all random
draws. Seed recorded in every output row.

**Descriptive, not classificatory.** Reports quantiles and z-scores. No
automatic "typical/atypical" labels.

---

## Scripts

| Script | Description |
|--------|-------------|
| `charybdis_check.sage` | Extraction layer + projection + statistics + validation tests |
| `charybdis_sweep.sage` | Multi-configuration ensemble sweep |
| `adversary_sweep.sage` | Adversary partition sweep (6 partitions × d=7,8) |
| `charybdis_plots.sage` | Wall scaling and ξ\_n sign map plots |

Run any with `./sagew experiments/rotation/<script>`.

Running `charybdis_check.sage` directly executes the validation battery
(Part A: extraction, Part B: Step 4 validation). Running
`charybdis_sweep.sage` runs the full ensemble sweep.

To load the functions without running self-tests or the sweep:

```python
_CHARYBDIS_NO_SELFTEST = True
_SWEEP_NO_RUN = True
load(pathing('experiments', 'rotation', 'charybdis_check.sage'))
load(pathing('experiments', 'rotation', 'charybdis_sweep.sage'))
```

---

## Results layout

```
results/
  charybdis_sweep.csv       72 configurations × 300 random draws
  adversary_sweep.csv       12 adversary configurations × 300 draws
  wall_zscore_scaling.png   Wall z-score vs depth (LI/LD facets)
  xi_signmap_d8.png         ξ_n z-score heatmap at depth 8
```

**CSV schema:**

```
depth, q, kind, layer_mode,
rank_tol, p, rng_seed, xi_tie_policy, xi_tie_seed,
n_draws, n_fallbacks_fsm, n_fallbacks_ensemble,
wall_fsm, wall_quantile, wall_zscore,
xi_fsm, xi_quantile, xi_zscore,
W0_raw, ..., Wd_raw,
P0_norm, ..., Pd_norm,
W0_quantile, ..., Wd_quantile,
P0_quantile, ..., Pd_quantile
```

Sweep parameters: depths 5–8, q ∈ {2, 3, 4}, partition kinds
{geometric\_x, uniform\_x, harmonic\_x}, layer modes {LI, LD}.

---

## Key findings

### Wall magnitude: FSM is always atypical

The FSM achieves a much smaller wall than random subspaces of the same
dimension in all 72 configurations (quantile = 0.000 everywhere). The
z-scores grow with depth:

| Depth | n | Typical wall z-score range |
|-------|---|---------------------------|
| 5 | 32 | −8 to −75 |
| 6 | 64 | −27 to −235 |
| 7 | 128 | −94 to −1118 |
| 8 | 256 | −305 to −4027 |

The FSM's orientation in ℝ^n is special. A random subspace of the
same dimension does not come close to the same L∞ approximation quality.

### ξ\_n: atypical, direction depends on configuration

At depth ≥ 7 (n ≥ 128), ξ\_n resolves clearly in almost all
configurations, but with mixed sign:

- **Positive z** (FSM residual more ε-structured than random):
  LD mode, and geometric/uniform with q ≥ 3 under LI.
- **Negative z** (FSM residual less ε-structured than random):
  harmonic\_x with q = 3, and q = 2 LI at higher depths.

The sign depends on (kind, q, layer\_mode) in a structured way. This
is a richer finding than uniform atypicality: the FSM is special, but
*how* it relates to the ε forcing differs across partition geometries.

At depth 5 (n = 32), many ξ\_n values are in the typical range. This
is a power issue: ξ\_n needs more cells to discriminate.

### Walsh spectral profile

Walsh energy concentrates at levels 1–2 across most configurations.
For q = 3 with LI, energy leaks into levels 3–5, reflecting the
interaction between the mod-3 automaton and binary addressing. The
Walsh profile has not yet been systematically compared against the
ensemble at each level.

### Residual selection

The LP vertex solution was used in all 72 FSM and 21,600 ensemble
projections (the unconstrained LS solution never satisfies the L∞
constraint). Wall magnitude is unaffected: it equals t\* regardless
of which L∞ minimizer is selected. ξ\_n and Walsh profiles depend
on the cellwise residual, not just t\*, so they are computed from
the LP vertex residual rather than an L2-tie-broken residual.

For random subspaces the L∞ minimizer is generically unique (the LP
has a non-degenerate vertex), so the distinction is moot. For the
FSM's structured matrix, degeneracy is possible in principle but
was not observed.

---

## Reading outward

- [`CHARYBDIS.md`](../../reckoning/CHARYBDIS.md):
  the experimental design.
- [`ABYSSAL-DOUBT.md`](../../reckoning/ABYSSAL-DOUBT.md) §4: the doubt
  this experiment addresses.
- [`TRAVERSE.md`](../../reckoning/TRAVERSE.md) Step 2: the wall's
  status.
- [`TILING.md`](../tiling/TILING.md): the displacement field that
  organises δ\*.
