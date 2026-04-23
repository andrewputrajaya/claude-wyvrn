# Refactor: <title>

> [template] Title is from the initial prompt. Do not modify after Clarify ends.

**Flow ID:** <REF-NNNN>
**Status:** <Draft | Clarifying | Working | Verifying | Validated | Failed>
**Created:** <ISO 8601 timestamp>

## Target area

> [template] Files, modules, or code regions to be refactored. List as paths or identifiers. Precise — not "the auth stuff" but "src/auth/*.ts and src/api/middleware/auth.ts".

<target area>

## Desired shape

> [template] The intended structure, pattern, decomposition, or renaming after the refactor. Developed during Clarify if not in initial prompt.

<desired shape>

## Preservation statement

> [template] The behavior, interface, and invariants that must not change. Each invariant is testable — name a test or an observable behavior.

<preservation statement>

## Scope boundary

> [template] What is explicitly out of scope. If the initial prompt or Clarify produced no scope boundary, write "N/A". Do not leave empty.

<out-of-scope items, or N/A>

## Rationale

> [template] Optional. Why the refactor is being done. If none, write "N/A".

<rationale, or N/A>

## Baseline

> [template] Populated at Work step 4.1, before any code modification. Records the pre-refactor test suite state.

**Captured at:** <ISO 8601 timestamp>
**Test suite command:** <command used to run tests>

### Baseline results

> [template] List every test with its pre-refactor status. Format: one line per test, `<test identifier>: pass | fail`.

<baseline test results>

## Implementation notes

> [template] Populated during Work. Captures the refactor approach, sequence of changes, and any decision records (DEC-NNNN) relevant to the refactor.

<implementation notes, or N/A>

## Completion record

> [template] Populated by the verifier at Verify success. Do not fill manually.

**Verifier report:** <path to verifier report artifact>
**Flow closed:** <ISO 8601 timestamp>
