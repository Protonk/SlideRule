"""
crossings.sage — Redirect to art/multiplexer.sage (single-panel mode).

The raster engine and rendering logic now live in:
  art/raster.sage       — pure raster math
  art/multiplexer.sage  — config, layout, colormaps

This file delegates to make_single() so existing ./sagew invocations keep
working.

Run:  ./sagew experiments/stepstone/hazards/crossings.sage
"""

from helpers import pathing
load(pathing('experiments', 'stepstone', 'art', 'multiplexer.sage'))
