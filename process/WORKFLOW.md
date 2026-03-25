# WORKFLOW.md — Development Phases & Checkpoints

> **Prerequisite:** You have read CLAUDE.md and INDEX.md.
> This file defines the phases of building a feature. One feature = one pass through these phases.

---

## Phase 0: Read & Scan

**Purpose:** Understand the spec, verify it's the right size, and surface all gaps before writing code.

1. Follow the Reading Route from INDEX.md for your task.
2. Read all decision records in `decisions/` that relate to your feature or its dependencies.
3. Run **Section 0: Scope Check** from `process/GAP_SCAN.md` FIRST.
   - If any metric triggers SPLIT: file an HIR with a split proposal. **STOP. Do not continue until the human responds.**
   - If the human approves the split: this session ends. New feature specs must be written for the sub-features.
   - If the human overrides: log the override in `decisions/` and continue.
4. Run the **Pre-Implementation Gap Scan** (Sections 1-6).
5. File HIRs for every ABSENT item.
6. **WAIT** for all HIRs to be resolved before proceeding.

**Exit gate:** Scope check passed or overridden. Zero open HIRs. Gap Scan results recorded in `reviews/`.

---

## Phase 1: Scaffold

**Purpose:** Create the files and structure for this feature. Zero logic.

1. Create only the files this feature needs, as defined in `technical/MODULES.md`.
2. Add empty functions / stubs with comments referencing the spec requirement they'll satisfy.
3. Verify the project still compiles/runs.

**Rules:**
- No application logic in this phase.
- No files beyond what MODULES.md defines. If you need a new file, file an HIR.

**Exit gate:** Project compiles. All stubs reference a spec requirement.

---

## Phase 2: Implement

**Purpose:** Fill in the stubs with spec-compliant code.

For each acceptance criterion in the feature spec:

1. Write the code that satisfies it.
2. After each logical unit, run the self-check:
   - "Can I cite a spec line for this code?"
   - "Would another agent do this differently?"
   - "Am I changing anything outside my scope?"
3. Log any INFERRED decisions in `decisions/`.
4. If you hit an UNDECIDED or CONTRADICTION: STOP, file an HIR, wait.

**Rules:**
- One acceptance criterion at a time. Don't jump ahead.
- If a later AC contradicts an earlier one, file an HIR. Don't resolve it yourself.

**Exit gate:** All acceptance criteria implemented.

---

## Phase 3: Verify

**Purpose:** Confirm the implementation matches the spec — nothing more, nothing less.

1. Run the **Post-Implementation Gap Scan** (`process/GAP_SCAN.md`, Sections 7-8).
2. For each acceptance criterion, verify it passes and document HOW you verified it.
3. Write the **Completion Report** in the feature spec file.
4. Record Gap Scan results in `reviews/`.

**Exit gate:** All ACs verified. Gap Scan clean. Completion report written.

---

## What To Do When Blocked

| Situation | Action |
|---|---|
| Waiting for HIR resolution | State that you are blocked. Do NOT work around it. |
| Found a bug in a prior feature | File an HIR. Do NOT fix another feature's code. |
| Feature is larger than expected | File an HIR suggesting a split. Do NOT expand scope silently. |
| Spec changed mid-work | STOP. Re-read the changed spec. Report impact before continuing. |
| Prior feature's code doesn't work as expected | File an HIR. Reference the prior feature's completion report. |
