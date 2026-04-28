# Wyvrn Claude Tools — Harness

A standardized structure that lets Claude Code, Claude CLI, and Claude Cowork agents do development work autonomously and predictably.

Starting in v0.2, the harness installs **globally per machine** (one install, many projects) and each project carries a small **project-local folder** for its artifacts.

## Install

### Install the harness globally (once per machine)

**macOS / Linux / WSL / Git Bash:**

```bash
curl -fsSL https://raw.githubusercontent.com/WyvrnOfficial/claude-wyvrn/main/install.sh | bash
```

**Windows (PowerShell):**

```powershell
iwr -useb https://raw.githubusercontent.com/WyvrnOfficial/claude-wyvrn/main/install.ps1 | iex
```

That installs the harness to `~/.claude-wyvrn/` and puts a `claude-wyvrn` shim on your PATH (`~/.local/bin/` on Unix, `~/.claude-wyvrn/bin/` on Windows). Open a new shell to pick up the PATH change. Then verify:

```
claude-wyvrn doctor
```

All projects on this machine share the harness. When a new version ships, run `claude-wyvrn update` and every project on the machine picks it up.

**Pin a specific version** (handy for CI reproducibility):

```bash
CLAUDE_WYVRN_VERSION=0.2.1 curl -fsSL https://raw.githubusercontent.com/WyvrnOfficial/claude-wyvrn/main/install.sh | bash
```

**Verified install** (for users who don't want to pipe curl into bash):

```bash
curl -fsSLO https://github.com/WyvrnOfficial/claude-wyvrn/releases/latest/download/install.sh
curl -fsSLO https://github.com/WyvrnOfficial/claude-wyvrn/releases/latest/download/SHA256SUMS
sha256sum --ignore-missing -c SHA256SUMS
bash install.sh
```

**Locked-down corp environments** (where `iex` or `curl | bash` is blocked): use `gh release download` or download the assets manually from the [latest release](https://github.com/WyvrnOfficial/claude-wyvrn/releases/latest), then run `bash install.sh` / `.\install.ps1`. On Windows, you may need `Set-ExecutionPolicy -Scope Process Bypass` first.

### Initialize a project (once per project)

From the root of the project:

```
claude-wyvrn init
```

That copies `CLAUDE.md` and `.claude-wyvrn-local/` into the current directory from the harness install. If you already had a `CLAUDE.md` with project content, `init` automatically moves it to `.claude-wyvrn-local/PROJECT.md` so nothing is lost. Then:

1. Track both in git.
2. Open `.claude-wyvrn-local/ARCHITECTURE.md` and fill it in for your project.
3. If `init` created `PROJECT.md` from your old `CLAUDE.md`, review it — that's now the project spec the harness reads. You can also add stack-specific conventions; see Customization below.

### Refresh an existing project (after a harness upgrade)

From an already-initialized project root:

```
claude-wyvrn refresh
```

`refresh` overwrites `CLAUDE.md` with the current skeleton (it's the harness entry-point — project-specific content lives in `PROJECT.md`) and additively creates any missing directories or `.gitkeep` files under `.claude-wyvrn-local/`. It **never** touches `PROJECT.md`, `ARCHITECTURE.md`, artifacts (`features/`, `fixes/`, `refactors/`, `decisions/`, etc.), `conventions/`, or `.archive/`. Run it after `claude-wyvrn update` if a new harness version adds new artifact dirs or updates the entry-point template.

### Updating the harness

```
claude-wyvrn update
```

Replaces `~/.claude-wyvrn/` with the latest release. The harness territory is read-only during flows, so there is nothing user-edited to preserve.

### CLI reference

| Command | What it does |
|---|---|
| `claude-wyvrn install` | First-time install (idempotent — running again no-ops if up-to-date). |
| `claude-wyvrn update` | Upgrade to the latest harness release (or `CLAUDE_WYVRN_VERSION`). |
| `claude-wyvrn init` | Initialize a new project. Auto-preserves any pre-existing `CLAUDE.md` to `PROJECT.md`. Refuses if `.claude-wyvrn-local/` already exists. |
| `claude-wyvrn refresh` | Re-apply skeleton in an already-initialized project. Overwrites `CLAUDE.md`; additively adds missing dirs/files. Never touches `PROJECT.md`, `ARCHITECTURE.md`, or artifacts. |
| `claude-wyvrn uninit` | Inverse of `init`: restore `PROJECT.md` as `CLAUDE.md` and remove `.claude-wyvrn-local/`. Refuses if artifacts are present; override with `--force`. |
| `claude-wyvrn doctor` | Verify install integrity, check for newer version. |
| `claude-wyvrn version` | Print installed harness version. |
| `claude-wyvrn uninstall` | Remove `~/.claude-wyvrn/` and the CLI shim (global; this is *not* the per-project undo — use `uninit` for that). |
| `claude-wyvrn help` | Show usage. |

### CI

Run the same one-liner at the start of any CI job that uses Claude flows. For reproducibility, pin a version with `CLAUDE_WYVRN_VERSION=<x.y.z>`. The project-template files (`CLAUDE.md` and `.claude-wyvrn-local/`) come with your repo.

## What you can do

### Run a flow

Three flow types:

- `/flow-feature` — add new functionality.
- `/flow-fix` — resolve a bug.
- `/flow-refactor` — restructure code without changing behavior.

Each flow reads its required context, asks clarifying questions through the active session, does the work autonomously, verifies the result, and closes with a verifier report. Phases and rules are in `~/.claude-wyvrn/workflows/WORKFLOW.md`.

Each flow type has its own initial-prompt requirements. Check the flow file (`~/.claude-wyvrn/workflows/FEATURE.md`, `FIX.md`, or `REFACTOR.md`) before invocation.

### Invoke utility skills directly

Most of the time you'll only invoke the flow skills above. Each sub-step is also available standalone:

- `/run-clarifier` — re-run clarification on an existing spec.
- `/run-verifier` — re-verify a closed flow's artifacts.
- `/template-check <artifact-path>` — check template compliance for one file.
- `/decision-log` — manually log a decision record.
- `/archive` — archive old validated or failed flows.

### Customization

Drop files into project territory to customize behavior without touching the global harness:

- **`.claude-wyvrn-local/PROJECT.md`** — project specification. When present, agents read this instead of the root `README.md` for project context. Useful when your README is installation-focused and you want a separate project spec.
- **`.claude-wyvrn-local/conventions/[stack].md`** — project-specific stack conventions. Overrides any matching global conventions. Use the template at `~/.claude-wyvrn/templates/conventions.md`.
- **`.claude-wyvrn-local/ARCHITECTURE.md`** — project architecture. Seeded from the template. Fill in your modules, interfaces, and invariants before first use.

Machine-wide stack conventions go into `~/.claude-wyvrn/conventions/` using the same template. These apply to every project on the machine and are typically maintained by whoever owns the harness install.

### Validation mode

Flows default to non-blocking validation: the flow closes on verifier success and you review the report asynchronously. If you prefer the flow to pause until you explicitly validate:

- Per-flow: include `validation: blocking` in the initial prompt.
- Project-wide default: declare it in `PROJECT.md`.

## Folder map

### Machine-wide (`~/.claude-wyvrn/`)

| Path | Purpose |
|---|---|
| `HARNESS.md` | Agent rules. |
| `INDEX.md` | Agent navigation map. |
| `DECISIONS.md` | Decision procedure. |
| `conventions/` | Universal and stack-specific rules. |
| `workflows/` | Flow definitions. |
| `templates/` | Templates for every artifact type. |
| `agents/` | Subagent definitions. |
| `skills/` | Invocable skills. |
| `extensions/` | Drop-in extensions. Empty by default. |

### Per project

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Entry point for the agent. |
| `.claude-wyvrn-local/` | Your project's artifacts and overrides. Track in git. |
| `.claude-wyvrn-local/ARCHITECTURE.md` | Your project architecture. Fill in before first use. |
| `.claude-wyvrn-local/features/` | Feature specs. |
| `.claude-wyvrn-local/fixes/` | Fix specs. |
| `.claude-wyvrn-local/refactors/` | Refactor specs. |
| `.claude-wyvrn-local/decisions/` | Decision records. |
| `.claude-wyvrn-local/clarifications/` | Clarification batches. |
| `.claude-wyvrn-local/reviews/` | Verifier reports. |
| `.claude-wyvrn-local/verifier-gaps/` | Verifier gap reports. |
| `.claude-wyvrn-local/conventions/` | Project-specific stack conventions (optional). |
| `.claude-wyvrn-local/.archive/` | Archived artifacts. Off-limits to agents during flows. |

## What not to do

- **Don't edit files under `~/.claude-wyvrn/`** directly unless you're updating the machine-wide harness intentionally. To customize for one project, use `.claude-wyvrn-local/` overrides.
- **Don't hand-write artifacts.** Artifacts come from templates through flows. Writing them by hand bypasses template compliance and verification.
- **Don't answer agent questions by editing artifact files.** The agent asks through the session; you answer through the session. Agents record your answers in the artifacts.
- **Don't skip the verifier.** A flow is not complete without a successful verifier pass.
- **Don't expand flow scope mid-flow.** If you realize you want more, either let the current flow close and start a new one, or respond to the out-of-scope prompt when it appears.

## Where to learn more

The files under `~/.claude-wyvrn/` are the authoritative reference. They're written for agents but are also readable by humans. In order of usefulness for a dev who wants to understand the system:

1. `~/.claude-wyvrn/HARNESS.md` — the rules agents follow.
2. `~/.claude-wyvrn/workflows/WORKFLOW.md` — what happens during a flow.
3. `~/.claude-wyvrn/DECISIONS.md` — how agents classify decisions and when they stop to ask.
4. `~/.claude-wyvrn/conventions/CONVENTIONS.md` — how agents produce code and artifacts.
5. `~/.claude-wyvrn/INDEX.md` — the map of where everything lives.

Individual flow types, agents, and skills have their own files under `workflows/`, `agents/`, and `skills/`.

## Version

See `~/.claude-wyvrn/VERSION` for the installed harness version.
