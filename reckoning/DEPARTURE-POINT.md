# Departure Point

This note records the mathematical starting point of the project: Day's FRGR framework and why the pseudo-log, the geometric grid, and the binary representation are jointly adapted.

1. the pseudo-log and its inverse;
2. the coarse approximation via a line in pseudo-log space;
3. the quality metric z(x) and its periodicity;
4. the finite candidate set for the extrema of z;
5. the optimal intercept via switchover functions;
6. the logarithm as the unique scaling coordinate;
7. the pseudo-log as the boundary-aligned surrogate;
8. the base-2 significance space as the free representation;

Sections 1–5 follow Day (2023), arXiv:2307.15600. Section 8 uses the
significance space formalization of Matula (1970). Sections 6 & 7 are
ours. See [`experiments/keystone/KEYSTONE.md`](../experiments/keystone/KEYSTONE.md)
for exhibits and partial experimental support.

---

## 1. The pseudo-log

For `x > 0`, define

    E_x = floor(log₂ x),
    m_x = x · 2^{−E_x} − 1,

so that `E_x ∈ ℤ` and `0 ≤ m_x < 1`. Then

    L(x) = E_x + m_x.

L is piecewise linear on each binade `[2^k, 2^{k+1})`, agrees with
`log₂` at every power of 2, and has slope `2^{−E_x}` within each
binade.

The inverse: given `X ∈ ℝ`, let `E_X = floor(X)`, `m_X = X − E_X`.
Then

    L⁻¹(X) = 2^{E_X} (1 + m_X).

The gap between L and log₂ on one binade is `ε(m) = log₂(1+m) − m`.

---

## 2. The coarse approximation

For the target function `f(x) = x^{−a/b}` with `a, b ∈ ℤ⁺`,
`gcd(a,b) = 1`, the relation `log₂ y ≈ −(a/b) log₂ x` becomes
the affine line

    aX + bY = c

in pseudo-log coordinates `X = L(x)`, `Y = L(y)`. Solving for y:

    y = L⁻¹((c − aL(x)) / b).

This is the coarse stage of the FRGR algorithm (Day, Algorithm 2).
The classic FRSR bit-hack is the case `a = 1`, `b = 2`, where the
magic constant encodes c.

---

## 3. The quality metric

Define

    z(x) = x^a · y(x)^b.

When `y = x^{−a/b}` exactly, `z = 1`. The deviation of z from 1
measures coarse-stage error. Since `y / y_exact = z^{1/b}`, the
relative error of y lives in `[z_min^{1/b} − 1, z_max^{1/b} − 1]`.

Substituting the pseudo-log expressions:

    z = 2^{aE_x + bE_y} (1 + m_x)^a (1 + m_y)^b.

The periodicity of the floor function gives `z|_{X+b} = z|_X`, so
z is periodic with period b in X and period a in Y. The behaviour
of z is determined by one representative interval `X ∈ [0, b)`.

The optimisation target is `ρ = z_max / z_min`, because after the
best constant correction the degree-0 minimax relative error is

    (ρ^{1/b} − 1) / (ρ^{1/b} + 1).

---

## 4. The candidate set

z is continuous and piecewise-smooth. Its interior stationary points
occur only where `m_x = m_y`, i.e., where the line `aX + bY = c`
crosses the diagonal of an integer grid square. The remaining
extrema occur at boundary crossings, where X or Y is an integer.
This gives three finite candidate families: H and V for the boundary
crossings, and D for the diagonal crossings where `X − Y` is an
integer.

Define

    ζ(r, k, c) = 2^{s−r} (1 + (r + t) / k)^k

where `s = floor(c)`, `t = frac(c)`, `k ∈ ℤ⁺`, `r ∈ {0, …, k−1}`.
Then:

- **H** (integer X): `z|_{X∈ℤ} = ζ(r_b, b, c)`, `r_b ∈ {0, …, b−1}`.
- **V** (integer Y): `z|_{Y∈ℤ} = ζ(r_a, a, c)`, `r_a ∈ {0, …, a−1}`.
- **D** (integer X−Y): `z|_{X−Y∈ℤ} = ζ(r_γ, γ, c)`, `r_γ ∈ {0, …, γ−1}`,
  where `γ = a + b`.

Setting `α = min(a,b)` and `β = max(a,b)`:

    z_min(c) = ζ(r_α, α, c),
    z_max(c) = ζ(r_γ, γ, c).

The minimum comes from the smaller of {a, b}; the maximum from D.

---

## 5. The optimal intercept

ρ = z_max/z_min depends only on `t = frac(c)`, not on `s = floor(c)`.
Two switchover functions determine which candidates are active:

    t₀(k) = (k − 1) / (2^{1−1/k} − 1) − k

controls which candidate gives z_min (switchover between residues
0 and α−1). At k → 1: `t₀ → 1/ln 2 − 1 ≈ 0.4427`.

    φ(k) = 1 / (2^{1/k} − 1) − k + 1

with `r̄ = floor(φ)` and `t₁ = φ − r̄` controls which D-candidate
gives z_max.

The optimal `t*` minimising ρ:

    α = 1:   t* = clamp(t₁, (r̄−1)/β, r̄/β)
    α ≥ 2:   t* = t₀

For FRSR (`a = 1, b = 2`): `α = 1, β = 2, γ = 3`, giving
`t* = 0.5`, so `c* = s + 0.5` for any integer s.

---

## 6. The coordinate

On `ℝ_{>0}`, scaling `x → λx` is the native symmetry. The
logarithm is the unique coordinate (up to affine transformation)
satisfying

    u(λx) = u(x) + c(λ).

If `u` is nonconstant and obeys a standard regularity hypothesis
such as continuity, measurability, local boundedness, or monotonicity,
then `u = A log x + B`.

For example, the chord-error problem for `log₂` on a geometric cell
`[a, ar]` is a translated copy of the problem on `[1, r]`, so its
peak error depends only on the ratio `r`. Equal-log-width cells are
therefore equally hard for that metric.

---

## 7. The surrogate

The affine pseudo-log `L(x) = x − 1` on `[1, 2)` is not the best
affine pointwise fit to `log₂`. A Chebyshev minimax affine fit
achieves peak residual 0.043 vs the pseudo-log's 0.086. But the
Chebyshev residual is offset by −0.043 at both binade boundaries.

Within the class of affine surrogates in the intra-binade coordinate
`m`, say `S(m) = αm + β`, the pseudo-log is the unique one whose
residual `log₂(1+m) − S(m)` vanishes at the binade boundaries
`m = 0` and `m = 1`. Endpoint exactness forces `β = 0` and
`α + β = 1`, hence `S(m) = m`.

So the pseudo-log is the endpoint-exact affine surrogate on the
binade, not the minimax affine surrogate.

---

## 8. The representation

Matula (1970) defines the significance space of base β with n
significant digits as

    S^n_β = { kβ^j : k, j ∈ ℤ, |k| < β^n }.

For `β = 2`, within any interval `[2^j, 2^{j+1})`, the members of
`S^n_2` are uniformly spaced by `2^{j−n+1}`. The fractional position
of x within its binade,

    m = x · 2^{−j} − 1,

is the pseudo-log's intra-binade coordinate. This is a property of
the base-2 significance space itself.

Matula's gap function `F^n_β(x)` is multiplicatively periodic:

    F^n_β(βx) = F^n_β(x).

If we pass to the fixed log coordinate `X = log₂ x` and define

    G^n_β(X) = F^n_β(2^X),

then the same statement becomes additive periodicity:

    G^n_β(X + log₂ β) = G^n_β(X).

So binary has log-scale period `1`, while hexadecimal has log-scale
period `4`. Because `16 = 2^4`, the hexadecimal reset lattice is a
coarser sublattice of the binary one: the two sawteeth are nested
and share the common additive period `4` in `log₂` space.

More generally, if β and δ are commensurable, so `β^i = δ^j` for
some positive integers `i, j` (Matula, Lemma 1 and Corollary 2),
then their log-scale periods `log₂ β` and `log₂ δ` are rationally
related, and the corresponding gap functions admit a common additive
period in `log₂` space. If β and δ are incommensurable, Matula's
Theorem 6 says their significance spaces intersect in only finitely
many points.

The binary format's binade boundaries therefore nest perfectly with
the geometric grid at every depth d: the grid points
`g_k = 2^{k/2^d}` are dyadic refinements of the binade lattice.
