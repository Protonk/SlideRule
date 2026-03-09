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

## Working Hypotheses

### H1. Shared FSM structure gives real approximation power

Hypothesis:
for fixed `alpha` and fixed parameter budget, a shared FSM policy lowers Day's
exact coarse-stage worst-case error by a stable amount relative to the best
single-intercept baseline.

What to test:
add a true `best_single_c` baseline and compare it against the optimized
shared-`delta` policy using the exact H/V/D evaluator. Track both worst
absolute log-error and global log-ratio, not just one of them.

How it is falsified:
if the best shared policy only beats the best single-`c` model in isolated
small cases, or if the gain decays toward zero as depth grows.

Why it is independent:
this is a pure Day-side numerical claim. It can fail even if interesting
combinatorics show up elsewhere.

### H2. The policy-induced active-extrema family actually grows

Hypothesis:
once we move from a single global intercept to a family of FSM policies, the
induced H/V/D active-pattern family grows materially with `q`, depth, or
`(a, b)`, rather than collapsing to a tiny bounded repertoire.

What to test:
extend the `trajectory.py` idea from single-`c` to FSM policies. For each leaf
under a policy, extract an active-pattern signature and then measure distinct
counts, collision counts, additive energy, `|A + A|`, and Sidon/cover-free
subset sizes on those induced objects.

How it is falsified:
if the number of distinct induced signatures saturates quickly, or grows no
faster than the single-`c` pilot already suggests.

Why it is independent:
this is a structure-only claim. It can hold even if FSM policies do not improve
approximation error.

### H3. The relevant Jukna object is the induced pattern family, not the raw path family

Hypothesis:
the Jukna diagnostics that matter are not the raw path-incidence vectors, but
policy-induced active-pattern vectors; only the latter should vary meaningfully
with policy and track approximation quality.

What to test:
for the existing policy menu, compute Sidon / cover-free / additive-collision
statistics twice: once on the raw path vectors and once on induced
active-pattern vectors. Then compare those metrics against exact error
improvement.

How it is falsified:
if induced metrics are no more policy-sensitive than raw path metrics, or if
policy-induced structure does not correlate at all with error improvement.

Why it is independent:
it does not assert that either improvement or growth exists in the abstract. It
asserts where the meaningful object lives.

### H4. There is a real tropical-vs-arithmetic compression story

Hypothesis:
there is a constrained FSM policy class for which the coarse stage admits
polynomial-size state-based evaluation or search, even while the leaf family or
induced signature family grows exponentially; the arithmetic refinement remains
a small second stage.

What to test:
pick a sharply defined policy class, such as layer-invariant rational
corrections from a small alphabet or bounded-variation tables, and implement a
DP or shortest-path-style evaluator over automaton states. Compare its runtime
scaling against exhaustive leaf enumeration as depth grows.

How it is falsified:
if exact evaluation or optimization still effectively requires enumerating
leaves, or if the DP state space blows up in lockstep with the combinatorial
family.

Why it is independent:
this is a complexity claim, not an approximation or structure claim. You could
have a compression gap without a Jukna lower-bound story, and vice versa.

Taken together, these hypotheses separate the possibilities cleanly:

- H1 true, H2 false: useful numerical trick, no serious combinatorics.
- H2 true, H1 false: interesting structure, but not helping approximation.
- H1 and H2 true, H3 false: both phenomena exist, but we are measuring the
  wrong combinatorial object.
- H4 true without the others: there is a computational compression story, but
  not yet a Day-Jukna one.

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
