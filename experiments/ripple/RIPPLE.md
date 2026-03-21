# Ripple

## The idea

Each partition kind produces a step-function approximation to the continuous
slope `1/(m ln 2)` on `[1, 2)`. The **coastline area** is the integral of the
absolute deviation between the continuous slope and the step function:

```
A(depth, kind) = integral_1^2 |1/(m ln 2) - sigma_j(m)| dm
```

where `sigma_j` is the chord slope on the cell containing `m`.

As depth increases (more cells), most partitions drive `A` toward zero. But
the *rate* of convergence, the *shape* of the approach (monotone, oscillatory,
overshooting), and whether the area converges at all vary dramatically across
partition families. Ripple studies this behavior.

### Normalization

Raw area `A` shrinks as `O(1/N)` for well-behaved partitions. The **scaled
area** `N * A` removes this trivial decay, leaving a quantity that converges
to a finite constant for partitions with smooth convergence and diverges for
partitions with structural problems.

The **geometric-relative** normalization divides each partition's scaled area
by geometric's scaled area at the same depth. This shows how each partition
compares to the thesis winner at every depth.

### Closed-form computation

The per-cell coastline integral uses a closed-form antiderivative (no
quadrature). The antiderivative of `1/(m ln 2) - sigma_j` is
`F(m) = log2(m) - sigma_j * m`. The integrand changes sign at most once per
cell, at `m_cross = 1/(sigma_j * ln 2)`. The implementation splits at this
crossing point when it falls within the cell. This is exact to floating-point
precision and runs in microseconds per cell.

---

## Scripts

All scripts load `experiments/coastline_series.sage` as a shared helper.

| Script | Output | Description |
|--------|--------|-------------|
| `stability_heatmap.sage` | `results/stability_heatmap.png` | Binary stability grid: red = stable (<5% change from previous depth), black = shifted. Rows sorted by instability. Extended to depth 12 (N=4096). |
| `settlers.sage` | `results/settlers.png` | Sparklines for 8 partitions that converge to a finite scaled-area constant, ordered by convergence speed |
| `divergent.sage` | `results/divergent.png` | Sparklines for 7 partitions that diverge or never settle: exponential growth, irregular growth, persistent oscillation |
| `area_comparison.sage` | `results/area_comparison.png` | Raw area comparison: geometric vs golden, showing golden's three-distance wobble |
| `integrate_coastline.sage` | `results/integrate_coastline.png` | Bar chart of raw area vs depth for uniform partitions |

Run any of them with `./sagew experiments/ripple/<script>`.

### Shared helper

`experiments/coastline_series.sage` (one level up, shared with stepstone)
provides:

- `_cell_coastline_area(a, b)` -- closed-form per-cell integral
- `coastline_area(depth, kind)` -- total area for one (depth, kind) case
- `coastline_series(kinds, depths)` -- raw area across a depth range
- `scaled_series(raw, depths)` -- multiply by N to remove trivial decay
- `geometric_relative_series(series)` -- normalize against geometric

---

## Data flow

```
lib/partitions.sage (cell boundaries)
  +-- coastline_series.sage (closed-form integrals + normalization)
       |-- stability_heatmap.sage  --> results/stability_heatmap.png
       |-- settlers.sage           --> results/settlers.png
       |-- divergent.sage          --> results/divergent.png
       |-- area_comparison.sage    --> results/area_comparison.png
       +-- integrate_coastline.sage--> results/integrate_coastline.png
```

No caching -- all computations are fast (closed-form integrals, no optimizer).

---

## Key findings

### Convergence classes

The partition kinds split into two groups based on scaled-area behavior:

**Settlers** (converge to a finite constant):
geometric, arc-length, uniform, harmonic, mirror-harmonic, minimax-chord,
chebyshev, sinusoidal, thue-morse, ruler, reverse-geometric, dyadic,
power-law, radical-inverse, sturmian, bitrev-geometric.

Convergence speed varies widely: geometric and arc-length are flat by depth 3;
bitrev-geometric is still visibly moving at depth 12.

**Divergent / restless:**
beta, stern-brocot, cantor (exponential growth), farey-rank (irregular
growth), golden (persistent oscillation with +/-0.04 wobble that never damps),
random (stochastic baseline).

### Golden oscillation

The golden partition's scaled area oscillates at every depth due to the
three-distance property of Kronecker sequences. The wobble is real, not
numerical -- it reflects the fact that golden-ratio breakpoints never align
smoothly with the curvature structure of log2.

### Geometric as normalization baseline

Geometric's scaled area converges monotonically and rapidly, making it a
natural denominator for relative comparisons. The stability heatmap uses
geometric-relative normalization: a partition that tracks geometric closely
appears as a solid red row (stable), while one that diverges appears
increasingly black.
