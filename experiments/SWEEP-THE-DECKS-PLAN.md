# Sweep the Decks

Four steps: organize, narrow, delete, re-organize.

The goal is to make the experiments/ folder legible at a glance, so that
each experiment's role in the TRAVERSE roadmap is obvious and the visual
artifacts we carry are ones we can explain.

---

## Inventory

| Experiment | TRAVERSE step | Hypotheses | ~Scripts | ~PNGs | Status |
|------------|---------------|------------|----------|-------|--------|
| keystone/ | 1–3 | K1a–c, K2, K3, H1 | 13 | 10 | Concluded |
| wall/ | 2–3 | K3, W1 | 16 | 13 | Core done; damage/ open |
| alternation/ | 2–3 | K3 (supports) | 9 | 4 | Concluded |
| stepstone/ | 1 | K1a mechanism | 13 | 12 | Concluded |
| ripple/ | 1 | (partition diagnostic) | 5 | 5 | Concluded |
| tiling/ | 3–6 | T1, T2, T3 | 12 | 12 | Active |
| rotation/ | 2 | (Charybdis test) | 6 | 6 | Concluded |

Shared root utilities: `zoo_figure.sage`, `sweep_driver.sage`,
`coastline_series.sage`, `EXPERIMENTS.md`, `AGENTS.md`.

---

## Step 1. Organize — sort into root / aft / fore

Three destinations:

- **root** (`experiments/`): active experiments near the current step
  (Steps 4–7) that we are likely to extend.
- **aft** (`experiments/aft/`): experiments whose results are depended on
  but that are not about to be extended. Archival, not dead.
- **fore** (`experiments/fore/`): experiments whose main articulation is
  ahead of us. Written but not yet fully exploited.

### Proposed assignments

| Experiment | Destination | Rationale |
|------------|-------------|-----------|
| tiling/ | **root** | Directly addresses Steps 5–6 (coordinate change, exchange rate). Basis identification and displacement field are the active front. |
| wall/ (top-level) | **root** | Wall definition is load-bearing for Steps 4–7. `absorption_staircase` and `binding_cell_migration` directly serve Step 4 (exchange rate). |
| wall/damage/ | **fore** | W1 negative result established, but user says "not done figuring out what's up with damage." Main articulation ahead. Will become `fore/damage/`. |
| rotation/ | **aft** | Test of Charybdis is complete. All three plans executed. Results depended on by TRAVERSE Step 2 and ABYSSAL-DOUBT §4. Not extending. |
| keystone/ | **aft** | K1–K3 and H1 established. Sweep data depended on by wall/ and alternation/. Not extending. |
| alternation/ | **aft** | Sign-pattern analysis complete. Supports K3. Not extending. |
| stepstone/ | **aft** | K1a mechanism exhibited. Fractal art is a visual capability to preserve. Not extending. |
| ripple/ | **aft** | Coastline convergence complete. Not extending. |

### Moves

```
mkdir experiments/aft experiments/fore

mv experiments/rotation   experiments/aft/rotation
mv experiments/keystone   experiments/aft/keystone
mv experiments/alternation experiments/aft/alternation
mv experiments/stepstone  experiments/aft/stepstone
mv experiments/ripple     experiments/aft/ripple

mv experiments/wall/damage experiments/fore/damage
```

After this step:

```
experiments/
  wall/             ← active (Steps 2–4)
  tiling/           ← active (Steps 3–6)
  aft/
    keystone/       ← concluded (Steps 1–3)
    rotation/       ← concluded (Step 2)
    alternation/    ← concluded (Steps 2–3)
    stepstone/      ← concluded (Step 1)
    ripple/         ← concluded (Step 1)
  fore/
    damage/         ← future (wall mechanism)
  zoo_figure.sage
  sweep_driver.sage
  coastline_series.sage
  EXPERIMENTS.md
  AGENTS.md
```

### Fixups after moving

- Update `import` / `load` / `pathing` calls in moved scripts that
  reference sibling experiments or shared utilities. The `pathing()`
  helper resolves from project root, so most paths are fine. Check:
  - `alternation/` scripts that read keystone percell CSV
  - `wall/damage/` scripts that load `wall/_foreign_error.sage`
  - `rotation/spectral/` scripts that load `rotation/charybdis_*.sage`
  - `EXPERIMENTS.md` relative links to experiment .md files

- Update `EXPERIMENTS.md` directory references.
- Update `README.md` layout tree if it lists experiment paths.
- Update cross-references in reckoning/ docs that point to experiment paths
  (e.g., TRAVERSE Step 2 points to `experiments/rotation/ROTATION.md`).

---

## Step 2. Narrow — simplify each experiment

Go experiment by experiment. For each one: read the doc, read the
scripts, read the results. Coalesce redundant files, flatten unnecessary
subdirectories, remove stale intermediates.

### 2a. keystone/ (aft)

1. **Dated run directories.** Three exist: `keystone_2026-03-11/`,
   `partition_2026-03-18/`, `wall_surface_2026-03-18/`. The oldest
   (`keystone_2026-03-11/`) is superseded by the later sweeps. Check
   whether any script or doc references it. If not, delete the directory
   and its README.

2. **h1_report.md and historical.md.** These are run-level narrative
   docs inside results/. If their content has been absorbed into
   KEYSTONE.md or EXPERIMENTS.md, delete them.

3. **`delta_tables.sage` and `scaling_summary.sage`.** These appear in
   the explore report but not in KEYSTONE.md's script table. Check
   whether they produce artifacts referenced anywhere. If orphaned,
   delete.

4. **`inspect_case.sage`.** Single-case workbench, outputs to stdout.
   Keep — it's a diagnostic tool, not a vis.

### 2b. wall/ (root)

1. **`exponent_robustness.sage` vs `exponent_robustness_sweep.sage`.**
   Check whether the former is an old version of the latter. If so,
   delete the old one.

2. **`displacement_structure.sage` and `damage_vs_wall.sage`.** These
   produce data for exchange_rate/. Confirm they are still needed or
   whether their outputs are already in the CSV. If the CSV is
   self-sufficient, the scripts can stay but don't need re-running.

3. **`li_vs_ld_shape.sage`.** Diagnostic plot. Check if its content is
   covered by keystone's `gap_surface.sage` or `wall_decomposition.sage`.
   If redundant, mark for deletion in Step 3.

4. **exchange_rate/ subfolder.** Contains summary.csv, percell.csv, and
   2 PNGs. This is exchange-rate data for Step 4 — keep intact.

### 2c. alternation/ (aft)

1. **refinement/ subfolder.** Contains a parallel sweep infrastructure
   (compute_signs, zoo_worker, zoo_split_sequences) that produces
   `zoo_split_sequences.csv` and `split_map.png`. The CSV's content is
   summarized in ALTERNATION.md's split-sequence table. The sweep
   infrastructure (5 scripts + cache) is heavy for what it delivers.
   Consider: keep the CSV and split_map.png, delete the 5 computation
   scripts and the JSONL cache directories. The data is preserved; the
   recomputation path is lost but was never cheap anyway.

2. **`zoo_barcode.sage`.** Computes on the fly via `compute_case` — all
   22 partition kinds at one depth. If `barcode_stack.sage` covers the
   key kinds, this may be redundant. Check whether the zoo barcode is
   referenced anywhere.

### 2d. stepstone/ (aft)

1. **`profiles/` subfolder.** Four zoo-grid visualizations of the same
   underlying data (per-cell chord error). All are variations:
   cartesian envelope, curvature mismatch, polar heatmap, radar peaks.
   Decision deferred to Step 3 (which to keep, which to delete).

2. **`fractal/` subfolder.** Five individual PNGs in `single/` plus two
   atlas PNGs in `grids/`. The user identified fractal/ as a visual
   capability to preserve. Keep the rendering pipeline
   (`raster.sage` + `multiplexer.sage` + `single_fractal.sage` +
   `grid_fractals.sage`) intact.

3. **`plog_chord_argument.sage`.** Symbolic argument, no output file.
   Keep — it's the theoretical backbone.

4. **`epsilon_portrait.sage`.** Standalone plot of ε(m). Check whether
   this is referenced or whether ε is plotted elsewhere (tiling, wall).
   If redundant, mark for Step 3.

### 2e. ripple/ (aft)

1. **Five scripts, five PNGs.** The scripts are small and independent.
   No obvious coalescing. Decision on which PNGs to keep deferred to
   Step 3.

### 2f. tiling/ (root)

1. **Zoo subfolder.** 11 CSVs + 3 PNGs. The zoo sweep is the
   comprehensive T3 test. Keep intact — active experiment.

2. **`binary_cascade.sage`, `tiling_trick.sage`, `two_slicings.sage`.**
   These are explanatory visualizations of the tiling framework. Check
   whether they are referenced in TILING.md. If not, mark for Step 3.

3. **`basis_overlay.sage`.** Visualization companion to
   `basis_identification.sage`. Check whether it produces a PNG that is
   referenced. If the overlay is redundant with
   `basis_template_overlays.png`, one can go.

4. **`layer_allocation.sage`.** Check its role — if it's a one-off
   diagnostic for T2, it may be redundant with displacement_field_test
   Stage B.

### 2g. rotation/ (aft)

1. **Spectral subfolder.** Self-contained program with its own plans:
   `SPECTRAL.md`, `SPECTRAL-PLAN.md`. The plans are now executed and
   concluded. Delete `SPECTRAL-PLAN.md` (plan artifacts don't survive
   execution). Keep `SPECTRAL.md` as the framing doc.

2. **`ADVERSARY-PLAN.md`.** Also executed and concluded. Delete.

3. **Spectral sidecar .npz files.** These are large binary blobs
   (~57 files at ~100KB each). They back the 4 spectral plots and
   enable re-plotting without re-running. Decision: keep them (they're
   the data behind the plots). But note their size.

### 2h. fore/damage/

1. **Nine PNGs from eight scripts.** Several are variations on the
   balance ratio: `balance_ratio_linear.png`, `balance_ratio.png`,
   `log_ratio.png` are three views of the same quantity. Decision
   deferred to Step 3.

2. **`balance_summary.csv` → downstream scripts.** Three scripts depend
   on this CSV. Keep the CSV and the dependency chain intact for now.

### 2i. Shared utilities

1. **`coastline_series.sage`.** Used by ripple/ and stepstone/. After
   the move, both consumers are in aft/. The utility stays at root
   because `pathing()` resolves from project root regardless.

2. **`AGENTS.md`.** Check whether it's still accurate post-reorg. If it
   describes the old layout, update or delete.

---

## Step 3. Delete — say goodbye to charts

Every visualization we keep must pass two tests:

1. **Can I explain it?** The chart must have a one-sentence explanation
   of what it shows and why it matters.
2. **Does it reflect back?** The explanation must connect to a claim in
   TRAVERSE, EXPERIMENTS.md, or an experiment's own .md file.

Charts that fail both tests are deleted along with the scripts that
produce them.

### 3a. keystone/ (aft)

| Chart | Explain? | Reflects? | Verdict |
|-------|----------|-----------|---------|
| `wall_decomposition.png` | Floor/captured/wall across depths and kinds | K3 | **keep** |
| `gap_surface.png` | (q, depth) heatmap for multiple kinds and layer modes | K2 | **keep** |
| `error_profile.png` | Per-cell worst error vs position for one case | K1a | **keep** — the simplest illustration of K1a |
| `intercept_displacement.png` | How far sharing pushes each cell; LI vs LD | W1, fan-out | **keep** |
| `coordinate_uniqueness.png` | Thesis exhibit §6 | DEPARTURE-POINT | review — is the thesis exhibit load-bearing for any current claim? |
| `surrogacy_test.png` | Thesis exhibit §7 | DEPARTURE-POINT | review — same question |
| `float_formats.png` | Thesis exhibit §8 | DEPARTURE-POINT | review — same question |
| `compatibility_matrix.png` | Thesis exhibit §9 | DEPARTURE-POINT | review — same question |
| `delta_tables.png` | Delta table shape visualization | ? | likely **delete** — check references first |
| `scaling_summary.png` | Scaling overview | ? | likely **delete** — check references first |

The four thesis exhibits (coordinate_uniqueness, surrogacy, float_formats,
compatibility_matrix) support DEPARTURE-POINT but not any current TRAVERSE
step. If DEPARTURE-POINT.md references them by name, keep. If it only
describes the ideas and the plots were one-off illustrations, delete.

### 3b. wall/ (root)

| Chart | Explain? | Reflects? | Verdict |
|-------|----------|-----------|---------|
| `worst_cell_map.png` | Which cell binds the minimax | K3 | **keep** |
| `wall_excess_ribbons.png` | Excess error per cell under sharing | K3 | review — may duplicate intercept_displacement |
| `gap_collapse.png` | How gap changes with parameters | K3 | **keep** |
| `candidate_phase_barcode.png` | Which candidates are active | diagnostic | review |
| `absorption_staircase.png` | Step 4 exchange rate prediction | Step 4 | **keep** |
| `li_vs_ld_shape.png` | LI vs LD error profiles | K3 | review — may duplicate gap_surface |
| `binding_cell_migration.png` | How binding cell moves with parameters | Step 4 | **keep** |
| exchange_rate/ PNGs (2) | Displacement structure | W1 | **keep** |

### 3c. alternation/ (aft)

| Chart | Explain? | Reflects? | Verdict |
|-------|----------|-----------|---------|
| `barcode_stack.png` | Sign pattern depth stack, 4 kinds × LI/LD | K3, ALTERNATION | **keep** — the defining visualization |
| `rle_ribbons.png` | Run-length structure | K3 | review — supplements barcode but may be redundant |
| `zoo_barcode.png` | All 22 kinds at one depth | K3 | review — comprehensive but is the breadth needed? |
| `refinement/split_map.png` | Where new sign boundaries appear | K3 | **keep** — shows refinement structure |

### 3d. stepstone/ (aft)

| Chart | Explain? | Reflects? | Verdict |
|-------|----------|-----------|---------|
| `chord_slope_crossing.png` | Step function with m* crossover | K1a, STEPSTONE | **keep** — the key illustration |
| `many_steps_miss.png` | N=8,16,32,64 overlays all miss m* | K1a | **keep** — shows universality of crossing |
| `epsilon_portrait.png` | ε(m) itself | foundational | review — is it plotted elsewhere? |
| profiles/`cartesean_envelope.png` | Sawtooths with peak envelopes | K1a | **keep** — the most informative of the four profiles |
| profiles/`curvature_mismatch.png` | Cell width vs optimal width | K1a | review — the curvature argument is in the text |
| profiles/`polar_heatmap.png` | Polar error heatmaps | K1a | likely **delete** — pretty but does it add to cartesian? |
| profiles/`radar_peaks.png` | Radar plot: geometric is a circle | K1a | review — memorable image but may be redundant |
| fractal/`complete_atlas.png` | Grid of all partition fractals | visual capability | **keep** — user flagged |
| fractal/`geo_vs_chaos.png` | Geometric vs chaotic comparison | visual capability | **keep** |
| fractal/ singles (5) | Individual partition fractals | visual capability | review — keep 1-2 best, delete rest? |

### 3e. ripple/ (aft)

| Chart | Explain? | Reflects? | Verdict |
|-------|----------|-----------|---------|
| `stability_heatmap.png` | Convergence classification grid | RIPPLE | **keep** — the defining visualization |
| `settlers.png` | 8 converging sparklines | RIPPLE | **keep** — shows convergence |
| `divergent.png` | 7 diverging sparklines | RIPPLE | **keep** — shows divergence |
| `area_comparison.png` | Geometric vs golden wobble | RIPPLE | review — specific comparison, may not be load-bearing |
| `integrate_coastline.png` | Raw area bar chart | RIPPLE | likely **delete** — settlers/divergent cover this |

### 3f. tiling/ (root — active, light touch)

| Chart | Explain? | Reflects? | Verdict |
|-------|----------|-----------|---------|
| `t3_summary.png` | 9 partitions' R0(c*) collapsing onto ε template | T3 | **keep** — the key result |
| `binary_cascade.png` | Binary tiling cascade visualization | TILING framework | review |
| `tiling_trick.png` | Tiling trick explanation | TILING framework | review |
| `two_slicings.png` | Horocyclic vs geodesic slicing | TILING framework | review |
| `layer_allocation.png` | Layer-0 allocation diagnostic | T2 | review |
| `zoo_field_summary.png` | Zoo field summary | T3 | review |
| displacement_field/ PNGs (2) | R0(c*) vs R0(Δ^L) | T1 | **keep** |
| basis_identification/ PNG (1) | Basis overlays | T3 | **keep** |
| zoo/ PNGs (3) | Zoo sweep visualizations | T3 | review |

For tiling/, be conservative — it's active. Only delete charts that are
clearly superseded.

### 3g. rotation/ (aft)

| Chart | Explain? | Reflects? | Verdict |
|-------|----------|-----------|---------|
| `wall_zscore_scaling.png` | Z-score grows exponentially with depth | Charybdis | **keep** |
| `xi_signmap_d8.png` | ξ_n structured sign pattern | Charybdis | **keep** |
| spectral/`plot_a_qscan.png` | Walsh profile across q values | spectral | **keep** — q-dependence |
| spectral/`plot_b_placement.png` | Geometry vs placement | spectral | review |
| spectral/`plot_c_inherited.png` | Inherited vs induced spectrum | spectral | **keep** — the key spectral finding |
| spectral/`plot_d_shape_null.png` | JSD null with FSM score | spectral | **keep** — statistical test |

### 3h. fore/damage/

| Chart | Explain? | Reflects? | Verdict |
|-------|----------|-----------|---------|
| `counter_factual.png` | Per-cell incoming vs exported error | DAMAGE | **keep** — the defining vis |
| `amplification.png` | Median excess R-1 across zoo | DAMAGE | **keep** — shows geometric robustness |
| `amplification_polar.png` | Same in polar coordinates | DAMAGE | likely **delete** — polar adds aesthetics, not information |
| `balance_ratio_linear.png` | Balance ratio per cell, linear | DAMAGE | review — one of three balance views |
| `balance_ratio.png` | Balance ratio in polar | DAMAGE | review |
| `log_ratio.png` | Log-ratio in polar | DAMAGE | likely **delete** — third view of same data |
| `balance_scatter.png` | Territory vs intensity scatter | DAMAGE | **keep** — separates structural classes |
| `balance_bars.png` | Diagonal residual ranked by balance | DAMAGE | review |
| `balance_bars_anti.png` | Anti-diagonal residual | DAMAGE | review |

Of the balance visualizations, keep at most 2 of the 5. The scatter
(`balance_scatter.png`) is the most informative. Pick one of
`balance_ratio_linear.png` or `balance_bars.png` as the spatial view.
Delete the rest.

### Execution

For each "review" item: read the chart (or the script that produces it),
write the one-sentence explanation, and check whether the explanation
connects to a current claim. If it does, promote to "keep." If not,
delete the PNG and the script that produces it.

For each "delete" item: delete the PNG. If the script produces only that
PNG, delete the script too. If the script produces multiple outputs and
some are kept, leave the script.

After deletion, verify that no surviving script references a deleted
output, and no .md file references a deleted chart.

---

## Step 4. Re-organize — fold experiments post-narrowing

After narrowing and deletion, some experiments may have become thin enough
to merge. Look for:

1. **alternation/ into wall/.** Both study the wall's spatial structure.
   Alternation's sign patterns are the wall's spatial fingerprint.
   After narrowing, alternation/ may be just `barcode_stack.sage`,
   `sign_sequences.sage`, `split_map.png`, and `ALTERNATION.md`. That
   could become `wall/alternation/` or `aft/wall/alternation/` depending
   on whether wall stays at root.

   Condition: only merge if alternation/ has ≤4 files after narrowing.

2. **ripple/ into stepstone/.** Both study partition geometry at the
   per-cell level. Ripple's coastline area is the integral of
   stepstone's chord slope deviation. After narrowing, ripple/ may be
   3 PNGs + 5 small scripts + `RIPPLE.md`.

   Condition: only merge if the resulting stepstone/ is still legible
   (no more than ~15 files total).

3. **Shared utilities.** After moves, check whether `coastline_series.sage`
   and `zoo_figure.sage` are still used by root-level experiments. If
   they're only used by aft/ experiments, move them to aft/ or into the
   specific consumer.

4. **EXPERIMENTS.md update.** Rewrite the experiment-areas section to
   reflect the new layout. Update all relative links. Add aft/ and fore/
   sections.

5. **AGENTS.md.** Either update to describe the new layout or delete if
   it's no longer needed.

### Final tree (target)

```
experiments/
  wall/               ← active (Steps 2–4, exchange rate)
  tiling/             ← active (Steps 3–6, displacement field)
  aft/
    keystone/         ← K1–K3, H1 (concluded)
    rotation/         ← Charybdis test (concluded)
    alternation/      ← sign patterns (concluded) [or merged into wall/]
    stepstone/        ← K1a mechanism + fractals (concluded)
    ripple/           ← coastline convergence (concluded) [or merged into stepstone/]
  fore/
    damage/           ← foreign-error analysis (future)
  zoo_figure.sage
  sweep_driver.sage
  coastline_series.sage
  EXPERIMENTS.md
```

---

## Execution order

Steps 1–4 are sequential. Within each step, work experiment by
experiment in the order listed. After each move or deletion, verify that
`./sagew` can still load the affected scripts (spot-check, not
exhaustive).

Step 1 is mechanical (mkdir + mv + fixup).
Step 2 requires reading and judgment — go slow.
Step 3 is the hardest — it requires looking at each chart.
Step 4 is contingent on what survives Steps 2–3.
