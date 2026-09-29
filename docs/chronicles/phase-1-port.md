# Phase 1: Port the pipeline

## Entry 2: Local build working (2026-09-28)

**What**: Ported resume-pipeline into this repo; `./build.sh` builds index.html, resume.html/pdf/docx/txt.

**Why**: One build script for local use and the GitHub Action (DEC-003).

**How**:

- Copied `templates/` and Gil's `resume.md`; moved the name from `# H1` to frontmatter `title`
- Restyled `reference.docx` Title style to match Heading 1 so the DOCX looks unchanged
- `build.sh` reads name and metadata via pandoc templates (`$title$`, `$meta-json$`), builds index with inherited metadata, embeds CSS in resume.html
- Installed weasyprint via Homebrew; checked PDF render; DOCX/TXT text matches the old output

**Decisions**:

- DEC-008: name only in frontmatter title
- DEC-009: index inherits resume metadata
- DEC-010: embed CSS in resume.html

**Files**: `build.sh`, `resume.md`, `index.md`, `templates/`, `.gitignore`, `README.md`

## Entry 3: Workflow calls build.sh (2026-09-28)

**What**: `pages.yml` installs pandoc and weasyprint from apt, runs `./build.sh _site`, and checks all five outputs exist.

**Why**: CI and local builds share one script (DEC-003).

**How**:

- apt `pandoc weasyprint` on ubuntu-latest (24.04); no extra fonts (DEC-006)
- Output check step makes a missing PDF fail the run instead of being skipped silently
- Not yet run on GitHub; verification is Phase 4

**Files**: `.github/workflows/pages.yml`

## Entry 4: Mimeo substitution resolved (2026-09-28)

**What**: Restored `title` in index.md as a placeholder that Mimeo sets to the domain; resume name stays hand-edited.

**Why**: Mimeo's frontmatter handler fails if the key is missing, and Mimeo DEC-024 limits substitution to the domain.

**How**:

- Read Mimeo's `template_manifest.py` and DEC-024
- User chose "domain on index" over no substitution or domain-as-name
- Verified with Mimeo's `apply_substitutions` on a copy, then built: index heading `gilborenstein.com`

**Decisions**:

- DEC-011: domain into index.md title

**Files**: `index.md`, `README.md`, `docs/`

## Entry 5: First deploy and font fix (2026-09-28)

**What**: The user pushed to `tepiton/pandoc-resume`, enabled the workflow and Pages. The Action succeeded; the PDF was 3 pages in CI vs 2 locally.

**Why**: Ubuntu runner lacked Calibri/Carlito; Liberation Sans is wider.

**How**:

- Checked all five deployed files (HTTP 200, correct types)
- `pdffonts` showed Liberation Sans; added `fonts-crosextra-carlito` to apt install
- Re-run: PDF is 2 pages in Carlito
- Removed README WIP note

**Decisions**:

- DEC-012: install Carlito (supersedes DEC-006)

**Files**: `.github/workflows/pages.yml`, `README.md`, `docs/`

## Entry 6: mimeo create end-to-end (2026-09-28)

**What**: User ran `mimeo create 002371.xyz --template pandoc-resume --force --yes`. Substitution and dev-file stripping worked; the live site first showed the placeholder title.

**Why**: Mimeo's rapid commits each trigger a run; the `pages` concurrency group cancelled pending runs, and a late push event for pre-manifest commit `e959ff5` was the only run to finish. HEAD `56f68ac` was cancelled.

**How**:

- Manual `gh workflow run` on main deployed `56f68ac`; site now shows `002371.xyz`
- Mimeo strips README, CLAUDE.md, docs/, mimeo.template.json from generated repos
- Race affects all templates; proposed Mimeo fix: dispatch the workflow on main after the final commit

**Files**: `docs/`

## Entry 7: Fictional sample resume (2026-09-28)

**What**: Replaced Gil's resume in `resume.md` with a fictional one: Wren Ashcombe, artificer, invented fantasy schools and employers, `example.com` email, 555-01xx phone.

**Why**: The template is public; real personal data should not ship in it.

**How**:

- Kept the same sections and bullet structure so layout is representative
- First draft ran to 3 pages by one line; tightened three bullets to get back to 2
- Updated `CLAUDE.md`; DEC-005 superseded

**Decisions**:

- DEC-013: fictional sample resume

**Files**: `resume.md`, `CLAUDE.md`, `docs/`

## Entry 8: Richer index, frontmatter contact (2026-09-28)

**What**: Index now shows the resume's name, objective, contact line, last-updated date, and file sizes. Objective and contact moved into resume.md frontmatter.

**Why**: User wanted the index to present the person, with no data pulled from body text.

**How**:

- `resume-header.lua` renders contact line and objective in all four formats from frontmatter
- `index.lua` appends sizes to index links (RESUME_OUTDIR)
- `html.template.pandoc`: objective fallback subtitle, contact line, "Updated" date, canonical/og:url
- Manifest now targets index.md `url`; the index filter stringifies it (gfm auto-links URLs in frontmatter too)
- Workflow checkout uses `fetch-depth: 0` for the git date; index checked at 375px in dark mode

**Decisions**:

- DEC-014: objective and contact as frontmatter keys
- DEC-015: index title from resume; Mimeo sets `url` (supersedes DEC-011)

**Files**: `resume.md`, `index.md`, `build.sh`, `html.template.pandoc`, `templates/*.lua`, `mimeo.template.json`, `.github/workflows/pages.yml`, `README.md`, `CLAUDE.md`, `docs/`
