Question: Does the geometric advantage under layer-dependent sharing hold
broadly, or is (q=3, d=6) a local win?

Alpha: 1/2
Grid: (q=3, d=4), (q=5, d=4), (q=5, d=6), (q=3, d=8)
Partition kinds: uniform_x, geometric_x
Modes: layer-invariant and layer-dependent for each point

Layer-invariant reference rows were rerun (not reused from the first lodestone
sweep) for output self-containment. The layer-invariant numbers match the
first sweep to full precision.

Stage 1 — (q=3, d=4), (q=5, d=4), (q=5, d=6):
  Geometric beats uniform on layer-dependent opt_err at all three points.
  Passed sanity check; proceeded to Stage 2.

Stage 2 — (q=3, d=8):
  Geometric beats uniform on layer-dependent opt_err.

Result: L1c supported at all 4 tested grid points.

Driver: experiments/lodestone/l1c_grid_sweep.sage
Artifacts: summary.csv (16 rows), percell.csv (1408 rows)
Date: 2026-03-12
