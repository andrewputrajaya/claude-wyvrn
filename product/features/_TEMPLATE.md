# Feature: [NAME]

> **ID:** FEAT-[NNNN]
> **Status:** DRAFT | APPROVED | IN_PROGRESS | COMPLETE
> **Depends On:** [FEAT-IDs]
> **Scope Check:** NOT RUN | PASS | SPLIT REQUIRED | OVERRIDE
> **Parent:** See `product/OVERVIEW.md` for product context.

---

## Purpose

[One paragraph. What does this feature DO from the user's perspective?]

---

## Requirements

| ID | Requirement | Priority |
|---|---|---|
| REQ-01 | [specific, measurable behavior] | MUST |
| REQ-02 | [specific, measurable behavior] | MUST |

---

## Acceptance Criteria

- **AC-01:** Given [X], when [Y], then [Z].
- **AC-02:** Given [X], when [Y], then [Z].

> If it's not in an AC, it's not part of this feature.

---

## Behavior

### Normal Flow
[Step-by-step happy path.]

### Edge Cases
[What happens at boundaries? Zero, max, empty, simultaneous?]

### Error States
[What happens when things go wrong?]

### Interactions
[How this feature connects to other features. If none: "NONE."]

---

## UI Specification

> **If this feature has UI and any field below is empty, the agent MUST file an HIR.**

- **Position:** [coordinates or layout rule]
- **Size:** [concrete dimensions]
- **Colors:** [hex codes]
- **Font:** [name and size]
- **States:** [list each visual state]
- **Animations:** [duration, easing, trigger — or "NONE"]

---

## Data / Values

| Parameter | Value | Unit | Source |
|---|---|---|---|
| [name] | [number] | [unit] | [why this value] |

> **If any value is TBD, the agent MUST file an HIR.**

---

## Constraints

- MUST NOT [forbidden behavior].
- MUST NOT modify [other feature/system].

---

## Out of Scope

- [related thing that is NOT part of this feature]

---

## Open Questions

| Question | HIR ID | Status | Resolution |
|---|---|---|---|
| [question] | HIR-[NNNN] | PENDING / RESOLVED | [answer] |

> **Features with PENDING questions cannot move to IN_PROGRESS.**

---

## Clarifications

[Populated as HIRs are resolved.]

> **[date] — HIR-[NNNN]:** [verbatim answer]

---

## Completion Report

```
Acceptance Criteria:
- AC-01: [PASS/FAIL] — [how verified]
- AC-02: [PASS/FAIL] — [how verified]

Decisions logged: [count] (see decisions/)
HIRs filed: [count] — all resolved: [YES/NO]
Out-of-scope changes: NONE
Gap Scan: [CLEAN / issues found — see reviews/]
```
