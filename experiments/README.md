# Experiment Guide

The `experiments/` directory contains runnable entry points. These scripts are
thin drivers over the `lib/` modules.

Run all commands from project root.

## Current Orientation

- [`LODESTONE.md`](../LODESTONE.md) is the main scientific target.
- The scripts currently checked in mostly characterize the dyadic/geometric
  baseline and its wall; they are not yet a full `L1`-`L3` comparison suite.
- If the repo is organized around the lodestone program, the next primary
  driver should compare geometric and uniform-in-`x` partitions under the same
  optimizer and reporting format.

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

Baseline shared-delta optimization sweep on the dyadic baseline.

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

Current dyadic wall baseline driver.

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

This is the main existing benchmark driver for the matched
dyadic/geometric partition. It is preparatory support for
[`LODESTONE.md`](../LODESTONE.md), not yet the full lodestone test suite.

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

## Missing Next Driver

- A partition-comparison sweep that runs the same minimax pipeline on geometric
  and uniform-in-`x` grids.
- That driver should record cellwise worst-case localization in addition to
  `single_err`, `opt_err`, `free_err`, and `gap`.
- If implemented, that becomes the natural source of truth for `L1`-`L3`.

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
