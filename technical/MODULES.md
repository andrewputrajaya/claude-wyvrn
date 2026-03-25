# MODULES.md — Module Boundaries & Interfaces

> **Depth:** Detail level. Specifies what each code module does and what it may access.
> **Parent:** See `ARCHITECTURE.md` for the high-level structure these modules fit into.

---

## Module Map

| Module | Responsibility | May Access | Must NOT Access |
|---|---|---|---|
| [name] | [what it does] | [which modules] | [off-limits modules] |

---

## Module Details

### [Module Name]

**Files:** `src/[path]/`
**Responsibility:** [What this module owns.]
**Public interface:**
- `functionName(params): return` — [what it does]

**Internal details:** [Agent decides implementation within module boundaries.]
**State owned:** [What state this module manages. Other modules must NOT directly modify this state.]

> Copy this section for each module.

---

## Interface Contracts

When Module A calls Module B, the contract is:

| Caller | Callee | Method | Input | Output | When |
|---|---|---|---|---|---|
| [A] | [B] | [function] | [data type] | [data type] | [trigger] |

> **If a feature needs a new interface between modules, the agent MUST file an HIR.**

---

## Clarifications

[Populated as HIRs are resolved.]
