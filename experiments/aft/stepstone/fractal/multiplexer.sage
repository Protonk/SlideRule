"""
multiplexer.sage — Shared rendering helpers for fractal crossings.

Provides colormap construction and panel rendering for the dedicated fractal
entry points in this directory.

Not intended to be run directly.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap


def _build_cmap(scheme, n_depths=None):
    """Return (N_COLORS, CMAP) for the given scheme name."""
    if scheme == 'bw':
        return 2, ListedColormap(['#000000', '#ffffff'])
    elif scheme == '2c':
        return 2, ListedColormap(['#2a9d8f', '#f0b429'])
    elif scheme == '4c':
        return 4, ListedColormap(['#e63946', '#457b9d', '#f4a261', '#2a9d8f'])
    elif scheme == 'depths':
        nc = (n_depths or 20) + 1
        return nc, plt.cm.get_cmap('turbo', nc)
    else:
        raise ValueError("Unknown SCHEME: %r" % scheme)


# ── Shared rendering ────────────────────────────────────────────────

def render_panel(ax, raw_counts, n_colors, cmap, title=None):
    """Draw a raster of raw crossing counts onto an axes."""
    img = raw_counts % n_colors
    ax.axis('off')
    ax.imshow(img, cmap=cmap, aspect='auto',
              interpolation='nearest', vmin=0, vmax=n_colors - 1)
    if title:
        ax.set_title(title, fontsize=8, fontweight='bold', pad=2)
