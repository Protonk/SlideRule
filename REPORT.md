# Report

This file is a handoff note. It should capture context, momentum, and the
things a next agent should know before deciding what to do. It is not the
canonical home for claims, sweep tables, or module reference material.

## Current position

The partition-support milestone is complete enough to be useful.

- There is now a partition layer with `uniform_x`, `geometric_x`,
  `harmonic_x`, and `mirror_harmonic_x`.
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
- under layer-dependent sharing, the tested x=1-heavy redistributions
  (`geometric_x`, `harmonic_x`) beat `uniform_x`
- the actual opposite-end control `mirror_harmonic_x` loses to `uniform_x`
  at every tested layer-dependent point
- under layer-invariant sharing, `mirror_harmonic_x` becomes competitive and is
  best at the tested deeper points

That is the current live tension. The interesting question is not whether the
lodestone thesis was simply right or wrong. It is where the cell-level
geometric advantage gets canceled by the sharing penalty, why layer-dependent
sharing prefers x=1-heavy redistributions, and why layer-invariant sharing can
flip toward the opposite end of the interval at depth.

If a future agent collapses this back into a single slogan, they are probably
throwing away the main result.

## Current working interpretation

Right now the repo is pointing at a three-part story:

1. `geometric_x` is better matched to the local approximation problem.
2. Under layer-dependent sharing, the beneficial redistributions tested so far
   are the ones that put more resolution near `x=1`; the x=2-heavy control
   fails.
3. Under layer-invariant sharing, the optimizer can instead favor the x=2-heavy
   control at deeper points.

That is why `free_err` and `opt_err` are telling different stories.

The wall story should also be treated carefully. The current evidence supports
"layer sharing is a major source of the wall at the tested deep points," but it
does not yet support a clean universal decomposition law across the comparison
grid.

The two newest wrinkles are:

- q=3 still shows a very narrow layer-dependent opt_err band across d=4..8
- the mirrored reciprocal control flips the old “any redistribution helps”
  interpretation from a live concern into a clear negative result under LD

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

## Active plan: domain parameterization

There is an active `PLAN.md` for parameterizing the input domain. The domain is
currently hardcoded as `[1, 2)` throughout the partition layer, evaluator, and
optimizer. The plan adds `x_start` and `x_width` keyword arguments (defaulting
to 1 and 1) so the domain becomes `[x_start, x_start + x_width)`.

This is infrastructure work, not a new experiment. It touches `partitions.sage`,
`day.sage`, `policies.sage`, and `optimize.sage`. The trickiest part is
re-deriving the D-candidate formula in the evaluator for general `x_start`. See
`PLAN.md` for the full file-by-file breakdown.

All existing call sites use the defaults and should not change.

## What a next useful step looks like

On the empirical side, the best next work is:

- Push on the q=3 band until it either breaks or starts to look structural.
- Add a few more small non-`1/2` `alpha` checkpoints, including the mirrored
  control.
- Read the per-cell artifacts, not just the summary rows:
  where does the worst cell move, and how does concentration change?
- Compare why LI and LD prefer opposite ends of the interval on the new control
  sweep.

The likely next breakpoint is this:

- If the q=3 band keeps holding, the project should pivot toward explaining the
  floor rather than just reporting it.
- If the alpha robustness starts to fail, the project should treat the current
  positive picture as regime-dependent rather than global.

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
- The new `l1c_stability` artifact set mixes reused and newly generated rows on
  purpose; use the `source_run` column instead of assuming every row was
  generated in one execution.
- The worktree was cleaned after the doc harmonization and source-file shuffle.
- Temporary plan files were intentionally dissolved. If a new multi-step task
  starts, create a fresh `PLAN.md` for that task rather than trying to recover
  the old one.
