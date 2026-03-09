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
- [`experiments/optimize_delta.sage`](experiments/optimize_delta.sage) uses a
  bisection+LP minimax solver to find the optimal shared-delta policy for each
  `(q, depth)` case, and compares it against the best single intercept and the
  free-per-cell lower bound.
- The minimax solver uses a lexicographic two-stage LP: stage 1 finds the
  optimal error via bisection on target `tau` + LP feasibility, stage 2
  minimizes `max |delta|` at fixed `tau` for a canonical policy table. Dyadic
  snapping with optional repair ensures the reported policy is honest.
- Exact global metrics include worst-case `max |log2(z)|`, max cellwise
  `log2(zmax/zmin)`, and the true union-level `log2(zmax/zmin)` over all leaves.
- Small-instance Sidon and cover-free subset sizes are certified exactly.
  Greedy sizes are still reported alongside the exact optima.

## Working Hypotheses

### H1. Shared FSM structure gives real approximation power — Confirmed, weak

Hypothesis:
for fixed `alpha` and fixed parameter budget, a shared FSM policy lowers Day's
exact coarse-stage worst-case error by a stable amount relative to the best
single-intercept baseline.

Empirical status (alpha=1/2, bisection+LP minimax sweep, 2024-03-09):
confirmed. `improve = single_err - opt_err > 0` in all 10 tested `(q, depth)`
cases. The best relative gain is ~54% at q=5/d=4. However:

- Improvement decays with depth at fixed q. At d=8, `improve` is ~0.002 on a
  `single_err` of ~0.048.
- Larger q helps: at d=6, q=5 gives `improve=0.013` vs q=1's `improve=0.004`.
- The gap to the free-per-cell bound dominates in every case: `gap >> improve`.
  At d=8, `opt_err ~ 0.045` while `free_err ~ 0.0007`. The sharing constraint
  is the binding bottleneck, not optimizer weakness.

The gain is real but modest. The FSM nibbles at the edge of a structural wall
imposed by the `1 + 2q` parameter sharing constraint.

Open questions:

- Does `improve / single_err` stabilize or decay to zero as depth grows?
- Do multi-alpha sweeps show different behavior?
- Is the structural wall a property of the layer-invariant `(state, bit)`
  parameterization, or of any shared-delta scheme?

### H2. The policy-induced active-extrema family actually grows — Falsified

Hypothesis:
once we move from a single global intercept to a family of FSM policies, the
induced H/V/D active-pattern family grows materially with `q`, depth, or
`(a, b)`, rather than collapsing to a tiny bounded repertoire.

Empirical status:
falsified under the minimax-optimal policy. `pat# = 2` or `3` in all 10 tested
cases, regardless of q (1–5) and depth (4–8). The minimax optimizer equalizes
cells, collapsing their Day-pattern signatures. Sumset sizes are 3–6 and the
full family is trivially Sidon and cover-free.

Why this happens:
the minimax objective minimizes the worst cell's error, which pushes all cells
toward similar intercepts and thus similar breakpoint configurations. This is
the opposite of the diversity needed for interesting additive structure.

What could revive it:
a different objective (e.g., minimizing average error, or maximizing pattern
diversity subject to an error budget) might produce richer families. But that
would be a different research question.

### H3. The relevant Jukna object is the induced pattern family — Moot

Hypothesis:
the Jukna diagnostics that matter are not the raw path-incidence vectors, but
policy-induced active-pattern vectors.

Empirical status:
moot. With `pat# = 2–3`, there is no meaningful additive structure to measure
on the induced family. The question of which family is "relevant" cannot be
answered when the induced family is too small to carry diagnostics.

### H4. There is a real tropical-vs-arithmetic compression story — Open

Hypothesis:
there is a constrained FSM policy class for which the coarse stage admits
polynomial-size state-based evaluation or search, even while the leaf family
grows exponentially.

Empirical status:
not yet tested directly. The bisection+LP solver already exploits the linear
structure of the intercept matrix (the LP operates on `1 + 2q` parameters, not
`2^depth` leaves), which is a form of compressed evaluation. But no dedicated
scaling experiment has been run. The collapse of H2 reduces the motivation for
H4 in its original form (there is no exponentially growing induced family to
compress), though the compression of the optimization problem itself remains
interesting.

### Refined H1 sub-hypotheses

With H1 confirmed and H2–H4 resolved or deferred, the open research front is
understanding the structural wall: why `gap >> improve`, and whether it can be
breached.

#### H1a. The gap closes with parameter budget at fixed depth

At fixed depth, the sharing gap `gap = opt_err - free_err` decreases as q
grows, because more automaton states allow the `1 + 2q` shared parameters to
approximate the `2^depth` free intercepts more closely.

Testable prediction: at depth=4 (16 cells), there exists a q such that
`gap < improve` — i.e., the FSM captures more than half the available
improvement over single-intercept.

Falsified if: `gap` plateaus well above `free_err` even as q grows large
relative to `2^depth`. That would mean the residue automaton's state structure
is a poor basis for approximating the per-cell optima, regardless of how many
parameters you throw at it.

#### H1b. Improvement has a nonzero depth limit at fixed parameter budget

At fixed q, the relative improvement `improve / single_err` converges to a
positive constant as depth grows, rather than decaying to zero. The FSM
captures a stable fraction of the total error, even though absolute `improve`
shrinks (because `single_err` itself is roughly constant while `free_err`
vanishes).

Testable prediction: `improve / single_err` stabilizes above 5% for q=5 as
depth goes from 4 to 10+.

Falsified if: `improve / single_err` decays monotonically toward zero with
depth, meaning the FSM's contribution becomes negligible for deep mantissa
approximation.

#### H1c. The wall is specific to layer-invariant parameterization

The gap is dominated by the constraint that all layers share the same
`delta[(state, bit)]` table. A layer-dependent parameterization
`delta[(layer, state, bit)]` with `1 + 2q * depth` parameters should
substantially reduce the gap at the cost of a larger parameter table.

Testable prediction: at q=3/d=6, layer-dependent optimization yields `gap` at
least 2x smaller than layer-invariant.

Falsified if: layer-dependent parameterization gives only marginal improvement
over layer-invariant, meaning the wall comes from the automaton's state-merging
structure itself (paths that visit the same state get the same correction), not
from the layer-sharing.

#### H1d. The minimax-optimal policy is nearly sparse in the delta table

The stage-2 LP already minimizes `max |delta|`, and the sweep shows `Mopt` is
small (0.001–0.013). A stronger claim: most entries of the optimal delta table
are near zero, with only a few active `(state, bit)` pairs carrying the
improvement.

Testable prediction: at the optimum, at least half the `delta[(r, b)]` entries
have magnitude below `Mopt / 10`.

Falsified if: the optimal delta table is dense — all entries are comparable in
magnitude. That would mean the FSM needs its full parameter budget to achieve
the observed improvement.

#### Experiment plan

H1a and H1b can be tested with a single sweep (vary q and depth). H1c requires
extending the optimizer to handle layer-dependent corrections. H1d can be read
off existing sweep data with a bit more reporting.

### Summary

The empirical picture as of 2024-03-09 is:

- H1 true, H2 false: the FSM is a useful numerical trick with modest gains,
  but there is no serious induced combinatorics under the minimax objective.
- H3 moot: the induced family is too small to carry additive diagnostics.
- H4 open but less motivated in its original form.

This matches the "H1 true, H2 false" row of the original contingency table:
useful numerical trick, no serious combinatorics. The refined H1a–H1d
sub-hypotheses now focus on characterizing the structural wall.

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
