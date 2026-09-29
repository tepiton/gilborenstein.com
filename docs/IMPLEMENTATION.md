# Implementation Progress

## Phase Overview

| Phase | Name | Status |
|---|---|---|
| 0 | Planning | Complete |
| 1 | Port the pipeline | Complete |
| 2 | GitHub Action | Complete |
| 3 | Mimeo integration and docs | Complete |
| 4 | Verify and publish as template | In Progress |

## Phase 0: Planning

**Goal**: Agree on the design for turning `~/projects/resume-pipeline/` into a Mimeo template built by a GitHub Action.

### Completed

- Reviewed `pandoc-simple` workflow (`pages.yml`, `html.template.pandoc`, `mimeo.template.json`)
- Reviewed `resume-pipeline` (`build.sh`, `templates/`, README, docs)
- Design questions answered (see `DECISIONS.md` DEC-001 to DEC-006)
- `CLAUDE.md` and `docs/` tracking set up

## Phase 1: Port the pipeline

**Goal**: A local `./build.sh` in this repo produces `index`, resume HTML, PDF, DOCX, and TXT.

### Tasks

- ✅ Copy `templates/pdf.css`, `templates/resume.css`, `templates/reference.docx` from resume-pipeline
- ✅ Replace `index.md` with an index page linking to `resume.html`, `resume.pdf`, `resume.docx`, `resume.txt`
- ✅ Add `resume.md` (Gil's resume) with YAML frontmatter (`title`, `description`, `lang`); H1 removed (DEC-008)
- ✅ No duplicate name in any format; `reference.docx` Title style restyled to match Heading 1
- ✅ Port `build.sh`: output dir arg, title from frontmatter, install hints dropped
- ✅ `build.sh` builds `index.md` with `html.template.pandoc`, inheriting resume metadata (DEC-009)
- ✅ Resume HTML embeds CSS (DEC-010)
- ✅ `.gitignore` for `dist/` and `_site/`
- ✅ Local build verified: PDF rendered and checked; DOCX/TXT text matches resume-pipeline output

## Phase 2: GitHub Action

**Goal**: `pages.yml` builds everything with `./build.sh _site` and deploys it.

### Tasks

- ✅ Install pandoc and weasyprint via apt (Ubuntu 24.04: pandoc 3.1.3; no extra fonts)
- ✅ Replace inline pandoc command with `./build.sh _site`
- ✅ Check step fails the run if any of the five outputs is missing (so a skipped PDF is caught)
- Dropped: separate `workflow_dispatch` artifact upload; Pages already serves every file

## Phase 3: Mimeo integration and docs

**Goal**: The template works when Mimeo generates a repo from it, and is documented.

### Tasks

- ✅ Mimeo substitution: `{domain}` into index.md `title` (placeholder restored); manifest unchanged; verified with Mimeo's code (DEC-011)
- ✅ Rewrite `README.md` (usage, file roles, ATS-safety rules from resume-pipeline)
- ✅ `html.template.pandoc` used unchanged for the index page

## Phase 4: Verify and publish as template

**Goal**: Confirm the Action works in a real repo, then register the template.

### Tasks

- ✅ Pushed to `tepiton/pandoc-resume`; Action builds and deploys to https://tepiton.com/pandoc-resume/; all five files serve with correct types
- ✅ CI PDF was 3 pages in Liberation Sans; fixed by installing Carlito (DEC-012); now 2 pages
- ✅ `mimeo create 002371.xyz --template pandoc-resume` works: title substituted, dev files stripped, five files served (needed a manual workflow re-run; see Mimeo deploy race below)
- [ ] Mimeo deploy race: out-of-order push events can leave Pages on a pre-manifest commit; fix belongs in Mimeo (dispatch workflow on main after last commit)
- ✅ Replaced Gil's resume with a fictional sample (DEC-013)
- ✅ Richer index: name, objective, contact, last-updated date, file sizes, canonical/og:url (DEC-014, DEC-015)
- ✅ Dark mode for the HTML resume
- [ ] User sign-off that the template is finished
- [ ] Set `is_template`, topics on `tepiton/pandoc-resume` (repo already exists)
- [ ] Add to `TEMPLATES/CLAUDE.md` and `TEMPLATES/README.md`; update "all templates" counts (ten to eleven)

## Future Phases

None planned.
