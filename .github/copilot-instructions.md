
---
post_title: "Copilot Instructions — SpecKit Template v0.0.62"
author1: "Project Maintainers"
post_slug: "copilot-instructions-speckit-v0-0-62"
microsoft_alias: "n/a"
featured_image: "https://via.placeholder.com/1200x630.png?text=Copilot+Instructions"
categories: ["Engineering"]
tags: ["Copilot", "SpecKit", "Workflows"]
ai_note: "Created/maintained with AI assistance."
summary: "Practical rules and workflows for GitHub Copilot to work effectively with the Spec‑Driven Development template."
post_date: "2025-10-12"
---

## Purpose
Make Copilot productive in this Spec‑Driven Development (SpecKit) template by following the repo’s workflows, files, and guardrails.

> [!TIP]
> See also: `AGENTS.md` (cross‑agent guidance) and `README.md` (project overview).

## Big picture
- Spec‑driven flow: feature spec → plan → tasks → implement; each feature lives in `specs/<feature-branch>/` (created by scripts).
- Feature folder is keyed by current branch; enforced naming `NNN-feature-name` (see `.specify/scripts/bash/common.sh`).
- Constitution at `.specify/memory/constitution.md` sets MUST/SHOULD gates used by prompts and `plan.md`.
- Prompts in `.github/prompts/*.prompt.md` define exact phase behavior; scripts in `.specify/scripts/bash/` implement it.

## Core workflows (use these commands)
- Create/Update spec: `/speckit.specify` → runs `create-new-feature.sh` once; writes `specs/<branch>/spec.md`.
- Plan: `/speckit.plan` → runs `setup-plan.sh --json`; copies `.specify/templates/plan-template.md` to `plan.md`.
- Tasks: `/speckit.tasks` → reads plan (+ optional `research.md`, `data-model.md`, `contracts/`, `quickstart.md`) and generates `tasks.md` organized by user stories.
- Implement: `/speckit.implement` → executes `tasks.md` by phases; verifies appropriate ignore files.
- Analyze (read‑only): `/speckit.analyze` → detects ambiguity/duplication/coverage/constitution issues across spec/plan/tasks.

## Conventions specific to this repo
- Absolute paths only when invoking scripts; escape single quotes like `I'\''m Groot` when passing args (see prompts).
- Resolve “NEEDS CLARIFICATION” in `plan.md` via Phase 0 research before moving on.
- Tasks are grouped by user story; tests are optional unless requested; mark parallel tasks with `[P]`.
- “Constitution Check” in `plan.md` must pass; violations go to “Complexity Tracking” with rationale.
- Non‑git fallback: set `SPECIFY_FEATURE=<feature-folder>` if branch detection isn’t available.

## Integration points
- `check-prerequisites.sh` → JSON with `FEATURE_DIR` and `AVAILABLE_DOCS` to safely locate artifacts.
- `update-agent-context.sh copilot` → parses `plan.md` fields (Language/Version, Primary Dependencies, Storage, Project Type) and updates this file from `.specify/templates/agent-file-template.md` while preserving manual sections.
- DDD helpers in `.specify/ddd` and `.specify/templates/ddd/*` (use only if the feature calls for DDD outputs).
- VS Code auto‑approves running scripts under `.specify/scripts/bash/` (see `.vscode/settings.json`).

## Examples from this repo
- Plan fields to parse: `**Language/Version**: Python 3.11`, `**Primary Dependencies**: FastAPI`, `**Storage**: PostgreSQL`, `**Project Type**: web`.
- Expected feature tree after creation: `specs/001-login/{plan.md,research.md,data-model.md,contracts/,quickstart.md,tasks.md}`.

## Guardrails for AI agents
- Don’t invent paths or workflows—use the provided prompts and scripts.
- Respect read‑only prompts (e.g., analyze) and avoid file writes in those flows.
- Preserve template heading order; remove placeholders only as templates instruct.
- Prefer updating artifacts via `/speckit.*` commands to keep phases in sync.
- If a prerequisite artifact/folder is missing, guide the user to run the preceding command rather than bypassing the flow.

> [!NOTE]
> For cross‑agent coordination patterns and troubleshooting, refer to `AGENTS.md`.

## Changelog and versioning

Use semantic versioning for this document to signal impact on agent behavior.

### Version bump rules
- MAJOR (X.0.0): Backward‑incompatible guidance changes (e.g., replace core workflows, rename required files/paths, alter gating semantics).
- MINOR (0.Y.0): Backward‑compatible additions or significant clarifications (e.g., new sections, new examples, added guardrails).
- PATCH (0.0.Z): Minor clarifications, typo/link fixes, formatting, rewording without behavior change.

### How to update
1. Update the version reference in `post_title` if present (e.g., “Copilot Instructions — SpecKit Template vX.Y.Z”).
2. Add a dated entry under the Changelog below.
3. Ensure cross‑references with `README.md` and `AGENTS.md` remain accurate.
4. Keep headings at H2/H3 and follow `.github/instructions/markdown.instructions.md`.

### Changelog

- v0.0.62 — 2025-10-12
	- Initial consolidation for this template version; added cross‑references to `README.md` and `AGENTS.md` and codified guardrails.

Purpose: Make AI agents productive in this Spec‑Driven Development (SpecKit) template by following the repo’s workflows, files, and guardrails.

## Big picture
- Spec‑driven flow: feature spec → plan → tasks → implement; each feature lives in `specs/<feature-branch>/` (created by scripts).
- Feature folder is keyed by current branch; enforced naming `NNN-feature-name` (see `.specify/scripts/bash/common.sh`).
- Constitution at `.specify/memory/constitution.md` sets MUST/SHOULD gates used by prompts and `plan.md`.
- Prompts in `.github/prompts/*.prompt.md` define exact phase behavior; scripts in `.specify/scripts/bash/` implement it.

## Core workflows (use these commands)
- Create/Update spec: `/speckit.specify` → runs `create-new-feature.sh` once; writes `specs/<branch>/spec.md`.
- Plan: `/speckit.plan` → runs `setup-plan.sh --json`; copies `.specify/templates/plan-template.md` to `plan.md`.
- Tasks: `/speckit.tasks` → reads plan (+ optional `research.md`, `data-model.md`, `contracts/`, `quickstart.md`) and generates `tasks.md` organized by user stories.
- Implement: `/speckit.implement` → executes `tasks.md` by phases; verifies appropriate ignore files.
- Analyze (read‑only): `/speckit.analyze` → detects ambiguity/duplication/coverage/constitution issues across spec/plan/tasks.

## Conventions specific to this repo
- Absolute paths only when invoking scripts; escape single quotes like `I'\''m Groot` when passing args (see prompts).
- Resolve “NEEDS CLARIFICATION” in `plan.md` via Phase 0 research before moving on.
- Tasks are grouped by user story; tests are optional unless requested; mark parallel tasks with `[P]`.
- “Constitution Check” in `plan.md` must pass; violations go to “Complexity Tracking” with rationale.
- Non‑git fallback: set `SPECIFY_FEATURE=<feature-folder>` if branch detection isn’t available.

## Integration points
- `check-prerequisites.sh` → JSON with `FEATURE_DIR` and `AVAILABLE_DOCS` to safely locate artifacts.
- `update-agent-context.sh copilot` → parses `plan.md` fields (Language/Version, Primary Dependencies, Storage, Project Type) and updates this file from `.specify/templates/agent-file-template.md` while preserving manual sections.
- DDD helpers in `.specify/ddd` and `.specify/templates/ddd/*` (use only if the feature calls for DDD outputs).
- VS Code auto‑approves running scripts under `.specify/scripts/bash/` (see `.vscode/settings.json`).

## Examples from this repo
- Plan fields to parse: `**Language/Version**: Python 3.11`, `**Primary Dependencies**: FastAPI`, `**Storage**: PostgreSQL`, `**Project Type**: web`.
- Expected feature tree after creation: `specs/001-login/{plan.md,research.md,data-model.md,contracts/,quickstart.md,tasks.md}`.

## Guardrails for AI agents
- Don’t invent paths or workflows—use the provided prompts and scripts.
- Respect read‑only prompts (e.g., analyze) and avoid file writes in those flows.
- Preserve template heading order; remove placeholders only as templates instruct.
- Prefer updating artifacts via `/speckit.*` commands to keep phases in sync.
- If a prerequisite artifact/folder is missing, guide the user to run the preceding command rather than bypassing the flow.
