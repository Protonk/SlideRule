# Ripple

Convergence and normalization experiments for coastline-area behavior across
partition families.

This folder studies how per-partition coastline area changes with depth after
normalization, with an emphasis on whether the approach to the apparent
asymptotic regime is smooth, ragged, or oscillatory.

## Files

- `coastline.sage` — shared coastline-area computation (closed-form
  antiderivative), scaling helpers, and measure registry
- `stability_heatmap.sage` — binary stability grid for all 23 partitions
- `settlers.sage` — sparklines for 8 partitions that converge to a finite
  constant, ordered by convergence speed
- `divergent.sage` — sparklines for 7 partitions that diverge or never
  settle, showing exponential growth, irregular growth, and persistent
  oscillation
- `CLOSED-FORM-PLAN.md` — derivation of the closed-form cell integral
  (implemented)

Generated outputs live in `results/`.

## Running

From repo root:

```sh
./sagew experiments/ripple/stability_heatmap.sage
./sagew experiments/ripple/settlers.sage
./sagew experiments/ripple/divergent.sage
```
