# CV Generation Plan

## Overview

A data-driven Jekyll CV site that reads structured YAML data from the `mlgill.github.io` repository. Uses the davewhipp style (customized). Deploys via Netlify.

**Architecture:** `mlgill.github.io/_data/` is the single source of truth for all CV content. This repo loads that data via a simple plugin and renders it as a printable CV.

## Quick Start

### Serve Locally
```bash
bundle exec jekyll serve --port 4001
```

### Generate PDF
```bash
# Requires: npm install puppeteer-core
node generate-pdf.js
```
This generates `GillMichelle_CV.pdf` with:
- Custom footer (name, date, page numbers) using Avenir font
- 0.5" margins (0.75" bottom for footer)
- Letter size format

### Deploy to Netlify
1. Push repository to GitHub
2. Create new site on Netlify, connect to repository
3. Build settings are configured in `netlify.toml`:
   - Build command: `bundle exec jekyll build`
   - Publish directory: `_site`
   - Ruby version: 3.3.10

## File Structure

```
markdown-cv/
├── _bibliography/
│   └── papers.bib              # → Symlink to mlgill.github.io/_bibliography/papers.bib
├── _layouts/
│   ├── cv.html                 # Main CV layout
│   └── bib.html                # Custom bibliography entry template
├── _plugins/
│   └── load_external_data.rb   # Loads YAML from mlgill.github.io/_data/
├── media/
│   ├── davewhipp-screen.css    # Screen styles
│   └── davewhipp-print.css     # Print/PDF styles
├── _config.yml                 # Jekyll + Scholar configuration
├── Gemfile                     # Ruby dependencies
├── netlify.toml                # Netlify deployment config
├── index.md                    # CV content with Liquid templating
├── generate-pdf.js             # Puppeteer PDF generation script
├── package.json                # Node.js dependencies (puppeteer-core)
└── PLAN.md                     # This file
```

## Data Architecture

All CV data lives in `mlgill.github.io/_data/` as YAML files:

| File | Contents | Loaded As |
|------|----------|-----------|
| `education.yml` | 3 education entries | `site.data.education` |
| `experience.yml` | 9 experience entries | `site.data.experience` |
| `service.yml` | 5 service entries | `site.data.service` |
| `awards.yml` | 6 award year-groups | `site.data.awards` |
| `patents.yml` | Patents by year | `site.data.patents` |
| `presentations.yml` | Presentations by year | `site.data.presentations` |
| `press.yml` | Media/press entries | `site.data.press` |
| `bio.yml` | Name, title, bio text | `site.data.bio` |
| `socials.yml` | Contact links | `site.data.socials` |

Publications use `_bibliography/papers.bib` (BibTeX) via jekyll-scholar.

### Visibility Flags

Each YAML entry supports:
- `visible: false` — Hide entry everywhere (archived)
- `selected: true` — Include in abbreviated CV (future use)

## Source File Mapping

| CV Section | Source | Format |
|------------|--------|--------|
| Name & Title | `bio.yml` | YAML |
| Contact Links | `socials.yml` | YAML |
| Currently (Bio) | `bio.yml` | YAML (markdown) |
| Education | `education.yml` | YAML |
| Experience | `experience.yml` | YAML |
| Publications | `papers.bib` | BibTeX |
| Patents | `patents.yml` | YAML (year-grouped) |
| Presentations | `presentations.yml` | YAML (year-grouped) |
| Awards | `awards.yml` | YAML (year-grouped) |
| Service | `service.yml` | YAML |

## Section Order

1. Name & Title (red)
2. Contact Links (GitHub, LinkedIn, Personal Website)
3. Currently (bio paragraph)
4. Education
5. Experience
6. Publications
7. Patents
8. Presentations
9. Awards
10. Service

## Plugin: load_external_data.rb

Simple YAML loader (~50 lines) that reads data files from `../mlgill.github.io/_data/`:

```ruby
module LoadExternalData
  class Generator < Jekyll::Generator
    SOURCE_REPO = '../mlgill.github.io'
    DATA_FILES = %w[education experience service awards patents presentations press bio socials]

    def generate(site)
      data_path = File.join(File.expand_path(SOURCE_REPO, site.source), '_data')
      DATA_FILES.each do |name|
        file = File.join(data_path, "#{name}.yml")
        site.data[name] = YAML.safe_load(File.read(file)) if File.exist?(file)
      end
    end
  end
end
```

## PDF Generation: generate-pdf.js

Uses Puppeteer with existing Chromium installation (`puppeteer-core`):

```javascript
await page.pdf({
  path: outputPath,
  format: 'Letter',
  printBackground: true,
  margin: { top: '0.5in', right: '0.5in', bottom: '0.75in', left: '0.5in' },
  displayHeaderFooter: true,
  headerTemplate: '<div></div>',
  footerTemplate: `
    <div style="font-family: Avenir, Verdana, sans-serif; font-size: 9px; ...">
      <span>Michelle Lynn Gill · Prepared ${date}</span>
      <span>Page <span class="pageNumber"></span> of <span class="totalPages"></span></span>
    </div>
  `,
});
```

## Template Patterns in index.md

### Education
```liquid
{% for edu in site.data.education %}
{% if edu.visible != false %}
`{{ edu.year }}`
__{{ edu.title }}__
<br>{{ edu.institution }}, {{ edu.location }}
{% endif %}
{% endfor %}
```

### Year-Grouped Data (Patents, Presentations)
```liquid
{% for year_group in site.data.patents %}
{% for patent in year_group.entries %}
{% if patent.visible != false %}
`{{ year_group.year }}`
{{ patent.title }}
- {{ patent.authors }}
- {{ patent.details }}
{% endif %}
{% endfor %}
{% endfor %}
```

### Relative URL Handling
Links from mlgill.github.io data that start with `/` are converted to absolute URLs:
```liquid
{% if pres.links.slides contains "://" %}
  <a href="{{ pres.links.slides }}">Slides</a>
{% else %}
  <a href="https://mlgill.github.io{{ pres.links.slides }}">Slides</a>
{% endif %}
```

## CSS Customizations

### Layout (both screen and print)
- Content positioned at 18% from left
- Section headers (h2, h3) width: 14%
- Paragraph width: 58%
- Year codes positioned at right: -32%

### Name Styling
- h1 color: #bc412b (screen) / #a00 (print)

### Bibliography
- `ol.bibliography`: no list styling, full width container
- `ol.bibliography li p`: positioned at 18% left, 58% width

## Configuration

### _config.yml
```yaml
markdown: kramdown
style: davewhipp

plugins:
  - jekyll-scholar

scholar:
  style: science
  sort_by: year
  order: descending
  source: ./_bibliography
  bibliography: papers.bib
  bibliography_template: bib
```

### Gemfile
```ruby
source "https://rubygems.org"
gem "jekyll", "~> 4.3"
gem "jekyll-scholar", "~> 7.0"
gem "kramdown-parser-gfm"
gem "webrick"
```

## Important Notes

- Jekyll Scholar is NOT supported on GitHub Pages — use Netlify
- Requires `../mlgill.github.io` directory to exist relative to markdown-cv
- PDF generation requires Node.js and `puppeteer-core`
- Uses existing Chromium at `/Applications/Chromium.app/Contents/MacOS/Chromium`

---

## TODO

- [ ] **Hide footer on first page of PDF** — Puppeteer's header/footer templates don't reliably execute JavaScript. Possible approaches:
  - Post-process PDF with a library (pdf-lib, PyPDF2) to remove footer from page 1
  - Use CSS `@page :first` in the main document (but doesn't affect Puppeteer's isolated footer)
  - Inject footer into page content instead of using Puppeteer's footer system

- [ ] **Combine repositories** — Eventually merge markdown-cv into mlgill.github.io as a subdirectory or build target

- [x] **Implement `selected` flag filtering** — Two CV versions now available:
  - `descriptive.md` → `GillMichelle_DescriptiveCV.pdf`: Shows entries where `visible != false`
  - `concise.md` → `GillMichelle_ConciseCV.pdf`: Shows entries where `visible != false AND selected == true`
  - Footer format: "Michelle Lynn Gill, [CV Type]" | "Page X of Y" | "[Date]"
  - Use `npm run pdf` to generate both, or `npm run pdf:descriptive` / `npm run pdf:concise` for individual

- [x] **Add npm scripts to package.json** — `npm run pdf`, `npm run serve`, etc.
