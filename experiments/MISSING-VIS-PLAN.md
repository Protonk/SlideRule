# Missing Visualizations: Survey & Bootstrap Plan

Purpose: inventory what the project visualizes today, identify gaps, and
provide a structured plan for an agent to build a richer atlas of missing
visualizations.

---

## Part A. Current Visualization Inventory

### Summary

51 PNG files across 10 results/ directories. 26 CSVs, 22 JSONL caches.
All static matplotlib rendered from SageMath at DPI 180-200, plus one
custom raster renderer (fractal grids). No interactive, animated, or
3D-beyond-surface visualizations. Zero broken documentation references
across 17 .md files.

### By area

| Area | Count | What they show |
|------|-------|----------------|
| **keystone/** | 8 | wall_decomposition (multi-panel), gap_surface (3D), error_profile, intercept_displacement, coordinate_uniqueness, surrogacy_test, float_formats, compatibility_matrix |
| **wall/** | 5+9 | gap_collapse, wall_excess_ribbons, worst_cell_map, candidate_phase_barcode, displacement_structure; **damage/** balance_scatter, balance_bars (2), balance_linear, balance_ratio (2), balance_polar, counter_factual, amplification (2) |
| **stepstone/** | 1+4+6 | chord_slope_crossing, many_steps_miss; **profiles/** cartesean_envelope, polar_heatmap, curvature_mismatch, radar_peaks; **fractal/** complete_atlas, geo_vs_chaos, 4 individual partition fractals |
| **alternation/** | 3+1 | zoo_barcode, rle_ribbons, barcode_stack; **refinement/** split_map |
| **ripple/** | 5 | area_comparison, integrate_coastline, stability_heatmap, settlers, divergent |
| **tiling/** | ~5 | displacement_field/ (geometry_residuals, cumulative_absorption, depth_scaling), basis_template_overlays, t3_summary |

### What IS well-visualized

- Per-cell chord error structure across partition kinds (profiles, error_profile)
- Wall decomposition and its 3 sources (wall_decomposition, gap_collapse, ribbons)
- Intercept displacement patterns: scatter, bars, polar (wall/damage/)
- Sign-sequence structure of displacement (alternation barcodes, RLE)
- Fractal self-similarity of partition grids (complete_atlas, individual fractals)
- Coastline convergence and stability (ripple area/stability)
- Displacement field T1-T3 results (tiling/)
- Surrogacy comparison of pseudo-log vs alternatives (surrogacy_test)

---

## Part B. Cursory Gap Survey

I identified gaps by cross-referencing: (a) the mathematical objects in
`lib/`, (b) the hypotheses in `EXPERIMENTS.md`, (c) the roadmap in
`DISTANT-SHORES.md`, and (d) the open edges listed under each hypothesis.

### Tier 1: Objects studied but never visualized

| Gap ID | Object | Where it lives | Why it matters |
|--------|--------|---------------|----------------|
| **G1** | **The pseudo-log error itself: epsilon(m) = log2(1+m) - m** | `lib/day.sage` (plog/pexp), used everywhere | The central forcing function of the entire project. It appears only as a minor trace in surrogacy_test. No standalone portrait showing its shape, concavity, peak at m*~0.44, nor overlay with the displacement field it organizes. |
| **G2** | **Automaton state trajectories / path structure** | `lib/paths.sage` | The FSM is the correction engine. No visualization of state-transition graphs, fan-out from layer 0, path multiplicities, or how trajectory structure changes with q and d. |
| **G3** | **Induced pattern families (0-1 vectors)** | `lib/jukna.sage`, retired H2/H3 | The Day-pattern families are the combinatorial fingerprint of the candidate structure. Sumset size, additive energy, cover-free properties are computed but only logged numerically. No scatter/matrix of family geometry. |
| **G4** | **Delta tables (LI and LD)** | `lib/optimize.sage` output | The optimizer's actual product. No heatmap of delta[state, bit_value] tables, no comparison of LI vs LD delta shapes, no portrait of how tables evolve with q. |
| **G5** | **LP constraint geometry** | `lib/optimize.sage` | The wall is a projection distance (DISTANT-SHORES Step 4). The LP polytope whose closest point determines opt_err has never been rendered, even in low-dimensional slices. |

### Tier 2: Relationships studied but under-visualized

| Gap ID | Relationship | Current coverage | What's missing |
|--------|-------------|-----------------|----------------|
| **G6** | **Absorption staircase (C, gap) curve** | Not visualized | DISTANT-SHORES Step 5 predicts a staircase: wall vs parameter budget with binding cell migration. This is the project's next major empirical target. No script exists to plot it. |
| **G7** | **Binding-cell migration** | worst_cell_map (static) | Only one snapshot. Need animated or multi-panel showing how the worst cell migrates as q grows, overlaid with epsilon(m) to test the staircase prediction. |
| **G8** | **Layer allocation: who absorbs what** | cumulative_absorption (1 plot) | Only aggregate. Missing per-layer heatmap showing which cells each layer's delta corrects, across depths. |
| **G9** | **LI vs LD delta shape comparison** | Mentioned in H1d, not visualized | H1d observes "LI concentrated, LD diffuse" but no visualization shows this directly. |
| **G10** | **Cross-exponent behavior** | gap_collapse sweeps exponents, but | No dedicated visualization of how epsilon's shape changes with target exponent (x^(-p/q) for various p/q) and how that reorganizes cell difficulty. |

### Tier 3: Presentation & communication gaps

| Gap ID | Need | Notes |
|--------|------|-------|
| **G11** | **Project overview figure** | No single "hero" figure showing the pipeline: partition -> Day evaluation -> FSM correction -> wall measurement. Every talk/paper needs one. |
| **G12** | **Epsilon + displacement field composite** | epsilon(m), Delta^L(m), c*(m) overlaid on one plot. The T-series results prove they're organized by the same structure, but no single figure shows it. |
| **G13** | **Partition zoo gallery** | complete_atlas exists as fractals, but no clean gallery of partition boundary positions on [1,2) for all 25 kinds at a reference depth (say d=6). Just the geometry, before any error analysis. |
| **G14** | **Hypothesis status dashboard** | The hypothesis registry is text. A visual status board (supported/mixed/not supported/retired) keyed to experiment area would help navigation. |
| **G15** | **Scaling law summary** | Tables exist in CSVs. No combined plot of free_err, opt_err, wall vs depth for the core partitions (geometric, uniform, harmonic) on one canvas, which is the single most-asked question. |

---

## Part B′. Deep Inventory Summary (Phase 1 output)

Phase 1 complete. Key findings:

### Artifact census

- **51 PNGs** across 10 results/ directories — all verified on disk
- **26 CSVs** + 22 JSONL caches — all verified
- **65 .sage scripts** cataloged (35 plot scripts, 14 sweep/data, 16 helpers)
- **Zero broken references** in documentation (17 .md files cross-checked)

### Plottable data in lib/ that has no visualization

| Module | Function | Returns | Gap |
|--------|----------|---------|-----|
| day.sage | `cell_breakpoints_arb()` | sorted list of plog-domain H-grid crossings | G1 area |
| day.sage | `cell_logerr_arb()` | meta['candidates'] list of (plog, value, type) | no error curve viz |
| day.sage | `build_active_pattern_family()` | unique_vectors, multiplicities, coordinate_keys | G3 |
| paths.sage | `residue_paths()` | (edges, paths, edge_index) — automaton structure | G2 |
| optimize.sage | `optimize_minimax()` | delta_rat dict, cell_free_intercepts, interval_stats | G4, G9 |
| optimize.sage | `build_intercept_matrix()` | (n_paths × n_params) numpy array | G5 |
| optimize.sage | `free_per_cell_metrics()` | per-cell rows: (bits, c_opt, zmin, zmax, cell_worst) | G15 |
| jukna.sage | `summarize_vector_family()` | 13-key dict: sumset, energy, Sidon/CF subsets | G3 |
| leading_bit_projection.sage | `eps_val()`, `delta_L()` | scalar functions on [0,1) | G1, G12 |
| trajectory.py | `growth_table()`, `sum_sweep()` | numeric tables (n, counts) | G3 area |

### CSVs cited in docs but never visualized

| CSV | Rows | Could become |
|-----|------|-------------|
| wall/results/enriched_summary.csv | ~200 | G10, G15 |
| wall/results/joined_layer_modes.csv | ~40 | G9 |
| wall/results/exponent_robustness_2026-03-20/summary.csv | ~160 | G10 |
| tiling/results/zoo/zoo_case_metrics.csv | ~100 | G16 (new) |
| alternation/refinement/results/zoo_split_sequences.csv | 22 | G17 (new) |
| tiling/results/basis_identification/basis_fit_summary.csv | 14 | minor |

### Scripts that compute but don't plot

| Script | Computes | Could become |
|--------|----------|-------------|
| h1_sweep.sage | `delta_shape_stats()` — l1, l2, nnz, top2_mass | G4, G9 |
| inspect_case.sage | pattern family, delta table, cell report | G3, G4 |
| coastline_series.sage | per-kind area series (kind → [areas]) | (covered by ripple) |
| zoo_sweep.sage | per-cell g, δ^L, ε features; case-level correlations | G16 |
| displacement_field_test.sage | residual arrays, cumulative c^(≤t), correlation sequences | G8 |

---

## Part B″. Gap Cards (Phase 2 output)

### P0 — Blocks roadmap

---

### G1. Epsilon portrait

**Object:** ε(m) = log₂(1+m) − m on [0, 1) — the pseudo-log error / forcing function
**Priority:** P0 (dependency of G6 and G12; the central object has no standalone figure)
**Difficulty:** trivial (pure function, no data needed)
**Data source:** `leading_bit_projection.sage::eps_val(m)`, `eps_prime(m)`, `eps_pp(m)`;
equivalently `day.sage::plog()` minus identity
**Suggested encoding:** 3-panel column:
  (1) ε(m) with peak at m\* ≈ 0.4427 annotated, zero endpoints marked;
  (2) ε′(m) = 1/((1+m)ln2) − 1 showing sign change at m\*;
  (3) ε″(m) = −1/((1+m)²ln2) showing uniform concavity.
  Optional: light fill under ε in panel 1, vertical m\* line shared across panels.
**Suggested location:** `experiments/stepstone/results/epsilon_portrait.png`
**Depends on:** none
**Roadmap link:** DISTANT-SHORES Steps 1–2, 5 (forcing function); T3 (ε organizes c\*)

---

### G6. Absorption staircase

**Object:** Wall (opt_err − free_err) vs parameter budget q at fixed depth and partition
**Priority:** P0 (directly serves DISTANT-SHORES Step 5 — the project's active frontier)
**Difficulty:** moderate (needs q-sweep: run `compute_case()` for q=1,3,5,7,9,11,13,15
at fixed depth=6, for geometric_x and uniform_x, both LI and LD)
**Data source:** `keystone_runner.sage::compute_case(q, depth, kind, ...)` → extract
`opt_err`, `free_err`, `worst_cell_index`, `worst_cell_plog_mid` per q.
Partial data exists in `h1a_gap_vs_q.csv` (uniform_x LI only, d=4, q=1..15).
**Suggested encoding:** 2-panel figure:
  (1) Top: step-like curve (q on x-axis, gap on y-axis) for 4 series
  (geometric LI/LD, uniform LI/LD). Staircase prediction: flat plateaus
  separated by drops. Mark stair edges.
  (2) Bottom: worst-cell plog midpoint vs q (same 4 series), with ε(m)
  shape as gray background. Staircase prediction: worst cell migrates
  inward from boundaries toward m\* as q grows.
**Suggested location:** `experiments/wall/results/absorption_staircase.png`
**Depends on:** G1 (ε reference line in bottom panel)
**Roadmap link:** DISTANT-SHORES Step 5 (absorption rate and stair structure)

---

### G7. Binding-cell migration

**Object:** Which cell is worst (binding) and how it moves as q increases
**Priority:** P0 (tests the staircase prediction: boundary cells bind first, peak cells last)
**Difficulty:** moderate (reuses G6 sweep data; adds spatial overlay)
**Data source:** Same `compute_case()` sweep as G6. Extract per-cell error vectors
at each q. Also: `worst_cell_map.png` exists but shows (q, depth) heatmap — this
gap needs a spatial (cell position) view across q.
**Suggested encoding:** Multi-panel strip (one panel per q value, q=1,3,5,7,9,11):
  x-axis = cell midpoint m, y-axis = per-cell error. Worst cell highlighted with
  marker. Gray fill = ε(m) scaled to match. Shows binding cell migrating from
  domain edges toward ε peak as q grows.
  Alternative: single panel with colored vertical bars at worst-cell position,
  one bar per q, overlaid on ε.
**Suggested location:** `experiments/wall/results/binding_cell_migration.png`
**Depends on:** G6 (shares sweep data), G1 (ε overlay)
**Roadmap link:** DISTANT-SHORES Step 5 (binding-cell ordering prediction)

---

### P1 — Strengthens key hypotheses

---

### G4. Delta table heatmaps

**Object:** Optimized delta[state, bit] tables (LI) and delta[layer, state, bit] (LD)
**Priority:** P1 (the optimizer's actual product; H1d observes concentrated vs diffuse
but never shows it)
**Difficulty:** trivial (data computed by `optimize_minimax()`, returned in policy dict
as `delta_rat`; also `h1_sweep.sage::delta_shape_stats()` computes l1, nnz, top2_mass)
**Data source:** Run `compute_case(q=5, depth=6, kind='geometric_x', ...)` for LI and
LD. Extract `case['opt_pol']['delta_rat']`. Convert to matrix: rows=states (0..q-1),
cols=bits (0,1) for LI; layers × (states, bits) for LD.
**Suggested encoding:** Side-by-side heatmaps:
  (1) LI: q×2 grid, cells colored by delta magnitude, annotated with exact QQ value.
  (2) LD: depth panels each showing q×2 grid. Colorbar shared.
  Color: diverging (blue-white-red) centered at 0.
  Bottom strip: bar chart of delta_shape_stats (l1, nnz, top2_mass) for quick comparison.
**Suggested location:** `experiments/keystone/results/delta_tables.png`
**Depends on:** none
**Roadmap link:** H1d (delta shape depends on parameterization)

---

### G9. LI vs LD delta shape comparison

**Object:** Structural difference between layer-invariant and layer-dependent optima
**Priority:** P1 (H1d is "observed" status — visualization would strengthen to "supported")
**Difficulty:** trivial (data exists in `h1c_layer_dependent.csv` and
`joined_layer_modes.csv`; delta tables from G4)
**Data source:** `joined_layer_modes.csv` for gap_reduction, worst_cell_shift.
`h1_sweep.sage::delta_shape_stats()` for l1, nnz, top2_mass at LI vs LD.
`compute_case()` for delta_rat dicts.
**Suggested encoding:** 3-panel figure:
  (1) Paired bar chart: LI vs LD sparsity metrics (l1, nnz, top2_mass) across q values.
  (2) Gap reduction waterfall: how much wall each LD layer removes (from G8 data).
  (3) Overlay: LI delta as stem plot, LD layer-0 delta as stems on same axes,
  showing concentrated vs diffuse.
**Suggested location:** `experiments/wall/results/li_vs_ld_shape.png`
**Depends on:** G4 (delta table data)
**Roadmap link:** H1d (delta shape), K1b vs K1c (LI hurts geometric, LD helps)

---

### G8. Layer allocation heatmap

**Object:** Per-layer contribution to intercept correction across cells
**Priority:** P1 (cumulative_absorption.png shows aggregate; need spatial detail)
**Difficulty:** moderate (need `cumulative_intercept()` from leading_bit_projection.sage
for layers 0..d-1, already called in displacement_field_test.sage Stage C)
**Data source:** `leading_bit_projection.sage::cumulative_intercept(bits, c0, delta, q, up_to_layer)`.
Stage BC CSV at `tiling/results/displacement_field/stage_bc.csv` has aggregate metrics
but not per-cell per-layer arrays. Recompute from `compute_case()` at one benchmark
(geometric, q=5, d=6, LD).
**Suggested encoding:** Heatmap: x-axis = cell index (0..63), y-axis = layer (0..5).
Cell color = delta contribution at that layer for that cell. Colorbar: diverging.
Bottom row: free intercept c\* for reference. Top annotation: total displacement.
Side panel: L∞ norm per layer (from Stage C data).
**Suggested location:** `experiments/tiling/results/layer_allocation.png`
**Depends on:** none (but shares data pipeline with G4)
**Roadmap link:** T2 (layer-0 is coarse absorber, layers 1+ repair)

---

### G10. Cross-exponent wall figures

**Object:** How wall structure changes across target exponents 1/3, 1/2, 2/3
**Priority:** P1 (exponent_robustness_sweep ran 160 cases on 2026-03-20; data exists,
no figure)
**Difficulty:** trivial (CSV exists: `wall/results/exponent_robustness_2026-03-20/summary.csv`)
**Data source:** Load CSV. Columns include partition_kind, q, depth, exponent,
layer_dependent, opt_err, free_err, gap, worst_cell_*.
Also: `enriched_summary.csv` has param_to_cell_ratio, gap_over_free.
**Suggested encoding:** 3-column figure (one column per exponent):
  Each column: gap_collapse-style scatter (param_to_cell_ratio vs gap/free) with
  partition kinds as colored markers. Shared y-axis to see cross-exponent shift.
  Annotation: median wall fraction for layer-sharing source per exponent.
**Suggested location:** `experiments/wall/results/exponent_robustness.png`
**Depends on:** none
**Roadmap link:** K3 (wall decomposition is partition-dependent), DISTANT-SHORES Step 5
(does forcing shape change with exponent?)

---

### G15. Scaling law summary

**Object:** free_err, opt_err, wall vs depth for core partitions on one canvas
**Priority:** P1 (most-asked question; data spread across multiple CSVs)
**Difficulty:** trivial (data in `wall_surface_2026-03-18/summary.csv` and
`exponent_robustness_2026-03-20/summary.csv`)
**Data source:** Load summary CSVs. Filter to geometric_x, uniform_x, harmonic_x.
Extract (depth, free_err, opt_err, gap) grouped by (kind, layer_mode).
**Suggested encoding:** 2×2 grid:
  Rows = LI / LD. Columns = log-scale error / wall fraction.
  Left panels: log y-axis, three curves per panel (free, opt, single) across depth,
  colored by partition kind.
  Right panels: gap/free_err (wall fraction) across depth, same kind colors.
  Shared x-axis (depth 3..8 or 3..10).
**Suggested location:** `experiments/keystone/results/scaling_summary.png`
**Depends on:** none
**Roadmap link:** K1 (geometric outperforms), K2 (depth scaling), H1b (improvement decays)

---

### G16. Zoo displacement field metrics (new)

**Object:** T1-T3 diagnostic metrics across all 27 zoo cases
**Priority:** P1 (strengthens T-series by showing which partitions conform and which don't)
**Difficulty:** trivial (data exists: `tiling/results/zoo/zoo_case_metrics.csv`,
~100 rows × 15 columns including corr_g_dL, nrmse_g_dL, rho_peak)
**Data source:** Load `zoo_case_metrics.csv`. Key columns: kind, depth, corr_g_dL
(correlation of residual with Δ^L), nrmse_g_dL, worst_abs, rho_peak.
**Suggested encoding:** 2-panel figure:
  (1) Scatter: x = corr_g_dL, y = nrmse_g_dL, sized by worst_abs, colored by
  partition category. Adversaries labeled. Shows clustering near high-corr / low-NRMSE.
  (2) Strip chart or heatmap: kinds on y-axis, depths on x-axis, colored by corr_g_dL.
  Shows whether correlation strengthens or weakens with depth.
**Suggested location:** `experiments/tiling/results/zoo_field_summary.png`
**Depends on:** none
**Roadmap link:** T1 (free intercept tracks Δ^L), T3 (ε organizes c\*)

---

### P2 — Aids communication

---

### G12. Epsilon + displacement field composite

**Object:** ε(m), Δ^L(m), and c\*(m) overlaid, showing they share the same shape
**Priority:** P2
**Difficulty:** trivial (eps_val, delta_L, free intercepts all available)
**Data source:** `leading_bit_projection.sage::eps_val()`, `delta_L()`;
`free_intercepts_from_partition()` for c\* on geometric_x at reference depth.
**Suggested encoding:** Single panel: three curves on [0,1), vertically shifted or
scaled for alignment. Dashed reference at m\*, zero endpoints. Legend. Annotation
showing correlation coefficient.
**Suggested location:** `experiments/tiling/results/forcing_composite.png`
**Depends on:** G1 (ε portrait establishes the baseline)
**Roadmap link:** T1, T3 (forcing function organizes c\*)

---

### G13. Partition zoo gallery

**Object:** Cell boundary positions on [1, 2) for all 25 kinds at d=6
**Priority:** P2
**Difficulty:** trivial (`float_cells(6, kind)` for each kind)
**Data source:** `lib/partitions.sage::float_cells()` or `build_partition(6, kind=...)`.
**Suggested encoding:** Zoo-grid (use `zoo_subplots()` from zoo_figure.sage).
Each panel: thin vertical lines at cell boundaries, colored by category.
No error data — pure geometry.
**Suggested location:** `experiments/stepstone/results/partition_gallery.png`
**Depends on:** none
**Roadmap link:** General orientation

---

### G11. Project overview figure

**Object:** Pipeline: partition → Day evaluation → FSM correction → wall measurement
**Priority:** P2
**Difficulty:** moderate (composition, not computation; needs design)
**Data source:** Schematic; no data computation. Could embed small insets from existing
figures (error_profile, wall_decomposition, fractal).
**Suggested encoding:** Horizontal flow diagram with 4-5 annotated stages. Each stage
has a small embedded plot from existing figures. Matplotlib + text annotations.
**Suggested location:** `experiments/keystone/results/overview.png`
**Depends on:** G13 (partition gallery for stage 1 inset), G1 (ε for stage 2 inset)
**Roadmap link:** DISTANT-SHORES overview

---

### G15b. Basis ranking visualization (new, folded under P2)

**Object:** Basis family fit quality from T3 holdout analysis
**Priority:** P2
**Difficulty:** trivial (`basis_fit_summary.csv` has 14 rows)
**Data source:** `tiling/results/basis_identification/basis_fit_summary.csv`
**Suggested encoding:** Horizontal bar chart: bases on y-axis, test NRMSE on x-axis,
colored by holdout type (partition vs depth). Annotate feature count per basis.
**Suggested location:** `experiments/tiling/results/basis_ranking.png`
**Depends on:** none
**Roadmap link:** T3 (ε organizes c\*)

---

### P3 — Nice to have

---

### G2. Automaton state trajectories

**Object:** FSM transition graph, fan-out from layer 0, path multiplicities
**Priority:** P3
**Difficulty:** moderate (`residue_paths(q, depth)` returns edges and paths;
need graph layout)
**Data source:** `lib/paths.sage::residue_paths(q, depth)` → edges list, path dicts
**Suggested encoding:** Layered directed graph: nodes = (layer, state), edges colored
by bit (0/1). Width proportional to path count through edge. For q=5, d=4.
**Suggested location:** `experiments/stepstone/results/automaton_graph.png`
**Depends on:** none
**Roadmap link:** W1 (layer-0 fan-out drives displacement)

---

### G3. Induced pattern families

**Object:** Day-induced 0-1 vector families and their additive structure
**Priority:** P3 (H2/H3 retired — pattern families too small for discrimination)
**Difficulty:** moderate (`build_active_pattern_family()` + `summarize_vector_family()`)
**Data source:** `day.sage::build_active_pattern_family()` returns unique_vectors and
multiplicities; `jukna.sage::summarize_vector_family()` returns sumset/energy/subsets
**Suggested encoding:** Incidence matrix heatmap (rows=unique vectors, cols=coordinates),
annotated with multiplicity. Side panel: sumset size, additive energy, Sidon subset size.
**Suggested location:** `experiments/stepstone/results/pattern_family.png`
**Depends on:** none
**Roadmap link:** retired H2/H3 (diagnostic, not active)

---

### G5. LP constraint geometry

**Object:** Feasible region of the minimax LP in low-dimensional projection
**Priority:** P3
**Difficulty:** hard (need to extract LP constraints, project to 2-3D, render polytope)
**Data source:** `optimize.sage::build_intercept_matrix()` → A matrix;
`_cell_feasible_interval()` → per-cell bounds
**Suggested encoding:** 2D projection: scatter of feasible intercept vectors at several
tau values, showing how the feasible region shrinks to a point as tau → opt_err.
**Suggested location:** `experiments/wall/results/lp_geometry.png`
**Depends on:** none
**Roadmap link:** DISTANT-SHORES Step 4 (wall = projection distance)

---

### G14. Hypothesis status dashboard

**Object:** Visual status board for hypothesis registry
**Priority:** P3
**Difficulty:** trivial (hand-coded from EXPERIMENTS.md)
**Data source:** Text in EXPERIMENTS.md — parse status labels
**Suggested encoding:** Grid: rows = hypotheses (K1a..K3, H1..H1d, W1, T1..T3),
columns = (status icon, experiment area, key figure). Color by status.
**Suggested location:** `experiments/results/hypothesis_dashboard.png`
**Depends on:** none
**Roadmap link:** project navigation

---

### G17. Split sequence patterns (new)

**Object:** Refinement split-count sequences for all 22 partition kinds
**Priority:** P3
**Difficulty:** trivial (`zoo_split_sequences.csv` exists with 22 rows)
**Data source:** `alternation/refinement/results/zoo_split_sequences.csv`
**Suggested encoding:** Matrix heatmap: kinds on y-axis, depth transitions on x-axis,
colored by split count. Side annotation: total sequence string.
**Suggested location:** `experiments/alternation/refinement/results/split_matrix.png`
**Depends on:** none
**Roadmap link:** alternation framework (future E5)

---

## Part B‴. Priority Order and Dependency DAG (Phase 3 output)

### Execution order

| Order | Gap | Priority | Difficulty | Data status |
|-------|-----|----------|------------|-------------|
| 1 | G1 | P0 | trivial | pure function |
| 2 | G15 | P1 | trivial | CSV exists |
| 3 | G10 | P1 | trivial | CSV exists |
| 4 | G16 | P1 | trivial | CSV exists |
| 5 | G4 | P1 | trivial | compute_case() |
| 6 | G9 | P1 | trivial | CSV + G4 data |
| 7 | G6 | P0 | moderate | needs q-sweep |
| 8 | G7 | P0 | moderate | shares G6 data |
| 9 | G8 | P1 | moderate | partial recompute |

Rationale: trivial P0/P1 first (quick wins that unblock dependencies), then
moderate-difficulty items that need new computation. G6/G7 are P0 but ordered
after G1 (which they depend on) and after trivial P1s (to maximize delivered
figures before hitting the compute wall).

### Dependency DAG

```
G1 (epsilon portrait)
├──> G6 (staircase — needs ε reference line)
│    └──> G7 (binding cell — shares G6 sweep data)
├──> G12 (forcing composite — needs ε curve) [P2]
└──> G11 (overview — needs ε inset) [P2]

G4 (delta tables)
├──> G9 (LI vs LD — compares G4 heatmaps)
└──> G8 (layer allocation — related delta data)

G13 (partition gallery) ──> G11 (overview — needs gallery inset) [P2]

G15, G10, G16: independent (CSV-only, no cross-dependencies)
G17, G14, G2, G3, G5: independent [P3]
```

---

## Part C. Bootstrap Plan for Atlas Agent

The following plan is designed for an agent that will produce a richer,
prioritized atlas of missing visualizations. The agent should treat this
document as its briefing, produce the inventory / gap cards / specs, and then
implement the P0 and P1 visualizations. P2 and P3 are deferred unless the
first batch lands quickly.

### Execution guardrails

- **Deliverables:** inventory, gap cards, priority order, concrete specs, then
  working P0 and P1 figures.
- **Data policy:** prefer existing `results/` artifacts, CSVs, and prior sweep
  outputs. Run new computation only when an actual gap has no reusable data.
- **Sweep policy:** do not launch heavy multi-hour sweeps without flagging that
  cost first. A fresh q-sweep for G6 is expected; broader recomputation is not
  the default.
- **Authority rule:** code is authoritative. If this document disagrees with
  the current API, registry, or result layout, update this document inline and
  proceed with the codebase reality.

### Phase 1: Deep inventory (read-only)

The agent should build a complete cross-reference matrix:

1. **Read every `.sage` script** in `experiments/` and catalog:
   - What data it computes (input objects, output metrics)
   - What it plots (axes, visual encoding, figure structure)
   - What it writes to disk (CSV, PNG, text)
   - What objects it computes but does NOT visualize

2. **Read `lib/` modules** and catalog every function that returns
   plottable data (arrays, matrices, sequences) vs functions that return
   scalars or booleans.

3. **Read all results/ directories** and verify which PNGs actually
   exist (some scripts may not have been run recently). Reuse existing CSV /
   PNG inputs wherever they already support a gap.

4. **Read all `.md` files** in `experiments/` and cross-reference:
   every claim that says "see figure X" or "visualized in Y" — does the
   figure exist? Every claim that cites only CSV data — could it benefit
   from a figure?

### Phase 2: Gap classification

For each gap found, the agent should produce a card:

```
## [G-ID] Short title

**Object:** what mathematical object or relationship
**Priority:** P0 (blocks roadmap) | P1 (strengthens key hypothesis) |
              P2 (aids communication) | P3 (nice to have)
**Difficulty:** trivial (existing data, just plot) |
               moderate (need new computation + plot) |
               hard (new math + new computation + plot)
**Data source:** which lib function or script provides the data
**Suggested encoding:** chart type, axes, color mapping
**Suggested location:** which experiment area it belongs to
**Depends on:** other gap IDs that should be done first
**Roadmap link:** which DISTANT-SHORES step or hypothesis it serves
```

### Phase 3: Priority ordering

Group by priority. Within each priority:

- **P0 (blocks roadmap):** G6 (absorption staircase) and G7 (binding-cell
  migration) directly serve DISTANT-SHORES Step 5, which is the project's
  active frontier. These should be specified first.

- **P1 (strengthens key hypothesis):** G1 (epsilon portrait), G4 (delta
  tables), G8 (layer allocation), G9 (LI vs LD shape), G10 (cross-exponent).
  These fill holes in the evidence for supported hypotheses.

- **P2 (aids communication):** G11 (overview figure), G12 (epsilon +
  displacement composite), G13 (partition gallery), G15 (scaling summary).
  These are what you'd need to explain the project to someone new.

- **P3 (nice to have):** G2 (automaton trajectories), G3 (pattern families),
  G5 (LP geometry), G14 (hypothesis dashboard). Interesting but not
  blocking progress.

After ordering, the agent should execute P0 and P1 in that order. P2/P3 stay
as specs only unless the first batch is clearly low-cost.

### Phase 4: Specification writing

For each P0 and P1 gap, the agent should write a concrete spec:

- **Filename:** e.g., `experiments/tiling/absorption_staircase.sage`
- **Inputs:** exact function calls to get data from the real API
  (e.g., `compute_case(...)`, `build_partition(...)`,
  `free_per_cell_metrics(...)`, `optimize_shared_delta(...)`)
- **Figure layout:** panels, axes labels, color scheme
- **Output path:** e.g., `experiments/tiling/results/absorption_staircase.png`
- **Validation:** what the figure should show if the hypothesis is correct
  vs what it shows if the hypothesis is wrong

### Phase 4b: Implementation pass

Implement every P0 and P1 spec as actual `.sage` visualization scripts,
preferring:

1. Existing result tables and artifacts
2. Lightweight recomputation of missing derived series
3. Fresh sweeps only where no reusable data exists

Each implemented figure should:

- write to the documented `results/` location
- have a `Run:` docstring using `./sagew ...`
- use project import conventions (`helpers/pathing.py`)
- validate against the supporting hypothesis or roadmap claim

### Phase 5: Dependency graph

Produce a simple DAG of the visualization gaps:

```
G1 (epsilon portrait) -----> G12 (composite overlay)
                       \---> G6 (staircase, needs epsilon reference line)
G4 (delta tables) ---------> G9 (LI vs LD comparison)
                       \---> G8 (layer allocation)
G7 (binding cell) ---------> G6 (staircase incorporates migration)
G13 (partition gallery) ----> G11 (overview figure uses gallery as panel)
```

The agent should emit this as both text and (if practical) a rendered
dependency graph.

---

## Notes for the atlas agent

- **All visualization code must be SageMath** (`.sage` files), run via
  `./sagew`. Use `matplotlib` with `Agg` backend, DPI 180-200, matching
  the existing style. See any existing script for the import pattern.

- **The project uses exact arithmetic** (QQ, RealField). Visualization
  data should be converted to float only at plot time.

- **25 partition kinds** are defined in `lib/partitions.sage` via
  `PARTITION_KINDS`; `build_case_table()` exposes 27 executable zoo cases
  because `scramble_x` expands into two synthetic cases. The authoritative
  constructor is `build_partition(depth, kind=..., **kwargs)`, which returns
  row dicts, not just breakpoints. Use `partition_row_map(...)` or
  `float_cells(...)` when plotting convenience views. Always test on at least
  `geometric_x`, `uniform_x`, and one adversary.

- **Keystone case computation** already exists. Prefer
  `experiments/keystone/keystone_runner.sage::compute_case(...)` and the
  canonical summary / per-cell CSV schemas before inventing new ad hoc data
  pipelines.

- **Prefer existing artifacts first.** Many gaps should be fillable from
  `keystone/results/*.csv`, `wall/results/*.csv`, or `tiling/results/*`
  without repeating the original sweep.

- **Flag expensive recomputation first.** If a visualization requires a new
  long-running sweep rather than a lightweight derived pass, stop and surface
  that cost before launching it.

- **Fractal renderer** in `stepstone/fractal/` uses a custom raster
  approach, not matplotlib. Don't try to extend it; write new viz as
  standard matplotlib.

- **The project's nautical-cartographic naming convention** (Distant Shores,
  Dangerous Shoals, Abyssal Doubt, Ripple, etc.) is intentional. Name new
  visualizations descriptively, not thematically.

- **Read `AGENTS.md`** for import conventions and how to run scripts.

---

## Part D. Implementation Status (Phase 4b output)

8 scripts implemented covering all 9 P0+P1 gaps (G6 and G7 share one script).

| Gap | Script | Output | Data | Runtime est. |
|-----|--------|--------|------|-------------|
| G1 | `stepstone/epsilon_portrait.sage` | `stepstone/results/epsilon_portrait.png` | pure function | <5s |
| G15 | `keystone/scaling_summary.sage` | `keystone/results/scaling_summary.png` | wall_surface CSV + enriched CSV | <5s |
| G10 | `wall/exponent_robustness.sage` | `wall/results/exponent_robustness.png` | enriched CSV + robustness CSV | <5s |
| G16 | `tiling/zoo_field_summary.sage` | `tiling/results/zoo_field_summary.png` | zoo_case_metrics.csv | <5s |
| G4 | `keystone/delta_tables.sage` | `keystone/results/delta_tables.png` | compute_case() x2 | ~60s |
| G9 | `wall/li_vs_ld_shape.sage` | `wall/results/li_vs_ld_shape.png` | joined_layer_modes.csv + h1a/h1c CSVs | <5s |
| G6+G7 | `wall/absorption_staircase.sage` | `wall/results/absorption_staircase.png` + `binding_cell_migration.png` | q-sweep: compute_case() x24 | ~5-15min |
| G8 | `tiling/layer_allocation.sage` | `tiling/results/layer_allocation.png` | compute_case() x1 (LD) | ~30s |

### Run order

```sh
# Trivial (CSV / pure function) — seconds each
./sagew experiments/stepstone/epsilon_portrait.sage
./sagew experiments/keystone/scaling_summary.sage
./sagew experiments/wall/exponent_robustness.sage
./sagew experiments/tiling/zoo_field_summary.sage
./sagew experiments/wall/li_vs_ld_shape.sage

# Moderate (needs optimize_minimax calls)
./sagew experiments/keystone/delta_tables.sage          # ~60s
./sagew experiments/tiling/layer_allocation.sage         # ~30s
./sagew experiments/wall/absorption_staircase.sage       # ~5-15min (q-sweep)
```

### What each script validates

| Gap | If hypothesis correct | If hypothesis wrong |
|-----|----------------------|---------------------|
| G1 | ε is smooth, concave, peaks at m\*≈0.44, zero at endpoints | (pure math — always correct) |
| G6 | Wall drops in discrete steps; plateaus between stairs | Wall drops smoothly — no staircase |
| G7 | Worst cell migrates from boundaries toward m\* | Worst cell stays near boundary or jumps randomly |
| G4 | LD tables are diffuse (many nonzero entries); LI concentrated | Both have similar sparsity patterns |
| G8 | Layer 0 has largest L∞ norm; layers 1+ have smaller repair contributions | Contributions distributed evenly across layers |
| G9 | Gap reduction > 0 for all kinds; geometric benefits most from LD | LD doesn't help or hurts some kinds |
| G10 | Wall structure is qualitatively similar across exponents | Exponent changes wall structure fundamentally |
| G15 | Geometric free_err < uniform at all depths; gap grows with depth under LI | Scaling relationships differ from K1/K2 claims |
| G16 | Most partition kinds have corr > 0.8 with Δ^L; adversaries don't break it | Low correlation for many kinds — field theory fails |
