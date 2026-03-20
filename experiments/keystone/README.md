# Keystone

Compares partition kinds under shared-delta optimization. The core question
is whether geometric partitions achieve lower worst-case error than
alternatives under the FSM sharing constraint.

## Scripts

### `partition_sweep.sage`

The main driver. Edit KINDS, GRID, EXPONENTS, LAYER_MODES at the top, then
run. The pipeline is fully kind-agnostic — any partition kind from
`lib/partitions.sage` works.

```sh
./sagew experiments/keystone/partition_sweep.sage
```

Output: `results/<RUN_TAG>/summary.csv` and `results/<RUN_TAG>/percell.csv`.

### `h1_sweep.sage`

Uniform-only H1 hypothesis baseline: depth scaling (H1b), q scaling (H1a),
layer-dependent comparison (H1c), and delta-shape statistics (H1d).

```sh
./sagew experiments/keystone/h1_sweep.sage
```

### `inspect_case.sage`

Single-case diagnostic workbench. Edit the case configuration at the top
and run. Prints three-metric computation, delta table, induced pattern
family, combinatorial summary, and exact-vs-sampled validation.

```sh
./sagew experiments/keystone/inspect_case.sage
```

### `error_profile.sage`

Per-cell error profile visualization from an existing run's percell CSV.
Edit RUN_TAG at the top to point at the desired run.

```sh
./sagew experiments/keystone/error_profile.sage
```

## Shared machinery

`keystone_runner.sage` provides `compute_case()` plus the canonical
partition-sweep `summary.csv` / `percell.csv` column definitions.
`h1_sweep.sage` reuses `compute_case()` but defines its own H1 CSV schema.

## Results layout

Each `partition_sweep` run creates a dated `results/<RUN_TAG>/` directory
with `summary.csv` and `percell.csv`. H1 outputs are flat CSVs in
`results/`.

Each run directory carries a `README.md` with the box-score tables and
direct observations for that run. The H1 baseline tables are in
`results/h1_report.md`. Older runs whose artifacts exist only in git history
are documented in `results/historical.md`.
