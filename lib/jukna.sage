"""
Layer 3 — Jukna-type combinatorial diagnostics.

Sidon sets, cover-free sets, and greedy subset extraction for
0-1 incidence vectors from the path family.

References:
  Jukna, "Tropical Complexity, Sidon Sets, and Dynamic Programming"
  (SIAM J. Discrete Math., 2016)  — sources/jukna_2016_tropical_sidon.pdf
"""


# ── Sidon sets ──────────────────────────────────────────────────────────

def pairwise_sums(vectors, idx_list):
    """Build dict: sum-vector -> first pair that produced it."""
    seen = {}
    collisions = 0
    for i_pos, i in enumerate(idx_list):
        for j in idx_list[i_pos:]:
            s = vectors[i] + vectors[j]
            key = tuple(s)
            pair = tuple(sorted((i, j)))
            if key in seen:
                if seen[key] != pair:
                    collisions += 1
            else:
                seen[key] = pair
    return seen, collisions


def ordered_pair_sum_multiplicities(vectors, subset=None):
    """Count ordered pair sums a+b over the chosen subset."""
    idx = list(range(len(vectors))) if subset is None else list(subset)
    counts = {}
    for i in idx:
        for j in idx:
            key = tuple(vectors[i] + vectors[j])
            counts[key] = counts.get(key, 0) + 1
    return counts


def additive_summary(vectors, subset=None):
    """
    Basic additive statistics for a vector family.

    Returns:
      * sumset_size
      * pair_collision_count  -- ordered-pair collisions beyond first occurrence
      * additive_energy       -- sum_s m(s)^2 on ordered pairs
    """
    counts = ordered_pair_sum_multiplicities(vectors, subset=subset)
    return {
        "sumset_size": len(counts),
        "pair_collision_count": sum(max(0, count - 1) for count in counts.values()),
        "additive_energy": sum(count * count for count in counts.values()),
    }


def is_sidon(vectors, subset=None):
    """Check whether vectors indexed by subset form a Sidon set under +."""
    idx = list(range(len(vectors))) if subset is None else list(subset)
    _, collisions = pairwise_sums(vectors, idx)
    return collisions == 0


def greedy_sidon_subset(vectors):
    """Greedy extraction of a large Sidon subset."""
    n = len(vectors)
    chosen = []
    seen_sums = {}
    for i in range(n):
        conflict = False
        trial_sums = []
        for j in chosen:
            s = tuple(vectors[i] + vectors[j])
            if s in seen_sums:
                conflict = True
                break
            trial_sums.append((s, tuple(sorted((i, j)))))
        if conflict:
            continue
        s_self = tuple(vectors[i] + vectors[i])
        if s_self in seen_sums:
            continue
        trial_sums.append((s_self, (i, i)))
        chosen.append(i)
        for s, pair in trial_sums:
            seen_sums[s] = pair
    return chosen


def exact_sidon_subset(vectors, max_vectors=22):
    """Exact maximum Sidon subset by branch-and-bound on small instances."""
    if len(vectors) > max_vectors:
        return None

    n = len(vectors)
    best = []

    def rec(pos, chosen, seen_sums):
        nonlocal best
        if len(chosen) + (n - pos) <= len(best):
            return
        if pos == n:
            if len(chosen) > len(best):
                best = list(chosen)
            return

        trial_sums = []
        ok = True
        for j in chosen:
            s = tuple(vectors[pos] + vectors[j])
            if s in seen_sums:
                ok = False
                break
            trial_sums.append((s, tuple(sorted((pos, j)))))
        s_self = tuple(vectors[pos] + vectors[pos])
        if ok and s_self in seen_sums:
            ok = False
        if ok:
            new_seen = dict(seen_sums)
            for s, pair in trial_sums:
                new_seen[s] = pair
            new_seen[s_self] = (pos, pos)
            chosen.append(pos)
            rec(pos + 1, chosen, new_seen)
            chosen.pop()

        rec(pos + 1, chosen, seen_sums)

    rec(0, [], {})
    return best


# ── Cover-free sets ─────────────────────────────────────────────────────

def is_cover_free(vectors, subset=None):
    """
    For 0-1 vectors: check that no vector c in the family is
    coordinate-wise <= max(a, b) for any other pair a, b.
    """
    idx = list(range(len(vectors))) if subset is None else list(subset)
    n = len(idx)
    for ii in range(n):
        for jj in range(ii + 1, n):
            i, j = idx[ii], idx[jj]
            u = vector(ZZ, [max(vectors[i][k], vectors[j][k])
                            for k in range(len(vectors[i]))])
            for kk in range(n):
                k = idx[kk]
                if k == i or k == j:
                    continue
                if all(vectors[k][t] <= u[t] for t in range(len(vectors[k]))):
                    return False, (i, j, k)
    return True, None


def greedy_cover_free_subset(vectors):
    """Greedy extraction of a large cover-free subset."""
    n = len(vectors)
    chosen = []
    for candidate in range(n):
        ok = True
        vc = vectors[candidate]
        for ii in range(len(chosen)):
            for jj in range(ii + 1, len(chosen)):
                i, j = chosen[ii], chosen[jj]
                u = vector(ZZ, [max(vectors[i][k], vectors[j][k])
                                for k in range(len(vc))])
                if all(vc[t] <= u[t] for t in range(len(vc))):
                    ok = False
                    break
            if not ok:
                break
        if not ok:
            continue
        still_ok = True
        for ii in range(len(chosen)):
            i = chosen[ii]
            u_new = vector(ZZ, [max(vectors[candidate][k], vectors[i][k])
                                for k in range(len(vc))])
            for jj in range(len(chosen)):
                j = chosen[jj]
                if j == i:
                    continue
                if all(vectors[j][t] <= u_new[t] for t in range(len(vc))):
                    still_ok = False
                    break
            if not still_ok:
                break
        if still_ok:
            chosen.append(candidate)
    return chosen


def exact_cover_free_subset(vectors, max_vectors=20):
    """Exact maximum cover-free subset by branch-and-bound on small instances."""
    if len(vectors) > max_vectors:
        return None

    n = len(vectors)
    best = []

    def rec(pos, chosen):
        nonlocal best
        if len(chosen) + (n - pos) <= len(best):
            return
        if pos == n:
            if len(chosen) > len(best):
                best = list(chosen)
            return

        trial = chosen + [pos]
        if is_cover_free(vectors, subset=trial)[0]:
            rec(pos + 1, trial)

        rec(pos + 1, chosen)

    rec(0, [])
    return best


def summarize_vector_family(vectors, exact_sidon_limit=22, exact_cover_limit=20):
    """
    Combined additive and subset diagnostics for a vector family.
    """
    add = additive_summary(vectors)
    greedy_sidon = greedy_sidon_subset(vectors)
    greedy_cover = greedy_cover_free_subset(vectors)
    exact_sidon = exact_sidon_subset(vectors, max_vectors=exact_sidon_limit)
    exact_cover = exact_cover_free_subset(vectors, max_vectors=exact_cover_limit)

    return {
        "size": len(vectors),
        "dimension": len(vectors[0]) if len(vectors) > 0 else 0,
        "full_sidon": is_sidon(vectors),
        "sumset_size": add["sumset_size"],
        "pair_collision_count": add["pair_collision_count"],
        "additive_energy": add["additive_energy"],
        "greedy_sidon_subset": greedy_sidon,
        "greedy_sidon_subset_size": len(greedy_sidon),
        "greedy_cover_free_subset": greedy_cover,
        "greedy_cover_free_subset_size": len(greedy_cover),
        "exact_sidon_subset": exact_sidon,
        "exact_sidon_subset_size": None if exact_sidon is None else len(exact_sidon),
        "exact_cover_free_subset": exact_cover,
        "exact_cover_free_subset_size": None if exact_cover is None else len(exact_cover),
    }
