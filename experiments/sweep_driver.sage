"""
sweep_driver.sage — Shared sweep and CSV infrastructure.

Provides result directory creation, CSV writing, and common formatting
helpers used by multiple sweep scripts.

Not intended to be run directly.
"""

import os
import csv

from helpers import pathing


def result_dir(topic, tag=None):
    """Create experiments/<topic>/results/<tag>/ and return the path."""
    parts = ['experiments', topic, 'results']
    if tag:
        parts.append(tag)
    d = pathing(*parts)
    if not os.path.exists(d):
        os.makedirs(d)
    return d


def write_csv(rows, filepath, columns):
    """Write dicts-as-rows to a CSV file, creating parent directories."""
    d = os.path.dirname(filepath)
    if not os.path.exists(d):
        os.makedirs(d)
    with open(filepath, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=columns, extrasaction='ignore')
        writer.writeheader()
        for r in rows:
            writer.writerow(r)
    print(f"  -> {filepath}  ({len(rows)} rows)")


def subset_size_str(greedy_size, exact_size):
    """Render greedy/exact subset sizes compactly."""
    exact_str = "-" if exact_size is None else str(exact_size)
    return f"{greedy_size}/{exact_str}"
