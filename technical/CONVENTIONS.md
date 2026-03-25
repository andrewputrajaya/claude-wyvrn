# CONVENTIONS.md — Coding Standards

> **Depth:** Detail level.
> **Parent:** See `ARCHITECTURE.md` for the technology stack these conventions apply to.
> **Rule:** If the codebase already exists, match existing conventions. These apply to new code.

---

## Naming

| Element | Convention | Example |
|---|---|---|
| Variables | [e.g., camelCase] | `userName` |
| Functions | [e.g., camelCase] | `calculateTotal()` |
| Classes | [e.g., PascalCase] | `OrderProcessor` |
| Constants | [e.g., UPPER_SNAKE] | `MAX_RETRIES` |
| Files | [e.g., kebab-case] | `data-service.ts` |

## Formatting

| Rule | Standard |
|---|---|
| Indentation | [e.g., 2 spaces] |
| Max file length | [e.g., 300 lines] |
| Max function length | [e.g., 50 lines] |

## Comments

- Every function: one-line comment explaining WHAT (not HOW).
- Every constant: comment citing the spec requirement or decision record.
- No commented-out code.

## Error Handling

[e.g., "All errors caught and logged. No silent swallowing. No generic catch-all."]

---

## Clarifications

[Populated as HIRs are resolved.]
