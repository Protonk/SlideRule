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
- [`PARTITIONS.md`](PARTITIONS.md): analytical classification of the partition
  family and the current selection rationale.
- [`HYPOTHESES.md`](HYPOTHESES.md): active research claims and their status.
- [`WALL.md`](WALL.md): the current obstruction model and its
  decomposition.
- [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md): dated sweep summaries and artifact links.
- [`experiments/README.md`](experiments/README.md): experiment drivers, output
  columns, and which scripts support the lodestone program.
- [`lib/README.md`](lib/README.md): module graph, data contracts, and numerical caveats.

## Terminology

- `uniform_x`: equal additive width on `[1,2)`.
- `geometric_x`: equal width in `log x` on `[1,2)`.
- `bits` / `binary_prefix`: binary address of a cell, not the cell geometry.
- `index`: integer cell id `0 .. 2^depth - 1`.
- Historical notes may still say "dyadic" for binary addressing or the older
  baseline; in current repo docs, it is not the canonical geometry name.

## Running

All commands below are run from project root.

```sh
./sagew experiments/lodestone/lodestone_sweep.sage
./sagew experiments/lodestone/fsm_coarse.sage
./sagew experiments/lodestone/optimize_delta.sage
./sagew experiments/lodestone/h1_sweep.sage
python3 lib/trajectory.py
./sagew tests/run_tests.sage
./sagew
```

## Dependencies And Runtime

- SageMath is required for the `.sage` drivers.
- The optimizer in [`lib/optimize.sage`](lib/optimize.sage) uses `numpy` and
  `scipy.optimize.linprog`.
- [`experiments/lodestone/fsm_coarse.sage`](experiments/lodestone/fsm_coarse.sage) is the
  legacy/exploratory entry point.
- [`experiments/lodestone/optimize_delta.sage`](experiments/lodestone/optimize_delta.sage) and
  [`experiments/lodestone/h1_sweep.sage`](experiments/lodestone/h1_sweep.sage) are the legacy
  baseline drivers on the exact `uniform_x` oracle path.
- [`experiments/lodestone/lodestone_sweep.sage`](experiments/lodestone/lodestone_sweep.sage) is
  the current primary comparison driver for `L1`-`L3`.
- The minimax optimizer is implemented as float bisection plus LP feasibility,
  followed by dyadic snapping of the returned parameters. Treat it as a strong
  numerical solver, not a fully certified rational optimum.

Project-local Sage state is stored in `.sage/`.
