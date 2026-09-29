#!/usr/bin/env bash
# build.sh — render resume.md (the single source of truth) into every
# output format a job application might need, plus an index page.
#
# Usage: ./build.sh [output-dir]   (default output dir: ./dist)
#
# Requires: pandoc (hard requirement) and weasyprint (for the PDF only —
# if it's missing, the PDF is skipped and everything else still builds).
# The GitHub Actions workflow runs this same script: ./build.sh _site

set -uo pipefail
cd "$(dirname "$0")"

SRC="resume.md"
INDEX="index.md"
OUTDIR="${1:-dist}"

# --- Preflight: make sure we have what we need --------------------------
echo "Checking dependencies..."
MISSING_HARD=0
SKIP_PDF=0

if command -v pandoc >/dev/null 2>&1; then
  echo "  [ok]      pandoc  ($(pandoc --version | head -1))"
else
  echo "  [MISSING] pandoc — required, can't build anything without it."
  MISSING_HARD=1
fi

if command -v weasyprint >/dev/null 2>&1; then
  echo "  [ok]      weasyprint  ($(weasyprint --version 2>&1))"
else
  echo "  [missing] weasyprint — only needed for the PDF; the rest still builds."
  SKIP_PDF=1
fi

for f in "$SRC" "$INDEX" html.template.pandoc \
         templates/reference.docx templates/pdf.css templates/resume.css \
         templates/resume-header.lua templates/index.lua; do
  if [ -f "$f" ]; then
    echo "  [ok]      $f"
  else
    echo "  [MISSING] $f — required source/template file not found."
    MISSING_HARD=1
  fi
done

if [ "$MISSING_HARD" -eq 1 ]; then
  echo ""
  echo "Missing something required above — fix it and re-run. Nothing was built."
  exit 1
fi

echo ""
set -e

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# --- Metadata from resume.md frontmatter ------------------------------
# NAME feeds the page/PDF title. meta.yaml lets index.md inherit the
# resume's frontmatter (title, objective, contact, ...) unless it sets
# its own.
printf '%s' '$title$' > "$TMP/title.tpl"
printf '%s' '$meta-json$' > "$TMP/meta.tpl"
NAME="$(pandoc "$SRC" -t plain --template="$TMP/title.tpl")"
pandoc "$SRC" -t markdown --template="$TMP/meta.tpl" > "$TMP/meta.yaml"

if [ -z "$NAME" ]; then
  echo "resume.md has no 'title' in its frontmatter — add your name there."
  exit 1
fi
PAGETITLE="$NAME - Resume"

# Date resume.md last changed in git (needs full history in CI), else today.
UPDATED="$(git log -1 --format=%cd --date=format:'%B %-d, %Y' -- "$SRC" 2>/dev/null || true)"
[ -n "$UPDATED" ] || UPDATED="$(date '+%B %-d, %Y')"

# Contact line and objective come from frontmatter (resume-header.lua).
HEADER=(--lua-filter=templates/resume-header.lua)

mkdir -p "$OUTDIR"
echo "Building from $SRC -> $OUTDIR/"

# --- PDF (human-facing, styled) ---------------------------------------
# Pandoc converts markdown -> HTML, then hands it to weasyprint, which
# lays it out with templates/pdf.css. No LaTeX/TeX install required.
if [ "$SKIP_PDF" -eq 0 ]; then
  pandoc "$SRC" \
    -o "$OUTDIR/resume.pdf" \
    "${HEADER[@]}" \
    --pdf-engine=weasyprint \
    --css=templates/pdf.css \
    --metadata pagetitle="$PAGETITLE"
fi

# --- DOCX (human-facing, styled; what most ATS actually parse best) ---
pandoc "$SRC" \
  -o "$OUTDIR/resume.docx" \
  "${HEADER[@]}" \
  --reference-doc=templates/reference.docx

# --- Plain text (maximally ATS-safe fallback / paste-into-textarea) ---
# --standalone so the name (frontmatter title) is included.
pandoc "$SRC" \
  -o "$OUTDIR/resume.txt" \
  "${HEADER[@]}" \
  --to=plain \
  --standalone \
  --wrap=none

# --- HTML (web version) -------------------------------------------------
# CSS is embedded so the page is self-contained wherever it's served.
pandoc "$SRC" \
  -o "$OUTDIR/resume.html" \
  "${HEADER[@]}" \
  --standalone \
  --embed-resources \
  --metadata pagetitle="$PAGETITLE" \
  --css=templates/resume.css

# --- Index page (links to the files above) ----------------------------
# Built last so index.lua can measure the files it links to.
RESUME_OUTDIR="$OUTDIR" pandoc "$INDEX" \
  -o "$OUTDIR/index.html" \
  --standalone \
  --template=html.template.pandoc \
  --metadata-file="$TMP/meta.yaml" \
  --metadata updated="$UPDATED" \
  --lua-filter=templates/index.lua \
  -f gfm

echo "Done. Files in $OUTDIR/:"
ls -la "$OUTDIR"
if [ "$SKIP_PDF" -eq 1 ]; then
  echo ""
  echo "Note: resume.pdf was NOT built (weasyprint missing)."
fi
