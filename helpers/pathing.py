"""
pathing — resolve project-relative paths.

Usage (from any .sage script run via ./sagew):

    from helpers import pathing
    load(pathing('lib', 'partitions.sage'))
"""

import os

_PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def pathing(*parts):
    """Join path components relative to the project root."""
    return os.path.join(_PROJECT_ROOT, *parts)
