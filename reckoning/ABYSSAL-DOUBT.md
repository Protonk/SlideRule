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

---

## 2. The forcing-residual gap

Δ^L = −ε organises c* — the *target* the shared optimizer is aiming
at. T3 confirms this across the partition zoo. But the wall is not
the target. The wall is `dist(δ*, S)`: the distance from the target to
the achievable subspace. That distance depends on two things — the
target and the subspace — and the forcing function only tells you
about one of them.

ε tells you where you're going. It does not tell you how far it is
from where you are. "Where you are" is determined by the
architecture's sharing topology — the subspace S. Two architectures
aiming at the same δ* from different subspaces will have different
walls, and the difference has nothing to do with ε.

This is nastier than it looks. Step 5 says the (C, gap) curve should
be a staircase whose stair *locations* are set by Δ^L. But the stair
locations are set by which cells bind the minimax — which cells sit at
the frontier of the absorbed region. That frontier depends on the
angle between δ* and S, not on δ* alone. ε could perfectly organise
the target and still have zero predictive power over the wall, if the
wall is dominated by the geometry of S. The 33% partition-dependent
variance in the tiling analysis is an early signal: it's exactly the
part of the wall that ε doesn't explain.

The forcing organises the landscape. The wall measures the distance
across it. These are not the same thing.

---

## 3. The exactness trap

Step 1 of DISTANT-SHORES presents the triangle inequality as the
foundation: `|APPROX − log₂| ≤ |APPROX − L| + |L − log₂|`. The
decomposition is exact. The two terms share no degrees of freedom.
This seems like bedrock.

But examine what the experimental program actually does. Steps 3–6
compute walls by LP optimization, measuring `opt_err − free_err`
directly. The LP never references the triangle inequality. It doesn't
decompose error into "computable part plus known budget" — it solves
for the best shared correction and reports the gap. The wall
decomposition (parameter budget / layer sharing / automaton coupling)
comes from comparing LP solutions at different sharing levels. None of
this passes through Step 1.

Step 1 provides a *conceptual frame*: "ε is the budget, corrections
are withdrawals against it." But the actual measurements don't use
this accounting. The triangle inequality is tight only when APPROX is
worse than L everywhere — i.e., when the correction makes things worse
at every point. Any correction that works at all produces partial
cancellation between the terms, making the bound loose. The better the
approximation, the looser the inequality. The foundation is most exact
when it is least useful.

If you removed Step 1 from DISTANT-SHORES, Steps 2–6 would proceed
unchanged. The geometric baseline, the subspace story, the wall, the
exchange rate — none depend on the triangle decomposition. The
"exactness" is real but may be load-bearing nothing. And if the
conceptual foundation of the program is decorative rather than
structural, the question is what the program's actual foundation is —
and whether it has one.

---

## 4. The subspace is chosen, not discovered

Step 3 derives an achievable set (S) from a chosen finite correction model. (S) is therefore not a fact about the approximation problem alone. It is a fact about the model together with its access pattern to the input and its rule for reusing parameters. Change the model, and (S) changes.

The wall, as defined, is then not the cost of correcting (\varepsilon) in the abstract. It is the cost of correcting (\varepsilon) under one particular sharing discipline.

### 4a. The description of (S) does not yet match the burden placed on it

Step 3 shows that (S) is the image of a linear map and gives its size in terms of the model parameters. That identifies a budget and a sharing pattern. It does not characterise (S) geometrically in the sense needed here: which directions it contains, which it excludes, and why those exclusions line up with the observed wall.

This matters because equal dimension does not imply equal approximation power, and nesting does not explain orientation. Two achievable sets can have the same parameter count and very different distances to (\delta^*).

One can see this with an ideal lookup-table. At fixed depth (d), a full table yields (S=\mathbb{R}^{2^d}), so the wall relative to that discretisation is zero. This does not remove the computational burden but it **neatly** removes sharing by assigning one degree of freedom to each cell, making the present description of (S) too thin for the conclusion being drawn from it. It tells us how one model shares. It does not yet tell us what class of finite realisers the problem belongs to, nor which computational features of those realisers govern the gap.

### 4b. The forcing correlation may be only a target correlation

(\Delta^L=-\varepsilon) organises the target (\delta^*). The wall is (\mathrm{dist}(\delta^*,S)). A correlation between the wall and (\varepsilon) therefore does not by itself show that (\varepsilon) governs the wall. It may show only that (\varepsilon) governs the target, while the chosen achievable set (S) governs what part of that target can be reached.

On that reading, the wall inherits (\varepsilon)-structure because a structured target is being measured against a particular finite model. The forcing organises the demand. The model determines what can be supplied. These are not the same claim.
