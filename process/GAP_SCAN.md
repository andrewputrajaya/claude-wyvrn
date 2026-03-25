# GAP_SCAN.md — Mechanical Spec Completeness Checklist

> **Purpose:** This checklist catches spec gaps that agent judgment misses.
> It does NOT rely on the agent "noticing" a problem. It is a mechanical audit.
> Run this checklist BEFORE implementing a feature and AFTER completing it.
> Results are recorded in `reviews/[feature]-review.md`.

---

## Why This Exists

The Certainty Framework (CLAUDE.md) relies on agents recognizing ambiguity. But agents share systematic blind spots — if two agents both assume the same thing, neither will flag it. This checklist forces agents to mechanically verify spec completeness by checking for the PRESENCE of specific information, not by judging whether the information is "clear enough."

**The principle:** Don't ask "do I understand this?" Ask "does the spec CONTAIN this specific piece of information?"

---

## Section 0: Scope Check (Run FIRST)

**Purpose:** Detect features that are too broad, too vague, or too large BEFORE any other analysis. If this section triggers, the feature must be split before proceeding. Do not run Sections 1-8 on an oversized feature — it wastes effort on a spec that will be restructured.

Count the following from the feature spec and record the numbers:

| Metric | Count | Threshold | Status |
|---|---|---|---|
| **SC-01:** Number of requirements (REQ-* rows) | | > 8 = SPLIT | |
| **SC-02:** Number of acceptance criteria (AC-* items) | | > 10 = SPLIT | |
| **SC-03:** Number of distinct entities or systems introduced | | > 3 = SPLIT | |
| **SC-04:** Number of OTHER features listed in Interactions section | | > 3 = SPLIT | |
| **SC-05:** Number of distinct screens or UI views this feature creates | | > 2 = SPLIT | |
| **SC-06:** Number of distinct states an entity can be in (sum all entities) | | > 8 = SPLIT | |
| **SC-07:** Number of rows in Data/Values table | | > 12 = SPLIT | |
| **SC-08:** Number of TBD values in Data/Values table | | any = BLOCK | |
| **SC-09:** Word count of the Behavior section (4.1 + 4.2 + 4.3) | | > 800 words = SPLIT | |
| **SC-10:** Number of modules touched (cross-reference MODULES.md) | | > 2 = SPLIT | |

### Interpreting Results

**If ANY metric hits SPLIT:**

File an HIR with this exact structure:

```
## HUMAN INPUT REQUEST — Feature Split Required

**Priority:** BLOCKER
**Feature:** FEAT-[NNNN] — [name]
**Gap Scan Check:** SC-[NN]

### Scope Violation
[Which metric(s) exceeded the threshold and by how much.]

### Proposed Split
Based on the spec, this feature can be decomposed into:

- **Sub-feature A:** [name] — covers REQ-01, REQ-02, REQ-03
  - Scope: [one sentence describing what it does]
  - Dependencies: [what it needs from other features]

- **Sub-feature B:** [name] — covers REQ-04, REQ-05
  - Scope: [one sentence]
  - Dependencies: [Sub-feature A, other features]

- **Sub-feature C:** [name] — covers REQ-06, REQ-07, REQ-08
  - Scope: [one sentence]
  - Dependencies: [Sub-feature A, Sub-feature B]

### Split Rationale
[Why these groupings? What natural seams exist in the spec?]
```

**DO NOT proceed to Section 1 until the human approves the split (or overrides and says the feature is fine as-is).**

**If SC-08 hits BLOCK:** TBD values mean the spec is incomplete. File an HIR for each TBD value. These must be resolved before the feature can proceed regardless of size.

### Finding Natural Split Points

When proposing a split, look for these seams:

1. **Data vs. Display:** Can you separate the underlying system from its UI? (e.g., "Cart data model" vs. "Cart UI")
2. **Input vs. Processing vs. Output:** Can you isolate how data enters, transforms, and exits? (e.g., "Input handling" vs. "Validation logic" vs. "Response rendering")
3. **Entity boundaries:** Does the feature involve multiple distinct entities? Each entity might be its own sub-feature. (e.g., "User accounts" vs. "Permissions" vs. "Audit logging")
4. **State machine phases:** Does the feature have distinct lifecycle phases? Each phase might split. (e.g., "Order creation" vs. "Order fulfillment" vs. "Order completion")
5. **Module boundaries:** Does the feature cross module lines in MODULES.md? Each module's portion might be a sub-feature.

### Override

If the human reviews the split recommendation and responds that the feature should remain whole, record this as a decision in `decisions/` with the human's rationale. Proceed to Section 1.

---

## Pre-Implementation Scan

Run this BEFORE writing any code for a feature. For each item, answer PRESENT / ABSENT / N/A.

**Prerequisite:** Section 0 (Scope Check) has passed or been overridden by the human.

### Section 1: Values & Numbers

For every variable, parameter, or quantity the feature involves, check:

| Check | Question | Status |
|---|---|---|
| V-01 | Does the spec assign a concrete numeric value (not "fast," "large," "a few")? | |
| V-02 | Does the spec define the UNIT for each value (pixels, seconds, ms, bytes, items, percentage)? | |
| V-03 | Does the spec define MINIMUM and MAXIMUM bounds for variable values? | |
| V-04 | Does the spec define the INITIAL / DEFAULT value? | |
| V-05 | If a value changes over time, does the spec define the rate and formula? | |

**If any item is ABSENT:** File an HIR. Do not estimate, infer, or use "reasonable" defaults.

### Section 2: States & Transitions

For every entity or system the feature involves:

| Check | Question | Status |
|---|---|---|
| S-01 | Does the spec list ALL possible states the entity can be in? | |
| S-02 | For each state, does the spec define what the entity LOOKS like? | |
| S-03 | For each state, does the spec define what the entity DOES (behavior)? | |
| S-04 | Does the spec define every valid transition BETWEEN states? | |
| S-05 | Does the spec define what TRIGGERS each transition? | |
| S-06 | Does the spec define the INITIAL state? | |
| S-07 | Does the spec define what happens in INVALID transitions (error states)? | |

**If any item is ABSENT:** File an HIR.

### Section 3: Boundaries & Edges

| Check | Question | Status |
|---|---|---|
| B-01 | What happens at ZERO? (zero items, zero results, zero balance, zero time remaining) | |
| B-02 | What happens at MAXIMUM? (max capacity, full storage, max connections, time limit) | |
| B-03 | What happens with NEGATIVE input? (underflow, invalid negative values) | |
| B-04 | What happens on SIMULTANEOUS events? (two things happen on the same frame/tick) | |
| B-05 | What happens on RAPID REPEAT? (button mashed, event fires multiple times) | |
| B-06 | What happens on EMPTY state? (no items to display, no enemies alive, nothing loaded) | |

**If any item is ABSENT and the boundary is reachable during normal or abnormal use:** File an HIR.

### Section 4: Interactions

| Check | Question | Status |
|---|---|---|
| I-01 | Does the spec list every OTHER feature this feature interacts with? | |
| I-02 | For each interaction, does the spec define WHO initiates it? | |
| I-03 | For each interaction, does the spec define WHAT data is exchanged? | |
| I-04 | For each interaction, does the spec define the ORDER of operations? | |
| I-05 | If Feature A and Feature B both modify the same state, does the spec define priority? | |

**If any item is ABSENT:** File an HIR.

### Section 5: Visual / UI

If the feature has any user-facing element:

| Check | Question | Status |
|---|---|---|
| U-01 | Does the spec define POSITION (coordinates, anchor, or layout rule)? | |
| U-02 | Does the spec define SIZE (width, height — in concrete units)? | |
| U-03 | Does the spec define COLORS (hex codes, not "red" or "dark")? | |
| U-04 | Does the spec define FONT and SIZE for any text? | |
| U-05 | Does the spec define EVERY visual state (normal, hover, active, disabled, empty, error)? | |
| U-06 | Does the spec define ANIMATIONS with duration and easing? Or explicitly state NONE? | |
| U-07 | Does the spec define RESPONSIVE behavior or screen-size assumptions? | |

**If any item is ABSENT and the feature has UI:** File an HIR.

### Section 6: Acceptance Criteria Audit

| Check | Question | Status |
|---|---|---|
| A-01 | Does every requirement (REQ-*) have at least one matching acceptance criterion (AC-*)? | |
| A-02 | Is every AC written as a pass/fail test (Given/When/Then)? | |
| A-03 | Can every AC be verified without subjective judgment? | |
| A-04 | Do the ACs cover the HAPPY PATH? | |
| A-05 | Do the ACs cover at least one ERROR/EDGE case? | |
| A-06 | Are there any ACs that reference behavior not described in the spec? (orphan ACs) | |

**If any item is ABSENT or if A-06 finds orphans:** File an HIR.

---

## Post-Implementation Scan

Run this AFTER implementation, BEFORE marking the feature as complete.

### Section 7: Unspecified Code Audit

Walk through every file you created or modified and answer:

| Check | Question | Status |
|---|---|---|
| C-01 | For every constant/magic number in the code: can I cite a spec line that defines this value? | |
| C-02 | For every conditional branch: can I cite a spec line that requires this behavior? | |
| C-03 | For every UI element: can I cite a spec line that describes it? | |
| C-04 | For every function: does it serve a spec requirement, or did I add it "for good measure"? | |
| C-05 | Did I introduce any error handling behavior the spec doesn't define? | |
| C-06 | Did I introduce any default values the spec doesn't define? | |
| C-07 | Did I make any ordering/priority choices the spec doesn't mandate? | |

**If any item is flagged:** Either remove the unspecified code OR file an HIR to get it approved. Do not leave unspecified code in place.

### Section 8: Drift Detection

| Check | Question | Status |
|---|---|---|
| D-01 | Read the feature spec's Purpose section. Does my implementation do EXACTLY that and NOTHING more? | |
| D-02 | Count the features/behaviors in my implementation. Count the requirements in the spec. Do the counts match? | |
| D-03 | Is there any "polish" I added that the spec didn't request? | |
| D-04 | Did I modify any file that isn't listed in this feature's scope? | |

---

## Recording Results

After running the scan, create a review record in `reviews/[feature-name]-review.md`:

```markdown
# Review: [Feature Name]

**Date:** [timestamp]
**Agent:** [identifier]
**Scan Type:** PRE-IMPLEMENTATION | POST-IMPLEMENTATION
**Feature Spec:** `product/features/[name].md`

## Results Summary
- **Total checks run:** [N]
- **PRESENT:** [N]
- **ABSENT:** [N] → HIRs filed: [list HIR IDs]
- **N/A:** [N]

## Gaps Found
| Check ID | Gap Description | HIR Filed |
|---|---|---|
| [e.g., V-01] | [e.g., request timeout has no numeric value] | HIR-0005 |

## Notes
[Any additional observations about spec quality or completeness.]
```
