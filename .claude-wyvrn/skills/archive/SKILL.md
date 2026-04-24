# archive

Archives artifacts from closed flows.

## Trigger

Slash command: `/archive`

Natural language: "archive old flows" or equivalent.

Manual invocation only in v1. Not invoked by any flow.

## Description

Scans project-territory artifact folders for candidates based on status and age. Proposes candidates to the human via session. On approval, moves selected artifacts to `.claude-wyvrn-local/.archive/`.

## Inputs

- None required.
- Optional: age threshold in days (default: 30).

## Behavior

1. Scan the following folders for candidates:
    - `.claude-wyvrn-local/features/`
    - `.claude-wyvrn-local/fixes/`
    - `.claude-wyvrn-local/refactors/`
2. For each artifact, check:
    - Status is `Validated` or `Failed`.
    - Last modified timestamp is older than the age threshold.
3. For each candidate spec artifact, identify related artifacts:
    - Corresponding clarification batch in `.claude-wyvrn-local/clarifications/`.
    - Corresponding verifier reports in `.claude-wyvrn-local/reviews/`.
    - Decision records in `.claude-wyvrn-local/decisions/` with matching Flow ID.
    - Verifier gap reports in `.claude-wyvrn-local/verifier-gaps/` with matching Flow ID.
4. Present the candidate list to the human via session per `HARNESS.md` §8. Format: one line per flow, with counts of related artifacts.
5. Human responds with approvals, exclusions, or "cancel."
6. On approval:
    1. For each approved flow, move its spec artifact and related artifacts to `.claude-wyvrn-local/.archive/` preserving the original folder structure.
    2. Update decision records with `Status: Archived` before moving.
7. Emit `Archive complete: <N> flows archived` in session.

## Outputs

- Return value: summary of archived flows.
- Side effect: artifacts moved from active folders to `.archive/`.

## Invokes

None. Archive skill performs file operations directly.
