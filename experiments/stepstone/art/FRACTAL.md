# Fractal Crossing Art — Migration from `hazards/crossings.sage`

## Origin

`hazards/crossings.sage` builds a single full-bleed fractal image by:

1. Scanning vertically through slope-deviation step functions at many depth
   layers plus the continuous limit.
2. At each pixel (x, y), counting how many curves lie above y.
3. Filling black/white by parity of that count.

The result is a binary fractal — visually striking, mathematically meaningful
(each black/white band boundary is a step-function or the smooth 1/(m ln 2)
curve).

The current script bundles three concerns into one file:
- **Raster math** — vectorized NumPy logic that builds the uint8 image.
- **Configuration** — KIND, DEPTHS, resolution, clipping mode.
- **Rendering** — matplotlib figure, colormap, output path, panel layout.

## What moves into `art/`

### `raster.sage` — the raster engine

Pure computation.  No matplotlib, no output paths, no configuration globals.

Exports:

| Function | Signature | Returns |
|----------|-----------|---------|
| `build_raster` | `(kind, depths, x_res, y_res, x_chunk=500)` | `np.ndarray` (uint16, shape y_res x x_res) — raw crossing counts |
| `build_raster_clipped` | `(kind, depths, x_res, y_res, x_chunk=500)` | `np.ndarray` (uint16, shape y_res x x_res) — raw crossing counts |

Internal helpers (not exported but available):

| Function | Purpose |
|----------|---------|
| `cell_chord_slope(a, b)` | chord slope of log on [a, b] |
| `step_values_vec(depth, kind, xs)` | vectorized step-function values |
| `continuous_slope_vec(xs)` | 1/(x ln 2) - 1 evaluated at xs |

Key change from `crossings.sage`: all configuration passed as arguments,
nothing read from globals.  `raster.sage` is a loadable library, not a
runnable script.

### `multiplexer.sage` — configuration, layout, rendering

The driver.  Imports `raster.sage`, decides _what_ to render and _how_ to
arrange it.

Responsibilities:

1. **Single-panel mode** — reproduce what `crossings.sage` does today:
   one KIND, one DEPTHS range, full-bleed image.  Default output:
   `art/crossings.png`.

2. **Zoo mode** — 4x4 grid, one panel per PARTITION_ZOO entry, same params.
   Output: `art/zoo.png`.

3. **Param-sweep mode** — 4x4 grid, single KIND, varying (DEPTHS,
   SPIRAL_TURNS, R_INNER) or any parameter subspace.
   Output: `art/params.png`.

4. **Colormap control** — a hand-editable switch block selects between
   BW, 2-color, 4-color, or depths-color schemes.  The raster returns raw
   crossing counts; the multiplexer applies `count % N_COLORS` and maps
   through the chosen `ListedColormap`.  Adding a scheme is one `elif`.

5. **Polar projection** (future) — the rectangular raster can be remapped
   into polar coordinates with a spiral twist.  This warping lives in the
   multiplexer (or a small `polar.sage` helper) since it transforms a
   finished raster, not the math that builds it.

### What stays in `hazards/`

`crossings.sage` gets a one-liner that loads `art/raster.sage` and
`art/multiplexer.sage` in single-panel mode, so existing `./sagew` invocations
keep working.  Or it is retired entirely once `art/multiplexer.sage` subsumes
its output.

## Dependency graph

```
lib/partitions.sage
       |
       v
  art/raster.sage          (pure raster math)
       |
       v
  art/multiplexer.sage     (config, layout, colormaps, output)
       |
       +---> art/crossings.png
       +---> art/zoo.png
       +---> art/params.png
```

## Design principles

- **raster.sage is stateless** — same inputs, same ndarray.  No side effects.
- **multiplexer.sage owns all I/O** — file paths, figure sizing, titles, dpi.
- **No code duplication** — `_slope_deviation.sage` shares `cell_chord_slope`
  with `raster.sage`.  After migration, `_slope_deviation.sage` can import
  the math from `raster.sage` instead of duplicating it.
- **Resolution scales with panel count** — single panel: 3000x2250.
  16-panel grid: 1200x900 per tile (otherwise too slow / too much memory).
