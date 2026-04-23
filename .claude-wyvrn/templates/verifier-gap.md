# Verifier gap: <title>

**Gap ID:** <GAP-NNNN>
**Flow ID:** <FEAT-NNNN | FIX-NNNN | REF-NNNN>
**Reported at:** <ISO 8601 timestamp>
**Status:** <Open | Addressed | Accepted>

> [template] A gap report is produced when a human correction after flow close implies the verifier should have caught an issue but did not. The gap is surfaced to the human for subsequent verifier update consideration. No automatic verifier change is made.

## Issue

<What the human correction revealed that the verifier missed.>

## Verifier scope

> [template] What the verifier checked when it missed this issue. Reference specific sections of the verifier agent's definition or the flow's Verify deltas.

<verifier scope>

## Why it was missed

> [template] Analysis of why the verifier's current checks did not catch this. Imperative and specific.

<analysis>

## Suggested update

> [template] What could be changed in the verifier, the spec template, or the flow deltas to catch this class of issue in future flows. This is a suggestion only; no change is applied.

<suggested update>

## Resolution

> [template] Populated when the human addresses the gap. Records the decision taken (update verifier, update template, accept as-is, defer).

**Resolved at:** <ISO 8601 timestamp, or `<pending>`>
**Resolution:** <decision, or `<pending>`>
