Purpose: experiment directory map and hypothesis registry
Canonical for: what scripts exist, what questions they test, and what the project currently believes
Not for: run logs, numeric evidence tables, or implementation details

All scripts require SageMath; run from project root via
`./sagew experiments/<topic>/<script>.sage`.

# Experiments

## Experiment areas

### Active (root)

#### `wall/`

Wall obstruction model: spatial diagnostics and exponent robustness.
[`WALL.md`](wall/WALL.md) defines the wall.

Scripts: `enrich_summary`, `join_layer_modes`, `worst_cell_map`,
`wall_excess_ribbons`, `gap_collapse`, `candidate_phase_barcode`,
`exponent_robustness_sweep`.

Tests: K3, W1

#### `tiling/`

Hyperbolic binary tiling framework: the representation displacement
field Δ^L and its connection to the wall. Tests whether the wall
responds to a representation-level forcing function.
[`TILING.md`](tiling/TILING.md) contains the framework.

Scripts: `displacement_field_test`, `leading_bit_projection`,
`basis_identification`, `basis_overlay`, `t3_summary_plot`,
`zoo_sweep`, `zoo_summary_plots`.

Tests: T1, T2, T3

### Concluded (`aft/`)

#### `aft/keystone/`

Partition-comparison sweeps and the guiding thesis.
[`KEYSTONE.md`](aft/keystone/KEYSTONE.md) contains the thesis and caveats.

Scripts: `partition_sweep`, `h1_sweep`, `inspect_case`,
`error_profile`, `wall_decomposition`, `gap_surface`,
`intercept_displacement`, `coordinate_uniqueness`, `surrogacy_test`,
`float_formats`, `compatibility_matrix`.

Tests: K1a, K1b, K1c, K2, H1, H1a–H1d

#### `aft/rotation/`

Test of Charybdis: whether the FSM's wall is special relative to
random subspaces. Includes adversary sweep and Walsh spectral
experiment. See [`ROTATION.md`](aft/rotation/ROTATION.md).

Tests: Charybdis rotation check (ABYSSAL-DOUBT §4)

#### `aft/alternation/`

Sign-pattern analysis of shared vs free-per-cell intercept
displacement. Barcodes, RLE ribbons, split maps.
See [`ALTERNATION.md`](aft/alternation/ALTERNATION.md).
Supports: K3 (sign structure predicts wall properties; future E5)

#### `aft/stepstone/`

Chord error structure and visualization. Why geometric partitions
equalize per-cell error, plus multi-partition profiles and fractal art.
Subfolders: `profiles/`, `fractal/`, `ripple/`.
Exhibits: K1a mechanism (scale-equivariance → equal cell difficulty)

Subfolder `ripple/`: coastline area across partition families.
Scaled-area convergence, wobble, and stability diagnostics.

### Future (`fore/`)

#### `fore/counterfactual/`

Foreign-error analysis (chord sharing counterfactuals). W1 negative
result established; open question is counterfactual chord-sharing
geometry. See [`DAMAGE.md`](fore/counterfactual/DAMAGE.md).

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
**Tested in:** `aft/keystone/partition_sweep`, `aft/stepstone/`

**Question:** Is free-per-cell worst-case error lower on geometric
than uniform at every tested depth?

**Current answer:** Yes. Equal-log-width cells match the curvature of
log2(z), distributing error evenly (KEYSTONE.md §1). Geometric
`free_err` is strictly lower at every depth in the q=5, d=3..6 sweep.
See `aft/keystone/results/wall_surface_2026-03-18/summary.csv`.

### K1b. Geometric yields lower minimax error under LI sharing

**Status:** not supported
**Tested in:** `aft/keystone/partition_sweep`

**Question:** Under LI shared-delta, do geometric partitions yield
lower `opt_err` than uniform?

**Current answer:** No. At d>=4 with q=5, geometric `opt_err` exceeds
uniform. The sharing penalty is consistently larger on geometric —
the FSM's bitwise/additive structure may align better with uniform
cell boundaries. See same summary CSV as K1a.

### K1c. Under LD sharing, x=1-heavy partitions outperform uniform

**Status:** supported, with qualifications
**Tested in:** `aft/keystone/partition_sweep`, `wall/join_layer_modes`

**Question:** Does the geometric free-per-cell advantage propagate to
lower `opt_err` under layer-dependent deltas?

**Current answer:** Geometric and harmonic LD `opt_err` < uniform LD
at all tested points. Mirror_harmonic (x=2-heavy control) loses to
uniform under LD but is competitive under LI at deeper points.
Within x=1-heavy: harmonic wins at q=3, geometric at q=5.
See `aft/keystone/results/` and `wall/results/joined_layer_modes.csv`.

**Open edges:**
- Does the harmonic-vs-geometric q-dependence persist at other exponents?
- Why does LI favor mirror_harmonic at depth while LD does not?

### K2. Log-organized schemes scale more naturally with depth

**Status:** mixed, needs subdivision like K1
**Tested in:** `aft/keystone/partition_sweep`, `aft/keystone/h1_sweep`

**Question:** Does error for x^(p/q) degrade less with depth on
geometric than uniform?

**Current answer:** `free_err` decays faster on geometric (confirming
K1a), but `opt_err` grows faster under LI (mirroring K1b). Needs the
K1a/K1b/K1c subdivision applied to depth scaling.

**Open edges:**
- Repeat depth sweep with LD parameterization.
- Subdivide if pattern persists.

### K3. The wall decomposition is partition-dependent

**Status:** supported
**Tested in:** `wall/` (all scripts), `aft/alternation/` (supports)

**Question:** Does the wall's source decomposition (parameter budget /
layer sharing / automaton coupling) change between partition kinds?

**Current answer:** Confirmed across exponents 1/3, 1/2, and 2/3 (160
new cases). Layer sharing is the dominant wall source for uniform,
geometric, and harmonic (median wall fraction 43–75%, varying by
exponent). Mirror_harmonic is an outlier at ~40%. Wall excess is
distributed under LI but concentrated under LD for geometric.
Worst-cell migrates on geometric, pinned near x=1 on uniform. LD gap
saturates by d=7–8. See `wall/results/exponent_robustness_2026-03-20/`.

**Open edges:**
- Does residual automaton-coupling wall shrink with larger q in LD?
- Is there a scaling law in param-to-cell ratio?
- Does sign-sequence structure predict wall properties? (Future E5.)

## Supporting observations (H1)

Baseline observations on `uniform_x` establishing that the baseline is
non-degenerate. Evidence for the wall model (K3), not independent
research lines. All tested in `aft/keystone/h1_sweep`.

### H1. Shared FSM structure gives real approximation power on uniform_x

**Status:** supported, qualified

**Question:** Does shared-delta optimization beat single-intercept Day
models on the legacy uniform baseline?

**Current answer:** Yes — `improve > 0` in all tested LI cases.
Performance improves with q at fixed depth. LD recovers much more of
the gap. But the gain is fragile under LI and decays with depth.
See `aft/keystone/results/h1_*.csv`.

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
decay. See `aft/keystone/results/h1b_depth_scaling.csv`.

### H1c. Layer sharing is the dominant wall source at tested benchmarks

**Status:** supported

**Question:** Is reusing one delta table across all layers the main
obstruction in the LI baseline model?

**Current answer:** Yes. At (q=5, d=6), LD reduces the LI gap from
0.032 to 0.009. See `aft/keystone/results/h1c_layer_dependent.csv`.

### H1d. Delta shape depends on parameterization

**Status:** observed

**Question:** Do LI and LD optima use their parameter budgets
differently?

**Current answer:** LI optima are concentrated (small active support).
LD optima are diffuse (broad support). Confirmed at tested benchmarks,
not yet across partition kinds.

## Wall mechanism (W-series)

### W1. The wall is not pairwise chord displacement

**Status:** supported (negative result)
**Tested in:** `wall/damage_vs_wall`, `wall/displacement_structure`

**Question:** Is the wall explained by cells being forced to use
neighboring cells' intercepts?

**Current answer:** No. Adjacent cells' free intercepts are nearly
interchangeable (best-donor excess is small), but the FSM's shared
intercept causes wall excess 10–17x larger. The displacement pattern
is spatially structured and driven by early-layer fan-out: layer 0
must serve all 2^d cells with one delta pair, creating systematic
positional displacement. Final residue state does not explain the
pattern. LD cuts the displacement range ~50% by using middle layers
to pull back. See `wall/results/exchange_rate/`.

**Open edges:**
- Layer-0 fan-out stabilizes with depth (T1/Stage D confirms bounded
  forcing). Remaining question: does a second binary architecture
  see the same forcing? (ABYSSAL-DOUBT resolution path 1.)

## Tiling displacement field (T-series)

### T1. The free intercept field has the same leading-bit residual shape as Δ^L

**Status:** supported (strengthened by adversary test)
**Tested in:** `tiling/displacement_field_test` (Stage A)

**Question:** After removing the best leading-bit step, does the free
intercept field c* track the representation displacement field Δ^L
across partitions and depths?

**Current answer:** Yes. R0(c*) correlates with R0(Δ^L) at r=0.80–0.89
across all 20 geometry-only cases (4 Group A kinds x 5 depths). Three
adversary partitions (Group H) designed to break this correlation all
failed: half_geometric 0.876, eps_density 0.80–0.83, midpoint_dense
0.88. The residual is a property of the approximation problem, not the
partition geometry. See `tiling/results/displacement_field/`.

### T2. The optimizer's layer-0 allocation is near the best leading-bit projection

**Status:** partially supported
**Tested in:** `tiling/displacement_field_test` (Stages B, C)

**Question:** Does the optimizer use layer 0 as the best coarse
absorber, with LD gains coming from later-layer repair?

**Current answer:** Layer 0 is in the right neighborhood of the best
leading-bit projection (median fit gap ~0.020) but systematically
offset by deeper path-algebra constraints. The cumulative absorption
test confirms LD gains come from layers 1+ repairing the coarse
forcing, not from a different layer-0 picture. Stage D shows the
forcing stabilizes with depth (bounded allocation problem).
See `tiling/results/displacement_field/`.

**Open edges:**
- Harmonic q=3 d=6 LD has an outlier fit gap (0.048). Investigate.
- Does the picture hold at non-1/2 exponents?

### T3. The within-half variation of c* is primarily organised by pointwise ε

**Status:** supported
**Tested in:** `tiling/basis_identification`, `tiling/t3_summary_plot`

**Question:** After Π₀ projection, is the residual of c* predicted
by ε(m_mid) across partitions with different cell-width distributions,
including those with inverted width-position coupling?

**Current answer:** Yes. H_value (single feature ε(m_mid)) achieves
holdout corr 0.85–0.89 across 3 adversaries and 2 width-scrambles
that invert or maximise the width-ε coupling. H_width is eliminated
(corr 0.17–0.54). On affine-detrended geometric, corr > 0.999.
H_balance adds a correction of 0.01–0.07 NRMSE from endpoint-balance
geometry; this margin is width-modulated (shrinks on peak_swap,
widens on peak_avoid). The transported residual collapses onto a
shared ε template across all 9 partition families tested.
See `tiling/results/t3_summary.png`.

**Open edges:**
- Path 2 (local asymptotic model): derive c*(m, w) ≈ c₀(m) + c₁(m)·w
  through the Day candidate structure. The basis competition has
  reverse-engineered the term structure: c₀ tracks ε, corrections
  track balance features.

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
