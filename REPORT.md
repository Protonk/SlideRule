# Report

This file is a handoff note. It should capture context, momentum, and the
things a next agent should know before deciding what to do. It is not the
canonical home for claims, sweep tables, or module reference material.

## Current position

The partition-support milestone is complete enough to be useful.

- There is now a partition layer with `uniform_x` and `geometric_x`.
- There is an arbitrary-cell evaluator, validated against the exact
  `uniform_x` oracle path.
- The optimizer is partition-aware.
- `experiments/lodestone_sweep.sage` exists and has already produced the first
  direct partition-comparison artifacts.

The project is no longer in the "build the comparison machinery" phase. It is
in the "learn what the comparison is actually saying" phase.

## What seems to matter

The important empirical split is not "geometric wins" versus "uniform wins" in
one piece. It is:

- geometric clearly wins at the free-per-cell level
- geometric does not generally win under layer-invariant shared deltas
- geometric does win at least once under layer-dependent sharing

That is the current live tension. The interesting question is not whether the
lodestone thesis was simply right or wrong. It is where the cell-level
geometric advantage gets canceled by the sharing penalty, and when loosening
the parameterization lets that advantage reappear.

If a future agent collapses this back into a single slogan, they are probably
throwing away the main result.

## Current working interpretation

Right now the repo is pointing at a two-part story:

1. `geometric_x` is better matched to the local approximation problem.
2. The current FSM sharing scheme is itself structured in a way that can favor
   the `uniform_x` baseline unless layer sharing is loosened.

That is why `free_err` and `opt_err` are telling different stories.

The wall story should also be treated carefully. The current evidence supports
"layer sharing is a major source of the wall at the tested deep points," but it
does not yet support a clean universal decomposition law across the comparison
grid.

## Important conventions

Do not backslide on terminology.

- `uniform_x` and `geometric_x` are the geometry names.
- `bits`, `binary_prefix`, `index`, and `depth` are addressing / hierarchy
  terms, not geometry names.
- `dyadic` should be reserved for historical remarks, binary structure, or
  dyadic parameter snapping.

Do not backslide on evaluator discipline either.

- The exact `uniform_x` path is a regression oracle.
- The actual lodestone comparisons should use the arbitrary-cell evaluator for
  both partition kinds.
- If a future change compares exact `uniform_x` against arbitrary `geometric_x`
  directly, that reintroduces an evaluator confound.

## What a next useful step looks like

The best next work is still empirical, not architectural.

- Extend the layer-dependent comparison beyond the single `(q, d) = (3, 6)`
  benchmark.
- Add a few more small non-`1/2` `alpha` checkpoints.
- Read the per-cell artifacts, not just the summary rows:
  where does the worst cell move, and how does concentration change?

The likely next breakpoint is this:

- If `L1c` keeps holding on a broader grid, the project should pivot toward
  understanding why layer sharing suppresses the geometric advantage in the
  invariant model.
- If `L1c` fails away from the current benchmark, the project should treat the
  existing win as local and start looking for the actual regime boundary.

Either way, the next step is more lodestone data, not a repo-wide refactor.

## Baseline drivers

`optimize_delta.sage` and `h1_sweep.sage` should still be treated as baseline
drivers, not the main comparison surface.

They are useful for:

- legacy `uniform_x` wall characterization
- sanity checks
- historical comparison points

They are not where the repo's main scientific motion is now.

## Practical notes

- The per-cell artifact contract matters. Keep both `worst_candidate_x` and
  `worst_candidate_plog`.
- The summary artifact is not enough by itself for the lodestone claims.
- The worktree was cleaned after the doc harmonization and source-file shuffle.
- Temporary plan files were intentionally dissolved. If a new multi-step task
  starts, create a fresh `PLAN.md` for that task rather than trying to recover
  the old one.
