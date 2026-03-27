# SCYLLA

The corona-aliasing argument of Dragon 7 applies to machines
with finite total configuration space M. A machine with M
configurations can distinguish at most M local types at a
given depth. The Böröczky corona count grows as 2^{k−1},
which outruns M for every finite M.

A natural objection: allow the machine unbounded real-valued
accumulation. A single-state machine reading bits b₁, …, b_d
and computing

    S = Σ_{j=1}^{d}  δ_j · b_j

with δ_j drawn from any fixed alphabet produces up to 2^d
distinct outputs. This outruns the corona count. The aliasing
argument does not apply.

This document follows the objection to its conclusion.

---

## §1. The machine

Fix a positive integer d. The machine reads a binary string
(b₁, b₂, …, b_d) ∈ {0,1}^d. It has one control state and
one real-valued register, initialized to zero. At step j it
adds δ_j · b_j to the register, where δ_j is a fixed real
number depending only on j. After d steps the register holds

    S(b₁, …, b_d) = Σ_{j=1}^{d}  δ_j · b_j .

The machine has one state. It has no finite-configuration
bound. For generic choices of (δ₁, …, δ_d) the map
(b₁, …, b_d) ↦ S is injective, producing 2^d distinct
output values.

## §2. The natural weights

The input string (b₁, …, b_d) is the binary significand of
a floating-point number x in the binade [1, 2). The
relationship is

    x = 1 + Σ_{j=1}^{d}  2^{−j} · b_j .

Set δ_j = 2^{−j}. Then

    S = Σ_{j=1}^{d}  2^{−j} · b_j  =  x − 1  =  m_x ,

the mantissa of x. This is the most natural choice: each
bit contributes at its positional weight.

## §3. What the machine has computed

The pseudo-logarithm of x ∈ [1, 2) is defined by

    L(x) = ⌊log₂ x⌋ + m_x .

On [1, 2), the exponent ⌊log₂ x⌋ = 0, so L(x) = m_x.

The machine with δ_j = 2^{−j} computes L(x) exactly on
the binade [1, 2). It reads d bits and produces the
pseudo-logarithm without error, for every d.

For x in a general binade [2^E, 2^{E+1}), the exponent E
is determined by the binade and can be obtained separately.
The machine's output m_x, together with E, gives L(x) = E + m_x.

## §4. The gap

The true logarithm of x ∈ [1, 2) is log₂(x) = log₂(1 + m_x).
The machine has produced m_x. Define

    ε(m) = log₂(1 + m) − m,    m ∈ [0, 1).

Then

    log₂(x) = L(x) + ε(m_x) .

The machine has L(x). It does not have log₂(x). The
difference is ε(m_x).

## §5. Properties of ε

ε(0) = 0.

ε(m) → 0 as m → 1.

ε is strictly positive on (0, 1): for m ∈ (0, 1),
log₂(1 + m) > m because log₂(1 + m) is concave and
agrees with m at m = 0 with a steeper initial slope
(d/dm log₂(1+m)|_{m=0} = 1/ln 2 > 1).

ε has a unique maximum at m* = 1/ln 2 − 1 ≈ 0.4427,
where ε(m*) = log₂(e) − 1/ln 2 ≈ 0.0861.

ε is concave on [0, 1).

These are properties of ε as a function. They do not depend
on d, on the machine, or on any choice of correction method.

## §6. Using the output

Suppose the machine's purpose is to approximate x^{−a/b}
for fixed positive integers a, b (the setting of Day [2023]).
The machine has computed m_x, which gives L(x). The
algorithm proceeds:

    X = L(x) = E_x + m_x

    Y = c/b − (a/b)X

    y = L^{−1}(Y) = 2^{⌊Y⌋}(1 + (Y − ⌊Y⌋}))

The value y is a coarse approximation to x^{−a/b}. It is
obtained from L(x) by one linear map and one inverse
pseudo-log evaluation. These are exact operations on the
bit representation: an integer multiply-and-shift, an
integer subtraction, and a bit reinterpretation.

The constant c parameterizes the linear map. Its value
affects the quality of the coarse approximation but not its
cost.

## §7. Measuring the coarse error

Define the auxiliary

    z(x) = x^a · y(x)^b .

If y were exactly x^{−a/b}, then z would equal 1 everywhere.
The deviation of z from 1 measures how far the coarse
approximation y is from the target.

Day shows that z is a bounded, continuous, periodic function
of L(x) with period b. Its range is a closed interval
[z_min, z_max] determined entirely by c and the pair (a, b).

Define ρ = z_max / z_min. The ratio ρ depends on c. The
optimal c is the one that minimizes ρ.

## §8. Correcting the coarse approximation

The exact correction factor is g(x) = z(x)^{−1/b}. If the
machine could evaluate g exactly, it would produce x^{−a/b}
without error. It cannot, because g involves a fractional
power, which is exactly the function the algorithm exists to
approximate.

Instead, the machine evaluates a polynomial p(z) of fixed
degree n and returns y · p(z) as the refined approximation.
The relative error is

    e(x) = (z^{−1/b} − p(z)) / z^{−1/b} .

This is the relative error of approximating the function
z^{−1/b} by a degree-n polynomial on the interval
[z_min, z_max].

## §9. The minimax error

By standard approximation theory (Chebyshev, Remez), for
every finite degree n and every interval [z_min, z_max] with
z_min < z_max, the minimax relative error

    ε_n^* = min_{deg p ≤ n}  max_{z ∈ [z_min, z_max]}
            |z^{−1/b} − p(z)| / z^{−1/b}

is strictly positive. The function z^{−1/b} is not a
polynomial (it is algebraic of infinite polynomial degree
for b ≥ 2, and transcendental in related formulations).
No finite-degree polynomial reproduces it exactly on any
interval of positive length.

ε_n^* depends on ρ and n. It does not depend on d. It
does not depend on how many distinct values of z the machine
can produce. A machine that distinguishes all 2^d values of
z and evaluates p(z) at each one incurs worst-case error
ε_n^* at some z in the interval.

## §10. What the unbounded accumulator bought

The machine with δ_j = 2^{−j} computes m_x exactly. This
gives L(x) exactly. This gives z(x) exactly (given c, a, b).
The machine resolves all 2^d values of z without aliasing.

None of this reduces ε_n^*. The error is set by the degree
of p, not by the resolution of z.

To reduce ε_n^*, the machine must increase n (more
multiply/add operations with more fixed constants), or
change the correction architecture (piecewise polynomial,
lookup table, different iteration family). Each of these
costs additional fixed resources.

## §11. The structure of the cost

The cost of reducing ε_n^* below a target τ is:

At degree n = 0: p(z) = c₀, a single constant. The error
is determined by ρ alone.

At degree n = 1: p(z) = c₀ + c₁z. Two constants, one
multiply, one add. This is the standard FRSR with one
Newton-Raphson step. The error is ε_1^*(ρ).

At degree n = 2: three constants, two multiplies, two adds.
Householder's method or a quadratic minimax polynomial. The
error is ε_2^*(ρ).

At each degree, the optimal c changes: the magic constant
and the polynomial are co-optimized through ρ(c). The
cost of the constant and the cost of the polynomial are not
separable.

The sequence ε_0^*(ρ) > ε_1^*(ρ) > ε_2^*(ρ) > ⋯ is
strictly decreasing and converges to 0 as n → ∞. The
convergence rate depends on the smoothness of z^{−1/b} on
[z_min, z_max], which depends on ρ, which depends on c.

## §12. Where the wall is

The machine with unbounded accumulation and a degree-n
correction polynomial has:

- Zero error in computing L(x).
- Zero error in computing z(x).
- Nonzero error ε_n^*(ρ(c*)) in approximating z^{−1/b}
  by p(z).

The wall is not in the accumulation. It is not in the
computation of L. It is not in the resolution of z. It is
in the approximation of a non-polynomial function by a
polynomial of finite degree on a bounded interval.

The bounded interval is [z_min, z_max]. Its width ratio ρ
is controlled by c, which is controlled by ε: the extrema of
z occur where the pseudo-log line crosses integer grid
boundaries (Day, Section 4.3), and those crossings are
determined by the deviation of L from log₂.

The function being approximated is z^{−1/b}. The difficulty
of approximating it on [z_min, z_max] is set by ρ, which
is set by the grid crossings, which are set by ε.

The correction cost is a functional of ε, mediated by ρ.

## §13. The pseudo-logarithm

The machine computes L(x) for free: the bit representation
gives it without arithmetic. The gap ε(m) = log₂(1+m) − m
is what remains. Every correction architecture — polynomial,
piecewise, lookup, iterative — spends its resources reducing
ε's contribution to the final error.

L is the unique piecewise-linear function that agrees with
log₂ at every power of 2 and is determined entirely by the
binary significand. Any other piecewise-linear approximation
to log₂ that uses the same bit-level addressing reproduces L
or is more expensive to compute.

The machine that escapes the corona-aliasing bound does so
by computing L exactly. Having computed L, it faces ε. The
resources it spends on ε are the wall.

---

## Status

§§1–5: definitions and elementary properties.

§§6–9: follows Day [2023], Sections 3–4.4, specialized to
the FRSR case where needed and stated in general where
possible.

§§10–12: consequences of §§6–9 for the unbounded
accumulator objection. No novel claims; the argument is
that the objection and the wall address different stages
of the computation.

§13: interpretive. States what L is and what ε is. Does not
prove any claim about optimality or uniqueness beyond the
piecewise-linear observation.

## Reading outward

- Dragon 7 in [HERE-BE-DRAGONS](HERE-BE-DRAGONS.md): the
  corona-aliasing argument for finite-configuration machines.
- [NARROW-PASSAGE](NARROW-PASSAGE.md): the correction task
  as connection-flattening.
- [ROARING-40s](ROARING-40s.md): three residuals, one object.
- Day [2023], arXiv:2307.15600: the FRGR framework.
