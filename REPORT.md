# Report

This file is now a current-cycle handoff, not the canonical home for research
claims or sweep conclusions.

## This cycle

- The partition-support milestone landed:
  - `lib/partitions.sage`
  - arbitrary-cell evaluation in `lib/day.sage`
  - partition-aware optimizer threading in `lib/optimize.sage`
  - `experiments/lodestone_sweep.sage`
- The first lodestone partition-comparison run (2026-03-11) now exists and is
  recorded in the results artifacts.
- Repo docs were synchronized around the new post-lodestone state, with
  `uniform_x` / `geometric_x` as the canonical geometry names.

## Where things live now

- Guiding thesis:
  [`LODESTONE.md`](LODESTONE.md)
- Current research claims/status:
  [`HYPOTHESES.md`](HYPOTHESES.md)
- Current obstruction model and wall diagnostics:
  [`WALL.md`](WALL.md)
- Dated sweep evidence and artifact links:
  [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md)
- Script usage and experiment scope:
  [`experiments/README.md`](experiments/README.md)
- Implementation/module structure:
  [`lib/README.md`](lib/README.md)

## Most recent substantive runs

The current primary lodestone evidence is the 2026-03-11 partition-comparison
sweep:

- [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md)
- [`experiments/results/lodestone_summary.csv`](experiments/results/lodestone_summary.csv)
- [`experiments/results/lodestone_percell.csv`](experiments/results/lodestone_percell.csv)

The older H1 baseline runs remain useful support and context:

- [`experiments/results/h1b_depth_scaling.csv`](experiments/results/h1b_depth_scaling.csv)
- [`experiments/results/h1a_gap_vs_q.csv`](experiments/results/h1a_gap_vs_q.csv)
- [`experiments/results/h1c_layer_dependent.csv`](experiments/results/h1c_layer_dependent.csv)

## Likely next work

- extend the layer-dependent comparison beyond `(q, d) = (3, 6)`
- add more secondary `alpha` checkpoints
- inspect per-cell concentration and worst-cell movement across partition kinds
- decide whether any baseline-only docs or drivers still need a historical note
  clarifying their `uniform_x` geometry
