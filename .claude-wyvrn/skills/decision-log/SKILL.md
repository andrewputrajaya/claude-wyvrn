# decision-log

Creates a decision record.

## Trigger

Slash command: `/decision-log`

Natural language: "log a decision" or equivalent.

Invoked by agents when classifying a decision as INFERRED or when recording a HUMAN_OVERRIDE per `DECISIONS.md` §6.2.

## Description

Writes a decision record using the decision template. Assigns the next DEC-NNNN ID. Runs template-verifier.

## Inputs

- Flow ID (the flow in which the decision was made).
- Classification (`INFERRED` or `HUMAN_OVERRIDE`).
- Title (short description).
- Context, decision, rationale, sources cited, scope, consequences — the decision template fields.

## Behavior

1. Scan `claude-wyvrn-local/decisions/` for highest existing `DEC-NNNN`. Increment by 1.
2. Generate slug from title.
3. Load template at `.claude-wyvrn/templates/decision.md`.
4. Fill template fields with provided inputs. Use `<pending>` for fields not yet determinable.
5. Write to `claude-wyvrn-local/decisions/DEC-NNNN-[slug].md`.
6. Invoke `template-check` on the written file.
7. If template findings, correct and re-check until clean.
8. Return the decision record path.

## Outputs

- Return value: path to the new decision record.
- Side effect: decision record artifact created.

## Invokes

- `template-check` (utility skill).
- `template-verifier` (subagent, via template-check).
