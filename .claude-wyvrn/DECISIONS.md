# DECISIONS.md

Decision procedure. Apply to every decision during a flow. Escalation and logging rules are in `HARNESS.md`.

## 1. Classification

Every decision resolves into exactly one of four states. Classify before acting.

### 1.1 SPEC-DEFINED

Authoritative source states the answer.

Authoritative sources, in precedence order:

1. The initial human prompt for the current flow.
2. `HARNESS.md`.
3. `.claude-wyvrn-local/conventions/[stack].md` files, then `~/.claude-wyvrn/conventions/[stack].md` files, then `~/.claude-wyvrn/conventions/CONVENTIONS.md`.
4. `.claude-wyvrn-local/PROJECT.md` if present, else `README.md`.
5. `.claude-wyvrn-local/ARCHITECTURE.md`.
6. The task-specific spec (feature, fix, or refactor artifact).
7. Prior decision records in `.claude-wyvrn-local/decisions/` not marked archived.

Action: apply the answer. No log required.

### 1.2 INFERRED

Answer is not explicit but is logically unavoidable given authoritative sources. Unavoidable means: given stated constraints and requirements, any other answer contradicts something stated.

Action: apply the answer. Log the decision via the `decision-log` skill before proceeding.

### 1.3 UNDECIDED

A value, choice, or piece of information required to proceed is absent from every authoritative source and cannot be logically derived from them.

Action: add to the clarification batch. Do not proceed on that path.

### 1.4 CONTRADICTION

Two or more authoritative sources disagree. Precedence rules in §1.1 do not resolve the disagreement.

Action: add to the clarification batch, citing each conflicting source and the exact text. Do not proceed on that path.

## 2. Classification procedure

Apply these checks in order. Stop at the first that applies.

1. Answer is explicit in an authoritative source? → SPEC-DEFINED.
2. Two authoritative sources give different answers? → CONTRADICTION.
3. Information required to proceed is absent from every authoritative source? → UNDECIDED.
4. Exactly one answer follows logically from authoritative sources? → INFERRED.
5. Multiple answers follow logically with no authoritative basis to choose? → UNDECIDED.

## 3. Tie-breaker

When classification between INFERRED and UNDECIDED is unclear, apply the second-agent test:

A hypothetical second agent, reading the same authoritative sources with no additional context, could arrive at a different answer → UNDECIDED.

A hypothetical second agent would be forced to the same answer → INFERRED.

## 4. Scope

### 4.1 Task scope definition

Scope for the current flow is defined by:

- The initial human prompt.
- The task-specific spec artifact.
- The clarification batch responses, once answered.

Scope is what the agent is authorized to produce or modify. Anything outside scope is out of scope, regardless of how small, adjacent, or improving the change would be.

### 4.2 Out-of-scope work encountered

When encountering work that should be done but is outside current scope:

1. Do not do the work.
2. Record in the verifier report under out-of-scope findings.
3. Proceed with the original task.

Out-of-scope findings do not fail the flow.

### 4.3 Out-of-scope work required

When completing the current task requires modifying something outside declared scope:

1. Classify the required modification per §1 and §2.
2. In most cases, classification is UNDECIDED. Add to clarification batch.
3. Do not proceed on dependent work until resolved.

Exception: modifications that are pure mechanical consequences of the task and add no new behavior (e.g., updating an import when moving a file whose move is in scope) are SPEC-DEFINED by the in-scope change.

## 5. Autonomy tiers

| Tier | Condition | Action |
|---|---|---|
| Free | No spec-visible effect. | Act. No log. |
| Log-and-proceed | INFERRED. | Act. Log via `decision-log` skill. |
| Stop | UNDECIDED or CONTRADICTION. | Add to clarification batch. Do not proceed on that path. |

"No spec-visible effect" means:

- A reasonable reader of the spec would not notice this choice was made.
- Behavior is identical under any reasonable alternative.
- No artifact the human reads differs.

Variable names, private helper structure, internal loop form typically qualify. Error messages, public interface names, data formats, artifact structure do not.

## 6. Logging

### 6.1 What to log

| Classification | Log? |
|---|---|
| SPEC-DEFINED | No |
| INFERRED | Yes, via `decision-log` skill |
| UNDECIDED | No (add to clarification batch instead) |
| CONTRADICTION | No (add to clarification batch instead) |
| Free-tier | No |
| Human override | Yes, via `decision-log` skill |

### 6.2 Human overrides

When an explicit human instruction during a flow overrides a harness rule or a spec (`HARNESS.md` §7.2), log it as a decision record. The override binds only the current flow and does not modify any authoritative source.

## 7. Conflict resolution within this document

1. §1.1 precedence order determines which authoritative source wins.
2. For internal conflicts in this document, apply the more restrictive rule.
3. If still unresolved, treat as CONTRADICTION. Add to clarification batch.
