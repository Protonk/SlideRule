# smale

FSM-parameterised coarse-stage approximations meet scale-equivariant geometry.

Day's FRSR analysis gives an exact finite candidate set for the extrema of
piecewise-linear coarse approximations to `x^(p/q)`. This repo studies finite-
state intercept policies for those coarse approximations. The main guiding push
is now the thesis in [`LODESTONE.md`](LODESTONE.md): on `R_{>0}`, approximation
problems governed by scaling should be organized in log coordinates,
approximated by the affine pseudo-log, and discretized on geometric grids.

The current shared-delta wall work remains important, but as supporting
baseline machinery. It tells us how the legacy `uniform_x` baseline and its
sharing constraints behave, and the repo now has a first direct comparison
against `geometric_x`.

## Documentation

- [`LODESTONE.md`](LODESTONE.md): guiding thesis, structural motivation, and
  the primary `L1`-`L3` tests.
- [`HYPOTHESES.md`](HYPOTHESES.md): active research claims and their status.
- [`WALL.md`](WALL.md): the current obstruction model and its
  decomposition.
- [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md): dated sweep summaries and artifact links.
- [`experiments/README.md`](experiments/README.md): experiment drivers, output
  columns, and which scripts support the lodestone program.
- [`lib/README.md`](lib/README.md): module graph, data contracts, and numerical caveats.
- [`REPORT.md`](REPORT.md): current-cycle handoff, not canonical science.

## Terminology

- `uniform_x`: equal additive width on `[1,2)`.
- `geometric_x`: equal width in `log x` on `[1,2)`.
- `bits` / `binary_prefix`: binary address of a cell, not the cell geometry.
- `index`: integer cell id `0 .. 2^depth - 1`.
- Historical notes may still say "dyadic" for binary addressing or the older
  baseline; in current repo docs, it is not the canonical geometry name.

## Current State

- The first lodestone partition-comparison sweep exists (2026-03-11) and
  compares `uniform_x` against `geometric_x` under the same optimizer.
- `L1` has split into three claims: `L1a` is supported, `L1b` is not generally
  supported under layer-invariant sharing, and `L1c` has first positive
  evidence at `(q, d) = (3, 6)` under layer-dependent sharing.
- `L2` is currently mixed, and `L3` now has first partition-dependent evidence.
- The older H1 sweeps remain useful as legacy `uniform_x` baseline evidence and
  wall diagnostics.

## Reading Order

1. [`README.md`](README.md)
2. [`LODESTONE.md`](LODESTONE.md)
3. [`HYPOTHESES.md`](HYPOTHESES.md)
4. [`WALL.md`](WALL.md)
5. [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md)
6. [`experiments/README.md`](experiments/README.md)
7. [`lib/README.md`](lib/README.md)
8. [`PLAN.md`](PLAN.md)
9. [`REPORT.md`](REPORT.md)

## Layout

```
smale/
├── sagew
├── README.md
├── LODESTONE.md
├── HYPOTHESES.md
├── WALL.md
├── SWEEP-REPORTS.md
├── PLAN.md
├── REPORT.md
├── lib/
│   ├── README.md
│   ├── paths.sage
│   ├── policies.sage
│   ├── day.sage
│   ├── partitions.sage
│   ├── jukna.sage
│   ├── optimize.sage
│   └── trajectory.py
├── experiments/
│   ├── README.md
│   ├── fsm_coarse.sage
│   ├── optimize_delta.sage
│   ├── h1_sweep.sage
│   ├── lodestone_sweep.sage
│   └── smoke_test.sage
├── tests/
│   └── run_tests.sage
└── sources/
    ├── day_generalize_frsr.pdf
    ├── jukna_2016_tropical_sidon.pdf
    ├── rojas_2013_ultrametric.pdf
    └── koiran_portier_rojas_2024_tropical_permanent.pdf
```

## Running

All commands below are run from project root.

```sh
./sagew experiments/fsm_coarse.sage
./sagew experiments/optimize_delta.sage
./sagew experiments/h1_sweep.sage
./sagew experiments/lodestone_sweep.sage
python3 lib/trajectory.py
./sagew tests/run_tests.sage
./sagew
```

## Dependencies And Runtime

- SageMath is required for the `.sage` drivers.
- The optimizer in [`lib/optimize.sage`](lib/optimize.sage) uses `numpy` and
  `scipy.optimize.linprog`.
- [`experiments/fsm_coarse.sage`](experiments/fsm_coarse.sage) is the
  legacy/exploratory entry point.
- [`experiments/optimize_delta.sage`](experiments/optimize_delta.sage) and
  [`experiments/h1_sweep.sage`](experiments/h1_sweep.sage) are the legacy
  baseline drivers on the exact `uniform_x` oracle path.
- [`experiments/lodestone_sweep.sage`](experiments/lodestone_sweep.sage) is
  the current primary comparison driver for `L1`-`L3`.
- The minimax optimizer is implemented as float bisection plus LP feasibility,
  followed by dyadic snapping of the returned parameters. Treat it as a strong
  numerical solver, not a fully certified rational optimum.

Project-local Sage state is stored in `.sage/`.
