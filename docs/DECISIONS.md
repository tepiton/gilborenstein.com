# Decisions

Architectural decisions for this project. Search with `grep -i "keyword" docs/DECISIONS.md`.

## Active Decisions

### DEC-001: resume.md is the single source of truth (2026-09-28)

**Status**: Active

**Context**: The resume-pipeline project already established this (its DEC-001). The template must keep it while also feeding a website.

**Decision**: All content lives in `resume.md`, including YAML frontmatter for name and metadata. HTML, PDF, DOCX, and TXT are generated from it.

**Alternatives considered**: Keeping the name in a separate config file; parsing the name from the H1.

**Consequences**: Frontmatter must not render as a duplicate heading in any output. Mimeo substitution targets `resume.md` frontmatter.

---

### DEC-002: Index page is a separate, customizable index.md (2026-09-28)

**Status**: Active

**Context**: The Pages site root needs to work and link to several files. The user may want to customize it.

**Decision**: `index.md` is a normal Markdown page that links to `resume.html`, `resume.pdf`, `resume.docx`, and `resume.txt`. It is built independently of the resume.

**Alternatives considered**: Making the resume HTML the site root with download links; copying `resume.html` to `index.html`.

**Consequences**: Two build targets (index and resume). Index links are relative and static.

---

### DEC-003: build.sh is the single build entry point, used locally and in CI (2026-09-28)

**Status**: Active

**Context**: The pipeline already has `build.sh`. Duplicating pandoc commands in the workflow would let CI and local builds drift.

**Decision**: The workflow runs `./build.sh _site`. Dependency install hints (brew/apt) are removed from the script since CI installs dependencies.

**Alternatives considered**: Inline pandoc/weasyprint commands in `pages.yml`.

**Consequences**: The workflow stays short. `build.sh` needs a title derived from frontmatter rather than a hardcoded name.

---

### DEC-004: Keep html.template.pandoc for the index page; resume.css for the resume HTML (2026-09-28)

**Status**: Active

**Context**: The user left this to my call. `pandoc-simple`'s `html.template.pandoc` is a general page template; the resume HTML uses `resume.css`, a centered reading column.

**Decision**: Use `html.template.pandoc` for `index.md`, so the index remains a customizable pandoc-simple-style page. The resume HTML uses pandoc's default template with `--css=templates/resume.css`, as in resume-pipeline.

**Alternatives considered**: Dropping `html.template.pandoc` and styling everything with CSS only; using the template for the resume too.

**Consequences**: Keeps the resume HTML identical to the existing pipeline output. May revisit if the two pages should look alike. `resume.css` gained a `prefers-color-scheme: dark` variant (2026-09-28) using the same dark background/text colors as `html.template.pandoc`, so both pages follow the system theme.

---

### DEC-005: Sample content is Gil Borenstein's resume (2026-09-28)

**Status**: Superseded by DEC-013

**Context**: The template exists for this resume.

**Decision**: Ship Gil's `resume.md` as the sample, with frontmatter added.

**Alternatives considered**: Generic placeholder resume.

**Consequences**: Mimeo substitution must replace the name for other users. Personal contact info ships in the template repo.

---

### DEC-006: Default fonts, weasyprint in CI (2026-09-28)

**Status**: Superseded by DEC-012

**Context**: `pdf.css` requests Carlito/Calibri/Arial. The user does not care about exact PDF fonts.

**Decision**: Do not install extra fonts in CI. Install only pandoc and weasyprint (plus required Pango libraries).

**Alternatives considered**: Installing `fonts-crosextra-carlito` to match local output.

**Consequences**: CI PDF may look slightly different from a local PDF. Acceptable.

---

### DEC-007: Template is not registered until approved (2026-09-28)

**Status**: Active

**Context**: The user wants to be happy with the template before it appears in the org docs.

**Decision**: Do not create the GitHub repo, set `is_template`, or edit `TEMPLATES/CLAUDE.md` / `README.md` until the user approves.

**Alternatives considered**: Registering early.

**Consequences**: Phase 4 gates on user sign-off.

---

### DEC-008: Name lives only in frontmatter `title`; no H1 in resume.md (2026-09-28)

**Status**: Active

**Context**: With both a frontmatter `title` and a `# Name` heading, pandoc prints the name twice (title block plus H1) in HTML, PDF, and DOCX. Keeping only the H1 means build.sh would have to parse Markdown to get the name.

**Decision**: The name is the frontmatter `title`, and `resume.md` has no H1. Pandoc renders it as `h1.title` in HTML/PDF, a Title paragraph in DOCX, and the first line of TXT (built with `--standalone`). The `Title` style in `templates/reference.docx` was restyled to match `Heading 1` (green, left-aligned, same size), so the DOCX looks the same as before.

**Alternatives considered**: Keeping the H1 with a separate frontmatter `name` key (name stored twice); parsing the H1 in build.sh.

**Consequences**: One place for the name. build.sh reads it with a `$title$` template and sets `pagetitle` to "Name - Resume". The resume's first heading in DOCX is Title rather than Heading 1.

---

### DEC-009: index.md inherits resume.md metadata (2026-09-28)

**Status**: Active

**Context**: The index page should show the person's name without storing it a second time.

**Decision**: build.sh dumps resume.md's metadata as JSON (`$meta-json$` template, valid YAML) and passes it to the index build with `--metadata-file`. Values set in index.md's own frontmatter win.

**Alternatives considered**: Duplicating title in index.md; passing `-M title=` (would override index.md).

**Consequences**: index.md inherits description and lang. Its `title` is set in index.md itself for Mimeo (DEC-011), so the resume's name is not inherited as the index heading.

---

### DEC-010: Resume HTML embeds its CSS (2026-09-28)

**Status**: Active

**Context**: resume-pipeline linked `templates/resume.css` by relative path, which does not exist inside `dist/` or `_site/`.

**Decision**: Build `resume.html` with `--embed-resources`, so the file is self-contained.

**Alternatives considered**: Copying the CSS into the output directory.

**Consequences**: `resume.html` works when served or downloaded on its own.

---

### DEC-011: Mimeo substitutes the domain into index.md title, not the resume name (2026-09-28)

**Status**: Superseded by DEC-015

**Context**: `mimeo.template.json` targeted index.md `title`, which DEC-009 had removed; Mimeo's `yaml-frontmatter-key` handler fails the deploy if the key is missing. Mimeo's own DEC-024 limits substitution to the site's domain self-reference; names and bios are authoring, not Mimeo's job.

**Decision**: index.md keeps `title: "pandoc-resume"` as a placeholder; the manifest (unchanged) sets it to `{domain}`. The index heading reads the domain, subtitle "Resume". resume.md's `title` (the person's name) is edited by hand.

**Alternatives considered**: No substitution (index heading = name inherited from resume.md); substituting the domain into resume.md `title` (outputs would show the domain as the name; contradicts Mimeo DEC-024).

**Consequences**: Deploys succeed. Verified with Mimeo's `apply_substitutions` against a copy of the template, then a build: index shows `gilborenstein.com`.

---

### DEC-012: Install Carlito in CI (2026-09-28)

**Status**: Active

**Context**: First CI run (DEC-006, no extra fonts) rendered the PDF in Liberation Sans, which is wider than Calibri: 3 pages in CI vs 2 locally, with only "Hardware Systems" on page 3.

**Decision**: Add `fonts-crosextra-carlito` (metric-compatible with Calibri) to the apt install. `pdf.css` already lists Carlito first.

**Alternatives considered**: Tightening `pdf.css` spacing/size to fit Liberation Sans; accepting 3 pages.

**Consequences**: CI PDF layout matches local Calibri output. One more small apt package.

---

### DEC-013: Fictional sample resume (2026-09-28)

**Status**: Active

**Context**: The template repo is public and generated sites start from its `resume.md`. Shipping a real person's name, email, phone, schools, and employers exposes personal data and has to be scrubbed by every user.

**Decision**: The sample is a fictional artificer, Wren Ashcombe (gender-neutral name), from an invented fantasy setting: Collegium Mechanica of Vell, Brightwater Academy, and similar made-up institutions. Email is `wren.ashcombe@example.com`, phone `(555) 555-0142` (555-01xx is reserved for fiction). Section structure matches the original so layout and page count (2) are representative.

**Alternatives considered**: Keeping Gil's resume (DEC-005); a generic "Your Name / Company" placeholder resume.

**Consequences**: Gil's real resume lives in its own site repo, not the template. Sample content was trimmed slightly to stay at 2 pages.

---

### DEC-014: Objective and contact details are frontmatter keys (2026-09-28)

**Status**: Active

**Context**: The index should show the name, objective, and contact details. These lived in the resume body as a contact paragraph and an objective paragraph. The user ruled out extracting data from body text by position.

**Decision**: `resume.md` frontmatter has `objective`, `email`, `phone`, `location` (and optional `website`). `templates/resume-header.lua` inserts the contact line (plain text, " - " separated), a rule, and the objective at the top of every resume format. The index template renders the same keys (objective as subtitle, email as a mailto link).

**Alternatives considered**: A Lua filter reading the first paragraph after the rule (implicit convention); keeping the text in the body and duplicating it in frontmatter.

**Consequences**: Resume outputs look the same as before. Anything new the index needs becomes a frontmatter key, never parsed from the body.

---

### DEC-015: Index shows the resume name; Mimeo sets `url` (2026-09-28)

**Status**: Active

**Context**: The user wants the index title to be the name and the subtitle the objective. Mimeo's manifest must still target a key that exists in index.md.

**Decision**: index.md no longer sets `title` or `subtitle`; both come from resume.md (subtitle falls back to `objective` in the template). index.md has `url: "https://example.com/"`, which the manifest sets to `https://{domain}/`; the template emits it as `<link rel="canonical">` and `og:url`. The index filter (`index.lua`) stringifies `url`, because the gfm reader auto-links bare URLs even in frontmatter; body autolinking stays on.

**Alternatives considered**: Dropping the manifest; a visible `site:` key.

**Consequences**: The domain is used only for the site's own address, as Mimeo DEC-024 intends. Verified with Mimeo's `apply_substitutions`.

---

## Superseded/Deprecated

None yet.
