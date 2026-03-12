# Experiment Guide

The `experiments/` directory contains runnable entry points. These scripts are
thin drivers over the `lib/` modules.

Run all commands from project root.

## Current Orientation

- [`LODESTONE.md`](../LODESTONE.md) is the main scientific target.
- [`lodestone_sweep.sage`](lodestone_sweep.sage) is the primary current driver
  for `L1`-`L3`.
- [`l1c_grid_sweep.sage`](l1c_grid_sweep.sage) and
  [`l1c_stability_sweep.sage`](l1c_stability_sweep.sage) are focused follow-up
  drivers for the current L1c program.
- [`harmonic_diagnostic_sweep.sage`](harmonic_diagnostic_sweep.sage) is the
  current redistribution-control driver. It compares the existing lodestone
  geometries against reciprocal and mirrored-reciprocal controls.
- [`optimize_delta.sage`](optimize_delta.sage) and
  [`h1_sweep.sage`](h1_sweep.sage) remain legacy baseline drivers on the exact
  `uniform_x` oracle path.
- The repo now has a first partition-comparison sweep, but coverage is still
  sparse and should be extended before treating the lodestone claims as settled.

## Scripts

### `fsm_coarse.sage`

Legacy/secondary Day x Jukna driver.

What it does:

- Builds residue-automaton paths for a chosen `(q, depth)`.
- Chooses an intercept policy such as `zero`, `state_bit`, `terminal_bias`, or
  `hand_tuned`.
- Evaluates exact Day-style coarse-stage metrics on every leaf cell.
- Builds the induced Day-pattern family for that policy.
- Runs additive diagnostics on the induced family.
- Validates the exact evaluator against dense sampling on a small set of cases.

Run:

```sh
./sagew experiments/fsm_coarse.sage
```

Use this when you want:

- exact evaluator spot checks
- induced-family diagnostics under named policies
- the older Day x Jukna exploratory view

Primarily informs:

- [`SWEEP-REPORTS.md`](../SWEEP-REPORTS.md) for background baseline context
- [`HYPOTHESES.md`](../HYPOTHESES.md) for the retired H2/H3 path

Row fields:

- `pol`: policy name.
- `q`, `d`: automaton modulus and bit depth.
- `paths`: total number of leaf paths, usually `2^d`.
- `pat#`: number of distinct induced Day-pattern vectors after deduplication.
- `dim`: ambient dimension of the induced 0-1 vectors.
- `c#`: number of distinct intercepts realized by the policy.
- `cspan`: `max(c_sigma) - min(c_sigma)` across leaves.
- `sum`: sumset size `|A + A|` on the induced family.
- `coll`: ordered-pair sum collisions beyond the first occurrence.
- `E`: additive energy.
- `sidon`: whether the full induced family is already Sidon.
- `s`: greedy/exact Sidon subset size.
- `cf`: greedy/exact cover-free subset size.
- `single`: best single-intercept baseline error.
- `err`: current policy worst-case `max |log2(z)|`.
- `union`: true union-level `log2(zmax/zmin)`.

### `optimize_delta.sage`

Legacy exact shared-delta optimization sweep on the `uniform_x` baseline.

What it does:

- Builds the best single-intercept baseline.
- Computes the free-per-cell lower bound.
- Solves the shared-delta minimax problem with the default optimizer in
  `lib/optimize.sage`.
- Builds the induced Day-pattern family for the optimized policy.
- Reports additive diagnostics for the optimized family next to the error
  numbers.

Run:

```sh
./sagew experiments/optimize_delta.sage
```

This is the expensive layer-invariant sweep.

Primarily informs:

- [`HYPOTHESES.md`](../HYPOTHESES.md)
- [`SWEEP-REPORTS.md`](../SWEEP-REPORTS.md)

Table fields:

- `q`, `d`: automaton modulus and bit depth.
- `#p`: number of shared policy parameters, equal to `1 + 2q`.
- `paths`: number of leaf cells.
- `single_err`: best single-intercept baseline `max |log2(z)|`.
- `opt_err`: optimized shared-delta `max |log2(z)|`.
- `free_err`: free-per-cell lower bound on `max |log2(z)|`.
- `single_u`, `opt_u`, `free_u`: true union-level `log2(zmax/zmin)` under the
  same three baselines.
- `improve`: `single_err - opt_err`.
- `gap`: `opt_err - free_err`.
- `Mopt`: minimum continuous `max |delta_(r,b)|` at the selected minimax `tau`.
- `pat#`: number of distinct induced Day-pattern vectors under the optimized
  policy.
- `sum`: sumset size of the optimized induced family.
- `s`: greedy/exact Sidon subset size on the optimized induced family.
- `cf`: greedy/exact cover-free subset size on the optimized induced family.
- `steps`: optimizer iteration count currently reported by the minimax solver.
- `time`: elapsed wall-clock time for that row.

Important interpretation notes:

- `single_err` is the correct comparison baseline for asking whether shared
  deltas help over a single global intercept.
- `free_err` is not achievable by any shared policy; it is the unconstrained
  lower bound.
- The detailed optimizer dump also reports `tau_cont`, `tau_snap`, dyadic loss,
  whether the snapped policy still matches the continuous target, and whether a
  snap-repair LP was needed.
- The additive columns in this script describe the induced family of the
  optimized policy only.

### `h1_sweep.sage`

Legacy `uniform_x` wall baseline driver.

What it does:

- Sweep 1: fixed `q`, varying depth for H1b
- Sweep 2: fixed depth, varying `q` for H1a
- Sweep 3: layer-invariant vs layer-dependent benchmark comparisons for H1c
- Reports delta-shape statistics for H1d
- Writes CSV artifacts into `experiments/results/`

Run:

```sh
./sagew experiments/h1_sweep.sage
```

This is the main legacy benchmark driver for the exact `uniform_x` oracle path.
Historically these runs were described as "dyadic" because the cells are
addressed by binary prefixes, but geometrically this is the `uniform_x`
baseline. It remains preparatory support for [`LODESTONE.md`](../LODESTONE.md),
not the primary lodestone comparison source.

Primarily informs:

- [`LODESTONE.md`](../LODESTONE.md)
- [`HYPOTHESES.md`](../HYPOTHESES.md)
- [`WALL.md`](../WALL.md)
- [`SWEEP-REPORTS.md`](../SWEEP-REPORTS.md)

Printed columns:

- `q`, `d`: automaton modulus and bit depth
- `#p`: parameter count
- `paths`: leaf count
- `single_err`, `opt_err`, `free_err`
- `improve`
- `gap`
- `imp/sgl`: `improve / single_err`
- `imp/avl`: `improve / (single_err - free_err)`
- `Mopt`: minimum continuous `max |delta|` at the selected minimax `tau`
- `l1_d`: `sum |delta_i|`
- `nnz`: count of entries with `|delta_i| >= Mopt / 10`
- `top2`: L1 mass fraction in the two largest entries
- `time`

CSV outputs:

- `experiments/results/h1b_depth_scaling.csv`
- `experiments/results/h1a_gap_vs_q.csv`
- `experiments/results/h1c_layer_dependent.csv`

### `lodestone_sweep.sage`

Primary partition-comparison driver for the lodestone program.

What it does:

- Runs the same minimax pipeline on `uniform_x` and `geometric_x`.
- Records both summary metrics and per-cell localization data.
- Compares layer-invariant and layer-dependent sharing at the lodestone
  benchmark points.
- Includes a small secondary `alpha` checkpoint in addition to the main
  `alpha = 1/2` runs.

Run:

```sh
./sagew experiments/lodestone_sweep.sage
```

Primarily informs:

- [`LODESTONE.md`](../LODESTONE.md)
- [`HYPOTHESES.md`](../HYPOTHESES.md)
- [`WALL.md`](../WALL.md)
- [`SWEEP-REPORTS.md`](../SWEEP-REPORTS.md)

Artifacts:

- [`experiments/results/lodestone_summary.csv`](results/lodestone_summary.csv)
- [`experiments/results/lodestone_percell.csv`](results/lodestone_percell.csv)

Summary fields:

- `partition_kind`, `alpha`, `q`, `depth`, `layer_dependent`
- `single_err`, `opt_err`, `free_err`
- `improve`, `gap`
- worst-cell metadata and runtime

Per-cell fields:

- cell bounds in both `x` and `plog`
- `cell_worst_err`, `cell_log2_ratio`
- optimized path intercept and free-per-cell intercept
- worst-candidate type and location

### `l1c_grid_sweep.sage`

Focused follow-up driver for the first L1c expansion.

What it does:

- tests whether geometric still beats uniform under layer-dependent sharing on
  a small `(q, depth)` grid at `alpha = 1/2`
- writes a separate run-directory artifact set under
  `experiments/results/lodestone/`
- keeps the first lodestone comparison artifacts untouched

Run:

```sh
./sagew experiments/l1c_grid_sweep.sage
```

Use this when you want:

- the first post-benchmark L1c grid
- a clean follow-up artifact set rather than appending to the original
  lodestone CSVs

### `l1c_stability_sweep.sage`

Focused follow-up driver for the current q=3 and alpha-robustness checks.

What it does:

- fills in the q=3 layer-dependent depth band at `alpha = 1/2`
- adds the first small `alpha = 1/3` robustness checks
- reuses exact-match rows from earlier lodestone artifact sets where possible
- writes a fresh run directory with `source_run` provenance columns

Run:

```sh
./sagew experiments/l1c_stability_sweep.sage
```

Use this when you want:

- the current best evidence about the q=3 layer-dependent band
- the first non-`1/2` checks for L1c
- an artifact set that distinguishes reused versus newly generated rows

### `harmonic_diagnostic_sweep.sage`

Redistribution-control driver for the post-L1c interpretation check.

What it does:

- reuses exact-match `uniform_x` and `geometric_x` rows from the L1c grid
- reuses prior `harmonic_x` rows when present
- runs the mirrored reciprocal control `mirror_harmonic_x` fresh
- writes a single corrected artifact set with per-row provenance

Run:

```sh
./sagew experiments/harmonic_diagnostic_sweep.sage
```

Use this when you want:

- to compare `uniform_x`, `geometric_x`, reciprocal spacing, and the actual
  opposite-end reciprocal control on the same grid
- to test whether the layer-dependent advantage is specific to log-like
  geometry or survives other redistributions of cell resolution

## Next Comparison Expansions

- Extend the layer-dependent comparison beyond `(q, d) = (3, 6)`.
- Add more secondary `alpha` checkpoints.
- Use the per-cell artifacts to compare worst-cell movement and error
  concentration across partition kinds.

### `smoke_test.sage`

Compatibility wrapper around the real test suite in `tests/run_tests.sage`.

Run:

```sh
./sagew experiments/smoke_test.sage
```

For actual regression checking, use:

```sh
./sagew tests/run_tests.sage
```

## Generated Files

Sage may emit sibling `.sage.py` files next to the drivers. Those are generated
artifacts, not source-of-truth files.

## Runtime And Dependencies

- All `.sage` experiments require SageMath.
- `optimize_delta.sage` also requires the SciPy/NumPy stack used by
  `lib/optimize.sage`.
- `lib/trajectory.py` is not an experiment driver in this directory, but it is
  still useful for quick pure-Python pilot work on the older fixed-intercept
  trajectory question.
