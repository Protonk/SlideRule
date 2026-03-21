# Experiments

Runnable entry points organized by topic. All scripts require SageMath;
run from project root via `./sagew experiments/<topic>/<script>.sage`.

## Subdirectories

### `keystone/`

Partition-comparison sweeps and the guiding thesis. Tests whether geometric
partitions achieve lower worst-case error under shared-delta optimization.
`KEYSTONE.md` contains the thesis, hypotheses, and caveats.

Scripts: `partition_sweep`, `h1_sweep`, `inspect_case`, `error_profile`,
`wall_decomposition`, `gap_surface`, `intercept_displacement`.

### `ripple/`

Normalized asymptotic-behavior experiments for coastline area across
partition families. Focuses on scaled-area convergence, wobble, and
stability diagnostics.

Scripts: `stability_heatmap`, `settlers`, `divergent`, `integrate_coastline`,
`area_comparison`.

### `stepstone/`

Chord error structure and visualization. The theoretical argument for why
geometric partitions equalize per-cell error, plus multi-partition error
profile visualizations and fractal crossing-count art.

Subfolders: `profiles/` (per-partition error visualizations across the zoo),
`fractal/` (fractal raster rendering and outputs).

### `damage/`

Foreign-error analysis: what happens when a cell is forced to use another
cell's chord instead of its own. Amplification ribbons, balance ratios,
and counterfactual error profiles.

Scripts: `amplification`, `amplification_polar`, `balance_bars`,
`balance_bars_anti`, `balance_linear`, `balance_polar`, `balance_scatter`,
`balance_summary`, `counter_factual`.

### `alternation/`

Sign-pattern analysis of the displacement between shared and free-per-cell
intercepts. Barcode visualizations, RLE ribbons, refinement split maps,
and the zoo-wide split-sequence computation pipeline.

See `alternation/ALTERNATION.md` for full documentation.

### `wall/`

The wall obstruction model: definition, decomposition into three nested
sharing constraints, and current evidence. See `wall/WALL.md`.

## Cross-cutting documents

- **`HYPOTHESES.md`** — Active research claims (K1-K3, H1) and their status.

## Shared utilities

- **`zoo_figure.sage`** — Zoo-grid subplot helpers: `zoo_subplots()`,
  `zoo_iter()`, `zoo_hide_unused()`, `zoo_label_edges()`.
- **`sweep_driver.sage`** — CSV and result-directory helpers: `write_csv()`,
  `result_dir()`, `subset_size_str()`.
- **`coastline_series.sage`** — Shared coastline-area computation
  (closed-form antiderivative), scaling helpers, and measure registry.

## Generated files

Sage emits `.sage.py` files next to drivers. These are generated artifacts
and are gitignored.
