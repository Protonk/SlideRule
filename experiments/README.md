# Experiments

Runnable entry points organized by topic. All scripts require SageMath;
run from project root via `./sagew experiments/<topic>/<script>.sage`.

## Subdirectories

### `keystone/`

Partition-comparison sweeps for the keystone program. Tests whether
geometric partitions beat uniform under shared-delta optimization.
CSV results live in `keystone/results/`.

Scripts: `partition_sweep`, `h1_sweep`, `inspect_case`, `error_profile`.

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
