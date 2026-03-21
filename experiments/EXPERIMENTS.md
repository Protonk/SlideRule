Purpose: experiment directory map and hypothesis registry
Canonical for: what scripts exist, what questions they test, and what the project currently believes
Not for: run logs, numeric evidence tables, or implementation details

All scripts require SageMath; run from project root via
`./sagew experiments/<topic>/<script>.sage`.

# Experiments

## Experiment areas

### `keystone/`

Partition-comparison sweeps and the guiding thesis.
[`KEYSTONE.md`](keystone/KEYSTONE.md) contains the thesis and caveats.

Scripts: `partition_sweep`, `h1_sweep`, `inspect_case`,
`error_profile`, `wall_decomposition`, `gap_surface`,
`intercept_displacement`, `coordinate_uniqueness`, `surrogacy_test`,
`float_formats`, `compatibility_matrix`.

Tests: K1a, K1b, K1c, K2, H1, H1a–H1d

### `wall/`

Wall obstruction model: spatial diagnostics and exponent robustness.
[`WALL.md`](wall/WALL.md) defines the wall;
[`WALL-PLAN.md`](wall/WALL-PLAN.md) tracks current work.

Scripts: `enrich_summary`, `join_layer_modes`, `worst_cell_map`,
`wall_excess_ribbons`, `gap_collapse`, `candidate_phase_barcode`,
`exponent_robustness_sweep`.

Tests: K3

### `alternation/`

Sign-pattern analysis of shared vs free-per-cell intercept
displacement. Barcodes, RLE ribbons, split maps.
See [`ALTERNATION.md`](alternation/ALTERNATION.md).
Supports: K3 (sign structure predicts wall properties; future E5)

### `stepstone/`

Chord error structure and visualization. Why geometric partitions
equalize per-cell error, plus multi-partition profiles and fractal art.
Subfolders: `profiles/`, `fractal/`.
Exhibits: K1a mechanism (scale-equivariance -> equal cell difficulty)

### `damage/`

Foreign-error analysis: what happens when a cell uses another cell's
chord. Amplification ribbons, balance ratios, counterfactual profiles.
Supports: wall model (quantifies sharing cost per cell)

### `ripple/`

Coastline area across partition families. Scaled-area convergence,
wobble, and stability diagnostics.

## Shared utilities

- **`zoo_figure.sage`** — Zoo-grid subplot helpers.
- **`sweep_driver.sage`** — CSV and result-directory helpers.
- **`coastline_series.sage`** — Coastline-area computation and
  measure registry.

---

# Hypothesis registry

## Primary hypotheses (K1–K3)

### K1. Geometric partitions outperform uniform for power-law targets

**Status:** subdivided — see K1a, K1b, K1c

**Question:** Do geometric partitions achieve lower worst-case error
than uniform under shared-delta optimization?

**Claim:** Depends on parameterization. Cell-level advantage is clear,
but the shared-delta advantage requires LD and is not unique to
geometric among x=1-heavy partitions.

### K1a. Geometric cells have lower optimal per-cell error

**Status:** supported
**Tested in:** `keystone/partition_sweep`, `stepstone/`

**Question:** Is free-per-cell worst-case error lower on geometric
than uniform at every tested depth?

**Current answer:** Yes. Equal-log-width cells match the curvature of
log2(z), distributing error evenly (KEYSTONE.md §1). Geometric
`free_err` is strictly lower at every depth in the q=5, d=3..6 sweep.
See `keystone/results/wall_surface_2026-03-18/summary.csv`.

### K1b. Geometric yields lower minimax error under LI sharing

**Status:** not supported
**Tested in:** `keystone/partition_sweep`

**Question:** Under LI shared-delta, do geometric partitions yield
lower `opt_err` than uniform?

**Current answer:** No. At d>=4 with q=5, geometric `opt_err` exceeds
uniform. The sharing penalty is consistently larger on geometric —
the FSM's bitwise/additive structure may align better with uniform
cell boundaries. See same summary CSV as K1a.

### K1c. Under LD sharing, x=1-heavy partitions outperform uniform

**Status:** supported, with qualifications
**Tested in:** `keystone/partition_sweep`, `wall/join_layer_modes`

**Question:** Does the geometric free-per-cell advantage propagate to
lower `opt_err` under layer-dependent deltas?

**Current answer:** Geometric and harmonic LD `opt_err` < uniform LD
at all tested points. Mirror_harmonic (x=2-heavy control) loses to
uniform under LD but is competitive under LI at deeper points.
Within x=1-heavy: harmonic wins at q=3, geometric at q=5.
See `keystone/results/` and `wall/results/joined_layer_modes.csv`.

**Open edges:**
- Does the harmonic-vs-geometric q-dependence persist at other exponents?
- Why does LI favor mirror_harmonic at depth while LD does not?

### K2. Log-organized schemes scale more naturally with depth

**Status:** mixed, needs subdivision like K1
**Tested in:** `keystone/partition_sweep`, `keystone/h1_sweep`

**Question:** Does error for x^(p/q) degrade less with depth on
geometric than uniform?

**Current answer:** `free_err` decays faster on geometric (confirming
K1a), but `opt_err` grows faster under LI (mirroring K1b). Needs the
K1a/K1b/K1c subdivision applied to depth scaling.

**Open edges:**
- Repeat depth sweep with LD parameterization.
- Subdivide if pattern persists.

### K3. The wall decomposition is partition-dependent

**Status:** first evidence
**Tested in:** `wall/` (all scripts), `alternation/` (supports)

**Question:** Does the wall's source decomposition (parameter budget /
layer sharing / automaton coupling) change between partition kinds?

**Current answer:** At (q=3, d=6, exp=1/2), LD reduces the gap by ~40%
(uniform) and ~50% (geometric). Layer sharing is dominant for both,
but residual gaps differ. Wall excess is distributed under LI but
concentrated under LD for geometric. Worst-cell migrates on geometric,
pinned near x=1 on uniform.

**Open edges:**
- Does the decomposition survive at non-1/2 exponents? (Sweep running.)
- Does residual automaton-coupling wall shrink with larger q in LD?
- Is there a scaling law in param-to-cell ratio?

## Supporting observations (H1)

Baseline observations on `uniform_x` establishing that the baseline is
non-degenerate. Evidence for the wall model (K3), not independent
research lines. All tested in `keystone/h1_sweep`.

### H1. Shared FSM structure gives real approximation power on uniform_x

**Status:** supported, qualified

**Question:** Does shared-delta optimization beat single-intercept Day
models on the legacy uniform baseline?

**Current answer:** Yes — `improve > 0` in all tested LI cases.
Performance improves with q at fixed depth. LD recovers much more of
the gap. But the gain is fragile under LI and decays with depth.
See `keystone/results/h1_*.csv`.

### H1a. At fixed depth, the gap closes with parameter budget

**Status:** supported

**Question:** Does increasing q drive `opt_err` close to `free_err`?

**Current answer:** Yes. At depth 4, LI is near the free-per-cell
floor by q=9.

### H1b. At fixed q (LI), relative improvement decays with depth

**Status:** supported

**Question:** Does `improve / single_err` decay toward zero as depth
grows at fixed q?

**Current answer:** Yes. q=5 depth sweep (d=4..10) shows monotone
decay. See `keystone/results/h1b_depth_scaling.csv`.

### H1c. Layer sharing is the dominant wall source at tested benchmarks

**Status:** supported

**Question:** Is reusing one delta table across all layers the main
obstruction in the LI baseline model?

**Current answer:** Yes. At (q=5, d=6), LD reduces the LI gap from
0.032 to 0.009. See `keystone/results/h1c_layer_dependent.csv`.

### H1d. Delta shape depends on parameterization

**Status:** observed

**Question:** Do LI and LD optima use their parameter budgets
differently?

**Current answer:** LI optima are concentrated (small active support).
LD optima are diffuse (broad support). Confirmed at tested benchmarks,
not yet across partition kinds.

## Retired

- **H2** (active-extrema growth): falsified — minimax equalizes cells rather than diversifying the induced pattern family.
- **H3** (Jukna induced family): moot — induced families too small for meaningful additive-structure discrimination.
- **H4** (tropical compression): open but deprioritized — the original Jukna motivation is no longer central.

---

## Adding a new hypothesis

**Add** when a sweep produces a result not predicted by an existing
hypothesis, or an existing one needs subdivision. **Don't add** when
the result confirms/refutes an existing hypothesis (update it instead)
or when the observation is a numeric detail (put it in the CSV).

**Template:**
- **Status:** open | supported | not supported | retired
- **Tested in:** `directory/script`
- **Question:** one sentence
- **Current answer:** short paragraph (3-8 lines), cite artifacts
- **Open edges:** bullet list, only items that would change status

**Rules:**
1. Pick the next ID in the relevant series (K4, H1e, etc.).
2. Keep it under 20 lines.
3. If subdividing, mark the parent "subdivided" and list children.
4. If retiring, move to Retired as a one-liner.
5. Add the ID to the relevant experiment area's `Tests:` line above.

**ID conventions:** K-series = keystone thesis predictions.
H-series = baseline observations on uniform_x.
New series (E, W, etc.) for new research directions.
