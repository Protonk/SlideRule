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

## Hypothesis-Driven Test Plan

This repo is now organized around four research hypotheses from the root
README. The current drivers already cover part of that space, but not all of
it. This section turns those hypotheses into a concrete experiment queue.

### H1. Shared FSM structure gives real approximation power

Question:
does a shared FSM policy beat the best single-intercept Day model by a stable
margin under a fixed parameter budget?

Current driver:

- `optimize_delta.sage`

What this driver already measures:

- `single_err`, `opt_err`, `free_err`
- `single_u`, `opt_u`, `free_u`
- `improve = single_err - opt_err`
- `gap = opt_err - free_err`
- `Mopt = min max |delta_(r,b)|` at fixed continuous tau

What to add or emphasize next:

- A fixed-budget sweep where the parameter count `1 + 2q` is held fixed while
  depth grows.
- Multi-`alpha` sweeps, not just `alpha = 1/2`.
- Output saved to CSV or JSON so the decay or persistence of `improve` can be
  plotted directly.

Suggested success signal:

- `opt_err < single_err` and `opt_u < single_u` across a stable range of depths
  for the same parameter budget.

Suggested falsification signal:

- Improvement appears only in small isolated cases, or tends to zero rapidly as
  depth grows.

Recommended output columns:

- `alpha`, `q`, `depth`, `n_params`, `single_err`, `opt_err`, `free_err`,
  `single_u`, `opt_u`, `free_u`, `improve`, `gap`, `Mopt`, `steps`, `time`

### H2. The policy-induced active-extrema family actually grows

Question:
does the induced active-pattern family become materially richer under FSM
policies, or does it collapse to a tiny bounded repertoire?

Current starting points:

- `fsm_coarse.sage`
- `lib/trajectory.py`

What this test should do:

- For each policy and each leaf, extract an active-pattern signature.
- Measure the number of distinct signatures and their multiplicities.
- Compute additive diagnostics on the induced family:
  `|A + A|`, pair-collision count, additive energy, Sidon size, and cover-free
  size.
- Sweep over `q`, depth, and selected `alpha` values.

What is still missing:

- A dedicated growth driver, likely something like
  `experiments/pattern_growth.sage`.
- Optional policy sweeps beyond the current named presets and the shared-delta
  optimizer.

Suggested success signal:

- `pat#`, dimension, or additive statistics show sustained growth with `q`,
  depth, or policy richness.

Suggested falsification signal:

- `pat#` saturates quickly and the induced families remain tiny even as the path
  family grows.

Recommended output columns:

- `alpha`, `policy`, `q`, `depth`, `paths`, `pat#`, `dim`, `c#`, `sum`,
  `coll`, `E`, `sidon_full`, `sidon_size`, `cover_free_size`

### H3. The relevant Jukna object is the induced pattern family, not the raw path family

Question:
which family tracks approximation quality: raw path-incidence vectors or
policy-induced active-pattern vectors?

Current driver:

- `fsm_coarse.sage` already computes the induced-family side.

What this test should do:

- For each case and policy, compute additive diagnostics twice:
  once on raw path vectors and once on induced active-pattern vectors.
- Compare both diagnostic sets against exact error improvement from the same
  policy.
- Report whether raw metrics are policy-invariant while induced metrics move.

What is still missing:

- A side-by-side comparison driver, likely
  `experiments/object_compare.sage`.
- A compact correlation summary between combinatorial metrics and
  approximation improvement.

Suggested success signal:

- Raw-path diagnostics stay essentially fixed under policy changes, while
  induced-pattern diagnostics move with policy and track `improve`.

Suggested falsification signal:

- Induced metrics are no more policy-sensitive than raw metrics, or neither
  family correlates with approximation quality.

Recommended output columns:

- `alpha`, `policy`, `q`, `depth`, `improve`, `raw_sum`, `raw_coll`, `raw_E`,
  `raw_sidon`, `raw_cf`, `ind_sum`, `ind_coll`, `ind_E`, `ind_sidon`, `ind_cf`

### H4. There is a real tropical-vs-arithmetic compression story

Question:
can a constrained policy class be evaluated or searched in polynomial-size
state space even when the leaf family grows exponentially?

Current ingredients:

- `paths.sage` for the layered residue automaton
- `day.sage` for exact local evaluation
- `optimize.sage` for shared-parameter policy search

What this test should do:

- Pick a sharply defined restricted policy class.
- Build a DP or shortest-path-style evaluator over compressed states.
- Compare the DP runtime and state count against full leaf enumeration.
- Check whether the DP reproduces the exact exhaustive metric on the same cases.

What is still missing:

- A dedicated compression driver, likely `experiments/dp_scaling.sage`.
- A clearly defined restricted policy family that is rich enough to be
  interesting but small enough to compress.

Suggested success signal:

- DP state count and runtime scale polynomially in depth while matching the
  exact leaf-enumeration answer on benchmark cases.

Suggested falsification signal:

- The DP state blows up with depth in the same way as leaf enumeration, or
  exact agreement requires effectively tracking leaves anyway.

Recommended output columns:

- `alpha`, `policy_class`, `q`, `depth`, `leaves`, `dp_states`, `dp_time`,
  `enum_time`, `matches_exact`, `worst_err`, `union_ratio`

## Suggested Next Drivers

If the repo grows by one driver per hypothesis, the clean layout is:

- `fsm_coarse.sage`: quick coupled measurement and validation.
- `optimize_delta.sage`: H1 baseline-vs-shared optimization sweep.
- `pattern_growth.sage`: H2 induced-family growth sweep.
- `object_compare.sage`: H3 raw-vs-induced comparison.
- `dp_scaling.sage`: H4 compression and runtime scaling experiment.

## Suggested Result Artifacts

To make repeated runs comparable, future experiment drivers should save their
tables in a machine-readable format. A simple convention is:

- `experiments/results/h1_shared_power.csv`
- `experiments/results/h2_pattern_growth.csv`
- `experiments/results/h3_object_compare.csv`
- `experiments/results/h4_dp_scaling.csv`

That keeps the human-readable scripts separate from the archived sweep outputs.
