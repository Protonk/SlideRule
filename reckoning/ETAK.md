# Etak

Four links from the wall to algebraic independence. This is the
horizon map. [TRAVERSE](TRAVERSE.md) is the route: its Steps 8–11 are
the work items corresponding to Links 1–4 here.

The name is from Polynesian navigation: etak is the reference island
that appears to move as you sail, though it is stationary. The
reference island here is ε. Each link says what ε would have to mean,
at increasing range, for the project to reach shore.

The zero-state base point for this horizon is Minkowski's question
mark function ?(x): the singular binary-to-geometric translation with
no computational resources at all. Every finite corrector would then
be spending structure to buy back part of what that singularity loses.

The links are ordered by decreasing confidence. Each records:

- the claim;
- ε's role in that claim;
- the load-bearing joint;
- the payoff if the link holds.

---

## Link 1. The wall is necessary

**Claim.** No finite-state machine reading binary digits can
exactly correct the pseudo-log. The wall is nonzero for any
finite corrector.

**ε-role.** ε is the coordinate-level residue of the mismatch
between additive and multiplicative subdivision. If Link 1
holds, the wall is the finite-capacity shadow of that same
singular mismatch.

**Load-bearing joint.** ?(x) is the canonical singular map
between binary expansion and continued-fraction expansion. The
project's correction task lives on the same additive vs.
multiplicative split: binary midpoint subdivision against
geometric-mean subdivision. The joint that must be checked is:
does exact finite correction force an absolutely continuous
coordinate change between those addressing systems? The FSM
outputs real-valued corrections, not a measure, so "factors
through" is the phrase that needs precise formulation.

**Status.** The singularity of ?(x) is classical (Salem, 1943;
Kinney, 1960). The transfer from exact correction to absolute
continuity is not yet proved.

**What this gives the project.** If Link 1 holds, the wall
is not an empirical observation about FSMs. It is a theorem.
The wall exists because the map between additive and
multiplicative structure is singular, and singularity is
preserved under finite-state composition.

**Traverse.** [TRAVERSE](TRAVERSE.md) Step 8.

---

## Link 2. The wall's decay rate encodes the spectral structure of the singularity

**Claim.** As q (states) grows, the wall shrinks. The rate of
shrinkage is controlled by how many spectral modes of the
singular map the machine can absorb. The modes are the
Fourier/Walsh coefficients of ε, which are the spectral
fingerprint of ?(x)'s singularity.

**ε-role.** ε is the candidate spectral object. Its
Fourier/Walsh content is the proposed ruler against which wall
decay is measured.

**Load-bearing joint.** ε is smooth and explicit, with
circle-Fourier coefficients decaying as O(1/n²). The missing
step is not the analysis of ε itself, but the theorem that the
machine's finite sharing constraints correspond to absorbing a
controlled amount of that spectral content. The Schatte link is
suggestive background: additive procedures incur summability
costs when they are forced to respect multiplicative structure.
The project still needs the direct bridge from FSM sharing to
spectral absorption.

**Status.** The spectral characterization is conjectural. The
Schatte connection is speculative. The claim that the FSM's
sharing constraints are approximately aligned with the Fourier
basis of Δ^L is an empirical question that the existing
infrastructure could test but has not yet tested.

**What this gives the project.** If Link 2 holds, the
computational ruler's tick marks are not set by the machine.
They are set by the spectral content of the singular map. The
ruler measures how fast finite branching programs can locally
smooth a singularity, mode by mode.

**Traverse.** [TRAVERSE](TRAVERSE.md) Step 9, fed by Steps 3–7.

---

## Link 3. The coefficient decay is controlled by the Diophantine properties of ln 2

**Claim.** The rate at which the Fourier coefficients of ε
decay — equivalently, how smooth the singularity of ?(x) is
in the spectral sense — is determined by how well ln 2 can be
approximated by rationals.

**ε-role.** ε is where the arithmetic would become visible.
If Link 2 succeeds, its spectral tail is the object whose decay
rate could reflect the irrationality type of ln 2.

**Load-bearing joint.** The continued fraction of ln 2 governs
near-commensurabilities between additive and multiplicative
lattices. The unproved step is the passage from those
near-commensurabilities to actual control of ε's spectral tail.
Baker's theorem constrains linear forms in logarithms; the
project still needs the bridge from irrationality measure to
coefficient decay, and then from coefficient decay to ruler
tick marks.

**Status.** The connection between Diophantine properties of
ln 2 and the spectral content of ε is not established. It is
a natural conjecture given the role of ln 2 in controlling
the incommensurability that generates both ?(x)'s singularity
and ε's shape. The Baker bound is classical. The specific
chain — Baker → irrationality measure → coefficient decay →
ruler tick marks — is unworked.

**What this gives the project.** If Link 3 holds, the
computational ruler is a measuring instrument for the
Diophantine properties of the exponential. Its tick marks
encode how incommensurable addition and multiplication are,
frequency by frequency. This is intrinsic: it depends on the
numbers, not the machine.

**Traverse.** [TRAVERSE](TRAVERSE.md) Step 10.

---

## Link 4. The ruler's structure is incompatible with algebraic dependence

**Claim.** If d_comp(τ) has a functional form whose structure
requires that no polynomial relation P(2, e) = 0 exists, then
the ruler is a computational proof of the algebraic
independence of 2 and e (a case of Schanuel's conjecture).

**ε-role.** ε would no longer just expose a gap. Through the
ruler, it would expose arithmetic structure strong enough to
distinguish algebraic dependence from independence.

**Load-bearing joint.** The project would have to show that
the staircase of d_comp really encodes arithmetic data, not
just machine behavior. Only then does the final leap become
meaningful: an algebraic relation P(2, e) = 0 would have to
force a visible regularization in the ruler, for example by
collapsing or terminating steps that should otherwise persist.

**Status.** This is the leap. Nothing in the current project
approaches it. The specific mechanism — algebraic relation →
regularization of singularity → collapse of staircase step —
is a conjecture about the structure of a conjecture. It would
require showing that d_comp is sensitive enough to detect
arithmetic structure at all, which in turn demands tight
control over all three preceding links.

**What this gives the project.** If all four links hold, the
project has arrived at Schanuel's conjecture through
computation, measure theory, and approximation complexity
rather than through algebraic number theory. The exponential's
algebraic independence from the rationals would be witnessed by
the non-termination of a computational process: no finite
machine can close the gap, the gap's spectral structure encodes
the Diophantine type of ln 2, and that Diophantine type is
incompatible with algebraic dependence.

**Traverse.** [TRAVERSE](TRAVERSE.md) Step 11.

---

## Reading outward

- [TRAVERSE](TRAVERSE.md): the route; Steps 8–11 are the work
  items for Links 1–4.
- [NARROW-PASSAGE](NARROW-PASSAGE.md): the three-partition
  framework (Part I) and the spectral characterization (Part II §8).
- [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md) §5: the non-factoring
  conversion doubt, which threatens Links 2–3.
- [INTERRUPTED-LOG](INTERRUPTED-LOG.md): the Step-5 zoo-surgery
  stress test.
- [COMPLEXITY-REEF](COMPLEXITY-REEF.md): the branching program
  lower bound question.
- [HERE-BE-DRAGONS](HERE-BE-DRAGONS.md): Dragons 1, 4, 6 as
  the geometric precursors.

## Sources

- Minkowski, H. "Zur Geometrie der Zahlen." Verhandlungen
  des III. internationalen Mathematiker-Kongresses, Heidelberg,
  1904.

- Salem, R. "On some singular monotonic functions which are
  strictly increasing." Trans. Amer. Math. Soc. 53 (1943),
  427–439.

- Kinney, J. R. "Note on a singular function of Minkowski."
  Proc. Amer. Math. Soc. 11 (1960), 788–794.

- Baker, A. "Linear forms in the logarithms of algebraic
  numbers." Mathematika 13 (1966), 204–216.

- Schatte, P. "On mantissa distributions in computing and
  Benford's law." J. Inform. Process. Cybernet. 24 (1988),
  443–455.

- Böröczky, K. "Gömbkitöltések állandó görbületű terekben I."
  Mat. Lapok 25 (1974), 265–306.

- Radin, C. "Orbits of Orbs: Sphere Packing Meets Penrose
  Tilings." Amer. Math. Monthly 111 (2004), 137–149.
