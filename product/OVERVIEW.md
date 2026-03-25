# OVERVIEW.md — Product Specification

> **Depth:** Domain level. Contains WHAT we're building at a summary level.
> **Detail lives in:** `features/[name].md` for per-feature specs.
> **Prerequisite:** You have read CLAUDE.md and INDEX.md.

---

## 1. One-Paragraph Description

[Describe the entire product in one paragraph. Someone reading only this should understand the core experience.]

---

## 2. Core Loop

```
[Action] → [Feedback] → [Decision] → [Action] ...
```

[Explain each step in concrete terms.]

---

## 3. Session Flow

1. [User opens the application] → [what they see]
2. [First interaction] → [what happens]
3. [Core activity] → [the main thing they do]
4. [Session end] → [how it ends, what's saved]

---

## 4. Feature List

| ID | Feature | Priority | Depends On | Spec File |
|---|---|---|---|---|
| FEAT-0001 | [name] | MUST | — | `features/[name].md` |
| FEAT-0002 | [name] | MUST | FEAT-0001 | `features/[name].md` |

> **Detail:** Each feature's full spec is in its own file under `features/`.

---

## 5. Entities

| Entity | Description | Key Properties |
|---|---|---|
| [e.g., User] | [what it is] | [e.g., role: string, quota: 500 MB] |

---

## 6. Global Rules

[Rules that apply across ALL features. Feature-specific rules go in the feature spec.]

1. [Rule]
2. [Rule]

---

## 7. Screen Map

| Screen | Purpose | Enters From | Exits To |
|---|---|---|---|
| [Login] | [purpose] | [app launch] | [Dashboard, Settings] |

---

## 8. Visual Standards

[Applies to ALL features. Feature-specific visuals go in the feature spec.]

- **Color palette:** [hex codes]
- **Typography:** [font names, sizes]
- **Visual style:** [description]

---

## 9. User Inputs

| Input | Action | Context |
|---|---|---|
| [interaction method] | [what it does] | [when it applies] |

---

## 10. Success Criteria

- **Primary goal:** [what "done" looks like for the end user]
- **Failure states:** [what constitutes a failed interaction, if applicable]
- **Progression:** [how the experience evolves over time, if applicable]

---

## 11. Out of Scope

**If it's not in the Feature List (Section 4), it is out of scope by default.**

Additionally, these are explicitly excluded:
- [thing]
- [thing]

---

## Clarifications

[Populated as HIRs are resolved. Date, HIR ID, verbatim answer.]
