# Inverse Marshall Plan

Editing process for LORENTZ-ROUTE.md. Two phases: a pre-clearing
pass that removes known debris and installs the Baire bridge, then
a relaxation loop that converges the surviving prose onto its
mathematical skeleton.

---

## Disciplines

These are filters applied throughout both phases.

### NTBT

Does the negation add information the surrounding text doesn't
carry? If no, delete. Does it misrepresent the finding? If yes,
re-frame. Everything else goes to human judgment.

### Source router

When a claim needs grounding:

1. **reckoning/** — already stated precisely elsewhere? Reference.
2. **sources/** — in local primary literature? Cite with theorem
   number.
3. **Known classical** — cite by author, year, result name.
4. **Beyond the project** — stop and discuss.

---

## Phase 1: Pre-clearing

Safe, mechanical edits. Each item is independent. The goal is to
remove known debris so the relaxation loop works on clean text.

### 1a. Remove Lorentz metaphor from body text

Title and filename stay. Seven instances leave:

| Line | Instance | Action |
|------|----------|--------|
| 3-8 | Opening paragraph (reference frames, acceleration) | Rewrite: state content directly |
| 10-12 | "freefall through successive floors" | Rewrite as structural guide |
| 88-90 | "No smooth boost crosses that gap" | Delete; L:78 has the math |
| 245 | "The thermocline here is sharper" | Delete |
| 332-335 | "two reference frames viewing the same invariant" | Rewrite without frame language |
| 341-342 | "Frame-independence of the coarse structure" | Rewrite: "inherited by every correction architecture" |
| 344-345 | "Brouwer route and Lorentz route" | Name routes by content |

### 1b. Delete clear loiterers

Sentences where the surrounding text already carries the content.

| Line | Sentence | Why |
|------|----------|-----|
| 28-30 | "geometry does all the visible work..." | Nothing downstream uses it |
| 101 | "The floor supports only itself. Circular." | Redundant with L:98 |
| 197 | "What does this accomplish, read as an integration tactic?" | Rhetorical question; answer stands alone |
| 245 | "The thermocline here is sharper than §5's." | Already caught in 1a |
| 297 | "The floor supports only itself. This is §4. ∎" | No theorem was stated; ∎ is rhetorical |

### 1c. One-line rephrases

Sentences with real content buried in theatrical delivery.

| Line | Current | Rephrase to |
|------|---------|-------------|
| 141-142 | Two sentences ("refuses to look... A machine that simply enumerates.") | One sentence |
| 252 | "a fresh civilizational effort" | "full recomputation" |
| 254-260 | "ghosts of grid alignment" | Keep continued-fractions content, drop metaphor |
| 262-263 | "standing on air" | "complete at p=53, unavailable at p=113" |
| 265 | "## §7. The Culture" | Retitle to describe content |

### 1d. Retitle §7

"The Culture" is opaque. The section removes all resource bounds.
Title should say that.

### 1e. Write the Baire bridge

Transition paragraph between §3 and §4. Four statements:

1. Absolutely continuous measures are meager in the weak-*
   topology (Oxtoby, *Measure and Category*, Ch. 18).
2. §3's smooth candidates all stay inside that meager class.
3. So §3 fails for structural reasons: smooth deformations do not
   leave the absolutely-continuous side.
4. §4's fractal construction approaches μ_? through finite
   approximants that remain in that class; only the limiting
   object escapes it.

This replaces the geographic metaphor in L:77 ("continent of
Lebesgue-absolute-continuity"). Do not collapse §§3-4 into one
section.

State only what Oxtoby Ch. 18 directly provides. If it supports a
stronger complement statement, cite it exactly. If not, say only
that μ_? lies outside the smooth absolutely-continuous class.

### 1f. Pause and review

After 1a-1e, read the document. Is the mathematical content
sound? Are the section boundaries right? Address basic issues
before entering the relaxation loop.

---

## Phase 2: Inverse Marshall relaxation

The pre-clearing removed debris. The relaxation converges the
surviving prose onto its mathematical skeleton.

### The method

For each surviving substantive claim, temporarily remove it.
Observe what happens to the surrounding text:

- **The argument gains clarity.** The sentence was noise. Leave
  the gap. This is play in the structure — the sentence was
  adding constraint without adding information.

- **The argument loses coherence.** The sentence was a joint
  between two mathematical statements. The joint is real; the
  English was providing it badly. Rebuild the joint: find the
  mathematical or structural role and express it precisely.

- **A theorem appears underneath.** The sentence was encoding
  mathematics in prose. State the theorem. Check whether the
  English adds anything about the theorem's *role in the
  argument* that the theorem statement alone doesn't carry. If
  yes, keep both. If no, the theorem replaces the English.

### The three categories

These are the same Marshall categories, but the action is
different from a burn.

**Already mathematical.** Fixed points of the relaxation. These
don't move. They are the skeleton the prose re-settles around.

**English encoding mathematics.** State the theorem. Then ask:
is the English saying something about the theorem's role in the
argument — a joint, a turn, a structural connection — that the
theorem alone doesn't carry? If yes, the English earns its
place alongside the theorem. If the English is restating the
theorem less precisely, the theorem replaces it.

Known candidates:

- "The corrections cannot eventually repeat" → generating
  function is irrational.
- "Each precision is a separate, non-transferable act" →
  worst-case inputs at p don't predict p+1.
- "The error is the next level of the fractal" → weak-*
  distance controlled by the (n+1)-st Stern-Brocot level.
- "The list does not refine" → worst-case set at p is not a
  subset of worst-case set at p+1.

**English encoding nothing.** Remove. Observe. If the text has
more freedom (a constraint was doing no work), the sentence was
decoration. If the text has less freedom (structural tension is
lost), something real is there — find it and express it as
mathematics or as a precise structural statement.

Known candidates:

- "The floor supports this weight."
- "A fresh civilizational effort."
- "You are standing on air."
- "The floor supports only itself. This is §4. ∎"

### Execution

Work through the document section by section. Each section is a
conversation turn. Present the removals, the observed effect on
coherence, and the proposed replacements (theorems, joints, or
gaps) to the human for review before making edits.

The relaxation converges when every surviving sentence is either
mathematics, English that earned its place by carrying a joint
the mathematics alone doesn't express, or structural connective
tissue. Sentences that are directionally useful but lack
theorem-level grounding stay in the body if they are carrying a
real joint; mark them with [MENEHUNE] or an explicit
"interpretive" qualifier rather than relocating them to Status.

### Scope note

The goal is a tightly status-qualified thought piece. LORENTZ-
ROUTE should not overclaim beyond what SCYLLA, BINADE-WHITECAPS,
and DEPARTURE-POINT already establish. Its value is the sequence
of successive failures against ?(x)'s singularity, presented in
one place. The invariance route is the governing backbone. The
contradiction route stays in ROARING-40s, referenced from
reading-outward.
