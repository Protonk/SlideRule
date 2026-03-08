# Launchpad Plan

Status legend: `todo`, `in_progress`, `done`

## Goal

Refactor the repo so the main experiments test the coupled object:
policy-induced Day extrema and their additive/combinatorial structure.

## Work Items

1. `done` Create the planning file and keep it updated while work proceeds.
2. `done` Add stronger Day baselines and objectives.
   - Implement a true best single-intercept baseline `best_single_c` with `delta = 0`.
   - Implement the true union-level global ratio across all leaves.
   - Thread both metrics through the coarse experiment and optimizer experiment.
3. `done` Couple the Day and Jukna sides.
   - Extract exact active-pattern signatures from the Day evaluator.
   - Encode induced vectors from those signatures.
   - Run additive diagnostics on the induced family, not just raw path vectors.
4. `done` Replace greedy-only small-instance combinatorics with certifying routines.
   - Add exact maximum Sidon search for small families.
   - Add exact maximum cover-free search for small families.
   - Keep greedy routines for larger cases, but label them clearly as heuristics.
5. `done` Add real project tests.
   - Cover residue-path construction.
   - Cover exact evaluator metrics and baselines.
   - Cover induced Day-pattern vectors.
   - Cover exact-vs-greedy combinatorial routines on small instances.
6. `done` Update docs and experiment output so the new objects and metrics are explicit.
