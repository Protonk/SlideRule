# Refinement efficiency: active plan

## Goal

Reduce the wall-clock cost of `compute_signs` while preserving the canonical
`optimize_minimax` output for the authoritative configuration:

- `tol=1e-10`
- `dyadic_bits=20`
- identical snapped policy
- identical per-depth sign lists
- identical derived split digits

## Current priority

Attack the profiled hot path inside `lib/optimize.sage` rather than changing
solver semantics:

1. Verify the interval-builder assumptions on the actual arb path at `d=3`.
2. Add warm-start support for interval construction across bisection steps.
3. Reuse prior feasible interval boundaries when τ moves during bisection.
4. Keep a cold-path fallback so correctness does not depend on warm starts.

## Current status

- Warm-start interval reuse has been implemented in `lib/optimize.sage`.
- Regression tests for the `d=3` nesting gate and warm-vs-cold policy equality
  have been added to `tests/run_tests.sage`.
- Validation is blocked in Codex app because Sage execution is being killed
  before producing output; the next step is to run the Sage test suite and a
  small timing comparison from a working CLI environment.

## Expected work

1. Verify empirically at `d=3` that the cold-path feasible intervals are
   nested in `tau` and behave as a single interval around `c_star`.
2. Instrument interval construction enough to see whether warm starts reduce
   scalar boundary evaluations.
3. Extend `_build_feasible_intervals_arb` and `_bisect_feasible_interval` to
   accept optional prior boundary state.
4. Thread warm-start state through `optimize_minimax` without changing the
   surrounding solver contract.
5. Compare old vs new snapped policy and sign lists on small depths first.
6. Time one moderate depth before spending budget on slower cases.

## Iteration budget

- Exactness checks first on cheap depths, then one moderate depth.
- Treat the `d=3` monotonicity/nesting check as a gate before warm starts.
- Timing first at `d=7`, then `d=8` if the result is clean.
- Use `d=9` only as a confirmation point if `d=7/8` already show a real gain.
- Avoid depth-13 exploration until the implementation already looks credible.

## Pivot rules

- If policy equality fails, stop and fix semantics before more timing.
- If the `d=3` nesting check fails, do not proceed with warm-start logic.
- If exactness holds but speedup is weak, inspect counters before escalating.
- If interval work drops but total time does not, consider within-depth
  subprocess parallelism as a follow-on layer.
- Keep tolerance reduction and other semantics-risking ideas secondary.
