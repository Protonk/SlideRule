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
