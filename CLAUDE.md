# CLAUDE.md — Agent Constitution

> **This is the highest-authority document in the project.**
> Read this file FIRST. Then read INDEX.md to navigate to what you need.
> If anything in the spec tree contradicts this file, THIS FILE WINS.

---

## The Three Laws

### Law 1: Never Assume

Before writing any code or making any design choice, you MUST be able to classify the decision:

- **SPEC-DEFINED** → The spec explicitly states the answer. Implement it.
- **INFERRED** → The answer is logically unavoidable from stated requirements. Implement it, but log it in `decisions/`.
- **UNDECIDED** → The spec is silent, vague, or interpretable. **STOP. Request human input.**
- **CONTRADICTION** → Two spec sections disagree. **STOP. Request human input.**

**The test:** If a reasonable second agent could read the same spec and arrive at a different implementation, the decision is UNDECIDED. Stop and ask.

### Law 2: Never Improvise Scope

You implement what the spec says. Nothing more, nothing less.

- Do NOT add features, polish, or "nice-to-haves" not in the spec.
- Do NOT refactor or reorganize code outside your current task scope.
- Do NOT change architecture unless the task spec explicitly calls for it.
- If the spec is missing something critical, file a Human Input Request. Do not fill the gap yourself.

### Law 3: Never Self-Validate

You are not the arbiter of what is "best." The spec is.

- If the spec prescribes an approach, use that approach — even if you believe a better one exists.
- If the spec doesn't prescribe an approach and multiple exist, you do NOT pick one. You request human input.
- "It works" is not validation. "It matches the spec" is validation.

---

## Reading Protocol

**Every agent session begins with this exact reading sequence:**

1. **CLAUDE.md** (this file) — Non-negotiable rules.
2. **INDEX.md** — Understand the spec tree and locate your task.
3. **The files INDEX.md directs you to** — Based on your assigned task.

You do NOT read every file in the tree. INDEX.md tells you which files are required reading for your specific task. But you ALWAYS read CLAUDE.md and INDEX.md.

---

## Spec Tree Rules

### Navigation Hierarchy

The spec tree is organized by depth. Higher files are broader; deeper files are more detailed.

```
Level 0 (Root):    CLAUDE.md, INDEX.md — Always read.
Level 1 (Domain):  process/, product/, technical/ — Read the domain relevant to your task.
Level 2 (Topic):   OVERVIEW.md, ARCHITECTURE.md — Read for context.
Level 3 (Detail):  features/[name].md, MODULES.md — Read for implementation.
```

**The rule of upward dependency:** A deeper file may REFERENCE a higher file, but never CONTRADICT it. If you find a contradiction, the higher file wins and you file a Human Input Request.

### Updating Specs

When human input resolves a question:

1. **Record the answer** in `decisions/` (always).
2. **Update the spec at the correct depth:**
   - If the answer is about the overall product → update in `product/OVERVIEW.md`.
   - If the answer is about a specific feature → update in `product/features/[name].md`.
   - If the answer is about architecture → update in `technical/ARCHITECTURE.md`.
   - If the answer is about a module → update in `technical/MODULES.md`.
3. **Never duplicate information across depths.** A detail belongs at ONE level. Deeper files reference higher files; they don't copy from them.
4. **Add updates to the `## Clarifications` section** of the relevant file, with the date and HIR ID.

### What "Done" Means

A task is DONE only when ALL of the following are true:

1. Every acceptance criterion in the feature spec passes.
2. The Gap Scan checklist has been run (see `process/GAP_SCAN.md`).
3. No code exists that isn't justified by a spec line.
4. All inferred decisions are logged in `decisions/`.
5. All Human Input Requests are resolved.
6. No code outside the task scope has been modified.
7. A completion report is written.

---

## Forbidden Patterns

| Forbidden | Do Instead |
|---|---|
| Adding an unspecified feature | File an HIR suggesting the addition |
| Choosing between valid approaches without spec guidance | File an HIR with options |
| Rewriting working code "to be cleaner" | File a separate improvement proposal |
| Ignoring a spec requirement that seems wrong | File an HIR explaining your concern |
| Continuing past a contradiction | STOP and file an HIR |
| Using a library not in ARCHITECTURE.md | File an HIR |
| Interpreting "should" as optional | In this system, "should" means "must" |
| Skipping the decision log | Always log inferences |
| Skipping the Gap Scan | Always run it before marking done |
