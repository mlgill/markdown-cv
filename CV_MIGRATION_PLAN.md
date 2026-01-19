# CV Migration Plan: markdown-cv → mlgill.github.io

## Overview

Migrate CV generation from standalone `markdown-cv` repository into `mlgill.github.io`, producing:
- **Web pages**: Descriptive CV at `/cv/`, Concise CV at `/cv/concise/` (unlisted)
- **PDFs**: Both versions generated during Netlify build, identical to current markdown-cv output
- **Style**: Web CV uses markdown-cv styling embedded within mlgill.github.io navbar/footer shell

After migration, `markdown-cv` repository will be deprecated.

---

## Phase 1: File Migration

### 1.1 Copy Core Files

| From (markdown-cv) | To (mlgill.github.io) | Notes |
|-------------------|----------------------|-------|
| `_plugins/bibtex-filters.rb` | `_plugins/bibtex-filters.rb` | LaTeX→HTML conversion |
| `_plugins/load_external_data.rb` | *(delete)* | No longer needed - data is native |
| `_layouts/cv_bib.liquid` | `_layouts/cv_bib.liquid` | Already exists, verify identical |
| `media/davewhipp-print.css` | `assets/css/cv-print.css` | Rename for clarity |
| `media/davewhipp-screen.css` | `_sass/_cv-standalone.scss` | Convert to SCSS, scope styles |
| `generate-pdf.js` | `scripts/generate-cv-pdf.js` | PDF generation script |
| `package.json` | Merge into existing or create `scripts/package.json` | puppeteer-core dependency |

### 1.2 Create New Files

| File | Purpose |
|------|---------|
| `_layouts/cv-standalone.liquid` | New layout: mlgill.github.io shell + markdown-cv content styling |
| `_pages/cv.md` | Descriptive CV page (replaces current cv.md) |
| `_pages/cv-concise.md` | Concise CV page (unlisted) |
| `_includes/cv-standalone/header.liquid` | CV header (name, title, contact links) |
| `_includes/cv-standalone/section.liquid` | Reusable section template |

---

## Phase 2: Layout & Styling

### 2.1 Create `_layouts/cv-standalone.liquid`

Structure:
```liquid
---
layout: default
---
<div class="cv-standalone">
  {% if page.cv_pdf_descriptive or page.cv_pdf_concise %}
    <div class="cv-download-buttons">
      <!-- PDF download buttons -->
    </div>
  {% endif %}

  <div class="cv-content">
    {{ content }}
  </div>
</div>
```

### 2.2 Create `_sass/_cv-standalone.scss`

Convert `davewhipp-screen.css` to SCSS with scoped selectors:

```scss
// All CV-specific styles scoped under .cv-standalone
.cv-standalone {
  // Override al-folio defaults within CV
  font-family: Avenir, Verdana, sans-serif;

  .cv-content {
    // Port all davewhipp styles here
    // Adjust selectors: `p` → `.cv-content p`
  }

  // Restore sup/sub/i styling
  sup { vertical-align: super; font-size: 0.75em; line-height: 0; }
  sub { vertical-align: sub; font-size: 0.75em; line-height: 0; }
  i { font-style: italic; }
}
```

Key styling decisions:
- Keep Avenir font for CV content (different from site's Roboto)
- Keep dark red (#880000) headings
- Keep gray (#888) year codes and subheadings
- Keep 18%/58% positioning layout
- Presentation link colors match current

### 2.3 Print Stylesheet

Add `assets/css/cv-print.css` (or `_sass/_cv-print.scss`) with:
- `@media print` rules
- PDF-specific adjustments
- Same styling as current `davewhipp-print.css`

### 2.4 Import in Main SCSS

Add to `assets/css/main.scss`:
```scss
@import "cv-standalone";
```

---

## Phase 3: Page Templates

### 3.1 Descriptive CV (`_pages/cv.md`)

```yaml
---
layout: cv-standalone
permalink: /cv/
title: Curriculum Vitae
nav: true
nav_order: 10
cv_type: descriptive
cv_pdf_descriptive: GillMichelle_DescriptiveCV.pdf
cv_pdf_concise: GillMichelle_ConciseCV.pdf
description: Michelle Lynn Gill, Ph.D.
---
```

Content structure (ported from markdown-cv `index.md`):
1. Name & Title (h1)
2. Contact links (webaddress div)
3. Overview section
4. Education (visible entries)
5. Experience (visible entries)
6. Publications ({% bibliography --template cv_bib --group_by none %})
7. Patents (visible entries)
8. Presentations (visible entries)
9. Awards (visible entries)
10. Service (visible entries)

### 3.2 Concise CV (`_pages/cv-concise.md`)

```yaml
---
layout: cv-standalone
permalink: /cv/concise/
title: Curriculum Vitae (Concise)
nav: false  # Not in navbar
cv_type: concise
cv_pdf_descriptive: GillMichelle_DescriptiveCV.pdf
cv_pdf_concise: GillMichelle_ConciseCV.pdf
---
```

Content: Same structure but filtered to `selected == true` entries.

### 3.3 Download Buttons

In `cv-standalone.liquid`, add download buttons at top:

```liquid
{% if page.cv_pdf_descriptive or page.cv_pdf_concise %}
<div class="cv-download-buttons">
  {% if page.cv_pdf_descriptive %}
    <a href="{{ 'assets/pdf/' | append: page.cv_pdf_descriptive | relative_url }}"
       class="btn btn-cv-download" target="_blank">
      <i class="fa-solid fa-file-pdf"></i> Descriptive CV
    </a>
  {% endif %}
  {% if page.cv_pdf_concise %}
    <a href="{{ 'assets/pdf/' | append: page.cv_pdf_concise | relative_url }}"
       class="btn btn-cv-download" target="_blank">
      <i class="fa-solid fa-file-pdf"></i> Concise CV
    </a>
  {% endif %}
</div>
{% endif %}
```

---

## Phase 4: PDF Generation on Netlify

### 4.1 Update `generate-cv-pdf.js`

Modify script to:
- Find Chromium in Netlify build environment (`/usr/bin/google-chrome-stable` or similar)
- Accept base URL as parameter (use Netlify deploy URL or localhost)
- Output to `_site/assets/pdf/`

```javascript
const chromePath = process.env.CHROME_PATH ||
  '/usr/bin/google-chrome-stable' ||  // Netlify
  '/Applications/Chromium.app/Contents/MacOS/Chromium';  // Local macOS

const baseUrl = process.env.BASE_URL || 'http://localhost:4000';
```

### 4.2 Create `netlify.toml`

Currently mlgill.github.io has no `netlify.toml` - Netlify auto-detects Jekyll and pushes built site to `gh-pages` branch, which GitHub Pages serves.

Adding `netlify.toml` to enable PDF generation:

```toml
[build]
  command = "bundle exec jekyll build && npm install && node scripts/generate-cv-pdf.js"
  publish = "_site"

[build.environment]
  RUBY_VERSION = "3.3.10"
  NODE_VERSION = "20"
```

Note: Netlify build images include Chrome at `/usr/bin/google-chrome-stable`, which Puppeteer can use.

### 4.3 PDF Generation Flow

1. Jekyll builds site to `_site/`
2. Node script runs, loading `_site/cv/index.html` and `_site/cv/concise/index.html`
3. Puppeteer generates PDFs to `_site/assets/pdf/`
4. Netlify deploys complete `_site/` including PDFs

### 4.4 Local Development

Add npm scripts to root `package.json`:
```json
{
  "scripts": {
    "pdf": "node scripts/generate-cv-pdf.js",
    "pdf:local": "node scripts/generate-cv-pdf.js --base-url http://localhost:4000"
  }
}
```

---

## Phase 5: Configuration Updates

### 5.1 `_config.yml` Updates

Ensure scholar config includes:
```yaml
scholar:
  last_name: [Gill, Sippel]
  first_name: [Michelle, M.L., M.]
  style: science
  locale: en
  sort_by: year
  order: descending
  source: /_bibliography/
  bibliography: papers.bib
  bibliography_template: bib
  bibtex_filters: [mathmode, subscript, latex, smallcaps, superscript]
  replace_strings: true
  group_by: none
```

### 5.2 Verify `papers.bib`

Confirm `_bibliography/papers.bib` is the single source of truth (no symlink needed).

---

## Phase 6: Dark Mode (Future)

Initial implementation: CV always renders in light mode.

Future enhancement:
1. Create `_sass/_cv-standalone-dark.scss` with dark theme variables
2. Add JavaScript to detect theme and apply appropriate class
3. Update PDF generation to always use light mode (print stylesheets)

```scss
// Future dark mode support
.cv-standalone {
  --cv-heading-color: #880000;
  --cv-text-color: #000;
  --cv-bg-color: #fff;

  html[data-theme="dark"] & {
    --cv-heading-color: #ff6666;
    --cv-text-color: #e0e0e0;
    --cv-bg-color: #1a1a1a;
  }
}
```

---

## Implementation Order

| Step | Task | Estimated Complexity |
|------|------|---------------------|
| 1 | Copy `bibtex-filters.rb` plugin | Low |
| 2 | Create `_sass/_cv-standalone.scss` from screen CSS | Medium |
| 3 | Create `_layouts/cv-standalone.liquid` | Medium |
| 4 | Create `_pages/cv.md` (descriptive) | Medium |
| 5 | Create `_pages/cv-concise.md` | Low (copy + modify) |
| 6 | Add download buttons styling | Low |
| 7 | Test web rendering locally | - |
| 8 | Port `generate-cv-pdf.js` with environment detection | Medium |
| 9 | Update `netlify.toml` for PDF generation | Medium |
| 10 | Test PDF generation locally | - |
| 11 | Deploy to Netlify and verify | - |
| 12 | Delete redundant files, deprecate markdown-cv | Low |

---

## Questions Resolved

| Question | Answer |
|----------|--------|
| Web CV styling | Identical to markdown-cv, embedded in mlgill.github.io shell |
| PDF generation | Part of Netlify build |
| Download buttons | Yes, for both versions on cv.html |
| markdown-cv fate | Deprecated after migration |
| papers.bib | Native file (no symlink) |
| Concise CV URL | `/cv/concise/` |
| Descriptive CV URL | `/cv/` |
| Author underlining | Keep |
| Section order | Same as markdown-cv |

---

## Files to Delete from mlgill.github.io After Migration

- Current `_pages/cv.md` (replaced)
- Current `_layouts/cv.liquid` (replaced by cv-standalone.liquid, or keep for JSON resume fallback)
- `_includes/cv/*` (if no longer used)

---

## Rollback Plan

If issues arise:
1. markdown-cv remains functional as standalone
2. Revert mlgill.github.io to previous cv.liquid layout
3. Remove cv-standalone files

---

## Success Criteria

1. `/cv/` renders descriptive CV with correct styling + navbar/footer
2. `/cv/concise/` renders concise CV (not in nav)
3. PDFs download correctly from buttons
4. PDFs look identical to current markdown-cv output
5. Netlify build completes successfully with PDF generation
6. All LaTeX formatting (sup/sub/italics) renders correctly
7. Author names underlined in publications
