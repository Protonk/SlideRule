# Report

This file is now a current-cycle handoff, not the canonical home for research
claims or sweep conclusions.

## This cycle

- Elevated [`LODESTONE.md`](LODESTONE.md) to the primary scientific entry
  point.
- Reframed:
  - [`README.md`](README.md)
  - [`HYPOTHESES.md`](HYPOTHESES.md)
  - [`WALL.md`](WALL.md)
  - [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md)
  - [`experiments/README.md`](experiments/README.md)
  so the scale-equivariance thesis is primary and the wall/H1 material is
  supporting baseline machinery.
- Left experiment driver names and code layout unchanged pending the actual
  implementation of partition-comparison experiments.

## Where things live now

- Guiding thesis:
  [`LODESTONE.md`](LODESTONE.md)
- Current research claims/status:
  [`HYPOTHESES.md`](HYPOTHESES.md)
- Current dyadic obstruction model:
  [`WALL.md`](WALL.md)
- Dated sweep evidence and artifact links:
  [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md)
- Script usage and experiment scope:
  [`experiments/README.md`](experiments/README.md)
- Implementation/module structure:
  [`lib/README.md`](lib/README.md)

## Most recent substantive run

The latest substantive numeric cycle is still the dyadic H1 sweep recorded in:

- [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md)
- [`experiments/results/h1b_depth_scaling.csv`](experiments/results/h1b_depth_scaling.csv)
- [`experiments/results/h1a_gap_vs_q.csv`](experiments/results/h1a_gap_vs_q.csv)
- [`experiments/results/h1c_layer_dependent.csv`](experiments/results/h1c_layer_dependent.csv)

These runs are now framed as preparatory baseline evidence for the lodestone
program. No direct partition-comparison run exists yet.

## Likely next work

- add a partition generator that can switch between dyadic/geometric and
  uniform-in-`x` grids
- build a lodestone comparison driver or extend `h1_sweep.sage` to run `L1`-`L3`
- reuse the existing H1 benchmark points as the first `L3` comparison cases
- run multi-`alpha` checks once the first partition comparison exists
