# template-check

Invokes the `template-verifier` agent on a specific artifact.

## Trigger

Slash command: `/template-check <artifact-path>`

Natural language: "check template compliance on X" or equivalent.

Invoked by agents automatically on every artifact write per `HARNESS.md` §4.6. Devs may invoke directly to check an artifact outside a flow.

## Description

Checks structural compliance of an artifact against its template. Returns findings.

## Inputs

- Artifact path.
- Template path (optional; derivable from artifact folder via `INDEX.md` if not provided).

## Behavior

1. If template path not provided, derive from the artifact's folder using the `INDEX.md` artifacts table.
2. Invoke `template-verifier` subagent in a fresh context with the template path and artifact path.
3. `template-verifier` returns findings.
4. Return findings to the invoking agent or dev.

## Outputs

- Return value: findings list (may be empty).
- No artifact is written.

## Invokes

- `template-verifier` (subagent).
