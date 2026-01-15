# CV Generation Plan

## Overview

A data-driven Jekyll CV site that reads content from YAML, BibTeX, and Markdown files sourced from the mlgill.github.io repository. Uses the davewhipp style (customized). Deploys via Netlify.

## Quick Start

### Build Site
```bash
/opt/homebrew/opt/ruby@3.3/bin/bundle exec jekyll build
```

### Serve Locally
```bash
/opt/homebrew/opt/ruby@3.3/bin/bundle exec jekyll serve
```

### Generate PDF
```bash
/Applications/Chromium.app/Contents/MacOS/Chromium \
  --headless \
  --print-to-pdf="/Volumes/Files/code/markdown-cv/GillMichelle_CV.pdf" \
  --no-pdf-header-footer \
  "file:///Volumes/Files/code/markdown-cv/_site/index.html"
```

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
│   └── papers.bib              # Publications in BibTeX format
├── _data/
│   ├── cv.yml                  # Education, Experience, Awards, Service
│   └── socials.yml             # Contact links (email, GitHub, LinkedIn)
├── _layouts/
│   ├── cv.html                 # Main CV layout
│   └── bib.html                # Custom bibliography entry template
├── _plugins/
│   └── markdown_data.rb        # Parses patents.md, presentations.md, about.md
├── media/
│   ├── davewhipp-screen.css    # Screen styles
│   └── davewhipp-print.css     # Print/PDF styles
├── _config.yml                 # Jekyll + Scholar configuration
├── Gemfile                     # Ruby dependencies
├── netlify.toml                # Netlify deployment config
├── index.md                    # CV content with Liquid templating
└── PLAN.md                     # This file
```

## Source File Mapping

| CV Section | Source File | Format |
|------------|-------------|--------|
| Name & Title | `mlgill.github.io/_pages/about.md` | Markdown frontmatter |
| Contact Links | `mlgill.github.io/_data/socials.yml` + hardcoded | YAML |
| Currently (Bio) | `mlgill.github.io/_pages/about.md` | Markdown |
| Education | `mlgill.github.io/_data/cv.yml` | YAML |
| Experience | `mlgill.github.io/_data/cv.yml` | YAML |
| Publications | `mlgill.github.io/_bibliography/papers.bib` | BibTeX |
| Patents | `mlgill.github.io/_pages/patents.md` | Markdown (parsed by plugin) |
| Presentations | `mlgill.github.io/_pages/presentations.md` | Markdown (parsed by plugin) |
| Awards | `mlgill.github.io/_data/cv.yml` | YAML |
| Service | `mlgill.github.io/_data/cv.yml` | YAML |

## Section Order

1. Name & Title (red)
2. Contact Links (email, GitHub, LinkedIn, Personal Website)
3. Currently (bio paragraph)
4. Education
5. Experience
6. Publications
7. Patents
8. Presentations (with slides links)
9. Awards
10. Service

## Configuration Files

### _config.yml
```yaml
markdown: kramdown
style: davewhipp

plugins:
  - jekyll-scholar

scholar:
  style: science
  locale: en
  sort_by: year
  order: descending
  source: ./_bibliography
  bibliography: papers.bib
  bibliography_template: bib
  replace_strings: true
  group_by: none
```

### Gemfile
```ruby
source "https://rubygems.org"

gem "jekyll", "~> 4.3"
gem "jekyll-scholar", "~> 7.0"
gem "kramdown-parser-gfm"
gem "webrick"
```

### netlify.toml
```toml
[build]
  command = "bundle exec jekyll build"
  publish = "_site"

[build.environment]
  RUBY_VERSION = "3.3.10"
  JEKYLL_ENV = "production"
```

## Custom Components

### Plugin: _plugins/markdown_data.rb

Parses markdown files from `../mlgill.github.io` at build time:

- **Patents** (`_pages/patents.md`) → `site.data.patents`
  - Array of `{ year, entries: [{ title, authors, details }] }`

- **Presentations** (`_pages/presentations.md`) → `site.data.presentations`
  - Array of `{ year, entries: [{ title, venue, authors, details, slides_url }] }`
  - Extracts slides URLs and converts relative paths to absolute (https://mlgill.github.io/...)

- **Bio** (`_pages/about.md`) → `site.data.bio`
  - Hash with `name`, `title`, `bio`

### Template: _layouts/bib.html

Custom bibliography entry format:
```html
<p>{{ entry.author | replace: " and ", ", " }}. "{{ entry.title }}." <strong>{{ entry.journal }}</strong>{% if entry.volume %} {{ entry.volume }}{% endif %}{% if entry.pages %}, {{ entry.pages | replace: "--", "–" }}{% endif %} ({{ entry.year }}){% if entry.doi and entry.journal != "In preparation" %}, <a href="https://doi.org/{{ entry.doi }}">doi: {{ entry.doi }}</a>{% endif %}.</p>
```

Format: `Authors. "Title." **Journal** Volume, Pages (Year), doi: DOI.`

## CSS Customizations

### Layout Changes (both screen and print)
- Content positioned at 18% from left (was 25%)
- Section headers (h2, h3) width: 14% (was 20%)
- Paragraph width: 58%
- List width: 72%
- Year codes positioned at right: -32% (was -20%)

### Name Styling
- h1 color: #bc412b (screen) / #a00 (print) - red

### List Items
- Removed hanging indent (padding-left, text-indent)
- Added `li p { left: 0; width: 100%; }` for nested paragraphs

### Bibliography
- `ol.bibliography`: no list styling, full width container
- `ol.bibliography li p`: positioned at 18% left, 58% width
- `h2.bibliography`: hidden (no year group headers)

## Template Patterns in index.md

### Education (degree and institution on separate lines)
```liquid
{% for edu in education.contents %}
`{{ edu.year }}`
__{{ edu.title }}__
<br>{{ edu.institution }}, {{ edu.location }}
{% if edu.description %}
{% for desc in edu.description %}
- {{ desc }}
{% endfor %}
{% endif %}
{% endfor %}
```

### Presentations (with slides links)
```liquid
{% for pres in year_group.entries %}
`{{ year_group.year }}`
__{{ pres.title }}__{% if pres.venue %}, *{{ pres.venue }}*{% endif %}
{% if pres.authors and pres.authors != "" %}- {{ pres.authors }}
{% endif %}{% if pres.details and pres.details != "" %}- {{ pres.details }}
{% endif %}{% if pres.slides_url and pres.slides_url != "" %}- [Slides]({{ pres.slides_url }})
{% endif %}
{% endfor %}
```

### Publications (via Jekyll Scholar)
```liquid
{% bibliography %}
```
Uses custom `_layouts/bib.html` template.

### Contact Links
```html
<div id="webaddress">
{% if site.data.socials.email %}<a href="mailto:{{ site.data.socials.email }}">{{ site.data.socials.email }}</a> | {% endif %}
<a href="https://github.com/{{ site.data.socials.github_username }}">GitHub</a> |
<a href="https://linkedin.com/in/{{ site.data.socials.linkedin_username }}">LinkedIn</a> |
<a href="https://michellelynngill.com">Personal Website</a>
</div>
```

## BibTeX Notes

### Superscript/Subscript in Titles
Use HTML tags in papers.bib:
```bibtex
title={<sup>205</sup>Tl NMR methods...}
title={...for <sup>13</sup>C<sup>1</sup>H<sub>3</sub> methyl groups...}
```

### In Preparation Papers
Set `journal={In preparation}` - DOI will be omitted automatically.

## macOS Setup Notes

### Ruby Installation
```bash
brew install ruby@3.3
```

### If eventmachine fails to build
```bash
export SDKROOT=$(xcrun --show-sdk-path)
export CXXFLAGS="-I${SDKROOT}/usr/include/c++/v1"
/opt/homebrew/opt/ruby@3.3/bin/gem install eventmachine -- --with-cxxflags="$CXXFLAGS"
```

### Install Dependencies
```bash
/opt/homebrew/opt/ruby@3.3/bin/bundle install
```

## Important Notes

- Jekyll Scholar is NOT supported on GitHub Pages - use Netlify
- The plugin requires `../mlgill.github.io` directory to exist relative to markdown-cv
- GPU-related error messages from Chromium PDF generation can be ignored
- PDF generation uses print CSS styles
