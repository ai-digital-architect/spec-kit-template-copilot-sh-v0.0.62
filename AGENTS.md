---
post_title: "AI Agents Guide — SpecKit Template v0.0.62"
author1: "Project Maintainers"
post_slug: "agents-guide-speckit-v0-0-62"
microsoft_alias: "n/a"
featured_image: "https://via.placeholder.com/1200x630.png?text=AI+Agents+Guide"
categories: ["Engineering"]
tags: ["AI Agents", "SpecKit", "Workflows"]
ai_note: "Created/maintained with AI assistance."
summary: "Cross‑agent guidance for working effectively with the Spec‑Driven Development template, including context updates, file locations, and troubleshooting."
post_date: "2025-10-12"
---

## Purpose

Provide cross‑agent guidance for collaborating in this Spec‑Driven Development (SpecKit) template. This complements `README.md` (project overview) and `.github/copilot-instructions.md` (Copilot‑specific rules).

> [!TIP]
> Start with `README.md` to understand the project, then use this guide to align multiple agents, and finally see `.github/copilot-instructions.md` for Copilot‑specific behavior.

## Supported agents and context files

Agent context files are updated or created by `.specify/scripts/bash/update-agent-context.sh` based on data parsed from the active feature’s `plan.md`.

| Agent | Path |
|-------|------|
| Claude Code | `CLAUDE.md` |
| Gemini CLI | `GEMINI.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Cursor IDE | `.cursor/rules/specify-rules.mdc` |
| Qwen Code | `QWEN.md` |
| Codex / opencode | `AGENTS.md` |
| Windsurf | `.windsurf/rules/specify-rules.md` |
| Kilo Code | `.kilocode/rules/specify-rules.md` |
| Auggie CLI | `.augment/rules/specify-rules.md` |
| Roo Code | `.roo/rules/specify-rules.md` |
| CodeBuddy | `.codebuddy/rules/specify-rules.md` |
| Amazon Q Dev CLI | `AGENTS.md` |

> [!NOTE]
> If no agent files exist, the updater creates a default Claude file using `.specify/templates/agent-file-template.md`.

## How agents should work with this repo

- Follow the spec → plan → tasks → implement flow; feature artifacts live under `specs/<feature-branch>/`.
- Honor the constitution at `.specify/memory/constitution.md`; gates in `plan.md` are non‑negotiable unless justified in Complexity Tracking.
- Use absolute paths with scripts; escape single quotes in args (e.g., `I'\''m Groot`).
- When a prompt is read‑only (e.g., analyze), do not write files.
- Prefer running the chat commands (`/speckit.*`) over ad‑hoc edits to keep artifacts in sync.

## Updating agent contexts

- The updater parses these fields from `plan.md` (if present):
  - `**Language/Version**:`
  - `**Primary Dependencies**:`
  - `**Storage**:`
  - `**Project Type**:`

### Update a single agent

```bash
.specify/scripts/bash/update-agent-context.sh copilot
```

```bash
.specify/scripts/bash/update-agent-context.sh claude
```

```bash
.specify/scripts/bash/update-agent-context.sh gemini
```

```bash
.specify/scripts/bash/update-agent-context.sh cursor-agent
```

### Update all existing agent files

```bash
.specify/scripts/bash/update-agent-context.sh
```

> [!IMPORTANT]
> Manual sections between markers in generated agent files are preserved. Keep custom notes within those markers.

## Troubleshooting and tips

- Branch validation failed: ensure you’re on a feature branch named `NNN-feature-name` (e.g., `001-login`). In non‑git environments, set `SPECIFY_FEATURE=<feature-folder>`.
- No `plan.md` found: run `/speckit.plan` first; it copies `.specify/templates/plan-template.md` to the active feature.
- Template missing: ensure `.specify/templates/agent-file-template.md` exists for new agent files.
- Nothing updates: confirm `plan.md` includes the required fields and that values aren’t `NEEDS CLARIFICATION`.

## References

- `README.md` — project overview, architecture, workflows
- `.github/copilot-instructions.md` — Copilot‑specific rules and workflows
- `.github/prompts/*.prompt.md` — authoritative behavior for each phase
- `.specify/scripts/bash/` — script entrypoints used by prompts