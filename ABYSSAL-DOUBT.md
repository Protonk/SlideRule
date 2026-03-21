# Abyssal Doubt

Can't get to islands without going over water

---

## 1. The algebraic fan-out problem

The keystone thesis says: the logarithm is the canonical coordinate,
the geometric grid is the zero-cost baseline, and scale symmetry
organizes everything. Steps 1–4 of DISTANT-SHORES build on this
cleanly. But the FSM — the architecture we chose to *correct* the
surrogate — does not share the symmetry it is correcting for.

The FSM processes bits sequentially. Its first layer splits the domain
in half by the leading bit. Its second layer splits each half again.
This is a binary tree decomposition: algebraic, discrete, rigid. The
function it is trying to correct — the residual ε(m) = log₂(1+m) − m
— is smooth, self-similar, and organized by scale symmetry. The FSM's
fan-out topology does not match this structure.

The displacement analysis (2026-03-21) makes this concrete. Layer 0's
delta must serve all 2^d cells with a single correction pair. No
single pair works well for all of them, so it imposes a systematic
positional displacement that cascades through subsequent layers. Later
layers have finer sharing granularity but cannot fully undo the
distortion, because their own sharing constraints are also binary, not
log-equivariant. The wall is dominated by this early-layer fan-out; the
residual LD wall shows that the deeper path algebra and automaton
coupling continue the pattern at finer scales.

This matters for the roadmap because:

**Step 5 asks whether the projection distance scales predictably with
structural cost.** But if the dominant wall source is a topological
mismatch between the correction architecture and the function's
symmetry, then the (C, gap) curve is not measuring the cost of
approximation — it is measuring the cost of *forcing a binary tree to
imitate a logarithm*. The exchange rate would be FSM-specific in a
deep sense, not just in the trivial sense that different architectures
have different constants.

**Step 6 asks whether the cost measure is architecture-invariant.** The
fan-out problem suggests it might not be. If the wall is dominated by
topological mismatch rather than by the intrinsic difficulty of
correcting ε, then the FSM's curve tells us about the FSM, not about
the problem.

The wall may be measuring the wrong thing for the purposes of
steps 5 and 6. If the dominant contribution to the wall is
architecture-specific rather than problem-intrinsic, then:

- A scaling law fitted to FSM (C, gap) data may not generalize.
- The "computational ruler" may have tick marks that depend on which
  ruler you pick up, defeating the universality claim.
- The path from steps 1–4 (which are clean and architecture-neutral)
  to steps 5–6 (which require architecture-invariance) may have a
  gap that no amount of FSM data can bridge.

### Why not just build a log-equivariant architecture?

One natural response: build an architecture whose sharing topology
matches the logarithm's self-similarity. A "tree automaton with
log-equivariant branching" that splits the domain at geometric
boundaries rather than binary ones.

This is circular. Such an architecture would need to decompose
along powers of 2^(1/N) rather than at binary digit boundaries.
But then it is no longer processing the bits of a number — it
is processing a different representation. And if you already have
a representation that decomposes along log-equivariant lines, you
have already solved the approximation problem at the representation
level. The geometric grid *is* the log-equivariant decomposition.
The whole point of the FSM is to bridge from the binary
representation you are given to the logarithmic structure you want.
An architecture that starts from the log-equivariant decomposition
doesn't need to bridge anything.

### The deeper version of the doubt

This means the fan-out problem may not be an accident of choosing
FSMs. It may be an unavoidable cost of starting from a binary
representation and trying to reach a logarithmic target. Any
correction architecture that processes binary digits will face some
version of the leading-bit fan-out, because the leading bit is the
coarsest partition of the domain and it is algebraic (splits at the
midpoint), not geometric (splits at the geometric mean). The mismatch
between binary and logarithmic is baked into the starting point, not
the correction strategy.

If that is true, the doubt is simultaneously more serious and more
interesting than the FSM-specific version:

- More serious: the wall cannot be escaped by switching architectures,
  because every binary-representation architecture inherits the same
  leading-bit fan-out.
- More interesting: the wall would then be measuring something real
  about the cost of correcting a binary surrogate toward a
  logarithmic truth. That is actually closer to what the computational
  ruler *wants* to measure than the FSM-specific reading suggests.

The question flips: is the wall an artifact of the FSM, or is the
FSM faithfully measuring a cost that any binary-to-logarithmic
correction must pay? In the first case, the ruler is broken. In the
second case, the ruler works but what it measures is the
binary-to-log gap, not a universal approximation cost.

Either outcome is informative. Neither is fatal to the project. But
they lead to very different versions of steps 5 and 6.

### What would resolve it

1. **A second binary-representation architecture.** Not a
   log-equivariant one (that's circular), but another architecture
   that also processes binary digits and shares structure across
   cells — such as De Caro's shared-coefficient piecewise
   polynomials. If its (C, gap) curve aligns with the FSM curve
   after normalization, the wall is a binary-representation cost,
   not an FSM cost, and the ruler measures something real about the
   binary-to-log gap. If the curves diverge, the wall is genuinely
   FSM-specific and step 6 must be narrowed.

2. **A lower bound.** A minimax lower bound on shared-structure
   approximation of ε from binary representations, matching the
   observed wall magnitude. This would prove the wall is
   representation-intrinsic regardless of architecture.

3. **Fan-out scaling data.** If the layer-0 displacement range
   stabilizes with depth (approaches a constant rather than growing
   with 2^d), the fan-out cost is bounded and additional states can
   in principle absorb it. The wall would be a finite allocation
   problem. If it grows, the cost is structural and permanent.
   This is testable now.
