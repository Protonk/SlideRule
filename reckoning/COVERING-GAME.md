# Covering Game

The mathematical program for proving that the computational ruler is
architecture-invariant. This document describes the proof strategy.
The hazards of the passage are in
[DANGEROUS-SHOALS](DANGEROUS-SHOALS.md).

---

## 1. A covering game on hybrid partitions

The displacement field Δ^L organises the free intercept field c*
across the tested partition families. The covering question is:
can a *composite* partition — cells 0–15 from family A, cells 16–31
from family B, chosen adversarially — achieve locally competitive
performance on every cell simultaneously without paying more than
the ε-organised baseline?

If no such composite exists (or exists only at bounded excess cost),
then the optimality of the ε-organised structure is a property of
the problem geometry, not of the correction method. The set-cover
framing applies: for fixed N, measure each zoo partition's signed
per-cell deviation from geometric, and ask how many families are
needed to cover all cells with locally competitive performance.

This game must be made precise. "Locally competitive" needs a
quantitative threshold. The cost of surgery — gluing cells from
different families — must be commensurable with the cost of splitting
and slope-choosing within a single family. If these two costs live
in different units, the game proves nothing.

## 2. A coordinate change, not a metaphor

The project has a geometric measure (displacement from the
ε-organised baseline, Δ^L) and a computational measure (parameter
count, sharing depth, automaton topology). Right now they are
connected by empirical correlation. The crossing requires showing
that the translation between them is a genuine coordinate change:
a bound proved in one system is automatically a bound in the other.

The suspicion: the correction task — mapping a d-bit prefix to a
near-optimal δ — is a function from {0,1}^d to ℝ. Its complexity
is controlled by the information content of the target vector δ*,
which is in turn controlled by the shape of ε. Two avenues:

**Branching programs.** The FSM is a branching program of width q
and depth d. Lower bounds on branching program size for computing
certain functions would, if the correction function falls in the
right class, give a lower bound on the wall that references Δ^L
but not the FSM. The staircase becomes a forced consequence of the
function's structure under any width-bounded sequential reader of
binary digits.

**Communication complexity.** The binary representation encodes
position in one coordinate system. The optimal correction lives
in another. Any architecture that reads binary digits and outputs
corrections is performing a coordinate translation. The minimum
cost of that translation is bounded below by something intrinsic
to the two coordinate systems — which is Δ^L, again. The bound
does not care what sits between input and output.

Either route would make the computational ruler a duality: geometry
on one face, complexity on the other, readings locked together by
the coordinate change.

## 3. The covering game as the arena for the proof

The covering game is where the coordinate change gets tested. It
asks: can any combination of strategies beat the ε-organised
baseline? If the answer is no, geometric structure controls
computational cost, and the two measures are locked. If the answer
is "yes, but only at bounded cost controlled by Δ^L," that is
almost as good — it localises the slack and bounds the leakage.

The existing infrastructure does not support this. Evaluating hybrid
partitions (cells drawn from different families, optimised jointly)
requires new code. The measure-theoretic formulation needs to
distinguish "optimal against surgery" from "optimal against
everything," which is a stronger claim than Step 6 needs and a
weaker claim than we might be tempted to make.

---

## Risks specific to this program

### The coordinate change might not exist

The suspicion that branching program or communication complexity
bounds apply to the correction function is currently unsupported.
These are hard theorems to prove for specific functions. The
correction function may fall in an intermediate regime where
existing tools give only trivial bounds. The shape of ε is smooth
and structured, which is good for some lower-bound techniques and
bad for others.

If the coordinate change turns out to be merely approximate — "the
geometric measure predicts the computational cost to within a
constant factor" — that may still be useful, but it is a weaker
result and it will be tempting to paper over the gap.

### The covering game might prove less than we think

It is possible to win the covering game (no hybrid beats geometric)
and still not have Step 6, if the victory depends on properties of
the partition families tested rather than on the structure of Δ^L.
The zoo is large but finite. An adversary not in the zoo might
behave differently. The game needs to be formulated so that its
conclusion references the forcing function, not the participants.

### Commensurability is hard

Making the cost of partition surgery commensurable with the cost of
within-partition slope choice is not a bookkeeping exercise. It
requires a single cost currency in which both operations have
well-defined prices. If the currency is parameter count, surgery
might be free (just reassign cells). If the currency is entropy of
the correction vector, surgery has a definite cost (the description
complexity changes). The choice of currency determines what the
game can prove.

---

## Operational rules

1. **Formulate before attempting.** Write the precise definitions —
   what is a hybrid partition, what is the cost currency, what
   constitutes "locally competitive" — before running any code. If
   the definitions are not clean, the game will prove whatever we
   want it to prove.

2. **Test with an adversary designed to beat it.** Construct the
   hybrid partition most likely to refute the claim, optimise it
   honestly, and report the result. If the adversary cannot be
   constructed, explain why — that explanation may be the proof.

---

## Reading outward

- [DANGEROUS-SHOALS](DANGEROUS-SHOALS.md): the broader passage and
  its hazards.
- [DISTANT-SHORES](DISTANT-SHORES.md): the destination (d_comp).
- [TRAVERSE](TRAVERSE.md) Steps 5–6: the scientific context.
- [POINCARE-CURRENTS](POINCARE-CURRENTS.md): the displacement field
  the covering game operates on.
- [KEYSTONE](../experiments/keystone/KEYSTONE.md) §4: the
  compatibility argument the crossing would complete.
