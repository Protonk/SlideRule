# smale

FSM-parameterised coarse-stage approximations meet tropical complexity.

Day's FRSR analysis gives an exact finite candidate set (H/V/D) for the
error extrema of piecewise-linear coarse approximations to `x^(p/q)`.
This project replaces Day's single global intercept `c` with a
finite-state machine that reads mantissa bits, producing a
prefix-dependent intercept per dyadic cell.  The resulting path family
is the object whose Jukna-type combinatorial structure (Sidon subsets,
cover-free subsets, Minkowski complexity) we measure.

## Layout

```
smale/
├── sagew                        # Sage runner (wraps macOS cask)
├── lib/
│   ├── paths.sage               # Layer 1: residue automaton, path vectors
│   ├── policies.sage            # Layer 1.5: path-dependent intercept policies
│   ├── day.sage                 # Layer 2: plog/pexp, exact H/V/D evaluator
│   ├── jukna.sage               # Layer 3: Sidon / cover-free diagnostics
│   └── trajectory.py            # Day trajectory analysis (pure Python, standalone)
├── experiments/
│   ├── fsm_coarse.sage          # Main experiment: Day × Jukna measurement
│   └── smoke_test.sage          # Sage sanity check
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

# trajectory analysis (pure Python, no Sage needed)
python3 lib/trajectory.py

# sage REPL
./sagew
```

`experiments/fsm_coarse.sage` now compares several named intercept policies:
`zero`, `state_bit`, `terminal_bias`, and `hand_tuned` (currently for `q=3`).

Project-local Sage state is stored in `.sage/`.
