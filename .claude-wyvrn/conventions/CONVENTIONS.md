# CONVENTIONS.md

Conventions for agent-produced output. Code and artifact authorship. Structural rules in `HARNESS.md`. Decision procedure in `DECISIONS.md`.

## 1. Conventions system

### 1.1 Folders

- `.claude-wyvrn/conventions/` — package-shipped conventions. Baseline.
- `claude-wyvrn-local/conventions/` — project-specific conventions. Overrides package conventions on the same stack.

Universal rules below. Stack-specific files carry stack-specific rules.

### 1.2 Stack files

Each stack file lives at `conventions/[stack].md` in either territory. `[stack]` is a short identifier (e.g., `js`, `python`, `cpp`, `csharp`).

Every stack file declares its applicable file extensions in a header block at the top of the file.

### 1.3 Discovery and selection

At flow start:

1. Read all files in `.claude-wyvrn/conventions/` and `claude-wyvrn-local/conventions/`.
2. Build a map from file extension to stack file. On the same extension, project file wins over package file.
3. For each source file touched during the flow, apply the matching stack file in addition to this universal file.
4. If a touched extension has no matching stack file, apply only this universal file, and add a clarification asking whether a stack file should be created.

### 1.4 Precedence on conflict

Within a single source file:

1. `claude-wyvrn-local/conventions/[stack].md` rules.
2. `.claude-wyvrn/conventions/[stack].md` rules.
3. This file.
4. Observed conventions in the existing codebase (see §2.1).

Most specific wins. Project stack rules override package stack rules, which override universal rules.

## 2. Code production

### 2.1 Match existing style

When modifying or extending an existing codebase, match the style already in use: naming, file structure, import and dependency patterns.

Observed style overrides written conventions only when the existing code is internally consistent. Inconsistent codebases fall back to written conventions.

### 2.2 No speculative code

Do not produce:

- Commented-out code.
- TODO markers.
- Placeholder implementations or stubs, unless explicitly requested.
- Future-proofing for requirements not in the current scope.

Every line produced must serve the current task.

### 2.3 No new dependencies without a decision

Do not add a library, package, framework, or external tool without:

- Explicit instruction in the spec or initial prompt, or
- An INFERRED decision record via the `decision-log` skill citing why the dependency is unavoidable.

Adding a dependency because it "would be useful" or "is standard" is prohibited. If a dependency seems required but is not explicitly authorized, classify as UNDECIDED per `DECISIONS.md`.

### 2.4 No silent reformatting

Do not reformat code outside the task scope:

- No whitespace changes outside edited lines.
- No reordering of imports or declarations outside edited sections.
- No applying different style rules to untouched code.

Reformat only what is being modified for functional reasons.

### 2.5 No silent renames

Do not rename variables, functions, classes, files, or paths unless the rename is explicitly required by the task. Renames are high-impact and require explicit authorization.

### 2.6 Test production

General test rules. Stack-specific test rules (framework, file naming, runner invocation) live in stack files.

- Feature flow: new tests covering each acceptance criterion in the spec.
- Fix flow: at least one test that would have caught the bug. No regression in existing tests.
- Refactor flow: preserve existing test behavior. Do not delete or weaken tests without a decision record.
- Tests are written before declaring implementation complete.
- Do not mask, skip, or mark failures as expected without a decision record.

## 3. Artifact authorship

Artifacts are markdown files produced in `claude-wyvrn-local/` — specs, decision records, clarification batches, verifier reports, verifier gaps.

### 3.1 Agent-facing style

Every artifact is agent-facing. Optimize for agent parsing:

- Numbered or bulleted lists over prose.
- Imperative voice. Short sentences. One claim per line.
- Explicit structure via headings. No meta-commentary about the document.
- Tables for structured data.
- No decorative elements (banners, emoji, welcome messages).
- Brief prose only where structure would obscure meaning.

The human reads some artifacts at flow boundaries but reads them accepting this style. Do not adjust style to be "friendlier" to the human.

### 3.2 No prose preamble

Do not open any artifact with introductory prose about what the document is or why it exists. Template structure carries this. Begin with content under the first section.

### 3.3 Template compliance

Every artifact must match its template structurally. Rules are in `HARNESS.md` §4. Enforcement is by the `template-verifier` agent. Section presence, order, and naming are fixed by the template.

### 3.4 Template marker convention

Templates use `> [template]` blockquote markers to distinguish instructional content from structural content:

- Lines starting with `> [template]` contain instructions for the agent filling the template. They are not part of the artifact structure.
- Do not copy `> [template]` lines into the output artifact.
- All other lines (headings, list items, tables, prose) are structural and must appear in the output artifact as-is, with `<placeholder>` tokens replaced by content.

The `template-verifier` agent strips `> [template]` lines before comparing template structure to artifact structure.
