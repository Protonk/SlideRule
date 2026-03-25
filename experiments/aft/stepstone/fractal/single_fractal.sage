"""
single_fractal.sage — Render one partition's fractal crossing image.

Run:  ./sagew experiments/aft/stepstone/fractal/single_fractal.sage
"""

import os

from helpers import pathing
load(pathing('experiments', 'aft', 'stepstone', 'fractal', 'raster.sage'))
load(pathing('experiments', 'aft', 'stepstone', 'fractal', 'multiplexer.sage'))


# ── Configuration ────────────────────────────────────────────────────

KIND = 'stern_brocot_x'
DEPTHS = list(range(1, 21))
SCHEME = 'bw'
X_RES = 3000
Y_RES = 2250
CLIP = True
DPI = 300
OUT = None


def default_output_path():
    return pathing('experiments', 'aft', 'stepstone', 'fractal', 'results', 'single',
                   '%s.png' % KIND)


def main():
    n_colors, cmap = _build_cmap(SCHEME, n_depths=len(DEPTHS))

    print("Building single raster (%d x %d, %d curves) ..." % (
        X_RES, Y_RES, len(DEPTHS) + 1))

    if CLIP:
        raw = build_raster_clipped(KIND, DEPTHS, X_RES, Y_RES)
    else:
        raw = build_raster(KIND, DEPTHS, X_RES, Y_RES)

    fig = plt.figure(frameon=False)
    fig.set_size_inches(10, 10 * Y_RES / X_RES)
    ax = fig.add_axes([0, 0, 1, 1])
    render_panel(ax, raw, n_colors, cmap)

    out_path = os.path.abspath(OUT) if OUT is not None else default_output_path()
    out_dir = os.path.dirname(out_path)
    if out_dir and not os.path.exists(out_dir):
        os.makedirs(out_dir)

    fig.savefig(out_path, dpi=DPI, pad_inches=0)
    print("Saved: %s" % out_path)


main()
