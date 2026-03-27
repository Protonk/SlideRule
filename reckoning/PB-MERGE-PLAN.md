# PB Merge Plan

Merge POINCARE-CURRENTS into BINADE-WHITECAPS. One document for
the coordinate theory, the displacement field, the density defect
identity, and the staircase prediction.

---

## Why

BINADE-WHITECAPS derives ε from the coordinate theory
(representation side). POINCARE-CURRENTS derives Δ^L = −ε from
the grid displacement (geometric side). BINADE-WHITECAPS §7
proves they are identical. POINCARE-CURRENTS §6 references
BINADE-WHITECAPS §§7-8 for the Fourier coefficients. The
documents are already coupled at their load-bearing joints.

## Target structure

BINADE-WHITECAPS keeps its name and gains the displacement /
staircase material. New section numbering:

1. **Common coordinate** — current BW §1, unchanged.
2. **Periodized density on the circle** — current BW §2,
   unchanged.
3. **Reciprocal mantissa** — current BW §3, unchanged.
4. **Canonical binary coordinate change** — current BW §4,
   unchanged.
5. **Representation-native density** — current BW §5, unchanged.
6. **Pseudo-log residual** — current BW §6, unchanged.
7. **Density defect and pseudo-log residual** — current BW §7,
   unchanged.
8. **Fourier form** — current BW §8, unchanged.
9. **The displacement field** — from PC §2. The binary and
   geometric grids, Δ^L_k = −ε(k/2^d), architecture-free
   property. Absorbs PC §1 (binary tiling context) as a brief
   opening paragraph rather than a separate section.
10. **Hyperbolic distance between the grids** — from PC §3.
11. **The staircase prediction** — from PC §4.
12. **Combinatorial ordering invariance** — from PC §5.
13. **Spectral-spatial duality** — from PC §6, already edited
    to use the colon/dual-descriptions form.
14. **Experimental validation** — from PC "Experimental
    validation" section, unchanged.
15. **Generic calculus template** — current BW §9, moved to end.
    It is a reference appendix, not part of the main thread.

## What changes in the moved sections

PC §§2-6 and the experimental section move verbatim into
BW §§9-14. The only edits:

- PC §1 (binary tiling of the hyperbolic plane): compress to
  an opening paragraph of §9. The two-bullet description
  (horocyclic vs geodesic slicing) stays. The half-plane
  isometry sentence is context, not load-bearing.
- PC §6 internal references: "see BINADE-WHITECAPS §7" becomes
  "see §7 above." Same for "§§7-8."
- PC §2 reference to "Δ^L depends only on (d, k), not on the
  FSM..." stays verbatim.

## What to update elsewhere

Eight files reference POINCARE-CURRENTS:

1. TRAVERSE — reading outward link
2. CHARYBDIS — §2 "Why Walsh-Hadamard", reading outward
3. INTERRUPTED-LOG — reading outward
4. COMPLEXITY-REEF — reading outward
5. NARROW-PASSAGE — reading outward, §8 reference
6. ROARING-40s — reading outward
7. HERE-BE-DRAGONS — reading outward
8. GLOSSARY — displacement field entry, ε entry, tiling entry

All references change from `[POINCARE-CURRENTS](POINCARE-CURRENTS.md)`
to `[BINADE-WHITECAPS](BINADE-WHITECAPS.md)` with updated section
numbers where applicable.

## Opening paragraph

Rewrite the BW opening to reflect the merged scope:

> This note records the project's coordinate theory and its
> consequences: the mod-1 log₂ circle, the pseudo-log residual ε,
> the displacement field Δ^L = −ε between binary and geometric
> grids, the density defect identity, the Fourier decomposition,
> and the staircase prediction.

## Execution

1. Add PC §§1-6 and experimental section into BW as §§9-14.
2. Move current BW §9 (generic template) to §15.
3. Rewrite BW opening paragraph.
4. Update internal cross-references within the merged document.
5. Update all 8 external references.
6. Delete POINCARE-CURRENTS.md.
7. Verify with diff that no content was lost.
