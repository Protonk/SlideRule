# smale

FSM-parameterised coarse-stage approximations meet tropical complexity.

Day's FRSR analysis gives an exact finite candidate set for the extrema of
piecewise-linear coarse approximations to `x^(p/q)`. This repo studies finite-
state intercept policies for those coarse approximations and, at the moment, is
primarily about the structural wall between shared-delta policies and the
free-per-cell lower bound.

## Documentation

- [`HYPOTHESES.md`](HYPOTHESES.md): active research claims and their status.
- [`WALL.md`](WALL.md): the current obstruction model.
- [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md): dated sweep summaries and artifact links.
- [`lib/README.md`](lib/README.md): module graph, data contracts, and numerical caveats.
- [`experiments/README.md`](experiments/README.md): experiment drivers, output columns, and runtime notes.
- [`REPORT.md`](REPORT.md): current-cycle handoff, not canonical science.

## Current State

- Layer-invariant shared-delta policies beat the best single-intercept baseline
  in finite cases, but the relative gain collapses with depth at fixed `q`.
- At fixed shallow depth, increasing `q` can drive the layer-invariant model
  close to the free-per-cell floor.
- Layer-dependent deltas recover much more of the wall in the tested benchmark
  cases, so layer sharing is the main current suspect.
- The induced-family combinatorics did not survive contact with the minimax
  objective; the project is now centered on H1 and the wall.

## Reading Order

1. [`README.md`](README.md)
2. [`HYPOTHESES.md`](HYPOTHESES.md)
3. [`WALL.md`](WALL.md)
4. [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md)
5. [`experiments/README.md`](experiments/README.md)
6. [`lib/README.md`](lib/README.md)
7. [`PLAN.md`](PLAN.md)
8. [`REPORT.md`](REPORT.md)

## Layout

```
smale/
├── sagew
├── README.md
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
│   ├── jukna.sage
│   ├── optimize.sage
│   └── trajectory.py
├── experiments/
│   ├── README.md
│   ├── fsm_coarse.sage
│   ├── optimize_delta.sage
│   ├── h1_sweep.sage
│   └── smoke_test.sage
├── tests/
│   └── run_tests.sage
└── sources/
    ├── day_2022_frsr.pdf
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
python3 lib/trajectory.py
./sagew tests/run_tests.sage
./sagew
```

## Dependencies And Runtime

- SageMath is required for the `.sage` drivers.
- The optimizer in [`lib/optimize.sage`](lib/optimize.sage) uses `numpy` and
  `scipy.optimize.linprog`.
- [`experiments/fsm_coarse.sage`](experiments/fsm_coarse.sage) is the fast
  entry point. [`experiments/optimize_delta.sage`](experiments/optimize_delta.sage)
  is the expensive sweep.
- The minimax optimizer is implemented as float bisection plus LP feasibility,
  followed by dyadic snapping of the returned parameters. Treat it as a strong
  numerical solver, not a fully certified rational optimum.

Project-local Sage state is stored in `.sage/`.
