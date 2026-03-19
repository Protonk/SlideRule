"""
grid_fractals.sage — Render a preset-driven fractal grid or the full zoo.

Run:  ./sagew experiments/stepstone/fractal/grid_fractals.sage
"""

import json
import os

from helpers import pathing
load(pathing('experiments', 'stepstone', 'fractal', 'raster.sage'))
load(pathing('experiments', 'stepstone', 'fractal', 'multiplexer.sage'))
load(pathing('experiments', 'zoo_figure.sage'))


# ── Configuration ────────────────────────────────────────────────────

PRESET = 'complete_atlas'   # preset name, or None for full zoo
DEPTHS = list(range(1, 15))
SCHEME = 'bw'
X_RES = 1200
Y_RES = 900
DPI = 200
BG_COLOR = '#111111'
TITLE_COLOR = '#dddddd'
OUT = None


def metadata_path():
    return pathing('lib', 'partitions.json')


def default_output_path():
    filename = 'full_zoo.png' if PRESET is None else '%s.png' % PRESET
    return pathing('experiments', 'stepstone', 'fractal', 'results', 'grids',
                   filename)


def load_metadata():
    with open(metadata_path(), 'r') as fh:
        return json.load(fh)


def metadata_by_kind(data):
    return {entry['kind']: entry for entry in data['partitions']}


def build_panel(kind, n_colors, cmap, title):
    raw = build_raster_clipped(kind, DEPTHS, X_RES, Y_RES)
    return raw


def save_figure(fig):
    out_path = os.path.abspath(OUT) if OUT is not None else default_output_path()
    out_dir = os.path.dirname(out_path)
    if out_dir and not os.path.exists(out_dir):
        os.makedirs(out_dir)
    fig.savefig(out_path, dpi=DPI, bbox_inches='tight',
                facecolor=fig.get_facecolor())
    print("Saved: %s" % out_path)


def render_preset_grid(data):
    presets = data['presets']
    if PRESET not in presets:
        raise ValueError("unknown preset %r; expected one of %s" % (
            PRESET, sorted(presets.keys())))

    preset = presets[PRESET]
    kind_meta = metadata_by_kind(data)
    n_rows, n_cols = preset['dimensions']
    fig, axes = plt.subplots(n_rows, n_cols,
                             figsize=(4.0 * n_cols, 3.0 * n_rows),
                             squeeze=False,
                             constrained_layout=True)
    fig.set_facecolor(BG_COLOR)

    n_colors, cmap = _build_cmap(SCHEME, n_depths=len(DEPTHS))
    cell_map = {(row, col): kind for row, col, kind in preset['cells']}

    print("Preset: %s" % PRESET)
    print("Narrative: %s" % preset['narrative'])

    total = len(preset['cells'])
    done = 0
    for row in range(n_rows):
        for col in range(n_cols):
            ax = axes[row, col]
            kind = cell_map.get((row, col))
            if kind is None:
                ax.axis('off')
                ax.set_facecolor(BG_COLOR)
                continue

            meta = kind_meta.get(kind)
            if meta is None:
                raise ValueError("preset %r references unknown kind %r" % (PRESET, kind))

            done += 1
            title = meta['display_name']
            print("  [%2d/%d] %-20s ..." % (done, total, title))
            raw = build_panel(kind, n_colors, cmap, title)
            render_panel(ax, raw, n_colors, cmap, title=title)
            ax.title.set_color(TITLE_COLOR)

    save_figure(fig)


def render_full_zoo():
    n_colors, cmap = _build_cmap(SCHEME, n_depths=len(DEPTHS))
    fig, axes, _n_rows, _n_cols = zoo_subplots(figsize_per_cell=(4.0, 3.0))
    fig.set_facecolor(BG_COLOR)

    total = len(PARTITION_ZOO)
    for idx, (name, _color, kind) in enumerate(PARTITION_ZOO):
        row, col = divmod(idx, _n_cols)
        ax = axes[row, col]
        print("  [%2d/%d] %-20s ..." % (idx + 1, total, name))
        raw = build_panel(kind, n_colors, cmap, name)
        render_panel(ax, raw, n_colors, cmap, title=name)
        ax.title.set_color(TITLE_COLOR)

    zoo_hide_unused(axes.flat)
    save_figure(fig)


def main():
    data = load_metadata()
    if PRESET is None:
        render_full_zoo()
    else:
        render_preset_grid(data)


main()
