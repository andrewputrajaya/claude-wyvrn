# Architecture

> [template] Top-level project architecture. Human-seeded at install; updated by refactor flows. Feature and fix flows do not modify this file.

**Last updated:** <ISO 8601 timestamp>
**Last updated by:** <FEAT-NNNN | FIX-NNNN | REF-NNNN | human>

## System overview

<One paragraph describing what the system is at the highest level.>

## Modules

> [template] One subsection per module. Add subsections as the project grows. Do not remove a module subsection; mark a retired module as `**Status:** Retired` and leave the record.

### <module name>

**Path:** <directory path>
**Status:** <Active | Retired>
**Responsibility:** <one sentence>

**Interfaces:**
> [template] Public functions, classes, APIs, or entry points exposed to other modules.
- <interface>

**Dependencies:**
> [template] Other modules this module depends on. One per line.
- <dependency>

**Notes:**
> [template] Optional. Architectural constraints, historical context, or invariants specific to this module. If none, write "N/A".
<notes, or N/A>

## Cross-module contracts

> [template] Agreements between modules not enforced by the module subsections (shared schemas, event contracts, protocol versions). If none, write "N/A".

<contracts, or N/A>

## External dependencies

> [template] Third-party libraries, services, or infrastructure the system depends on. Format: one line per dependency, `<name> <version constraint> — <purpose>`.

<external dependencies>

## Architectural invariants

> [template] Top-level rules that apply to the whole system (e.g., "no module depends on UI", "all persistence goes through the data layer"). If none, write "N/A".

<invariants, or N/A>

## Change log

> [template] Append-only during normal flow. One entry per flow that modified this file. Edits to existing entries are recorded in the Changes section below, not by rewriting the entry in place.

### <ISO 8601 timestamp> — <FEAT-NNNN | FIX-NNNN | REF-NNNN>

<one-paragraph summary of what changed and why>

## Changes

> [template] Records edits made to prior sections of this document after their original write. One entry per edit. Append-only. The edit itself may modify any prior section; this section records that the edit happened, when, why, and by whom.

### <ISO 8601 timestamp> — <FEAT-NNNN | FIX-NNNN | REF-NNNN | human>

**Edited section:** <section path, e.g., "Change log > 2026-04-12 entry" or "Modules > auth">
**Reason:** <why the edit was needed>
**Summary of change:** <what was changed — before/after, or description>
