# Harmonic diagnostic sweep — 2026-03-12

## Question

This sweep corrects the initial harmonic interpretation.
`harmonic_x` is reciprocal spacing and is still finer near x=1.
The actual opposite-end control is `mirror_harmonic_x`, which is
finer near x=2.

## Parameters

- alpha = 1/2
- grid: [(3, 4), (5, 4), (5, 6), (3, 8)]
- partitions: uniform_x, geometric_x, harmonic_x, mirror_harmonic_x
- modes: layer-invariant and layer-dependent

## Artifacts

- `summary.csv` — one row per case
- `percell.csv` — one row per cell per case

## Reuse

- `uniform_x` and `geometric_x` rows reused from l1c_grid_2026-03-12
  (marked source_run=l1c_grid_2026-03-12).
- prior `harmonic_x` rows reused from the first harmonic diagnostic
  (marked source_run=harmonic_diag_v1) when present.
- fresh rows in this rewrite are marked source_run=harmonic_diag_v2.
