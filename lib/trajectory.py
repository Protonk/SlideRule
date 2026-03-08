#!/usr/bin/env python3

from __future__ import annotations

import math
from dataclasses import dataclass
from fractions import Fraction
from math import floor, gcd


@dataclass(frozen=True)
class Candidate:
    family: str
    r: int
    k: int

    def short(self) -> str:
        return f"{self.family}{self.r}/{self.k}"


def zeta_log2(r: int, k: int, s: int, t: Fraction) -> float:
    return float(s - r) + k * math.log2(1.0 + (r + float(t)) / k)


def decompose(value: Fraction) -> tuple[int, Fraction]:
    s = floor(value)
    return s, value - s


def unique_sorted(values: list[Fraction]) -> list[Fraction]:
    return sorted(set(values))


def grid_crossings(a: int, b: int, c_exact: Fraction, n: int) -> list[Fraction]:
    gamma = a + b
    xs: list[Fraction] = []

    for x in range(n + 1):
        xs.append(Fraction(x, 1))

    for k in range(-4 * n - abs(c_exact.numerator), 4 * n + abs(c_exact.numerator) + 1):
        x_val = Fraction(c_exact - b * k, a)
        if 0 <= x_val <= n:
            xs.append(x_val)

    for k in range(-4 * n - abs(c_exact.numerator), 4 * n + abs(c_exact.numerator) + 1):
        x_val = Fraction(b * k + c_exact, gamma)
        if 0 <= x_val <= n:
            xs.append(x_val)

    return unique_sorted(xs)


def segment_midpoints(a: int, b: int, c_exact: Fraction, n: int) -> list[Fraction]:
    cuts = grid_crossings(a, b, c_exact, n)
    mids: list[Fraction] = []
    for left, right in zip(cuts, cuts[1:]):
        if left < right:
            mids.append((left + right) / 2)
    return mids


def candidate_logs(a: int, b: int, c_exact: Fraction, x_value: Fraction) -> list[tuple[Candidate, float]]:
    y_value = Fraction(c_exact - a * x_value, b)
    d_value = x_value - y_value
    families = [
        ("H", y_value, b),
        ("V", x_value, a),
        ("D", d_value, a + b),
    ]

    values: list[tuple[Candidate, float]] = []
    for family, c_value, k in families:
        s, t = decompose(c_value)
        for r in range(k):
            values.append((Candidate(family, r, k), zeta_log2(r, k, s, t)))
    return values


def active_extrema(a: int, b: int, c_exact: Fraction, x_value: Fraction) -> tuple[Candidate, Candidate]:
    values = candidate_logs(a, b, c_exact, x_value)
    min_cand, _ = min(values, key=lambda item: (item[1], item[0].family, item[0].r, item[0].k))
    max_cand, _ = max(values, key=lambda item: (item[1], item[0].family, item[0].r, item[0].k))
    return min_cand, max_cand


def trajectory(a: int, b: int, c_exact: Fraction, n: int) -> tuple[tuple[Candidate, ...], tuple[Candidate, ...], tuple[tuple[Candidate, Candidate], ...]]:
    mins: list[Candidate] = []
    maxes: list[Candidate] = []
    pairs: list[tuple[Candidate, Candidate]] = []

    for x_mid in segment_midpoints(a, b, c_exact, n):
        min_cand, max_cand = active_extrema(a, b, c_exact, x_mid)
        mins.append(min_cand)
        maxes.append(max_cand)
        pairs.append((min_cand, max_cand))

    return tuple(mins), tuple(maxes), tuple(pairs)


def trajectory_signature(items: tuple[Candidate, ...]) -> tuple[str, ...]:
    return tuple(item.short() for item in items)


def pair_signature(items: tuple[tuple[Candidate, Candidate], ...]) -> tuple[str, ...]:
    return tuple(f"{left.short()}|{right.short()}" for left, right in items)


def sampled_intercepts(a: int, b: int, span_units: int | None = None, denom: int | None = None) -> list[Fraction]:
    if span_units is None:
        span_units = a + b
    if denom is None:
        denom = 2 * (a + b)

    return [Fraction(q, denom) for q in range(-span_units * denom, span_units * denom + 1)]


def distinct_trajectories(
    a: int,
    b: int,
    n: int,
    span_units: int | None = None,
    denom: int | None = None,
) -> dict[str, object]:
    min_set: set[tuple[str, ...]] = set()
    max_set: set[tuple[str, ...]] = set()
    pair_set: set[tuple[str, ...]] = set()
    witnesses: dict[tuple[str, ...], Fraction] = {}

    for c_exact in sampled_intercepts(a, b, span_units=span_units, denom=denom):
        mins, maxes, pairs = trajectory(a, b, c_exact, n)
        min_sig = trajectory_signature(mins)
        max_sig = trajectory_signature(maxes)
        pair_sig = pair_signature(pairs)
        min_set.add(min_sig)
        max_set.add(max_sig)
        pair_set.add(pair_sig)
        witnesses.setdefault(pair_sig, c_exact)

    return {
        "min_count": len(min_set),
        "max_count": len(max_set),
        "pair_count": len(pair_set),
        "sample_count": len(sampled_intercepts(a, b, span_units=span_units, denom=denom)),
        "witnesses": witnesses,
    }


def crossing_preview(a: int, b: int, c_exact: Fraction, n: int, limit: int = 15) -> list[str]:
    return [str(x) for x in grid_crossings(a, b, c_exact, n)[:limit]]


def summarize_trajectory(a: int, b: int, c_exact: Fraction, n: int) -> dict[str, object]:
    mins, maxes, pairs = trajectory(a, b, c_exact, n)
    return {
        "segment_count": len(pairs),
        "min_seq": [c.short() for c in mins],
        "max_seq": [c.short() for c in maxes],
        "pair_seq": [f"{left.short()}|{right.short()}" for left, right in pairs],
    }


def growth_table(a: int, b: int, ns: list[int], span_units: int | None = None, denom: int | None = None) -> list[tuple[int, int, int, int]]:
    rows = []
    for n in ns:
        counts = distinct_trajectories(a, b, n, span_units=span_units, denom=denom)
        rows.append((n, counts["min_count"], counts["max_count"], counts["pair_count"]))
    return rows


def sum_sweep(max_sum: int, n: int, span_units: int | None = None) -> list[tuple[int, int, int, int, int]]:
    rows = []
    for total in range(3, max_sum + 1):
        best = None
        for a in range(1, total):
            b = total - a
            if gcd(a, b) != 1:
                continue
            counts = distinct_trajectories(a, b, n, span_units=span_units)
            row = (total, a, b, counts["min_count"], counts["pair_count"])
            if best is None or row[-1] > best[-1]:
                best = row
        if best is not None:
            rows.append(best)
    return rows


def print_table(title: str, headers: tuple[str, ...], rows: list[tuple[object, ...]]) -> None:
    print(title)
    widths = [len(h) for h in headers]
    for row in rows:
        for idx, value in enumerate(row):
            widths[idx] = max(widths[idx], len(str(value)))
    header_line = "  ".join(str(h).ljust(widths[idx]) for idx, h in enumerate(headers))
    print(header_line)
    print("  ".join("-" * width for width in widths))
    for row in rows:
        print("  ".join(str(value).ljust(widths[idx]) for idx, value in enumerate(row)))
    print()


def main() -> None:
    sanity = summarize_trajectory(1, 2, Fraction(-1, 2), 20)
    print("Sanity check for (a,b)=(1,2), c=-1/2, N=20")
    print(f"First crossings: {crossing_preview(1, 2, Fraction(-1, 2), 20)}")
    print(f"Segments: {sanity['segment_count']}")
    print(f"Min trajectory head: {sanity['min_seq'][:12]}")
    print(f"Max trajectory head: {sanity['max_seq'][:12]}")
    print()

    print_table(
        "Intercept-sampled trajectory counts for (1,2)",
        ("N", "min", "max", "pair"),
        growth_table(1, 2, [4, 8, 12, 16], span_units=8, denom=24),
    )

    print_table(
        "Intercept-sampled trajectory counts for (7,11)",
        ("N", "min", "max", "pair"),
        growth_table(7, 11, [4, 8, 12], span_units=18, denom=36),
    )

    print_table(
        "Best sampled pair count by a+b (coprime pairs, N=6)",
        ("a+b", "a", "b", "min", "pair"),
        sum_sweep(12, 6, span_units=8),
    )


if __name__ == "__main__":
    main()
