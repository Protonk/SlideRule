# Experiment Guide

The `experiments/` directory contains runnable entry points. These scripts are
thin drivers over the `lib/` modules and are the intended way to inspect the
current research state from the command line.

Run all commands from project root.

## Scripts

### `fsm_coarse.sage`

Main coupled Day x Jukna experiment.

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

This is the faster experiment and the best first run after changing code.

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

Optimization sweep for shared-delta policies.

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

This is the expensive sweep. Expect it to take substantially longer than
`fsm_coarse.sage`, especially as `q` and `depth` grow.

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

## Hypothesis Status and Experiment Roadmap

This repo is organized around four research hypotheses from the root README.
The first full sweep with the bisection+LP minimax solver was run on
2024-03-09. Results are summarized here; see the root README for the full
hypothesis statements and empirical findings.

### H1. Shared FSM structure gives real approximation power — Confirmed, weak

Driver: `optimize_delta.sage`

Key findings (alpha=1/2, 10 cases, q=1..5, depth=4..8):

- `improve > 0` in all cases. Best relative gain ~54% at q=5/d=4.
- Improvement decays with depth at fixed q.
- `gap >> improve` everywhere: the sharing constraint, not solver weakness, is
  the bottleneck.

Open follow-ups:

- Fixed-budget sweep: hold `1 + 2q` constant while depth grows, to measure
  whether `improve / single_err` stabilizes or decays to zero.
- Multi-alpha sweeps beyond `alpha = 1/2`.
- Characterize the structural wall: is it a property of layer-invariant
  `(state, bit)` parameterization specifically, or of any `O(q)`-parameter
  shared scheme?

### H2. The policy-induced active-extrema family actually grows — Falsified

Driver: `optimize_delta.sage` (pat# column)

Key finding: `pat# = 2` or `3` in all 10 cases. The minimax objective
equalizes cells, collapsing their Day-pattern signatures. Sumset sizes are 3–6
and the full family is trivially Sidon.

The minimax objective is structurally antagonistic to pattern diversity. A
different objective (average error, or diversity-maximizing under an error
budget) might produce richer families, but that would be a different research
question.

### H3. The relevant Jukna object is the induced pattern family — Moot

Moot because `pat# = 2–3` leaves no meaningful additive structure to measure.

### H4. Tropical-vs-arithmetic compression — Open, less motivated

Not yet tested directly. The LP already operates on `1 + 2q` parameters rather
than `2^depth` leaves, which is a form of compressed evaluation. But with H2
falsified, the original motivation (compressing an exponentially growing induced
family) does not apply.

### Refined H1 sub-hypotheses

See the root README for full statements. Summary:

- **H1a**: the gap closes with parameter budget at fixed depth. Test by
  sweeping q at fixed depth=4. Predicted crossover: `gap < improve` for some q.
- **H1b**: `improve / single_err` has a nonzero limit as depth grows at fixed
  q. Test by sweeping depth at fixed q=5.
- **H1c**: the wall is specific to layer-invariant parameterization. Requires
  extending the optimizer to layer-dependent `delta[(layer, state, bit)]`.
- **H1d**: the optimal delta table is nearly sparse. Can be read off existing
  data with minor reporting additions.

### Suggested next experiments

Priority order given the current findings:

1. **H1a+H1b sweep**: a single experiment varying q (1..15+) at depth=4, and
   depth (4..10+) at q=5, reports `improve`, `gap`, `improve / single_err`,
   and `gap / (single_err - free_err)`. This is the most important next step.
2. **H1d sparsity check**: add reporting of per-entry delta magnitudes to the
   existing sweep. No new optimizer work needed.
3. **H1c layer-dependent**: extend `optimize_minimax` to support
   `delta[(layer, state, bit)]` parameterization. Requires expanding the
   intercept matrix and LP. Medium implementation effort.
4. **H4 scaling experiment**: lower priority, but the compression of the LP
   itself is still a clean result worth documenting if time permits.

Suggested result artifacts:

- `experiments/results/h1_shared_power.csv`
- `experiments/results/h1a_gap_vs_q.csv`
- `experiments/results/h1b_depth_scaling.csv`
