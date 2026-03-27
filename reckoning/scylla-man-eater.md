# SCYLLA aftertaste: a narrower and more dangerous claim

SCYLLA does not save the old theorem target. It improves it.

The weak target was: finite control cannot resolve enough local types, therefore a wall must remain. That target is now dead in the machine class that matters. An unbounded accumulator can read the bit string with positional weights, recover the mantissa exactly, and therefore recover the affine pseudo-log exactly on the binade. If the claim had really been about finite control *as such*, SCYLLA would have killed it.

Good. It should die.

Because the real object was never “finite control” in the abstract. The real object was the cost of correcting the additive surrogate into the multiplicative truth. SCYLLA strips away a false bottleneck and leaves the hard residue exposed.

## 1. What survives the objection

Once the machine is allowed to compute

- the mantissa exactly,
- hence `L(x)` exactly,
- hence the coarse-stage variable `z(x)` exactly,

there is still a nontrivial problem left. The remaining task is to realize the correction from `L` to `log₂`, or equivalently from the coarse stage to the target, using a bounded correction family.

That residual task is not a bookkeeping nuisance. It is the computation.

So the post-SCYLLA question is not:

> can a finite machine distinguish enough addresses?

It is:

> after the address has already been resolved for free, what bounded corrective structure is required to absorb the displacement field `Δ^L = -ε` to a given tolerance?

That is a better question. It is less model-fragile, more architectural, and closer to the real source of cost.

## 2. The corrected meaning of the wall

The wall should no longer be framed as a generic consequence of state aliasing. That is too weak, and in the unbounded-accumulator setting it is false.

The wall is instead the residual forced by **bounded correction architecture after free pseudo-log extraction**.

That one sentence does several things at once.

First, it concedes SCYLLA completely. The machine may know the binary address perfectly. It may know `m`. It may know `L`. None of that closes the gap.

Second, it identifies the actual source of difficulty: not access to the bits, but the bounded family of functions permitted to act on what the bits reveal.

Third, it moves the project from an FSM-specific obstruction to an **architecture-sensitive complexity question**. Polynomial correction, piecewise polynomial correction, lookup tables, iterative schemes, shared-parameter families, and other bounded mechanisms can now be compared on common ground: what class of corrective action do they realize against `ε`?

That is a substantial upgrade in sharpness.

## 3. Why this helps ETAK

ETAK's useful content was never the literal wording of Link 1. Its useful content was the hope that the wall is not merely an accident of one impoverished model, but the visible trace of a deeper mismatch between additive and multiplicative structure.

SCYLLA does not refute that hope. It disciplines it.

The disciplined version is:

> the wall is not caused by inability to *name* the cell; it is caused by the bounded cost of *repairing* the additive surrogate once the cell has already been named.

That is the form in which ETAK Link 2 becomes worth touching. If the machine's first job is free, then the ruler is not measuring address resolution. It is measuring how much of `ε` a bounded corrector can absorb.

That is already enough to change the program.

It means that any future “spectral ruler” claim should be stated against a corrected base point:

- zero-cost address resolution;
- explicit surrogate `L`;
- explicit displacement field `Δ^L = -ε`;
- bounded corrective family acting on that field.

Only in that normalized setting is it meaningful to ask whether wall decay tracks spectral content of `ε`, or whether different bounded families buy back different modes at different prices.

Without SCYLLA, that question is blurred by a fake front-end obstruction. With SCYLLA, it becomes legible.

## 4. Why this helps ROARING-40s

ROARING-40s wants an identification among three residuals:

1. the machine residual;
2. the Schatte/additive residual;
3. the Stern–Brocot/Padé residual.

In its loose form, that is too ambitious. The machine side was contaminated by the possibility that the observed wall was mostly a consequence of weak addressing.

SCYLLA removes that excuse.

Once `L` is free, the machine residual is no longer “whatever finite state fails to notice.” It is the residual left after exact binary addressing and exact surrogate extraction, when a bounded corrective family tries to repair the additive/multiplicative mismatch encoded by `ε`.

That does **not** prove the three residuals are one object. But it makes the first member of the trio precise enough to compare to anything else.

Before SCYLLA, ROARING's first residual was too entangled with machine weakness to serve as a clean comparison target.

After SCYLLA, the first residual becomes:

> the error left after bounded correction acts on the explicit displacement field induced by the additive surrogate.

That is finally a mathematically serious object.

## 5. The claim worth defending

Here is the version I would actually defend.

> SCYLLA shows that the corona-aliasing argument cannot be the final explanation of the wall. But it also shows that this failure is productive: once exact pseudo-log extraction is admitted, the remaining irreducible question is the complexity of bounded correction against `ε`. Therefore the wall should be reformulated as an architecture-sensitive lower bound on the cost of absorbing the representation displacement field `Δ^L = -ε`, not as a generic consequence of finite state.

This is narrower than the old claim and much harder to evade.

It does not say:

- that every bounded family has a nonzero wall;
- that the wall is already known to equal a spectral tail of `ε`;
- that ROARING's three residuals are already identified;
- that any arithmetic contradiction has been reached.

But it does say something real:

- the front end can be normalized away;
- the residue after normalization is explicit;
- the project's natural invariant is no longer “number of states” but “cost of corrective structure applied to `ε`.”

That is not a retreat. It is a purification.

## 6. The hard consequence

Once stated this way, the problem becomes more dangerous, not less.

A toy obstruction can be defeated by a clever accumulator. A correction-complexity obstruction cannot be dismissed so cheaply. It asks for a theorem of a different kind: not that the machine forgets, but that even after it remembers everything cheap to remember, a bounded corrective family still cannot flatten the mismatch for free.

That is the place where a genuine lower bound could live.

And if such a lower bound can be tied, even partially, to the spectral organization of `ε`, then ETAK stops being decorative. The ruler would no longer be counting states. It would be counting purchased repair of a specific displacement field.

That is the first version of the story that sounds like it might survive contact with mathematics.

## 7. The immediate program

The next work should be scoped to that corrected target.

1. Fix a correction family.
2. Normalize away address resolution by giving the machine `L` exactly.
3. Express the remaining task explicitly as correction of `ε`, or of the induced coarse-stage field.
4. Prove or estimate the residual as a function of bounded resources in that family.
5. Only then ask whether the residual's decay is organized by Fourier/Walsh content, by another basis, or by no spectral law at all.

Anything larger than this is still horizon talk.

This much is not.

## 8. Final sentence

SCYLLA does not show that the wall was illusory. It shows that the wall, if real, begins *after* the machine has already gotten the obvious part for free.
