# ARCHITECTURE.md — Technical Architecture

> **Depth:** Domain level. High-level structure and constraints.
> **Detail lives in:** `MODULES.md` for module boundaries, `CONVENTIONS.md` for coding standards.
> **Prerequisite:** You have read CLAUDE.md, INDEX.md, and `product/OVERVIEW.md`.

---

## 1. Platform

| Property | Value |
|---|---|
| **Language** | [e.g., TypeScript] |
| **Runtime / Engine** | [e.g., Browser + Canvas API] |
| **Target** | [e.g., Desktop Chrome/Firefox] |
| **Performance floor** | [e.g., 60fps on 2020 laptop] |

---

## 2. Project Structure

```
project-root/
├── src/
│   ├── [folder]/          ← [purpose]
│   └── [entry-point]      ← [purpose]
├── assets/
│   └── [folder]/          ← [purpose]
├── specs/                  ← Spec tree (do not modify during implementation)
└── [config files]
```

> **If a file or folder is not listed here, agents MUST NOT create it without an approved HIR.**
> **Detail:** See `MODULES.md` for what goes in each folder.

---

## 3. Allowed Dependencies

| Dependency | Version | Purpose |
|---|---|---|
| [name] | [version] | [why] |

> **Adding a dependency not on this list requires an approved HIR.**

---

## 4. Data Flow

```
[Input] → [System A] → [System B] → [Output]
```

[Describe each connection briefly. Detail lives in MODULES.md.]

---

## 5. State Management

- **Global state:** [what, how accessed]
- **Local state:** [rules]
- **Persistence:** [how/when saved, or "NONE"]

---

## 6. Build & Run

```bash
# Install
[command]

# Run dev
[command]

# Build
[command]
```

---

## 7. Prohibitions

- DO NOT use [pattern/library] because [reason].
- DO NOT introduce [type of coupling].
- ALL [resource type] must go through [system].

---

## Clarifications

[Populated as HIRs are resolved.]
