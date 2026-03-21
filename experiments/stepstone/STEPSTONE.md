# Stepstone

## The idea

The chord approximation to log2 on a cell [a, b] has an error structure
determined entirely by the cell's position and width. Stepstone studies this
structure: what the error looks like, why geometric partitions equalize it,
and what happens visually when you vary the partition geometry.

### Tilt decomposition

Every per-cell chord error is the global chord error minus an affine
correction:

    E_{[a,b]}(m) = eps(m) - delta(m)

where `eps(m) = log_2(m) - (m - 1)` is the global error and
`delta(m) = chord_{[a,b]}(m) - (m - 1)` is the tilt. The tilt is affine
in m with slope `(sigma - 1)`, where sigma is the per-cell chord slope.

The second derivative is preserved: `E'' = eps'' = -1/(m^2 ln 2)`. Only
the first derivative changes. This is Stage 3 of the chord error argument
(`plog_chord_argument.sage`).

### The tilt as piecewise-linear interpolant

When we tile [1, 2] with N cells and draw delta(m) on each cell, the result
is continuous across cell boundaries -- both sides equal eps at each boundary
point. The collection of tilt segments is the piecewise-linear interpolant
of eps at the partition points. The gap between eps and this interpolant is
E, the per-cell error.

### Convergence

The peak ratio for uniform partitions does not vanish with N. In the
small-cell limit:

    E_peak(a) ~ 1 / (8 N^2 a^2 ln 2)        (uniform, cell at position a)
    E_peak    ~ ln(2) / (8 N^2)               (geometric, all cells)

The ratio `E_uniform(a) / E_geometric = 1/(a^2 ln^2 2)`, independent of N.
At a=1 the uniform peak is ~2.08x the geometric peak; at a=2 it is ~0.52x.
They cross at `a = 1/ln 2` -- the same m* again.

---

## Scripts

### Top-level: the theoretical argument

| Script | Description |
|--------|-------------|
| `plog_chord_argument.sage` | Three-stage symbolic argument: error shape, curvature front-loading, tilt decomposition |
| `chord_slope_crossing.sage` | Per-cell chord slope as a step function; shows the m* crossover |
| `many_steps_miss.sage` | Overlays step functions at N = 8, 16, 32, 64; all miss the exact m* crossing |

Run with `./sagew experiments/stepstone/<script>`.

### `profiles/` -- per-partition error visualizations

Each script renders a zoo grid showing a different view of per-cell chord
error across partition kinds.

| Script | Output | Description |
|--------|--------|-------------|
| `cartesean_envelope.sage` | `results/cartesean_envelope.png` | Per-cell error sawtooths with peak envelopes, independent y-scales |
| `curvature_mismatch.sage` | `results/curvature_mismatch.png` | Cell width vs locally optimal width: over-resolved vs under-resolved |
| `polar_heatmap.sage` | `results/polar_heatmap.png` | Error heatmaps in polar coordinates; geometric gives uniform rings |
| `radar_peaks.sage` | `results/radar_peaks.png` | Radar plot of peak errors; geometric is a circle, others are starbursts |

Run with `./sagew experiments/stepstone/profiles/<script>`.

### `fractal/` -- crossing-count fractal art

Scans vertically through slope-deviation step functions at many depth layers.
At each pixel (x, y), counts how many curves cross that height. The resulting
count array, rendered with modular colormaps, produces fractal images.

| Script | Description |
|--------|-------------|
| `raster.sage` | Pure raster engine: returns raw uint16 count arrays, no rendering |
| `multiplexer.sage` | Shared colormap and panel rendering helpers |
| `single_fractal.sage` | Render one partition kind to one image |
| `grid_fractals.sage` | Render a preset grid or the full zoo |

Run with `./sagew experiments/stepstone/fractal/<script>`.

---

## Data flow

```
lib/partitions.sage (cell boundaries)
  |
  |-- plog_chord_argument.sage     (standalone, symbolic)
  |-- chord_slope_crossing.sage    (standalone)
  |-- many_steps_miss.sage         (standalone)
  |
  +-- zoo_figure.sage (shared grid layout)
  |    |-- profiles/cartesean_envelope.sage  --> profiles/results/
  |    |-- profiles/curvature_mismatch.sage  --> profiles/results/
  |    |-- profiles/polar_heatmap.sage       --> profiles/results/
  |    +-- profiles/radar_peaks.sage         --> profiles/results/
  |
  +-- fractal/raster.sage (count engine)
       +-- fractal/multiplexer.sage (rendering)
            |-- fractal/single_fractal.sage  --> fractal/results/
            +-- fractal/grid_fractals.sage   --> fractal/results/
```

---

## Key findings

### Geometric equalizes peak error

On geometric partitions, every cell has the same peak chord error:
`ln(2) / (8 N^2)`. This is visible in the radar plot as a perfect circle
and in the cartesian envelope as a flat peak line. No other partition kind
achieves this.

### Curvature is front-loaded

Exactly 2/3 of the total curvature integral of `eps''(m) = -1/(m^2 ln 2)`
lives in the left half [1, 3/2]. This is why uniform partitions waste
resolution on the right side (curvature-poor) and under-resolve the left
(curvature-rich). The curvature mismatch plot makes this directly visible.

### The m* crossing is universal

The crossover at `m* = 1/ln 2 ~ 1.4427` appears in every visualization:
it's where chord slope equals the global slope, where uniform and geometric
peak errors cross, and where the tilt changes sign. The step functions at
every resolution miss this crossing -- they bracket it but never land on it.
