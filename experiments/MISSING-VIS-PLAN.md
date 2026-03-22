# Missing Visualizations: Survey & Bootstrap Plan

Purpose: inventory what the project visualizes today, identify gaps, and
provide a structured plan for an agent to build a richer atlas of missing
visualizations.

---

## Part A. Current Visualization Inventory

### Summary

~50 PNG files across 6 experiment areas. All static matplotlib rendered
from SageMath at DPI 180-200. One custom raster renderer (fractal grids).
No interactive, animated, or 3D-beyond-surface visualizations.

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
