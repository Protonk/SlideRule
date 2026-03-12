# PLAN

Activity:
Harmonize repo terminology and current-state docs after the first lodestone
partition-comparison run.

Question:
How should the repo describe the post-lodestone state consistently?

Design:
- Use `uniform_x` and `geometric_x` as the canonical geometry names.
- Reserve `bits` / `binary_prefix` for cell addressing, not geometry.
- Update the top-level guides, experiment/library guides, and research docs to
  agree that `experiments/lodestone_sweep.sage` exists and that the first
  2026-03-11 comparison run has landed.
- Keep `dyadic` only for historical shorthand, binary-prefix structure, or
  dyadic parameter snapping, not as a current geometry label.
