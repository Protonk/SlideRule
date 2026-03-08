# smale

FSM-parameterised coarse-stage approximations meet tropical complexity.

Day's FRSR analysis gives an exact finite candidate set for the extrema of
piecewise-linear coarse approximations to `x^(p/q)`. This project replaces
Day's single global intercept `c` with a finite-state machine that reads
mantissa bits and produces a prefix-dependent intercept on each dyadic cell.

The repo now studies three connected objects:

1. A residue automaton path family over mantissa prefixes.
2. An exact Day-style coarse-stage evaluator on each leaf cell.
3. The induced Day-pattern vector family, on which Jukna-style additive
   diagnostics are computed.

The central question is no longer just whether an FSM policy improves Day's
error, but whether the policy-induced active-pattern family acquires
meaningful additive structure at the same time.

## Documentation

- [`lib/README.md`](lib/README.md): module graph, data contracts, and numerical caveats.
- [`experiments/README.md`](experiments/README.md): experiment drivers, output columns, and runtime notes.

## Layout

```
smale/
├── sagew
├── README.md
├── LAUNCHPAD-PLAN.md
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
python3 lib/trajectory.py
./sagew tests/run_tests.sage
./sagew
```

## Current Shape

- [`experiments/fsm_coarse.sage`](experiments/fsm_coarse.sage) is the main
  coupled experiment. It evaluates named intercept policies, computes exact
  coarse-stage metrics, and measures combinatorics on the induced Day-pattern
  family rather than on raw path vectors.
- [`experiments/optimize_delta.sage`](experiments/optimize_delta.sage) compares
  three baselines for each `(q, depth)` case: best single intercept,
  optimized shared-delta policy, and free-per-cell lower bound.
- Exact global metrics include worst-case `max |log2(z)|`, max cellwise
  `log2(zmax/zmin)`, and the true union-level `log2(zmax/zmin)` over all leaves.
- Small-instance Sidon and cover-free subset sizes are certified exactly.
  Greedy sizes are still reported alongside the exact optima.

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
