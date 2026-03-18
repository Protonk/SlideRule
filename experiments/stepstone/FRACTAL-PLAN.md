# Plan: Centralize fractal generation in stepstone/

## Problem

Fractal crossing-count images are scattered across three places:

- **art/** — `raster.sage` (engine), `multiplexer.sage` (config + layout +
  rendering), plus ad-hoc PNGs (`crossings.png`, `zoo.png`, `params.png`).
- **hazards/crossings.sage** — a redirect shim that loads multiplexer and
  runs `make_single()`, depositing a duplicate `crossings.png` in art/.
- **art/FRACTAL.md** — documents the raster/multiplexer split but is now
  stale (predates the 23-partition zoo and the restructure).

The multiplexer bundles three render modes, four color-scheme presets, and
all configuration into one file with a "comment/uncomment to select mode"
interface. To actually generate the full zoo grid for visual assessment
(which we haven't done yet with all 23 partitions), you have to hand-edit
the file and re-run. The param-sweep mode was exploratory work; its job is
done and the refactor should actively retire it rather than preserve it.

Meanwhile, `distillations/` holds two orphaned files:

- **`partitions.json`** — machine-readable partition metadata including 9
  curated grid presets (`geo_vs_elementary`, `complete_atlas`, etc.) with
  cell assignments, dimensions, and narratives.
- **`PARTITIONS.md`** — human-readable classification of all 23 partitions
  into 7 groups (A–G) with parameters, equivalences, and a preset summary.

Neither file is referenced by any code. The presets exist specifically for
comparative grid visualization but have never been wired up to a renderer.

## Goal

Two clean runnable scripts, preset-driven grid rendering, generated outputs
centralized under a dedicated results directory, and no orphaned data at the
end of the full plan:

```
lib/
├── partitions.sage              EXISTS — partition definitions + PARTITION_ZOO
└── partitions.json              MOVED  — metadata + 9 grid presets

PARTITIONS.md                    MOVED  — classification reference (project root)

stepstone/
├── fractal/
│   ├── raster.sage              KEPT   — pure raster engine (unchanged)
│   ├── multiplexer.sage         KEPT   — colormaps + panel rendering only
│   ├── single_fractal.sage      NEW    — render one partition, one image
│   ├── grid_fractals.sage       NEW    — render preset or full zoo grid
│   └── results/
│       ├── single/              NEW    — single-image outputs
│       └── grids/               NEW    — preset/zoo grid outputs
```

And delete the ad-hoc outputs, the redirect shim, and the empty directories:

- DELETE `art/crossings.png`, `art/zoo.png`, `art/params.png`
- DELETE `art/FRACTAL.md`
- DELETE `hazards/crossings.sage`, `hazards/crossings.png`
- DELETE `distillations/` (empty after moves)
- DELETE `art/` (empty after moves)

## Sequencing

Execution should be split into two phases.

### Phase 1 — Coherent fractal pipeline

Do the renderer cleanup first, entirely within `experiments/stepstone/`:

- create `fractal/` and `fractal/results/`
- move `art/raster.sage` and `art/multiplexer.sage` into `fractal/`
- strip `multiplexer.sage` down to reusable rendering helpers
- add `single_fractal.sage` and `grid_fractals.sage`
- delete the redirect shim and the ad-hoc generated PNGs
- explicitly retire param-sweep rendering

During this phase, `grid_fractals.sage` keeps loading preset metadata from
`distillations/partitions.json`. Do **not** move metadata and docs at the same
time as the renderer cleanup.

### Phase 2 — Metadata/document relocation

Only after Phase 1 lands cleanly:

- move `distillations/partitions.json` to `lib/partitions.json`
- move `distillations/PARTITIONS.md` to project root `PARTITIONS.md`
- update references to point at the new canonical locations
- remove the now-empty `distillations/` directory

## Distillations relocation

### Phase 1 interim state

During Phase 1, keep both metadata files where they already live:

- `distillations/partitions.json`
- `distillations/PARTITIONS.md`

`grid_fractals.sage` should load `distillations/partitions.json` directly
until the renderer pipeline is stable.

### Phase 2 move: `partitions.json` → `lib/partitions.json`

Natural companion to `lib/partitions.sage`. The JSON carries the same
23-entry zoo in machine-readable form plus:

- Per-partition: `category`, `density`, `symmetry`, `arithmetic`,
  `curve_aware`, `params`, `equivalences`, `description`.
- `categories`: group labels (A–G).
- `equivalences`: known boundary-array identities.
- **`presets`**: 9 curated grid layouts with `dimensions`, `cells`,
  `center`, `fill`, and `narrative`.

After the Phase 2 move, `grid_fractals.sage` loads `lib/partitions.json` to
get preset definitions. Other scripts or future tools can use it for any
partition-metadata need.

### Phase 2 move: `PARTITIONS.md` → project root `PARTITIONS.md`

Reference document alongside `LODESTONE.md`, `HYPOTHESES.md`, `WALL.md`.
Describes the 7 groups, parameters, equivalences, and the analytical
selection story around the partition family. It should **not** carry preset
specifications or even a preset summary table after the move. Preset layouts
and narratives live only in `lib/partitions.json`.

## What stays, what moves, what changes

### `raster.sage` — stays, unchanged

Pure stateless engine. Exports `build_raster()`, `build_raster_clipped()`,
`cell_chord_slope()`, `step_values_vec()`, `continuous_slope_vec()`.
No matplotlib, no I/O. Already clean.

Moves from `art/` to `fractal/`.

### `multiplexer.sage` — stays, stripped to library

Currently owns three render modes (`make_single`, `make_zoo`, `make_params`)
plus colormap construction (`_build_cmap`) and panel rendering
(`render_panel`). After the refactor it keeps only the reusable parts:

- `_build_cmap(scheme, n_depths=None)` — returns `(n_colors, cmap)`
- `render_panel(ax, raw_counts, n_colors, cmap, title=None)` — draws one
  raster onto an axes

`make_single`, `make_zoo`, `make_params` are deleted from this file.
Single-image and zoo-grid logic migrate into the two new scripts. Param-sweep
logic is retired entirely and is **not** replaced. Config constants
(`KIND`, `DEPTHS`, `SCHEME`, `ZOO_DEPTHS`, etc.) and the `_here`
computation leave too.

Moves from `art/` to `fractal/`.

### `single_fractal.sage` — NEW

Renders one partition kind at high resolution. No mode toggling inside
`multiplexer.sage`: all knobs live as constants at the top of this dedicated
script.

```
Configuration:
  KIND       = 'stern_brocot_x'
  DEPTHS     = list(range(1, 21))
  SCHEME     = 'bw'
  X_RES      = 3000
  Y_RES      = 2250
  CLIP       = True
  DPI        = 300
  OUT        = None   # auto: experiments/stepstone/fractal/results/single/<kind>.png
```

Logic: load raster.sage + multiplexer.sage, build raster, create a single
full-bleed figure, call `render_panel`, save. The script creates
`fractal/results/single/` if needed.

```
Run:  ./sagew experiments/stepstone/fractal/single_fractal.sage
```

### `grid_fractals.sage` — NEW

Two modes selected by a config constant at the top:

**Mode 1 — Named preset** (e.g. `PRESET = 'complete_atlas'`):
During Phase 1, loads `distillations/partitions.json`; after Phase 2, loads
`lib/partitions.json`. Reads the preset's `dimensions` and `cells`, creates a
grid of that size, renders the specified partitions in the specified cells,
leaves remaining cells blank. The preset's `narrative` is printed to stdout
for context.

**Mode 2 — Full zoo** (`PRESET = None`):
Renders all 23 PARTITION_ZOO entries in a compact grid (5x5, 2 blanks)
using `zoo_figure.sage` layout utilities. Equivalent to the old
multiplexer `make_zoo()`.

```
Configuration:
  PRESET      = 'complete_atlas'   # preset name, or None for full zoo
  DEPTHS      = list(range(1, 15))
  SCHEME      = 'bw'
  X_RES       = 1200
  Y_RES       = 900
  DPI         = 200
  BG_COLOR    = '#111111'
  TITLE_COLOR = '#dddddd'
  OUT         = None   # auto: fractal/results/grids/<preset>.png or full_zoo.png
```

The script creates `fractal/results/grids/` if needed.

The 9 available presets from the partitions metadata JSON:

| Preset | Grid | Theme |
|--------|------|-------|
| `geo_vs_elementary` | 3x3 | Thesis winner vs naive spacing alternatives |
| `geo_vs_number_theory` | 3x3 | Thesis winner vs number-theoretic constructions |
| `geo_vs_chaos` | 3x3 | Thesis winner vs fractal/stochastic perturbations |
| `density_gradient` | 4x4 | Density centroid left-to-right |
| `mathematical_sophistication` | 4x4 | Rows = increasing mathematical machinery |
| `relational_triangle` | 4x4 | 4 anchors with bridging relationships |
| `symmetry_spine` | 3x3 | Symmetric diagonal with symmetry-breaking departures |
| `complete_atlas` | 5x5 | All 23 partitions in concentric rings |
| `four_pillars` | 4x4 | 4 fundamental design philosophies |

```
Run:  ./sagew experiments/stepstone/fractal/grid_fractals.sage
```

## Dependency graph after Phase 1

```
lib/partitions.sage          distillations/partitions.json
       |                                   |
       v                                   |  (presets)
fractal/raster.sage                        |
       |                                   |
       v                                   v
fractal/multiplexer.sage             grid_fractals.sage ---+
       |                                                   |
       +---- single_fractal.sage                           |
       +---------------------------------------------------+
```

After Phase 2, the metadata edge moves from `distillations/partitions.json`
to `lib/partitions.json`.

`_slope_deviation.sage` in hazards/ continues to load `raster.sage` for
`cell_chord_slope`. Its load path changes from `art/raster.sage` to
`fractal/raster.sage`.

## Deletions

| File | Reason |
|------|--------|
| `art/crossings.png` | Ad-hoc output; regenerated under `fractal/results/single/` |
| `art/zoo.png` | Ad-hoc output; regenerated under `fractal/results/grids/` |
| `art/params.png` | Exploratory artifact; param-sweep rendering is retired and not replaced |
| `art/FRACTAL.md` | Superseded by this plan, then by the working code |
| `hazards/crossings.sage` | Redirect shim; no longer needed |
| `hazards/crossings.png` | Output of the deleted shim |
| `distillations/` | Empty after `partitions.json` and `PARTITIONS.md` move |
| `art/` | Empty after `raster.sage` and `multiplexer.sage` move |

## Internal reference updates

| File | Old path | New path |
|------|----------|----------|
| `hazards/_slope_deviation.sage` | `pathing('experiments', 'stepstone', 'art', 'raster.sage')` | `pathing('experiments', 'stepstone', 'fractal', 'raster.sage')` |
| `PARTITIONS.md` preset section | preset summary/spec material present | preset material removed; JSON is sole source |
| `PARTITIONS.md` preset pointer | "Full specifications ... are in `PLAN.md`." | "Preset layouts live in `lib/partitions.json`." |

The old multiplexer load in `hazards/crossings.sage` disappears entirely
(file deleted).

## Implementation steps

### Phase 1 — renderer coherence

1. Create `fractal/` and `fractal/results/{single,grids}/`.
2. `git mv art/raster.sage fractal/raster.sage`
3. `git mv art/multiplexer.sage fractal/multiplexer.sage`
4. Strip `multiplexer.sage` to library-only (remove `make_single`,
   `make_zoo`, `make_params`, config constants, `_here`, main block).
5. Write `fractal/single_fractal.sage`.
6. Write `fractal/grid_fractals.sage` with preset loading from
   `distillations/partitions.json`.
7. Update `_slope_deviation.sage` load path (`art/` → `fractal/`).
8. Delete `hazards/crossings.sage` and `hazards/crossings.png`.
9. Delete `art/crossings.png`, `art/zoo.png`, `art/params.png`,
   and `art/FRACTAL.md`.
10. `rmdir art/` (now empty).
11. Verify: run both new scripts, confirm outputs land in
    `fractal/results/`, run tests.

### Phase 2 — metadata/doc relocation

12. `git mv distillations/partitions.json lib/partitions.json`
13. `git mv distillations/PARTITIONS.md PARTITIONS.md`
14. Remove preset summary/spec material from `PARTITIONS.md`, leaving it as an
    analytical/classification document only.
15. Update `PARTITIONS.md` internal pointer so preset layouts point to
    `lib/partitions.json`.
16. Update `grid_fractals.sage` load path (`distillations/` → `lib/`).
17. Remove empty `distillations/`.
18. Update `AGENTS.md` at project root — add `PARTITIONS.md` to doc table.
