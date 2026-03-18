Question:
Does the q=3 layer-dependent behavior indicate a real depth floor, and does the
current L1c advantage survive a small move away from alpha=1/2?

Artifact set:

- `summary.csv`
- `percell.csv`

Provenance:

- Reused from `l1c_grid_2026-03-12`:
  - alpha=1/2, q=3, d=4, both modes, both partition kinds
  - alpha=1/2, q=3, d=8, both modes, both partition kinds
- Reused from `lodestone_2026-03-11`:
  - alpha=1/2, q=3, d=6, both modes, both partition kinds
  - alpha=1/3, q=3, d=4, layer-invariant rows
- Newly run in this sweep:
  - alpha=1/2, q=3, d=5 and d=7, both modes, both partition kinds
  - alpha=1/3, q=3, d=4, layer-dependent rows
  - alpha=1/3, q=5, d=6, both modes, both partition kinds

Key results:

- At q=3 with alpha=1/2, geometric layer-dependent `opt_err` stays in a very
  narrow band across d=4..8:
  - d=4: 0.021838
  - d=5: 0.021864
  - d=6: 0.021915
  - d=7: 0.021844
  - d=8: 0.021838
- Uniform layer-dependent `opt_err` at q=3 is also narrow across d=4..8:
  - d=4: 0.024510
  - d=5: 0.024520
  - d=6: 0.024520
  - d=7: 0.024630
  - d=8: 0.024538
- This is stronger evidence for a q=3 layer-dependent floor, but still only an
  empirical regularity.
- The initial alpha=1/3 checks preserve L1c:
  - (q=3, d=4): geometric 0.012381 vs uniform 0.014569
  - (q=5, d=6): geometric 0.005819 vs uniform 0.007441

Rows:

- summary.csv: 28 rows
- percell.csv: 2304 rows

Driver:

- `experiments/lodestone/l1c_stability_sweep.sage`

Date:

- 2026-03-12
