# OPERATIONS.md — How to Orchestrate Agent Work

> **Audience:** This file is for the HUMAN, not the agent.
> It defines how to feed work to agents, size iterations, and prevent the failure modes
> that emerge at scale.

---

## The Core Problem

AI agents degrade in three predictable ways over iterative work:

1. **Context decay.** The longer the conversation, the more the agent's grip on the spec loosens. Details from early messages get deprioritized or forgotten.
2. **Assumption compounding.** One small assumption in iteration 1 becomes the foundation for iteration 2's assumptions, which become iteration 3's "facts." The drift accelerates.
3. **Scope creep by accumulation.** Each iteration adds a tiny bit of unspecified behavior. After 10 iterations, the product is 30% unspecified.

This system fights all three. But the system only works if you operate it correctly.

---

## Principle 1: One Feature, One Session

**An iteration is ONE feature spec, start to finish.**

Do not ask an agent to build multiple features in a single session. Each feature is an isolated unit of work:

```
Session 1: FEAT-0001 (user authentication)  → completion report
Session 2: FEAT-0002 (data persistence)     → completion report
Session 3: FEAT-0003 (notification system)  → completion report
```

### Why

- Each new session forces the agent to re-read the specs from scratch. This is a FEATURE, not a bug. It resets context decay.
- The completion report from Session 1 becomes permanent memory for Session 2. The decisions log carries institutional knowledge across sessions.
- If Session 2 goes off the rails, you've only lost one feature — not the whole project.

### Sizing Features

The Gap Scan includes a **Scope Check** (Section 0 of `process/GAP_SCAN.md`) with concrete thresholds — things like more than 8 requirements, more than 10 acceptance criteria, more than 3 entity interactions, or touching more than 2 modules. If any threshold is exceeded, the agent must propose a split before proceeding.

You can also use these thresholds when writing specs. If you notice your feature spec crossing these limits as you draft it, split proactively:

| Too Large | Split Into |
|---|---|
| "Implement payment system" | FEAT-A: Payment data model, FEAT-B: Payment processing, FEAT-C: Payment UI, FEAT-D: Receipt generation |
| "Build the dashboard" | FEAT-A: Dashboard data aggregation, FEAT-B: Dashboard layout, FEAT-C: Dashboard widgets |
| "Create the search feature" | FEAT-A: Search indexing, FEAT-B: Query parsing, FEAT-C: Results display |

**The human test:** Can the feature's acceptance criteria be verified in under 15 minutes? If not, it's too large.

---

## Principle 2: Sequential Over Parallel

**Build features one at a time, in dependency order. Do not parallelize.**

```
CORRECT:
  FEAT-0001 → done → FEAT-0002 → done → FEAT-0003 → done

WRONG:
  FEAT-0001 ─┐
  FEAT-0002 ──┼── merge → chaos
  FEAT-0003 ─┘
```

### Why

- Parallel work requires agents to predict how other agents' code will look. This is pure assumption — exactly what we're trying to eliminate.
- Merge conflicts between agent-written code are far harder to resolve than merge conflicts between human-written code, because agents can't reliably reason about another agent's unfinished work.
- Sequential work lets each feature build on verified, complete foundations.

### The One Exception

You may parallelize ONLY when both conditions are true:
1. The features share ZERO code files, ZERO state, and ZERO interactions per the spec.
2. The features are in completely separate modules with no interface between them per ARCHITECTURE.md.

This is rare. When in doubt, go sequential.

---

## Principle 3: Spec First, Code Second

**Never start a coding session before the spec for that feature is complete.**

The workflow:

```
Step 1: YOU write the feature spec (using the template).
Step 2: YOU or an AGENT runs the Gap Scan (process/GAP_SCAN.md) on the spec.
Step 3: YOU resolve all gaps found by the scan.
Step 4: The spec reaches APPROVED status.
Step 5: An agent implements the feature.
```

### Using an Agent as a Spec Reviewer

You can use a dedicated agent session to review your specs before handing them to a building agent:

```
Prompt: "Read specs/process/GAP_SCAN.md. Then read specs/product/features/[name].md.
         Run the full pre-implementation gap scan and report all ABSENT items.
         Do NOT attempt to fill the gaps — just report them."
```

This uses the agent as an auditor, not a builder. It catches YOUR blind spots in the spec using the mechanical checklist.

---

## Principle 4: Hard Boundaries on Agent Sessions

### Starting a Session

Every agent session gets the same opening prompt structure:

```
SYSTEM/PROMPT:
You are working on [project name].
Your task is to implement feature FEAT-[NNNN]: [feature name].

Before doing anything, read these files in this exact order:
1. specs/CLAUDE.md
2. specs/INDEX.md
3. Follow Reading Route A from INDEX.md for your feature.

Do not write any code until you have:
- Completed the reading route
- Run the pre-implementation Gap Scan
- Filed HIRs for any ABSENT items
- Received resolution for all HIRs

Your scope is ONLY the feature spec at specs/product/features/[name].md.
Do not modify code or specs outside this scope.
```

### Mid-Session Resets

If the agent starts showing signs of drift (introducing unspecified behavior, making assumptions without logging them, getting "creative"), you can force a reset:

```
STOP. Re-read specs/CLAUDE.md and your feature spec at
specs/product/features/[name].md.

List every acceptance criterion.
For each one, state whether it is DONE, IN PROGRESS, or NOT STARTED.
Do not write any code in this response.
```

This forces the agent to re-anchor to the spec and give you a checkpoint.

### Ending a Session

Before closing a session, require:

```
Before we end:
1. Run the post-implementation Gap Scan (specs/process/GAP_SCAN.md, Sections 7-8).
2. Write the completion report in your feature spec.
3. Confirm every acceptance criterion status.
4. List every decision record you created in decisions/.
```

---

## Principle 5: The Spec Tree Stays Lean

As the project grows, actively manage spec size:

### The Depth Rule

| Depth | Max Size | Content |
|---|---|---|
| Root (CLAUDE.md, INDEX.md) | ~2 pages each | Universal rules, navigation only |
| Domain (OVERVIEW.md, ARCHITECTURE.md) | ~3-4 pages each | Summary-level information |
| Detail (feature specs, MODULES.md) | ~2-3 pages each | Specific to one feature or module |
| Record (decisions, reviews) | ~0.5-1 page each | One decision or review per file |

### When a File Gets Too Long

If a domain-level file grows past 4 pages, it's accumulating detail that belongs at a lower level. Split it:

```
BEFORE (too long):
  product/OVERVIEW.md (8 pages, includes detailed notification routing rules)

AFTER (correctly split):
  product/OVERVIEW.md (3 pages, references notification feature)
  product/features/notification-routing.md (3 pages, detailed notification spec)
```

The higher file retains a one-line summary and a cross-reference. The detail moves down.

### When to Prune

After every 5 features completed:
- Review the decisions log. Any decisions that have been implemented and are now reflected in updated specs can be marked `ARCHIVED`. Don't delete them, but move them to a `decisions/archive/` subfolder so active agents aren't reading stale decisions.
- Review the reviews log. Completed reviews for finished features can similarly be archived.

---

## Principle 6: Human Input Is Not a Bottleneck — It's a Feature

You WILL get a lot of Human Input Requests, especially at the start. This is correct behavior.

### How to Handle HIR Volume

1. **Batch them.** After the agent runs the Gap Scan, collect all HIRs before answering. Answer them all at once. This is faster than answering one-at-a-time with context switches.

2. **Answer precisely.** Don't give prose explanations — give the specific value, choice, or rule the agent needs. The agent will record your answer verbatim.

3. **Push detail into the spec.** After answering an HIR, update the feature spec yourself with the answer. This prevents the next agent from asking the same question. The spec should get MORE complete over time, not accumulate a pile of disconnected HIR answers.

4. **Notice patterns.** If multiple features generate the same type of HIR (e.g., "what color should the UI element be?"), you have a gap in your Domain-level specs. Add a visual standards section to OVERVIEW.md.

### Diminishing HIRs Over Time

If the system is working correctly:
- **First feature:** Many HIRs (your specs are still incomplete).
- **Fifth feature:** Fewer HIRs (patterns are established).
- **Tenth feature:** Rare HIRs (specs are mature).

If HIR volume isn't decreasing, your specs aren't absorbing the answers. Check that decisions are being propagated back into the spec files.

---

## Principle 7: Verify, Don't Trust

After every agent session, spend 5 minutes on a human review:

1. **Read the completion report.** Does it claim all ACs pass?
2. **Spot-check one AC.** Actually run the feature and verify one acceptance criterion yourself.
3. **Read the decisions log entries.** Did the agent make any inferences you disagree with?
4. **Check for scope creep.** Is there anything in the implementation that isn't in the spec? If so, either add it to the spec (if you want it) or tell the next agent to remove it.

This 5-minute check catches drift before it compounds.

---

## Quick Reference: Session Lifecycle

```
┌─────────────────────────────────────────────────┐
│  BEFORE SESSION                                  │
│  1. Feature spec is written and APPROVED         │
│  2. Gap Scan has been run on the spec            │
│  3. All spec gaps are resolved                   │
│  4. Dependencies (prior features) are complete   │
└──────────────────────┬──────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────┐
│  START SESSION                                   │
│  1. Agent reads CLAUDE.md → INDEX.md → Route A   │
│  2. Agent reads decisions/ for prior context      │
│  3. Agent runs pre-implementation Gap Scan       │
│  4. Agent files HIRs for any remaining gaps      │
│  5. Human resolves HIRs                          │
└──────────────────────┬──────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────┐
│  IMPLEMENTATION                                  │
│  - Agent builds one feature per spec             │
│  - Agent logs inferences in decisions/           │
│  - Agent asks (HIR) when hitting UNDECIDED items │
│  - Human can force mid-session reset if needed   │
└──────────────────────┬──────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────┐
│  END SESSION                                     │
│  1. Agent runs post-implementation Gap Scan      │
│  2. Agent writes completion report               │
│  3. Human spot-checks one AC                     │
│  4. Human reviews decision log entries           │
│  5. Human propagates answers into specs          │
└──────────────────────┬──────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────┐
│  BETWEEN SESSIONS                                │
│  - Update specs with new decisions               │
│  - Archive completed decisions/reviews           │
│  - Prep the next feature spec                    │
│  - Run Gap Scan on next spec (optional)          │
└─────────────────────────────────────────────────┘
```
