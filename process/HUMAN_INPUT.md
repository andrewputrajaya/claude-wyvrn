# HUMAN_INPUT.md — Escalation Protocol

> **Prerequisite:** You have read CLAUDE.md and INDEX.md.
> This file defines when and how to request human input.

---

## When to Ask

You MUST file an HIR when:

1. **The Gap Scan flags an ABSENT item.** (Most common. The checklist found a hole.)
2. **Multiple valid approaches exist** and the spec doesn't prescribe one.
3. **Two spec sections contradict** each other.
4. **You need to modify code outside your feature scope.**
5. **You need a dependency/library** not listed in ARCHITECTURE.md.
6. **The feature is larger** than one session can handle — propose a split.
7. **A subjective term** appears in the spec ("fast," "smooth," "intuitive," "looks good").

## When NOT to Ask

- **Trivial implementation details** with zero spec-visible effect (variable names, loop structure, private helpers).
- **Standard engineering practices** (null checks, bounds validation) — unless the spec defines specific error behavior.
- **Things the spec explicitly answers.** Re-read the spec before asking. Check `decisions/` too.

---

## HIR Format

```markdown
## HUMAN INPUT REQUEST

**ID:** HIR-[NNNN]
**Priority:** BLOCKER | BLOCKING | DEFERRED
**Feature:** FEAT-[NNNN] — [name]
**Gap Scan Check:** [check ID, e.g., V-01] (if triggered by Gap Scan) or MANUAL

### Question
[One specific question. Not open-ended.]

### Options
- **A:** [approach] — Tradeoff: [gain/lose]
- **B:** [approach] — Tradeoff: [gain/lose]

### Spec Reference
[Quote the section that is silent, vague, or conflicting.]

### Impact
[What is blocked until this is resolved?]
```

**Priority levels:**
- **BLOCKER** — No work on ANY feature can proceed.
- **BLOCKING** — This specific feature is blocked.
- **DEFERRED** — Can be resolved later (aesthetic choices, polish decisions).

---

## After the Human Answers

1. **Create a decision record** in `decisions/[NNNN]-[description].md`.
2. **Update the spec** that had the gap — add the answer in the `## Clarifications` section.
3. **Check for cascading effects** — does this answer affect other features? Note it in the decision record.
4. **Resume work** from where you stopped. Re-read the relevant spec section first — the context may have shifted.

Record the human's answer verbatim. Do not paraphrase or interpret.
