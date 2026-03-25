# Agent Specification System v2

A structured specification framework that constrains AI agents to build exactly what humans intend at any project scale.

---

## The Problem

AI agents degrade over iterative work in three ways:

1. **Drift** — Scope and details blur. The agent slowly diverges from intent.
2. **Assumption** — The agent picks approaches without validation. Different agents would choose differently.
3. **Silence** — The agent doesn't recognize when it's making an unsupported decision.

And at scale, two more:

4. **Shared blind spots** — If two agents have the same gap in judgment, the "second agent" test fails silently.
5. **Information burial** — As specs grow, agents either skip what they need or drown in what they don't.

---

## How It Solves Each

| Problem | Mechanism |
|---|---|
| Drift | Acceptance criteria are pass/fail. Post-implementation Gap Scan catches unspecified code. |
| Assumption | Certainty Framework + mandatory decision logging for inferences. |
| Silence | GAP_SCAN.md is a mechanical checklist — it doesn't rely on the agent "noticing" gaps. |
| Shared blind spots | The Gap Scan checks for the PRESENCE of information, not the agent's judgment of clarity. |
| Information burial | Tree hierarchy with INDEX.md routing. Agents read only what their task requires. |

---

## Architecture

```
specs/
├── CLAUDE.md              ← Agent constitution. Always read first.
├── INDEX.md               ← Navigation map. Routes agents to the right files.
│
├── process/               ← HOW agents work (pre-built, rarely changes)
│   ├── WORKFLOW.md        ← Phases: Read → Scaffold → Implement → Verify
│   ├── HUMAN_INPUT.md     ← When/how to escalate to human
│   ├── GAP_SCAN.md        ← Mechanical checklist for spec completeness
│   └── OPERATIONS.md      ← Human guide: how to orchestrate agent work
│
├── product/               ← WHAT we're building (you fill this in)
│   ├── OVERVIEW.md        ← One-page product summary
│   └── features/          ← One spec per feature
│       └── _TEMPLATE.md
│
├── technical/             ← HOW it's built (you fill this in)
│   ├── ARCHITECTURE.md    ← Tech stack, structure, constraints
│   ├── MODULES.md         ← Module boundaries & interfaces
│   └── CONVENTIONS.md     ← Coding standards
│
├── decisions/             ← Institutional memory (agents fill this in)
│   └── _TEMPLATE.md
│
└── reviews/               ← Gap scan results (agents fill this in)
    └── _TEMPLATE.md
```

---

## Quick Start

### 1. Fill in your product spec
Edit `product/OVERVIEW.md`. Describe your product. Every section matters.

### 2. Fill in your architecture
Edit `technical/ARCHITECTURE.md`, `MODULES.md`, and `CONVENTIONS.md`.

### 3. Write your first feature spec
Copy `product/features/_TEMPLATE.md` to `product/features/[name].md`. Fill in every section. Use concrete values, not adjectives.

### 4. Run a Gap Scan on your spec (optional but recommended)
Give an agent this prompt:
```
Read specs/process/GAP_SCAN.md. Then read specs/product/features/[name].md.
Run the full pre-implementation gap scan. Report all ABSENT items.
Do NOT attempt to fill the gaps — just report them.
```

### 5. Hand the feature to a building agent
```
You are working on [project name].
Your task is to implement feature FEAT-[NNNN]: [name].
Before doing anything, read specs/CLAUDE.md, then specs/INDEX.md,
then follow Reading Route A.
```

### 6. Review the output
Read the completion report. Spot-check an acceptance criterion. Review decision logs.

### 7. Repeat for the next feature

---

## Key Principles

Read `process/OPERATIONS.md` for the full guide. The headlines:

- **One feature per session.** Resets context decay.
- **Sequential over parallel.** Avoids assumption compounding between agents.
- **Spec first, code second.** Never start coding an unapproved spec.
- **The Gap Scan is mandatory.** It catches what agent judgment misses.
- **HIRs are a feature, not a bottleneck.** More questions early = fewer bugs later.
- **Verify, don't trust.** 5-minute human spot-check after every session.
