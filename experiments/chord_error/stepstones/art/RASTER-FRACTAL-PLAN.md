# RASTER-FRACTAL-PLAN

Concrete implementation plan for splitting `hazards/crossings.sage` into
`art/raster.sage` + `art/multiplexer.sage`.

---

## Step 1 — `art/raster.sage`

Extract the raster engine from `crossings.sage`.

```
File: art/raster.sage
Loads: lib/day.sage, lib/partitions.sage  (via pathing)
Exports: build_raster(), build_raster_clipped()
No matplotlib.  No globals.  No output.
```

Changes from `crossings.sage`:

| Current (crossings.sage) | New (raster.sage) |
|---|---|
| `KIND`, `DEPTHS`, `X_RES`, `Y_RES` are module globals | All passed as function arguments |
| `build_raster(kind, x_chunk)` reads globals | `build_raster(kind, depths, x_res, y_res, x_chunk=500)` |
| `build_raster_clipped(kind, x_chunk)` reads globals | `build_raster_clipped(kind, depths, x_res, y_res, x_chunk=500)` |
| Math helpers at module level | Unchanged, stay at module level |

The raster functions return a `np.ndarray` of dtype `uint16` with **raw
crossing counts** (0 .. len(depths)+1).  No modular arithmetic applied.
The multiplexer decides how to color from these raw counts.

---

## Step 2 — `art/multiplexer.sage`

The driver script.  Three render modes selected by a top-level `MODE` variable
(or separate `make_*` functions called from `__main__`).

```
File: art/multiplexer.sage
Loads: art/raster.sage  (via pathing)
Imports: matplotlib, numpy
Outputs: art/crossings.png, art/zoo.png, art/params.png
```

### 2a — Single-panel mode (`make_single`)

Replaces `crossings.sage` 1:1.

Config block:
```python
KIND = 'stern_brocot_x'
DEPTHS = list(range(1, 21))
X_RES = 3000
Y_RES = 2250
CMAP = 'gray'            # or ListedColormap([...])
CLIP = True               # use build_raster_clipped
```

Renders one full-bleed image, no axes, no title.  Saves to
`art/crossings.png`.

### 2b — Zoo mode (`make_zoo`)

4x4 grid over all 16 PARTITION_ZOO entries.

Config block:
```python
ZOO_DEPTHS = list(range(1, 15))
ZOO_X_RES = 1200
ZOO_Y_RES = 900
ZOO_CMAP = ListedColormap(['#2a9d8f', '#f0b429'])   # green/gold
```

Each panel: `build_raster_clipped(kind, ZOO_DEPTHS, ZOO_X_RES, ZOO_Y_RES)`.
Panel title = display name from PARTITION_ZOO.

Saves to `art/zoo.png`.

### 2c — Param-sweep mode (`make_params`)

Same KIND, varying parameters across 4x4 grid.

Config block:
```python
PARAM_KIND = 'geometric_x'
PARAM_CMAP = ListedColormap(['#2a9d8f', '#f0b429'])
SPIRAL_GRID = [1, 2, 4, 7]           # rows
R_INNER_GRID = [0.05, 0.15, 0.30, 0.50]  # cols
DEPTHS_GRID = [                       # shifts across diagonal
    list(range(1, 11)),
    list(range(1, 13)),
    list(range(1, 15)),
    list(range(1, 17)),
]
```

Panel label: `"S=%d r=%.2f D=%d"`.  Saves to `art/params.png`.

Note: SPIRAL_GRID and R_INNER_GRID only apply when polar remapping is active.
For plain raster param sweeps, the grid axes could be DEPTHS x KIND subsets,
or DEPTHS x resolution, etc. — the multiplexer just needs a
`(row, col) -> config dict` mapping.

### 2d — Color scheme selector

A hand-editable block near the top of the multiplexer.  Pick one, comment
out the rest.  The raster returns raw crossing counts; the scheme determines
how those counts map to colors.

```python
# ── COLOR SCHEME — uncomment exactly one ─────────────────────────────

# Black & white (binary parity)
SCHEME = 'bw'

# 2-color: green / gold
# SCHEME = '2c'

# 4-color: teal / red / orange / steel-blue
# SCHEME = '4c'

# Depth-color: one hue per curve (len(DEPTHS) + 1 bands)
# SCHEME = 'depths'
```

Beneath that, a plain switch that builds the colormap and modulus:

```python
from matplotlib.colors import ListedColormap

if SCHEME == 'bw':
    N_COLORS = 2
    CMAP = ListedColormap(['#000000', '#ffffff'])
elif SCHEME == '2c':
    N_COLORS = 2
    CMAP = ListedColormap(['#2a9d8f', '#f0b429'])
elif SCHEME == '4c':
    N_COLORS = 4
    CMAP = ListedColormap(['#e63946', '#457b9d', '#f4a261', '#2a9d8f'])
elif SCHEME == 'depths':
    N_COLORS = len(DEPTHS) + 1
    CMAP = plt.cm.get_cmap('turbo', N_COLORS)
```

Then the shared render function uses these:

```python
def render_panel(ax, raw_counts, cmap=CMAP, n_colors=N_COLORS, title=None):
    """Draw a raster of raw crossing counts onto an axes."""
    img = raw_counts % n_colors
    ax.axis('off')
    ax.imshow(img, cmap=cmap, aspect='auto',
              interpolation='nearest', vmin=0, vmax=n_colors - 1)
    if title:
        ax.set_title(title, fontsize=8, fontweight='bold', pad=2)
```

No abstraction beyond this.  Want a different palette?  Edit the hex codes.
Want a 7-color scheme?  Add an `elif`.

---

## Step 3 — Retire or redirect `hazards/crossings.sage`

Option A (redirect):
```python
# crossings.sage — now delegates to art/multiplexer.sage
from helpers import pathing
load(pathing('experiments', 'chord_error', 'stepstones', 'art', 'multiplexer.sage'))
make_single()
```

Option B (retire): delete `crossings.sage`, update any references.

Recommendation: **Option A** initially, retire later once `art/` is settled.

---

## Step 4 — Consolidate shared math

`hazards/_slope_deviation.sage` duplicates `cell_chord_slope` with
`raster.sage`.  After the migration, `_slope_deviation.sage` should load
`art/raster.sage` and use its `cell_chord_slope` instead of defining its own.
(`curated.sage` and any other consumers of `_slope_deviation.sage` are
unaffected — the function signature doesn't change.)

---

## Step 5 — Polar projection (future, not blocking)

A `polar.sage` helper or section within `multiplexer.sage` that takes a
finished raster and remaps it into polar coordinates with spiral twist.
This is a post-processing transform, not a change to the raster math.

```python
def rect_to_polar(rect, spiral_turns, r_inner, r_outer, polar_res):
    """Remap a rectangular raster into a polar image."""
    ...
```

This keeps `raster.sage` focused on the crossing-count math and lets polar
art be a composable layer.

---

## File inventory after migration

```
art/
  FRACTAL.md               <- you are here
  RASTER-FRACTAL-PLAN.md   <- this file
  raster.sage              <- pure raster engine
  multiplexer.sage         <- config + layout + output
  crossings.png            <- single-panel output
  zoo.png                  <- 16-kind grid
  params.png               <- parameter sweep grid
```

---

## Resolved decisions

1. **Single script, multiple `make_*` functions.**  Uncomment the one you
   want at the bottom.  No MODE enum.

2. **`raster.sage` returns raw crossing counts** (uint16, values 0..n_curves).
   The multiplexer applies `% N_COLORS` from the hand-editable color scheme
   block.  Four built-in schemes: BW, 2-color, 4-color, depths-color.
   Adding more is one `elif` away.

3. **Name stays `multiplexer.sage`.**
