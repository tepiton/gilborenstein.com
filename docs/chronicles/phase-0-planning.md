# Phase 0: Planning

## Entry 1: Design and tracking setup (2026-09-28)

**What**: Reviewed `pandoc-simple` and `resume-pipeline`, agreed on a design, and created `CLAUDE.md` and the `docs/` tracking files.

**Why**: Turn the resume pipeline into a Mimeo template built by a GitHub Action, without duplicating build logic.

**How**:

- Read `pages.yml`, `html.template.pandoc`, `mimeo.template.json`, and resume-pipeline's `build.sh`, templates, and docs
- Asked six design questions; answers recorded as DEC-001 to DEC-006
- Added DEC-007 (do not register the template until approved)
- Wrote `CLAUDE.md`, `docs/IMPLEMENTATION.md` (5 phases), `docs/DECISIONS.md`, `docs/CONTEXT.md`

**Decisions**:

- DEC-001: resume.md single source with frontmatter
- DEC-002: separate customizable index.md
- DEC-003: build.sh shared by CI and local
- DEC-004: html.template.pandoc for index, resume.css for resume HTML
- DEC-005: Gil's resume as sample
- DEC-006: default fonts in CI
- DEC-007: no registration until approved

**Files**: `CLAUDE.md`, `docs/`
