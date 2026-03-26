# Log₂ / Mod-1 Scaffold

This note records three project facts on the mod-1 `log₂` coordinate:

1. endpoint exactness of the pseudo-log residual;
2. reciprocal mantissa as a special distributional regime;
3. dyad-boundary seam conditions.

The generic antiderivative/Fourier bridge is included only as a short
calculus template. The project-specific content is in the binary choice of
coordinates and in the approximation `log₂(1+m) ≈ m`.

---

## 1. Common coordinate

Let `X > 0` and define

    W = log₂ X.

Write

    N = floor(W),
    T = {W} = W - floor(W) ∈ [0,1).

Then

    X = 2^W = 2^{N+T} = 2^N 2^T.

So:

- `N` is the binade index;
- `T` is the position inside the binade in `log₂` coordinates;
- the mantissa is `M = 2^T`.

Thus mantissa extraction is exactly:

1. move to `log₂` coordinates;
2. reduce modulo `1`;
3. exponentiate back.

In this coordinate, binade boundaries are the integer lattice `ℤ`, and
reducing modulo `1` identifies those boundaries to form the circle
`[0,1)` with endpoints glued.

---

## 2. Periodized density on the circle

If `W` has density `f_W(w)` on `ℝ`, then the density of `T = {W}` on
`[0,1)` is the periodization

    f_T(t) = Σ_{k∈ℤ} f_W(t+k).

Its Fourier series is

    f_T(t) = Σ_{n∈ℤ} c_n e^{j 2π n t},

with coefficients

    c_n = ∫_0^1 f_T(t) e^{-j 2π n t} dt
        = ∫_ℝ f_W(w) e^{-j 2π n w} dw.

So the Fourier coefficients of the periodized density are the
integer-frequency samples of the characteristic function of `W`.

This is the Fourier object attached to the binade lattice.

---

## 3. Reciprocal mantissa

The mantissa `M = 2^T` is reciprocally distributed exactly when `T` is
uniform on `[0,1)`.

Equivalently,

    f_T(t) = 1.

Equivalently,

    c_n = 0    for all n ≠ 0.

In `M`-space this is the density

    f_M(m) = 1 / (m ln 2),    1 ≤ m < 2.

So departure from reciprocality is exactly the non-constant Fourier
content of the periodized `log₂` density.

---

## 4. Canonical binary coordinate change on one binade

On one binade `x ∈ [1,2)`, write

    m = x - 1 ∈ [0,1),
    t = log₂ x ∈ [0,1).

These are related by

    1 + m = 2^t.

Hence the canonical coordinate maps are

    ψ(m) = log₂(1+m),
    φ(t) = 2^t - 1,

with

    ψ = φ^{-1}.

These maps are the coordinate change between linear intra-binade position `m` and logarithmic intra-binade position `t` selected by binary representation.

---

## 5. Representation-native density in the log coordinate

Take the continuous idealization of uniform linear density on one binade:

    f_X(x) = 1,    1 ≤ x < 2.

Under the coordinate change `x = 2^t`, with `dx/dt = 2^t ln 2`, this becomes

    f_t(t) = 2^t ln 2,    0 ≤ t < 1.

Relative to the reciprocal regime `f_T(t) = 1`, define the defect

    δ(t) = 2^t ln 2 - 1.

This defect has mean zero on `[0,1]`:

    ∫_0^1 δ(t) dt = 0.

The mean-zero property is needed in §7–8: it ensures the accumulated
defect is periodic on the circle.

The defect `δ` is the representation-native departure from reciprocality,
expressed in log-binade coordinates.

---

## 6. Pseudo-log residual

The affine pseudo-log surrogate on `[1,2)` is

    L(x) = x - 1 = m.

The true log-binade coordinate is

    ψ(m) = log₂(1+m).

The residual is therefore

    ε(m) = ψ(m) - m = log₂(1+m) - m.

This is the error of replacing the canonical binary coordinate `ψ` by the
identity map on `[0,1)`.

### Endpoint exactness

At the binade endpoints,

    ε(0) = log₂(1) - 0 = 0,
    ε(1) = log₂(2) - 1 = 0.

The vanishing is an interpolation fact: `m` and `log₂(1+m)` agree at
`m = 0` and `m = 1`.

The location of the vanishing is the binade-lattice fact: these are the
seam points selected by the same `log₂ / mod-1` coordinate system. That
is, the pseudo-log's endpoint exactness occurs at the points where the
circle `[0,1)` is glued (§1).

---

## 7. Exact relation between density defect and pseudo-log residual

From the representation-specific defect,

    δ(t) = 2^t ln 2 - 1 = φ'(t) - 1,

we get the accumulated defect

    E(t) = ∫_0^t δ(w) dw
         = ∫_0^t (2^w ln 2 - 1) dw
         = (2^t - 1) - t
         = φ(t) - t.

Now substitute `m = φ(t)` and `t = ψ(m)`:

    E(t) = φ(t) - t = m - ψ(m) = -ε(m).

Equivalently,

    E(t) = -ε(φ(t)),
    E(ψ(m)) = -ε(m).

So the accumulated representation-native density defect in the `t`
coordinate is exactly the negated pseudo-log residual after the binary
coordinate change.

This is the project-specific instantiation of the generic template (§9).

---

## 8. Fourier form of the same relation

Because `δ` has mean zero (§5), the accumulated defect `E` is periodic on
the circle. By the generic Fourier multiplier (§9), for `n ≠ 0`:

    Ê(n) = δ̂(n) / (j 2π n).

Combined with `E(t) = -ε(φ(t))` from §7, this relates the Fourier
coefficients of departure from reciprocality to the pseudo-log residual.

The multiplier is generic antidifferentiation (§9). What is specific to
this project is that the `δ̂(n)` being divided are the Fourier coefficients
of the binary representation-native defect `δ(t) = 2^t ln 2 - 1`, and
the result after division is tied to `ε` through the canonical maps `φ`
and `ψ`.

---

## 9. Generic calculus template

Let `φ: [0,1] → [0,1]` be a `C^1` increasing bijection with

    φ(0) = 0,
    φ(1) = 1.

Define the source-coordinate defect

    δ_φ(t) = φ'(t) - 1,

and its accumulated error

    E_φ(t) = ∫_0^t δ_φ(w) dw.

Then

    E_φ(t) = φ(t) - t.

For `n ≠ 0`, the Fourier coefficients satisfy

    Ê_φ(n) = δ̂_φ(n) / (j 2π n).

This is a generic calculus/Fourier fact for endpoint-fixing coordinate
changes.

If one transports uniform measure `dt` on the source interval through the
change of variable `y = φ(t)`, then:

- in source coordinates, the Jacobian weight is `φ'(t) dt`;
- in target coordinates, the pushed-forward density is

      1 / φ'(φ^{-1}(y)).

This section is only a template. By itself it does not distinguish the
binary case. In the binary case, `φ(t) = 2^t - 1`, `ψ(m) = log₂(1+m)`,
`ε(m) = ψ(m) - m`, and the instantiation is §7.

## Background sources

The reciprocal density characterisation in §3 is due to Sripad & Snyder
(1978), Proposition 2. The dyad-boundary continuity condition underlying
§§5–6 is due to Lacroix & Hartwig (1992), §IV. The mod-1 convergence
criterion used implicitly in §2 is due to Miller & Nigrini (2007),
Theorem 1.1. Detailed reading notes for all three are in
[REFERENCES](REFERENCES.md).
