# Historical sweep reports

Runs whose artifacts exist only in git history. The box-score tables are
preserved here so that the K1c and harmonic-control evidence remains
accessible without checking out old commits.

---

## 2026-03-12 — K1c grid sweep

Driver: `l1c_grid_sweep.sage` (removed; regenerable via `partition_sweep.sage`)
Artifacts: `results/l1c_grid_2026-03-12/` (historical, see git)
Purpose: check whether the geometric advantage under layer-dependent sharing
holds beyond the single (q=3, d=6) benchmark.

### Stage 1 — (q=3, d=4), (q=5, d=4), (q=5, d=6), exponent_t=1/2

| kind | q | d | mode | opt_err | free_err | gap | gap reduction |
|------|---|---|------|---------|----------|-----|---------------|
| uniform_x | 3 | 4 | layer-inv | 0.031873 | 0.010423 | 0.021450 | — |
| geometric_x | 3 | 4 | layer-inv | 0.033031 | 0.007554 | 0.025477 | — |
| uniform_x | 3 | 4 | layer-dep | 0.024510 | 0.010423 | 0.014088 | 34.3% |
| geometric_x | 3 | 4 | layer-dep | 0.021838 | 0.007554 | 0.014284 | 43.9% |
| uniform_x | 5 | 4 | layer-inv | 0.022005 | 0.010423 | 0.011582 | — |
| geometric_x | 5 | 4 | layer-inv | 0.023075 | 0.007554 | 0.015521 | — |
| uniform_x | 5 | 4 | layer-dep | 0.012065 | 0.010423 | 0.001642 | 85.8% |
| geometric_x | 5 | 4 | layer-dep | 0.010251 | 0.007554 | 0.002697 | 82.6% |
| uniform_x | 5 | 6 | layer-inv | 0.034749 | 0.002763 | 0.031986 | — |
| geometric_x | 5 | 6 | layer-inv | 0.037989 | 0.001937 | 0.036051 | — |
| uniform_x | 5 | 6 | layer-dep | 0.012127 | 0.002763 | 0.009364 | 70.7% |
| geometric_x | 5 | 6 | layer-dep | 0.010127 | 0.001937 | 0.008190 | 77.3% |

Direct observations:

- Geometric layer-dependent `opt_err` < uniform layer-dependent `opt_err` at
  all three Stage 1 points.
- Gap reduction from layer dependence is larger on geometric at two of the
  three Stage 1 points, but not at (q=5, d=4).
- At (q=5, d=4), the layer-dependent gap nearly closes on both partition kinds.

### Stage 2 — (q=3, d=8), exponent_t=1/2

| kind | q | d | mode | opt_err | free_err | gap | gap reduction |
|------|---|---|------|---------|----------|-----|---------------|
| uniform_x | 3 | 8 | layer-inv | 0.044895 | 0.000701 | 0.044194 | — |
| geometric_x | 3 | 8 | layer-inv | 0.046349 | 0.000487 | 0.045862 | — |
| uniform_x | 3 | 8 | layer-dep | 0.024538 | 0.000701 | 0.023837 | 46.1% |
| geometric_x | 3 | 8 | layer-dep | 0.021838 | 0.000487 | 0.021351 | 53.5% |

Direct observations:

- K1c continues to hold at d=8.
- The geometric layer-dependent `opt_err` at (q=3, d=8) matches (q=3, d=4) to
  full precision and is close to, but not identical with, the earlier
  (q=3, d=6) result. This suggests a q=3 floor but does not establish one.
- Uniform layer-dependent `opt_err` is also nearly stable across d=4, 6, 8 at
  q=3 (~0.0245).

---

## 2026-03-12 — K1c stability sweep

Driver: `l1c_stability_sweep.sage` (removed; regenerable via
`partition_sweep.sage`)
Artifacts: `results/l1c_stability_2026-03-12/` (historical, see git)
Purpose: fill in q=3 intermediate depths and add initial exponent_t=1/3
robustness checks.

### Stage 1 — q=3 depth fill at exponent_t=1/2

| d | uniform_x LD opt_err | geometric_x LD opt_err |
|---|----------------------|------------------------|
| 4 | 0.024510 | 0.021838 |
| 5 | 0.024520 | 0.021864 |
| 6 | 0.024520 | 0.021915 |
| 7 | 0.024630 | 0.021844 |
| 8 | 0.024538 | 0.021838 |

Direct observations:

- Geometric remains better than uniform at every tested q=3 depth.
- The q=3 layer-dependent bands are narrow across d=4..8 on both partition
  kinds.
- Geometric varies by about 7.7e-5 across the full band; uniform varies by
  about 1.2e-4.
- This is stronger evidence for a q=3 layer-dependent floor, though still only
  empirical evidence.

### Stage 2 — exponent_t=1/3 robustness

| q | d | uniform_x LD opt_err | geometric_x LD opt_err |
|---|---|----------------------|------------------------|
| 3 | 4 | 0.014569 | 0.012381 |
| 5 | 6 | 0.007441 | 0.005819 |

Direct observations:

- K1c survives both tested exponent_t=1/3 points.
- At both points, geometric also gets the larger gap reduction from introducing
  layer dependence.

---

## 2026-03-12 — Harmonic diagnostic sweep

Driver: `harmonic_diagnostic_sweep.sage` (removed; regenerable via
`partition_sweep.sage`)
Artifacts: `results/harmonic_diagnostic_2026-03-12/` (historical, see git)
Purpose: corrected redistribution-control test separating three possibilities:
the log-like geometry is unique; any x=1-heavy redistribution helps under
layer dependence; any redistribution at all helps under layer dependence.

Note: the initial harmonic interpretation was backwards. `harmonic_x` is
reciprocal spacing and is still finer near `x=1`. The actual opposite-end
control is `mirror_harmonic_x`, which is finer near `x=2`.

### Layer-invariant results, exponent_t=1/2

| kind | q | d | opt_err | free_err | gap |
|------|---|---|---------|----------|-----|
| uniform_x | 3 | 4 | 0.031873 | 0.010423 | 0.021450 |
| geometric_x | 3 | 4 | 0.033031 | 0.007554 | 0.025477 |
| harmonic_x | 3 | 4 | 0.033496 | 0.007685 | 0.025811 |
| mirror_harmonic_x | 3 | 4 | 0.033495 | 0.018303 | 0.015192 |
| uniform_x | 5 | 4 | 0.022005 | 0.010423 | 0.011582 |
| geometric_x | 5 | 4 | 0.023075 | 0.007554 | 0.015521 |
| harmonic_x | 5 | 4 | 0.022495 | 0.007685 | 0.014810 |
| mirror_harmonic_x | 5 | 4 | 0.022183 | 0.018303 | 0.003881 |
| uniform_x | 5 | 6 | 0.034749 | 0.002763 | 0.031986 |
| geometric_x | 5 | 6 | 0.037989 | 0.001937 | 0.036051 |
| harmonic_x | 5 | 6 | 0.038901 | 0.002225 | 0.036676 |
| mirror_harmonic_x | 5 | 6 | 0.027559 | 0.005339 | 0.022219 |
| uniform_x | 3 | 8 | 0.044895 | 0.000701 | 0.044194 |
| geometric_x | 3 | 8 | 0.046349 | 0.000487 | 0.045862 |
| harmonic_x | 3 | 8 | 0.047126 | 0.000577 | 0.046550 |
| mirror_harmonic_x | 3 | 8 | 0.043617 | 0.001390 | 0.042227 |

Direct observations:

- `mirror_harmonic_x` is already competitive at `(q=5, d=4)` and is best at
  the tested deeper points `(q=5, d=6)` and `(q=3, d=8)`.
- Under LI sharing, the x=2-heavy partition can outperform both x=1-heavy
  partitions and uniform at deeper points.

### Layer-dependent results, exponent_t=1/2

| kind | q | d | opt_err | free_err | gap |
|------|---|---|---------|----------|-----|
| uniform_x | 3 | 4 | 0.024510 | 0.010423 | 0.014088 |
| geometric_x | 3 | 4 | 0.021838 | 0.007554 | 0.014284 |
| harmonic_x | 3 | 4 | 0.019220 | 0.007685 | 0.011535 |
| mirror_harmonic_x | 3 | 4 | 0.028325 | 0.018303 | 0.010022 |
| uniform_x | 5 | 4 | 0.012065 | 0.010423 | 0.001642 |
| geometric_x | 5 | 4 | 0.010251 | 0.007554 | 0.002697 |
| harmonic_x | 5 | 4 | 0.010910 | 0.007685 | 0.003225 |
| mirror_harmonic_x | 5 | 4 | 0.018968 | 0.018303 | 0.000665 |
| uniform_x | 5 | 6 | 0.012127 | 0.002763 | 0.009364 |
| geometric_x | 5 | 6 | 0.010127 | 0.001937 | 0.008190 |
| harmonic_x | 5 | 6 | 0.011029 | 0.002225 | 0.008803 |
| mirror_harmonic_x | 5 | 6 | 0.019016 | 0.005339 | 0.013676 |
| uniform_x | 3 | 8 | 0.024538 | 0.000701 | 0.023837 |
| geometric_x | 3 | 8 | 0.021838 | 0.000487 | 0.021351 |
| harmonic_x | 3 | 8 | 0.019220 | 0.000577 | 0.018643 |
| mirror_harmonic_x | 3 | 8 | 0.028325 | 0.001390 | 0.026935 |

### Rankings under layer dependence

| q | d | 1st (best) | 2nd | 3rd | 4th (worst) |
|---|---|------------|-----|-----|-------------|
| 3 | 4 | harmonic_x (0.01922) | geometric_x (0.02184) | uniform_x (0.02451) | mirror_harmonic_x (0.02833) |
| 5 | 4 | geometric_x (0.01025) | harmonic_x (0.01091) | uniform_x (0.01207) | mirror_harmonic_x (0.01897) |
| 5 | 6 | geometric_x (0.01013) | harmonic_x (0.01103) | uniform_x (0.01213) | mirror_harmonic_x (0.01902) |
| 3 | 8 | harmonic_x (0.01922) | geometric_x (0.02184) | uniform_x (0.02454) | mirror_harmonic_x (0.02833) |

Direct observations:

- `harmonic_x` and `geometric_x` both beat `uniform_x` at all tested
  layer-dependent points.
- The actual opposite-end control `mirror_harmonic_x` loses to `uniform_x` at
  all tested layer-dependent points. The broad claim "any redistribution helps
  under LD sharing" is false. Direction matters.
- Within the x=1-heavy family, the ranking is q-dependent: harmonic wins at
  q=3, geometric wins at q=5.
- Harmonic `opt_err` at q=3 is identical at d=4 and d=8 (0.019220),
  mirroring the q=3 floor pattern seen in the stability sweep for geometric.
