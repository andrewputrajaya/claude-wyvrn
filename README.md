# Wyvrn Claude Tools — Harness

A standardized structure that lets Claude Code, Claude CLI, and Claude Cowork agents do development work autonomously and predictably. Drop the harness into a project, invoke a flow, answer clarifying questions through the session, and review the verifier report.

## Install (v1 — manual)

v1 is a template folder. To install:

1. Copy the contents of this archive into your project root, **except this `README.md`**.
2. Your project should now contain:
   - `CLAUDE.md` at the root
   - `.claude-wyvrn/` (the harness itself — never edit)
   - `claude-wyvrn-local/` (your project's artifacts — track in git)
3. Open `claude-wyvrn-local/ARCHITECTURE.md` and fill it in for your project.
4. Optionally add stack-specific conventions — see "Customization" below.

## What you can do

### Run a flow

Three flow types cover the common cases:

- `/flow-feature` — add new functionality.
- `/flow-fix` — resolve a bug.
- `/flow-refactor` — restructure code without changing behavior.

Each flow reads its required context, asks for clarifications through the session, does the work autonomously, verifies the result, and closes with a verifier report. See `.claude-wyvrn/workflows/WORKFLOW.md` for the phase-by-phase details.

Each flow type has its own initial-prompt requirements. Check the flow file (`.claude-wyvrn/workflows/FEATURE.md`, `FIX.md`, or `REFACTOR.md`) before invocation.

### Invoke utility skills directly

Most of the time you'll only invoke the flow skills above. Each sub-step is also available standalone:

- `/run-clarifier` — re-run clarification on an existing spec.
- `/run-verifier` — re-verify a closed flow's artifacts.
- `/template-check <artifact-path>` — check template compliance for one file.
- `/decision-log` — manually log a decision record.
- `/archive` — archive old validated or failed flows.

### Customization

Drop files into project territory to customize behavior without touching the package:

- **`claude-wyvrn-local/PROJECT.md`** — project specification. When present, agents read this instead of your root `README.md` for project context. Useful when your README is installation-focused and you want a separate project spec.
- **`claude-wyvrn-local/conventions/[stack].md`** — project-specific stack conventions. Overrides any matching package-level conventions. Use the template at `.claude-wyvrn/templates/conventions.md`.
- **`claude-wyvrn-local/ARCHITECTURE.md`** — project architecture. Pre-seeded from the template. Fill in your modules, interfaces, and invariants before first use.
- **`claude-wyvrn-local/CONVENTIONS.md`** is not a file — project conventions live per-stack under `claude-wyvrn-local/conventions/[stack].md`.

Package-level stack conventions are added by dropping files into `.claude-wyvrn/conventions/` following the same template. These apply to all projects using the harness and are typically maintained by whoever owns the harness package, not individual projects.

### Validation mode

Flows default to non-blocking validation: the flow closes on verifier success and you review the report asynchronously. If you prefer the flow to pause until you explicitly validate:

- Per-flow: include `validation: blocking` in the initial prompt.
- Project-wide default: declare it in `PROJECT.md`.

## Folder map

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Entry point for the agent. Never edit. |
| `.claude-wyvrn/` | Harness package. Never edit. |
| `.claude-wyvrn/HARNESS.md` | Agent rules. |
| `.claude-wyvrn/INDEX.md` | Agent navigation map. |
| `.claude-wyvrn/DECISIONS.md` | Decision procedure. |
| `.claude-wyvrn/conventions/` | Stack-agnostic and stack-specific rules. |
| `.claude-wyvrn/workflows/` | Flow definitions. |
| `.claude-wyvrn/templates/` | Templates for every artifact type. |
| `.claude-wyvrn/agents/` | Subagent definitions. |
| `.claude-wyvrn/skills/` | Invocable skills. |
| `.claude-wyvrn/extensions/` | Drop-in extensions. Empty by default. |
| `claude-wyvrn-local/` | Your project's artifacts and overrides. Track in git. |
| `claude-wyvrn-local/ARCHITECTURE.md` | Your project architecture. Fill in before first use. |
| `claude-wyvrn-local/features/` | Feature specs. |
| `claude-wyvrn-local/fixes/` | Fix specs. |
| `claude-wyvrn-local/refactors/` | Refactor specs. |
| `claude-wyvrn-local/decisions/` | Decision records. |
| `claude-wyvrn-local/clarifications/` | Clarification batches. |
| `claude-wyvrn-local/reviews/` | Verifier reports. |
| `claude-wyvrn-local/verifier-gaps/` | Verifier gap reports. |
| `claude-wyvrn-local/conventions/` | Project-specific stack conventions (optional). |
| `claude-wyvrn-local/.archive/` | Archived artifacts. Off-limits to agents during flows. |

## What not to do

- **Don't edit files under `.claude-wyvrn/`.** They are overwritten on harness updates. Use project-territory overrides instead.
- **Don't hand-write artifacts.** Artifacts come from templates through flows. Writing them by hand bypasses template compliance and verification.
- **Don't answer agent questions by editing artifact files.** The agent asks through the session; you answer through the session. Agents record your answers in the artifacts.
- **Don't skip the verifier.** A flow is not complete without a successful verifier pass.
- **Don't expand flow scope mid-flow.** If you realize you want more, either let the current flow close and start a new one, or respond to the out-of-scope prompt when it appears.

## Where to learn more

The files under `.claude-wyvrn/` are the authoritative reference. They're written for agents but are also readable by humans. In order of usefulness for a dev who wants to understand the system:

1. `.claude-wyvrn/HARNESS.md` — the rules agents follow.
2. `.claude-wyvrn/workflows/WORKFLOW.md` — what happens during a flow.
3. `.claude-wyvrn/DECISIONS.md` — how agents classify decisions and when they stop to ask.
4. `.claude-wyvrn/conventions/CONVENTIONS.md` — how agents produce code and artifacts.
5. `.claude-wyvrn/INDEX.md` — the map of where everything lives.

Individual flow types, agents, and skills have their own files under `workflows/`, `agents/`, and `skills/`.

## Version

See `.claude-wyvrn/VERSION` for the harness version shipped with this archive.
