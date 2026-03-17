"""
uniform_vs_geometric_peaks.sage — Three-panel comparison of partition geometries.

Top:    uniform sawtooth with peak envelope (decaying 1/(8N²m²ln2))
Middle: both peak envelopes only — uniform (decaying) vs geometric (flat)
        with m* = 1/ln2 crossing marked
Bottom: geometric sawtooth with peak envelope (flat ln2/(8N²))

Run:  ./sagew experiments/error/tilt/uniform_vs_geometric_peaks.sage
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, log2 as math_log2


# ── Configuration ────────────────────────────────────────────────────

N = 100
M_PER_CELL = 40


# ── Partitions ──────────────────────────────────────────────────────

def uniform_partition(N):
    return [(1.0 + j / N, 1.0 + (j + 1) / N) for j in range(N)]


def geometric_partition(N):
    """Equal-width in log space: x_j = 2^{j/N}."""
    return [(2.0 ** (j / N), 2.0 ** ((j + 1) / N)) for j in range(N)]


# ── Math ─────────────────────────────────────────────────────────────

def cell_chord_slope(a, b):
    return (math_log2(b) - math_log2(a)) / (b - a)


def log_mean(a, b):
    return (b - a) / (log(b) - log(a))


def build_profiles(cells):
    m_segments = []
    E_segments = []
    peak_ms = []
    peak_Es = []

    for a, b in cells:
        sigma = cell_chord_slope(a, b)
        ms = np.linspace(a, b, M_PER_CELL)
        chord_vals = math_log2(a) + sigma * (ms - a)
        E_vals = np.log2(ms) - chord_vals

        m_segments.append(ms)
        E_segments.append(E_vals)

        m_pk = log_mean(a, b)
        E_pk = math_log2(m_pk) - (math_log2(a) + sigma * (m_pk - a))
        peak_ms.append(m_pk)
        peak_Es.append(E_pk)

    m_all = np.concatenate(m_segments)
    E_all = np.concatenate(E_segments)
    return m_all, E_all, np.array(peak_ms), np.array(peak_Es)


# ── Plotting ─────────────────────────────────────────────────────────

UNI_COLOR = '#1f77b4'
GEO_COLOR = '#9467bd'
UNI_ENV_COLOR = '#d62728'
GEO_ENV_COLOR = '#2ca02c'


def make_plot():
    u_cells = uniform_partition(N)
    g_cells = geometric_partition(N)

    u_m, u_E, u_pk_m, u_pk_E = build_profiles(u_cells)
    g_m, g_E, g_pk_m, g_pk_E = build_profiles(g_cells)

    # Asymptotic envelopes — hard stop at [1, 2].
    env_ms = np.linspace(1.0, 2.0, 400)
    env_uniform = 1.0 / (8.0 * N**2 * env_ms**2 * log(2.0))
    geo_level = log(2.0) / (8.0 * N**2)

    m_star = 1.0 / log(2.0)

    # Shared y-max for top and bottom sawtooth panels
    y_max = max(u_pk_E.max(), g_pk_E.max()) * 1.15

    fig, (ax_u, ax_env, ax_g) = plt.subplots(
        3, 1, figsize=(9, 8),
        gridspec_kw={'height_ratios': [2, 1.2, 2]},
        sharex=True,
        constrained_layout=True,
    )

    # ── Top: uniform sawtooth ──────────────────────────────────────

    ax_u.fill_between(u_m, 0, u_E, color=UNI_COLOR, alpha=0.4)
    ax_u.plot(u_m, u_E, '-', color=UNI_COLOR, linewidth=0.3)
    ax_u.plot(env_ms, env_uniform, '--', color=UNI_ENV_COLOR, linewidth=1.8,
              alpha=0.85, label=r'$1/(8N^2 m^2 \ln 2)$')
    ax_u.set_ylim(0, y_max)
    ax_u.set_ylabel('per-cell error $E(m)$', fontsize=10)
    ax_u.set_title('uniform', fontsize=11, fontweight='bold')
    ax_u.legend(fontsize=8, loc='upper right')
    ax_u.ticklabel_format(axis='y', style='scientific', scilimits=(0,0), useMathText=True)
    ax_u.yaxis.get_offset_text().set_visible(False)
    ax_u.tick_params(labelsize=8)

    # ── Middle: envelope comparison ────────────────────────────────

    ax_env.plot(u_pk_m, u_pk_E, '-', color=UNI_ENV_COLOR, linewidth=2.0,
                label='uniform (exact)')
    ax_env.plot(g_pk_m, g_pk_E, '-', color=GEO_ENV_COLOR, linewidth=2.0,
                label='geometric (exact)')

    ax_env.axvline(m_star, color='#888888', linewidth=1.0, linestyle=':')
    ax_env.annotate(
        r'$m^* = 1/\ln 2$',
        xy=(m_star, geo_level),
        xytext=(m_star + 0.12, geo_level * 1.6),
        fontsize=9, color='#555555',
        arrowprops=dict(arrowstyle='->', color='#888888', lw=0.8),
    )

    ax_env.set_ylim(0, u_pk_E.max() * 1.15)
    ax_env.legend(fontsize=8, loc='upper right')
    ax_env.ticklabel_format(axis='y', style='scientific', scilimits=(0,0), useMathText=True)
    ax_env.yaxis.get_offset_text().set_visible(False)
    ax_env.tick_params(labelsize=8)

    # ── Bottom: geometric sawtooth ─────────────────────────────────

    ax_g.fill_between(g_m, 0, g_E, color=GEO_COLOR, alpha=0.35)
    ax_g.plot(g_m, g_E, '-', color=GEO_COLOR, linewidth=0.3)
    ax_g.plot([1.0, 2.0], [geo_level, geo_level], '--', color=GEO_ENV_COLOR,
              linewidth=1.8, alpha=0.85, label=r'$\ln 2 \,/\, 8N^2$')
    ax_g.set_ylim(0, y_max)
    ax_g.set_ylabel('per-cell error $E(m)$', fontsize=10)
    ax_g.set_xlabel('$m$', fontsize=10)
    ax_g.set_title('geometric', fontsize=11, fontweight='bold')
    ax_g.legend(fontsize=8, loc='upper right')
    ax_g.ticklabel_format(axis='y', style='scientific', scilimits=(0,0), useMathText=True)
    ax_g.yaxis.get_offset_text().set_visible(False)
    ax_g.tick_params(labelsize=8)

    fig.suptitle(
        f'Per-cell chord error: uniform vs geometric\n'
        f'$N = {N}$ cells on $[1,\\, 2)$',
        fontsize=13, fontweight='bold',
    )

    out_path = 'experiments/error/tilt/uniform_vs_geometric_peaks.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print(f"Saved: {out_path}")


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    u_cells = uniform_partition(N)
    g_cells = geometric_partition(N)
    _, _, _, u_pk_E = build_profiles(u_cells)
    _, _, _, g_pk_E = build_profiles(g_cells)

    geo_level = log(2.0) / (8.0 * N**2)

    print()
    print("Uniform vs geometric diagnostics")
    print("=" * 55)
    print(f"  N = {N}")
    print(f"  uniform  peak range: {u_pk_E.min():.6e} .. {u_pk_E.max():.6e}  "
          f"(ratio {u_pk_E.max()/u_pk_E.min():.2f}:1)")
    print(f"  geometric peak range: {g_pk_E.min():.6e} .. {g_pk_E.max():.6e}  "
          f"(ratio {g_pk_E.max()/g_pk_E.min():.4f}:1)")
    print(f"  geometric flat level: {geo_level:.6e}")
    print(f"  crossing m* = 1/ln2 = {1.0/log(2.0):.6f}")
    print()


# ── Main ─────────────────────────────────────────────────────────────

print_diagnostics()
make_plot()
print("Done.")
