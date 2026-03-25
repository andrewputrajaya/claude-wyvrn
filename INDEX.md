# INDEX.md — Spec Tree Navigation Map

> **Read after CLAUDE.md, before anything else.**
> This file tells you WHERE to go. It does not contain specs itself.
> When the spec tree changes, this file MUST be updated to reflect the current structure.

---

## Spec Tree Structure

```
specs/
├── CLAUDE.md                        ← Agent constitution (ALWAYS READ)
├── INDEX.md                         ← You are here (ALWAYS READ)
│
├── process/                         ← HOW agents work
│   ├── WORKFLOW.md                  ← Development phases & checkpoints
│   ├── HUMAN_INPUT.md               ← When and how to escalate to human
│   ├── GAP_SCAN.md                  ← Mechanical checklist to catch blind spots
│   └── OPERATIONS.md                ← How humans orchestrate agent work
│
├── product/                         ← WHAT we are building
│   ├── OVERVIEW.md                  ← One-page product summary (read first in this branch)
│   └── features/                    ← Individual feature specs (read per task)
│       ├── _TEMPLATE.md             ← Template for new features
│       └── [feature-name].md        ← One file per feature
│
├── technical/                       ← HOW it is built
│   ├── ARCHITECTURE.md              ← High-level structure & constraints
│   ├── MODULES.md                   ← Module boundaries & interfaces
│   └── CONVENTIONS.md               ← Coding standards & patterns
│
├── decisions/                       ← Institutional memory
│   ├── _TEMPLATE.md                 ← Template for decision records
│   └── [NNNN]-[description].md      ← Logged decisions & inferences
│
└── reviews/                         ← Gap scan results & audits
    ├── _TEMPLATE.md                 ← Template for review records
    └── [feature]-review.md          ← Per-feature gap scan results
```

---

## Reading Routes

**Based on your task, follow the reading route below. Read files in the order listed.**

### Route A: Starting a New Feature

| Order | File | Why |
|---|---|---|
| 1 | `CLAUDE.md` | Constitution |
| 2 | `INDEX.md` | Navigation (you're here) |
| 3 | `product/OVERVIEW.md` | Understand what we're building |
| 4 | `technical/ARCHITECTURE.md` | Understand technical constraints |
| 5 | `product/features/[your-feature].md` | Your specific task |
| 6 | `process/WORKFLOW.md` | Understand the phase you're in |
| 7 | `process/GAP_SCAN.md` | You'll need this before marking done |
| 8 | `decisions/` (scan all) | Check for prior decisions affecting your work |

### Route B: Resuming Work in a New Session

| Order | File | Why |
|---|---|---|
| 1 | `CLAUDE.md` | Constitution |
| 2 | `INDEX.md` | Navigation (you're here) |
| 3 | `decisions/` (scan all) | Restore institutional memory |
| 4 | `reviews/` (scan relevant) | See what gaps were already found |
| 5 | The feature spec you were working on | Resume context |

### Route C: Running a Gap Scan / Review

| Order | File | Why |
|---|---|---|
| 1 | `CLAUDE.md` | Constitution |
| 2 | `INDEX.md` | Navigation (you're here) |
| 3 | `process/GAP_SCAN.md` | The checklist to run |
| 4 | The feature spec being reviewed | Subject of the scan |
| 5 | `product/OVERVIEW.md` | Needed for cross-referencing |
| 6 | `technical/ARCHITECTURE.md` | Needed for cross-referencing |

### Route D: Answering a Human Input Request

| Order | File | Why |
|---|---|---|
| 1 | `CLAUDE.md` | Constitution |
| 2 | `INDEX.md` | Navigation (you're here) |
| 3 | The HIR itself | Understand the question |
| 4 | The spec sections cited in the HIR | Understand the context |

---

## Depth Principle

Information lives at ONE level of the tree. It is never duplicated across levels.

| Level | Contains | Example |
|---|---|---|
| **Root** | Universal rules, navigation | CLAUDE.md, INDEX.md |
| **Domain** | Process rules, product overview, architecture overview | WORKFLOW.md, OVERVIEW.md, ARCHITECTURE.md |
| **Detail** | Feature specs, module specs, coding standards | features/auth.md, MODULES.md |
| **Record** | Decisions, reviews, completion reports | decisions/0001-*.md, reviews/*-review.md |

**When updating specs from human input:**
- Ask: "At what level does this information apply?"
- If it affects the whole product → update at Domain level.
- If it affects one feature → update at Detail level.
- If it resolves a specific question → record at Record level AND update the spec that had the gap.
- NEVER copy information upward or downward. Reference it.

---

## Cross-Reference Convention

When a deeper file needs information from a higher file, use this format:

```
> **See:** `technical/ARCHITECTURE.md` Section 3 for allowed dependencies.
```

When a higher file delegates detail to a deeper file:

```
> **Detail:** See `product/features/auth.md` for full authentication specification.
```

This creates a navigable web without duplication.
