# smale

FSM-parameterised coarse-stage approximations meet tropical complexity.

Day's FRSR analysis gives an exact finite candidate set (H/V/D) for the
error extrema of piecewise-linear coarse approximations to `x^(p/q)`.
This project replaces Day's single global intercept `c` with a
finite-state machine that reads mantissa bits, producing a
prefix-dependent intercept per dyadic cell.  The resulting path family
induces a Day-pattern vector family whose Jukna-type combinatorial
structure (Sidon subsets, cover-free subsets, additive collisions,
sumsets, additive energy) we measure.

## Layout

```
smale/
├── sagew                        # Sage runner (wraps macOS cask)
├── lib/
│   ├── paths.sage               # Layer 1: residue automaton, path vectors
│   ├── policies.sage            # Layer 1.5: path-dependent intercept policies
│   ├── day.sage                 # Layer 2: plog/pexp, exact H/V/D evaluator
│   ├── jukna.sage               # Layer 3: Sidon / cover-free diagnostics
│   ├── optimize.sage            # Dyadic shared-delta and free-per-cell optimization
│   └── trajectory.py            # Day trajectory analysis (pure Python, standalone)
├── experiments/
│   ├── fsm_coarse.sage          # Main experiment: Day × Jukna measurement
│   ├── optimize_delta.sage      # Optimization sweep with corrected baselines
│   └── smoke_test.sage          # Wrapper around the project test suite
├── tests/
│   └── run_tests.sage           # Project tests
└── sources/
    ├── day_2022_frsr.pdf         # Day — generalising the FRSR algorithm
    ├── jukna_2016_tropical_sidon.pdf
    ├── rojas_2013_ultrametric.pdf
    └── koiran_portier_rojas_2024_tropical_permanent.pdf
```

## Running

All commands from project root:

```sh
# main experiment
./sagew experiments/fsm_coarse.sage

# optimization sweep
./sagew experiments/optimize_delta.sage

# trajectory analysis (pure Python, no Sage needed)
python3 lib/trajectory.py

# project tests
./sagew tests/run_tests.sage

# sage REPL
./sagew
```

## Current Experiment Shape

- `experiments/fsm_coarse.sage` compares several named intercept policies:
  `zero`, `state_bit`, `terminal_bias`, and `hand_tuned` (currently for `q=3`).
- Coarse-stage metrics now include:
  `best_single_c`, worst-case `max |log2(z)|`, max cell ratio, and the true
  union-level `log2(zmax/zmin)` over all leaves.
- The combinatorial object is the induced Day-pattern family, not the raw
  automaton path family.
- Small-instance Sidon and cover-free subset sizes are certified exactly; the
  greedy routines remain available and are still reported alongside them.
- `experiments/optimize_delta.sage` uses dyadic-quantized shared-delta search
  and compares optimized policies against the best single intercept and the
  free-per-cell lower bound.

Project-local Sage state is stored in `.sage/`.
