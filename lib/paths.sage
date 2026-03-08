"""
Layer 1 — Layered path families.

Residue automaton mod q with binary input.  States 0..q-1,
transitions r -> (2r + b) mod q.  Each source-to-sink path
corresponds to a binary prefix sigma = b_1 ... b_m and carries
a 0-1 incidence vector over the edge set.
"""

from itertools import product as iproduct


def residue_paths(q, depth):
    """
    Build the layered graph and enumerate all source-to-sink paths.

    Parameters
    ----------
    q     : int — number of automaton states (residues mod q)
    depth : int — number of layers (= mantissa bit depth m)

    Returns
    -------
    edges      : list of ((layer, state_from), (layer+1, state_to), bit)
    paths      : list of dicts with keys:
                   'bits'     — tuple of 0/1
                   'states'   — tuple of (layer, state) visited
                   'vec'      — ZZ-vector, 0-1 incidence over edges
                   'terminal' — final state (int)
    edge_index : dict  edge -> position in edge list
    """
    edges = []
    edge_index = {}

    for t in range(depth):
        for r in range(q):
            for b in (0, 1):
                r2 = (2*r + b) % q
                e = ((t, r), (t + 1, r2), b)
                edge_index[e] = len(edges)
                edges.append(e)

    paths = []
    for bits in iproduct((0, 1), repeat=depth):
        r = 0
        states = [(0, r)]
        vec = [0] * len(edges)
        for t, b in enumerate(bits):
            r2 = (2*r + b) % q
            e = ((t, r), (t + 1, r2), b)
            vec[edge_index[e]] = 1
            r = r2
            states.append((t + 1, r))
        paths.append({
            "bits": tuple(bits),
            "states": tuple(states),
            "vec": vector(ZZ, vec),
            "terminal": r,
        })

    return edges, paths, edge_index
